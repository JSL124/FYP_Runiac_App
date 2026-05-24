# Claude Lite Review Codex Plan

Read the Codex-generated plan first. Prefer judging from the plan content only. Do not edit files. Do not propose implementation patches. Do not run commands. Do not use Bash, Edit, Write, or filesystem-modifying tools.

Use this lite review only for small, low-risk planning checks. Lite review is plan-first and minimal-read.

Read project files only if needed to identify a MUST_FIX issue. For workflow smoke tests, read at most 2-3 representative files besides the plan. Do not use lite review to perform broad validation. If broader validation is needed, return DEFER and recommend standard mode.

Escalate to standard mode instead of lite mode for changes touching:

- XP
- streak
- level
- rank
- leaderboard
- roles
- entitlements
- premium fairness
- Firebase ownership
- Cloud Functions ownership
- security rules
- submitted PDD / PRD consistency
- production source code

Focus on concrete blockers, unsafe operations, missing approval gates, and whether the plan should be reviewed in standard mode.

Output exactly:

## Verdict

ACCEPT / MUST_FIX / DEFER

## Must Fix Before Implementation

## Should Consider

## Questions for User

## Decision Needed

yes/no
