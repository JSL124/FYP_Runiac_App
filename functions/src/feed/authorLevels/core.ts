import { HttpsError } from "firebase-functions/v2/https";
import type { FeedRelationshipCheckInput } from "../relationship.js";
import { evaluateFeedRelationship } from "../relationship.js";
import { resolveProfileLevelDisplay, type ProfileLevelDisplay } from "../../progression/profileLevelDisplay.js";
import { resolveProfileIdentityDisplay, type ProfileIdentityDisplay } from "../../profile/profileIdentityDisplay.js";

export type FeedAuthorLevelsRequest = { readonly auth?: { readonly uid: string }; readonly data: unknown };

/**
 * One author's CURRENT display identity and level, as the viewer's Feed should
 * render them right now.
 *
 * A Feed post and a Feed comment both freeze `authorDisplayName`,
 * `authorAvatarInitials`, and `authorLevelLabel` at write time, and
 * `feedPosts` is closed to every client write, so a renamed runner would keep
 * appearing under their old name on every earlier post. This is what the
 * client overlays on top of those stored values.
 *
 * The callable id stays `getFeedAuthorLevels` because it is already deployed
 * and older app builds still call it; only its result grew.
 */
export type FeedAuthorLevel = ProfileLevelDisplay & ProfileIdentityDisplay;
export type FeedAuthorLevelsResult = { readonly levels: Readonly<Record<string, FeedAuthorLevel>> };
export interface FeedAuthorLevelsPorts {
  relationshipFor(viewerUid: string, authorUid: string): Promise<FeedRelationshipCheckInput>;
  readProfiles(uids: readonly string[]): Promise<readonly (Readonly<Record<string, unknown>> | undefined)[]>;
}

const MAX_UIDS = 50;

export async function getFeedAuthorLevels(request: FeedAuthorLevelsRequest, ports: FeedAuthorLevelsPorts): Promise<FeedAuthorLevelsResult> {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) throw new HttpsError("unauthenticated", "Authentication is required.");
  const requested = parseUids(request.data);
  if (requested === undefined) throw new HttpsError("invalid-argument", "Invalid author levels request.");
  const unique = [...new Set(requested)];
  if (unique.length > MAX_UIDS) throw new HttpsError("invalid-argument", `At most ${MAX_UIDS} uids may be requested.`);
  if (unique.length === 0) return { levels: {} };
  const permittedFlags = new Map<string, boolean>();
  await Promise.all(unique.map(async (authorUid) => {
    if (authorUid === uid) { permittedFlags.set(authorUid, true); return; }
    const relationship = evaluateFeedRelationship(await ports.relationshipFor(uid, authorUid));
    permittedFlags.set(authorUid, relationship.kind === "allowed_owner" || relationship.kind === "allowed_friend");
  }));
  const permitted = unique.filter((authorUid) => permittedFlags.get(authorUid) === true);
  if (permitted.length === 0) return { levels: {} };
  const profiles = await ports.readProfiles(permitted);
  const levels: Record<string, FeedAuthorLevel> = {};
  permitted.forEach((authorUid, index) => {
    levels[authorUid] = { ...resolveProfileLevelDisplay(profiles[index]), ...resolveProfileIdentityDisplay(profiles[index]) };
  });
  return { levels };
}

function parseUids(raw: unknown): readonly string[] | undefined {
  if (!isRecord(raw) || Object.keys(raw).length !== 1) return undefined;
  const uids = raw["uids"];
  if (!Array.isArray(uids) || !uids.every(isNonEmptyString)) return undefined;
  return uids;
}
function isNonEmptyString(value: unknown): value is string { return typeof value === "string" && value.length > 0; }
function isRecord(value: unknown): value is Readonly<Record<string, unknown>> { return typeof value === "object" && value !== null && !Array.isArray(value); }
