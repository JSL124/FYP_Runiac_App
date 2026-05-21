# Runiac PDD Diagram Instructions

## Scope
- Applies to PDD diagram documentation and diagram assets under `docs/pdd/diagrams/`.
- Keep diagrams PDD-level, not implementation-level.
- Prefer simple academic diagrams over overcomplicated enterprise architecture.

## Diagram Deliverables
- Application Architecture
- Physical Architecture
- Component Diagram
- Class Diagram

## Diagram Rules
- Use PlantUML source files where applicable.
- Keep rendered diagram images under `docs/pdd/diagrams/` or another clearly named PDD diagram/image folder.
- If PlantUML rendering, missing rendered image, or diagram path errors are found, route to A14_ERROR_TRIAGE for minimal correction, then return to A6_REVIEW and A8_OUTPUT_CHECKER.
- Use straight-line PlantUML links if requested by the user.
- Do not add Kubernetes, custom server clusters, custom load balancers, or microservice complexity unless explicitly requested.
- Application, physical, component, and class diagrams must remain consistent with the same Runiac assumptions.
- Do not model Basic User and Premium User as separate subclasses.
- Use `subscriptionStatus` for Basic/Premium access and `userRole` for operational/governance access.
- XP, streak, level, rank, weekly XP, monthly XP, leaderboard score, and leaderboard aggregation remain server-side.
- Medical Trainer/Expert provides content only; Platform Administrator controls expert plan publication.

## Review Checklist
- Diagram source and rendered image both exist when needed.
- Diagram title and caption match the PDD section.
- Component/service names are consistent across PDD files.
- Trusted backend operations are not shown as client-owned.
- Future extensions are clearly marked or kept realistic for FYP scope.
