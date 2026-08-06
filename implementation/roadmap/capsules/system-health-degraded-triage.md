# System Health Degraded Triage

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested production defect fix. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-06 Asia/Singapore after the admin console's System health panel showed
**Cloud Functions: Degraded** and **App error rate: Degraded** at the 2026-08-05 20:10 UTC check.
The panel was reading production correctly; both badges resolved to real defects.

## Goal

Fix the two production defects the panel surfaced, and add a repository-level guard so the first
one cannot recur silently.

## Background — how the two badges were traced

`getLiveSystemHealth()` (`website/src/lib/admin/live-data.ts:682`) derives all four rows from the
`errorGroups` collection:

- **Cloud Functions** → `degraded` when a group with `source: "functions"` and `severity: "high"`
  was last seen within 24h (`live-data.ts:711-723`).
- **App error rate** → `degraded` when any group of any source with `severity: "critical"` was
  last seen within 24h (`live-data.ts:725-729`).

A read of the production collection (13 groups in `runiac-fypp`) returned exactly one match for
each rule. Neither badge was a console bug, and `errorGroups` was reachable, so the
`errorGroupsUnavailable` branch that would have set both rows amber together was not taken.

### Defect 1 — account deletion aborts on an undeclared collection-group index

The one `source: "functions"` group, last seen 2026-08-05 18:17:38 UTC, screen
`accountDeletionCommandCreated`:

```
9 FAILED_PRECONDITION: The query requires a COLLECTION_GROUP_ASC index
for collection likes and field userUid
```

`accountDeletionCommands/1tfcxmyohWTaWvAEol1hv7479HE2` is at `status: "failed"` with
`completedSteps: ["challenge-exit", "avatar-objects", "feed-posts"]`. The fan-out died on the
fourth step, `feed-engagement`, which runs
`firestore.collectionGroup("likes").where("userUid", "==", uid)`
(`accountDeletionInventory.ts:109-114`, executed at `accountDeletionCore.ts:162-170`).

Firestore creates single-field indexes implicitly only at COLLECTION scope. A COLLECTION_GROUP
equality query needs an explicit `fieldOverrides` entry, and three of the inventory's four
collection-group steps had none:

| Step | Query | Declared before this capsule |
| --- | --- | --- |
| `feed-engagement` | `likes` / `userUid` | no — the observed failure |
| `feed-comments` | `comments` / `authorUid` | no — would fail next |
| `social-mirrors` | `friends`, `friendRequests`, `blockedUsers` / `uid` | yes |
| `inbox-mentions` | `items` / `data.actorUid` | no — would fail after that |

The deployed index configuration was confirmed against the live project and matched the repository
file exactly: four COLLECTION_GROUP overrides (`friends.uid`, `friendRequests.uid`,
`blockedUsers.uid`, `tokens.tokenFingerprint`) and nothing else. So this is a declaration gap, not
a deploy gap.

**Why the omission survived review.** `social-mirrors` reuses the three groups
`nicknameFanoutReferences` (`friendsNicknameFanout.ts:15-21`) had already indexed for the rename
fan-out, and the capsule record for `account-deletion` says so explicitly — "so the needed indexes
exist". That sentence is true of `social-mirrors` and was read as covering the collection-group
steps generally. `firestore.indexes.json` is also absent from the `account-deletion` path
allowlist in both governance checkers, so no gate ever asked whether the capsule needed an index.

**Why this is more than an error badge.** `accountDeletionCommand.ts` performs the irreversible
half first — `accountStatus = "deleting"`, `nicknameClaims` release, `revokeRefreshTokens`, Auth
disable — and only then creates the command document the trigger consumes. A throwing step sets
`status: "failed"` and skips every later step. The affected runner is therefore locked out of an
account whose activities, run summaries, progression events, notification inbox, and storage
objects all still exist. Against a capsule whose binding scope decision was "immediate and
irreversible" deletion, that is a data-protection failure, not a degraded metric.

