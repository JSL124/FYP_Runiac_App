import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  handleNewsletterCampaignWrite,
  type CampaignSnapshot,
  type NewsletterCampaignPort,
  type RecipientRecord,
} from "../src/newsletter/newsletterCampaignQueued.js";
import type { MailDocument } from "../src/newsletter/mailRender.js";

type FakeCampaignRecord = {
  status: string;
  subject: string;
  bodyMarkdown: string;
  testRecipients: string[];
  recipientCount?: number;
  deliveredCount?: number;
  failedCount?: number;
  error?: string;
  lastTestSentAt?: string;
};

describe("newsletterCampaignQueued fan-out", () => {
  it("sends a queued campaign to every confirmed subscriber across multiple pages, ending 'sent' with correct counts", async () => {
    const port = fixture(
      { status: "queued", subject: "Hello", bodyMarkdown: "Hi runners.", testRecipients: [] },
      [recipient("s1"), recipient("s2"), recipient("s3")],
      { pageSize: 2 },
    );

    await handleNewsletterCampaignWrite("camp1", "draft", "queued", port);

    assert.equal(port.campaign.status, "sent");
    assert.equal(port.campaign.recipientCount, 3);
    assert.equal(port.campaign.deliveredCount, 3);
    assert.equal(port.campaign.failedCount, 0);
    assert.equal(port.mails.length, 3);
    assert.equal(port.claimCalls.length, 1);
    assert.deepEqual(port.claimCalls[0], { campaignId: "camp1", mode: "send" });

    for (const mail of port.mails) {
      assert.match(mail.message.text, /Unsubscribe from this newsletter/);
      assert.match(mail.message.html, /Unsubscribe from this newsletter/);
      assert.equal(typeof mail.message.headers?.["List-Unsubscribe"], "string");
    }
  });

  it("skips a recipient whose delivery lock already exists (retry-safe: never double-sends)", async () => {
    const port = fixture(
      { status: "queued", subject: "Hello", bodyMarkdown: "Hi.", testRecipients: [] },
      [recipient("s1"), recipient("s2")],
      { pageSize: 10, preLockedKeys: ["camp1:s1"] },
    );

    await handleNewsletterCampaignWrite("camp1", "draft", "queued", port);

    assert.equal(port.mails.length, 1);
    assert.equal(port.mails[0]?.to, "s2@example.com");
    assert.equal(port.campaign.recipientCount, 2);
    assert.equal(port.campaign.deliveredCount, 2);
    assert.equal(port.campaign.failedCount, 0);
    // No new delivery record is written for the already-locked recipient.
    assert.equal(port.deliveryRecords.filter((record) => record.subscriberId === "s1").length, 0);
    assert.equal(port.deliveryRecords.filter((record) => record.subscriberId === "s2").length, 1);
  });

  it("counts a per-recipient send failure without aborting the whole campaign", async () => {
    const port = fixture(
      { status: "queued", subject: "Hello", bodyMarkdown: "Hi.", testRecipients: [] },
      [recipient("s1"), recipient("s2")],
      { pageSize: 10, failEnqueueForEmails: ["s1@example.com"] },
    );

    await handleNewsletterCampaignWrite("camp1", "draft", "queued", port);

    assert.equal(port.campaign.status, "sent");
    assert.equal(port.campaign.recipientCount, 2);
    assert.equal(port.campaign.deliveredCount, 1);
    assert.equal(port.campaign.failedCount, 1);
    const failedRecord = port.deliveryRecords.find((record) => record.subscriberId === "s1");
    assert.equal(failedRecord?.outcome.status, "failed");
  });

  it("ends the campaign 'failed' with an error and partial counts, and rethrows, when the fan-out itself faults", async () => {
    const port = fixture(
      { status: "queued", subject: "Hello", bodyMarkdown: "Hi.", testRecipients: [] },
      [recipient("s1"), recipient("s2"), recipient("s3")],
      { pageSize: 1, throwOnPageIndex: 1 },
    );

    await assert.rejects(handleNewsletterCampaignWrite("camp1", "draft", "queued", port));

    assert.equal(port.campaign.status, "failed");
    assert.equal(typeof port.campaign.error, "string");
    assert.equal(port.campaign.recipientCount, 1);
    assert.equal(port.campaign.deliveredCount, 1);
  });

  it("ignores writes that are not ENTERING queued or testQueued", async () => {
    const port = fixture({ status: "queued", subject: "s", bodyMarkdown: "b", testRecipients: [] }, []);

    await handleNewsletterCampaignWrite("camp1", "queued", "queued", port); // already queued, not entering
    await handleNewsletterCampaignWrite("camp1", undefined, "draft", port); // entering draft, irrelevant
    await handleNewsletterCampaignWrite("camp1", "sending", undefined, port); // deletion

    assert.equal(port.claimCalls.length, 0);
    assert.equal(port.mails.length, 0);
  });

  it("does not double-send on a redelivered trigger event once the campaign has already moved past 'queued'", async () => {
    const port = fixture(
      { status: "sending", subject: "s", bodyMarkdown: "b", testRecipients: [] },
      [recipient("s1")],
    );

    // A retried event still claims it saw "draft" -> "queued", but the
    // authoritative status is already "sending" by the time the claim
    // transaction runs.
    await handleNewsletterCampaignWrite("camp1", "draft", "queued", port);

    assert.equal(port.mails.length, 0);
    assert.equal(port.campaign.status, "sending");
  });

  it("sends a test campaign only to testRecipients, creates NO delivery locks, and returns the campaign to draft", async () => {
    const port = fixture(
      { status: "testQueued", subject: "Preview", bodyMarkdown: "Hi [team](https://runiac.example).", testRecipients: ["admin@runiac.example", "qa@runiac.example"] },
      [recipient("s1"), recipient("s2")],
    );

    await handleNewsletterCampaignWrite("camp1", "draft", "testQueued", port);

    assert.equal(port.mails.length, 2);
    assert.deepEqual(
      port.mails.map((mail) => mail.to).sort(),
      ["admin@runiac.example", "qa@runiac.example"],
    );
    assert.equal(port.deliveryLocks.size, 0);
    assert.equal(port.campaign.status, "draft");
    assert.equal(port.campaign.lastTestSentAt, "server-timestamp");
    for (const mail of port.mails) {
      assert.match(mail.message.html, /Unsubscribe from this newsletter/);
    }
  });

  it("flips a test claim to 'draft' immediately, before any test mail is sent", async () => {
    const port = fixture(
      { status: "testQueued", subject: "Preview", bodyMarkdown: "Hi.", testRecipients: ["admin@runiac.example"] },
      [],
    );

    const claimed = await port.claimCampaign("camp1", "test");

    assert.notEqual(claimed, null);
    // The claim alone — before sendTestCampaign has enqueued anything —
    // already moved the campaign out of "testQueued", making the claim
    // single-winner.
    assert.equal(port.campaign.status, "draft");
    assert.equal(port.mails.length, 0);
  });

  it("does not re-send a test campaign on a redelivered trigger event for the same write", async () => {
    const port = fixture(
      { status: "testQueued", subject: "Preview", bodyMarkdown: "Hi.", testRecipients: ["admin@runiac.example"] },
      [],
    );

    await handleNewsletterCampaignWrite("camp1", "draft", "testQueued", port);
    assert.equal(port.mails.length, 1);
    assert.equal(port.campaign.status, "draft");

    // Cloud Functions triggers are at-least-once: the SAME event (identical
    // before/after status pair) can be redelivered. The enter-transition
    // check alone cannot tell this apart from the first delivery — only the
    // transactional claim (re-reading CURRENT status, now "draft" instead
    // of "testQueued") can refuse it.
    await handleNewsletterCampaignWrite("camp1", "draft", "testQueued", port);

    assert.equal(port.mails.length, 1);
    assert.equal(port.claimCalls.length, 2);
  });
});

