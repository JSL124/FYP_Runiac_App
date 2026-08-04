# Account Deletion

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003 lane
rules). No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-04 Asia/Singapore. Driven by store policy: Apple Guideline 5.1.1(v) requires
an account-deletion path initiated **inside the app** for any app that supports account creation,
and Google Play's Data deletion policy requires both an in-app path and a web-accessible request
URL.

## Goal

Let a signed-in runner delete their own Runiac account and its data from inside the app, with the
deletion taking effect immediately and irreversibly, and with the small set of records Runiac
keeps for moderation and support integrity anonymized rather than retained under the runner's
identity.

## Background — what exists today

There is **no deletion path of any kind**. The only artifact is a URL constant:

- `implementation/mobile/runiac_app/lib/core/legal/runiac_legal_urls.dart:20` defines
  `accountDeletion = '$base/legal/account-deletion'`. Grep across `lib/` returns that definition
  and **no call site** — no screen links to it.
- `implementation/roadmap/capsules/legal-documents-and-links.md:72,170` states the gap
  deliberately: "No account-deletion implementation. The Account Deletion page documents the
  request path only; building an in-app deletion flow is a separate capsule", and calls the
  hosted page "a knowingly incomplete answer to the Google Play requirement until a deletion flow
  ships." This capsule is that separate capsule.
- `functions/src/index.ts` exports 61 functions; none of them delete a user or user data.

Deletion cannot be a client-side operation in this codebase. `firestore.rules:724-726` denies
`create, update, delete` on `users/{uid}` to every client including the owner, and the same
`delete: if false` appears on `userProfiles`, `generatedPlans`, `planProgress`,
`adaptivePlanEstimates`, `activities`, `runSummaries`, `progressionEvents`, `sharedRoutes`,
`planEnrollments`, `notificationInbox` items, `notificationPreferences`, and every challenge and
leaderboard collection. Only the Admin SDK can carry this out.

Two pieces of existing machinery are directly reusable:

1. **The command-document pattern.** `leaderboardAdminCommands` →
   `leaderboardAdminCommandCreated` and `moderationCommands` → `moderationCommandCreated`
   (`functions/src/moderation/moderationCommand.ts`) both accept a client-denied command document
   and run the real work in an `onDocumentCreated` trigger, merging the outcome back onto the same
   document (a merge-write does not re-trigger `onDocumentCreated`). Deletion needs the same
   shape, for a different reason: the fan-out is unbounded and cannot be guaranteed to fit a
   callable's execution budget.
2. **The account-status lockout.** `functions/src/security/accountStatus.ts` defines
   `BLOCKING_ACCOUNT_STATUSES` over `users/{uid}.accountStatus`, enforced at write-bearing
   callables and mirrored in `firestore.rules:564-583`. Adding `deleting` to that set locks the
   account out through the existing, already-tested path instead of a new one.

## User decisions of record (2026-08-04 Asia/Singapore)

Three design questions were put to the user before any code was written. The answers are binding
scope for this capsule:

1. **Immediate, irreversible deletion.** "즉시 삭제로 진행을 해." No grace period, no restore
   flow, no scheduled sweep, no "pending deletion" login state. The alternative — a 7-day
   recoverable window — was put to the user and rejected.
2. **Reports and feedback are anonymized, not deleted.** "신고/피드백은 deleted user 같은 것으로
   익명화후에 유지." The moderation record survives so that deleting an account is not a way to
   erase a report filed about, or by, the account.
3. **Newsletter is out of scope.** "구독은 별개의 시스템 고려하지 않아도 됨." `newsletterSubscribers`
   is keyed by email address and has its own unsubscribe endpoints; this capsule does not touch it.

## Design

### Three stages

| Stage | Runs in | Does |
| --- | --- | --- |
| A. Lock | `requestAccountDeletion` callable | Everything that makes the account immediately unusable and cannot be left half-done: set `users/{uid}.accountStatus = 'deleting'`, release the `nicknameClaims` entry, `revokeRefreshTokens(uid)`, disable the Auth user, create `accountDeletionCommands/{uid}`. |
| B. Erase | `accountDeletionCommandCreated` trigger | The batched, resumable fan-out over every collection and Storage prefix in the inventory below, recording a per-step cursor on the command document. |
| C. Finalize | end of the same trigger | `admin.auth().deleteUser(uid)`, then mark the command `completed`. |

