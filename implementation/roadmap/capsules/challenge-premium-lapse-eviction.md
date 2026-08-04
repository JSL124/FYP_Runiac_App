# Challenge Premium-Lapse Eviction

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested Backend Guarded Lane full-stack capsule (ADR-002 emulator-first, ADR-003 lane
rules). No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-04 Asia/Singapore. Implemented test-first at the user's explicit instruction
("TDD 방식으로 possible한 case들에 대한 test들을 우선 만들고 구현 시작해").

## Goal

Make a premium-only Challenge tier stay premium for as long as it is being run, instead of only
at the instant it is created. A runner who drops to Basic mid-challenge gets a 24-hour grace
window with an in-app warning and a paywall; if they are still Basic when it expires they are
removed from the challenge, and an owner's removal transfers ownership to a remaining eligible
member rather than destroying everyone else's progress.

## Background — what exists today

The premium gate is a **single check at lobby creation**. `createChallengeLobbyForCallable`
(`functions/src/challenge/challengeLobbyCore.ts:259-264`) reads `users/{uid}` and throws
`PREMIUM_REQUIRED` when the tier appears in `config/challengeAccess.premiumOnlyTiers`. The
comment immediately above it (lines 247-256) states the consequence plainly:

> Only lobby CREATION is gated: invited friends may join a premium owner's lobby regardless of
> their own tier, and an owner whose subscription lapses after creation keeps the already-created
> lobby.

Nothing else in the challenge system reads subscription state. Grepping `functions/src/challenge/`
for `premium`/`subscriptionStatus` matches only `challengeLobbyCore.ts` and the
`PREMIUM_REQUIRED` constant in `challengeErrors.ts` — `challengeContribution.ts`,
`challengeSettlementCore.ts` and `challengeExpiry.ts` have no entitlement check at all, so a
downgraded runner keeps accruing metres and is awarded the badge on settlement.
`firestore.rules:1108-1124` scopes `challengeInstances` and its `participants` subcollection by
`rosterUids` membership, never by `isPremiumUser()`, so rules do not gate it either.

Neither downgrade path touches challenges: `runSubscriptionExpirySweep`
(`functions/src/progression/subscriptionExpiryCore.ts:146-176`) writes only the subscription
fields on `users`/`userProfiles` plus an `adminAuditLogs` entry, and the admin console's
`setUserSubscription` (separate `website/` repo) is an Admin-SDK write with no challenge
side effect.

## User decisions of record (2026-08-04 Asia/Singapore)

Four design questions were put to the user before any code was written. The answers are binding
scope for this capsule:

1. **Membership requires premium too.** "Premium challenge는 초대받을 수 있는 멤버도 premium이어야
   해." The gate extends from creation to acceptance.
2. **Owner lapse transfers ownership.** "만약에 owner가 premium을 잃어버리면 소유권은 남은 멤버에게
   이양이 될거야." Cancelling everyone else's challenge because the owner stopped paying was
   explicitly rejected.
3. **24-hour grace, warned in-app, reversible.** "Premium에서 basic으로 내려간 시점에서 24시간
   유예기간을 주자 그 사이에 Premium으로 다시 재구독하면 다시 재진입이 가능하게", and during the
   window the app tells the user they may be removed and shows the paywall.
4. **Detection is shared-core + sweep + trigger.** The admin console cannot call callables, so a
   `users/{uid}` update trigger is the only way to observe an admin-driven downgrade; the sweep
   calls the same core so a trigger failure still converges.

## Design

### The hold document

New **client-denied** top-level collection `challengePremiumHolds/{uid}`:

```
{ uid, challengeId, tierId, role, lapsedAt: Timestamp, graceExpiresAt: Timestamp }
```

Keyed by uid because `challengeSlots/{uid}` already guarantees at most one live challenge per
user, so one hold per user is sufficient and no fan-out query over participants is needed.

