# Capsule: Runner Profile Entry Points

Backend Guarded Lane (ADR-003), emulator-first (ADR-002). Explicitly user-routed on
2026-07-27 Asia/Singapore as a direct follow-up to the merged runner public profile work
(PR #37 `feat(profile): show another runner's public profile`, PR #38 the review fixes on it).

## Problem

The runner public profile was reachable from exactly one place: a leaderboard rank row.
Every other surface that renders another runner's avatar left it inert —
feed post authors (`feed_post_section.dart`), feed comment authors
(`feed_comment_list.dart`), all four Friends tabs via the shared `FriendRowBadge`
(`friend_row_identity.dart`), the challenge lobby roster and progress participants
(`challenge_lobby_screen.dart`, `challenge_progress_screen.dart`), and the challenge friend
picker (`challenge_friend_picker_screen.dart`).

Two things blocked it:

1. **Addressing.** `getRunnerPublicProfile` accepted only `{snapshotId, rankLabel, buildId}`.
   That form exists because `leaderboardSnapshots` deliberately publishes no uid — putting one
   there would hand every signed-in client a uid directory — and PR #38's review removed the
   uid-addressed form entirely to stop arbitrary-uid probing. But every non-leaderboard surface
   holds a uid and nothing else, so none of them could call it.
2. **Wiring.** The repository was threaded five constructor hops to reach only `LeaderboardTab`.
   The feed, friends and challenge screens never received it, and the challenge screens alone
   are pushed from seven sites across four files.

## Decision

Restore a uid-addressed form behind a visibility gate, and hand the repository down through a
scope instead of constructor threading.

The gate answers "may this caller see this runner at all", and its branches are exactly the
relationships that already let the caller see that person's name and level somewhere in the app:

- the caller themself;
- publicly discoverable, decided by `socialProfile()` — the same predicate `searchFriends`
  uses, so "findable by nickname search" and "openable from a search result" cannot drift apart;
- an edge at `users/{caller}/friends/{uid}` or `users/{caller}/friendRequests/{uid}`;
- on the roster of the caller's active challenge (`challengeSlots/{caller}` →
  `challengeInstances/{id}.rosterUids`).

Blocks in either direction and suspended accounts always deny. The response still carries no
uid, and the leaderboard form is untouched.

Two deliberate rejections:

- The edge check does **not** reuse `friendLevels`' `hasSocialEdge`, which ORs in
  `blockedUsers` — that would turn "I blocked them" into a visibility grant.
- The Blocked tab is **not** an entry point. A block denies both ways, so the tap could only
  ever answer "not available"; offering it would be dishonest UI.

## Authorization

`users/{uid}`, `userProfiles/{uid}` and `users/{uid}/challengeBadges` are owner-read-only in
`firestore.rules`, so the projection stays server-side; no rules or index change is needed
because the gate is document gets only.

Every denial on the uid path returns the same `not-found` and message, **and performs the same
four reads in the same order**. The identical body alone was not enough: an early bail-out let a
caller time the call and distinguish "no such runner" from "not allowed", which is the existence
oracle the single error code exists to close. Only the allow path short-circuits.

## Implementation

Backend (`functions/src/profile/publicProfile/{core,callable}.ts`):

- `parseTarget` becomes a discriminated union over `{snapshotId, rankLabel, buildId}` and `{uid}`.
- Two ports added: `readSocialEdge` (reusing `friendsPaths.ts` helpers) and `isChallengeCoMember`
  (reusing `challengeLobbySupport.ts` `slotRef`/`instanceRef`/`readRoster`).
- `denyCode` keeps the leaderboard path's existing codes byte-for-byte.

Client:

- `RunnerPublicProfileQuery.runner({uid})` alongside the leaderboard form.
- `RunnerPublicProfileScope` (mirroring `RunRepositoryScope`) installed above `MaterialApp` in
  `app.dart`; the four hops below it are deleted.
- `openRunnerProfile()` seeds a snapshot from what the surface already shows and lets the
  callable fill in the rest; `RunnerProfileAvatarLink` owns the tap target, semantics label and
  44px hit area, collapsing to today's exact `ExcludeSemantics` when disabled.
- Nine avatar surfaces wired. The viewer's own avatar is never linked, and the link is disabled
  wherever the viewer cannot be identified at all — `viewerUserId` is null on the demo feed path
  and `ownsComment` is always false without a repository, so an "is this me?" comparison alone
  would have linked the runner to their own profile there.

Executed as an orchestrator/worker capsule: Opus orchestrates, verifies every diff against these
constraints, and issues delta corrections; Sonnet workers implement one scoped task at a time
(W1 backend gate, W2 emulator integration, W3 client wiring, W4 friends+feed, W5 challenge).

## Validation

- Backend: 24 core unit tests over fake ports and 20 emulator integration tests through the real
  ports, covering every gate branch, denial uniformity (body **and** read count), and that a
  profile with an inconsistent nickname index is not treated as discoverable.
- HTTPS end-to-end against the emulator with a real ID token: 13 steps, asserting all four
  denials are byte-identical and that neither a uid nor any private profile field leaves the
  server.
- A new app-tree test asserts the real `RuniacApp` installs the scope. Without it the
  entry-point tests would all pass while the feature silently degraded to seed-only previews in
  production.
- Regression: Flutter 2216/2216, Cloud Functions 825/825 across all five emulator groups,
  Firestore rules 66/66, `flutter analyze` clean, Governance CI green.

## Forbidden

Any production `runiac-fypp` deploy without separate authorization; `firestore.rules` or index
changes; echoing a resolved uid back to the client; publishing a uid in `leaderboardSnapshots`;
client-side computation of any XP/level/rank/streak/leaderboard value; new dependencies or
secrets; and any edit or staging inside the isolated `adaptive-character-guidance` worktree.

## Open Items

- `getRunnerPublicProfile` needs a separately authorized scoped deploy before the new avatars
  resolve; until then they open into the seed-only state.
- The co-member branch reads `challengeSlots/{caller}`, which holds only the active challenge, so
  a participant opened from a settled challenge falls through to the discoverability branch.
- Reporting a runner now works from a uid-opened profile; it remains unavailable from a
  leaderboard-opened one, which would need its own server-resolved write.
- Feed rows have no `explicitChildNodes` semantics boundary, so an avatar's label merges with the
  adjacent text into one node. Cosmetic; the tap target and gating are unaffected.
