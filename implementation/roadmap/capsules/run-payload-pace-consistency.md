# Run Payload Pace Consistency

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested `completeRun` payload-validation hardening fix. No Phase 02 selection is implied
or authorized.

## Status

Routed on 2026-08-04 Asia/Singapore. Implementation and tests were written and verified before
this capsule was created; this document is the required routing paperwork so
`./tools/governance-ci/run-all-checks.sh` accepts the already-made `functions/**` edit.

## Goal

Reject `completeRun` payloads whose three duration/distance/pace fields are mutually
inconsistent, closing a gap where each scalar was bounds-checked independently and a
self-contradictory triple could still pass.

## Background — the defect

`parseRunCompletionPayload` (`functions/src/run/validateRunPayload.ts`) validates
`durationSeconds`, `distanceMeters`, and `avgPaceSecondsPerKm` each against their own
independent bounds in `validateRunScalarFields.ts`, but never against each other. Before this
change, `{ durationSeconds: 60, distanceMeters: 100_000, avgPaceSecondsPerKm: 600 }` — 60 seconds
claimed to cover 100 km — passed every check individually and was accepted.

The client never produces such a payload. `local_run_tracking_session.dart:243-248` computes the
pace it submits as:

```dart
int get averagePaceSecondsPerKm {
  if (_distanceMeters <= 0) {
    return 0;
  }
  return (activeDurationSeconds / (_distanceMeters / 1000)).floor();
}
```

i.e. `pace = floor(activeDurationSeconds / (distanceMeters / 1000))`, algebraically the same
quantity as the server's `impliedPace = (durationSeconds * 1000) / distanceMeters` once
`durationSeconds === activeDurationSeconds` — which the server already enforces independently at
`validateRunPayload.ts:113-115` (`if (durationSeconds !== activeDurationSeconds) throw invalid(...)`).
So a genuine client payload's three fields are always arithmetically consistent by construction;
only a forged or hand-crafted payload can present a self-contradictory triple.

## What changed

`parseRunCompletionPayload` now computes `impliedPace = (durationSeconds * 1000) / distanceMeters`
whenever `distanceMeters > 0` and rejects the payload if `avgPaceSecondsPerKm` deviates from it by
more than `max(15, ceil(impliedPace * 0.02))` seconds/km:

```ts
if (distanceMeters > 0) {
  const impliedPace = (durationSeconds * 1000) / distanceMeters;
  const tolerance = Math.max(15, Math.ceil(impliedPace * 0.02));
  if (Math.abs(avgPaceSecondsPerKm - impliedPace) > tolerance) {
    throw invalid("avgPaceSecondsPerKm is not consistent with durationSeconds and distanceMeters.");
  }
}
```

### Why 15 s/km is the tolerance floor, not a smaller number

The client `.floor()`s the pace and computes it against the raw unrounded `_distanceMeters` double,
while only the rounded integer metre count is transmitted in the payload. At the client's own
minimum submittable run — `run_summary_scalar_mapper.dart:100-105`,
`_hasSufficientSummaryData`, `distanceMeters >= 50 && durationSeconds >= 60` — that
rounding/flooring slack is worth roughly 12 s/km (see the sufficient-data-floor test below, which
sits inside a 24 s/km tolerance band with no margin to spare below ~15). A smaller floor would
start rejecting genuine low-distance runs; 2% relative tolerance takes over and dominates once
pace is slow enough that 2% exceeds 15 s/km.

### Why pauses are unaffected

The consistency check is computed from `durationSeconds`, which the server already forces to
equal `activeDurationSeconds` (line 113-115) — i.e. the *active* (unpaused) duration — not
`elapsedWallSeconds`. Pausing extends `elapsedWallSeconds` and `pausedDurationSeconds` but leaves
`durationSeconds`/`activeDurationSeconds` and `distanceMeters` exactly as before, so the implied
pace a paused run produces is identical to an unpaused run covering the same distance in the same
active time. No pause-specific casing was needed; the `pausedRunPayload()` regression test below
proves this directly (durationSeconds/activeDurationSeconds 3207, distanceMeters 8460, implied
pace 3207 * 1000 / 8460 ≈ 379.0 s/km, submitted `avgPaceSecondsPerKm: 379`, well inside the
15 s/km floor).

## Repaired fixtures

Three existing test fixtures in `functions/test/completeRun.test.ts` overrode `distanceMeters`
without a matching `avgPaceSecondsPerKm`, so their inherited default pace became inconsistent
under the new check and needed a matching literal:

- Line ~975 (duplicate-detection-adjacent fixture): `durationSeconds: 1500`,
  `distanceMeters: 4200` → implied pace `1500 * 1000 / 4200 = 357.14…`; set
  `avgPaceSecondsPerKm: 357`.
- Line ~1320 (plan-linked long-run fixture): `durationSeconds: 1500`, `distanceMeters: 5000` →
  implied pace `1500 * 1000 / 5000 = 300`; set `avgPaceSecondsPerKm: 300`.
- Line ~1747 (replay/already-exists fixture): `durationSeconds: 1800`, `distanceMeters: 4000` →
  implied pace `1800 * 1000 / 4000 = 450`; set `avgPaceSecondsPerKm: 450`. This fixture exists to
  reach the replay/`already-exists` check, so it must pass payload parsing first — without the
  repair it would now fail parsing before ever reaching the behaviour under test.

## Added tests

All four added to `functions/test/completeRun.test.ts`, immediately before the existing
low-data-save test block:

