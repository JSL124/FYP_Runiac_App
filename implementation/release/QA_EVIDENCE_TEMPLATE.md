# QA Evidence Template

One file per flow run. Copy this, fill it in, and save the result under `test-evidence/`.

> **Why this template lives here.** `test-evidence/` is deny-listed for agent access — it is
> where screenshots containing real coordinates would land, and
> `tools/governance-ci/check-sensitive-paths.sh` enforces that protection. The template is kept in
> `implementation/release/` so it can be maintained; the filled-in evidence stays in
> `test-evidence/`, written by a human.

---

## Before you start

**Accounts.** Three dedicated QA accounts: Basic ×1, Premium ×1, Admin ×1. Never a personal
account — the evidence is committed.

**Data.** Synthetic routes only. **No real GPS traces and no real personal data.** Seed with:

```bash
(cd functions && npm run leaderboard:seed:emulator)
(cd functions && npm run feed:fixtures:emulator)
```

**App Check.** The debug build's token must be registered in the Firebase Console first.
Unregistered, every App Check-enforced callable fails and the run is wasted.

**iOS only.** Run `flutter build ios --config-only` after any `flutter analyze` or `flutter test`,
before building — those commands reset the SwiftPM manifest to iOS 13.0 while Firebase needs 15.0.
`tool/qa/run_qa_surface.sh` handles this when it drives the run.

**Launching a QA surface.**

```bash
cd implementation/mobile/runiac_app
tool/qa/run_qa_surface.sh --list                       # find a device id
tool/qa/run_qa_surface.sh app_tour -d "iPhone 17"
tool/qa/run_qa_surface.sh premium_paywall --android
```

Surfaces: `app_tour`, `feed_mvp`, `leaderboard_ranking`, `plan_completion`, `premium_paywall`,
`xp_update`.

Note these are **screen-level harnesses, not whole journeys**. They shortcut into a surface for
focused checks. The eight flows in `RELEASE_CHECKLIST.md` §2 are end-to-end and are driven through
the normal app, using the harnesses only where a state is otherwise hard to reach.

---

## Redaction — apply before saving anything

Same classes as `functions/src/errors/sanitize.ts`, which deliberately over-redacts:

| Remove | Appears in |
|---|---|
| Coordinate pairs and labelled lat/lon | Map screenshots, logs |
| Real place names recognisable as home or workplace | Map screenshots |
| Email addresses | Auth screens, logs |
| URL query strings | Logs |
| Digit runs of 5 or more | Logs |
| uids, ID tokens, FCM tokens, App Check debug tokens | Logs |

A map screenshot centred on a real location is not redactable by cropping — retake it with
synthetic data instead.

---

## Evidence record

```
Flow:            T1-1 | T1-2 | T1-3 | T1-4 | T2-5 | T2-6 | T2-7 | T2-8
Platform:        Android | iOS
Device:          <model / OS version, or simulator name>
Build:           <commit sha>
Account tier:    Basic | Premium | Admin
Date:            <YYYY-MM-DD, Asia/Singapore>
Result:          PASS | FAIL | BLOCKED
```

**Steps performed**

1.
2.
3.

**Observed**

<What actually happened. Note anything that differed from expectation even if the flow passed.>

**Screenshots**

| File | Shows | Redacted |
|---|---|---|
| `screenshots/<name>.png` | | ☐ |

**Defects found**

<None, or one line each with the reproduction.>

---

## Flows T1-3 and T1-4 need more than screenshots

These two carry **negative claims** — *the client does not write XP*, *Premium confers no
competitive advantage*. A screenshot of a correct number establishes neither. Attach all four
parts:

| # | Evidence | Where it comes from |
|---|---|---|
| ① | Observed behaviour | This record |
| ② | Client direct-write **denied** | `tests/firebase-rules/` — `users/{uid}` denies `create, update, delete` unconditionally |
| ③ | Server computes the value | `functions/test/` — `functions/src/progression/` |
| ④ | Basic and Premium use the identical formula | `functions/test/` |

Inventory what already exists before writing anything new: 139 rules cases, 82 Cloud Functions
test files, and `functions/src/progression/progressionAudit.ts`, which persists every XP
derivation step to `progressionEvents`. That audit trail is the strongest single artefact for
②–④.

**④ already has dedicated tests** — cite them rather than re-deriving the claim by hand:

- `functions/test/completeRun.test.ts:1683` — same XP and leaderboard credit for premium as basic,
  with client-authored `xp` / `rank` / `leaderboardScore` untouched regardless of tier
- `functions/test/completeCoolDown.test.ts:406` — same for the cool-down bonus

Note the direction of the one tier branch that does exist: `config/progression.premiumEarnsXp`
(default `true`) can suppress Premium XP entirely. Nothing grants Premium more. If QA runs against
a non-default config, record the flag's value alongside the result.

---

## Tier boundary specifics for T1-4

Assert all three directions, not just the denials:

| Check | Expected |
|---|---|
| Basic hits `aiHomeCoach`, `activityFeedback`, `workoutBriefing`, `shareRouteToFeed` | **Denied**, server-side |
| Basic uses `shareCards`, `healthWorkoutImport` | **Works** — these are basic tier |
| Premium hits all of the above | Works |
| `advancedAnalysis` | Configured premium with **no server gate** — computed on-device, so record what a Basic account actually sees |

Testing only the denials would miss a regression that locks Basic Users out of their own features.
