import { FieldValue, getFirestore, type Firestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { reportBackendError } from "../errors/reportBackendError.js";
import { hashesEqual, sha256Hex } from "./crypto.js";
import { siteBaseUrl } from "./env.js";
import { NEWSLETTER_SUBSCRIBERS_COLLECTION } from "./collections.js";

// Unsubscribe link target: GET /unsubscribeNewsletter?s=<subscriberId>&t=<rawToken>.
// Deliberately GET, not POST: this is what every campaign email's
// List-Unsubscribe header (and the visible in-body link) points at, and
// mail clients / spam filters expect a plain GET link there. The accepted
// trade-off is that some mail-scanner prefetchers follow links before a
// human ever opens the message, which could unsubscribe an address nobody
// asked to unsubscribe — but the operation is idempotent and low-stakes
// (re-subscribing is one form submission away), and RFC 8058 one-click
// (POST, no confirmation) is the alternative Gmail/most providers actually
// expect for List-Unsubscribe, which this endpoint already matches in
// spirit (no interstitial confirmation page) without requiring a second
// endpoint shape.
export type UnsubscribeNewsletterOutcome = "unsubscribed" | "invalid";

export type UnsubscribeNewsletterSubscriberSnapshot = {
  readonly status: string;
  readonly unsubscribeTokenHash?: string;
};

export type UnsubscribeNewsletterPort = {
  readonly getSubscriber: (subscriberId: string) => Promise<UnsubscribeNewsletterSubscriberSnapshot | null>;
  readonly markUnsubscribed: (subscriberId: string) => Promise<void>;
};

export async function unsubscribeNewsletterCore(
  input: { readonly subscriberId: string | null; readonly token: string | null },
  port: UnsubscribeNewsletterPort,
): Promise<UnsubscribeNewsletterOutcome> {
  if (input.subscriberId === null || input.token === null) {
    return "invalid";
  }

  const subscriber = await port.getSubscriber(input.subscriberId);
  if (subscriber === null || subscriber.unsubscribeTokenHash === undefined) {
    return "invalid";
  }
  if (!hashesEqual(sha256Hex(input.token), subscriber.unsubscribeTokenHash)) {
    return "invalid";
  }

  // The unsubscribe token never expires (see subscribeNewsletter.ts), so
  // there is no expiry check here — only the hash comparison above.
  if (subscriber.status !== "unsubscribed") {
    await port.markUnsubscribed(input.subscriberId);
  }
  // Idempotent either way: an already-unsubscribed address with a valid
  // token still redirects to success.
  return "unsubscribed";
}

export const unsubscribeNewsletter = onRequest(
  { region: "asia-southeast1", invoker: "public" },
  async (req, res) => {
    try {
      const subscriberId = readQueryParam(req.query["s"]);
      const token = readQueryParam(req.query["t"]);
      const outcome = await unsubscribeNewsletterCore({ subscriberId, token }, firebaseUnsubscribeNewsletterPort());
      res.redirect(302, `${siteBaseUrl()}/newsletter/${outcome === "unsubscribed" ? "unsubscribed" : "invalid"}`);
    } catch (error) {
      // See confirmNewsletterSubscription.ts's identical comment: there is
      // no shared onRequest error-reporting wrapper in this codebase, so
      // this reports inline and always fails toward the safe redirect.
      await reportBackendError({ functionName: "unsubscribeNewsletter", error, fatal: true });
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

function firebaseUnsubscribeNewsletterPort(firestore: Firestore = getFirestore()): UnsubscribeNewsletterPort {
  return {
    getSubscriber: async (subscriberId) => {
      const snapshot = await firestore.collection(NEWSLETTER_SUBSCRIBERS_COLLECTION).doc(subscriberId).get();
      if (!snapshot.exists) {
        return null;
      }
      const data = snapshot.data() ?? {};
      const unsubscribeTokenHash = data["unsubscribeTokenHash"];
      return {
        status: readStatus(data["status"]),
        ...(typeof unsubscribeTokenHash === "string" ? { unsubscribeTokenHash } : {}),
      };
    },
    markUnsubscribed: async (subscriberId) => {
      await firestore.collection(NEWSLETTER_SUBSCRIBERS_COLLECTION).doc(subscriberId).set(
        { status: "unsubscribed", unsubscribedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
    },
  };
}
