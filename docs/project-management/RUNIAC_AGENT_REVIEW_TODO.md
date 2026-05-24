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
  - `REVIEW_ENABLED=1` runs Codex read-only review
  - `REVIEW_ENABLED=0` skips review with `SKIP_REASON`
  - skipped-review artifact is created
  - Codex final decision still runs
- [x] `REVIEW_ENABLED=0` actual smoke test passed:
  - Codex plan was created
  - review was skipped
  - `_external_review_skipped.md` artifact was created
  - Codex decision completed
  - implementation was not run
- [x] `REVIEW_ENABLED=1` lite dry-run regression passed
- [x] Future context packet builder design documented
- [x] `inventory_limits` added to generic and Runiac `context-policy.yml` files
- [x] Standalone `build_context_packet.sh` helper implemented and smoke-tested
- [x] Future context packet runner integration design documented
- [x] Opt-in `CONTEXT_PACKET_ENABLED` runner integration implemented:
  - `CONTEXT_PACKET_ENABLED=0` is the default
  - `CONTEXT_PACKET_ENABLED=1` calls `build_context_packet.sh` before Codex planning
  - context packet is prepended to the Codex planning prompt
  - packet size limit is enforced
  - builder failure stops the pipeline with no broad repo scan fallback
- [x] Context packet dry-run regression passed
- [x] Actual `CONTEXT_PACKET_ENABLED=1` + `REVIEW_ENABLED=0` smoke test passed
- [x] Smoke-test traceability artifact committed:
  - `docs(traceability): record context packet integration smoke test`
- [x] First deterministic high-risk auto-routing guard implemented:
  - `HIGH_RISK_GUARD_ENABLED=1` is the default
  - block-level high-risk dry-runs stop unless approved
  - `HIGH_RISK_APPROVED=1` requires non-empty `HIGH_RISK_REASON`
  - `REVIEW_ENABLED`, `REVIEW_MODE`, and `CONTEXT_PACKET_ENABLED` remain separate from high-risk approval
- [x] External provider routing abandoned and simplified:
  - Claude review repeatedly hit the local budget cap
  - Gemini actual headless provider smoke tests repeatedly hung
  - active workflow is now Codex-only for feasibility, reliability, and efficiency
- [x] Codex-only review cleanup completed:
  - `REVIEW_ENABLED=1` runs Codex read-only plan review
  - `REVIEW_ENABLED=0` skipped-review behavior remains available with `SKIP_REASON`
  - Gemini and Claude provider routing are no longer active in `run_plan_review.sh`
  - implementation remains separate and requires explicit user approval

## Current Important Limits

- [ ] TODO auto-updater is postponed
- [ ] Flutter/Firebase implementation has not started
- [ ] TODO status is not approval.
- [ ] Gate status `Under Review` is not approval.
- [ ] Codex/LLM-generated artifacts are not human/project approval.
- [ ] Human/project approval evidence is required before any setup gate becomes `Approved`.

## Next Planned Steps

- [ ] Continue Phase 1 implementation preparation review and approval:
  - formal human/project approval for Gate-00
  - formal human/project approval for Secret / API Key / Environment Handling Gate
  - prepare Firebase Project and Config Gate
  - prepare Flutter Scaffold Gate
- [ ] Do not start Flutter/Firebase scaffolding until setup gates approve it

## Postponed TODO Automation

- [ ] Do not implement TODO automation now
- [ ] Prefer deterministic script first
- [ ] Add marker-delimited TODO sections later if needed
- [ ] Add optional Codex review later if useful
- [ ] Git hooks or GitHub Actions should warn/check first, not auto-edit

## Later Efficiency Work

- [ ] Defer `DECISION_POLICY=if-needed`

## Phase 1 Runiac Implementation Preparation

- [x] PRD complete.
- [x] PDD submitted.
- [x] Submitted PDD under `docs/submissions/pdd/` is the official frozen assessment snapshot.
- [x] `docs/pdd/` retained as internal/reference-only material.
- [x] Codex-only review flow simplification completed.
- [x] Phase 1 traceability docs added and committed:
  - `implementation/traceability/requirements-map.md`
  - `implementation/traceability/setup-gates.md`
- [x] `requirements-map.md` created.
- [x] `setup-gates.md` created.
- [x] Gate-00 readiness reviewed.
- [x] Gate-00 moved to `Under Review`.
- [x] Secret / API Key / Environment Handling Gate hardened.
- [x] MVP features and implementation-preparation boundaries mapped in `requirements-map.md`.
- [ ] Formal human/project approval for Gate-00.
- [ ] Formal human/project approval for Secret / API Key / Environment Handling Gate.
- [ ] Future guardrail reverse-mapping / sync review across:
  - `.gitignore`
  - `classify_high_risk_task.sh`
  - `.agents/skills/runiac-review-flow/SKILL.md`
  - `tools/agent-review/profiles/runiac/context-policy.yml`
  - legacy `.claude/settings.json`
- [ ] Decide config injection strategy before scaffolding.
- [ ] Decide Firebase config boundary before `firebase init`.
- [ ] Decide Flutter scaffold target path before `flutter create`.
- [ ] Prepare Firebase Project and Config Gate.
- [ ] Prepare Flutter Scaffold Gate.
- [ ] Mark deferred features F5, F7, F8, F10 unless user decides otherwise
- [ ] Clarify expert/admin governance scope

Secret gate coverage now includes Firebase project/config identifiers, Firebase mobile config files, map provider keys, AI/LLM provider keys, service account credentials, Android/iOS signing material, native iOS/Android build configuration, local developer-only env vars, and future CI/CD env vars. Client-side injection strategies do not prevent reverse-engineering; any value shipped inside the mobile app is potentially discoverable. XP, streak, level, rank, weekly XP, monthly XP, and leaderboard scores remain backend-owned.

`classify_high_risk_task.sh` is a task/prompt classifier, not a git commit hook. Git-level enforcement is optional future work and must be handled separately.

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
- [ ] Do not create production Firebase config.
- [ ] Do not add `google-services.json`.
- [ ] Do not add `GoogleService-Info.plist`.
- [ ] Do not add `.env` files with real values.
- [ ] Do not add Android/iOS signing material.
- [ ] Do not add API keys or service account files.

## Next Codex Prompt Topic

Continue Phase 1 implementation preparation by collecting explicit human/project approval evidence for Gate-00 and preparing the Firebase Project and Config Gate / Flutter Scaffold Gate without running scaffold commands.
