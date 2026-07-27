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
- `functions/src/feed/authorLevels/core.ts`: `FeedAuthorLevel` widens from `ProfileLevelDisplay` to `ProfileLevelDisplay & ProfileIdentityDisplay`, so each permitted uid now returns `displayName` and `avatarInitials` alongside its level. The callable id stays `getFeedAuthorLevels` because it is already deployed and older app builds still call it; only the result grew. The 50-uid cap, the dedup, and the silent omission of unauthorized uids are unchanged.
- `functions/src/feed/authorLevels/core.ts`, **post-scoped grant** (added 2026-07-27 in response to a Codex review finding on PR #40): the request gains an optional second form, `{ postId, uids }`. `firestore.rules` authorizes a Feed comment through its POST — `canReadFeedPost` checks the post author, not the commenter — so two runners who share a friend but are not friends with each other still read each other's comments on that friend's post. The reciprocal-friendship-only check omitted exactly those commenters, so the overlay resolved nothing for them and **the rename defect survived on every comment by a non-friend**. The post-scoped form closes it, deliberately narrowly: the viewer must pass the same post-author check `canReadFeedPost` applies against a post that exists and is `published`; the uid must be proven server-side to have actually commented on that post; and a directional block still denies, which is *stricter* than the rules (they check blocks against the post author only). The grant returns the same three display fields the viewer can already read, frozen, on the comment document — current instead of stale — and never returns a uid the caller did not supply. The uid-only form is untouched, so older clients and the timeline path behave exactly as before.
- `functions/src/feed/authorLevels/callable.ts`: implements the two new optional ports — `readPost` over `feedPosts/{postId}`, and `commentAuthorsAmong` as at most two `where('authorUid','in', …)` equality queries (Firestore caps `in` at 30, the callable caps the request at 50) against the automatically indexed `authorUid` field. No composite index is added.
- `functions/src/profile/publicProfile/core.ts`: the projection's `displayName` / `avatarInitials` now resolve through `resolveProfileIdentityDisplay` instead of a private local copy of the same nickname-wins rule. Behaviour is identical; the duplicate helper is deleted. **No authorization change** — the target forms, the gate, the denial codes, and the constant-cost read ordering PR #39 established are all untouched.

### Client (display-only)

- `FeedAuthorLevel` (`feed_data_port.dart`) carries `displayName` / `avatarInitials`, defaulting to empty. `firebase_feed_data_port.dart` parses them defensively, so a backend deployment that predates this change simply omits them.
- `fetchAuthorLevels` / `FeedAuthorLevelResolver.ensureResolved` take an optional `postId`. `feed_comment_page_loader.dart` passes the post it is loading comments for; the timeline path passes nothing and its payload stays byte-identical, so a backend that predates the post-scoped form keeps answering it.
- `feed_timeline_page_loader.dart` and `feed_comment_page_loader.dart` overlay name, initials, and level **independently**: each field is replaced only when the backend resolved a non-empty value, and an empty resolved value never erases what the post or comment already stores. Combined with the resolver swallowing its own failures, the Feed still paints when the overlay resolves nothing at all.
- Rename propagation on the renamer's own device: `HomeTab.onAccountProfileChanged` fires when the Account screen closes, the shell re-reads the feed-author profile, and `CurrentSessionFeed` re-reads the timeline only when the viewer's name or initials actually changed (a level change alone is already applied in place and must not pay for a reload). Without this the fix would only be visible after a manual pull-to-refresh.

## Validation Evidence

Re-run on 2026-07-27 after the rebase onto `origin/main` (`8b5c097d`), against the reduced scope:

- `functions`: `npm run build` clean, `npx tsc --noEmit -p tsconfig.json` clean. `node --test lib/test/feedAuthorLevels.test.js lib/test/runnerPublicProfile.test.js` — 43/43 pass, including the seven post-scoped grant cases (non-friend commenter resolved, non-commenter omitted, block never relaxed in either direction, unreadable post omitted, draft and missing post omitted, no post read when every uid is already a friend, malformed `postId` rejected).
- Flutter: `flutter analyze --no-pub` clean ("No issues found!"). `flutter test --no-pub` — 2224/2224 pass.
- `./tools/governance-ci/run-all-checks.sh` — 11/11 PASS with this capsule routed. `git diff --check` clean.

The emulator integration run is **not** repeated here. `runnerPublicProfileEmulatorIntegration.test.ts` is `origin/main`'s file, unmodified by this capsule, and the authorization paths it exercises are unchanged; the only backend behaviour this capsule still alters is the shape of `getFeedAuthorLevels`' result, which its unit suite covers. ADR-002 emulator-first therefore applies to `getFeedAuthorLevels` only, and its existing suite passed.

The pre-rebase evidence this document originally carried (36/36 unit, 16/16 emulator, 2212/2212 Flutter, 11/11 governance) is superseded: it was measured against the two-defect implementation that no longer exists, including emulator cases for the `{runnerUid}` form that was dropped.

## Production Deploy Record

Supersedes the "NOT deployed" status this document carried when it was first written: the user explicitly authorized a scoped production deploy on 2026-07-27 Asia/Singapore, immediately after authorizing the commit, limited to `functions:getFeedAuthorLevels` and `functions:getRunnerPublicProfile`, and it was executed against `runiac-fypp`.

Both were **updates**, not creates — each function already existed in production, and this capsule adds no new export. No other function was deployed, and no rules, index, or storage rule was released.

| Function | Result |
| --- | --- |
| `getFeedAuthorLevels` | `ACTIVE`, v2 callable, `asia-southeast1`, `nodejs22`, `updateTime 2026-07-27T11:39:40Z` |
| `getRunnerPublicProfile` | `ACTIVE`, v2 callable, `asia-southeast1`, `nodejs22`, `updateTime 2026-07-27T11:39:38Z` |

Post-deploy behavioural verification against production was **not** performed: it needs a signed-in real account and a real device/simulator, and the account uses Google SSO. Real-screen acceptance stays user-owned and is not claimed by this record.

### Production drift introduced by that deploy — REDEPLOY REQUIRED

That deploy was executed from this branch **before** it was rebased onto `origin/main`, so what is live in `runiac-fypp` right now is the **pre-rebase** source, which no branch in this repository still contains:

- Live `getRunnerPublicProfile` is this capsule's dropped design: its one-key target form is `{ runnerUid }`, gated on an accepted mutual friendship. It **rejects `{ uid }` with `invalid-argument`**, because `parseTarget` matches the single-key form on that exact key.
- `origin/main` (PR #39) is the design that was kept, and its client sends `{ uid }`. **Every uid-addressed profile entry point on `main` therefore fails against production as deployed.**
- No user is affected yet only because the mobile release carrying PR #39's client has not shipped. The leaderboard-entry form (`snapshotId` + `rankLabel` + `buildId`) is unaffected in both designs and still works.

`getFeedAuthorLevels` now also diverges, for a different reason: the post-scoped grant added after the Codex review is **not deployed**. Production accepts only the one-key `{ uids }` payload, so a comment page sending `{ postId, uids }` is answered `invalid-argument`. This degrades safely — `FeedAuthorLevelResolver` swallows every failure and the comment falls back to its stored name — but it means the comment half of the rename fix does nothing until the redeploy. The timeline half still works, because that path deliberately keeps sending the uid-only payload.

**Required remediation, not authorized by this record:** after this branch merges, redeploy **both** `functions:getRunnerPublicProfile` and `functions:getFeedAuthorLevels` from `main`, before any mobile release ships. Until then production and `main` disagree about both callables' request contracts.

## Allowed Scope

- `functions/src/profile/profileIdentityDisplay.ts` (new)
- `functions/src/profile/publicProfile/core.ts` (identity-reader refactor only)
- `functions/src/feed/authorLevels/core.ts`
- `functions/src/feed/authorLevels/callable.ts`
- `functions/test/feedAuthorLevels.test.ts`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_author_level_resolver.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_test_data_port.dart`
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

- Any production `runiac-fypp` deploy beyond the two callables authorized and recorded above. The `getRunnerPublicProfile` redeploy the drift section calls for needs its own authorization.
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
- Any evidence that `getFeedAuthorLevels` returns an identity for a uid the caller is not permitted to see — in particular, any post-scoped grant that resolves a uid which did not comment on the named post, on a post the caller may not read, or across a block in either direction.
- Any evidence that the post-scoped form widens the uid-only form's reach, or that it returns a field the caller could not already read on the comment document.
- Any behavioural change to `getRunnerPublicProfile` relative to `origin/main`.
- Any `firestore.rules` or index change introduced under this capsule's name.
- Any modification to an unrelated capsule's files, or any reordering of an existing `CURRENT.md` routing bullet.

## Exit Criteria

- [x] Defect 1 implemented as recorded above.
- [x] Defect 2 resolved by PR #39 instead; this capsule's competing implementation dropped on rebase.
- [x] Required tests re-run after the rebase onto `origin/main` — recorded in the follow-up commit.
- [x] `implementation/roadmap/CURRENT.md` updated (append-only) with this capsule's routing bullet and its scope correction.
- [x] Governance allowlist entries added to `tools/governance-ci/check-diff-hygiene.sh` and `tools/governance-ci/check-pre-scaffold-scope.sh`.
- [x] Production deploy of the two callables — user-authorized on 2026-07-27, recorded above.
- [ ] Redeploy of `getRunnerPublicProfile` from `main` — required to clear the drift recorded above, not authorized here.
- [ ] Mobile app release — required before the identity fix is visible on a device, and must not ship before that redeploy.
- [ ] Real-screen QA of the renamed-nickname Feed — user-owned, not claimed here.

## Stop State

Rebased onto `origin/main` on 2026-07-27 with the profile-entry half dropped per the Scope Correction above. Stop at `Ready for commit`. No push, PR, redeploy, or mobile release is authorized by this task.
