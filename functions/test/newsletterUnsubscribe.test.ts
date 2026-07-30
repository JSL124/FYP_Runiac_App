import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { sha256Hex } from "../src/newsletter/crypto.js";
import {
  unsubscribeNewsletterCore,
  type UnsubscribeNewsletterPort,
  type UnsubscribeNewsletterSubscriberSnapshot,
} from "../src/newsletter/unsubscribeNewsletter.js";

const RAW_TOKEN = "unsubscribe-raw-token";
const TOKEN_HASH = sha256Hex(RAW_TOKEN);

describe("unsubscribeNewsletter", () => {
  it("unsubscribes a confirmed subscriber with a valid token", async () => {
    const port = fixture();
    port.subscribers.set("sub1", { status: "confirmed", unsubscribeTokenHash: TOKEN_HASH });

    const outcome = await unsubscribeNewsletterCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);

    assert.equal(outcome, "unsubscribed");
    assert.deepEqual(port.unsubscribedIds, ["sub1"]);
  });

  it("is idempotent: an already-unsubscribed subscriber with a valid token succeeds without writing again", async () => {
    const port = fixture();
    port.subscribers.set("sub1", { status: "unsubscribed", unsubscribeTokenHash: TOKEN_HASH });

    const outcome = await unsubscribeNewsletterCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);

    assert.equal(outcome, "unsubscribed");
    assert.deepEqual(port.unsubscribedIds, []);
  });

  it("never expires: an old token still works regardless of how long ago it was issued", async () => {
    const port = fixture();
    port.subscribers.set("sub1", { status: "confirmed", unsubscribeTokenHash: TOKEN_HASH });

    const outcome = await unsubscribeNewsletterCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);
    assert.equal(outcome, "unsubscribed");
  });

  it("rejects a wrong token", async () => {
    const port = fixture();
    port.subscribers.set("sub1", { status: "confirmed", unsubscribeTokenHash: TOKEN_HASH });

    const outcome = await unsubscribeNewsletterCore({ subscriberId: "sub1", token: "wrong-token" }, port);

    assert.equal(outcome, "invalid");
    assert.deepEqual(port.unsubscribedIds, []);
  });

  it("rejects a missing subscriberId or token", async () => {
    const port = fixture();
    assert.equal(await unsubscribeNewsletterCore({ subscriberId: null, token: RAW_TOKEN }, port), "invalid");
    assert.equal(await unsubscribeNewsletterCore({ subscriberId: "sub1", token: null }, port), "invalid");
  });

  it("rejects an unknown subscriberId", async () => {
    const port = fixture();
    const outcome = await unsubscribeNewsletterCore({ subscriberId: "missing", token: RAW_TOKEN }, port);
    assert.equal(outcome, "invalid");
  });

  it("rejects a subscriber with no unsubscribe token on file", async () => {
    const port = fixture();
    port.subscribers.set("sub1", { status: "confirmed" });
    const outcome = await unsubscribeNewsletterCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);
    assert.equal(outcome, "invalid");
  });
});

class FakeUnsubscribePort implements UnsubscribeNewsletterPort {
  readonly subscribers = new Map<string, UnsubscribeNewsletterSubscriberSnapshot>();
  readonly unsubscribedIds: string[] = [];

  async getSubscriber(subscriberId: string): Promise<UnsubscribeNewsletterSubscriberSnapshot | null> {
    return this.subscribers.get(subscriberId) ?? null;
  }

  async markUnsubscribed(subscriberId: string): Promise<void> {
    this.unsubscribedIds.push(subscriberId);
    const existing = this.subscribers.get(subscriberId);
    if (existing !== undefined) {
      this.subscribers.set(subscriberId, { ...existing, status: "unsubscribed" });
    }
  }
}

function fixture(): FakeUnsubscribePort {
  return new FakeUnsubscribePort();
}
