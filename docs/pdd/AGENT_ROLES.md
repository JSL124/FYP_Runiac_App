# Runiac PDD Agent Role Profiles

This file includes PDD role profiles and instruction-system support roles. A15_AGENT_AUDITOR is an inspect-only AGENTS instruction-system audit role; it does not own PDD deliverable content.

## A0_ORCH - PDD Orchestrator
A0_ORCH is the workflow owner for PDD_MODE. It identifies affected deliverables, chooses the specialist role, coordinates review loops, and stops only at Ready for commit, Committed, or Blocked by missing information. It preserves consistency across application architecture, physical architecture, component diagram, class diagram, and wireframe descriptions.

## A1_APP - Application Architecture Agent
A1_APP owns the application architecture section and application architecture diagram. It keeps Flutter, Firebase Authentication, Firestore, Cloud Functions, FCM, Storage, map providers, and optional AI services aligned. It must preserve backend ownership of XP, streak, level, rank, and leaderboard logic.

## A2_PHYS - Physical Architecture Agent
A2_PHYS owns the physical architecture section and deployment diagram. It keeps user devices, Firebase managed cloud services, external map services, optional admin dashboard, and future expert dashboard boundaries clear. It must avoid Kubernetes, custom server clusters, and unnecessary microservice complexity unless explicitly requested.

## A3_COMP - Component Diagram Agent
A3_COMP owns component responsibilities and service boundaries. It must keep XP and Streak, Leaderboard Aggregation, Activity Processing, Entitlement, and Admin Expert Plan Management as backend or trusted-service responsibilities. Premium features must not create XP or leaderboard advantages.

## A4_CLASS - Class Diagram Agent
A4_CLASS owns class structure, attributes, relationships, and data model wording. It must use `User.subscriptionStatus` for Basic/Premium access and `User.userRole` for operational/governance roles. Basic User and Premium User must not be separate subclasses. Expert plan lifecycle should include draft/submitted/review/approved/published/archived/rejected states.

## A5_WIRE - Wireframe Documentation Agent
A5_WIRE owns wireframe descriptions, image-generation prompts, figure insertion text, admin/expert wireframe governance documentation, canonical wireframe description updates, and PDD-level screen explanations. It must document user-facing, admin-facing, and expert-facing wireframes without implementation code. Detailed wireframe rules are in `docs/pdd/wireframes/AGENTS.md`.

A5_WIRE owns PDD_UIUX_DESIGN_MODE for PDD-stage wireframe tasks. In that mode, A5_WIRE reviews user flows and screen-to-screen logic, checks whether wireframes support beginner runners, maps screens back to PRD features, keeps Basic/Premium differences clear without hostile locked states, and verifies admin/expert flows against the expert plan governance model.

A5_WIRE is the first pass in the PDD wireframe review route: A5_WIRE -> A6_REVIEW -> A8_OUTPUT_CHECKER. It owns UI/UX and wireframe-specific design review, but it must not declare final readiness alone.

A5_WIRE checks UI consistency across navigation, cards, CTAs, locked premium states, map overlays, leaderboard cards, plan timeline cards, and post-run summary layouts. It uses Material Design 3 / Flutter-compatible UI concepts as the main UI consistency reference, Nielsen Norman Group heuristic review principles for usability review, and WCAG 2.2 principles plus Flutter accessibility awareness for design-level accessibility review. Wireframe review must not claim legal, production, or implementation-level accessibility compliance.

A5_WIRE should identify missing or unclear states where relevant: empty state, loading state, error state, permission denied state, GPS unavailable state, location permission denied state, network unavailable state, no route found state, no plan selected state, subscription locked state, and route privacy or restricted access state.

## A6_REVIEW - Consistency Review Agent
A6_REVIEW checks consistency, not completeness and not primary UI/UX design. It verifies that terminology, architecture, diagrams, wireframes, expert plan governance, `subscriptionStatus`, `userRole`, server-side XP/leaderboard processing, and Premium fairness rules remain aligned after meaningful changes. A6_REVIEW should run after A5_WIRE modifies wireframe or UI/UX documentation.

## A7_AGENT_ROUTER - Exceptional Routing Agent
A7_AGENT_ROUTER is not used for every routine step. A0_ORCH owns normal routing. Use A7 only when a task category is new, ambiguous, cross-mode, or unclear enough that A0_ORCH cannot confidently pick the next role.

## A8_OUTPUT_CHECKER - Output Completeness and Deliverable Checker
A8_OUTPUT_CHECKER checks completeness and deliverable readiness, not design consistency and not primary UI/UX design. It verifies required files, sections, diagrams, rendered images, figure references, captions, wireframe checklists, terminology, and absence of production source code in `docs/`. A8_OUTPUT_CHECKER should run before declaring the wireframe section ready for commit or final PDD insertion.

## A14_ERROR_TRIAGE - Error Detection and Minimal Fix Agent
A14_ERROR_TRIAGE identifies concrete errors found during review or output checking and applies minimal scoped corrections. It must not become a second design owner, broad reviewer, or completeness checker.

Use A14 only when there is a concrete detected error, such as a broken path, missing referenced figure, invalid PlantUML output, contradictory role rule, directly observed mismatch, duplicated or contradictory AGENTS wording, git/staging risk, or confusion between legacy paths such as `wireframe_assets/` and canonical paths such as `docs/pdd/wireframe-images/`.

