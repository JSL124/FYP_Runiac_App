# Repository Consolidation — Quality Gates

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested governance/CI consolidation capsule under ADR-003 Governance Lite Execution
Lanes. No Phase 02 selection is implied or authorized by this capsule.

## Status

Routed on 2026-07-31 Asia/Singapore. This capsule carries the CI-gate half of a repository
consolidation effort whose goal is to prove the already-implemented product as one coherent
system rather than to add features.

## Goal

Close two verification holes in governance CI, both of which are cheap and both of which guard
against a failure mode that has already occurred once in this repository:

1. A cross-system drift guard that exists in the tree but has no execution path.
2. Test suites that are enumerated by filename and therefore vanish silently when the
   enumeration is not updated.

## Background — why these two

**paywall drift is the only unguarded contract of its family.** `tests/cross-system/` holds
three drift guards. `config-contract-drift.mjs` and `avatar-path-contract-drift.mjs` are each
wired into `run-all-checks.sh` through a `tests/governance/*.sh` wrapper.
`paywall-config-drift.mjs` has no wrapper and no execution path, so `config/paywall` drift
between the Dart read model, the website admin editor, and the fixture is currently unguarded.

Note on reach: the script already handles an absent `website/` checkout by printing a loud SKIP
and exiting 0 (`paywall-config-drift.mjs:117-125`). Since `website/` is gitignored at the repo
root, wiring this in gives **local** protection plus a visible SKIP line in hosted CI — not
full hosted protection. The fixture-to-Dart half of the contract is already covered in hosted
CI by `implementation/mobile/runiac_app/test/paywall_config_defaults_fixture_test.dart`. This
asymmetry is intentional and recorded rather than hidden.

**Enumeration drift has already bitten.** `capsules/review-triage-notification-privacy-quota.md`
fix #8 records that `friends.firestore.rules.test.mjs` had never executed in CI because it was
missing from the explicit suite list in `tests/firebase-rules/package.json`. The same shape of
risk is live today: `functions/package.json` enumerates its suites by filename across five
scripts (`test`, `test:feed`, `test:moderation`, `test:challenge`, `test:friends`) and
`tests/firebase-rules/package.json` across two. A suite omitted from those lists silently never
runs, and nothing currently detects that.

## Allowed Scope

- Add `tests/governance/paywall_config_drift_test.sh` mirroring the two existing wrappers, and
  register it in `tools/governance-ci/run-all-checks.sh`.
- Add `tools/governance-ci/check-test-enumeration.sh`, which reconciles the enumerated suite
  lists against the test files present on disk, and register it.
- Where the two checkers must be taught this capsule's paths, add the routing predicate pair in
  the established `is_<capsule>_capsule_active` / `is_<capsule>_path` form.
- Update this capsule document and `implementation/roadmap/CURRENT.md` routing.

## Forbidden Scope

- No production service, deploy, secret, or credential action.
- No Phase 02 selection.
- No change to any `- Newly routed …` or `- Current active capsule …` line already present in
  `CURRENT.md`. Those are capability grants parsed by the checkers; this capsule appends one new
  routing line and touches no existing one.
- No change to the drift `.mjs` bodies themselves — this capsule adds execution paths, not new
  contract logic.
- No functions/ or Flutter source changes. The mobile integration-test CI job is deliberately
  left to a later stage because it needs device-tier work.
- No automatic staging or commit.

## Exact Target Files

- `implementation/roadmap/capsules/repository-consolidation-quality-gates.md`
- `implementation/roadmap/CURRENT.md`
- `tests/governance/paywall_config_drift_test.sh`
- `tools/governance-ci/check-test-enumeration.sh`
- `tools/governance-ci/run-all-checks.sh`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only, if required)
- `tools/governance-ci/check-pre-scaffold-scope.sh` (routing predicate only, if required)

## Required Tests

No new unit tests. Each gate is validated by a negative-control demonstration, which is the
appropriate test for a checker:

- paywall wrapper: mutate `tests/cross-system/fixtures/paywall-config-defaults.json`, confirm
  the wrapper exits non-zero, restore, confirm it exits zero.
- enumeration check: remove one suite from an enumeration list, confirm FAIL, restore, confirm
  PASS. Also confirm a registered intentional-standalone exception does not produce a false
  positive.

## Required Validation

- `./tools/governance-ci/run-all-checks.sh` PASS with both new checks registered.
- `git diff --check` clean.
- The `CURRENT.md` anchor set is unchanged in count: 39 `- Newly routed` lines before this
  capsule's routing line is appended, 40 after; exactly 1 `- Current active capsule` line
  throughout.
- A13_SECURITY_RULES review, because 2a guards paid-tier configuration and 2b guards whether
  security-rules suites execute at all.

## Required Evidence

- Negative-control logs for both gates (FAIL then restored PASS).
- `run-all-checks.sh` output showing both new checks listed and passing.
- The hosted CI run URL after push.

## Rollback Conditions

- Revert if either new check proves flaky, or if it fails for reasons unrelated to real drift.
- Revert if adding a routing predicate to either checker changes the outcome for any path
  outside this capsule's Exact Target Files.
- Stop and re-route if the work is found to require functions/ or Flutter source changes.

## Exit Criteria

- [ ] Both gates registered in `run-all-checks.sh` and passing.
- [ ] Negative-control demonstration recorded for each.
- [ ] Anchor-count invariance verified.
- [ ] Governance CI PASS locally; hosted CI green after push.
- [ ] `CURRENT.md` routing appended without disturbing existing anchors.
