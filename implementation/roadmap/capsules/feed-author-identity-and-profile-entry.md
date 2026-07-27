# feed-author-identity-and-profile-entry

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Mode / Type

Mode: IMPLEMENTATION_MODE. The user reported both defects from QA on 2026-07-27 Asia/Singapore, reviewed the diagnosis, and explicitly authorized implementing both (option "b": the nickname fix plus the Feed/Friends profile entry points including their backend).

Type: Backend Guarded Lane capsule (an existing read-only callable's result widened, plus display-only Flutter wiring), emulator-first per ADR-002, lane classification per ADR-003.

## Scope Correction — 2026-07-27

This capsule was authored against `a62be838` and originally covered **two** defects. Defect 2 (uid-addressed runner profile entry points) had **already been implemented and merged** on `main` by PR #39 (`8b5c097d`, branch `JSL124/feat-profile-entry-points`) with a different design; this capsule's branch was cut before that merge and re-implemented the same feature independently.

On rebasing onto `origin/main` the user explicitly decided to keep PR #39's implementation. Everything this capsule wrote for defect 2 was therefore dropped:

| Dropped from this capsule | Kept from PR #39 instead |
| --- | --- |
| `RunnerTarget` `{ runnerUid }` form gated on `evaluateFeedRelationship` (accepted mutual friendship only) | `RunnerTarget` `{ uid }` form gated on own-uid / active `socialDiscoveryStatus` / social edge / shared challenge roster, with every denial costing the same reads |
| `readFriendshipRelationship` port in `publicProfile/callable.ts` | existing `readBlockEdges` / `readSocialEdge` / `isChallengeCoMember` ports |
| `openRunnerPublicProfile` helper, repository threaded through shell → feed → home → friends | `RunnerPublicProfileScope` (`InheritedWidget`), `openRunnerProfile`, `RunnerProfileAvatarLink` |
| whole-row `RuniacTappableSurface` on the Feed author row and the friend row | avatar-scoped `RunnerProfileAvatarLink` on both |

**The profile entry points and their authorization that ship to users are PR #39's, not this capsule's.** This capsule no longer changes `getRunnerPublicProfile`'s authorization in any way.

What remains in scope is defect 1 only, plus one refactor: routing PR #39's runner-public-profile projection through the same new identity reader, so the nickname-wins rule lives in one place rather than two copies.

## Problem

**A renamed runner keeps their old name on every post they already shared.** A Feed post freezes `authorDisplayName` / `authorAvatarInitials` at publish time (`functions/src/feed/contracts.ts:112`), and a Feed comment freezes the same values at write time (`firebase_feed_data_port.dart`, enforced by `matchesCallerProfileSnapshot()` in `firestore.rules`). Nothing refreshes either afterwards: `upsertNickname`'s fan-out (`functions/src/friends/friendsNicknameFanout.ts`) rewrites only the `friends`, `friendRequests`, and `blockedUsers` collection groups, and `firestore.rules` denies every client write to `feedPosts` (`allow create, update, delete: if false`), so no client could repair a stale name even if it wanted to. This is the identical failure mode `feed-live-author-level` already fixed for `authorLevelLabel` — the name was simply never included.

## Decision

Show the author's CURRENT identity through the same live overlay that already carries their level, with NO data migration and no backfill. The stored `authorDisplayName` / `authorAvatarInitials` stay exactly as written and become an offline/fallback cache rather than the source of truth.

A backfill was considered and rejected: the rename transaction already reserves 497 of Firestore's 500 transaction writes for social-identity rows (`NICKNAME_RENAME_MAX_FANOUT_ROWS`), the post and comment counts are unbounded, and a backfill would still leave every post published before it ran uncorrected. The overlay fixes all history at once and costs no writes.

## Constraint

`userProfiles/{uid}` is owner-read-only in `firestore.rules`, so a viewer cannot read another runner's current name directly under any existing rule — it must be resolved server-side, per request, with its own authorization check. That is why the overlay extends the already-deployed `getFeedAuthorLevels` rather than introducing a client read.

## Implementation

### Backend

- `functions/src/profile/profileIdentityDisplay.ts` (new): the single reader for backend-owned identity display fields on `userProfiles/{uid}` — nickname wins over `displayName`, both trimmed — mirroring how `functions/src/progression/profileLevelDisplay.ts` already centralizes the level rules.
- `functions/src/feed/authorLevels/core.ts`: `FeedAuthorLevel` widens from `ProfileLevelDisplay` to `ProfileLevelDisplay & ProfileIdentityDisplay`, so each permitted uid now returns `displayName` and `avatarInitials` alongside its level. The callable id stays `getFeedAuthorLevels` because it is already deployed and older app builds still call it; only the result grew. Authorization, the 50-uid cap, the dedup, and the silent omission of unauthorized uids are all unchanged.
- `functions/src/profile/publicProfile/core.ts`: the projection's `displayName` / `avatarInitials` now resolve through `resolveProfileIdentityDisplay` instead of a private local copy of the same nickname-wins rule. Behaviour is identical; the duplicate helper is deleted. **No authorization change** — the target forms, the gate, the denial codes, and the constant-cost read ordering PR #39 established are all untouched.

### Client (display-only)

- `FeedAuthorLevel` (`feed_data_port.dart`) carries `displayName` / `avatarInitials`, defaulting to empty. `firebase_feed_data_port.dart` parses them defensively, so a backend deployment that predates this change simply omits them.
- `feed_timeline_page_loader.dart` and `feed_comment_page_loader.dart` overlay name, initials, and level **independently**: each field is replaced only when the backend resolved a non-empty value, and an empty resolved value never erases what the post or comment already stores. Combined with the resolver swallowing its own failures, the Feed still paints when the overlay resolves nothing at all.
- Rename propagation on the renamer's own device: `HomeTab.onAccountProfileChanged` fires when the Account screen closes, the shell re-reads the feed-author profile, and `CurrentSessionFeed` re-reads the timeline only when the viewer's name or initials actually changed (a level change alone is already applied in place and must not pay for a reload). Without this the fix would only be visible after a manual pull-to-refresh.

## Validation Evidence

Recorded after the rebase onto `origin/main` in the follow-up commit on this branch.

## Allowed Scope

- `functions/src/profile/profileIdentityDisplay.ts` (new)
- `functions/src/profile/publicProfile/core.ts` (identity-reader refactor only)
- `functions/src/feed/authorLevels/core.ts`
- `functions/test/feedAuthorLevels.test.ts`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_timeline_page_loader.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/comments/feed_comment_page_loader.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/current_session_feed.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/test/feed_author_level_overlay_test.dart`
- `implementation/mobile/runiac_app/test/feed_author_level_resolver_test.dart`
- `implementation/mobile/runiac_app/test/feed_author_rename_refresh_test.dart` (new)
- `implementation/mobile/runiac_app/test/home_static_ui_test.dart` (one expectation, because returning from Account now also re-reads the feed-author profile)
- `implementation/roadmap/capsules/feed-author-identity-and-profile-entry.md` (this file, new)
- `implementation/roadmap/CURRENT.md` (append-only routing entry)
- `tools/governance-ci/check-diff-hygiene.sh` and `tools/governance-ci/check-pre-scaffold-scope.sh` (routed-capsule allowlist entries only, added because `run-all-checks.sh` failed without them)

## Forbidden Scope

- Any production `runiac-fypp` deploy without separate authorization.
- Any change to `getRunnerPublicProfile`'s authorization, target forms, or denial codes. That surface belongs to PR #39 and is out of scope here.
- Any `firestore.rules`, Firestore index, or `storage.rules` change. The defect needs none.
- Any backfill or mutation of existing `feedPosts` documents or their comments.
- Any change to publish-time behaviour in `functions/src/feed/contracts.ts` or `functions/src/feed/publish/core.ts`.
- Any new Cloud Function export. Both callables already exist and are already deployed.
- Any client-side computation of backend-owned values (level, XP, rank, streak, score).
- New dependencies or secrets.
- Repo-wide `dart format` (the local formatter is newer than CI's and reflows unrelated files); formatting stays scoped to the lines this capsule authored.

## Exact Target Files

Same list as Allowed Scope above.

## Required Tests

```bash
cd functions && npm run build
cd functions && npx tsc --noEmit -p tsconfig.json
cd functions && node --test lib/test/feedAuthorLevels.test.js lib/test/runnerPublicProfile.test.js
cd implementation/mobile/runiac_app && flutter analyze --no-pub
cd implementation/mobile/runiac_app && flutter test --no-pub
./tools/governance-ci/run-all-checks.sh
```

## Required Validation

- ADR-002 emulator-first validation before any deploy of `getFeedAuthorLevels`.
- A11_FIREBASE_IMPL for the widened callable result; A10_FLUTTER_IMPL for the display-only client wiring; A13_SECURITY_RULES to confirm no `firestore.rules` change was required, that `userProfiles/{uid}` stays owner-read-only, and that `getRunnerPublicProfile`'s authorization is unchanged from `origin/main`; A6_REVIEW for boundary/consistency; A12_QA_TEST for the analyze/test runs; A8_OUTPUT_CHECKER before any readiness claim.
- `./tools/governance-ci/run-all-checks.sh` and `git diff --check` must pass with only this capsule's files in the diff.

## Rollback Conditions

- Any evidence that an empty resolved identity blanks out a post's or comment's stored author name.
- Any evidence that `getFeedAuthorLevels` returns an identity for a uid the caller is not permitted to see.
- Any behavioural change to `getRunnerPublicProfile` relative to `origin/main`.
- Any `firestore.rules` or index change introduced under this capsule's name.
- Any modification to an unrelated capsule's files, or any reordering of an existing `CURRENT.md` routing bullet.

## Exit Criteria

- [x] Defect 1 implemented as recorded above.
- [x] Defect 2 resolved by PR #39 instead; this capsule's competing implementation dropped on rebase.
- [ ] Required tests passing after the rebase onto `origin/main` — recorded in the follow-up commit.
- [x] `implementation/roadmap/CURRENT.md` updated (append-only) with this capsule's routing bullet and its scope correction.
- [x] Governance allowlist entries added to `tools/governance-ci/check-diff-hygiene.sh` and `tools/governance-ci/check-pre-scaffold-scope.sh`.
- [ ] Production deploy — not authorized by this record.
- [ ] Real-screen QA of the renamed-nickname Feed — user-owned, not claimed here.

## Stop State

Stop at `Ready for commit`.
