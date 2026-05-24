# Runiac Agent Review TODO

Implementation remains user-approved only. The pipeline may prepare plans, reviews, and decisions, but it must not implement, commit, push, test, build, deploy, run Flutter, run Firebase, or run npm.

## Current Completed Milestones

- [x] Local agent-review scaffold created
- [x] Codex exec compatibility fixed
- [x] Claude CLI compatibility fixed
- [x] Authenticated Claude print mode working
- [x] Manual plan/review/decision workflow tested
- [x] Pipeline subcommand added
- [x] Pipeline actual run tested
- [x] Pipeline traceability records committed
- [x] Generic core + Runiac profile migration completed
- [x] `REVIEW_MODE=standard|lite` implemented and tested
- [x] Claude review cost caps implemented and tested:
  - `CLAUDE_MAX_TURNS`
  - `CLAUDE_MAX_BUDGET_USD`
- [x] Claude read protection guardrails added through `.claude/settings.json`
- [x] Generic context selection protocol documented
- [x] `context-policy.yml` schema files added for:
  - `tools/agent-review/profiles/generic/context-policy.yml`
  - `tools/agent-review/profiles/runiac/context-policy.yml`
- [x] `REVIEW_ENABLED` on/off policy documented
- [x] `REVIEW_ENABLED` runner support implemented:
  - `REVIEW_ENABLED=1` keeps existing Claude review behavior
  - `REVIEW_ENABLED=0` skips external review with `SKIP_REASON`
  - skipped-review artifact is created
  - Codex final decision still runs
- [x] `REVIEW_ENABLED=0` actual smoke test passed:
  - Codex plan was created
  - Claude review was skipped
  - `_external_review_skipped.md` artifact was created
  - Codex decision completed
  - implementation was not run
- [x] `REVIEW_ENABLED=1` lite dry-run regression passed

## Completed Recently

- [x] Future context packet builder design drafted in documentation
- [x] `inventory_limits` added to generic and Runiac `context-policy.yml` files
- [x] Future `build_context_packet.sh` design documented in `tools/agent-review/README.md`

## Current Important Limits

- [ ] `build_context_packet.sh` is not implemented yet
- [ ] `run_plan_review.sh` does not read `context-policy.yml` yet
- [ ] Context packet runner integration has not started
- [ ] Flutter/Firebase implementation has not started

## Next Planned Steps

- [ ] Commit `inventory_limits` YAML policy changes
- [ ] Commit future context packet builder design documentation
- [ ] Implement standalone `build_context_packet.sh`
- [ ] Test standalone context packet builder
- [ ] Only after standalone validation, consider runner integration

## Later Efficiency Work

- [ ] Defer `REVIEW_PROVIDER=codex`
- [ ] Defer `DECISION_POLICY=if-needed`
- [ ] Defer Codex fallback reviewer

## Phase 1 Runiac Implementation Preparation

- [ ] Create `implementation/traceability/requirements-map.md` later
- [ ] Create `implementation/traceability/setup-gates.md` later
- [ ] Verify submitted PDD PDF readable text first
- [ ] Compare submitted PDD baseline with `docs/pdd/` only for implementation-relevant deltas
- [ ] Map MVP features F1, F2, F3, F4, F6, F9
- [ ] Mark deferred features F5, F7, F8, F10 unless user decides otherwise
- [ ] Clarify expert/admin governance scope

## Do Not Do Yet

- [ ] Do not run `flutter create`
- [ ] Do not run `firebase init`
- [ ] Do not run `npm`
- [ ] Do not run tests
- [ ] Do not run builds
- [ ] Do not run deployment
- [ ] Do not create `firebase/functions`
- [ ] Do not create `firebase/firestore`
- [ ] Do not create `pubspec.yaml`
- [ ] Do not create `firebase.json`
- [ ] Do not create `package.json`
- [ ] Do not create Firestore rules
- [ ] Do not create Storage rules
- [ ] Do not create GitHub Actions
- [ ] Do not create production source code

## Next Codex Prompt Topic

Commit current context policy/design documentation changes, then implement standalone `build_context_packet.sh` only after the committed documentation baseline is clean.
