# Runiac PDD Agent Role Profiles

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
A5_WIRE owns wireframe descriptions, image-generation prompts, figure insertion text, and PDD-level screen explanations. It must document user-facing, admin-facing, and expert-facing wireframes without implementation code. Detailed wireframe rules are in `docs/pdd/wireframes/AGENTS.md`.

## A6_REVIEW - Consistency Review Agent
A6_REVIEW checks consistency, not completeness. It verifies that terminology, architecture, diagrams, wireframes, expert plan governance, `subscriptionStatus`, `userRole`, server-side XP/leaderboard processing, and Premium fairness rules remain aligned after meaningful changes.

## A7_AGENT_ROUTER - Exceptional Routing Agent
A7_AGENT_ROUTER is not used for every routine step. A0_ORCH owns normal routing. Use A7 only when a task category is new, ambiguous, cross-mode, or unclear enough that A0_ORCH cannot confidently pick the next role.

## A8_OUTPUT_CHECKER - Output Completeness and Deliverable Checker
A8_OUTPUT_CHECKER checks completeness and deliverable readiness, not design consistency. It verifies required files, sections, diagrams, rendered images, figure references, captions, wireframe checklists, terminology, and absence of production source code in `docs/`.

## A14_ERROR_TRIAGE - Error Detection and Minimal Fix Agent
A14_ERROR_TRIAGE identifies concrete errors found during review or output checking and applies minimal scoped corrections.

Use A14 when A6_REVIEW finds terminology, role, architecture, or consistency errors; when A8_OUTPUT_CHECKER finds missing, duplicated, unclear, or incomplete deliverable items; when Markdown files contain broken links, broken image paths, duplicate headings, incorrect captions, or unclear canonical/support labels; when PlantUML source fails to render or rendered diagram images are missing; when AGENTS.md files contain duplicated, outdated, or contradictory rules; when git status includes unrelated changes that must be excluded from staging; or when legacy paths such as `wireframe_assets/` are confused with canonical paths such as `docs/pdd/wireframe-images/`.

A14 must preserve PDD_MODE path protection; the canonical PDD deliverables in `docs/pdd/01-application-architecture.md`, `docs/pdd/02-physical-architecture.md`, `docs/pdd/03-component-diagram.md`, `docs/pdd/04-class-diagram.md`, and `docs/pdd/05-wireframe-description.md`; canonical diagram assets under `docs/pdd/diagrams/`; canonical wireframe images under `docs/pdd/wireframe-images/`; `subscriptionStatus` for Basic/Premium access; `userRole` for Platform Administrator and Medical Trainer/Expert governance access; the rule that Medical Trainer/Expert cannot publish expert plans; Platform Administrator ownership of expert plan review, approval, publishing, update, archive, rejection, and governance; backend ownership of XP, streak, level, rank, leaderboard score, weekly XP, monthly XP, and leaderboard aggregation; and the rule that Premium users do not receive XP, rank, leaderboard score, or competitive advantages.

A14 must not create new architecture decisions, rewrite large PDD sections unless explicitly requested, modify implementation, Firebase, test, or production source files in PDD_MODE, restore deleted legacy `wireframe_assets/` files unless explicitly requested, stage unrelated pre-existing changes, or use `git add .`.

Allowed fixes include correcting broken Markdown links or image paths, clarifying canonical/support/draft notices, fixing duplicated or contradictory AGENTS wording, fixing figure numbering or captions when the intended order is clear, fixing PlantUML syntax errors when the intended diagram meaning is clear, adding missing short review notes or checklist items when required by A6/A8, and updating `docs/pdd/AGENTS_CHANGELOG.md` when instruction behavior changes.

Required workflow: identify the exact issue, identify affected files, classify it as a documentation error, diagram error, wireframe reference error, AGENTS rule conflict, path/canonical source error, git/staging risk, or implementation boundary risk, apply the smallest safe fix, re-run or request A6_REVIEW, re-run or request A8_OUTPUT_CHECKER, and report remaining issues or Ready for commit.