Stage A alone is what the user experiences as "deleted": the session is dead, sign-in fails, and
the nickname is free. Stage B may take multiple invocations; it must therefore be idempotent on
replay, which is why each step re-reads persisted state rather than trusting the trigger payload —
the same discipline `moderationCommand.ts:71-79` already applies.

The Auth user is disabled in stage A but **deleted only in stage C**, deliberately: as long as the
Auth record exists, the uid is unambiguously reserved and a partially-completed fan-out can be
resumed and audited. Disabling plus token revocation already closes every access path, so
postponing the delete costs no security.

### The command document

New **client-denied** top-level collection `accountDeletionCommands/{uid}`. Keying by uid rather
than an auto-id makes a duplicate request naturally idempotent — a second tap creates nothing new.

```
accountDeletionCommands/{uid}
  uid: string
  status: 'pending' | 'erasing' | 'completed' | 'failed'
  requestedAt: string (ISO)
  completedAt?: string (ISO)
  completedSteps: string[]     // resumable cursor
  error?: string
```

### Deletion inventory

Every path below was read out of `firestore.rules` and `functions/src`, not assumed. `{uid}` is
the deleted runner.

**Deleted — uid is the document id**

`users/{uid}` and its six subcollections (`friends`, `blockedUsers`, `friendRequests`,
`hiddenFeedPosts`, `challengeHistory`, `challengeBadges`); `userProfiles/{uid}`;
`generatedPlans/{uid}`; `planProgress/{uid}`; `adaptivePlanEstimates/{uid}`;
`homeGuideConsents/{uid}`; `notificationDevices/{uid}/tokens/*`; `notificationInbox/{uid}/items/*`;
`notificationPreferences/{uid}`; `challengeSlots/{uid}`; `challengePremiumHolds/{uid}`;
`leaderboardCurrentViews/{uid}`; `friendRateLimits/{uid}`; `errorReportRateLimit/{uid}/events/*`.

`agentGuidanceDaily/{uid}_{dayKey}` (`functions/src/agent/homeGuideQuotaCache.ts:87`) is a
composite id, so it is collected by a `FieldPath.documentId()` range query over the `{uid}_`
prefix rather than a field query.

`leaderboardContributions/{leaderboardContributionId(uid, period)}`
(`functions/src/run/completeRun.ts:93-95`) is likewise deterministic per period.

**Deleted — found by owner field**

`activities` (`ownerUid`), `runSummaries` (`ownerUid`), `progressionEvents` (`ownerUid`),
`sharedRoutes` (`ownerUid`), `planEnrollments` (`ownerUid`), `leaderboardUserRanks` (`ownerUid`),
`challengeInvitations` (`ownerUid` or `recipientUid`), `notificationDeliveries` (operational
delivery log, uid-bearing).

**Deleted — authored content and its reciprocal mirrors**

- `feedPosts where authorUid == uid`: each post goes through the existing
  `beginFeedPostCleanup` + `cleanupFeedPost` pair rather than a raw delete, so likes, comments,
  Storage thumbnails, and other users' `hiddenFeedPosts` markers are removed by the code path that
  already owns that invariant (`functions/src/feed/lifecycle/core.ts`, `functions/src/feed/cleanup.ts`).
- Engagement the runner left on **other people's** posts: `collectionGroup('likes') where userUid == uid`
  and `collectionGroup('comments') where authorUid == uid`.
- Social mirrors held by other users: `collectionGroup('friends' | 'friendRequests' | 'blockedUsers') where uid == {uid}`.
  This is exactly the query `nicknameFanoutReferences`
  (`functions/src/friends/friendsNicknameFanout.ts:15-21`) already runs to fan a rename out, so the
  required collection-group indexes exist.
- Other users' inbox entries about the runner: `collectionGroup('items') where data.actorUid == uid`.
  These are **deleted, not anonymized**, because the actor's nickname is baked into the rendered
  `title`/`body` prose of the envelope
  (`functions/src/feed/engagement/engagementNotifications.ts:245-252`), so there is no field to
  overwrite.
- `friendCooldowns/p1_{sha256(pair)}` is keyed by a hash of the uid pair and cannot be queried by
  uid. It is swept with a bounded batched scan that strips the
  `directionalCooldownUntilByUid.{uid}` map key and any `lastOutcomeSenderUid == uid`
  (`functions/src/friends/friendsCooldowns.ts:20-33`).

**Anonymized and retained** — per user decision 2. The uid is replaced with the sentinel
`deleted-user`; no other field changes.

