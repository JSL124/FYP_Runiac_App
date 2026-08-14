# route-preview-coordinate-precision

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested IMPLEMENTATION_MODE bug fix. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-09 Asia/Singapore after the user reported that the route polyline on a saved
run "used to be smooth" and now looks wrong, and asked for the cause to be confirmed before any
implementation. The cause was confirmed first; the precision change below is the user's decision
taken after being shown the trade-off.

## Goal

Draw a saved run's route as the line the runner actually ran, instead of the axis-aligned
staircase produced by snapping every stored point onto a ~111 m grid.

## Mode / Lane / Status

- Mode: IMPLEMENTATION_MODE.
- Lane: Flutter run-completion serialization plus the trusted `completeRun` payload validator.
- Status: `Implemented, pending deploy and mobile release`.

## Background — the confirmed mechanism

`RunCompletionRequestPayloadSerializer._quantizeCoordinate` rounded every persisted
`routePreview` coordinate to three decimals, and
`functions/src/run/validateRoutePreview.ts` rejected anything finer, so three decimals was a
hard ceiling on both sides of the contract.

0.001° is ~111 m of latitude, and ~111 m of longitude at Singapore's latitude. The same preview
caps at 256 points, so an 8.19 km run samples about every 32 m: three to four consecutive points
land in one grid cell and then jump a whole cell, which renders as 90° steps. The screenshot the
user reported shows steps of roughly one scale-bar-tenth (~100 m), matching the grid.

The read path is `routePreview` → `FirestoreRunSummarySnapshotDecoder` (`:31`) →
`FirestoreActivityHistoryRepository` (`:225`) → `CompletedRouteMapSurface` /
`ActivityRoutePreview`. Nothing on that path re-quantizes; the geometry was already lost at write
time.

"It used to be smooth" is consistent with this: before `5fa1aa5c` (2026-07-12) no route preview
was persisted at all, and only the live in-memory session route — full GPS precision — was ever
drawn. That same commit introduced both the three-decimal client quantizer and the server ceiling.

## Decision

Five decimals (~1.1 m) on both sides. Consumer GPS error is roughly 5 m, so five decimals sit
just below the noise floor of the source data: the stored line is honest without carrying
precision a map preview cannot use. Where a route may be seen at all stays a `routePrivacy`
decision, which is unchanged by this capsule.

Rejected alternatives:

- **Four decimals (~11 m).** Removes most of the visible staircase but still quantizes at road
  width, so the artifact survives at zoom.
- **Keep three decimals, smooth the polyline at render time.** No backend change and it would
  also improve already-stored runs, but it draws a curve through points that can be ~55 m from
  where the runner was. That is a prettier wrong line, not a right one.

## Allowed Scope

- `RunCompletionRequestPayloadSerializer._quantizeCoordinate`: 3 → 5 decimals.
- `functions/src/run/validateRoutePreview.ts` `readCoordinate`: same ceiling, same rejection
  shape, message updated.
- Update the two backend fixtures/cases that pin the old ceiling, and the Flutter adapter test
  expectations; add one Flutter regression test that successive points ~3 m apart stay distinct.
- Correct the stale precision claim in the `compact_run_activity_card.dart` diagnostic comment.
  The diagnostic log itself stays masked at three decimals — a debug line has no reason to
  pinpoint the runner.
- This capsule document, `implementation/roadmap/CURRENT.md` routing, and the two governance
  routing predicates.

## Forbidden Scope

- No change to the 64-segment / 256-point bounds, and no new persisted route field: timestamps,
  altitude, accuracy, speed, and raw samples stay rejected.
- No change to `routePrivacy`, feature entitlement, or who may view a route.
- No XP, streak, level, rank, leaderboard, or entitlement behaviour change.
- No attempt to repair already-stored runs. The server holds only the quantized copy, so runs
  written before this change cannot be recovered and will stay stepped.
- No secret or dependency change under this capsule. The `completeRun` deploy below was
  separately authorized by the user mid-task; nothing else may be deployed under this routing.
- No repo-wide `dart format`.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/features/run/domain/models/run_completion_request_payload_serializer.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/compact_run_activity_card.dart` (comment only)
- `implementation/mobile/runiac_app/test/run_completion_request_adapter_test.dart`
- `functions/src/run/validateRoutePreview.ts`
- `functions/test/completeRunRichSummaryCases.ts`
- `functions/test/completeRunRichSummaryFixtures.ts`
- `implementation/roadmap/capsules/route-preview-coordinate-precision.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)
- `tools/governance-ci/check-pre-scaffold-scope.sh` (routing predicate only)

