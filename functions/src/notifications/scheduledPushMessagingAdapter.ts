import { Timestamp } from "firebase-admin/firestore";
import {
  createInboxPayload,
  deviceDeliveryKey,
  type NotificationDeviceRecord,
  type NotificationDispatch,
  type NotificationSendAdapter,
} from "./dispatchPlanner.js";
import type { ScheduledPushDependencies } from "./scheduledPushFirestore.js";

/**
 * How long a "pending" delivery row suppresses a retry. Comfortably longer
 * than one sweep interval plus its delay tolerance, so an in-flight attempt is
 * never sent twice, and short enough that an attempt lost to a crash is
 * retried on a later sweep rather than being stranded forever.
 */
const pendingAttemptLeaseMs = 30 * 60 * 1000;

export function firestoreMessagingAdapter(
  dependencies: ScheduledPushDependencies,
  now: string,
): NotificationSendAdapter {
  return {
    send: async (
      dispatch: NotificationDispatch,
      device: NotificationDeviceRecord,
      inboxPayload,
    ) => {
      const deliveryRef = dependencies.firestore
        .collection("notificationDeliveries")
        .doc(deviceDeliveryKey(dispatch.deliveryKey, device.tokenFingerprint));
      const timestampNow = Timestamp.fromDate(new Date(now));
      const deliveryCreated = await dependencies.firestore.runTransaction(async (transaction) => {
        const existingDelivery = await transaction.get(deliveryRef);
        if (existingDelivery.exists && existingDelivery.get("status") === "sent") {
          return false;
        }
        // A "pending" row means a previous attempt reached this point and has
        // not reported back. Only "sent" used to be skipped, so an attempt
        // whose FCM response was lost — or two sweeps overlapping on the same
        // reminder — sent the push again. The sweep window is now one sweep
        // interval wide plus scheduler-delay tolerance, so consecutive sweeps
        // can legitimately both consider the same reminder due, which makes
        // this the load-bearing guard rather than a theoretical one. A pending
        // row older than the lease is treated as genuinely lost and retried,
        // so a crash between the write and the send still recovers.
        if (existingDelivery.exists && existingDelivery.get("status") === "pending") {
          const attemptedAtMs = millisOf(existingDelivery.get("updatedAt"));
          if (
            attemptedAtMs !== null &&
            timestampNow.toMillis() - attemptedAtMs < pendingAttemptLeaseMs
          ) {
            return false;
          }
        }
        transaction.set(deliveryRef, {
          ...inboxPayload,
          createdAt: timestampNow,
          sentAt: timestampNow,
          status: "pending",
          updatedAt: timestampNow,
        });
        transaction.set(
          dependencies.firestore
            .collection("notificationInbox")
            .doc(dispatch.uid)
            .collection("items")
            .doc(dispatch.deliveryKey),
          {
            ...createInboxPayload(dispatch, device.tokenFingerprint, now),
            createdAt: timestampNow,
            updatedAt: timestampNow,
          },
          { merge: true },
        );
        return true;
      });
      if (!deliveryCreated) {
        return { status: "skipped-duplicate" };
      }

      try {
        await dependencies.messaging.send({
          token: device.fcmToken,
          notification: {
            title: dispatch.title,
            body: dispatch.body,
          },
          data: {
            deliveryKey: dispatch.deliveryKey,
            kind: dispatch.kind,
            scheduledDate: dispatch.scheduledDate,
            ...(dispatch.scheduledWorkoutId === null
              ? {}
              : { scheduledWorkoutId: dispatch.scheduledWorkoutId }),
          },
        });
        await deliveryRef.set({ status: "sent", sentAt: timestampNow, updatedAt: timestampNow }, { merge: true });
        return { status: "sent" };
      } catch (error) {
        if (isInvalidTokenError(error)) {
          await deliveryRef.set({ status: "invalid-token", updatedAt: timestampNow }, { merge: true });
          return { status: "invalid-token", disabledAt: now };
        }
        await deliveryRef.set(
          {
            status: "failed",
            errorCode: errorCode(error),
            updatedAt: timestampNow,
          },
          { merge: true },
        );
        throw error;
      }
    },
    disableToken: async (device: NotificationDeviceRecord, disabledAt: string) => {
      await dependencies.firestore
        .collection("notificationDevices")
        .doc(device.uid)
        .collection("tokens")
        .doc(device.tokenFingerprint)
        .set(
          {
            enabled: false,
            disabledAt,
            updatedAt: Timestamp.fromDate(new Date(disabledAt)),
          },
          { merge: true },
        );
    },
  };
}

function isInvalidTokenError(error: unknown): boolean {
  const code = errorCode(error);
  return code === "messaging/invalid-registration-token" || code === "messaging/registration-token-not-registered";
}

function errorCode(error: unknown): string {
  if (isRecord(error) && typeof error["code"] === "string") {
    return error["code"];
  }
  return "unknown";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function millisOf(value: unknown): number | null {
  if (value instanceof Timestamp) {
    return value.toMillis();
  }
  if (typeof value === "string") {
    const parsed = Date.parse(value);
    return Number.isNaN(parsed) ? null : parsed;
  }
  return null;
}
