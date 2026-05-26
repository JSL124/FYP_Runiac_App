# github-actions-governance-ci-baseline

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

CI/governance documentation + workflow capsule.

## Status

Status: Closed.

Routed on: 2026-05-26 Asia/Singapore.

Completed on: 2026-05-26 Asia/Singapore.

Completion evidence commit target: `ci: add governance checks workflow`.

Completion review:

- A9_TRACE PASS.
- A6_REVIEW PASS.
- A12_QA_TEST PASS.
- A8_OUTPUT_CHECKER PASS.
- `git diff --check` PASS.
- Governance CI PASS.
- Local YAML inspection PASS.
- GitHub-hosted Actions run verification pending post-push inspection.

This capsule is closed. Do not add further work to it.

## Required Agent Chain

```text
A0_ORCH -> A9_TRACE -> A6_REVIEW -> A12_QA_TEST -> A8_OUTPUT_CHECKER
```

## Goal

Add a minimal GitHub Actions workflow for existing governance checks.

## Allowed Scope

- `.github/workflows/governance-ci.yml`
- `implementation/roadmap/CURRENT.md`
- `implementation/roadmap/snapshots/latest.md`
- `implementation/roadmap/capsules/github-actions-governance-ci-baseline.md`
- Exact Governance CI allowlist update only if required for the approved new files

## Forbidden Scope

- No Flutter SDK setup.
- No Flutter analyze/test in Actions.
- No `flutter pub get`.
- No Android/iOS build.
- No Firebase.
- No secrets.
- No deployment.
- No environment variables.
- No product code changes.
- No Phase 02 selection.
- No new product capsule selection.

## Workflow Requirements

- Run on push to `main`.
- Run on pull request to `main`.
- Use `ubuntu-latest`.
- Check out the repository.
- Run `git diff --check`.
- Run `./tools/governance-ci/run-all-checks.sh`.
- Do not add Flutter setup, dependency caching, artifact upload, deployment, branch protection changes, secrets, or environment variables.

## Validation

- `git diff --check`
- `./tools/governance-ci/run-all-checks.sh`
- Local inspection of YAML
- Final Git status
- GitHub Actions run verification after push is a separate follow-up unless accessible in this session

## Done Criteria

- [x] Workflow file added.
- [x] Local governance checks pass.
- [x] Roadmap closure recorded.
- [ ] Committed and pushed.
- [ ] Final local working tree clean.

## Evidence

- Initial `git status --short`: no output.
- Initial `git status -sb`: `## main...origin/main`.
- Initial `git log --oneline -5` latest entry: `2bd4548 feat(mobile): align premium home dashboard static UI`.
- Existing workflow directory inspection: `.github` did not exist before this capsule.
- Workflow added at `.github/workflows/governance-ci.yml`.
- Workflow scope: push to `main`, pull request to `main`, `permissions: contents: read`, `ubuntu-latest`, `actions/checkout@v4`, `git diff --check`, and `./tools/governance-ci/run-all-checks.sh`.
- Governance CI exact allowlist was updated only for `.github/workflows/governance-ci.yml` and `implementation/roadmap/capsules/github-actions-governance-ci-baseline.md`.
- Local YAML inspection confirmed no Flutter SDK setup, no `flutter pub get`, no Flutter analyze/test, no Android/iOS build, no Firebase, no secrets, no environment variables, no deployment, no dependency caching, no artifact upload, and no branch protection changes.
- First `git diff --check`: no output.
- First `./tools/governance-ci/run-all-checks.sh`: `All Governance CI checks passed.`
- First `git status --short`: only approved files changed.
- Closure edit returned `CURRENT.md` active capsule to none selected and kept Phase 02 unselected.
- GitHub Actions run result is not claimed in this local closure evidence; it requires post-push hosted run inspection.

## Rollback Conditions

Stop and do not close this capsule if the work:

- Adds Flutter SDK setup, `flutter pub get`, Flutter analyze/test, Android/iOS build, Firebase, secrets, deployment, or environment variables to GitHub Actions.
- Modifies Flutter product code, Firebase/backend files, native platform files, dependency files, or generated files.
- Selects Phase 02 or a product implementation capsule.
- Fails required local validation.
