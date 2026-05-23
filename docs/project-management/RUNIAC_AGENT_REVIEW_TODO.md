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

## Immediate Checks

- [ ] Run `git status --short`
- [ ] Run `git log --oneline -8`
- [ ] Push `origin main` if not already pushed

## Next Major Task: Generic Core + Runiac Profile Migration

- [ ] Create `tools/agent-review/profiles/runiac/`
- [ ] Move or copy Runiac prompts into `profiles/runiac/prompts/`
- [ ] Move or copy Runiac env example into `profiles/runiac/`
- [ ] Add `profiles/runiac/README.md`
- [ ] Update runner to support profile paths
- [ ] Update README for generic core + profile structure
- [ ] Preserve pipeline behavior
- [ ] Run dry-run pipeline smoke check
- [ ] Commit only relevant files

## Later Efficiency Work

- [ ] Consider manual/no-automated-review mode
- [ ] Clearly label manual checklist artifacts
- [ ] Do not claim automated review when none happened
- [ ] Defer `REVIEW_MODE=lite|standard|full`
- [ ] Defer `REVIEW_PROVIDER=codex`
- [ ] Defer `DECISION_POLICY=if-needed`
- [ ] Defer Claude packet generation
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

Implement generic core + Runiac profile migration for `tools/agent-review` while preserving existing pipeline behavior.
