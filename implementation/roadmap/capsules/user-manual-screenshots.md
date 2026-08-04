# User Manual and Prototype Screenshots

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested documentation capsule. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-04 Asia/Singapore. Documentation only. The deliverable was captured and
committed before this routing existed (`59b224c1`); this capsule records the scope
retrospectively and restores Governance CI, which rejected `docs/user-manual/**` as an
unrecognised path.

## Goal

Deliver a step-by-step User Manual for Runiac, modelled on the supplied SinBike sample, backed by
screenshots captured from the running prototype rather than from wireframes.

## Background

`docs/project-management/RUNIAC_PROJECT_PLAN.md:227,248` has carried an open requirement to
support the major functionalities with prototype screenshots. The only UI imagery in the
repository was the design wireframe set under `docs/pdd/wireframe-images/`, which shows intent
rather than the built product, and no user manual existed anywhere.

## Deliverable

`docs/user-manual/RUNIAC_USER_MANUAL.md` plus 145 screenshots sorted by audience:

| Folder | Audience |
|---|---|
| `00-download/` | Anyone — APK download and install |
| `01-unregistered/` | Public website, authentication, 16 onboarding steps, 12-step app tour |
| `02-registered-basic/` | Everyday use on a Basic account |
| `03-registered-premium/` | What Premium adds on top of Basic |
| `04-platform-administrator/` | All 13 admin console pages |

## Capture conditions

- Mobile screens: Flutter debug build on the iPhone 17 simulator against production Firebase.
- Basic screens on a Basic account; Premium screens on a Premium account with real run history.
- Leaderboard screens used the built-in `leaderboard_ranking` QA surface. Seeding the production
  leaderboard was rejected: `leaderboardSeedCleanupAuthorization.js:27` only authorises cleanup
  when another verified cohort exists to replace the one being deleted, so a seeded cohort could
  never be fully removed. Nothing was written to `runiac-fypp` for the leaderboard.
- Social screens (friends, requests, invitations, comments) used temporary mock records written
  through the Admin SDK under a `manualmock_` uid prefix and deleted afterwards from a manifest.
  Post-cleanup verification showed zero remaining mock documents.
- Admin console: local Firebase emulator with seeded demo data, so no real user's personal data
  appears in Part 5.
- PNGs are stored at half scale with a 256-colour palette, which took the folder from 95 MB to
  15 MB with no visible loss at document size.

## Temporary production changes, all reverted

Recorded because they touched a live account:

- One generated-plan session was re-labelled from Wed to Tue so the pre-run sheet would show a
  planned workout instead of "Rest day". `generatedPlans/{uid}` was backed up first and restored.
- The onboarding screens are only reachable through **Retake onboarding**, which resets the plan
  and consistency streak. `userProfiles`, `planProgress` and `users` were backed up and restored.
- A 10K challenge was created to capture the lobby and friend picker, then deleted. Starting it
  left an ACTIVE `challengeInstances` document with no matching `challengeSlots` entry, which
  broke the Challenge tab until the instance was removed — a defect worth noting.
- A feed post report was filed unintentionally while capturing the post-options sheet; the report
  document and the reporter's `hiddenFeedPosts` entry were deleted and the post returned to
  `published`.

## Allowed Scope

- `docs/user-manual/**`
- `implementation/roadmap/capsules/user-manual-screenshots.md`
- The routing predicate pair in `tools/governance-ci/check-diff-hygiene.sh`
- The routing anchor line in `implementation/roadmap/CURRENT.md`

## Forbidden

- Any Flutter, Firebase, Cloud Functions, rules, index or test source change.
- Any production deploy, secret action, or further production data mutation.
- Any edit to `docs/submissions/`, which stays the frozen submitted assessment snapshot.
- Any Phase 02 selection.

## Known limitations recorded in the manual

Appendix A of the manual states these rather than hiding them:

1. The live-run screen shows `0.00 km`. `local_run_tracking_session.dart:1203` discards location
   samples above `maxAcceptedHorizontalAccuracyMeters = 100`, and the simulator's synthetic fixes
   report accuracy in the 25–100 m band, so the timer runs and the map follows but no distance
   accrues. A distance-accumulating capture requires a physical device.
2. The cool-down screens are absent; they appear only immediately after a run is completed and
   saved, which would write a real activity to a live account.
3. The XP & Streak Update screen is absent; `you_tab.dart:499` passes `showXpUpdateAction: false`,
   so a summary opened from Activity History does not offer it.

Screens with no entry point in the current build — the Maps tab, Saved Routes, Shared Route
Detail, and the Expert Plan list and detail — are deliberately not documented.

## Defects observed during capture

Recorded for triage; none were fixed under this capsule.

- `/pricing` renders blank until the visitor scrolls. `PricingSection` gates its content on
  `useInView(..., { amount: 0.18, margin: "-8% 0px -12% 0px" })`, and on that route the section is
  taller than the viewport, so it never registers as in view at scroll-top.
- The Feed renders raw ISO timestamps (`2026-08-03T14:39:09.541Z`) instead of a friendly date.
- **Report** in the feed post-options sheet submits immediately, with no confirmation step and no
  in-app undo.
- Starting a challenge can leave the Challenge tab in an unrecoverable error state, with no way
  back from inside the app.

## Verification

- 145 image references, 145 files on disk, zero missing and zero orphaned.
- `git status --short` shows only `docs/user-manual/` plus this capsule and its routing.
- Production cleanup verified: zero `manualmock_` profiles, friends list back to its original
  single entry, no mock invitations, no challenge instances owned by the capture account.