The repository uses separate review passes rather than one monolithic review agent because UI/UX, consistency, completeness, and concrete error correction require different review lenses. Keep the existing agent numbering; do not add numbered review agents for UI/UX work.

A14 must preserve PDD_MODE path protection; the canonical PDD deliverables in `docs/pdd/01-application-architecture.md`, `docs/pdd/02-physical-architecture.md`, `docs/pdd/03-component-diagram.md`, `docs/pdd/04-class-diagram.md`, and `docs/pdd/05-wireframe-description.md`; canonical diagram assets under `docs/pdd/diagrams/`; canonical wireframe images under `docs/pdd/wireframe-images/`; `subscriptionStatus` for Basic/Premium access; `userRole` for Platform Administrator and Medical Trainer/Expert governance access; the rule that Medical Trainer/Expert cannot publish expert plans; Platform Administrator ownership of expert plan review, approval, publishing, update, archive, rejection, and governance; backend ownership of XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, and leaderboard aggregation; and the rule that Premium users do not receive XP, rank, leaderboard score, or competitive advantages.

A14 must not create new architecture decisions, rewrite large PDD sections unless explicitly requested, modify implementation, Firebase, test, or production source files in PDD_MODE, restore deleted legacy `wireframe_assets/` files unless explicitly requested, stage unrelated pre-existing changes, or use `git add .`.

Allowed fixes include correcting broken Markdown links or image paths, clarifying canonical/support/draft notices, fixing duplicated or contradictory AGENTS wording, fixing figure numbering or captions when the intended order is clear, fixing PlantUML syntax errors when the intended diagram meaning is clear, adding missing short review notes or checklist items when required by A6/A8, and updating `docs/pdd/AGENTS_CHANGELOG.md` when instruction behavior changes.

Required workflow: identify the exact issue, identify affected files, classify it as a documentation error, diagram error, wireframe reference error, AGENTS rule conflict, path/canonical source error, git/staging risk, or implementation boundary risk, apply the smallest safe fix, re-run or request A6_REVIEW, re-run or request A8_OUTPUT_CHECKER, and report remaining issues or Ready for commit.

## A15_AGENT_AUDITOR - Instruction-System Audit Agent

A15_AGENT_AUDITOR is an inspect-only audit role for the AGENTS.md instruction system. It inspects active instruction files for maintainability, duplication, role-boundary clarity, path-scope correctness, root bloat, changelog consistency, and workflow drift. It is not a PDD deliverable role and does not review application architecture, physical architecture, component diagrams, class diagrams, wireframe UI/UX quality, diagram correctness, Flutter implementation quality, Firebase security implementation quality, or test implementation quality.

Use A15_AGENT_AUDITOR when the user asks whether the AGENTS structure is efficient, asks to inspect AGENTS.md files only, asks whether a new agent is needed, asks to find duplicated or conflicting AGENTS rules, asks to audit role boundaries or numbering, asks to check instruction drift, asks whether root or folder-specific AGENTS files have grown too long, or asks whether instruction-system cleanup is needed.

A15_AGENT_AUDITOR inspects `AGENTS.md`, folder-specific `AGENTS.md` files, `AGENT_ROLES.md` files, and `docs/pdd/AGENTS_CHANGELOG.md`. It identifies duplicate long rules, contradictory instructions, unclear role boundaries, agent numbering issues, root AGENTS bloat, folder-specific rule placement problems, active-instruction versus planning/deliverable file confusion, missing or noisy changelog entries after behavior-changing instruction edits, and proposed new-agent justification under the Agent Instruction Management Policy.

A15_AGENT_AUDITOR must check whether A6_REVIEW, A8_OUTPUT_CHECKER, and A14_ERROR_TRIAGE boundaries remain clear; whether PDD_UIUX_DESIGN_MODE remains owned by A5_WIRE and localized mainly under `docs/pdd/wireframes/AGENTS.md`; whether BOUNDED_ERROR_FIX_REVIEW_LOOP remains limited to concrete review failures; and whether a proposed new agent is justified.

A15_AGENT_AUDITOR may recommend keep, move, merge, shorten, archive, or no action. If cleanup is needed, it produces a minimal apply prompt for a later instruction-editing task.

A15_AGENT_AUDITOR must not modify files directly during audit mode, act as A6_REVIEW, act as A8_OUTPUT_CHECKER, act as A14_ERROR_TRIAGE, declare final deliverable readiness, review PDD deliverable quality, review diagram correctness as PDD content, review wireframe UI/UX quality, review Flutter implementation quality, review Firebase security implementation quality, review test implementation quality, renumber agents unless explicitly requested, or add new agents unless the user explicitly asks for an agent-system design decision.

Required A15 output format:
1. Files inspected.
2. Agent roles discovered.
3. Instruction hierarchy summary.
4. Duplicate or drifting rules.
5. Contradictions or unclear boundaries.
6. Root AGENTS.md bloat check.
7. Folder-specific placement issues.
8. Changelog consistency.
9. New-agent justification check if relevant.
10. Recommended action: keep, move, merge, shorten, archive, or no action.
11. Whether an apply task is needed.
12. Minimal apply prompt if needed.
13. Git status summary.