function recipient(subscriberId: string): RecipientRecord {
  return { subscriberId, emailLower: `${subscriberId}@example.com`, unsubscribeTokenRaw: `raw-${subscriberId}` };
}

class FakeCampaignPort implements NewsletterCampaignPort {
  readonly campaign: FakeCampaignRecord;
  readonly subscribers: readonly RecipientRecord[];
  readonly pageSize: number;
  readonly deliveryLocks = new Set<string>();
  readonly deliveryRecords: Array<{
    readonly campaignId: string;
    readonly subscriberId: string;
    readonly outcome: { readonly status: "sent" | "failed"; readonly mailDocId?: string; readonly error?: string };
  }> = [];
  readonly mails: MailDocument[] = [];
  readonly claimCalls: Array<{ readonly campaignId: string; readonly mode: "send" | "test" }> = [];
  private readonly failEnqueueForEmails: ReadonlySet<string>;
  private readonly throwOnPageIndex: number | null;
  private pageCallCount = 0;
  private tokenCounter = 0;

  constructor(
    campaign: FakeCampaignRecord,
    subscribers: readonly RecipientRecord[],
    options: {
      readonly pageSize?: number;
      readonly preLockedKeys?: readonly string[];
      readonly failEnqueueForEmails?: readonly string[];
      readonly throwOnPageIndex?: number;
    } = {},
  ) {
    this.campaign = campaign;
    this.subscribers = subscribers;
    this.pageSize = options.pageSize ?? 200;
    for (const key of options.preLockedKeys ?? []) {
      this.deliveryLocks.add(key);
    }
    this.failEnqueueForEmails = new Set(options.failEnqueueForEmails ?? []);
    this.throwOnPageIndex = options.throwOnPageIndex ?? null;
  }

