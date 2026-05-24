---
name: runiac-review-flow
description: Use when working in the Runiac repository to run, plan, review, smoke-test, or explain the local agent-review workflow safely, including context packets, Claude review, Codex final decisions, high-risk guard checks, and traceability artifact handling.
---

# Runiac Review Flow Skill

This skill is repo-scoped for the Runiac repository only. Codex may use it via `/skills` or by mentioning `$runiac-review-flow`; it is not a guaranteed custom slash command named `/runiac-review-flow`.

Always begin:

```bash
cd /Users/leejinseo/Desktop/FYP_Runiac
git status --short
```

If the working tree is dirty, stop and ask the user how to proceed. Do not stage, commit, clean, or overwrite changes unless the user explicitly approves the exact action.

## Defaults

- Default to `DRY_RUN=1` unless the user explicitly asks for actual pipeline execution.
- Default to `CONTEXT_PACKET_ENABLED=1` for review-flow tasks.
- Require explicit `CONTEXT_CLASS`.
- Valid context classes: `workflow`, `docs`, `implementation_prep`, `feature`, `security`, `architecture`.
- `unknown` is rejected and must not silently fall back to another class.
- Use `REVIEW_MODE=lite` for normal workflow or documentation checks.
- Use `REVIEW_MODE=standard` for broader, security-sensitive, architecture-sensitive, Firebase, roles, entitlement, XP, leaderboard, or PRD/PDD consistency review.

## Review Controls

- `REVIEW_ENABLED=1` runs Claude review.
- `REVIEW_ENABLED=0` skips Claude review only, requires `SKIP_REASON`, is not approval, and still requires Codex final decision.
- `HIGH_RISK_GUARD_ENABLED=1` is the default.
- `HIGH_RISK_APPROVED=0` is the default.
- `HIGH_RISK_REASON` is required when `HIGH_RISK_APPROVED=1`.
- `REVIEW_ENABLED`, `REVIEW_MODE`, and `CONTEXT_PACKET_ENABLED` are not high-risk approval.
- Codex must not add `HIGH_RISK_APPROVED=1` unless the user explicitly instructs it.
- Implementation must not run unless the user explicitly approves it.

## Command Templates

Basic dry-run pipeline:

```bash
DRY_RUN=1 CONTEXT_PACKET_ENABLED=1 CONTEXT_CLASS=workflow REVIEW_MODE=lite TASK_PROMPT="Describe the workflow task here." tools/agent-review/runner/run_plan_review.sh pipeline
```

Context packet dry-run:

```bash
DRY_RUN=1 CONTEXT_PACKET_ENABLED=1 CONTEXT_CLASS=workflow TASK_PROMPT="Context packet dry-run only. Do not modify files." tools/agent-review/runner/run_plan_review.sh pipeline
```

Actual review pipeline with Claude review:

```bash
DRY_RUN=0 CONTEXT_PACKET_ENABLED=1 CONTEXT_CLASS=workflow REVIEW_ENABLED=1 REVIEW_MODE=standard TASK_PROMPT="Describe the approved review task here." tools/agent-review/runner/run_plan_review.sh pipeline
```

Smoke test with skipped Claude review:

```bash
DRY_RUN=0 CONTEXT_PACKET_ENABLED=1 CONTEXT_CLASS=workflow REVIEW_ENABLED=0 SKIP_REASON="workflow smoke test" REVIEW_MODE=lite TASK_PROMPT="Smoke test only. Do not modify files." tools/agent-review/runner/run_plan_review.sh pipeline
```

High-risk expected block dry-run:

```bash
DRY_RUN=1 CONTEXT_PACKET_ENABLED=1 CONTEXT_CLASS=security TASK_PROMPT="Run firebase init and create Firebase config." tools/agent-review/runner/run_plan_review.sh pipeline
```

Explicitly approved high-risk dry-run:

```bash
DRY_RUN=1 CONTEXT_PACKET_ENABLED=1 CONTEXT_CLASS=docs HIGH_RISK_APPROVED=1 HIGH_RISK_REASON="approved dry-run validation" TASK_PROMPT="Modify PRD.md baseline." tools/agent-review/runner/run_plan_review.sh pipeline
```

## Post-Run Checks

After any run:

```bash
git status --short
```

Inspect created traceability artifacts before taking any next step. Commit only files explicitly approved by the user, and use explicit `git add <path>` commands rather than `git add .`.

## Non-Actions

Do not run `flutter create`, `firebase init`, `npm`, builds, tests, deployment, Flutter, Firebase, or production test commands. Do not modify PRD/PDD/submitted docs unless explicitly approved. Do not handle secrets, API keys, private GPS data, or precise location history. Do not automatically run `git add`, `git commit`, or `git push`.
