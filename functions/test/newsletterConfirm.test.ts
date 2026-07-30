import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { sha256Hex } from "../src/newsletter/crypto.js";
import {
  confirmNewsletterSubscriptionCore,
  type ConfirmNewsletterPort,
  type ConfirmNewsletterSubscriberSnapshot,
} from "../src/newsletter/confirmNewsletterSubscription.js";

const BASE_NOW = new Date("2026-07-30T12:00:00.000Z");
const RAW_TOKEN = "confirm-raw-token";
const TOKEN_HASH = sha256Hex(RAW_TOKEN);

describe("confirmNewsletterSubscription", () => {
  it("confirms a pending subscriber with a valid, unexpired token", async () => {
    const port = fixture();
    port.subscribers.set("sub1", {
      status: "pending",
      confirmTokenHash: TOKEN_HASH,
      confirmTokenExpiresAtMs: BASE_NOW.getTime() + 1000,
    });

    const outcome = await confirmNewsletterSubscriptionCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);

    assert.equal(outcome, "confirmed");
    assert.deepEqual(port.confirmedIds, ["sub1"]);
  });

  it("is idempotent: an already-confirmed subscriber with a still-matching token redirects to success without writing again", async () => {
    const port = fixture();
    port.subscribers.set("sub1", { status: "confirmed", confirmTokenHash: TOKEN_HASH });

    const outcome = await confirmNewsletterSubscriptionCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);

    assert.equal(outcome, "confirmed");
    assert.deepEqual(port.confirmedIds, []);
  });

  it("never resurrects an unsubscribed subscriber, even with a still-valid, unexpired token", async () => {
    const port = fixture();
    port.subscribers.set("sub1", {
      status: "unsubscribed",
      confirmTokenHash: TOKEN_HASH,
      confirmTokenExpiresAtMs: BASE_NOW.getTime() + 1000,
    });

    const outcome = await confirmNewsletterSubscriptionCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);

    assert.equal(outcome, "invalid");
    assert.deepEqual(port.confirmedIds, []);
  });

  it("rejects an expired confirm token", async () => {
    const port = fixture();
    port.subscribers.set("sub1", {
      status: "pending",
      confirmTokenHash: TOKEN_HASH,
      confirmTokenExpiresAtMs: BASE_NOW.getTime() - 1,
    });

    const outcome = await confirmNewsletterSubscriptionCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);

    assert.equal(outcome, "invalid");
    assert.deepEqual(port.confirmedIds, []);
  });

  it("rejects a wrong token", async () => {
    const port = fixture();
    port.subscribers.set("sub1", {
      status: "pending",
      confirmTokenHash: TOKEN_HASH,
      confirmTokenExpiresAtMs: BASE_NOW.getTime() + 1000,
    });

    const outcome = await confirmNewsletterSubscriptionCore({ subscriberId: "sub1", token: "wrong-token" }, port);

    assert.equal(outcome, "invalid");
    assert.deepEqual(port.confirmedIds, []);
  });

  it("rejects a missing subscriberId or token", async () => {
    const port = fixture();
    assert.equal(await confirmNewsletterSubscriptionCore({ subscriberId: null, token: RAW_TOKEN }, port), "invalid");
    assert.equal(await confirmNewsletterSubscriptionCore({ subscriberId: "sub1", token: null }, port), "invalid");
  });

  it("rejects an unknown subscriberId", async () => {
    const port = fixture();
    const outcome = await confirmNewsletterSubscriptionCore({ subscriberId: "missing", token: RAW_TOKEN }, port);
    assert.equal(outcome, "invalid");
  });

  it("rejects a subscriber with no confirm token on file", async () => {
    const port = fixture();
    port.subscribers.set("sub1", { status: "pending" });
    const outcome = await confirmNewsletterSubscriptionCore({ subscriberId: "sub1", token: RAW_TOKEN }, port);
    assert.equal(outcome, "invalid");
  });
});

class FakeConfirmPort implements ConfirmNewsletterPort {
  readonly subscribers = new Map<string, ConfirmNewsletterSubscriberSnapshot>();
  readonly confirmedIds: string[] = [];

  now(): Date {
    return BASE_NOW;
  }

  async getSubscriber(subscriberId: string): Promise<ConfirmNewsletterSubscriberSnapshot | null> {
    return this.subscribers.get(subscriberId) ?? null;
  }

  async markConfirmed(subscriberId: string): Promise<void> {
    this.confirmedIds.push(subscriberId);
    const existing = this.subscribers.get(subscriberId);
    if (existing !== undefined) {
      this.subscribers.set(subscriberId, { ...existing, status: "confirmed" });
    }
  }
}

function fixture(): FakeConfirmPort {
  return new FakeConfirmPort();
}
