import { HttpsError } from "firebase-functions/v2/https";
import { isSuspendedAccount } from "../../security/accountStatus.js";

/**
 * The public running-achievement projection of one runner, as shown on the
 * runner profile screen a viewer opens from the leaderboard.
 *
 * Every field here is a value a Cloud Function already computed and wrote to
 * `userProfiles/{uid}` (or a badge document a settled challenge wrote). This
 * projection only relays them: it must never derive a level from XP, a rank
 * from a score, a streak from run dates, or badge ownership from anything
 * other than the durable badge documents.
 *
 * Deliberately excluded — these are the private half of a profile and must
 * not leak through this callable: email, full name, date of birth, age,
 * weight, onboarding answers, plan setup, activity history, and every route
 * or GPS value.
 */
export type RunnerPublicProfile = {
  readonly uid: string;
  readonly displayName: string;
  readonly avatarInitials: string;
  readonly regionLabel: string;
  readonly levelLabel: string;
  readonly level: number;
  readonly levelProgressPercent: number;
  readonly totalXp: number | null;
  readonly nextLevelXp: number | null;
  readonly xpToNextLevel: number | null;
  readonly isMaxLevel: boolean;
  readonly divisionKey: string;
  readonly divisionLabel: string;
  readonly longestStreakLabel: string;
  readonly totalDistanceLabel: string;
  readonly subscriptionStatusLabel: string;
  readonly ownedBadgeTierIds: readonly string[];
};

export type RunnerPublicProfileRequest = { readonly auth?: { readonly uid: string }; readonly data: unknown };

export type BlockEdges = { readonly callerBlockedTarget: boolean; readonly targetBlockedCaller: boolean };

export interface RunnerPublicProfilePorts {
  /**
   * Block edges in both directions. A block either way hides the profile, the
   * same symmetry the Feed relationship check applies.
   */
  readBlockEdges(callerUid: string, targetUid: string): Promise<BlockEdges>;
  readProfile(uid: string): Promise<Readonly<Record<string, unknown>> | undefined>;
  readAccount(uid: string): Promise<Readonly<Record<string, unknown>> | undefined>;
  /** Document ids of `users/{uid}/challengeBadges`, i.e. the earned tier ids. */
  readOwnedBadgeTierIds(uid: string): Promise<readonly string[]>;
  /**
   * The uid behind one leaderboard entry, addressed the only way a viewer can
   * address it: by the snapshot it appears in and its rank within that
   * snapshot. `undefined` when no single rank projection matches.
   *
   * This exists because `leaderboardSnapshots` is readable by every signed-in
   * user and therefore carries NO uid — publishing one there would hand out a
   * uid directory. The reverse mapping stays server-side, in the
   * backend-written `leaderboardUserRanks` projection.
   */
  resolveLeaderboardEntryOwner(snapshotId: string, rankLabel: string): Promise<string | undefined>;
}

const UNAVAILABLE_MESSAGE = "This runner profile is not available.";

export async function getRunnerPublicProfile(
  request: RunnerPublicProfileRequest,
  ports: RunnerPublicProfilePorts,
): Promise<RunnerPublicProfile> {
  const callerUid = request.auth?.uid;
  if (callerUid === undefined || callerUid.length === 0) throw new HttpsError("unauthenticated", "Authentication is required.");
  const target = parseTarget(request.data);
  if (target === undefined) throw new HttpsError("invalid-argument", "Invalid runner profile request.");
  const targetUid = target.kind === "uid"
    ? target.uid
    : await ports.resolveLeaderboardEntryOwner(target.snapshotId, target.rankLabel);
  // A rank that resolves to no owner, or to more than one, is treated exactly
  // like a runner who does not exist: the viewer learns nothing either way.
  if (targetUid === undefined || targetUid.length === 0) throw new HttpsError("not-found", UNAVAILABLE_MESSAGE);

  if (targetUid !== callerUid) {
    const edges = await ports.readBlockEdges(callerUid, targetUid);
    if (edges.callerBlockedTarget || edges.targetBlockedCaller) throw new HttpsError("permission-denied", UNAVAILABLE_MESSAGE);
  }

  const [profile, account] = await Promise.all([ports.readProfile(targetUid), ports.readAccount(targetUid)]);
  if (profile === undefined) throw new HttpsError("not-found", UNAVAILABLE_MESSAGE);
  // A suspended or banned runner's profile stops being viewable at all, so a
  // moderation action removes them from every viewer's reach, not just from
  // the leaderboard.
  if (isSuspendedAccount(account)) throw new HttpsError("permission-denied", UNAVAILABLE_MESSAGE);

  const ownedBadgeTierIds = await ports.readOwnedBadgeTierIds(targetUid);
  return {
    uid: targetUid,
    displayName: profileDisplayName(profile),
    avatarInitials: trimmedString(profile["avatarInitials"]),
    regionLabel: trimmedString(profile["locationLabel"]),
    levelLabel: trimmedString(profile["levelLabel"]),
    level: nonNegativeInteger(profile["level"]),
    levelProgressPercent: clampedPercent(profile["levelProgressPercent"]),
    totalXp: nonNegativeIntegerOrNull(profile["totalXp"]),
    nextLevelXp: nonNegativeIntegerOrNull(profile["nextLevelXp"]),
    xpToNextLevel: nonNegativeIntegerOrNull(profile["xpToNextLevel"]),
    // Max level is asserted by the backend writing an explicit null, exactly
    // the signal the runner's own progress read model uses. An absent field
    // means "not published yet", never "max level".
    isMaxLevel: "xpToNextLevel" in profile && profile["xpToNextLevel"] === null,
    divisionKey: trimmedString(profile["divisionKey"]),
    divisionLabel: trimmedString(profile["divisionLabel"]),
    longestStreakLabel: trimmedString(profile["longestStreakLabel"]),
    totalDistanceLabel: trimmedString(profile["totalDistanceLabel"]),
    subscriptionStatusLabel: subscriptionStatusLabel(account),
    ownedBadgeTierIds,
  };
}