It is a separate collection rather than two fields on the participant document **for privacy**.
`challengeInstances/{id}/participants/{uid}` is readable by every roster member
(`firestore.rules:1117-1122`), so storing the lapse there would broadcast one runner's
subscription state to everyone else in their challenge. `firestore.rules` denies all client
access to the hold collection; the caller learns about their **own** hold only through the
`getActiveChallenge` callable response.

### Grace constant

`PREMIUM_LAPSE_GRACE_MS = 24 * 60 * 60 * 1000`, a module constant in
`functions/src/challenge/challengePremiumLapse.ts`. Deliberately **not** a
`config/challengeAccess` field: adding one would require mirroring the validator into the
separate `website/` repo and through `tests/cross-system/config-contract-drift.mjs`. The user
specified a fixed 24 hours; promoting it to config later is a separate, additive change.

### Core operations

`functions/src/challenge/challengePremiumLapse.ts`:

- `syncChallengePremiumHold(firestore, uid, nowMs)` — the shared core. Opens a hold when the
  runner is now non-premium and holds a slot in a premium-only tier on a non-terminal instance;
  clears it when they are premium again, left the challenge, or the instance went terminal;
  otherwise no-ops. **Never extends an existing hold** — re-running it cannot push the deadline
  out, so a repeatedly-written `users/{uid}` document (`completeRun` writes it on every run)
  cannot make the grace window immortal.
- `runChallengePremiumLapseSweep(firestore, nowMs, options?)` — queries holds whose
  `graceExpiresAt <= now`, then evicts each in its own transaction that re-reads and re-asserts
  the predicate, exactly like `runSubscriptionExpirySweep` does, so a renewal committed between
  the query and the write wins instead of being clobbered.

### Eviction semantics

- **Member** — participant `status`/`result` = `LEFT`, slot released, `challengeHistory` doc
  written with `outcome: "LEFT"`. Identical to the existing `leaveChallenge` effects, so credited
  metres stay in `teamMeters` and reward eligibility stays `NOT_ELIGIBLE`. No badge.
- **Owner, eligible successor exists** — the earliest-joined non-terminal member who is currently
  premium and not themselves under a hold becomes the owner (`rosterUids` order is join order:
  owner first, then accept order). `instance.ownerUid`, the successor's participant `role` and
  their `challengeSlots/{uid}.role` all move to `owner` in the same transaction; the lapsed owner
  is then removed as an ordinary member.
- **Owner, no eligible successor** — the instance is cancelled for everyone with the new terminal
  reason `OWNER_PREMIUM_LAPSED`, reusing the existing abandon/lobby-expiry effects (participants
  `CANCELLED`, slots released, `PENDING` invitations `REVOKED`). This covers SOLO instances,
  which have no other member by construction.

### State machine

`transitionParticipant` gains a `REMOVE` action (`ACCEPTED|ACTIVE -> LEFT`, actor `system`).
`LEAVE`/`WITHDRAW` stay self-service and stay blocked for owners; `REMOVE` is not a self-exit and
so is not subject to the `OWNER_CANNOT_LEAVE` guard — but an owner only ever reaches it after
being demoted to `member` by the transfer above, so the guard's intent is preserved. Ownership
transfer itself is a field update, not an instance transition; the instance state is unchanged.
`ChallengeTerminalReason` gains `OWNER_PREMIUM_LAPSED`.

### Acceptance gate

`respondToChallengeInvitationForCallable` rejects an `accept` on a premium-only tier with the
existing `PREMIUM_REQUIRED` reason when the recipient is not premium. The **invite** path
(`inviteChallengeFriendsForCallable`) is deliberately left ungated: rejecting an invitation at
send time would tell the owner which of their friends is not paying. The recipient learns it
about themselves, at accept time, and sees their own paywall.

### Client surface

