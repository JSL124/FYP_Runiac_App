/**
 * Shared reader for the backend-owned identity display fields stored on a
 * `userProfiles/{uid}` document.
 *
 * Feed posts and Feed comments freeze the author's name and initials at write
 * time, so a rename would otherwise leave every earlier post labelled with the
 * old name forever. Every surface that shows another runner's CURRENT identity
 * resolves it through this single helper — the runner public profile
 * projection and the Feed author overlay — so the nickname-wins rule and the
 * trimming rules exist in exactly one place.
 *
 * This only ever reads `nickname` / `displayName` / `avatarInitials`, all of
 * which the nickname callable already owns and wrote. It never derives an
 * identity from anything else.
 */

export type ProfileIdentityDisplay = {
  readonly displayName: string;
  readonly avatarInitials: string;
};

export function resolveProfileIdentityDisplay(data: Readonly<Record<string, unknown>> | undefined): ProfileIdentityDisplay {
  return { displayName: profileDisplayName(data), avatarInitials: trimmedString(data?.["avatarInitials"]) };
}

/**
 * The nickname wins when the runner set one, matching how they see their own
 * account screen and how the leaderboard labels their row.
 */
function profileDisplayName(data: Readonly<Record<string, unknown>> | undefined): string {
  const nickname = trimmedString(data?.["nickname"]);
  return nickname.length > 0 ? nickname : trimmedString(data?.["displayName"]);
}

function trimmedString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}
