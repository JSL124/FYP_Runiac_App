# Capsule: Android Native Haptics

Status: implemented and committed as `12e72f0a` on branch
`feat/android-native-haptics`, pushed, and open as PR #52 against `main`. NOT
merged, NOT released, and NOT verified on a physical Android device.
Real-device QA is the one piece of evidence this capsule cannot produce from
the host; it remains user-owned and is the only thing standing between this
capsule and its exit criteria.
Routed: 2026-07-31 Asia/Singapore (explicit user request, option A of the
triage below).
Lane: Mobile Client Lane. Client-only. No Firebase, no Cloud Function, no
Firestore rule, no dependency, no XP/level/rank/streak/leaderboard surface.

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Goal

Make Runiac's haptics actually felt on Android hardware.

A runner reported feeling no vibration at all on a physical Android device. The
Dart wiring is not at fault and was cleared first: `RuniacHapticsScope` is
mounted above `MaterialApp` in `lib/app.dart`, so no call site resolves to
`null`; `AppSettings.defaults.hapticFeedbackEnabled` is `true`; and
`_restoreHapticsSetting()` reads the same `shared_preferences` key
`SharedPreferencesAppSettingsRepository` writes.

The cause is the platform mapping. `SystemRuniacHaptics` called Flutter's
`HapticFeedback`, which on Android the engine implements in
`PlatformPlugin.vibrateHapticFeedback` as `View.performHapticFeedback` with
touch-tick constants:

| App API | Call sites | Android constant | iOS |
| --- | --- | --- | --- |
| `selection()` | 6 | `CLOCK_TICK` | `UISelectionFeedbackGenerator` |
| `impactLight()` | 5 | `VIRTUAL_KEY` | `UIImpactFeedbackGenerator(light)` |
| `impactMedium()` | 4 | `KEYBOARD_TAP` | `UIImpactFeedbackGenerator(medium)` |
| `impactHeavy()` | 3 | `CONTEXT_CLICK` | `UIImpactFeedbackGenerator(heavy)` |
| `error()` | 11 | `LONG_PRESS` | vibrate |

Those four constants are the class of effect the software keyboard uses: faint
on an LRA device and frequently a no-op on rotational (ERM) motors, with
`CLOCK_TICK` commonly unimplemented on Samsung hardware. Only `error()` mapped
onto `LONG_PRESS`, which is reliably felt. So 18 of the 29 call sites — every
one a runner actually notices: bottom-tab switches (`runiac_shell.dart:507`),
the Home stage-map menu, feed likes and comments, the app tour, run
start/finish, the plan-completion ceremony — produced nothing perceptible,
while the error buzz worked. That asymmetry is the diagnostic signature and is
also the fastest on-device confirmation: deliberately fail a profile save and
feel the error haptic, then switch tabs and feel nothing.

## Design decisions (user-confirmed 2026-07-31)

- **Option A: a native channel, not a package and not a level promotion.** Two
  alternatives were presented and declined. Promoting `selection`/`light` to
  `HapticFeedback.vibrate()` on Android would need no native code but collapses
  all five levels onto one buzz. Adding a `vibration`-style package would pull
  a dependency for behaviour that is roughly 200 lines of Kotlin. A channel
  keeps per-level strength and adds nothing to `pubspec.yaml`.
- **Android only.** iOS keeps the framework path unchanged, where the levels
  already map onto the distinct `UIFeedbackGenerator` classes. The branch is
  `defaultTargetPlatform == TargetPlatform.android`, read per call so a test
  can flip `debugDefaultTargetPlatformOverride`, rather than `Platform.isAndroid`
  which no test can override.
- **The system touch-feedback setting is respected, not bypassed.** Effects are
  tagged `VibrationAttributes.USAGE_TOUCH` (API 33+) or the equivalent
  sonification `AudioAttributes` below that, so a runner who has turned off
  touch feedback in Android settings still gets silence. Tagging the effects
  under another usage would bypass that toggle and was rejected: it fights a
  setting the user deliberately chose. The consequence is explicit — this
  capsule fixes the "everything except errors is imperceptible" half of the
  report, and a device with system touch feedback off (including some
  power-saving modes) stays silent by design.
