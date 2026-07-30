import { getApps, initializeApp } from "firebase-admin/app";
import {
  FieldPath,
  FieldValue,
  getFirestore,
  type DocumentData,
  type Firestore,
} from "firebase-admin/firestore";
import {
  onDocumentWritten,
  type Change,
  type DocumentSnapshot,
  type FirestoreEvent,
} from "firebase-functions/v2/firestore";
import { withTriggerErrorReporting } from "../errors/withErrorReporting.js";
import { generateRawToken } from "./crypto.js";
import { functionsBaseUrl } from "./env.js";
import { isAlreadyExistsError } from "./firestoreHelpers.js";
import { buildCampaignMail, type MailDocument } from "./mailRender.js";
import {
  NEWSLETTER_CAMPAIGNS_COLLECTION,
  NEWSLETTER_CAMPAIGN_DELIVERIES_SUBCOLLECTION,
  NEWSLETTER_SUBSCRIBERS_COLLECTION,
  MAIL_COLLECTION,
} from "./collections.js";

// Fan-out trigger for a newsletter campaign, mirroring the command-document
// pattern moderationCommand.ts / leaderboardAdminCommand.ts use for
// admin-console-initiated work, except the "command" here is the
// newsletterCampaigns document's own status field rather than a separate
// commands collection — the admin console (or a future admin UI) simply
// writes status "queued" (real send) or "testQueued" (send-to-testRecipients
// only) onto the campaign it already owns.
//
// SAFETY / idempotency: this fires on EVERY write to a campaign document,
// including this trigger's own status/count updates, so it must ignore
// almost everything. It only acts when the write is ENTERING "queued" or
// "testQueued" from some other status (a fresh queue action, not a retry of
// an already-queued write or one of this trigger's own writes back onto the
// document). Even then, the actual state transition is re-validated inside
// a transaction (claimCampaign) rather than trusted from the event's before/
// after snapshots, so a redelivered trigger event can only ever claim the
// campaign once: BOTH modes move the document out of their claimed status
// (queued -> sending, testQueued -> draft) inside the SAME transaction that
// verifies the expected status, before any mail is sent. By the time a
// retry re-reads the document, status is already "sending"/"draft" (or
// later "sent"/"failed"), never still "queued"/"testQueued", and the claim
// is refused. A test send flipping straight to "draft" (rather than some
// intermediate "testSending") is deliberate: "draft" is not an ENTER target
// this trigger ever acts on, so it cannot re-trigger itself, and it is also
// the correct terminal state for a test send per spec.
const PAGE_SIZE = 200;

export type CampaignSnapshot = {
  readonly subject: string;
  readonly bodyMarkdown: string;
  readonly testRecipients: readonly string[];
};

export type RecipientRecord = {
  readonly subscriberId: string;
  readonly emailLower: string;
  readonly unsubscribeTokenRaw: string;
};

export type NewsletterCampaignPort = {
  // Null means the claim did not apply — either the campaign does not
  // exist, or its status was no longer the expected one by the time the
  // transaction ran (already claimed by an earlier delivery of this same
  // event, or moved on by an unrelated write).
  readonly claimCampaign: (campaignId: string, mode: "send" | "test") => Promise<CampaignSnapshot | null>;
  readonly listConfirmedSubscriberPage: (
    afterSubscriberId: string | null,
  ) => Promise<{ readonly recipients: readonly RecipientRecord[]; readonly hasMore: boolean }>;
  // True = newly created (proceed to send). False = ALREADY_EXISTS (a prior
  // run already handled this recipient for this campaign; skip sending).
  readonly tryLockDelivery: (campaignId: string, subscriberId: string) => Promise<boolean>;
  readonly recordDelivery: (
    campaignId: string,
    subscriberId: string,
    outcome: { readonly status: "sent" | "failed"; readonly mailDocId?: string; readonly error?: string },
  ) => Promise<void>;
  readonly enqueueMail: (mail: MailDocument) => Promise<string>;
  readonly finishSend: (
    campaignId: string,
    result: {
      readonly status: "sent" | "failed";
      readonly recipientCount: number;
      readonly deliveredCount: number;
      readonly failedCount: number;
      readonly error?: string;
    },
  ) => Promise<void>;
  readonly finishTest: (campaignId: string) => Promise<void>;
  readonly generateToken: () => string;
};

export async function handleNewsletterCampaignWrite(
  campaignId: string,
  beforeStatus: string | undefined,
  afterStatus: string | undefined,
  port: NewsletterCampaignPort,
): Promise<void> {
  if (afterStatus === undefined) {
    // Deletion (or a write with no recognisable status) — nothing to do.
    return;
  }

  const enteringQueued = afterStatus === "queued" && beforeStatus !== "queued";
  const enteringTestQueued = afterStatus === "testQueued" && beforeStatus !== "testQueued";
  if (!enteringQueued && !enteringTestQueued) {
    return;
  }

  const mode = enteringQueued ? "send" : "test";
  const claimed = await port.claimCampaign(campaignId, mode);
  if (claimed === null) {
    return;
  }

  if (mode === "test") {
    await sendTestCampaign(campaignId, claimed, port);
  } else {
    await sendRealCampaign(campaignId, claimed, port);
  }
}