`reports` (`reporterUid`, and `targetId` where `targetType == 'user'`), `feedback` (`uid`),
`challengeRewardGrants` for already-settled challenges. `errorGroups/{groupId}/reporters/{uid}` is
a uid-keyed marker document, so it is deleted while the aggregate `errorGroups` document — which
carries no identity — is untouched.

**Retained verbatim**

`adminAuditLogs`. These record Platform Administrator actions, not runner activity, and rewriting
them would break the audit trail the moderation and config control planes depend on. Flagged to the
user as the one place the uid survives.

**Storage** (`storage.rules`)

`feed-thumbnails/{uid}/**`, `feed-thumbnail-staging/{uid}/**`, `share-cards/{uid}/**`,
`avatar-staging/{uid}/**` are prefix-deleted. The durable avatar is **not** under a uid prefix —
`avatarPaths.ts:42` mints `avatars/{32-hex}.png` with an opaque id — so it must be resolved from
`userProfiles/{uid}.avatarObjectPath` and `.avatarPreviousObjectPath`
(`functions/src/profile/avatar/callable.ts:108-118`) **before** that profile document is deleted.
Getting this order wrong leaks a permanently orphaned public bearer-URL object.

### Two ordering constraints that are easy to get wrong

1. **Avatar before profile.** As above: the only pointer to the durable avatar object lives on the
   document being deleted.
2. **Challenges before membership.** A live `challengeInstances/{id}` scopes reads by its
   `rosterUids` array and settles against its `participants` subcollection. Deleting
   `participants/{uid}` directly would corrupt headcount and settlement, so an in-flight challenge
   is exited through the challenge system's own transition rules first.

Both are asserted as tests over the inventory data, not left as comments.

### The challenge exit, and why it cannot reuse the callables

`leaveChallengeForCallable` and `abandonChallengeForCallable` both call
`assertCallerAccountNotSuspendedInTransaction` before anything else
(`challengeSettlementCore.ts:118,196`). By the time the fan-out runs, stage A has already set this
account's `accountStatus` to `deleting`, which this capsule adds to the blocking set — so those two
functions would reject their own system caller. That assertion is right for a self-service call and
wrong for a system actor, so the exit composes the same effects from the shared eviction core that
`challenge-premium-lapse-eviction` introduced at `9ab7fa0b`, rather than duplicating the rules:

- `removeParticipantAsSystem` — LEFT, slot released, history frozen, metres left with the team.
- `findEligibleSuccessor` — earliest-joined remaining participant, now taking a `requirePremium`
  flag. Premium lapse always passes `true` (it only ever fires on a premium-only tier); account
  deletion passes it only for a premium-only tier, because demanding premium on an open tier would
  cancel a challenge that has no premium requirement at all.
- `cancelInstanceAsSystem` — same terminal effects under a caller-supplied reason, so the two
  capsules cannot drift on what "the owner is gone" does to an instance.

One deliberate divergence from premium lapse: deletion also exits a **SETTLING** instance, which
premium lapse deliberately does not. The situations differ. A lapsed runner who reached the target
inside their grace window earned that result and must not be evicted out of a settlement in flight;
a runner deleting their account is forfeiting by choice, and leaving them in a settling instance
would let the settlement sweep write a badge and a history document under a uid the fan-out has
already erased.

New terminal reason `OWNER_ACCOUNT_DELETED`, distinct from `OWNER_ABANDONED` (the owner ended their
account, not this challenge) and from `OWNER_PREMIUM_LAPSED` (this one fires on any tier and is
never recoverable by re-subscribing).

### Leaderboard snapshot residue — plan corrected during implementation

This capsule was routed saying the fan-out would rewrite the runner's entry in
`leaderboardSnapshots.topEntries` to the sentinel. **It does not, because it cannot.**
`LeaderboardPublicEntry` (`functions/src/leaderboard/leaderboardTypes.ts:38-57`) carries
`publicAlias` and labels but deliberately **no `ownerUid`** — the comment there states the reason:
snapshot rows are world-readable to every signed-in user, so a uid-bearing row would disclose every
ranked runner's uid. There is therefore no way to locate this runner's row by uid, and matching on
`publicAlias` would risk rewriting a different runner's row on a nickname collision.

What happens instead: the row is superseded by the hourly `refreshLeaderboardSnapshots` pass, which
rebuilds snapshots from the `leaderboardContributions` the fan-out has already deleted. The residue
window is up to one hour and carries a public alias and a score, but no identifier. This is recorded
as a `RETAINED_COLLECTIONS` entry in `accountDeletionInventory.ts` so it is auditable in code rather
than only in this document.