- **Three hardware tiers, degrading honestly.** API 30+ with
  `areAllPrimitivesSupported(PRIMITIVE_CLICK, PRIMITIVE_TICK)` gets scaled
  composition primitives, the only tier where all five levels are distinct.
  API 29+ gets predefined effects, where `MEDIUM_IMPACT` and `HEAVY_IMPACT`
  collapse onto `EFFECT_HEAVY_CLICK` because only four predefined effects
  exist. API 26+ gets one-shot/waveform effects using amplitude when
  `hasAmplitudeControl()` and duration alone when not, so an ERM device reads
  the ramp as a shorter or longer buzz. Below API 26 (minSdk is 24) the legacy
  duration-only call is used.
- **`MissingPluginException` falls back to the framework path.** An engine
  without the native handler registered keeps the previous weak-but-present
  behaviour instead of going completely silent.
- **`android.permission.VIBRATE` is added.** It is a normal permission, so no
  runtime prompt is shown to the runner, but `Vibrator.vibrate` is a no-op
  without it. It was absent because `performHapticFeedback` routes through the
  system and does not require it.

## Allowed Scope

- One new Kotlin file implementing the vibrator playback and the wire-name enum.
- Channel registration in `MainActivity.configureFlutterEngine`, following the
  shape of the four channels already registered there.
- The `VIBRATE` permission in the main manifest.
- The Android branch inside `SystemRuniacHaptics`, plus the `@visibleForTesting`
  channel/method/wire-name constants the tests assert against.
- Test updates for the new dispatch, and one new JVM test for the wire-name
  contract.
- This capsule document plus its append-only `CURRENT.md` routing line. The
  `check-diff-hygiene.sh` allowlist pair that admits the capsule markdown was
  written for this capsule but reached `main` inside PR #51 (see the shared
  worktree note below), so this branch does not touch that file.
  `check-pre-scaffold-scope.sh` needs no change: everything else this capsule
  touches lives under the already-approved
  `implementation/mobile/runiac_app/` scaffold prefix.

## Forbidden Scope

- Any change to which call site fires which level. The semantic map is
  unchanged; only the strength of each level changes.
- Any new dependency, `pubspec.yaml`/`pubspec.lock` change, or plugin.
- Any iOS change — no Swift, no `Info.plist`, no `Runner.xcodeproj`, no
  `Podfile.lock`. `dart format` must not be run repo-wide.
- Bypassing the system touch-feedback setting under a non-touch vibration usage.
- Any Firebase, Cloud Function, `firestore.rules`, index, `storage.rules`,
  collection, secret, or backend surface.
- Any XP, level, rank, streak, or leaderboard computation, and any client-side
  writing of a backend-owned value.
- Any new user-visible string, settings row, or navigation change. The Settings
  toggle keeps its existing copy and behaviour.
- Any commit, push, PR, or release without separate explicit authorization.
- Edits inside the isolated `adaptive-character-guidance` worktree.

## Exact Target Files

Created:

- `implementation/mobile/runiac_app/android/app/src/main/kotlin/com/runiac/runiac_app/RuniacHaptics.kt`
- `implementation/mobile/runiac_app/android/app/src/test/kotlin/com/runiac/runiac_app/RuniacHapticKindTest.kt`
- `implementation/roadmap/capsules/android-native-haptics.md`

Modified:

- `implementation/mobile/runiac_app/android/app/src/main/kotlin/com/runiac/runiac_app/MainActivity.kt`
- `implementation/mobile/runiac_app/android/app/src/main/AndroidManifest.xml`
- `implementation/mobile/runiac_app/lib/core/haptics/runiac_haptics.dart`
- `implementation/mobile/runiac_app/test/runiac_haptics_test.dart`
- `implementation/roadmap/CURRENT.md`

## Shared worktree note (2026-07-31)

This capsule was implemented in the Desktop worktree while a concurrent session
was working the `feed-engagement-push-delivery` capsule in the same worktree.
Two consequences are recorded rather than hidden:

- The `is_android_native_haptics_capsule_active` / `is_android_native_haptics_path`
  pair in `tools/governance-ci/check-diff-hygiene.sh` was authored for this
  capsule but was staged and merged by that session as part of PR #51, so it is
  already on `main` and is absent from this branch's diff. Nothing was lost and
  the gate is live; only the provenance is split across two PRs.
- That session also moved the shared worktree onto its own branch mid-flight.
  This capsule's work was stashed, replayed onto `feat/android-native-haptics`
  fast-forwarded to `main` at `35108c41`, and re-validated there. No commit of
  either capsule was rewritten.

