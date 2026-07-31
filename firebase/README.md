## Purpose
Tracks the Firebase backend project area for Runiac.

## Current Firebase baseline
- Root `firebase.json` exists for local emulator configuration.
- Root `firestore.rules` and `firestore.indexes.json` exist.
- `tests/firebase-rules/` contains synthetic Firestore rules tests.
- `functions/` contains the emulator-only `completeRun` Cloud Functions skeleton.
- The Flutter auth flow can use Firebase Auth emulator wiring for email/password signup, login, password reset, auth-state persistence, and sign-out.
- Production Firebase Auth/mobile config is connected for project `runiac-fypp` as of `478898c0 feat(auth): connect production firebase auth` via `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `implementation/mobile/runiac_app/firebase.json`.
- Outside the emulator flag, Auth bootstrap uses `FirebaseRuniacAuthRepository`; emulator Auth/Functions wiring remains guarded by `RUNIAC_FIREBASE_EMULATOR=true`.
- Google/OAuth is not implemented. The mobile UI keeps Google sign-in disabled instead of faking success.
- Android debug emulator auth testing requires debug cleartext traffic so the app can reach the local Auth emulator host. This is a debug/emulator boundary only and is not production Firebase configuration.
- Firestore emulator smoke validation used transient `firebase-tools@14.27.0`.
- The mobile app now has a narrow onboarding profile persistence path for authenticated `userProfiles/{uid}` writes, backed by local Firestore rules tests.

## Not implemented

> **⚠️ This section is stale and is retained only as a record of the early-scaffold state.**
> Corrected 2026-07-31. Most entries below were superseded long ago by routed and shipped
> capsules. Verified against the tree at `main` @ `6eb6efef`:
>
> - **`functions/src/index.ts` exports 61 Cloud Function symbols** across newsletter (5), feed
>   (12), challenge (12), friends (11), moderation (3), leaderboard (2), profile (3),
>   notifications (3), progression, errors, and agents. The "emulator-only `completeRun`
>   skeleton" framing below and in `## Current backend direction` no longer describes this
>   repository.
> - `firestore.rules` (1,231 lines) and `storage.rules` are real, and are covered by 139 rules
>   test cases across ~40 collections in `tests/firebase-rules/`.
> - A server-owned progression formula exists — see `functions/src/progression/`, including
>   `progressionAudit.ts`, which persists every XP derivation step to `progressionEvents`.
> - Multiple capsules record production deploys to `runiac-fypp`.
>
> **Live deploy state is deliberately NOT asserted here.** Source presence is not deployment
> evidence. Confirming what is actually live requires the approved read-only inventory step
> (`firebase functions:list` / `firebase firestore:indexes`) defined in the release runbook.
> Until that runs, treat any per-function deploy claim in this repository as unverified.

Original entries, superseded:

- ~~No `.firebaserc`.~~
- ~~No Firestore rules/index deployment.~~
- ~~No broad production Firestore feature wiring beyond the narrow onboarding `userProfiles/{uid}` profile path.~~
- No auth-time Firestore profile bootstrap; signup has only email/password. Safe `userProfiles/{uid}` creation is tied to onboarding completion. The client must not write `users/{uid}` or backend-owned role, subscription, progression, leaderboard, validation, premium, or expert-publication fields. **(still accurate)**
- No Google/OAuth provider flow. **(still accurate)**
- ~~No production Cloud Functions deploy target.~~
- ~~No real backend-owned progression formula.~~
- No real GPS/private route fixtures. **(still accurate, and intentional)**

## Tooling note
The latest Firebase CLI may require Java 21 or newer. Java/tooling upgrade work remains future scope.

`functions/package.json` pins Firebase emulator tooling for this capsule. Current npm audit findings are accepted for this emulator-only tooling lane because the available fix requires a breaking `firebase-tools` major upgrade and production deploy remains forbidden. Reassess before any production Functions deploy or CI hardening capsule.

## Current backend direction

**Corrected 2026-07-31.** The paragraph previously here described an emulator-only `completeRun`
skeleton with rules deployment, production Functions deploy, XP formulas, and leaderboard
aggregation all listed as "future scope". That has not been true for some time — all four exist
in the tree today. It is preserved below for history only.

The backend is a full server-owned domain layer: run completion and cool-down, progression
(XP/level/streak with an audit trail in `progressionEvents`), leaderboard snapshots and
aggregation, challenges, friends, feed publish/engagement/lifecycle, moderation, notifications,
newsletter, profile avatars and public profiles, and error reporting. ADR-002 Emulator First
still governs *how* this work is developed and tested — every suite runs against emulators with
`demo-`-prefixed projects — but it no longer describes the deployment ceiling.

For what is actually live in `runiac-fypp`, do not trust this file or capsule prose. Run the
approved read-only inventory step in the release runbook and compare it against
`functions/src/index.ts`.

<details>
<summary>Superseded description (kept for history)</summary>

The active backend direction is the emulator-only `completeRun` Cloud Functions skeleton, bounded production Firebase Auth/mobile config for `runiac-fypp`, and a narrow onboarding `userProfiles/{uid}` profile persistence path. The callable skeleton may validate raw run completion input and write backend-owned emulator documents, and the Auth emulator supports email/password auth-state flows when `RUNIAC_FIREBASE_EMULATOR=true`. Firestore rules deployment, auth-time profile persistence, OAuth providers, production Cloud Functions deploy, real XP formulas, and leaderboard aggregation remain future scope.

</details>
