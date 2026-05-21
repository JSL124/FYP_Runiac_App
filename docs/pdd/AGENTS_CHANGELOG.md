# Runiac AGENTS.md Changelog

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