  generateToken(): string {
    this.tokenCounter += 1;
    return `test-token-${this.tokenCounter}`;
  }

  async claimCampaign(campaignId: string, mode: "send" | "test"): Promise<CampaignSnapshot | null> {
    this.claimCalls.push({ campaignId, mode });
    const expectedStatus = mode === "send" ? "queued" : "testQueued";
    if (this.campaign.status !== expectedStatus) {
      return null;
    }
    // Mirrors the production port: the claim is single-winner for BOTH
    // modes, so the status write happens here, inside the "transaction",
    // before any mail is sent. A test claim goes straight to "draft" (its
    // terminal state) rather than staying "testQueued".
    this.campaign.status = mode === "send" ? "sending" : "draft";
    return {
      subject: this.campaign.subject,
      bodyMarkdown: this.campaign.bodyMarkdown,
      testRecipients: this.campaign.testRecipients,
    };
  }

  async listConfirmedSubscriberPage(
    afterSubscriberId: string | null,
  ): Promise<{ readonly recipients: readonly RecipientRecord[]; readonly hasMore: boolean }> {
    if (this.throwOnPageIndex !== null && this.pageCallCount === this.throwOnPageIndex) {
      this.pageCallCount += 1;
      throw new Error("simulated pagination failure");
    }
    this.pageCallCount += 1;

    const startIndex =
      afterSubscriberId === null ? 0 : this.subscribers.findIndex((s) => s.subscriberId === afterSubscriberId) + 1;
    const recipients = this.subscribers.slice(startIndex, startIndex + this.pageSize);
    const hasMore = startIndex + this.pageSize < this.subscribers.length;
    return { recipients, hasMore };
  }

  async tryLockDelivery(campaignId: string, subscriberId: string): Promise<boolean> {
    const key = `${campaignId}:${subscriberId}`;
    if (this.deliveryLocks.has(key)) {
      return false;
    }
    this.deliveryLocks.add(key);
    return true;
  }

  async recordDelivery(
    campaignId: string,
    subscriberId: string,
    outcome: { readonly status: "sent" | "failed"; readonly mailDocId?: string; readonly error?: string },
  ): Promise<void> {
    this.deliveryRecords.push({ campaignId, subscriberId, outcome });
  }

  async enqueueMail(mail: MailDocument): Promise<string> {
    if (this.failEnqueueForEmails.has(mail.to)) {
      throw new Error(`simulated send failure for ${mail.to}`);
    }
    this.mails.push(mail);
    return `mail-${this.mails.length}`;
  }

  async finishSend(
    campaignId: string,
    result: {
      readonly status: "sent" | "failed";
      readonly recipientCount: number;
      readonly deliveredCount: number;
      readonly failedCount: number;
      readonly error?: string;
    },
  ): Promise<void> {
    this.campaign.status = result.status;
    this.campaign.recipientCount = result.recipientCount;
    this.campaign.deliveredCount = result.deliveredCount;
    this.campaign.failedCount = result.failedCount;
    if (result.error !== undefined) {
      this.campaign.error = result.error;
    }
  }

  async finishTest(_campaignId: string): Promise<void> {
    // status is intentionally NOT written here — claimCampaign already
    // moved it to "draft" as part of claiming, matching the production port.
    this.campaign.lastTestSentAt = "server-timestamp";
  }
}

function fixture(
  campaign: FakeCampaignRecord,
  subscribers: readonly RecipientRecord[],
  options?: {
    readonly pageSize?: number;
    readonly preLockedKeys?: readonly string[];
    readonly failEnqueueForEmails?: readonly string[];
    readonly throwOnPageIndex?: number;
  },
): FakeCampaignPort {
  return new FakeCampaignPort(campaign, subscribers, options);
}
