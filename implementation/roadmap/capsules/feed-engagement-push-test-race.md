# Feed Engagement Push Test Race

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested test-reliability fix. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-07-31 Asia/Singapore after the flake was observed failing hosted CI on PR #57, a
documentation-only change that could not have caused it.

## Goal

Remove a harness race in `functions/test/feedEngagementNotifications.test.ts` that makes two push
fan-out assertions fail intermittently. This is a test-harness defect, not a product bug — no
`functions/src/` change is in scope.

## Background — the mechanism

Observed in hosted CI run `30624921198`:

```
not ok 4 - sends a push to every enabled token on a written (first) comment
  expected: 2
  actual: 0
```

Re-running the identical commit passed, which confirms non-determinism rather than a regression.

These emulator tests run against `demo-runiac-feed` with the Functions emulator enabled, so
writing `feedPosts/{postId}/comments/{commentId}` fires the **real** `feedCommentCreated` trigger.
That trigger and the test's own direct `emitFeedCommentNotification` call both target the same
`notificationInbox` document, and the writer's exactly-once guard is a transactional
exists-check + create (`engagementNotifications.ts:242`).

Whichever arrives first gets `"written"`; the loser gets `"duplicate"`. Push rides that result —
`if (writeStatus !== "written") return;` — so when the trigger wins, the direct call sends nothing
and an assertion of 2 observes 0.

The log line that made this visible is the trigger's own failed send:
`[engagementPush] token send failed fp-1 FirebaseAppError: Credential implementation ... failed to
fetch a valid Google OAuth2 access token`. There is no FCM emulator, so the trigger's real send
always fails in CI — harmless in itself, but it proves the trigger ran and reached the push stage,
which is only possible if it had already claimed the inbox document.

`emitFeedLikeNotification` has the identical shape, so the like variant carries the same race and
had simply been winning.

## Allowed Scope

- Add a `stubWriter` helper to `functions/test/feedEngagementNotifications.test.ts` returning a
  fixed `FeedEngagementNotificationWriteStatus`, following the existing `throwingWriter` idiom
  already in that file.
- Inject `stubWriter("written")` into the two push fan-out tests so the assertion depends on the
  contract under test rather than on which writer arrives first.
- Correct the setup comment on the duplicate-suppression test, which asserts a state that may have
  been established by the trigger rather than by its own first call.
- Update this capsule document and `implementation/roadmap/CURRENT.md` routing.

## Forbidden Scope

- **No `functions/src/` change.** The product behaviour — push riding the writer's exactly-once
  result — is correct and is what the tests are meant to verify.
- No change to the assertions themselves. Weakening `assert.equal(sent.length, 2)` would hide the
  contract instead of testing it.
- No change to the duplicate-suppression test's logic. It is not flaky: whether the trigger or the
  setup call establishes the already-notified state, the assertion holds. Only its explanatory
  comment was inaccurate.
- No production service, deploy, or secret action. No Phase 02 selection.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line.

## Why injection rather than serialising against the trigger

Waiting for the trigger and then clearing the inbox document would also work, but it trades one
timing dependency for another and leaves the test asserting two things at once.

Injecting the writer isolates the unit actually under test — *given a `"written"` result, push to
every enabled token* — and the real writer's exactly-once behaviour keeps its own dedicated
coverage in the `firestoreFeedEngagementNotificationWriter dedup` suite. Nothing is lost.

## Exact Target Files

- `implementation/roadmap/capsules/feed-engagement-push-test-race.md`
- `implementation/roadmap/CURRENT.md`
- `functions/test/feedEngagementNotifications.test.ts`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)
- `tools/governance-ci/check-pre-scaffold-scope.sh` (routing predicate only, if required)

## Required Tests

- `npm run test:feed` in `functions/` passes locally.
- Because the defect is intermittent, a single green run is not sufficient evidence. The suite is
  run repeatedly and the result recorded.

## Required Validation

- `functions` typecheck clean (`tsc --noEmit`).
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- `CURRENT.md` anchors: 42 `- Newly routed` before this capsule's line is appended, 43 after;
  exactly 1 `- Current active capsule` throughout.
- A12_QA_TEST, since the deliverable is test reliability.

## Required Evidence

- The failing CI run and its assertion output, recorded above.
- The passing re-run of the identical commit, establishing non-determinism.
- Repeated local runs of `npm run test:feed` after the fix.

## Evidence (2026-07-31)

**Before — hosted CI run `30624921198`, PR #57 (documentation only):**

```
not ok 4 - sends a push to every enabled token on a written (first) comment
  location: 'functions/lib/test/feedEngagementNotifications.test.js:539:5'
  expected: 2
  actual: 0
  operator: 'strictEqual'
# tests 134 / pass 133 / fail 1
```

Accompanied by the trigger's own send attempt, which is what proves the trigger had already
claimed the inbox document:

```
i functions: Beginning execution of "asia-southeast1-feedCommentCreated"
# [engagementPush] token send failed fp-1 FirebaseAppError: Credential implementation
  provided to initializeApp() ... failed to fetch a valid Google OAuth2 access token
```

**Non-determinism confirmed:** re-running the identical commit with no code change passed
(`backend-emulator-tests` 6m47s).

**After — local `npm run test:feed`, four consecutive runs:**

```
run 1: # pass 134  # fail 0
run 2: # pass 134  # fail 0
run 3: # pass 134  # fail 0
run 4: # pass 134  # fail 0
```

`tsc --noEmit` clean. `./tools/governance-ci/run-all-checks.sh` PASS.

Four runs cannot prove absence of a race. What supports the fix is the mechanism rather than the
count: the assertion no longer depends on which caller reaches the inbox document first, because
the writer result is now supplied directly instead of being competed for.

## Rollback Conditions

- Revert if the fix requires touching `functions/src/`.
- Revert if repeated runs still show intermittent failure, which would mean the race was
  misdiagnosed.

## Exit Criteria

- [ ] `stubWriter` added and injected into both push fan-out tests.
- [ ] Duplicate-test setup comment corrected.
- [ ] `npm run test:feed` green across repeated runs.
- [ ] Governance CI PASS locally; hosted CI green after push.
