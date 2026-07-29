# Capsule: Level Progress Ring Live Fan-Out

Backend Guarded Lane (ADR-003), emulator-first (ADR-002). Explicitly user-routed on
2026-07-29 Asia/Singapore as a follow-up to `friends-live-level` and `profile-photo-avatar`.

## Problem

`RuniacLevelProfileBadge` draws an XP ring around the avatar disc on every surface that shows
a runner's profile circle. Three of those surfaces passed a hardcoded literal `0` for
`progressFraction`, so the ring painted only its track and never any progress — not "0%
progress", but "no data reached this widget":

- `lib/features/leaderboard/presentation/widgets/leaderboard_rank_row_helpers.dart:64` — every
  leaderboard rank row, on both the region preview sheet and the routed ranking page.
- `lib/features/challenge/presentation/challenge_friend_picker_screen.dart:240` — every
  challenge invite picker row.
- `lib/features/challenge/presentation/challenge_lobby_screen.dart:691` — every challenge
  lobby roster row.

The three had different causes, not one:

1. **Leaderboard** — no data existed anywhere in the pipeline. `LeaderboardPublicEntry`
   (`functions/src/leaderboard/leaderboardTypes.ts`) carried no progress field, so neither
   `leaderboardSnapshots.topEntries` nor `leaderboardUserRanks.currentEntry`/`nearbyEntries`
   could supply one.
2. **Invite picker** — the data was already in hand and discarded.
   `home_tab.dart:343` maps `FriendUserReadModel` (which carries a `levelProgressFraction`
   resolved through `getFriendLevels`) into `ChallengeInvitableFriend`, a model that had no
   such field.
3. **Lobby roster** — `ChallengeParticipantRow` carried `levelLabelSnapshot` and
   `avatarUrlSnapshot` but no progress snapshot, and `ParticipantLiveDisplay` on the backend
   resolved only the label and the avatar.

A fourth, adjacent defect surfaced during the same inspection and is fixed here because it is
one line on the same read path: the **Friends Search tab renders no profile photo**.
`friendsDiscovery.ts` returns `buildFriendIdentity` output, which is derived from the nickname
alone and carries no `avatarUrl`. The other four Friends tabs are unaffected — they overlay
their avatar from `getFriendLevels`, which Search never calls, having no social edge to the
runner yet. This belongs to `profile-photo-avatar`'s fan-out, which missed this one surface;
that capsule's path predicate is extended rather than this one claiming the file.

Verified not affected: Home header, Home stage-map header, account profile identity, Friends /
Requests / Blocked rows, Feed post and comment authors, share-route feed preview, and the
runner achievement profile screen all already pass a backend-resolved fraction.

## Decision

Publish the progress the same way each surface already publishes the level label beside it,
reusing the existing shared reader rather than adding a new one. No new callable, no new
collection, no new client computation, and no extra Firestore read anywhere.

`functions/src/progression/profileLevelDisplay.ts` (`resolveProfileLevelDisplay`) is already
the single source of the label/clamp rules for `getFriendLevels`, `getFeedAuthorLevels`, and
the `searchFriends` enrichment. Both new producers resolve through it, so a runner's ring
reads identically on every surface.

The leaderboard's `levelLabel` moves onto the same live source as the percent, rather than
staying frozen on the contribution. This is deliberate and was explicitly approved by the user
on 2026-07-29:

- It is the same staleness class the `publish the live nickname on ranked rows` fix
  (`c8276481`) already corrected — a contribution is only rewritten by a run **in that region
  and period**, so levelling up on a run elsewhere never updates this board's copy.
- Publishing only the percent would produce a knowingly inconsistent pair: a frozen `Lv.8`
  pill next to a live ring showing Lv.9's progress.

`divisionKey` remains the contribution's, because it is the board **grouping** key; only the
displayed label changes, so no runner moves between boards.

## Authorization

No new exposure surface. `levelProgressPercent` is a backend-owned field already published to
other signed-in users through three existing callables (`getFriendLevels`,
`getFeedAuthorLevels`, `getRunnerPublicProfile`). Adding it to `LeaderboardPublicEntry` places
it in `leaderboardSnapshots` (`allow read: if isSignedIn()`), alongside the alias, level label,
score, and avatar URL already published there; it discloses no uid and no new category of
personal data. The challenge roster field is served only to lobby members, exactly like the
level label it sits beside.

## Implementation

Backend:

- `functions/src/leaderboard/leaderboardTypes.ts` — `levelProgressPercent: number` added to
  `LeaderboardPublicEntry`.
- `functions/src/leaderboard/monthlyLeaderboardPlanner.ts` — new optional
  `levelDisplayByOwner` input, mirroring the existing `avatarUrlByOwner` /
  `publicAliasByOwner` convention. `publicEntry()` prefers the live label and falls back to the
  contribution's; the percent defaults to `0`. Omitting the map preserves every existing
  caller's behaviour exactly.
- `functions/src/leaderboard/monthlyLeaderboardWriter.ts` — builds that map from the
  `ownerFacts` it already loads for the premium re-check, through
  `resolveProfileLevelDisplay`. **Zero additional Firestore reads.**
