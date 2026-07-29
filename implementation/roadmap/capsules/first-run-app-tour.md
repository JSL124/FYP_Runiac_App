# first-run-app-tour

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed **client-only** implementation. This capsule adds no Firestore collection, no Cloud Function, and no `firestore.rules`/`storage.rules`/index change, so it stays outside the ADR-003 Backend Guarded Lane; ADR-002 Emulator First does not apply because nothing here talks to a Firebase emulator or production project.

## Status

Routed on 2026-07-29 Asia/Singapore at the user's explicit request, in the isolated worktree `/Users/leejinseo/Desktop/FYP_Runiac-first-run-app-tour` on branch `feat/first-run-app-tour`. Not yet implemented at routing time.

## Goal

Give a brand-new runner a one-time, character-led walkthrough of the app shell immediately after onboarding: a dimmed screen with a spotlight cut around one target widget at a time, a short caption spoken by the runner character the user picked during onboarding, and a guided path across the Home, Feed, Leaderboard, and You tabs. The tour runs automatically once per account, can be skipped at any point, and can be replayed on demand from the Home hamburger menu.

## Contract Summary

- Tour "seen" state is a local, uid-scoped `shared_preferences` flag only (`AppTourSeenStore`). There is no Firestore document, no Cloud Function, and no cross-device sync: a reinstall or a second device sees the tour again, which is accepted behaviour for a cosmetic onboarding nicety, not a correctness-bearing entitlement.
- The tour is display-only. It reads the character the user already picked during onboarding (existing local/`userProfiles` state) to choose which character illustration/voice-over copy to show, but it does not read, derive, or write any XP, level, rank, streak, leaderboard score, weekly/monthly XP, subscription/entitlement, or expert-plan-publication value. Advancing or skipping the tour has zero effect on any backend-owned field.
- The tour is armed exactly once, right after onboarding completes (the existing `onOnboardingCompleted`/`_completeOnboarding` seam in `app.dart`), and consumed by `AppTourController` the first time the shell builds afterward. Replays triggered from the Home menu reuse the same controller/overlay path without re-touching the "seen" flag's automatic-run semantics.
- Tab navigation during the tour (Home to Feed to Leaderboard to You and back) is driven through a **private** seam inside `RuniacShell`, not a new public API. `RuniacShell` does not grow a public method, constructor callback, or exported controller that lets arbitrary calling code programmatically change the selected tab; the tour host lives inside the shell's own state and reuses the shell's existing private `_selectedIndex`/`_handleNavigationTap`-style mechanics.
- Spotlight targeting uses a small anchor registry (`TutorialAnchorRegistry`) that screens register a `GlobalKey`/`RenderBox` against by a stable string id (e.g. `home.startRunCard`, `feed.timeline`, `leaderboard.rankCard`, `you.plansSection`, `shell.bottomNav.you`). The overlay looks up the anchor's on-screen `Rect` per step and paints a scrim with a spotlight hole cut to that rect; a step whose anchor is not currently mounted (e.g. because the user scrolled it off-screen or it does not exist on a smaller device) degrades to a centered caption card with no spotlight hole rather than crashing or freezing the tour.
- The nine-step script, its English copy, and its per-step target tab/anchor id live in `AppTourSteps` as a plain, testable data table so the sequencing and copy can be asserted without pumping the full overlay widget tree.

## Allowed Scope

- New tutorial feature module under `implementation/mobile/runiac_app/lib/features/tutorial/`: step data model, the step script, the local seen-store port and its `shared_preferences` adapter, the anchor registry, the tour controller, the host widget that mounts the overlay above the shell content, the scrim/overlay widget, and the spotlight-cut custom painter.
- Modify `RuniacShell` (`lib/features/shell/runiac_shell.dart`) to add a private tab-selection seam the tour host can drive, wrap the tour scope/host around the shell body, and register the bottom-navigation anchors (the four tab items plus the hamburger menu button) with `TutorialAnchorRegistry`.
- Modify `lib/app.dart`, `lib/main.dart`, and `lib/core/firebase/runiac_firebase_bootstrap.dart` to construct/inject the `AppTourSeenStore` implementation through the existing composition root and to arm the tour at the existing onboarding-completion callback.
- Modify `home_stage_map.dart`, `home_stage_map_header.dart`, and `home_stage_map_menu.dart` to register the Home-tab anchors the script targets (e.g. Start Run card, header greeting) and to add a new, inert-until-tapped "App tour" row in the existing hamburger Menu dropdown that replays the tour.
- Modify `current_session_feed.dart` (Feed), `leaderboard_tab.dart` (Leaderboard), and `you_tab.dart` (You) to register the one or two anchors each screen's step(s) target.
- New focused widget/unit tests under `implementation/mobile/runiac_app/test/`: `app_tour_steps_test.dart`, `app_tour_seen_store_test.dart`, `app_tour_anchor_registry_test.dart`, `app_tour_overlay_test.dart`, `app_tour_flow_test.dart`, `app_tour_home_guide_sequencing_test.dart`, `app_tour_replay_test.dart`, `app_tour_fallback_test.dart`.
- This capsule document plus one append-only `CURRENT.md` routing line.

