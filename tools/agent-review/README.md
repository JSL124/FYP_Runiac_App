# Agent Review Workflow

This folder defines a Runiac-local workflow for plan review before implementation:

1. Codex creates an inspect-only plan.
2. Claude Code reviews that plan in read-only plan-review mode.
3. Codex performs final review, accepts/rejects/deferred Claude feedback, and produces the final plan.
4. Codex implements only after explicit user approval.
5. The user performs `git add`, `git commit`, and push manually.

The workflow is local to this repository for now. Do not create a separate repo, Git submodule, package, or GitHub Actions workflow yet.

## Runner Usage

Manual step-by-step usage remains supported:

```bash
tools/agent-review/runner/run_plan_review.sh plan
tools/agent-review/runner/run_plan_review.sh review
tools/agent-review/runner/run_plan_review.sh decision
tools/agent-review/runner/run_plan_review.sh implement
```

The `pipeline` subcommand is a conservative convenience wrapper for only:

```text
plan -> review -> decision
```

It runs Codex inspect-only planning, Claude read-only plan review, and Codex final decision, then prints the generated `PLAN_FILE`, `REVIEW_FILE`, `DECISION_FILE`, `git status --short`, and reminders that implementation was not run.

Dry-run preview:

```bash
TASK_PROMPT="Pipeline smoke test only. Do not modify files." \
tools/agent-review/runner/run_plan_review.sh pipeline
```

Actual run:

```bash
DRY_RUN=0 \
TASK_PROMPT="$(cat /tmp/task.md)" \
tools/agent-review/runner/run_plan_review.sh pipeline
```

You can also provide a task prompt file when `TASK_PROMPT` is unset:

```bash
DRY_RUN=0 \
TASK_PROMPT_FILE=/tmp/task.md \
tools/agent-review/runner/run_plan_review.sh pipeline
```

If both `TASK_PROMPT` and `TASK_PROMPT_FILE` are set, `TASK_PROMPT` is used and `TASK_PROMPT_FILE` is ignored.

On failure, `pipeline` stops at the failed step (`plan`, `review`, or `decision`) and does not continue. It never falls back from Claude to Codex review and never starts implementation.

`pipeline` does not run implementation, `git add`, `git commit`, `git push`, tests, builds, deployment, Flutter, Firebase, or npm commands. Implementation remains a separate, user-approved step after inspecting the decision file.

## Layers

- `runner/` contains generic shell helpers and subcommands. It should not include Runiac PRD/PDD/business rules.
- `prompts/runiac/` contains Runiac-specific prompts for Codex and Claude.
- `config/` contains project-specific example settings.

## Safety

The runner uses subcommands instead of an automatic loop. It defaults to `DRY_RUN=1`; use `DRY_RUN=0` only when you intentionally want it to invoke Codex or Claude. In dry-run mode, if configured output directories do not exist, the runner prints the command preview to stdout instead of creating directories. Actual runs create configured output directories and refuse to overwrite existing output files.

Command examples use read-only Codex execution for plan and decision steps:

```bash
codex --sandbox read-only --ask-for-approval never -C . exec
```

First implementation runs should use interactive Codex only after explicit user approval:

```bash
codex --sandbox workspace-write --ask-for-approval on-request -C .
```

The workflow forbids `danger-full-access` and forbids combining `workspace-write` with `--ask-for-approval never`.

Claude plan review must use read-only tools:

```bash
claude -p "$(cat tools/agent-review/prompts/runiac/02_claude_review_plan.md)" \
  --permission-mode plan \
  --tools "Read,Grep,Glob" \
  --append-system-prompt "$(cat CLAUDE.md)"
```

Do not allow Claude review mode to use Bash, Edit, Write, filesystem-modifying tools, `dangerously-skip-permissions`, `bypassPermissions`, `auto`, or `acceptEdits` modes.

## Future

After 3-5 real planning tasks, review whether the runner logic is stable enough to externalize. Do not create a separate repo, Git submodule, package, or GitHub Actions workflow yet.