async function sendRealCampaign(
  campaignId: string,
  campaign: CampaignSnapshot,
  port: NewsletterCampaignPort,
): Promise<void> {
  let recipientCount = 0;
  let deliveredCount = 0;
  let failedCount = 0;
  let cursor: string | null = null;

  try {
    for (;;) {
      const page = await port.listConfirmedSubscriberPage(cursor);
      for (const recipient of page.recipients) {
        recipientCount += 1;
        const outcome = await deliverToRecipient(campaignId, campaign, recipient, port);
        if (outcome === "sent") {
          deliveredCount += 1;
        } else {
          failedCount += 1;
        }
      }

      const last = page.recipients[page.recipients.length - 1];
      if (!page.hasMore || last === undefined) {
        break;
      }
      cursor = last.subscriberId;
    }

    await port.finishSend(campaignId, { status: "sent", recipientCount, deliveredCount, failedCount });
  } catch (error) {
    await port.finishSend(campaignId, {
      status: "failed",
      recipientCount,
      deliveredCount,
      failedCount,
      error: error instanceof Error ? error.message : String(error),
    });
    // Rethrow so the fault surfaces in Cloud Logging (and is reported by
    // withTriggerErrorReporting at the call site below).
    throw error;
  }
}

async function deliverToRecipient(
  campaignId: string,
  campaign: CampaignSnapshot,
  recipient: RecipientRecord,
  port: NewsletterCampaignPort,
): Promise<"sent" | "failed"> {
  const locked = await port.tryLockDelivery(campaignId, recipient.subscriberId);
  if (!locked) {
    // ALREADY_EXISTS: a prior (partial) run already created this delivery
    // lock for this campaign+subscriber. Never send twice — this recipient
    // is counted as already delivered without touching `mail/` again.
    return "sent";
  }

  try {
    const unsubscribeUrl = buildUnsubscribeUrl(recipient.subscriberId, recipient.unsubscribeTokenRaw);
    const mail = buildCampaignMail({
      to: recipient.emailLower,
      subject: campaign.subject,
      bodyMarkdown: campaign.bodyMarkdown,
      unsubscribeUrl,
    });
    const mailDocId = await port.enqueueMail(mail);
    await port.recordDelivery(campaignId, recipient.subscriberId, { status: "sent", mailDocId });
    return "sent";
  } catch (error) {
    await port.recordDelivery(campaignId, recipient.subscriberId, {
      status: "failed",
      error: error instanceof Error ? error.message : String(error),
    });
    return "failed";
  }
}

async function sendTestCampaign(
  campaignId: string,
  campaign: CampaignSnapshot,
  port: NewsletterCampaignPort,
): Promise<void> {
  for (const to of campaign.testRecipients) {
    // Test recipients are arbitrary admin-supplied addresses, not real
    // subscribers, so there is no stored unsubscribe token to embed and — per
    // spec — NO delivery lock is created either. A fresh, inert per-send
    // token keeps the rendered template's unsubscribe link present and
    // realistic for the admin's preview; it is not expected to resolve to
    // any real subscriber if actually clicked.
    const unsubscribeUrl = buildUnsubscribeUrl("test", port.generateToken());
    const mail = buildCampaignMail({
      to,
      subject: campaign.subject,
      bodyMarkdown: campaign.bodyMarkdown,
      unsubscribeUrl,
    });
    await port.enqueueMail(mail);
  }
  await port.finishTest(campaignId);
}

function buildUnsubscribeUrl(subscriberId: string, unsubscribeTokenRaw: string): string {
  return `${functionsBaseUrl()}/unsubscribeNewsletter?s=${subscriberId}&t=${unsubscribeTokenRaw}`;
}

if (getApps().length === 0) {
  initializeApp();
}

export const newsletterCampaignQueued = onDocumentWritten(
  { document: `${NEWSLETTER_CAMPAIGNS_COLLECTION}/{campaignId}`, region: "asia-southeast1" },
  withTriggerErrorReporting(
    "newsletterCampaignQueued",
    async (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { campaignId: string }>) => {
      const change = event.data;
      const beforeStatus = readStatus(snapshotDataIfExists(change?.before));
      const afterStatus = readStatus(snapshotDataIfExists(change?.after));
      await handleNewsletterCampaignWrite(
        event.params.campaignId,
        beforeStatus,
        afterStatus,
        firebaseNewsletterCampaignPort(getFirestore()),
      );
    },
  ),
);

