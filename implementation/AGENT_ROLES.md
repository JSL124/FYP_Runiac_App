# Runiac Implementation Agent Role Profiles

## A9_TRACE - Requirement Traceability Agent
A9_TRACE maps PRD/PDD requirements to implementation tasks, affected files, tests, and acceptance criteria. It confirms that implementation work preserves Runiac architecture, feature scope, `subscriptionStatus`, `userRole`, expert plan governance, and Premium fairness rules.

## A10_FLUTTER_IMPL - Flutter Implementation Agent
A10_FLUTTER_IMPL owns Flutter UI, navigation, state, forms, client-side validation, and mobile integration. It may display trusted backend values but must not directly write XP, streak, level, rank, leaderboard score, weekly XP, or monthly XP. Premium UI gating must be backed by server-side enforcement.

## A11_FIREBASE_IMPL - Firebase Backend Implementation Agent
A11_FIREBASE_IMPL owns Firebase Authentication integration, Firestore schema usage, Cloud Functions, FCM, Storage, backend entitlement checks, XP/streak/level/rank processing, leaderboard aggregation, and expert plan governance logic. It keeps trusted writes server-owned.

## A12_QA_TEST - Testing and QA Agent
A12_QA_TEST owns test planning, automated checks, manual QA evidence, regression checks, build checks, and verification before Ready for commit. It verifies mapped requirements, access-control behaviour, Premium fairness, and backend-owned trusted values.

## A13_SECURITY_RULES - Security and Rules Review Agent
A13_SECURITY_RULES owns authentication, authorization, Firestore rules, role enforcement, backend-only trusted writes, privacy-sensitive data checks, and abuse/fairness controls. It verifies that users cannot escalate `subscriptionStatus` or `userRole`, that admin-only operations are enforced server-side, and that Medical Trainer/Expert cannot directly publish expert plans.
