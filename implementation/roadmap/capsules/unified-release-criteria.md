# Unified Release Criteria

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-requested documentation capsule under ADR-003 Governance Lite Execution Lanes. No Phase 02
selection is implied or authorized.

## Status

Routed on 2026-07-31 Asia/Singapore. Documentation only. Follows the repository consolidation
quality-gates capsule, which closed the two CI verification holes.

## Goal

Give the repository a single place that answers "can this ship?", and separate two things that
are currently conflated: **a feature is deployed** and **the app is ready to release**.

## Background — what is missing today

The repository has no release checklist, no deploy runbook, and no rollback procedure. Actual
deploy commands are scattered across capsule prose:

- `capsules/profile-lifetime-stats-backend.md:49`
- `capsules/profile-photo-avatar.md:227`
- `capsules/level-progress-ring-live-fan-out.md:145`

The consequence is visible in the roadmap: many capsules record "backend deployed to
`runiac-fypp`" while the corresponding mobile release never happened, and nothing tracks that
gap as a single number.

**The best operational practice in this repository exists in exactly one place, as prose.**
`capsules/profile-stats-visibility.md:68` records fetching the live ruleset from the Firebase
Rules API and diffing it against the working tree before deploying, because
`firebase deploy --only firestore:rules` replaces the whole file and would carry any
committed-but-undeployed rules change with it. The same capsule at `:70-74` records the matching
post-deploy verification. That is a genuine data-loss guard and belongs in a runbook, not in one
capsule's narrative.

## Measured facts this capsule is built on (2026-07-31, `main` @ `6eb6efef`)

- `functions/src/index.ts` exports **61** function symbols.
- `region: "asia-southeast1"` appears **61** times in `functions/src/` — every function is
  single-region.
- Trigger families in use: `onCall`, `onRequest`, `onSchedule`, `onDocumentCreated`,
  `onDocumentUpdated`, `onDocumentWritten`, `onDocumentDeleted`. Six modules declare scheduled
  functions.
- App Check: **8 callables** enforce it via `shouldEnforceAppCheck()`; `subscribeNewsletter`
  disables it deliberately (`enforceAppCheck: false, invoker: "public"`); the remaining exports
  do not set the option. This is recorded as an open release-gate question, not changed here.

## Allowed Scope

- Create `implementation/release/RELEASE_CHECKLIST.md`, `DEPLOY_RUNBOOK.md`, `ROLLBACK.md`.
- Promote the live-ruleset pre-deploy diff and post-deploy verification pattern out of capsule
  prose into the runbook.
- Define a per-change-type compatibility matrix in place of a fixed deploy order.
- Define the deploy inventory columns and the approval-gated read-only live inventory step.
- Update this capsule document and `implementation/roadmap/CURRENT.md` routing.

## Forbidden Scope

- **No deploy execution of any kind.** `firebase deploy` and `flutter build` are classified
  high-risk in `tools/agent-review/runner/classify_high_risk_task.sh`. This capsule documents
  procedure; it does not run it.
- No `firebase functions:list` / `firestore:indexes` execution without separate explicit user
  approval — that is defined as its own gated step inside the runbook.
- No assertion of live deploy state. Source presence is not deployment evidence.
- No change to App Check enforcement, rules, indexes, or any `functions/` or Flutter source.
  The App Check coverage gap is recorded as a question for the user, not acted on.
- No change to any existing `- Newly routed …` or `- Current active capsule …` line.
- No Phase 02 selection, secret, or credential action.

## Exact Target Files

- `implementation/roadmap/capsules/unified-release-criteria.md`
- `implementation/roadmap/CURRENT.md`
- `implementation/release/RELEASE_CHECKLIST.md`
- `implementation/release/DEPLOY_RUNBOOK.md`
- `implementation/release/ROLLBACK.md`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)
- `tools/governance-ci/check-pre-scaffold-scope.sh` (routing predicate only, if required)

## Required Tests

