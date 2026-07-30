import { FieldValue, getFirestore, type Firestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { reportBackendError } from "../errors/reportBackendError.js";
import { hashesEqual, sha256Hex } from "./crypto.js";
import { toMillis } from "./firestoreHelpers.js";
import { siteBaseUrl } from "./env.js";
import { NEWSLETTER_SUBSCRIBERS_COLLECTION } from "./collections.js";

// Confirmation link target for double opt-in: GET /confirmNewsletterSubscription?s=<subscriberId>&t=<rawToken>.
// Deliberately a public onRequest (not a callable) because the caller is a
// browser or mail-client link click with no Firebase SDK involved at all.
export type ConfirmNewsletterOutcome = "confirmed" | "invalid";

export type ConfirmNewsletterSubscriberSnapshot = {
  readonly status: string;
  readonly confirmTokenHash?: string;
  readonly confirmTokenExpiresAtMs?: number;
};

export type ConfirmNewsletterPort = {
  readonly now: () => Date;
  readonly getSubscriber: (subscriberId: string) => Promise<ConfirmNewsletterSubscriberSnapshot | null>;
  readonly markConfirmed: (subscriberId: string) => Promise<void>;
};

export async function confirmNewsletterSubscriptionCore(
  input: { readonly subscriberId: string | null; readonly token: string | null },
  port: ConfirmNewsletterPort,
): Promise<ConfirmNewsletterOutcome> {
  if (input.subscriberId === null || input.token === null) {
    return "invalid";
  }

  const subscriber = await port.getSubscriber(input.subscriberId);
  if (subscriber === null || subscriber.confirmTokenHash === undefined) {
    return "invalid";
  }
  if (!hashesEqual(sha256Hex(input.token), subscriber.confirmTokenHash)) {
    return "invalid";
  }

  if (subscriber.status === "confirmed") {
    // Idempotent: a repeat click (double-click, mail client prefetch retry)
    // with a still-matching token redirects to success again without a
    // second write.
    return "confirmed";
  }

  // MUST NOT resurrect an explicit unsubscribe. Scenario: a subscriber
  // confirms on day 0 and receives a campaign on day 2, then unsubscribes
  // that same day — but their original confirmation email (sent day 0) is
  // still sitting in their inbox with a confirm link that stays valid for 7
  // days. A stray click on that stale link, or a mail-scanner prefetch of
  // it, would otherwise re-confirm them against their explicit unsubscribe,
  // silently undoing it. So an "unsubscribed" record can never be
  // re-confirmed via an old confirm link, regardless of token validity — the
  // only path back to "pending"/"confirmed" is a genuine re-subscription
  // through subscribeNewsletter, which resets status to "pending" and mints
  // a fresh confirm token.
  if (subscriber.status === "unsubscribed") {
    return "invalid";
  }

  if (
    subscriber.confirmTokenExpiresAtMs !== undefined &&
    subscriber.confirmTokenExpiresAtMs < port.now().getTime()
  ) {
    return "invalid";
  }

  await port.markConfirmed(input.subscriberId);
  return "confirmed";
}

export const confirmNewsletterSubscription = onRequest(
  { region: "asia-southeast1", invoker: "public" },
  async (req, res) => {
    try {
      const subscriberId = readQueryParam(req.query["s"]);
      const token = readQueryParam(req.query["t"]);
      const outcome = await confirmNewsletterSubscriptionCore(
        { subscriberId, token },
        firebaseConfirmNewsletterPort(),
      );
      res.redirect(302, `${siteBaseUrl()}/newsletter/${outcome === "confirmed" ? "confirmed" : "invalid"}`);
    } catch (error) {
      // No shared onRequest error-reporting wrapper exists anywhere in this
      // codebase — every other entry point is a callable, a Firestore
      // trigger, or a scheduled job (see errors/withErrorReporting.ts),
      // which is exactly the set that module wraps. Rather than add a
      // fourth wrapper shape for the two onRequest handlers in this module,
      // report inline here, matching what withCallableErrorReporting does
      // internally, and always fail toward the safe redirect rather than
      // ever surfacing a raw 500 to a browser or mail client.
      await reportBackendError({ functionName: "confirmNewsletterSubscription", error, fatal: true });
      res.redirect(302, `${siteBaseUrl()}/newsletter/invalid`);
    }
  },
);

function readQueryParam(value: unknown): string | null {
  return typeof value === "string" && value.length > 0 ? value : null;
}

function readStatus(value: unknown): string {
  return typeof value === "string" ? value : "pending";
}

function firebaseConfirmNewsletterPort(firestore: Firestore = getFirestore()): ConfirmNewsletterPort {
  return {
    now: () => new Date(),
    getSubscriber: async (subscriberId) => {
      const snapshot = await firestore.collection(NEWSLETTER_SUBSCRIBERS_COLLECTION).doc(subscriberId).get();
      if (!snapshot.exists) {
        return null;
      }
      const data = snapshot.data() ?? {};
      const confirmTokenHash = data["confirmTokenHash"];
      const expiresAtMs = toMillis(data["confirmTokenExpiresAt"]);
      return {
        status: readStatus(data["status"]),
        ...(typeof confirmTokenHash === "string" ? { confirmTokenHash } : {}),
        ...(expiresAtMs === null ? {} : { confirmTokenExpiresAtMs: expiresAtMs }),
      };
    },
    markConfirmed: async (subscriberId) => {
      await firestore.collection(NEWSLETTER_SUBSCRIBERS_COLLECTION).doc(subscriberId).set(
        { status: "confirmed", confirmedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
    },
  };
}