Deliberately untouched: every `RuniacHapticsScope.maybeOf(context)?.…` call
site, `app_settings_screen.dart`, `app_settings.dart`,
`shared_preferences_app_settings_repository.dart`, `lib/app.dart`, and the
other three haptic test files, all of which exercise the abstraction rather
than the platform seam.

## Effect table (what a runner feels)

| Level | API 30+ primitives | API 29+ predefined | API 26+ one-shot |
| --- | --- | --- | --- |
| `selection` | `TICK` @ 0.4 | `EFFECT_TICK` | 10 ms @ 60 |
| `lightImpact` | `CLICK` @ 0.5 | `EFFECT_CLICK` | 15 ms @ 100 |
| `mediumImpact` | `CLICK` @ 0.8 | `EFFECT_HEAVY_CLICK` | 25 ms @ 180 |
| `heavyImpact` | `CLICK` @ 1.0 + `TICK` @ 0.6 after 30 ms | `EFFECT_HEAVY_CLICK` | 40 ms @ 255 |
| `error` | `CLICK` @ 0.7 twice, 90 ms apart | `EFFECT_DOUBLE_CLICK` | waveform 30/90/30 ms |

## Required Tests

- `test/runiac_haptics_test.dart`, Android group: every level reaches
  `runiac/haptics` with method `play` and the matching wire name, and
  `SystemChannels.platform` receives nothing.
- Same file: a missing native handler falls back to the framework channel with
  the correct `HapticFeedbackType`.
- Same file, off-Android group: the framework mapping is unchanged and the
  Android channel stays untouched.
- Both groups: disabled fires nothing, and no call throws when the channel
  fails or is unregistered.
- `RuniacHapticKindTest`: every Dart wire name resolves, unknown/`null` names
  do not, and the kind count is pinned so a level added on one side of the
  channel cannot silently go unfelt on the other.

## Required Validation

- `flutter analyze --no-pub` clean for the changed files.
- `flutter test --no-pub` for `runiac_haptics_test.dart`,
  `haptics_moments_test.dart`, `haptics_app_tree_scope_test.dart`,
  `haptics_error_moments_test.dart`, `app_settings_screen_test.dart`.
- `./gradlew :app:testDebugUnitTest` for the Kotlin test, which also proves the
  new Kotlin compiles against compileSdk 36.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --stat` reviewed before commit to confirm no formatter churn.

## Required Evidence

- Test and analyze output for the runs above.
- Governance CI output.
- **User-owned and not yet produced:** physical Android device confirmation
  that tab switches, the Home menu, feed likes, run start/finish, and the plan
  completion ceremony are now felt, with the device's Android version recorded
  so the tier that was exercised is known.

## Evidence recorded (2026-07-31)

- `flutter analyze --no-pub lib/core/haptics test/runiac_haptics_test.dart` —
  no issues.
- `flutter test --no-pub test/runiac_haptics_test.dart` — 10/10.
- `flutter test --no-pub` (full suite) — 2582/2582.
- `./gradlew :app:testDebugUnitTest --tests com.runiac.runiac_app.RuniacHapticKindTest`
  — exit 0, which also proves `RuniacHaptics.kt` compiles against compileSdk 36.
- `flutter build apk --debug --no-pub` — `app-debug.apk` built in 25.7 s,
  confirming the channel registration and the new permission survive manifest
  merge and the full Android build. The three Java 8 source/target warnings are
  pre-existing plugin noise, unrelated to this capsule.
- `./tools/governance-ci/run-all-checks.sh` — all checks PASS.
- **Not produced:** physical Android device confirmation. It cannot be
  generated from the host and remains user-owned.

## Rollback Conditions

- Roll back if a device reports haptics firing where the app is silent today,
  which would mean a level was remapped rather than restrengthened.
- Roll back if the vibration is felt while the system touch-feedback setting is
  off, which would mean the usage tagging is wrong.
- Roll back if any non-haptic Flutter test regresses, or if the Android build
  fails on a supported API level.

## Exit Criteria

- All validation above PASS. **Met** — see Evidence recorded.
- Committed, pushed, and opened as a PR. **Met** — `12e72f0a`, PR #52. The
  commit, push, and PR were explicitly authorized by the user on 2026-07-31,
  superseding the earlier "ready for manual commit" stop state.
- Hosted Governance CI and `backend-emulator-tests` PASS on PR #52. **Open** —
  both were still pending at the time of writing.
- Real-device confirmation recorded by the user. **Open** — never performed.
- Merge and mobile release remain separate and are NOT authorized by this
  capsule.