`getActiveChallenge` returns an additional `premiumHold: { graceExpiresAtMs } | null` for the
**caller only**, and the app renders a warning with the remaining time plus a "Keep Premium" CTA
into the existing paywall. The client never computes eviction state and never writes a hold.

## Allowed Scope

- `functions/src/challenge/challengePremiumLapse.ts` (new) — grace/eviction core.
- `functions/src/challenge/challengePremiumLapseTrigger.ts` (new) — `users/{uid}` onUpdate
  trigger that early-returns unless a subscription field actually changed.
- `functions/src/challenge/challengeTypes.ts`, `challengeStateMachine.ts` — the `REMOVE` action,
  the `OWNER_PREMIUM_LAPSED` terminal reason, and the hold document shape.
- `functions/src/challenge/challengeLobbyCore.ts` — the acceptance gate and the
  `getActiveChallenge` hold relay.
- `functions/src/challenge/challengeSettlementSchedule.ts` — calls the lapse sweep from the
  existing one-minute wrapper, so no new scheduled function is introduced.
- `functions/src/progression/subscriptionExpiryCore.ts` — calls the shared core after a
  materialised downgrade.
- `functions/src/index.ts`, `functions/package.json` — the one new trigger export and the new
  suite's registration in `test:challenge`.
- `functions/test/challengePremiumLapse.test.ts` (new) plus the existing
  `challengeStateMachine.test.ts`, `challengeLobby.test.ts`, `challengeCallableSurface.test.ts`.
- `firestore.rules` and `tests/firebase-rules/challenge.firestore.rules.test.mjs` — total client
  denial of `challengePremiumHolds`.
- The named Flutter challenge/paywall files under `implementation/mobile/runiac_app/` and their
  widget tests.
- This capsule document, its `implementation/roadmap/CURRENT.md` routing line, and the routing
  predicates in the two governance checkers.

## Forbidden Scope

- No production `runiac-fypp` deploy of any kind without separate explicit authorization. Nothing
  in this capsule has any production effect until such a deploy ships it.
- No XP, level, rank, streak, or leaderboard behaviour change. Eviction removes challenge
  participation only; it never reverses awarded XP or touches progression.
- No premium **advantage**. This capsule restricts access to premium-only challenge tiers, which
  is a paid-content gate; it does not change the scoring formula for anyone, in either direction.
- No badge revocation. A badge already granted by settlement stays granted; eviction only
  prevents earning a new one from the challenge the runner was removed from.
- No client-side computation or write of eviction state, hold state, or any backend-owned value.
- No change to the invite path's authorization, no new expert-plan/admin surface, no new
  dependency, no secret.
- No edit inside the isolated `adaptive-character-guidance` worktree.
- No staging or commit of the unrelated `run-payload-pace-consistency` working-tree changes that
  were already present when this capsule was routed.
- No commit, push, or PR without separate explicit authorization.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line in
  `implementation/roadmap/CURRENT.md`; this routing is strictly append-only.

## Validation performed (2026-08-04 Asia/Singapore)

- `tsc --noEmit` clean.
- `npm test` main emulator suite **716/716 pass**.
- `npm run test:feed` **134/134**, including the `feedCallableSurface` export-surface guard that
  now lists `challengeSubscriptionChanged`.
- `npm run test:moderation` **25/25**, `npm run test:friends` **34/34**.
- `npm run test:challenge` **218 pass / 1 fail**. The one failure is pre-existing and unrelated —
  see the section below.
- Firestore rules suite **154/154 pass**, including the two new cases proving
  `challengePremiumHolds` is unreadable and unwritable by every client (owner, lobby-mate, and
  outsider alike).
- `flutter analyze --no-pub` clean; `flutter test --no-pub` **2696/2696 pass**.
- `./tools/governance-ci/run-all-checks.sh` **PASS**, all ten checks.

### RED evidence, recorded before implementation