function snapshotDataIfExists(snapshot: DocumentSnapshot | undefined): DocumentData | undefined {
  return snapshot !== undefined && snapshot.exists ? snapshot.data() : undefined;
}

function readStatus(data: DocumentData | undefined): string | undefined {
  const value = data?.["status"];
  return typeof value === "string" ? value : undefined;
}

function firebaseNewsletterCampaignPort(firestore: Firestore): NewsletterCampaignPort {
  const campaigns = firestore.collection(NEWSLETTER_CAMPAIGNS_COLLECTION);

  return {
    generateToken: generateRawToken,
    claimCampaign: async (campaignId, mode) => {
      const ref = campaigns.doc(campaignId);
      return firestore.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(ref);
        if (!snapshot.exists) {
          return null;
        }
        const data = snapshot.data() ?? {};
        const status = typeof data["status"] === "string" ? data["status"] : undefined;
        const expectedStatus = mode === "send" ? "queued" : "testQueued";
        if (status !== expectedStatus) {
          return null;
        }

        // Claim is single-winner for BOTH modes: the status write happens
        // right here, inside the same transaction that just verified the
        // expected status, before any mail is sent. A test send has no
        // intermediate "sending" state, so it goes straight to its terminal
        // "draft" — see the file-header comment for why that is safe.
        transaction.update(ref, { status: mode === "send" ? "sending" : "draft" });

        const testRecipients = data["testRecipients"];
        return {
          subject: typeof data["subject"] === "string" ? data["subject"] : "",
          bodyMarkdown: typeof data["bodyMarkdown"] === "string" ? data["bodyMarkdown"] : "",
          testRecipients: Array.isArray(testRecipients)
            ? testRecipients.filter((value): value is string => typeof value === "string")
            : [],
        };
      });
    },
    listConfirmedSubscriberPage: async (afterSubscriberId) => {
      let query = firestore
        .collection(NEWSLETTER_SUBSCRIBERS_COLLECTION)
        .where("status", "==", "confirmed")
        .orderBy(FieldPath.documentId())
        .limit(PAGE_SIZE);
      if (afterSubscriberId !== null) {
        query = query.startAfter(afterSubscriberId);
      }
      const snapshot = await query.get();
      const recipients = snapshot.docs.map((doc) => {
        const data = doc.data();
        const emailLower = data["emailLower"];
        const unsubscribeTokenRaw = data["unsubscribeTokenRaw"];
        return {
          subscriberId: doc.id,
          emailLower: typeof emailLower === "string" ? emailLower : "",
          unsubscribeTokenRaw: typeof unsubscribeTokenRaw === "string" ? unsubscribeTokenRaw : "",
        };
      });
      return { recipients, hasMore: snapshot.docs.length === PAGE_SIZE };
    },
    tryLockDelivery: async (campaignId, subscriberId) => {
      const ref = campaigns.doc(campaignId).collection(NEWSLETTER_CAMPAIGN_DELIVERIES_SUBCOLLECTION).doc(subscriberId);
      try {
        await ref.create({ status: "pending", createdAt: FieldValue.serverTimestamp() });
        return true;
      } catch (error) {
        if (isAlreadyExistsError(error)) {
          return false;
        }
        throw error;
      }
    },
    recordDelivery: async (campaignId, subscriberId, outcome) => {
      const ref = campaigns.doc(campaignId).collection(NEWSLETTER_CAMPAIGN_DELIVERIES_SUBCOLLECTION).doc(subscriberId);
      await ref.set(
        {
          status: outcome.status,
          ...(outcome.mailDocId === undefined ? {} : { mailDocId: outcome.mailDocId }),
          ...(outcome.error === undefined ? {} : { error: outcome.error }),
        },
        { merge: true },
      );
    },
    enqueueMail: async (mail) => {
      const ref = await firestore.collection(MAIL_COLLECTION).add(mail);
      return ref.id;
    },
    finishSend: async (campaignId, result) => {
      await campaigns.doc(campaignId).set(
        {
          status: result.status,
          recipientCount: result.recipientCount,
          deliveredCount: result.deliveredCount,
          failedCount: result.failedCount,
          sentAt: FieldValue.serverTimestamp(),
          ...(result.error === undefined ? {} : { error: result.error }),
        },
        { merge: true },
      );
    },
    finishTest: async (campaignId) => {
      // status is deliberately NOT written here — claimCampaign's
      // transaction already moved the document to "draft" as part of
      // claiming it (see the file-header comment), so re-writing the same
      // value here would be redundant. Only the outcome-only field is set.
      await campaigns.doc(campaignId).set({ lastTestSentAt: FieldValue.serverTimestamp() }, { merge: true });
    },
  };
}