## Forbidden Scope

- No `firestore.rules`, `storage.rules`, `firestore.indexes.json`, or anything under `functions/**`. The tour has no server component.
- No change to `tools/governance-ci/**`, except the single user-authorized addition of this capsule's own predicate/path-allowlist pair (`is_first_run_app_tour_capsule_active`/`is_first_run_app_tour_path`) and its one-line dispatch wiring in `check-diff-hygiene.sh`, which allows exactly `implementation/roadmap/capsules/first-run-app-tour.md` and nothing else. Every other governance-CI change remains forbidden. If a governance check still fails only because a new file under this capsule's own scope (the tutorial Dart/test paths delivered by the concurrent implementation workers in this same worktree) is not yet present in `check-pre-scaffold-scope.sh` or elsewhere, that gap is reported, not patched from within this capsule — closing it is a separate, explicitly authorized governance-tooling change.
- No edit, file creation, staging, or commit inside the isolated `adaptive-character-guidance` worktree or capsule. That capsule remains active, unmodified, and not superseded by this routing.
- No client-side computation, caching, or write of XP, level, rank, streak, leaderboard score, weekly XP, monthly XP, subscription/entitlement state, or expert-plan publication state. The tour is presentation-only guidance over the existing shell; it must not gate, unlock, or influence any of those values in either direction, and it must not create a Premium-vs-Basic divergence in tour content or availability.
- No repo-wide `dart format`. Any formatting stays scoped to files this capsule's implementation workers actually touch.
- No new `pubspec.yaml`/`pubspec.lock` dependency. The tour ships with `Stack`/`CustomPainter`/`shared_preferences` (already a dependency) and nothing else.
- No public tab-navigation API added to `RuniacShell`. The tab-selection seam the tour host drives stays private to the shell's own state; no new exported method, constructor callback, or controller class lets external code programmatically switch tabs.
- No Firestore/Cloud Functions read or write of any kind, including read-only snapshot subscriptions; the tour's only state is the local `shared_preferences` seen-flag.
- No `git add`, `git commit`, or `git push` performed by this capsule's work.

## Exact Target Files

New:

- `implementation/mobile/runiac_app/lib/features/tutorial/domain/models/tutorial_step.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/domain/app_tour_steps.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/domain/app_tour_seen_store.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/data/shared_preferences_app_tour_seen_store.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/presentation/tutorial_anchor_registry.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/presentation/app_tour_controller.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/presentation/app_tour_host.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/presentation/app_tour_overlay.dart`
- `implementation/mobile/runiac_app/lib/features/tutorial/presentation/spotlight_scrim_painter.dart`

Modified:

- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/app.dart`
- `implementation/mobile/runiac_app/lib/main.dart`
- `implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map_header.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map_menu.dart`
- `implementation/mobile/runiac_app/lib/features/feed/presentation/current_session_feed.dart`
- `implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_tab.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`

New tests:

- `implementation/mobile/runiac_app/test/app_tour_steps_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_seen_store_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_anchor_registry_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_overlay_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_flow_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_home_guide_sequencing_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_replay_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_fallback_test.dart`

This capsule plus one append-only `CURRENT.md` routing line, plus this capsule's own governance-CI allowlist addition:

- `implementation/roadmap/capsules/first-run-app-tour.md` (this file)
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh` (additive predicate/path-allowlist pair scoped to allow exactly this capsule's own markdown path; no other line in that file is modified)

## Required Tests

- `app_tour_steps_test.dart` — the nine-step script is well-formed: every step names a valid target tab, a non-empty anchor id (or explicitly none, for a welcome/closing step), and non-empty English caption copy; step order is stable and deterministic.
- `app_tour_seen_store_test.dart` — the `shared_preferences` adapter is uid-scoped (two different uids do not share a "seen" flag), defaults to not-seen for a fresh uid, and marks/reads seen correctly across a fake-store round trip.
- `app_tour_anchor_registry_test.dart` — registering and unregistering an anchor id updates the registry; resolving an anchor id that was never registered (or was unregistered, e.g. after a screen disposes) returns a documented "not available" result rather than throwing.
- `app_tour_overlay_test.dart` — the overlay renders a scrim with a spotlight hole positioned at a registered anchor's `Rect`; Skip dismisses the tour immediately and marks it seen; the caption shown matches the current step's copy.
- `app_tour_flow_test.dart` — a full run from step one through the closing step advances through Home, Feed, Leaderboard, and You in the scripted order, switching the shell's selected tab at each tab transition, and marks the tour seen on completion.
- `app_tour_home_guide_sequencing_test.dart` — the tour does not fight with any existing Home first-run guide/animation (from the closed `home-stage-map-density-polish` capsule): the two do not show simultaneously, and one does not block the other from ever appearing.
- `app_tour_replay_test.dart` — tapping "App tour" in the Home hamburger Menu re-opens the tour from step one even when the local seen-flag is already true, and does not clear or corrupt the seen-flag's automatic-run semantics for that account.
- `app_tour_fallback_test.dart` — a step whose target anchor is not currently mounted degrades to a centered caption with no spotlight hole and the tour can still advance past it, instead of crashing, hanging, or skipping silently to the end.

## Required Validation

```bash
cd /Users/leejinseo/Desktop/FYP_Runiac-first-run-app-tour/implementation/mobile/runiac_app && flutter analyze --no-pub
cd /Users/leejinseo/Desktop/FYP_Runiac-first-run-app-tour/implementation/mobile/runiac_app && flutter test --no-pub test/app_tour_*.dart
cd /Users/leejinseo/Desktop/FYP_Runiac-first-run-app-tour && ./tools/governance-ci/run-all-checks.sh
```

Plus user-owned simulator screen QA on a fresh signup (iPhone 17 simulator): create a new account through onboarding, pick a runner character, confirm the tour opens automatically once onboarding closes, walk it across Home/Feed/Leaderboard/You, confirm Skip dismisses it at any point, confirm it does not reappear on the next app launch for the same account, and confirm "App tour" in the Home hamburger Menu replays it on demand.

## Required Evidence

- `flutter analyze --no-pub` clean output.
- Focused `flutter test --no-pub test/app_tour_*.dart` pass output (RED→GREEN if any test needed a fix cycle).
- `./tools/governance-ci/run-all-checks.sh` output, with an explicit note distinguishing any failure caused by this capsule's own markdown/routing from any failure caused by the concurrently-added tutorial Dart/test paths not yet appearing in a per-capsule governance-CI allowlist.
- A short note confirming the working tree's diff for this capsule's own contribution touches only the files listed under Exact Target Files, plus a statement of what unrelated concurrent changes (if any) were observed and left untouched.
- Simulator screen-QA notes (or screenshots) for the fresh-signup walkthrough described above, captured by the user, not fabricated.

## Rollback Conditions

- If arming the tour at onboarding completion is found to ever block, delay, or crash the transition into the shell (for example, a null character selection, or a `shared_preferences` failure), the tour must fail silently open — the user reaches the shell normally with no tour rather than being stuck — and the capsule's implementation must be revised before proceeding.
- If the private tab-selection seam cannot be added without exposing a public method/controller on `RuniacShell`, stop and re-route: a public seam is out of the Allowed Scope for this capsule as written.
- If satisfying a governance-CI check would require an edit under `tools/governance-ci/**`, stop and report the exact failing check rather than editing it under this capsule's authority.

## Exit Criteria

- [ ] All new tutorial domain/data/presentation files and all listed shell/Home/Feed/Leaderboard/You modifications are complete.
- [ ] The eight `test/app_tour_*.dart` files exist and pass.
- [ ] `flutter analyze --no-pub` is clean.
- [ ] `./tools/governance-ci/run-all-checks.sh` is run and its output is recorded, with any tutorial-path-only failure explicitly called out as expected pending a separate governance-tooling authorization.
- [ ] User-owned simulator screen QA on a fresh signup is recorded.
- [ ] Snapshot updated if state changed.
- [ ] `CURRENT.md` updated with this capsule's append-only routing line.
- [ ] Work stops at "Ready for user screen QA" and "Ready for manual commit" — no commit, no push, no deploy is performed by this capsule.
