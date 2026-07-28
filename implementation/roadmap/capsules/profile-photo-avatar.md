# Profile Photo Avatars

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Mode / Type

Mode: implementation-approved. The user explicitly routed this capsule on 2026-07-28 Asia/Singapore to let runners pick a photo from their phone gallery in Edit Profile and have it render inside the existing initials disc, on their own screens and on every other surface where other users see them, including leaderboard rows.

Type: Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003) spanning Cloud Functions, `firestore.rules`, a first-ever `storage.rules` deploy, Flutter client, and the separate `website/` admin console (git-ignored, not gated by this repo's CI).

## Status

Status: Routed, not yet implemented. Stage 1 (this document plus the governance-CI gate it opens) is in progress.

Routed on: 2026-07-28 Asia/Singapore.

Plan of record: `/Users/leejinseo/.claude/plans/profile-glowing-bumblebee.md` (Revision 2) and this capsule. Executed as an orchestrator/worker split: Opus architects, decomposes, and reviews every diff; Sonnet workers implement one stage at a time per `<sonnet_task_assignment>`. Work happens on `feat/profile-photo-avatars`, branched off `main`.

Note for the record: the working tree already carries one unrelated untracked file, `implementation/mobile/runiac_app/test/plan_completion_after_xp_update_qa_test.dart`. It is not part of this capsule and must never be staged as part of this capsule's work.

## Goal

Make every avatar surface in Runiac show the runner's own uploaded photo instead of only the two-letter initials disc, server-mediated end to end (upload, storage, serving URL, and every read-time fan-in), with no client-side computation of any backend-owned value and with the security, privacy, and moderation trade-offs of a first-ever public unauthenticated image asset explicitly recorded and accepted below.

## Context

Today every avatar in Runiac is a two-letter initials disc. `avatarInitials` is a backend-owned field on `userProfiles/{uid}`, derived server-side from the nickname and fanned out to friend edge documents, feed author fields, and the runner public profile callable. Serving is a Firebase Storage download-token URL stored as `avatarUrl` and rendered with `Image.network` — not a base64 callable relay, which would fire a Cloud Function per avatar per list row. Scope is every surface, including leaderboard rows. Moderation is admin-console-only via the Admin SDK, in the style of the existing `setUserXp` action; no new `moderationCommands` kind is introduced.

Key mechanics fixed by the plan of record (do not re-derive or re-open in a later stage without returning to Opus):

- The served object path never contains the uid. Clients upload only to `avatar-staging/{uid}/{uploadId}.png`; a Function promotes to `avatars/{opaqueId}.png` where `opaqueId` is a server-generated 32-char lowercase-hex id. `avatars/**` is `read, write: if false` for clients — the download token is the only read gate.
- One previous generation is always kept (`avatarObjectPath` + `avatarPreviousObjectPath` on `userProfiles/{uid}`, both backend-owned) so a path rotation on replace never produces an immediate dead URL in the up-to-hourly `leaderboardSnapshots` refresh.
- `Cache-Control: public, max-age=3600`, never `immutable` — this is a cost lever only, because Flutter's `Image.network`/`NetworkImage` ignores HTTP `Cache-Control` entirely (in-memory `ImageCache` only).
- The object-path parser is a strict full-string match on `^avatars/[0-9a-f]{32}\.png$`, hand-mirrored (never imported) between `functions/` and `website/`, with a text-level drift check in `tests/cross-system/`, matching the existing `functions`/`website` independence rule.
- Structural URL validation (scheme, host, path, runtime-resolved bucket, `alt=media` + UUIDv4 token, emulator gated on `FIREBASE_STORAGE_EMULATOR_HOST`) is shared by the builder and both validators (Functions + a Dart mirror) — never a `startsWith` check.
- PNG validation reuses the existing strict allow-list parser at `functions/src/feed/png.ts`, parameterized for a 256×256 dimension instead of generalized into a second parser.
- Every existing avatar-adjacent read surface (own profile, feed post/comment authors, Friends/Requests/Blocked via `FriendLevel`, runner public profile, leaderboard top/nearby/current, and the challenge lobby roster **and** challenge progress screen) gets the field; the Blocked tab and settled-challenge rosters are explicitly excluded per the plan's existing visibility rules.

## User Approvals Recorded

- Add the `image_picker` dependency to `implementation/mobile/runiac_app/pubspec.yaml` (otherwise forbidden by `implementation/AGENTS.md`).
- Add `NSPhotoLibraryUsageDescription` to `implementation/mobile/runiac_app/ios/Runner/Info.plist` (otherwise forbidden native configuration).
- Regenerated native artifacts `implementation/mobile/runiac_app/ios/Podfile.lock` and `implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj` are pre-authorized churn once `image_picker` is added and the project is next opened/built in Xcode — mirroring how the `legal-documents-and-links` capsule pre-authorized the same churn for `url_launcher`.
- The first-ever `storage:rules` production deploy. `storage.rules` has never been deployed to `runiac-fypp`. Because the file also carries never-deployed rule blocks for `feed-thumbnail-staging`, `feed-thumbnails`, `share-cards`, and `project-documents` (added by earlier, still-undeployed capsules), the first `--only storage:rules` publish will release all of those blocks simultaneously with the new `avatar-staging/{uid}/*` and `avatars/{fileName}` blocks this capsule adds. This is accepted as a deliberate, explicitly-gated deploy step (Stage 11 of the plan of record), never an incidental side effect of an unrelated deploy.
- The first-ever use of Cloud Storage object `cacheControl` metadata in this repository (`public, max-age=3600` on promoted `avatars/{id}.png` objects). There is no `cacheControl`/`setMetadata`/`makePublic` precedent anywhere in `functions/` or `website/` today.

## Accepted Disclosures

These are accepted, in-scope risk trade-offs of shipping a public, unauthenticated, network-served user photo. They must be stated in-app (the pre-upload confirmation flow in Stage 8) and are recorded here so no later stage re-litigates them as unforeseen defects:

1. **A `firebaseStorageDownloadTokens` URL is a bearer capability.** Anyone holding the forwarded link fetches the bytes with no auth, no Firestore/Storage rules check, and no App Check. Publishing it via the world-readable `leaderboardSnapshots` collection (`allow read: if isSignedIn()`) makes the avatar a public, unauthenticated internet asset — readable by users the owner has blocked, since `leaderboardSnapshots` carries no uid and cannot apply a block-aware filter the way `getRunnerPublicProfile` does.
2. **Takedown is not instantaneous.** Deletion is immediate at origin (the Storage object and the Firestore fields), but it does not revoke: intermediary/browser/CDN copies for up to `max-age` (1 hour); devices that already rendered the photo, which keep an in-memory `ImageCache` copy until app restart; or the dead URL sitting in the last `leaderboardSnapshots` refresh, until the next hourly cycle.
3. **The opaque avatar id is a cross-surface correlator.** String-matching `avatarUrl` between a leaderboard row and a known feed author reveals that runner's rank and region, even though neither surface echoes a uid.
4. **There is no automated content moderation.** The strict PNG byte validator (parameterized from `functions/src/feed/png.ts`) rejects malformed or non-conforming files and strips EXIF/GPS by construction, but it cannot judge nudity, someone else's face, or hateful imagery. Takedown is admin-console-only, via the Admin SDK, mirroring `setUserXp`.
5. **Abandoned `avatar-staging` objects accumulate forever.** This inherits an existing repo-wide gap: `feed-thumbnail-staging` has no cleanup sweep either, and there is no bucket lifecycle rule anywhere in this repo today. A GCS age-based lifecycle rule covering both staging prefixes is explicitly out of scope for this capsule and is optional future follow-up.

## Allowed Scope

Governance (this stage):

- This capsule document; the `CURRENT.md` routing bullet; the `snapshots/latest.md` routing record; the `is_profile_photo_avatar_*` registrations in `tools/governance-ci/check-diff-hygiene.sh` and `tools/governance-ci/check-pre-scaffold-scope.sh`.

Server (`functions/`), later stages:

- Generalizing `functions/src/feed/png.ts` to accept a parameterized dimension/size-limit, with the existing feed thumbnail behavior unchanged.
- A new `functions/src/profile/avatar/` module: the object-path parser/minter/URL builder, `resolveProfileAvatarUrl`, the `setProfileAvatar`/`clearProfileAvatar` callables, and their Admin-SDK adapter.
- `avatarUrl` fan-in on `RunnerPublicProfile` (`functions/src/profile/publicProfile/core.ts`), `FriendLevel` (`functions/src/friends/friendLevels/core.ts`), the challenge lobby roster payload (`functions/src/challenge/challengeLobbyCore.ts`, `challengeLobbySupport.ts`), and `LeaderboardPublicEntry` (`functions/src/leaderboard/leaderboardTypes.ts`, `monthlyLeaderboardPlanner.ts`, `monthlyLeaderboardWriter.ts`), all resolved through the shared `ProfileAvatarDisplay`/`resolveProfileAvatarUrl` seam in `functions/src/profile/profileIdentityDisplay.ts`.
- `avatar-staging/{uid}/*` and `avatars/{fileName}` blocks in `storage.rules`; the four new backend-owned `userProfiles/{uid}` keys (`avatarUrl`, `avatarObjectPath`, `avatarPreviousObjectPath`, `avatarUpdatedAt`) added to `backendOwnedKeys()` in `firestore.rules`.
- New cross-system drift check `tests/cross-system/avatar-path-contract-drift.mjs`, registered in the governance runner alongside the existing cross-system checks (`tests/governance/config_contract_drift_test.sh` is the precedent shape).

Client (`implementation/mobile/runiac_app/`), later stages:

- The `image_picker` dependency and the iOS `NSPhotoLibraryUsageDescription` entry (both pre-authorized above).
- New `lib/core/widgets/runiac_avatar_photo.dart` (Dart mirror of the URL validator, `@visibleForTesting` provider factory) wired into `RuniacLevelProfileBadge`/`_ProfileInitialsDisc` (`lib/core/widgets/runiac_level_profile_badge.dart`) and into `ChallengeInitialsAvatar` (`lib/features/challenge/presentation/widgets/challenge_widgets.dart`), or a swap of that screen to the shared disc.
- New `lib/features/profile/data/avatar/avatar_image_encoder.dart` and `.../firebase_avatar_upload_gateway.dart`; the tappable-avatar pick/confirm/upload flow in `account_edit_profile_screen.dart`; the Back-after-photo refresh-contract fix in `account_profile_screen.dart`, `home_tab.dart`, and `runiac_shell.dart`.
- Plumbing `avatarUrl` through every existing `avatarInitials` read site listed in Exact Target Files below (profile, feed, friends, challenge, runner public profile, leaderboard).

Admin console (`website/`, separate repository, not gated by this repo's CI):

- `clearUserAvatar(uid, reason)` in `website/src/lib/actions/admin.ts`; a dedicated `deleteAvatarObject` helper in `website/src/lib/firebase/storage.ts` (never `deleteProjectDocumentFile`); the mirrored path parser in `website/src/lib/avatarPaths.ts`; the control surface in `website/src/app/admin/users/page.tsx`; wiring the same takedown routine into the existing suspend/moderate actions.

## Forbidden Scope

- Any production `runiac-fypp` deploy without separate, explicit authorization — including the gated first-ever `storage:rules` deploy itself, which requires its own live-rules diff step (see Required Validation) before it may proceed, even though it is pre-authorized in principle above.
- A base64/callable-relay serving path, a second PNG parser, a `cached_network_image` dependency, a `CircularProgressIndicator` in the loading state of the profile badge, a scheduled grace-delete sweep, or a GCS bucket lifecycle rule — all explicitly rejected or deferred by the plan of record.
- A new `moderationCommands` kind for avatar takedown; takedown stays inside the existing `setUserXp`-style Admin SDK action shape.
- `functions/` and `website/` importing from each other for the avatar-path contract; the parser must stay hand-mirrored with a text-level drift check, per the existing `tests/cross-system/config-contract-drift.mjs:14-17` rule.
- Routing avatar deletes through `deleteProjectDocumentFile`; it accepts an arbitrary path via the Admin SDK and bypasses Storage rules, which is unsafe for a bucket that also holds `feed-thumbnails`/`share-cards`/`project-documents`.
- Naming the served object after the uid, or echoing a resolved uid back on any avatar-adjacent read path.
- Any XP, level, rank, streak, or leaderboard-score formula change; the avatar is presentation-only.
- Any change to `config/paywall`, subscription/entitlement logic, or premium-vs-basic avatar behavior; avatars are available identically to Basic and Premium users.
- Editing or staging inside the isolated `adaptive-character-guidance` worktree, or staging the pre-existing unrelated untracked file `implementation/mobile/runiac_app/test/plan_completion_after_xp_update_qa_test.dart`.
- New dependencies beyond `image_picker`, and no secrets.

## Exact Target Files

New:

- `implementation/roadmap/capsules/profile-photo-avatar.md`
- `functions/src/profile/avatar/avatarPaths.ts`
- `functions/src/profile/avatar/core.ts`
- `functions/src/profile/avatar/callable.ts`
- `functions/test/avatarPng.test.ts`
- `functions/test/profileAvatar.test.ts`
- `tests/cross-system/avatar-path-contract-drift.mjs`
- `tests/firebase-rules/avatar.storage.rules.test.mjs`
- `website/src/lib/avatarPaths.ts`
- `implementation/mobile/runiac_app/lib/core/widgets/runiac_avatar_photo.dart`
- `implementation/mobile/runiac_app/lib/features/profile/data/avatar/avatar_image_encoder.dart`
- `implementation/mobile/runiac_app/lib/features/profile/data/avatar/firebase_avatar_upload_gateway.dart`

Modified:

- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `tools/governance-ci/check-diff-hygiene.sh`
- `tools/governance-ci/check-pre-scaffold-scope.sh`
- `functions/src/feed/png.ts`
- `functions/src/index.ts`
- `functions/package.json`
- `firestore.rules`
- `storage.rules`
- `functions/src/profile/profileIdentityDisplay.ts`
- `functions/src/profile/publicProfile/core.ts`
- `functions/src/friends/friendLevels/core.ts`
- `functions/src/challenge/challengeLobbyCore.ts`
- `functions/src/challenge/challengeLobbySupport.ts`
- `functions/src/leaderboard/leaderboardTypes.ts`
- `functions/src/leaderboard/monthlyLeaderboardPlanner.ts`
- `functions/src/leaderboard/monthlyLeaderboardWriter.ts`
- `functions/test/runnerPublicProfile.test.ts`
- `functions/test/feedAuthorLevels.test.ts`
- `functions/test/friendLevels.test.ts`
- `functions/test/challengeLobby.test.ts`
- `functions/test/monthlyLeaderboard.test.ts`
- `functions/test/monthlyLeaderboardWriter.test.ts`
- `tests/firebase-rules/package.json`
- `implementation/mobile/runiac_app/pubspec.yaml`
- `implementation/mobile/runiac_app/ios/Runner/Info.plist`
- `implementation/mobile/runiac_app/lib/core/widgets/runiac_level_profile_badge.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/presentation/widgets/challenge_widgets.dart`
- `implementation/mobile/runiac_app/test/runiac_level_profile_badge_test.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/account_edit_profile_screen.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/account_profile_screen.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/profile/domain/models/user_profile_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/profile/data/firestore_user_profile_repository.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/data/account_profile_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/widgets/account_profile_identity.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/widgets/home_header.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map_header.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_data_port.dart`
- `implementation/mobile/runiac_app/lib/features/feed/domain/models/feed_display_models.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/widgets/feed_post_section.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/comments/feed_comment_list.dart`
- `implementation/mobile/runiac_app/lib/features/friends/data/friend_level_resolver.dart`
- `implementation/mobile/runiac_app/lib/features/friends/domain/models/friends_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/friends/presentation/widgets/friend_row_identity.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/data/firebase_challenge_repository.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_lobby_screen.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_progress_screen.dart`
- `implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_friend_picker_screen.dart`
- `implementation/mobile/runiac_app/lib/features/profile/domain/models/runner_public_profile_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/profile/data/cloud_functions_runner_public_profile_repository.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/runner_achievement_profile_screen.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/domain/models/leaderboard_read_model.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/data/firestore_leaderboard_repository.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_read_model_display_adapter.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/leaderboard_rank_row_helpers.dart`
- `implementation/mobile/runiac_app/test/home_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/friends_static_ui_test.dart`
- `implementation/mobile/runiac_app/test/account_profile_read_flow_test.dart`
- `implementation/mobile/runiac_app/test/challenge_lobby_ui_test.dart`
- `implementation/mobile/runiac_app/test/feed_comments_bottom_sheet_test.dart`
- `website/src/lib/actions/admin.ts`
- `website/src/lib/firebase/storage.ts`
- `website/src/app/admin/users/page.tsx`

Possible regenerated native artifacts (pre-authorized above): `implementation/mobile/runiac_app/ios/Podfile.lock` and `implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj`.

## Required Tests

- `functions/test/avatarPng.test.ts` — accepts a real 256×256 RGBA8 PNG and rejects 255×255, 512×512, bit depth 16, colour type 2, a `tEXt` chunk, a corrupted CRC, and bytes appended after `IEND`.
- `functions/test/profileAvatar.test.ts` plus a Storage-emulator integration test — foreign-uid staging path rejected; wrong metadata rejected; bad PNG rejected; suspended account rejected; cooldown enforced; replace deletes only the previous-previous generation; a poisoned `avatarObjectPath` clears fields without deleting the object; commit failure leaves the old object intact; interleaved replace/clear converges without deleting a live object; retry is idempotent.
- `tests/cross-system/avatar-path-contract-drift.mjs` — builder/validator round-trip; rejection of `project-documents/x.pdf`, `feed-thumbnails/...`, a leading slash, `..`, a non-hex id, a wrong extension, a foreign host, a missing `alt=media`, and an emulator URL when the emulator env is unset.
- `tests/firebase-rules/avatar.storage.rules.test.mjs` — the new `avatar-staging/{uid}/*` and `avatars/{fileName}` rule blocks.
- Extensions to `functions/test/runnerPublicProfile.test.ts`, `functions/test/feedAuthorLevels.test.ts`, `functions/test/friendLevels.test.ts`, `functions/test/challengeLobby.test.ts`, `functions/test/monthlyLeaderboard.test.ts`, `functions/test/monthlyLeaderboardWriter.test.ts` — each asserting a non-Storage URL in `userProfiles` resolves to `""`, and (leaderboard) that an absent owner or a rejected prefix yields `""`.
- `implementation/mobile/runiac_app/test/runiac_level_profile_badge_test.dart` — all four existing ring assertions untouched, plus photo-present, error-fallback, and a `paintsExactlyCountTimes(#drawArc, 1)` case with a photo.
- Full `flutter test --no-pub` regression across `home_static_ui_test`, `friends_static_ui_test`, `account_profile_read_flow_test`, `challenge_lobby_ui_test`, `feed_comments_bottom_sheet_test`, plus a new widget test proving Back-after-photo refreshes the Account screen.

## Required Validation

- `cd functions && npm run build && npm test`
- `cd tests/firebase-rules && npm test`
- `node tests/cross-system/avatar-path-contract-drift.mjs`
- `cd implementation/mobile/runiac_app && flutter analyze --no-pub && flutter test --no-pub`
- `cd website && npx tsc --noEmit && npm run lint && npm run build`
- `./tools/governance-ci/run-all-checks.sh` PASS
- `dart format`, scoped to changed files only — never repo-wide
- A6_REVIEW, A11_FIREBASE_IMPL, A13_SECURITY_RULES, A12_QA_TEST, A8_OUTPUT_CHECKER
- Before the gated first-ever `storage:rules` deploy: read the live production Storage rules and diff them against `storage.rules`, because the file also carries the never-deployed `feed-thumbnail-staging`, `feed-thumbnails`, `share-cards`, and `project-documents` blocks — treat that diff as its own explicit gate, separate from this capsule's implementation validation.

## Required Evidence

- Command output for every item in Required Validation.
- Simulator QA (iPhone 17 Pro simulator, per this environment's known iOS-26-physical-device-attach constraint): Edit Profile -> tap avatar -> confirmation -> Choose photo -> disc updates on Home header, Account, and stage-map header, and pressing Back (not Save) refreshes the Account screen.
- Real-device QA with a HEIC photo, to settle the `image_picker` -> `instantiateImageCodec` decode path (`ui.instantiateImageCodec` cannot decode HEIC directly; the `image_picker` `maxWidth`/`maxHeight`/`imageQuality` params must force the iOS plugin's `UIImage` re-encode).
- Cross-account emulator QA: a second runner sees the photo on the feed post, friends row, runner public profile, challenge lobby and challenge progress, and (after a manual `refreshLeaderboardSnapshots`) the leaderboard row.
- Takedown QA: clear from the admin console, then verify a screen already showing the photo, a re-entered screen, a different account, and a previously forwarded URL all behave per the Accepted Disclosures above (not "immediate").

## Rollback Conditions

- `./tools/governance-ci/run-all-checks.sh` cannot be brought back to PASS after these five files are in place.
- `tests/governance/backend_functions_scope_test.sh` leaves `implementation/roadmap/CURRENT.md` modified after `run-all-checks.sh` completes (it rewrites the file in place and restores it on EXIT; a leftover modification means something went wrong and must be reported, not hand-fixed).
- A later stage discovers the object-path contract, the cache-control decision, or the "keep one previous generation" design needs to change — that is a design change and returns to Opus, not a Sonnet-worker fix.
- The first-ever `storage:rules` deploy step is reached without the live-rules diff having been performed.

## Production Deploy Record (runiac-fypp, 2026-07-28 Asia/Singapore)

Explicitly authorized by the user. Executed:

```
firebase deploy --project runiac-fypp --only \
  functions:setProfileAvatar,functions:clearProfileAvatar,\
  functions:getRunnerPublicProfile,functions:getFriendLevels,\
  functions:getFeedAuthorLevels,functions:getActiveChallenge,\
  functions:refreshLeaderboardSnapshots,functions:leaderboardAdminCommandCreated,\
  firestore:rules,storage
```

- `setProfileAvatar` and `clearProfileAvatar` were **creates**; both verified in production as v2 callable, `asia-southeast1`, `nodejs22`, 256 MB. The other six were updates.
- Rulesets verified against production: `cloud.firestore` `897c99a1` -> `a8b8fb66`; `firebase.storage` `15fdb3aa` -> `e4bacea6`; both `updateTime 2026-07-28T12:28Z`.
- **The pre-deploy live-rules gate corrected this capsule's own premise.** `storage.rules` had NOT never been deployed: a live `firebase.storage` release already existed (ruleset `15fdb3aa`, `createTime 2026-07-27T09:01:52Z`, bucket `runiac-fypp.firebasestorage.app`) whose `feed-thumbnail-staging`, `feed-thumbnails`, `share-cards`, and `project-documents` blocks were already byte-identical to the local file. The only delta published was the two new avatar blocks. The `firestore.rules` delta was only the four new `backendOwnedKeys()` entries. The feared simultaneous publication of never-deployed prefixes did not occur.
- **CLI note:** the Storage rules deploy target is `--only storage`, not `--only storage:rules`. The latter is parsed as a named multi-bucket target and aborts with `Could not find rules for the following storage targets: rules` before deploying anything.
- Deployed from the uncommitted working tree on branch `feat/profile-photo-avatars`; this record carries **no commit hash**. A commit must be created and referenced here before this capsule is closed.
- Not live: the mobile app release (so every surface still renders initials in production), and the `website/` admin-console takedown + suspension wiring, which ships through its own repository. Until the console ships there is no production takedown path for an uploaded photo.
- `setProfileAvatar`/`clearProfileAvatar` enforce App Check in production, so a debug build used for device QA must have its App Check debug token registered in the Firebase Console or both callables fail.

## Exit Criteria

- [ ] Target files completed.
- [ ] Required tests or validation completed.
- [ ] Required evidence recorded.
- [ ] Snapshot updated if state changed.
- [ ] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