### Client flow

A danger-zone `Delete account` row below `AccountSignOutRow` on the Account screen opens a
confirmation screen that states plainly what is erased and what is kept, requires the word `DELETE`
to be typed, and reuses the Runiac destructive-confirmation dialog introduced at `1fbc59a3`. On
success the client signs out and returns to the auth screen. All copy is English.

The hosted `/legal/account-deletion` page (separate `website/` repository) is updated from
"email us" to the in-app path plus the retention statement, so the app and the Play listing agree.

## Allowed Scope

- New `functions/src/account/` module: deletion core, callable, trigger.
- `functions/src/index.ts` export wiring and `functions/package.json` test-script registration.
- `firestore.rules`: deny `accountDeletionCommands` outright; add `deleting` to the blocking
  account statuses.
- `functions/test/accountDeletion.test.ts` and the Firestore rules suite additions.
- The named Flutter Account/profile files and their widget test.
- This capsule document, the `CURRENT.md` routing anchor, and the two governance-checker
  allowlist branches.

## Forbidden Scope

- Any production `runiac-fypp` deploy. It requires separate explicit authorization.
- Any grace period, restore path, scheduled deletion sweep, or "pending deletion" sign-in state.
- Any newsletter (`newsletterSubscribers`, `newsletterCampaigns`, `mail`) change.
- Any `adminAuditLogs` rewrite.
- Any XP, level, rank, streak, or leaderboard *calculation* change. Deletion removes and
  anonymizes records; it never recomputes a score.
- Any client-side deletion of a backend-owned document, and any client-side computation of a
  backend-owned value.
- New dependencies or secrets.
- Repo-wide `dart format`.
- Any edit, staging, or commit inside the isolated `adaptive-character-guidance` worktree.
- Any commit or push without explicit authorization.

## Exact Target Files