/**
 * The nickname wins when the runner set one, matching how they see their own
 * account screen and how the leaderboard labels their row.
 */
function profileDisplayName(profile: Readonly<Record<string, unknown>>): string {
  const nickname = trimmedString(profile["nickname"]);
  return nickname.length > 0 ? nickname : trimmedString(profile["displayName"]);
}

/**
 * Relays the trusted Basic/Premium tier. An unknown or missing value resolves
 * to Basic so an unrecognised value is never shown as Premium.
 */
function subscriptionStatusLabel(account: Readonly<Record<string, unknown>> | undefined): string {
  const status = account?.["subscriptionStatus"];
  return typeof status === "string" && status.trim().toLowerCase() === "premium" ? "Premium" : "Basic";
}

/**
 * The two ways a viewer may address a runner:
 * - `{uid}` — a uid the viewer legitimately holds already (their own, or one
 *   a future friends/feed surface passes in).
 * - `{snapshotId, rankLabel}` — a leaderboard entry, which is all a viewer
 *   ever has for another runner, because the public snapshot carries no uid.
 * Exactly one form, with exactly its own keys and nothing else.
 */
type RunnerTarget =
  | { readonly kind: "uid"; readonly uid: string }
  | { readonly kind: "leaderboardEntry"; readonly snapshotId: string; readonly rankLabel: string };

function parseTarget(raw: unknown): RunnerTarget | undefined {
  if (!isRecord(raw)) return undefined;
  const keys = Object.keys(raw).sort();
  if (keys.length === 1 && keys[0] === "uid") {
    const uid = safeIdentifier(raw["uid"], 128);
    return uid === undefined ? undefined : { kind: "uid", uid };
  }
  if (keys.length === 2 && keys[0] === "rankLabel" && keys[1] === "snapshotId") {
    const snapshotId = safeIdentifier(raw["snapshotId"], 256);
    const rankLabel = safeIdentifier(raw["rankLabel"], 16);
    if (snapshotId === undefined || rankLabel === undefined) return undefined;
    return { kind: "leaderboardEntry", snapshotId, rankLabel };
  }
  return undefined;
}

function safeIdentifier(value: unknown, maxLength: number): string | undefined {
  if (typeof value !== "string" || value.length === 0 || value.length > maxLength) return undefined;
  if (value.includes("/") || value.includes("..") || /[\u0000-\u001F\u007F]/u.test(value)) return undefined;
  return value;
}

function trimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function nonNegativeInteger(value: unknown): number {
  return typeof value === "number" && Number.isInteger(value) && value >= 0 ? value : 0;
}

function nonNegativeIntegerOrNull(value: unknown): number | null {
  return typeof value === "number" && Number.isInteger(value) && value >= 0 ? value : null;
}

function clampedPercent(value: unknown): number {
  const percent = typeof value === "number" && Number.isFinite(value) ? value : 0;
  return Math.min(100, Math.max(0, percent));
}

function isRecord(value: unknown): value is Readonly<Record<string, unknown>> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
