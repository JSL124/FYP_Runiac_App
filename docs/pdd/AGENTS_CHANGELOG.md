# Runiac AGENTS.md Changelog

## 2026-05-21 - Add A14 Error Triage Role

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/diagrams/AGENTS.md`
- `docs/pdd/wireframes/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added A14_ERROR_TRIAGE for concrete error detection and minimal PDD/AGENTS fixes.

### Summary of changes
- Added A14_ERROR_TRIAGE to the root role index.
- Added PDD workflow routing rules for using A14 after A6_REVIEW or A8_OUTPUT_CHECKER finds concrete fixable issues.
- Added the detailed A14 role profile to `docs/pdd/AGENT_ROLES.md`.
- Added short diagram and wireframe routing references for concrete path, rendering, and governance wording errors.
- Kept A14 scoped to minimal corrections and prohibited new architecture decisions, large rewrites, PDD_MODE implementation changes, legacy `wireframe_assets/` restoration, unrelated staging, and `git add .`.

### Review required
- A6_REVIEW: verify A14 does not overlap too much with A6 or A8, is clearly a correction agent and not a design owner, preserves PDD_MODE and path protection, does not permit implementation changes in PDD_MODE, routes back to A6/A8 after fixes, and preserves Runiac role, subscription, expert governance, and backend-owned progression rules.
- A8_OUTPUT_CHECKER: verify A14 appears in the root role index, the detailed role exists in `docs/pdd/AGENT_ROLES.md`, folder-specific references are short and not duplicated excessively, changelog was updated, no production code was modified, no unrelated files were staged, and no `wireframe_assets/` deletions were staged.

### Final status
Ready for commit.

## 2026-05-21 - Add Ready-for-Commit Manual Command Rule

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added Ready-for-commit manual git command rule.

### Summary of changes
- Updated the root Commit Protocol so that when work reaches Ready for commit but auto-commit is not allowed, Codex must provide exact manual git commands.
- Required `git status --short`, task-relevant file identification, unrelated-change identification, explicit file staging commands, verification commands, and a suggested commit message.
- Prohibited recommending `git add .` when unrelated changes may exist.
- Required unrelated pre-existing changes to be listed under "Do not stage these unrelated changes."
- Updated `docs/pdd/AGENTS.md` with a short reference to the root Commit Protocol for Ready-for-commit manual commands.

### Review required
- A6_REVIEW: verify auto-commit remains limited to explicitly authorized AGENTS cleanup tasks, non-auto-commit tasks stop at Ready for commit, Ready-for-commit tasks provide safe manual git commands, commands use explicit file staging rather than `git add .`, unrelated pre-existing changes are listed and left unstaged, deleted legacy `wireframe_assets/` files are not automatically staged, and no production code was modified.
- A8_OUTPUT_CHECKER: verify root `AGENTS.md` contains the Ready-for-commit manual command rule, folder-specific AGENTS files do not duplicate the full protocol unnecessarily, changelog was updated, and no unrelated files were staged or committed.

### Final status
Ready for commit.

## 2026-05-21 - Add Conditional Auto-Commit Protocol

### Files modified
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
Added conditional auto-commit protocol.

### Summary of changes
- Added the canonical Commit Protocol to the root `AGENTS.md`.
- Kept the default rule as no commit unless the user explicitly grants commit or auto-commit permission for the current task or workflow.
- Allowed auto-commit only after Ready for commit and after required review/checker steps pass.
- Required Codex to inspect status and diff, stage only task-relevant files, avoid unrelated pre-existing changes, use repository commit message style, and report the commit hash.
- Added PDD_MODE and IMPLEMENTATION_MODE commit safeguards, including A6_REVIEW/A8_OUTPUT_CHECKER for PDD commits and relevant tests/reviews for implementation commits.
- Added a short PDD workflow reference in `docs/pdd/AGENTS.md` instead of duplicating the full protocol.

### Review required
- A6_REVIEW: verify auto-commit requires explicit user permission, only task-relevant files may be staged, PDD_MODE still protects implementation/Firebase/test files, deleted legacy `wireframe_assets/` files are not automatically restored or staged, commit message conventions are clear, and no production code was modified.
- A8_OUTPUT_CHECKER: verify root `AGENTS.md` contains the canonical Commit Protocol, folder-specific AGENTS files do not duplicate the full protocol unnecessarily, changelog was updated, and no unrelated files were staged or committed during this instruction update unless auto-commit permission was explicitly granted.

### Final status
Ready for commit.

## 2026-05-21 - Restructure Agent Instructions

### Files changed
- `AGENTS.md`
- `docs/pdd/AGENTS.md`
- `docs/pdd/AGENT_ROLES.md`
- `docs/pdd/diagrams/AGENTS.md`
- `docs/pdd/wireframes/AGENTS.md`
- `implementation/AGENTS.md`
- `implementation/AGENT_ROLES.md`
- `firebase/AGENTS.md`
- `tests/AGENTS.md`
- `docs/pdd/AGENTS_CHANGELOG.md`

### Reason
The root `AGENTS.md` had grown too long and repeated project rules across many agent descriptions. The instruction system was restructured so Codex can manage, review, modify, and generate Markdown documentation in a clean and maintainable way.

### Summary of rules moved or created
- Root `AGENTS.md` now holds global non-negotiable Runiac rules, mode defaults, path protection, Markdown management, AGENTS.md stewardship, and a short agent index.
- PDD_MODE rules and A0 to A8 summaries moved to `docs/pdd/AGENTS.md`.
- Detailed PDD role descriptions moved to `docs/pdd/AGENT_ROLES.md`.
- Diagram-specific rules moved to `docs/pdd/diagrams/AGENTS.md`.
- Wireframe-specific rules moved to `docs/pdd/wireframes/AGENTS.md`.
- IMPLEMENTATION_MODE rules and A9 to A13 summaries moved to `implementation/AGENTS.md`.
- Detailed implementation role descriptions moved to `implementation/AGENT_ROLES.md`.
- Firebase/backend security rules moved to `firebase/AGENTS.md`.
- QA and test-readiness rules moved to `tests/AGENTS.md`.

### Review required
- A6_REVIEW: verify consistency with Runiac PDD rules, role governance, `subscriptionStatus`/`userRole` separation, expert plan governance, server-side XP/leaderboard processing, and PDD_MODE path protection.
- A8_OUTPUT_CHECKER: verify all target AGENTS.md and AGENT_ROLES.md files exist and that long duplicate rules were removed from root.

### Final status
Ready for commit.
