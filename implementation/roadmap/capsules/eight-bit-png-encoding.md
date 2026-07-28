# 8-bit PNG Encoding for Rasterized Uploads

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md`

## Mode / Type

Mode: implementation-approved. The user explicitly routed this capsule on 2026-07-28 Asia/Singapore, after the `profile-photo-avatar` capsule's wide-gamut PNG defect was fixed and the same root cause was found to affect every other rasterized upload in the app.

Type: Flutter client-only capsule. No Cloud Function, no `firestore.rules`, no `storage.rules`, no Firestore schema, no config document, no dependency, and no deploy. It reaches users only through a new mobile build.

## Status

Status: Routed, implementation in progress.

Routed on: 2026-07-28 Asia/Singapore.

## Goal

Apply the 8-bit-per-channel PNG narrowing already shipped for avatars (commit `ebc8aaa8`) to every other place the app rasterizes a `ui.Image` into PNG bytes it then uploads: feed route thumbnails, the metric/route history artifacts, and share cards. Reduce upload and download bytes on user-visible surfaces, and remove a latent class of failure where a wide-gamut device produces a PNG that a server-side or rules-level size/format gate rejects.

## Context

On a wide-gamut (Display P3) device — every recent iPhone — Flutter renders `Picture.toImage` and `RenderRepaintBoundary.toImage` into an F16 surface, so Skia's PNG encoder emits bit depth 16 with `sBIT` 10,10,10,10 instead of bit depth 8. This is not a choice the encoding code makes; it follows the rendering surface.

Measured from production objects in `runiac-fypp.firebasestorage.app`, not assumed:

- `feed-thumbnails/RtEOc6ujVKWtOAzBTwBVfgqoGLD2/activity_c1ba56ea2087d065603b7e03/route-preview.png` — 382,632 bytes, `IHDR 1032x552 depth=16 colour=6`, `sBIT 10,10,10,10`.
- `feed-thumbnails/ncSjbFOHUObAgoM6oNxIQ2XcjoP2/activity_b563e6901c3806cfcfb719cc/route-preview.png` — 252,994 bytes, same dimensions, `depth=8`, `sBIT 8,8,8,8`. A different account on a device that is not wide-gamut, which is what makes the comparison diagnostic rather than speculative.
- `share-cards/RtEOc6ujVKWtOAzBTwBVfgqoGLD2/rank-card.png` — 2,855,220 bytes, `IHDR 1010x1263 depth=16`, `sBIT 10,10,10,10`.

A controlled re-encode of one 16-bit avatar upload measured 291,599 bytes at depth 16 against 127,643 bytes at depth 8: a 56% reduction, roughly 2.3x. The earlier "3-4x" figure recorded against the avatar capsule was an unmeasured guess and is corrected in `CURRENT.md`.

Two latent risks motivate this beyond byte cost. Both are UNVERIFIED and must not be reported as observed defects:

1. `validateFeedThumbnailPng` in `functions/src/feed/png.ts` allows bit depth 16 only for its wide dimensions (344x184, 688x368, 1032x552), never for its square ones (88, 176, 264). `view_summary_screen.dart` builds an 88x88 logical request, which is 264x264 at device pixel ratio 3 — a shape the server would reject exactly as it rejected 16-bit avatars. Every one of the nine thumbnails in the production bucket is 1032x552, and the 88x88 path is reached only through a `historyArtifactResolver` that nothing in `lib/` ever injects, so it appears unreachable in the shipped app. That was not traced to a conclusion and is not a claim this capsule makes.
2. `storage.rules` caps `share-cards/{uid}/{fileName}` at 4 MiB. The one production share card is 2.86 MiB at depth 16. A larger screen could plausibly cross the cap at depth 16 where it would not at depth 8.

## Constraint Discovered During Implementation

`ui.decodeImageFromPixels` delivers its result through an engine callback that `flutter_test`'s fake async never pumps. Calling it inside a `testWidgets` body does not fail — it hangs forever. A first implementation that always ran the round-trip broke two existing `run_flow_static_ui_test.dart` cases ("Share Route uses a summary route thumbnail when no artifact resolver is injected" and "Share Route keeps the route preview for a local run while posting stays disabled"), which were confirmed green at HEAD by stashing the change, and a probe `testWidgets` calling the helper directly hung past a ten-minute timeout with even its own `Future.timeout` unable to fire against the fake clock.

The resolution is ordering, not detection: `encodeEightBitPng` encodes directly FIRST and runs the round-trip only when that encode actually came back at depth 16. Host and simulator Skia always emit depth 8, so every widget test returns on the first encode and never reaches the engine callback, while a real wide-gamut device still narrows. This ordering is load-bearing and is commented as such in the helper; reordering it reintroduces the hang.

Verified after the fix, under fake async: the direct encode of a canvas-rendered image reports bit depth 8 and `encodeEightBitPng` returns from it immediately, never entering the round-trip. The two `run_flow_static_ui_test.dart` cases are the standing regression guard for this ordering, having actually caught it.

A dedicated `testWidgets` guard inside `test/eight_bit_png_test.dart` was attempted and deliberately REMOVED. Its body completed correctly (the helper returned narrowed bytes), but the test process then failed to exit — an artifact of driving raster work directly in a `testWidgets` body in this project, reproduced with a probe that does not call this helper at all. The cause was not traced further; the important point is that it is not evidence about the helper, and a test that hangs instead of failing is worse than no test.

Note this also de-risks the already-shipped avatar path from commit `ebc8aaa8`, which called the round-trip unconditionally and would have hung had any `testWidgets` case ever exercised `encodeAvatarPng`.

## Allowed Scope

- A new shared core module holding the narrowing helper, so the avatar encoder and every other rasterizing call site use one copy rather than four.
- Rewiring the four existing `toByteData(format: ui.ImageByteFormat.png)` call sites to that helper, preserving each site's existing null/exception handling exactly.
- Tests for the shared helper and the rewired sites.

## Forbidden Scope

- Any `functions/`, `firestore.rules`, `storage.rules`, index, or config change. In particular, do NOT relax `validateFeedThumbnailPng`'s square-dimension bit-depth rule; narrowing the client output is the fix, and loosening the server would re-open the exact hole the avatar work closed.
- Any production deploy, of anything.
- Any change to image dimensions, device-pixel-ratio handling, privacy masking, route geometry, or which artifact a surface chooses.
- Any new dependency (no `image` package; the narrowing uses `dart:ui` only).
- Chasing risk 1 or 2 above into a behaviour change. They are recorded as motivation, not as work items.
- Any edit or staging inside the isolated `adaptive-character-guidance` worktree.

## Exact Target Files

- `implementation/mobile/runiac_app/lib/core/imaging/eight_bit_png.dart` (new)
- `implementation/mobile/runiac_app/lib/core/share/share_card_export_service.dart`
- `implementation/mobile/runiac_app/lib/features/feed/data/feed_publish/history_artifact_resolver.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_mapbox_snapshot_provider.dart`
- `implementation/mobile/runiac_app/lib/features/profile/data/avatar/avatar_image_encoder.dart`
- `implementation/mobile/runiac_app/test/eight_bit_png_test.dart` (new)
- `implementation/mobile/runiac_app/test/avatar_image_encoder_test.dart`
- `implementation/roadmap/capsules/eight-bit-png-encoding.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh`

## Required Tests

- The shared helper returns a decodable PNG whose IHDR declares bit depth 8, whose pixels and alpha survive the round-trip, and which falls back rather than throwing when narrowing is unavailable.
- The existing avatar encoder suite continues to pass against the extracted helper.
- The feed thumbnail and share-card suites continue to pass unchanged.

## Required Validation

- `flutter analyze --no-pub` clean.
- The full `flutter test --no-pub` suite, compared against the known baseline.
- `tools/governance-ci/run-all-checks.sh` PASS.

## Required Evidence

- Byte-level confirmation that the narrowing branch is the one actually taken, not a silent fallback.
- Real-device confirmation is user-owned and cannot be claimed from the simulator, exactly as it could not be for avatars: host and simulator Skia emit depth 8 regardless, so a green suite proves the code is correct, never that the wide-gamut path narrowed.

## Rollback Conditions

Any narrowed output that fails to decode, loses alpha, or shifts pixels beyond the sRGB clamp. Because every call site falls back to the previous direct encode when narrowing is unavailable, reverting the helper's call sites restores prior behaviour exactly.

## Exit Criteria

All four rasterizing call sites route through the shared helper, validation above passes, and the capsule is committed with the real-device verification explicitly left open for the user to confirm after the next mobile build.
