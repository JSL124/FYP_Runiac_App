# Runiac PDD Agent Instructions

## PDD_MODE Scope
- PDD_MODE is used for Project Design Document preparation.
- Do not write implementation code unless explicitly asked.
- Do not modify Flutter, Firebase, backend, Cloud Functions, tests, or production implementation files.
- Keep PDD outputs academic, concise, and realistic for a university FYP.

## Required PDD Deliverables
1. Application Architecture
2. Physical Architecture
3. Component Diagram
4. Class Diagram
5. Wireframe descriptions

## PDD Documentation Rules
- Produce PDD-ready explanation.
- Use clear academic wording without overcomplicated enterprise architecture.
- Preserve heading hierarchy unless restructuring is required.
- Keep terminology consistent: Basic User, Premium User, Platform Administrator, Medical Trainer/Expert.
- Separate MVP assumptions, future extensions, and out-of-scope items.
- Do not mix PDD content, implementation planning, and production source code in the same Markdown file.
- After editing Markdown, check duplicated sections, terminology consistency, broken figure references, and whether diagrams, wireframes, or class model are affected.

## PDD Workflow
- A0_ORCH owns the workflow and chooses the needed PDD role.
- PDD work stops at Ready for commit by default. If auto-commit is not allowed, provide manual git commands following the root `AGENTS.md` Commit Protocol. PDD deliverable changes are not auto-committed unless separately authorized.
- Use A1_APP, A2_PHYS, A3_COMP, A4_CLASS, or A5_WIRE based on the affected deliverable.
- Run A6_REVIEW after meaningful documentation, diagram, or wireframe changes.
- Run A8_OUTPUT_CHECKER before declaring PDD output Ready for commit.
- If A6_REVIEW or A8_OUTPUT_CHECKER finds issues, route back to the correct specialist role, correct the issue, and review again.
- Use A14_ERROR_TRIAGE when A6_REVIEW or A8_OUTPUT_CHECKER finds concrete fixable issues. A14 must apply the smallest safe correction, then route back to A6_REVIEW and A8_OUTPUT_CHECKER.
- A14 must not introduce new architecture decisions or rewrite large sections unless explicitly requested.
- In PDD_MODE, A14 must not modify implementation, Firebase, test, or production source files.
- A7_AGENT_ROUTER is only for new, ambiguous, or unclear task categories.

## PDD Role Summary
- A0_ORCH: coordinates full PDD tasks until Ready for commit, Committed, or Blocked.
- A1_APP: application architecture.
- A2_PHYS: physical architecture.
- A3_COMP: component responsibilities and component diagram.
- A4_CLASS: class diagram and data model.
- A5_WIRE: wireframe descriptions, prompts, and figure insertion.
- A6_REVIEW: consistency review, not completeness.
- A7_AGENT_ROUTER: exception routing for unclear tasks.
- A8_OUTPUT_CHECKER: completeness and deliverable readiness, not consistency.
- A14_ERROR_TRIAGE: concrete error detection and minimal scoped fixes before returning to review.

Detailed PDD role profiles are in `docs/pdd/AGENT_ROLES.md`.

## Runiac PDD Constraints
- Basic/Premium access uses `subscriptionStatus`.
- Governance roles use `userRole`.
- Medical Trainer/Expert cannot directly publish expert plans.
- Platform Administrator owns expert plan review, approval, publishing, update, and archive.
- XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, and leaderboard aggregation remain server-side.
- Flutter client must not directly write trusted progression or ranking values.
- Premium users must not receive XP, ranking, leaderboard score, or competitive advantages.
- Basic User and Premium User are not separate subclasses.

## A8 PDD Checklist
A8_OUTPUT_CHECKER must check:
- Application Architecture exists.
- Physical Architecture exists.
- Component Diagram exists.
- Class Diagram exists.
- Wireframe descriptions exist.
- Required admin/expert wireframe descriptions or prompt sets are present when relevant.
- Figure references and captions are present where needed.
- Terminology is consistent.
- No production source code is placed inside `docs/`.
