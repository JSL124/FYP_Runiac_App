# 7. Security and Privacy Decisions

## 7.1 Purpose

Sections 1–6 describe what Runiac is designed to do. This section records the security and
privacy decisions that were actually made during implementation, where each one is enforced, and
what each one costs. It is written to be checkable: every claim names the file that enforces it.

Verified against `main` @ `6eb6efef` (2026-07-31). The requirement-to-test mapping lives in
`implementation/traceability/requirements-map.md` Part II.

## 7.2 Identity and the trust boundary

Firebase Authentication is the only identity source. The trust boundary sits at the Cloud
Functions layer: the Flutter client is treated as untrusted input, and every value that affects
progression, ranking, entitlement, or governance is computed server-side.

This is not a stylistic preference. It is what makes the Non-Negotiable rule "the client must not
calculate or write XP, level, rank, streak, or leaderboard score" enforceable rather than
aspirational.

## 7.3 Two-tier field protection

The data model splits user state across two documents, and each is protected by a different
mechanism. The split is deliberate.

### Tier 1 — total denial (`users/{uid}`)

```
match /users/{uid} {
  allow read: if isOwner(uid);
  allow create, update, delete: if false;
```

The client can read its own document and can **never write to it under any condition**. This is
where trusted progression state lives. The only writer is Cloud Functions through the Admin SDK,
which bypasses rules by design.

Total denial is stronger than field filtering because it cannot be defeated by a field the rules
author forgot to list.

### Tier 2 — explicit backend-owned key list (`userProfiles/{uid}`)

Profile documents must be client-writable — a runner edits their own nickname and avatar. So this
tier uses an allow-list of writable keys plus an explicit deny-list of backend-owned keys,
implemented as `backendOwnedKeys()` (`firestore.rules:21`) and enforced through
`doesNotTouchBackendOwnedKeys()` (`:128`) and `doesNotChangeBackendOwnedKeys()` (`:132`).

The list covers not only the primary values (`xp`, `totalXp`, `divisionTier`, `levelLabel`) but
also every **derived display value** (`nextLevelXp`, `levelProgressPercent`, `totalXpLabel`) and
every **intermediate term** of the XP calculation (`baseCompletionXp`, `distanceXp`, `durationXp`,
`rawXpBeforeDailyCap`, `dailyXpBefore`, `dailyXpAfter`, `activityCapApplied`).

Protecting the intermediates matters: a client that could write `dailyXpBefore` could defeat the
daily cap without ever touching `totalXp`.

The rules carry their own threat reasoning. On the streak milestone ledger (`:49`):

> *The ledger of which streak milestones have already been paid. An owner who could reset this
> could re-earn every milestone bonus.*

That is a recorded attack, not a generic comment.

## 7.4 App Check posture — stated honestly

App Check attests that a request comes from a genuine build of the app rather than a script.

**Current coverage: 8 of 61 exported functions enforce it**, through
`shouldEnforceAppCheck()` (`functions/src/security/appCheck.ts`), which returns false under the
emulator so local tests still run.

One function disables it deliberately: `subscribeNewsletter`
(`enforceAppCheck: false, invoker: "public"`). That is correct — a newsletter signup form on the
public website has no app build to attest.

The remaining exports do not set the option.

**This is recorded as an open decision, not presented as complete.** Enabling enforcement broadly
would reject requests from clients already installed on users' devices, which do not attach an App
Check token. Closing it requires a client-first rollout, and the decision is tracked in
`implementation/release/RELEASE_CHECKLIST.md`.

Note that App Check is a *defence in depth* layer here, not the primary control. Even without it,
§7.3 means an attacker with a valid token still cannot write progression state.

## 7.5 GPS and personal data

GPS traces, activity history, profile data, and running metrics are treated as sensitive.

**Storage.** Raw route data is owner-scoped. Publicly shared routes are masked before exposure.

**Logging and error reporting.** `functions/src/errors/sanitize.ts` redacts, before anything is
persisted to the `errorGroups` collection:

- coordinate pairs and labelled latitude/longitude
- email addresses
- URL query strings
- digit runs of five or more

The module deliberately over-redacts, and says why:

> *Losing a number out of a debugging string is cheap; leaking a runner's position is not.*

This is the right trade for a fitness app. The cost is real — some debugging strings lose
information — and it was accepted knowingly.

**Test data.** No real personal data and no real GPS traces are committed. QA uses synthetic
routes, seeded through `leaderboard:seed:emulator` and `feed:fixtures:emulator`.

## 7.6 Two independent access axes

Runiac deliberately separates two concerns that are often conflated:

| Axis | Field | Governs |
|---|---|---|
| Commercial tier | `subscriptionStatus` | Basic User vs Premium User feature access |
| Operational authority | `userRole` | Platform Administrator and Medical Trainer/Expert governance |

Neither implies the other. A Premium User has no governance authority; a Platform Administrator
gains no commercial features by virtue of the role.

Basic User and Premium User are **not modelled as subclasses** — they are the same entity with
different `subscriptionStatus`. This is what keeps the parity rule (§7.7) expressible.

Entitlement is enforced in `functions/src/config/featureEntitlement.ts`, server-side. Hiding UI is
never the control.

### Expert plans as currently implemented