### Defect 2 — the sign-out teardown awaits the platform before running

The one `critical` group, last seen 2026-08-05 19:55:25 UTC, 38 occurrences across 17 runners:

```
[firebase_messaging/apns-token-not-set] APNS token has not been received on the device yet.
  #2 NotificationRegistrationService.unregisterCurrentDevice
     (notification_registration_service.dart:220:36)
```

It scores `critical` because `deriveSeverity` returns critical for `fatal && affectedUserCount >= 10`
(`functions/src/errors/sanitize.ts:118`), and it is fatal because `app.dart:522-524` calls
`unregisterCurrentDevice()` inside `unawaited(...)` with no error handler, so the throw surfaces as
an uncaught async error.

Line 220 was `final token = _currentToken ?? await client.getToken();` — sitting **above** the
teardown block whose own comment states that "Isolating the device from the previous owner must not
depend on the network." On iOS `FirebaseMessaging.getToken()` throws until APNs has handed the
device its token, so a session that signed out before that point skipped `_generation`,
`_currentUid`, `_started`, and `_cancelSubscriptions()` entirely. That is precisely the state the
teardown ordering exists to prevent: the previous owner's message subscriptions stay live with
`_started` still true, and the next sign-in re-attaches to that stream while `start()` no-ops.

The registration path directly above it already guards the same call —
`if (client.platform == PushNotificationPlatform.apple)` then `getAppleApnsToken()` before
`getToken()` (`:198-203`). Only the unregister path calls it bare.

## Allowed Scope

- Add the three missing `fieldOverrides` entries (`likes`/`userUid`, `comments`/`authorUid`,
  `items`/`data.actorUid`) to `firestore.indexes.json`.
- Add `tests/cross-system/account-deletion-index-drift.mjs` plus its
  `tests/governance/` wrapper, and register it in `run-all-checks.sh`, so every
  `kind: "collectionGroup"` step in the deletion inventory is checked against the declared indexes.
- Comment-only edit to `accountDeletionInventory.ts` recording the index requirement at the point
  where the next collection-group step will be added.
- In `notification_registration_service.dart`: move the token resolution below the local teardown
  and behind the existing owner-switch guard, and make the platform token read non-throwing.
- Test coverage for the crash in `notification_registration_service_test.dart`, with a
  `tokenError` seam on `FakePushNotificationClient`.
- Update this capsule document, `implementation/roadmap/CURRENT.md` routing, and the two governance
  checker predicates.

## Forbidden Scope

- **No production deploy, commit, push, or PR without separate explicit authorization.** The index
  fix is inert until `firebase deploy --only firestore:indexes` runs and the build completes.
- **No re-drive of `accountDeletionCommands/1tfcxmyohWTaWvAEol1hv7479HE2`.** That is a production
  data mutation against a real runner's account and requires its own authorization, after the
  indexes are live.
- No change to the deletion step list, its ordering, or `RETAINED_COLLECTIONS`. The steps are
  correct; only their index declarations were missing.
- No change to the erase fan-out's failure semantics. Making a failing step non-fatal would
  silently under-delete, which is worse than failing loudly.
- No change to `deriveSeverity`, to the System health thresholds, or to any admin console file.
  The panel reported accurately and needs no adjustment.
- No change to `registerCurrentDevice`'s APNs guard, which is correct as written.
- No iOS/Android native change, no new dependency, no repo-wide `dart format`.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line.

## Why a drift check rather than a comment

A comment would have prevented this instance and nothing else. The failure mode is that a
TypeScript declaration and a JSON deploy artifact must agree with no type-level link between them,
which is the same shape as the three drift checks already wired into Governance CI
(`config-contract-drift`, `avatar-path-contract-drift`, `paywall-config-drift`). The check is
zero-dependency, runs in milliseconds, and fails loudly if the inventory's step shape changes
rather than silently passing over zero matches.

## Exact Target Files