- `functions/src/account/accountDeletionInventory.ts` (new)
- `functions/src/account/accountDeletionCore.ts` (new)
- `functions/src/account/accountChallengeExit.ts` (new)
- `functions/src/account/accountDeletionCommandTypes.ts` (new)
- `functions/src/account/requestAccountDeletion.ts` (new)
- `functions/src/account/accountDeletionCommand.ts` (new)
- `functions/src/challenge/challengePremiumLapse.ts` (exports and parameterizes the eviction core)
- `functions/src/challenge/challengeTypes.ts` (`OWNER_ACCOUNT_DELETED`)
- `functions/src/security/accountStatus.ts`
- `functions/src/index.ts`
- `functions/package.json`
- `firestore.rules`
- `functions/test/accountDeletion.test.ts` (new)
- `functions/test/feedCallableSurface.test.ts` (the exported-surface allow-list)
- `tests/firebase-rules/accountDeletion.firestore.rules.test.mjs` (new)
- `tests/firebase-rules/package.json`
- `implementation/mobile/runiac_app/test/account_profile_manage_routing_test.dart` (row count)
- `implementation/mobile/runiac_app/lib/features/profile/presentation/delete_account_screen.dart` (new)
- `implementation/mobile/runiac_app/lib/features/profile/presentation/widgets/account_delete_row.dart` (new)
- `implementation/mobile/runiac_app/lib/features/profile/data/firebase_account_deletion_repository.dart` (new)
- `implementation/mobile/runiac_app/lib/features/profile/presentation/widgets/account_profile_sections.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/qa/delete_account_qa_launcher.dart` (new)
- `implementation/mobile/runiac_app/lib/main.dart` (QA surface dispatch)
- `implementation/mobile/runiac_app/test/delete_account_flow_test.dart` (new)
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh`
- `tools/governance-ci/check-pre-scaffold-scope.sh`

## Required Tests

- Emulator-first Functions suite covering: the full inventory is erased for a seeded account; a
  replayed trigger is a no-op; `reports`/`feedback` survive with `deleted-user`; the nickname is
  reclaimable by another account afterwards; an in-flight challenge is exited rather than
  corrupted; the durable avatar object is removed; the Auth user is gone at the end.
- Firestore rules suite: `accountDeletionCommands` denied to every client; `accountStatus:
  'deleting'` blocks the same writes `suspended` does.
- Flutter widget test: the row is present, the typed confirmation gates the call, and a failure
  surfaces a message instead of signing the user out.

## Required Validation

- ADR-002 emulator-first. No fixture mutation outside the guarded emulator project.
- ADR-003 Backend Guarded Lane review (A11_FIREBASE_IMPL, A13_SECURITY_RULES, A12_QA_TEST).
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `flutter analyze` and the focused Flutter tests.

## Required Evidence

Recorded 2026-08-04 Asia/Singapore, all against the emulator (ADR-002):

- `npm test` (Functions, full): **742 / 134 / 25 / 219 / 34 = 1154 pass, 0 fail**, including the new
  `accountDeletion.test.js` at 26 tests.
- `tests/firebase-rules` (full): **160 pass, 0 fail** (was 154 before this capsule).
- `flutter analyze`: clean. `flutter test --no-pub` (full): **2704 pass, 0 fail**, including the new
  `delete_account_flow_test.dart` at 8 tests.
- `check-diff-hygiene` and `check-pre-scaffold-scope`: PASS.
- Simulator evidence: **produced** on the booted iPhone 17 (iOS 26.5), driven through `idb`, using a
  new `RUNIAC_QA_SURFACE=delete_account` launcher that renders the real screen against a stub
  repository. Verified: the screen renders and scrolls; the submit button stays inert until `DELETE`
  is typed exactly (it stayed inert for a mistyped value, which the simulator supplied for free by
  being in Hangul input mode); the confirmation dialog appears; the success path signs out and pops
  the screen; the failure path keeps the runner on the screen with a retryable error notice. The
  end-to-end path against the real callable is NOT covered, because the backend is undeployed and
  because exercising it for real means destroying a real account.

### Two visual defects found on device and fixed

Neither was reachable by a widget test, and both were found only by looking at the running app.

1. **The in-flight spinner was nearly invisible.** The button is disabled in two different
   situations — before `DELETE` is typed, and while the request is in flight — and both were
   drawing the same grey `disabledBackgroundColor`, so the white `CircularProgressIndicator` sat on
   a light grey fill at almost no contrast. The loading state now uses a dimmed red fill, which
   keeps the spinner legible and keeps the button reading as armed rather than switched off.
2. **`Delete forever` wrapped onto two lines** in the shared confirmation dialog, which gives both
   buttons an equal half width, while `Cancel` stayed on one. Changed to `Delete now`, which fits on
   one line and states the immediacy the whole screen is built around. The shared dialog widget
   itself was not touched, since it is used by Friends and the notification inbox too.

### One flake found and fixed, not written off

The first full-suite run failed `account deletion challenge exit` while the same code passed in
isolation. Root cause, reproduced by reasoning about the group configuration and then closed: the
main `npm test` group starts the **Functions** emulator, so `functions/src/index.ts` is live. The
moment `requestAccountDeletion` creates `accountDeletionCommands/{uid}` — which its own tests do
three times — the real `accountDeletionCommandCreated` trigger fires and begins a genuine fan-out
for that uid, in parallel and outside the test's control. Deleting the command document in
`beforeEach` does not stop an execution already in flight, so with a shared subject uid that stray
fan-out landed inside a later test and erased fixtures it had just seeded.

Fixed by giving every test a unique subject uid, which makes the stray work harmless: it converges
on an account nobody is looking at any more. The one assertion that genuinely could not survive two
concurrent fan-outs — an exact per-step row count in the trigger test — was replaced with the
race-stable end-state assertions and the reason recorded inline; exact counts stay in the direct
fan-out tests, where nothing races. Verified with three consecutive runs under the Functions
emulator plus two full-suite runs, all green.

## Rollback Conditions

- Any fan-out step that cannot be made idempotent on replay.
- Any evidence that the erase stage can leave an account signed-in or its data partially readable.
- Any Auth deletion occurring before the Firestore fan-out has converged.

## Deliberately not done, and why

- **The hosted `/legal/account-deletion` page still describes the email request path only.** It
  lives in the separate, git-ignored `website/` repository and ships through its own PR and Vercel
  deployment, so it cannot be part of this commit. Until it is updated, the app and the Play listing
  disagree about how deletion works. This is the one outstanding item before the store-policy claim
  is actually true end to end.
- **No production deploy.** `requestAccountDeletion` and `accountDeletionCommandCreated` are new
  exports and are inert in production until a separately authorized deploy ships them, together with
  `firestore.rules` (which the deploy replaces wholesale — check the live ruleset diff first, per
  `implementation/release/`).
- **No device QA.** Owner-held.

## Exit Criteria

- [x] Target files completed.
- [x] Required tests or validation completed.
- [x] Required evidence recorded.
- [ ] Snapshot updated if state changed.
- [x] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