- `functions/src/challenge/challengeLobbySupport.ts` — `levelProgressPercent` added to
  `ParticipantLiveDisplay`, `levelProgressPercentSnapshot` to `ChallengeParticipantView`, and
  the mapping to `serializeParticipant`.
- `functions/src/challenge/challengeLobbyCore.ts` — `readParticipantLiveDisplays` now resolves
  through `resolveProfileLevelDisplay`, replacing a local `participantLevelLabel` helper that
  had drifted into a duplicate of that reader's label rules.
- `functions/src/friends/friendsDiscovery.ts` — the search result is spread with
  `resolveProfileAvatarDisplay` from the profile snapshot it had already fetched.
- `functions/src/friends/{friendsTypes.ts,friendsCore.ts,callable.ts}` — `avatarContext`
  threaded onto `FriendsDependencies`, defaulted to `NULL_AVATAR_URL_CONTEXT` by
  `createFriendsService` (so an un-injected caller fails closed to `avatarUrl: ""`), and
  injected for real at the one callable that needs it, `searchFriends`.

Flutter:

- Leaderboard: `levelProgressFraction` on `LeaderboardRowReadModel` and
  `LeaderboardRankRowDisplaySnapshot`; `_progressFraction` parsing in
  `firestore_leaderboard_repository.dart` (the same `/100` + clamp Friends and Feed use);
  passthrough in the display adapter, `LeaderboardInitialBadge`, the preview sheet, and the
  ranking screen.
- Challenge picker: `levelProgressFraction` on `ChallengeInvitableFriend`, populated from
  `FriendUserReadModel` at `home_tab.dart`.
- Challenge lobby: `levelProgressPercentSnapshot` on `ChallengeParticipantRow` with a lenient
  clamped parse matching `avatarUrlSnapshot`'s; a `levelProgressPercentSeed` alongside the
  existing label and avatar seeds in `mapActiveChallengeView` and the realtime watch; the
  `/100` conversion at `_rosterBadge`.
- Friends Search: `friendAvatarUrlValue` in `friend_identity_mapper.dart`, populating
  `FriendUserReadModel.avatarUrl` from the enriched callable result. The URL stays raw and is
  sanitised at the render site, as every other avatar URL in the client is.

## Validation

- `functions`: `npx tsc --noEmit` clean. Leaderboard suite 35/35, challenge lobby + callable
  surface 65/65, friends core 34/34 — all pass, including 9 new tests.
- Flutter: `flutter analyze --no-pub` clean; full `flutter test --no-pub` run recorded in the
  session evidence, with 8 new tests.
- Every new field is additive and defaults to the pre-change rendering, so a client reading a
  document written before the deploy shows the empty ring it showed before, never an error.

## Forbidden

Any production `runiac-fypp` deploy without separate authorization; `firestore.rules`,
storage rules, or index changes; client-side computation of level, XP, progress, rank, or
score; deriving the ring from `scoreLabel` or any XP input; denormalizing progress onto
contribution or participant documents; any change to the XP/level/rank/streak/leaderboard-score
formulas; any premium-vs-basic divergence; changing `divisionKey` grouping; new dependencies or
secrets; edits inside the isolated `adaptive-character-guidance` worktree.

## Production Deploy Record (runiac-fypp, 2026-07-29 Asia/Singapore)

Separately authorized by the user on 2026-07-29 and deployed as a scoped
`firebase deploy --only functions:...` covering exactly the four functions whose behaviour
this capsule changes:

- `refreshLeaderboardSnapshots` (scheduled, `asia-southeast1`) — ACTIVE
- `leaderboardAdminCommandCreated` (Firestore trigger, `asia-southeast1`) — ACTIVE
- `getActiveChallenge` (callable, `asia-southeast1`) — ACTIVE
- `searchFriends` (callable, `asia-southeast1`) — ACTIVE

Scope confirmed before deploying: `sortedParticipantViews`/`serializeParticipant` have exactly
one consumer (`getActiveChallengeForCallable`), so no other challenge function serves the new
participant field; and `leaderboardSeedVerification.ts` is reached only by
`seedLeaderboardMockData`, a CLI that `index.ts` never exports, so its guard change ships no
function. No rules, index, or storage deploy was performed, and none is required.

The Friends Search photo and the challenge rings are live immediately, both being callable
reads. The leaderboard rings appear once `refreshLeaderboardSnapshots` republishes the boards
on its `every 60 minutes` schedule, or sooner if an admin recalculation command is issued.

## Open Items

- The leaderboard ring, like the alias and avatar beside it, is republished on the up-to-hourly
  snapshot refresh, so it can lag a just-finished run by up to an hour. Making the current
  user's own row tick live from the already-streaming `UserProgressReadModel` was considered
  and deliberately deferred — it would make one row disagree with the board it sits on.
- The challenge lobby's realtime seed keeps its documented pre-existing limitation: a
  stream-only update for a uid the `activeChallenge()` seed never saw renders an empty ring,
  the same fallback the avatar already takes.