1. **Exploit-shape rejection** — `{ durationSeconds: 60, distanceMeters: 100_000,
   avgPaceSecondsPerKm: 600 }` (60 s claimed to cover 100 km) is rejected `invalid-argument`. This
   is the literal payload that passed before this change.
2. **Sufficient-data-floor accept** — `{ durationSeconds: 60, distanceMeters: 50,
   avgPaceSecondsPerKm: 1200 }`, the client's own minimum submittable run
   (`_hasSufficientSummaryData`). Implied pace `60 * 1000 / 50 = 1200`; exact match, accepted.
3. **Just-outside-tolerance reject** — same floor (implied pace 1200 s/km, tolerance
   `max(15, ceil(1200 * 0.02)) = 24` s/km); `avgPaceSecondsPerKm: 1225` is 25 off, one past the
   boundary, and is rejected `invalid-argument`. Proves the check is a real boundary, not merely
   permissive.
4. **Paused-run accept** — `pausedRunPayload()` (durationSeconds/activeDurationSeconds 3207,
   elapsedWallSeconds 3900, pausedDurationSeconds 693, distanceMeters 8460,
   avgPaceSecondsPerKm 379) is accepted, proving pause handling needs no special casing per the
   mechanism above.

## What this does NOT fix — read before treating this as a security control

**This check does not close the challenge-badge forgery hole.** It rejects only
self-contradictory payloads — internal arithmetic consistency between three client-supplied
numbers, nothing more. `completeRun` still trusts the caller's own claimed distance, duration, and
pace as the ground truth for XP, streak, and challenge-badge purposes. An attacker who sends a
mutually **consistent** but entirely fabricated triple — for example
`{ distanceMeters: 10_000, durationSeconds: 3000, avgPaceSecondsPerKm: 300 }`, a plausible
50-minute 10K that was never run — still passes this check and every existing check, and still
earns XP, progression, and any challenge badge tied to that completion. Nothing about this change
verifies that a run actually happened, that the device was in motion, or that the reported numbers
correspond to real GPS/motion evidence.

Closing that hole requires either device attestation (App Check enforcement on `completeRun`,
currently unenforced per the `review-triage-notification-privacy-quota` capsule's open-items
list) and/or GPS/motion corroboration of the claimed distance and duration. Both are explicitly
deferred: the user was presented with this distinction and chose to scope this capsule to the
cross-field consistency defect only, leaving attestation/corroboration as a separate future
decision. Do not cite this capsule as evidence that run submissions are trustworthy end to end —
it narrows one specific class of malformed input and nothing else.

## Allowed Scope

- `functions/src/run/validateRunPayload.ts`: the cross-field consistency assertion described
  above, inside `parseRunCompletionPayload`, using existing `durationSeconds`/`distanceMeters`/
  `avgPaceSecondsPerKm` values already parsed by that function. No new field, no new allowed key.
- `functions/test/completeRun.test.ts`: the four new tests and the three fixture repairs listed
  above.
- This capsule document and its `implementation/roadmap/CURRENT.md` routing line.
- The routing predicate additions in `tools/governance-ci/check-diff-hygiene.sh` and
  `tools/governance-ci/check-pre-scaffold-scope.sh` needed to allowlist the three paths above.

## Forbidden Scope

- No production `runiac-fypp` deploy of any kind without separate explicit authorization. This
  change is **not deployed** and has no production effect until a separately authorized deploy
  ships it.
- No App Check change (enforcement remains exactly as it is today on `completeRun`).
- No challenge, leaderboard, or XP logic change — this capsule touches payload validation only,
  never the progression/leaderboard/challenge-award pipeline that consumes a validated payload.
- No bound change in `functions/src/run/validateRunScalarFields.ts` — the existing independent
  per-field bounds are untouched; this capsule adds a cross-field check on top of them.
- No new dependency, package, or `package.json`/lockfile change.
- No edit inside the isolated `adaptive-character-guidance` worktree.
- No commit, push, or PR without separate explicit authorization.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line in
  `implementation/roadmap/CURRENT.md`; this routing is strictly append-only.

## Required Validation

- `functions` typecheck / build clean.
- `functions/test/completeRun.test.ts`, `functions/test/completeRunCallableSurface.test.ts`,
  `functions/test/planProgressCompletion.test.ts`, `functions/test/completeCoolDown.test.ts`:
  130 tests, 130 pass, 0 fail, under the `runiac-functions-test` emulator.
- `./tools/governance-ci/run-all-checks.sh` PASS.

## Required Evidence

- The four added tests and three repaired fixtures, listed above with their arithmetic.
- The 130/130 emulator pass count above.
- This capsule's honesty section, read and retained: the fix is narrow and does not make run
  submissions trustworthy end to end.

## Rollback Conditions

- Revert if `avgPaceSecondsPerKm`, `durationSeconds`, or `distanceMeters` semantics change
  upstream such that the implied-pace formula no longer matches the client's actual computation.
- Revert if the tolerance floor proves too tight against real device data once physical-device or
  production evidence is available (none has been claimed here).

## Exit Criteria

- [x] Cross-field consistency assertion added to `parseRunCompletionPayload`.
- [x] Three pre-existing fixtures repaired to be internally consistent.
- [x] Four new regression tests added and passing.
- [x] 130/130 emulator suite evidence recorded.
- [ ] `./tools/governance-ci/run-all-checks.sh` PASS (recorded once this capsule's routing lands).
- [ ] Deploy — explicitly out of scope for this capsule; a separate authorization is required.
