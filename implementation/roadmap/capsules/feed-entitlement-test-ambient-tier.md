# Feed Entitlement Test Ambient Tier

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested CI fix. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-06 Asia/Singapore after `main` was found red on the hosted
`backend-emulator-tests` job. The failure predates the commit that surfaced it.

## Goal

Make `rejects a Basic subscriber from publishing to Feed and writes nothing (premium entitlement
gate)` test the gate it names instead of inheriting whatever tier the shipped default happens to
carry.

## Background — the mechanism

Hosted run `31080194069` (push of `297f890f`):

```
✓ governance-ci            7m7s
✗ backend-emulator-tests   4m55s   Run Functions emulator suites (main, feed, ...)
✓ mobile-integration-tests 11m46s
```

The main suite passed 742/742. The failure was in `npm run test:feed`, 133/134:

```
not ok 6 - rejects a Basic subscriber from publishing to Feed and writes nothing
  error: 'a Basic user must not be able to publish to Feed'
  expected: false   actual: true   operator: strictEqual
```

**This is not a regression from `297f890f`.** The immediately preceding run `30990224664`, for
`4287e786 fix(config): make the shareRouteToFeed default match production`, failed on the same
assertion with the same counts. `4287e786` is the cause.

That commit moved `DEFAULT_FEATURE_ACCESS_CONFIG.features.shareRouteToFeed.minimumTier` from
`"premium"` to `"basic"` — correctly, because the stored `config/featureAccess` document has held
`"basic"` since 2026-07-25 and `deepMerge` gives the stored value precedence, so the old default
described an environment that does not exist. The emulator project has no stored document, so it
falls back to the default; the default is now `"basic"`; publishing therefore succeeds and
`result.ok` is `true`.

The gate itself is intact and unchanged. What broke is that the test never provisioned the
condition it asserts — it read the tier ambiently. `4287e786` even updated the `setupProfiles()`
comment in this same file to acknowledge the new default, but did not follow the consequence into
the test twenty lines below.

## Allowed Scope

- In `functions/test/feedEmulatorIntegration.test.ts`: write `config/featureAccess` pinning
  `shareRouteToFeed` to `minimumTier: "premium"` before the call, assert inside a `try`, and delete
  the document in a `finally`.
- Correct the `setupProfiles()` comment, which describes the Basic test's dependency inaccurately
  now that the tier is pinned.
- This capsule, the `implementation/roadmap/CURRENT.md` routing anchor, and the checker predicate.

## Forbidden Scope

- **No `functions/src/` change.** The entitlement gate is correct; the default is correct and
  matches production. Only the test's provisioning was wrong.
- No weakening or deletion of the assertion. Inverting it to expect success would delete the
  coverage of a premium entitlement path rather than repair it — the gate must keep being proven to
  refuse a Basic subscriber when the tier demands Premium.
- No change to `DEFAULT_FEATURE_ACCESS_CONFIG` or to the stored production document.
- No production service, deploy, or secret action.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line.

## Why pin the config rather than pin the default

Reverting the default would re-break the thing `4287e786` fixed, and asserting whatever the default
currently says would leave the test re-breaking every time an admin flips a console tier — a tier
that is deliberately console-flippable at runtime. Pinning inside the test states the precondition
the assertion depends on, which is what makes the test a statement about the gate rather than about
the configuration.

The write is safe against neighbouring tests: `loadFeatureAccessConfig` re-reads the document on
every call with no caching, `test:feed` runs with `--test-concurrency=1`, and the `finally` removes
the pin so no later publish in the project inherits a Premium requirement.

## Exact Target Files

- `implementation/roadmap/capsules/feed-entitlement-test-ambient-tier.md`
- `implementation/roadmap/CURRENT.md`
- `functions/test/feedEmulatorIntegration.test.ts`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)

## Required Tests

- `npm run test:feed` passes locally with the Functions/Firestore/Auth/Storage emulators.

## Required Validation

- `functions` typecheck clean (`tsc --noEmit`).
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.

## Evidence (2026-08-06)

**Before** — hosted, on two consecutive commits, identical:

```
run 30990224664 (4287e786):  # tests 134 / # pass 133 / # fail 1
run 31080194069 (297f890f):  # tests 134 / # pass 133 / # fail 1
  not ok 6 - rejects a Basic subscriber from publishing to Feed and writes nothing
```

**After** — local `npm run test:feed` under JDK 21:

```
ok 6 - rejects a Basic subscriber from publishing to Feed and writes nothing (premium entitlement gate)
# tests 134
# pass 134
# fail 0
```

The pin is what flips the outcome: the assertion and the gate are byte-identical to the failing
run, and the only change is that the test now provisions the tier it asserts against. That the
result moved from fail to pass on that change alone is the proof the config write reaches the
Functions runtime.

`npx tsc --noEmit` in `functions/` — exit 0. `./tools/governance-ci/run-all-checks.sh` — all
sixteen checks PASS, zero findings.