- `implementation/roadmap/capsules/system-health-degraded-triage.md`
- `implementation/roadmap/CURRENT.md`
- `firestore.indexes.json`
- `functions/src/account/accountDeletionInventory.ts` (comment only)
- `tests/cross-system/account-deletion-index-drift.mjs`
- `tests/governance/account_deletion_index_drift_test.sh`
- `tools/governance-ci/run-all-checks.sh`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/notification_registration_service.dart`
- `implementation/mobile/runiac_app/test/notification_registration_service_test.dart`
- `implementation/mobile/runiac_app/test/support/fake_notification_services.dart`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)
- `tools/governance-ci/check-pre-scaffold-scope.sh` (routing predicate only)

## Required Tests

- `flutter test --no-pub test/notification_registration_service_test.dart` passes, with the new
  test shown RED against the pre-fix service and GREEN after.
- `node tests/cross-system/account-deletion-index-drift.mjs` passes, and is shown RED when the
  `likes` override is removed — reproducing the production error text.

## Required Validation

- `flutter analyze --no-pub` clean on the changed Dart files.
- `functions` typecheck clean (`tsc --noEmit`).
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- A12_QA_TEST (both deliverables carry tests) and A13_SECURITY_RULES (the deletion failure is a
  data-protection issue, and index declarations are part of the deletion guarantee).

## Evidence (2026-08-06)

**Defect 1 — production state read before the fix.**

Deployed single-field index overrides in `runiac-fypp`, via the Firestore Admin API:

```
blockedUsers/fields/uid        ['COLLECTION_GROUP']
friendRequests/fields/uid      ['COLLECTION_GROUP']
friends/fields/uid             ['COLLECTION_GROUP']
tokens/fields/tokenFingerprint ['COLLECTION_GROUP']
```

The failed command document:

```
accountDeletionCommands/1tfcxmyohWTaWvAEol1hv7479HE2
  status         failed
  requestedAt    2026-08-05T18:17:32.649Z
  startedAt      2026-08-05T18:17:38.320Z
  completedAt    2026-08-05T18:17:38.713Z
  completedSteps [challenge-exit, avatar-objects, feed-posts]
  error          9 FAILED_PRECONDITION: The query requires a COLLECTION_GROUP_ASC index
                 for collection likes and field userUid
```

**Drift check RED, with the `likes` override removed:**

```
FAIL account-deletion-index-drift: 1 account-deletion sweep(s) would throw FAILED_PRECONDITION:
  step "feed-engagement" queries collectionGroup("likes").where("userUid") — no ASCENDING
  COLLECTION_GROUP fieldOverride declared
exit=1
```

**Drift check GREEN, after the three overrides were added:**

```
PASS account-deletion-index-drift: 6 collection-group deletion queries all have a declared
COLLECTION_GROUP index
```

**Defect 2 — new test RED against the pre-fix service**, failing at the exact production line:

```
NotificationRegistrationService tears down locally when the platform cannot supply a token
at sign-out [E]
  Bad state: apns-token-not-set
  .../notification_registration_service.dart 220:49  NotificationRegistrationService.unregisterCurrentDevice
```

**GREEN after the fix**, whole file: `00:00 +16: All tests passed!`

**Static validation:** `flutter analyze --no-pub` on `lib/features/notifications` and the two test
files — "No issues found!". `npx tsc --noEmit` in `functions/` — exit 0.

## Deployment State

**NOT deployed.** The index declarations are inert in production until
`firebase deploy --only firestore:indexes` runs against `runiac-fypp` **and the index build
finishes** — a deploy returns before the index is queryable, so re-driving the failed deletion
before the build completes would fail the same way. The mobile fix ships with the next app release;
no Functions deploy is required for either change.

**Outstanding and deliberately not done here:** the failed deletion command has not been re-driven,
so that runner's account remains disabled with their data intact. That is a production data
mutation against a real account and needs its own explicit authorization, sequenced after the index
build reports READY.