Not applicable — documentation only. Validity is established by retrodiction instead: the
compatibility matrix must explain three real past deploys without contradiction (newsletter,
profile privacy, character gating).

## Required Validation

- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- `CURRENT.md` anchor counts: 40 `- Newly routed` before this capsule's line is appended, 41
  after; exactly 1 `- Current active capsule` throughout.
- A6_REVIEW then A8_OUTPUT_CHECKER — A8 is required because completeness of a checklist is the
  deliverable, and A6 alone does not judge that.

## Required Evidence

- Retrodiction notes for the three past deploys against the matrix. **Recorded below.**
- `run-all-checks.sh` output.
- The open App Check question surfaced to the user rather than silently resolved.

## Evidence — matrix retrodiction (2026-07-31)

The compatibility matrix in `DEPLOY_RUNBOOK.md` §1 was tested against three real deploys. It
explains all three without special-casing any of them.

### 1. `website-newsletter-subscription` (2026-07-30)

Deployed: five new `asia-southeast1` functions, `firestore.rules` (four deny-all newsletter
blocks), and a `newsletterSubscribers` `status`+`createdAt` composite index.

Matrix rows engaged: *Index addition*, *Rules — tightening*, *Function — new export*.

- The index row demands `READY` before dependent functions deploy. The deploy involved a
  function reading that composite, so the matrix derives index → wait `READY` → functions.
- The rules change is technically tightening, but on **new** collections no shipped client
  writes, so the lockout pre-condition is trivially satisfied — the matrix asks the question and
  gets a clean answer rather than being silent.
- One nuance the matrix surfaces that the capsule prose did not: `subscribeNewsletter` ships
  with `enforceAppCheck: false, invoker: "public"`, so it is reachable without an App Check
  token by design. That belongs in the inventory's App Check column.

### 2. `profile-stats-visibility` (2026-07-29)

Deployed: `functions:getRunnerPublicProfile` and `firestore:rules`.

Matrix rows engaged: *Function — signature change*, *Rules — loosening*.

This is the cleanest match. The matrix's signature-change pre-condition is "is the shipped client
compatible?", and the capsule answers it explicitly at `:75`: *"`statsHidden` is an added field
that older shipped clients ignore, and `publicStatsHidden` is a new writable key no shipped
client writes yet."* The runbook's §2 pre-deploy ruleset diff and §5 post-deploy verification are
both lifted verbatim from this deploy, so the fit is by construction.

### 3. `character-premium-access-gating` (2026-07-25)

Deployed: `firestore.rules` plus a `config/characterAccess` document. The mobile release that
surfaces the gating is still outstanding.

Matrix rows engaged: *Rules — tightening*, *Client release*.

This case is why `RELEASE_CHECKLIST.md` exists in its current form. Server-side the change is
complete; a user cannot see it. Under the old vocabulary the capsule reads as finished. Under
the new one it is **Deployed, not Release ready**, and belongs in the outstanding-release ledger.
Two of the roadmap's other capsules are in the same state.

It also exercises the runbook's preference for server-side switches: because the gate lives in a
`config/*` document rather than a client constant, disabling it is a Firestore edit rather than
an app-store release — exactly the risk placement `ROLLBACK.md` argues for.

### Conclusion

No deploy required a rule outside the matrix. The matrix additionally caught two things the
original prose records did not state: the newsletter endpoint's deliberate App Check exemption,
and that three capsules are Deployed-but-not-Release-ready.

## Rollback Conditions

- Revert if the matrix cannot explain a past deploy without special-casing it.
- Revert if any documented step would require executing a deploy to validate.
- Stop and re-route if the work is found to need `functions/` or Flutter source changes.

## Exit Criteria

- [ ] Three release documents created.
- [ ] Live-ruleset diff and post-deploy verification promoted out of capsule prose.
- [ ] Compatibility matrix retrodicts three past deploys.
- [ ] "Feature deployed" and "app release ready" separated in writing.
- [ ] Open questions surfaced to the user.
- [ ] Governance CI PASS locally; hosted CI green after push.
