# profile-stats-visibility

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md`, as an explicitly user-routed Backend Guarded Lane full-stack capsule under ADR-002 Emulator First and ADR-003.

## Status

Routed on 2026-07-29 Asia/Singapore at the user's explicit request. Implemented and validated locally, then deployed to production `runiac-fypp` under a separate explicit user authorization on 2026-07-29 Asia/Singapore, scoped to exactly `functions:getRunnerPublicProfile` and `firestore:rules`.

## Goal

Give a runner one switch that stops other runners from seeing their running record, and move the Settings entry point off the Profile body into a header overflow menu.

Two user-visible changes:

1. `Settings` leaves the Profile screen's Manage list and becomes an item in the Home stage-map `Menu` dropdown, below Challenge. Every other Manage row stays where it is, and the Profile header is unchanged.
2. A new `Private profile` master switch in Settings hides the runner's level/XP progress, longest streak, total distance, and challenge badges from every other runner's view of their profile.

## Contract Summary

- `userProfiles/{uid}.publicStatsHidden` (boolean, absent means `false`) is the stored preference. It is a user-owned display preference, not a backend-owned scoring value: the owner writes it directly under `firestore.rules`, and no XP, level, rank, streak, leaderboard score, or entitlement value is derived from it in either direction.
- `getRunnerPublicProfile` is the single enforcement point. When the resolved target has `publicStatsHidden == true` **and the viewer is not the target**, the projection returns the hidden fields at their empty values (`levelProgressPercent: 0`, `totalXp`/`nextLevelXp`/`xpToNextLevel`: `null`, `isMaxLevel: false`, `longestStreakLabel`/`totalDistanceLabel`/`divisionKey`/`divisionLabel`: `""`, `ownedBadgeTierIds`: `[]`) and adds `statsHidden: true`.
- **The values are withheld, not masked.** The blur is a rendering of an already-empty card, never an overlay on real data the client received. A viewer who reads the raw callable response learns nothing the screen does not show. This is what distinguishes this feature from the Premium blur guards (`_PremiumCoachingGuard` and friends), which are cosmetic teasers over data the owner is entitled to hold.
- The badge read is skipped entirely when hidden, so a hidden profile costs one Firestore read less rather than reading and discarding.
- Identity stays public: display name, avatar, avatar initials, region label, `levelLabel`/`level`, and the Basic/Premium tier are unchanged by the switch. All of them already appear on `leaderboardSnapshots`, which every signed-in user can read, so hiding them here would suppress nothing.
- The switch never applies to the owner's own view. `AccountProfileScreen` reads the runner's own documents and is unaffected.
- The switch confers no competitive advantage and no entitlement. It is available to Basic and Premium alike, and hiding a record does not change how that record scores.

## Allowed Scope

- Modified: `functions/src/profile/publicProfile/core.ts` for the visibility gate and the `statsHidden` field.
- Modified tests: `functions/test/runnerPublicProfile.test.ts`, `functions/test/runnerPublicProfileEmulatorIntegration.test.ts`.
- Modified: `firestore.rules` only to add `publicStatsHidden` to `userProfileWritableKeys()` with a boolean validator.
- Flutter, under the approved scaffold prefix: the runner public profile read model and its Cloud Functions repository, `RunnerAchievementProfileScreen`, `AppSettingsScreen`, `AccountProfileScreen`, `account_profile_sections.dart`, the Manage row sources that carry the Settings entry, the Home stage-map menu (`home_stage_map_menu.dart`, `home_stage_map.dart`, `home_tab.dart`) for the new Settings item, a new profile-visibility repository, and the matching widget tests.
- This capsule plus one append-only CURRENT routing line and the minimal governance-CI allowlist entries for the `functions/**` paths above.

## Forbidden Scope

- No production `runiac-fypp` deploy beyond the authorization recorded under Status and Deployment: exactly `functions:getRunnerPublicProfile` and `firestore:rules`, and nothing else. A full-function deploy (`--only functions`) stays forbidden.
- No client-side computation or write of any backend-owned value. `publicStatsHidden` is a preference, and adding it must not open a path to writing XP, level, rank, streak, or leaderboard fields.
- No change that makes the blur the enforcement mechanism. If the client renders a blur over values the callable actually returned, the capsule has failed its contract.
- No change to XP/leaderboard formulas, the leaderboard snapshot projection, feed, friends, challenge, notification, or agent behaviour.
- No change to the block, suspension, or visibility-gate semantics already in `getRunnerPublicProfile`. The new gate composes with them and must not reorder or short-circuit them.
- No new dependencies, no secrets, and no edits inside the isolated `adaptive-character-guidance` worktree.

## Validation

Completed on 2026-07-29 Asia/Singapore.

- `functions`: `npm run build` clean. `runnerPublicProfile` + `runnerPublicProfileEmulatorIntegration` 55/55 pass on the emulator (`firebase emulators:exec --only auth,functions,firestore,storage --project runiac-functions-test`, JDK 21).
- New backend cases: a hidden runner's XP, streak, distance, max-level assertion, and badges are all absent from the returned object; the badge read is not performed at all (`badgeReadCalls` empty); the runner still sees their own record; and a non-boolean `publicStatsHidden` (`"true"`, `1`, `{}`, `[]`, `null`) reads as visible so a malformed write can never blank a profile.
- The emulator case asserts withholding against a document that genuinely holds the figures and two earned badge documents, not merely an empty one — it serialises the projection and checks the stored values do not appear anywhere in it.
- Flutter: `flutter analyze` clean; full `flutter test --no-pub` 2357/2357 pass.
- New Flutter cases: the Home Menu's Settings item appears only while the panel is open, fires its callback, and closes the panel (and is inert rather than throwing when no handler is wired); `Settings` appears nowhere in the Profile body or the Manage list; the visibility switch loads, persists, reverts on a rejected save, and reads as unavailable rather than as "off" when unreachable; the blur guard renders for `statsHidden` and no leaderboard-row placeholder stands in behind it.
- `test/backend_owned_contract_test.dart` gained the new Firestore adapter to its approved-path allowlist plus a per-file constraint test pinning it to `userProfiles`/`publicStatsHidden` and forbidding every backend-owned field, matching how the other approved adapters are constrained.
- `./tools/governance-ci/run-all-checks.sh` PASS (all nine checks).
- Simulator (iPhone 17, iOS 26.5) against the local emulator suite on `demo-runiac-feed`: the Home Menu renders the new Settings item. The `getRunnerPublicProfile` callable, invoked over HTTP against the Functions emulator with a real ID token, returned the seeded private runner with `statsHidden: true` and empty `longestStreakLabel`/`totalDistanceLabel`/`totalXp`/`ownedBadgeTierIds`, and the seeded public runner with all of them populated.
- Not captured on-device: the blurred runner-profile screen itself. Both in-app routes to it need emulator fixtures outside this capsule — the `searchFriends` callable errored in the local suite, and the leaderboard read chain would not hydrate from hand-seeded `leaderboardPeriods`/`leaderboardCurrentViews`/`leaderboardSnapshots` documents. The blur is covered by widget tests; an on-device capture needs either a correct leaderboard fixture or a deploy.
- Diff hygiene: the working tree contains only Allowed Scope paths.

Not covered: `tests/firebase-rules/firestore.rules.test.mjs` has no case for the new writable key. The generic `changesOnlyAllowedKeys` / `doesNotChangeBackendOwnedKeys` gates already cover the smuggling risk, and that file is outside this capsule's allowlist; add it under a follow-up routing if owner-vs-non-owner write coverage is wanted explicitly.

## Deployment

Deployed to production `runiac-fypp` on 2026-07-29 Asia/Singapore under explicit user authorization, scoped to `functions:getRunnerPublicProfile` and `firestore:rules`.

Pre-deploy safety check: the live ruleset (`createTime 2026-07-28T12:28:05Z`) was fetched from the Firebase Rules API and diffed against the working tree before deploying, because `firebase deploy --only firestore:rules` replaces the whole file and would carry any committed-but-undeployed rules change with it. The only difference was this capsule's 18 added lines.

Post-deploy verification:

- `firestore:rules` — the new live ruleset (`createTime 2026-07-29T09:37:17Z`) was re-fetched and is byte-identical to the repository's `firestore.rules`.
- `functions:getRunnerPublicProfile` — `asia-southeast1`, `updateTime 2026-07-29T09:38:46Z`, state `ACTIVE`.

The change is backward compatible: `statsHidden` is an added field that older shipped clients ignore, and `publicStatsHidden` is a new writable key no shipped client writes yet. The mobile release that surfaces the Settings switch and the blur guard is still outstanding.
