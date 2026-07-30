// Feed engagement FCM push (WP2): emulator tests for `sendFeedEngagementPush`
// against a fake, injectable messaging port (no real FCM send).

import assert from "node:assert/strict";
import { before, beforeEach, describe, it } from "node:test";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";

import {
  sendFeedEngagementPush,
  type FeedEngagementMessagingPort,
} from "../src/feed/engagement/engagementPush.js";
import type { FeedEngagementNotification } from "../src/feed/engagement/engagementNotifications.js";

const PROJECT_ID = "demo-runiac-feed";

let firestore: Firestore;
let counter = 0;

before(() => {
  if (getApps().length === 0) initializeApp({ projectId: PROJECT_ID });
  firestore = getFirestore();
});

function uniqueId(prefix: string): string {
  counter += 1;
  return `${prefix}-${Date.now()}-${counter}`;
}

type CapturedSend = {
  readonly token: string;
  readonly notification: { readonly title: string; readonly body: string };
  readonly data: Readonly<Record<string, string>>;
};

// A messaging port that records every call and can be told to fail (or throw
// an FCM-shaped error) for specific tokens, so tests never touch real FCM.
function fakeMessaging(options?: {
  readonly invalidTokens?: ReadonlySet<string>;
  readonly otherErrorTokens?: ReadonlySet<string>;
}): { readonly port: FeedEngagementMessagingPort; readonly sent: CapturedSend[] } {
  const sent: CapturedSend[] = [];
  return {
    sent,
    port: {
      send: async (message) => {
        sent.push(message);
        if (options?.invalidTokens?.has(message.token)) {
          throw Object.assign(new Error("invalid token"), {
            code: "messaging/invalid-registration-token",
          });
        }
        if (options?.otherErrorTokens?.has(message.token)) {
          throw Object.assign(new Error("transient send failure"), { code: "messaging/internal-error" });
        }
        return "message-id";
      },
    },
  };
}

async function registerToken(
  uid: string,
  tokenFingerprint: string,
  fcmToken: string,
  enabled = true,
): Promise<void> {
  await firestore
    .collection("notificationDevices")
    .doc(uid)
    .collection("tokens")
    .doc(tokenFingerprint)
    .set({ tokenFingerprint, fcmToken, enabled });
}

async function tokenDoc(uid: string, tokenFingerprint: string) {
  return firestore.collection("notificationDevices").doc(uid).collection("tokens").doc(tokenFingerprint).get();
}

function sampleNotification(ownerUid: string): FeedEngagementNotification {
  return {
    ownerUid,
    deliveryKey: `post-1:feed_post_liked:actor-1`,
    title: "Jordan liked your run",
    body: "Tap to open your run post.",
    payload: { kind: "feed_post_liked", route: "feedComments", postId: "post-1" },
  };
}

describe("sendFeedEngagementPush (emulator)", () => {
  beforeEach(async () => {
    const snapshot = await firestore.collection("notificationDevices").get();
    await Promise.all(
      snapshot.docs.map(async (doc) => {
        const tokens = await doc.ref.collection("tokens").get();
        await Promise.all(tokens.docs.map((token) => token.ref.delete()));
        await doc.ref.delete();
      }),
    );
  });

  it("is a clean no-op when the recipient has no enabled tokens", async () => {
    const ownerUid = uniqueId("owner-none");
    const { port, sent } = fakeMessaging();

    await assert.doesNotReject(() =>
      sendFeedEngagementPush(firestore, port, sampleNotification(ownerUid), "2026-07-31T00:00:00.000Z"),
    );
    assert.equal(sent.length, 0);
  });

  it("ignores a disabled token: sends nothing and leaves it untouched", async () => {
    const ownerUid = uniqueId("owner-disabled");
    await registerToken(ownerUid, "fp-disabled", "token-disabled", false);
    const { port, sent } = fakeMessaging();

    await sendFeedEngagementPush(firestore, port, sampleNotification(ownerUid), "2026-07-31T00:00:00.000Z");

    assert.equal(sent.length, 0);
  });

  it("sends to every enabled token with the title/body matching the inbox item and an exact string data map", async () => {
    const ownerUid = uniqueId("owner-multi");
    await registerToken(ownerUid, "fp-1", "token-1");
    await registerToken(ownerUid, "fp-2", "token-2");
    const { port, sent } = fakeMessaging();
    const notification = sampleNotification(ownerUid);

    await sendFeedEngagementPush(firestore, port, notification, "2026-07-31T00:00:00.000Z");

    assert.equal(sent.length, 2);
    const tokensSent = sent.map((call) => call.token).sort();
    assert.deepEqual(tokensSent, ["token-1", "token-2"]);
    for (const call of sent) {
      assert.equal(call.notification.title, notification.title);
      assert.equal(call.notification.body, notification.body);
      assert.deepEqual(Object.keys(call.data).sort(), ["kind", "postId", "route"]);
      assert.equal(call.data["kind"], "feed_post_liked");
      assert.equal(call.data["route"], "feedComments");
      assert.equal(call.data["postId"], "post-1");
      for (const value of Object.values(call.data)) {
        assert.equal(typeof value, "string");
      }
    }
  });

  it("disables exactly the invalid token and still sends to the remaining enabled tokens", async () => {
    const ownerUid = uniqueId("owner-invalid");
    await registerToken(ownerUid, "fp-bad", "token-bad");
    await registerToken(ownerUid, "fp-good", "token-good");
    const { port, sent } = fakeMessaging({ invalidTokens: new Set(["token-bad"]) });

    await sendFeedEngagementPush(firestore, port, sampleNotification(ownerUid), "2026-07-31T00:00:00.000Z");

    assert.equal(sent.length, 2);
    const badDoc = await tokenDoc(ownerUid, "fp-bad");
    assert.equal(badDoc.get("enabled"), false);
    assert.equal(badDoc.get("disabledAt"), "2026-07-31T00:00:00.000Z");
    const goodDoc = await tokenDoc(ownerUid, "fp-good");
    assert.equal(goodDoc.get("enabled"), true);
    assert.equal(goodDoc.get("disabledAt"), undefined);
  });

  it("swallows any other send error and still resolves and still sends to the remaining tokens", async () => {
    const ownerUid = uniqueId("owner-othererror");
    await registerToken(ownerUid, "fp-flaky", "token-flaky");
    await registerToken(ownerUid, "fp-fine", "token-fine");
    const { port, sent } = fakeMessaging({ otherErrorTokens: new Set(["token-flaky"]) });

    await assert.doesNotReject(() =>
      sendFeedEngagementPush(firestore, port, sampleNotification(ownerUid), "2026-07-31T00:00:00.000Z"),
    );

    assert.equal(sent.length, 2);
    // A non-invalid-token error must not disable the token document.
    const flakyDoc = await tokenDoc(ownerUid, "fp-flaky");
    assert.equal(flakyDoc.get("enabled"), true);
  });

  it("never throws even when the messaging port itself is broken", async () => {
    const ownerUid = uniqueId("owner-broken-port");
    await registerToken(ownerUid, "fp-x", "token-x");
    const brokenPort: FeedEngagementMessagingPort = {
      send: async () => {
        throw new Error("port exploded");
      },
    };

    await assert.doesNotReject(() =>
      sendFeedEngagementPush(firestore, brokenPort, sampleNotification(ownerUid), "2026-07-31T00:00:00.000Z"),
    );
  });
});