- Backend: 8 TypeScript errors naming exactly the missing surface — `premiumHold` absent from
  `ActiveChallengeView` (×3), `challengePremiumLapse.js` module not found, and `"REMOVE"` not
  assignable to `ParticipantAction["type"]` (×4).
- Client: `ChallengePremiumLapseBanner`, `ChallengePremiumHold`, `premiumLapseCta`,
  `premiumLapseImminentBody` all unresolved.

### Test-environment finding worth keeping

The first GREEN run failed one owner-transfer case for a reason that was not a product defect:
the suite runs with the Functions emulator on, so the real `challengeSubscriptionChanged` trigger
is live and reacts to `users/{uid}` **updates** by calling the same core with the REAL clock,
while the tests drive it with a fixed simulated clock. A trigger invocation that took 2.0s landed
between a test's `seedChallenge` and its own `syncChallengePremiumHold`, stamping a real-clock
deadline about four hours beyond the simulated sweep instant, so the owner was silently not due.
Fixed by having the suite's `setSubscription` helper delete-then-create rather than merge —
`onDocumentUpdated` does not fire for a create — which removes the race at its source without
weakening any assertion or touching the trigger. Recorded because any future emulator test that
writes `users/{uid}` faces the same interaction.

## Pre-existing failure NOT caused by this capsule

`functions/test/challengeContribution.test.ts` › `a same-session different-payload upload is
rejected and never credits` fails with `avgPaceSecondsPerKm is not consistent with
durationSeconds and distanceMeters`. Cause: commit `9111960f fix(run): reject run payloads whose
pace contradicts distance and duration` (the `run-payload-pace-consistency` capsule) added a
cross-field consistency check and repaired three fixtures in `completeRun.test.ts`, but this
fourth inconsistent fixture lives in the challenge suite, which that capsule's validation did not
run. The fixture builds a payload for 4000 m (`durationSeconds: 1200`, `avgPaceSecondsPerKm: 300`)
and then overrides `distanceMeters: 5000`, giving an implied pace of `1200 * 1000 / 5000 = 240`
against a submitted 300 — 60 s/km outside the 15 s/km tolerance — so the payload is now rejected
with `invalid-argument` before ever reaching the `already-exists` duplicate check the test exists
to prove.

Deliberately left unfixed here: it belongs to that capsule, and repairing it under this one would
quietly hide a gap in validation the owner of that work should see. The repair is one line —
override `avgPaceSecondsPerKm: 240` alongside the `distanceMeters: 5000`.

## Not verified

- No device or simulator QA. The grace banner and paywall CTA are covered by widget tests only;
  real-screen acceptance is user-owned and is not claimed.
- Nothing is deployed. The trigger `challengeSubscriptionChanged` does not exist in production, so
  until a separately authorized deploy ships it, an admin-console downgrade still has no challenge
  effect and no hold is ever opened.

## Rollback Conditions

- Revert if the `users/{uid}` trigger's invocation volume proves material — `completeRun` writes
  that document on every run, so the trigger fires far more often than subscriptions change. The
  sweep alone still converges for expiry-driven downgrades; only admin-console downgrades would
  regress to being missed.
- Revert if ownership transfer produces a state the settlement sweep cannot settle.

## Exit Criteria

- [x] Full case matrix written as failing tests before implementation (28 backend cases across
      sync/sweep, 4 acceptance-gate cases, 3 relay cases, 3 state-machine cases, 10 client cases).
- [x] Grace/eviction core, state machine edges, acceptance gate, relay, trigger and sweep hook
      implemented.
- [x] `challengePremiumHolds` denied to all clients in rules, with two rules-suite cases.
- [x] Flutter grace warning + paywall CTA with widget tests, plus the `OWNER_PREMIUM_LAPSED`
      terminal-reason parse case that would otherwise have thrown on every affected runner's
      history screen.
- [x] Full validation executed and reported, including the one pre-existing failure that is not
      this capsule's.
- [ ] Deploy — explicitly out of scope; a separate authorization is required.
