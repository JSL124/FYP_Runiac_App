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
