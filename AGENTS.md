# Runiac Agent Instructions

## Project Defaults
- Default mode is PDD_MODE unless the user explicitly asks for implementation, build, test, or code changes.
- Runiac is a beginner-focused running app for a Final Year Project.
- Current primary work is Project Design Document preparation.
- Do not commit unless the user explicitly asks. Stop at Ready for commit.
- Use `grep` and `find` for repository searches.

## Non-Negotiable Runiac Rules
- Flutter handles UI, navigation, GPS tracking UI, and local interaction.
- Firebase Authentication handles identity.
- Firestore stores users, plans, activities, routes, XP summaries, and leaderboard data.
- Cloud Functions handle XP calculation, activity validation, streak update, level update, rank update, and leaderboard aggregation.
- The client must not directly calculate or write XP, level, rank, streak, leaderboard score, weekly XP, or monthly XP.
- Premium features must not rely only on hiding UI.
- Premium users must not receive XP, rank, leaderboard score, or competitive advantages.
- Basic/Premium feature access uses `subscriptionStatus`.
- Operational and governance access uses `userRole`.
- Basic User and Premium User must not be modelled as separate subclasses.
- Platform Administrator is the governance and CRUDS role.
- Medical Trainer/Expert is an expert plan content provider only and must not directly publish expert plans into the app or database.
- Platform Administrator reviews expert plan content for safety, completeness, beginner suitability, and consistency.
- Only Platform Administrator can approve, publish, update, archive, reject, suspend, or manage expert plans.
- Premium User can only view and select approved/published expert plans.
- Future Expert Dashboard may allow draft submission, but admin approval is still required before publishing.
- Treat GPS route data, activity history, profile data, and running metrics as sensitive user data.

## Path Protection
- In PDD_MODE, do not modify Flutter, Firebase, backend, Cloud Functions, tests, or production implementation files unless explicitly requested.
- In IMPLEMENTATION_MODE, do not rewrite PDD-only files unless explicitly required.
- Do not place production source code inside `docs/`.
- Keep `docs/pdd/` for design documentation only.
- Folder-specific rules are in the closest AGENTS.md file.

## Markdown Documentation Management
- Preserve heading hierarchy unless restructuring is required.
- Do not mix PDD content, implementation planning, and production code in the same Markdown file.
- Keep terminology consistent: Basic User, Premium User, Platform Administrator, Medical Trainer/Expert.
- Separate MVP assumptions, future extensions, and out-of-scope items.
- After editing Markdown, check duplicated sections, terminology consistency, broken figure references, and whether diagrams, wireframes, or class model are affected.

## Agent Execution Model
- A0_ORCH is the workflow owner.
- A0 to A13 are role profiles and review lenses by default.
- Do not assume real parallel Codex subagents are available unless the user explicitly asks Codex to spawn subagents.
- If subagents are not explicitly requested, A0_ORCH should emulate specialist checks sequentially.
- Stop only when Ready for commit, Committed, or Blocked by missing information.

## Short Agent Role Index
- A0_ORCH: workflow owner and mode coordinator.
- A1_APP: application architecture PDD role.
- A2_PHYS: physical architecture PDD role.
- A3_COMP: component diagram PDD role.
- A4_CLASS: class diagram and data model PDD role.
- A5_WIRE: wireframe documentation and prompt role.
- A6_REVIEW: consistency review role.
- A7_AGENT_ROUTER: new or ambiguous task routing role only.
- A8_OUTPUT_CHECKER: completeness and deliverable readiness role.
- A9_TRACE: requirement traceability role.
- A10_FLUTTER_IMPL: Flutter implementation role.
- A11_FIREBASE_IMPL: Firebase/backend implementation role.
- A12_QA_TEST: testing and QA role.
- A13_SECURITY_RULES: security and access-control review role.

## AGENTS.md Stewardship
- Keep AGENTS.md files short, practical, and non-repetitive.
- Add new rules only when they prevent repeated mistakes or protect important project constraints.
- Put new rules in the closest relevant AGENTS.md file.
- Do not duplicate long rules across multiple AGENTS.md files.
- If a rule changes project behavior, update `docs/pdd/AGENTS_CHANGELOG.md`.
- A0_ORCH must check whether an AGENTS.md update is needed when repeated mistakes occur.

## Mode-Specific Rule Files
- PDD work: `docs/pdd/AGENTS.md`
- PDD role details: `docs/pdd/AGENT_ROLES.md`
- Diagram work: `docs/pdd/diagrams/AGENTS.md`
- Wireframe work: `docs/pdd/wireframes/AGENTS.md`
- Implementation work: `implementation/AGENTS.md`
- Implementation role details: `implementation/AGENT_ROLES.md`
- Firebase/backend work: `firebase/AGENTS.md`
- Tests and QA: `tests/AGENTS.md`