## Required Tests

- `flutter test test/run_completion_request_adapter_test.dart test/run_completion_location_privacy_test.dart`
- `functions` `lib/test/completeRun.test.js`, which carries the rich-summary route preview cases.

## Required Validation

- `functions` build clean (`npm run build`).
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- `CURRENT.md` anchors: 43 `- Newly routed` before this capsule's line is appended, 44 after;
  exactly 1 `- Current active capsule` throughout.

## Evidence (2026-08-09)

**Flutter** — `flutter test test/run_completion_request_adapter_test.dart
test/run_completion_location_privacy_test.dart`: `All tests passed!` (22 tests), including the
new `keeps successive route preview points distinct at running scale`, which asserts 30 points
spaced 0.00003° (~3.3 m) apart remain 30 distinct values. Under the old ceiling they collapsed to
one.

**Functions** — `node --test lib/test/completeRun.test.js` against the Firestore/Auth emulators:
`# tests 89 # pass 89 # fail 0`, with `ok 8 - rejects unquantized route preview coordinates` now
rejecting a six-decimal coordinate against the five-decimal ceiling.

The emulators were already running from another session, so the suite was pointed at the live
emulator hosts under the isolated `runiac-functions-test` project id rather than starting a second
`emulators:exec`. No other session's emulator data is shared.

## Deploy Record (2026-08-09)

The user authorized proceeding on the `jason04334@gmail.com` account mid-task.
`firebase deploy --only functions:completeRun --project runiac-fypp` reported
`functions[completeRun(asia-southeast1)] Successful update operation.` — only that callable was
deployed, because `validateRoutePreview` reaches production through `validateRunPayload` ->
`completeRun` and nothing else.

The deploy carries the working tree, which is not yet committed.

## Deploy / Release Note

The server ceiling is enforced in `completeRun`, so **Functions must be deployed before the
mobile build ships**. A client at five decimals talking to a three-decimal validator has every
run completion rejected with `invalid-argument`. The reverse order is safe: the new validator
accepts the old client's three-decimal payloads unchanged.

Already-stored runs are not repaired by either step.

## Rollback Conditions

- Revert if any run completion is rejected on the coordinate rule after deploy.
- Revert if persisted preview size becomes a problem — five decimals adds digits, not points, and
  the 64/256 bounds are untouched, so this is not expected.

## Exit Criteria

- [x] Client and server ceilings moved to five decimals together.
- [x] Backend rejection case and fixtures updated; Flutter regression test added.
- [x] Flutter and Functions suites green; governance CI PASS locally.
- [x] `completeRun` deployed to `runiac-fypp` (2026-08-09).
- [x] Read-side ceiling raised to match the write contract (2026-08-14, see below).
- [ ] Mobile release built and shipped, after which new runs draw at the new precision.

## Follow-up — the read-side ceiling was missed (2026-08-14)

The 2026-08-09 change moved the writer and the server validator but left the reader on the old
grid. `FirestoreRunSummarySnapshotDecoder._readRoutePreviewPoint` gated every persisted point on
a three-decimal check, and the "Background" note above — that the read path "never re-quantizes"
— was true of the geometry but missed that the same path *validates* it. A five-decimal point
failed the check, the point decoded to `null`, and one `null` discards the entire `routePreview`,
so a run recorded by a fixed client would have opened from Activity History with
`RunRouteSnapshot.empty` and `isTrustedPersistedRoutePreview: false` — no line drawn at all.

It stayed invisible because the completion screen renders the live session route and never goes
through the decoder; only re-opening the run from history reads Firestore. No shipped build wrote
five-decimal data, so no stored run was affected.

The guard now accepts the five-decimal write contract. Coarser values still pass, which is what
keeps every run stored under the old ceiling readable — that grid is a subset of this one. The
check remains a real trust boundary: anything finer than the contract is raw geometry and is
still rejected, alongside the untouched timestamp/altitude/bounds rules.

Files: `implementation/mobile/runiac_app/lib/features/you/data/firestore_run_summary_snapshot_decoder.dart`
and its coverage in `implementation/mobile/runiac_app/test/firestore_activity_history_repository_test.dart`
(the `unquantized-preview` rejection fixture moved past the new ceiling, plus a positive
five-decimal acceptance test). Both sit under the unconditionally allowed
`implementation/mobile/runiac_app/*` scope; no backend, deploy, or privacy surface is touched.
