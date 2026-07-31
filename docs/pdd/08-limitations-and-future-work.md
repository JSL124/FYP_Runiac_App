# 8. Limitations and Future Work

## 8.1 Purpose

An honest account of what Runiac does not do, what is not verified, and what a next iteration
should address. Limitations are recorded here rather than left for a reader to discover, because
a system whose boundaries are stated is easier to assess than one whose boundaries are implied.

Verified against `main` @ `6eb6efef` (2026-07-31).

## 8.2 Verification limitations

### Device QA is outstanding

Every requirement area in `implementation/traceability/requirements-map.md` Part II is verified by
automated tests at the unit, emulator, or rules layer. **No requirement is currently verified
end-to-end on a physical Android or iOS device.**

The seven required user flows and the two-tier plan for covering them are defined in
`implementation/release/RELEASE_CHECKLIST.md` §2. Manual QA is owner-held and has not been claimed.

This is the single largest gap between "the system is built" and "the system is shown to work".

### Negative claims are supported, not proven

Two central claims are negative — they assert an absence:

1. *The client does not write XP.* Supported at close to proof strength: `firestore.rules` denies
   all client writes to `users/{uid}` unconditionally, and lists backend-owned keys explicitly for
   `userProfiles/{uid}`.
2. *Premium confers no competitive advantage.* Supported by the absence of entitlement checks from
   the progression calculators. **This is weaker.** Absence-from-inspection is not the same as a
   test that would fail if it changed. **Corrected 2026-07-31: such tests do exist** —
   `functions/test/completeRun.test.ts:1683` and `functions/test/completeCoolDown.test.ts:406`
   assert identical XP, leaderboard credit, and untouched client-authored fields across tiers, and
   the `premiumEarnsXp: false` suppression paths are covered too. The claim is therefore tested,
   not merely inspected. An earlier revision of this document asserted the gap without checking
   the suite, which is exactly the failure mode §8.2 is meant to guard against.

A screenshot establishes neither claim, which is why the release checklist requires a four-part
evidence bundle for the flows that depend on them.

### App Check covers a subset

8 of 61 exported functions enforce App Check; one (`subscribeNewsletter`) is deliberately public.
See §7.4. Broad enforcement would reject already-installed clients, so closing this needs a
client-first rollout rather than a configuration change.

## 8.3 Environment and process limitations

### There is no staging environment

Two environments exist: local emulators (`demo-*` projects) and production (`runiac-fypp`). A
change that cannot be validated against emulators cannot be validated before it reaches
production.

The mitigations are architectural rather than infrastructural: emulator-first development
(ADR-002), server-side feature flags and `config/*` documents so a misbehaving feature can be
disabled by a Firestore edit rather than an app store release, and the per-change-type
compatibility matrix in `implementation/release/DEPLOY_RUNBOOK.md` §1.

A staging project is the obvious future improvement.

### The mobile client cannot be rolled back

Of the seven change types in the deploy runbook, two are irreversible: data migrations and client
releases. A shipped install stays shipped. This is why the release checklist gates a client
release on every server-side pre-condition being satisfied first.

### The admin console is outside root CI

The website lives at `website/` and is git-ignored by the root repository, with its own git
history. Its 22 test files and roughly 180 cases therefore never run in root CI.

One practical consequence is visible today: `tests/cross-system/paywall-config-drift.mjs`
degrades to a loud `SKIP` in hosted CI because the file it compares against is absent, so that
contract is protected locally but not in CI. The fixture-to-Dart half of the same contract *is*
covered in CI.

## 8.4 Operational limitations

### Observability is uneven

Error reporting is strong: `functions/src/errors/withErrorReporting.ts` wraps callables, scheduled
functions, and triggers; `errorGroups/{fingerprint}` aggregates by fingerprint; `sanitize.ts`
redacts before persistence; `progressionAudit.ts` gives XP a full derivation trail.

General logging is not. Structured `firebase-functions/logger` calls appear in 3 files, while raw
`console.*` is used about 31 times across the backend. There is no request or trace correlation
ID, no per-callable latency metric, and no unified audit sink for administrator actions — those go
through domain-specific triggers instead.

### Scheduled functions fail silently

Six modules declare `onSchedule` handlers. A broken schedule has no caller to surface an error, so
failure is invisible until someone notices missing output. This is called out in
`implementation/release/ROLLBACK.md`, but there is no alerting.

### Roadmap state cannot be compacted

`implementation/roadmap/CURRENT.md` carries 40+ `- Newly routed …` and
`- Current active capsule …` lines. These are not prose: two governance CI scripts match them with
anchored regexes, and each match opens one capsule's path allow-list. Moving or rewording a line
silently revokes a permission branch.

The file therefore cannot shrink by editing. Compaction requires first migrating the checkers to a
structured manifest. Until then, a `## Canonical Current State` block at the top carries present
state and everything below it is a dated record.

## 8.5 Scope boundaries

Deliberately out of scope for this iteration, not defects:

- Territorial leaderboard mechanics beyond the implemented monthly aggregation.
- Medical or diagnostic guidance. Agent-generated summaries are explanatory only and cannot alter
  XP, rank, leaderboard score, or plan authority.
- **The expert plan governance workflow.** This is the largest gap between the design in sections
  1–6 and the implementation, and it is worth stating precisely rather than glossing.

  Designed: a Medical Trainer/Expert supplies plan content, and a Platform Administrator approves,
  publishes, updates, archives, rejects, suspends, or manages it.

  Implemented: `expertPlans` is a read-only Premium surface — `allow read: if isPremiumUser() &&
  resource.data.status == 'published'`, with all client writes denied and **no Cloud Function
  writing to the collection at all**. The Medical Trainer/Expert role does not exist in code;
  `functions/src/security/roles.ts` implements only `isPlatformAdminRole`. Published plans reach
  the collection through the Admin SDK, outside this repository.

  So the *consumption* half is built and enforced; the *authoring and approval* half is design
  intent. A future iteration needs the role, the draft lifecycle, the approval transitions, and an
  audit record of who published what.
- OAuth providers. Sign-in is email and password.

## 8.6 Future work, in priority order

1. **Device QA across the eight required flows**, both platforms — the largest verification gap.
   The flows are defined in `implementation/release/RELEASE_CHECKLIST.md` §2, derived from the app
   rather than from this document.
2. **App Check coverage decision and client-first rollout** — closes the attestation gap without
   breaking shipped clients.
4. **Routing manifest migration** — moves the governance CI anchors out of `CURRENT.md` so roadmap
   state can be compacted.
5. **Logging convention and alerting** — a structured logger standard, correlation IDs, and
   alerts on repeated scheduled-function failure.
6. **A staging project** — removes production as the first place a change meets real data.
7. **Admin console into CI** — brings the website suite and the paywall drift guard under hosted
   verification.
8. **Administrator audit sink** — a unified record of governance actions.