Sections 1–6 describe a Medical Trainer/Expert who supplies plan content and a Platform
Administrator who approves and publishes it. **That workflow is not implemented in this
repository, and this section describes what is.**

```
match /expertPlans/{planId} {
  allow read: if isPremiumUser() && resource.data.status == 'published';
  allow create, update, delete: if false;
}
```

Expert plans are a **read-only Premium feature**. A Premium User can read a plan only when its
`status` is `published`; no client can write one under any condition; and no Cloud Function in
`functions/src/` writes to the collection either. `isPremiumUser()` (`firestore.rules:586`)
resolves the tier by reading `users/{uid}.subscriptionStatus`, which per §7.3 Tier 1 the client can
never write — so the entitlement cannot be forged client-side.

No Medical Trainer/Expert role exists in the code. `functions/src/security/roles.ts` implements one
role predicate, `isPlatformAdminRole`. The string `"expert"` elsewhere in the codebase is an
onboarding running-experience level (beginner / intermediate / expert), not a user role.

The unimplemented approval workflow is recorded as a scope boundary in §8.5 rather than claimed
here.

### Administrator operations

Administrator actions do not run through client-facing callables with a role check. The model is
different, and deliberately so.

Command collections are **totally client-inaccessible**:

```
match /leaderboardAdminCommands/{commandId} { allow read, write: if false; }
match /moderationCommands/{commandId}       { allow read, write: if false; }
match /badgeConfigs/{badgeId}               { allow read, write: if false; }
```

The admin console is a separate Next.js server holding Admin SDK credentials. Because the Admin SDK
bypasses rules by design, and because that server cannot invoke callables directly, an
administrator action is expressed as a **Firestore write plus trigger handoff**: the console
creates a command document, a Cloud Function trigger consumes it and performs the real work, then
merge-writes the outcome back onto the same document.

The security boundary is therefore **possession of Admin SDK credentials in the console
deployment**, not a role check inside these Functions.

What makes this safe is that the trigger **does not trust its own input**.
`functions/src/leaderboard/leaderboardAdminCommand.ts:23`:

> *SAFETY: admin recalculation is deliberately restricted to the CURRENT Singapore month, and the
> period is derived here rather than trusted from the command document.*

The same comment explains the attack this prevents: a command naming an older month would repoint
`leaderboardPeriods/monthly_current` and then delete every snapshot outside the three-month window
around that key. Deriving the period server-side rather than reading it from the command removes
the possibility entirely.

`isPlatformAdminRole` exists for the cases where a Function does need a role check, and reconciles
the canonical `"platformAdmin"` value with the legacy `"Platform Administrator"` spelling in one
place so the two cannot drift apart across call sites.

## 7.7 Premium confers no competitive advantage

Premium User and Basic User earn XP, level, rank, and leaderboard score under identical
server-owned rules. Premium sells coaching, analysis, approved expert plans, route convenience,
and presentation — never scoring.

**Supporting evidence:** entitlement checks do not appear in the progression calculators
(`functions/src/progression/progressionCalculator.ts`, `streakCalculator.ts`), and every
derivation step is persisted to `progressionEvents` by
`functions/src/progression/progressionAudit.ts`, so any divergence would be visible in the audit
record.

**Stated limitation:** absence of entitlement from the calculators is strong support, not a proof
of absence. A dedicated Basic-vs-Premium identical-formula regression test would close this. It
does not exist yet and is recorded in §8.

## 7.8 Verification surface

| Surface | Scale |
|---|---|
| `firestore.rules` | 1,231 lines, 57 `match` blocks |
| `storage.rules` | 94 lines |
| Rules tests | 12 files, 139 cases, ~40 collections |
| Cloud Functions tests | 82 files |
| Flutter tests | 259 files |

Both backend suites are enumerated by filename in `package.json`. Because an unlisted suite would
silently never run — and this has happened once, to the friends rules suite —
`tools/governance-ci/check-test-enumeration.sh` reconciles the enumerations against the files on
disk on every CI run.

## 7.9 Secrets

No secrets, API keys, service accounts, `.env*` files, `google-services.json`,
`GoogleService-Info.plist`, or precise private GPS data are committed. The Mapbox token is
supplied at runtime via `--dart-define=MAPBOX_PUBLIC_ACCESS_TOKEN` and never stored in the
repository. `tools/governance-ci/check-sensitive-paths.sh` enforces the deny and ignore coverage
on every CI run.

## 7.10 Decision log

| Decision | Enforcement point | Accepted cost |
|---|---|---|
| Client is untrusted; server computes all trusted values | Cloud Functions layer | Every progression change needs a deploy |
| `users/{uid}` totally client-deniable | `firestore.rules` | Profile edits need a second document |
| Backend-owned keys listed explicitly, including intermediates | `firestore.rules:21,128,132` | The list must be maintained as fields are added |
| Over-redact logs rather than under-redact | `functions/src/errors/sanitize.ts` | Some debugging information is lost |
| Tier and role kept independent | `subscriptionStatus`, `userRole` | Two fields to reason about instead of one |
| Premium never affects scoring | `progressionCalculator.ts` | Premium must sell something other than winning |
| App Check on a subset, deliberately | `functions/src/security/appCheck.ts` | Incomplete coverage; open decision (§7.4) |
