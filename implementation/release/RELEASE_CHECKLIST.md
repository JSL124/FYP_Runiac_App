# Release Checklist

Answers one question: **is the app ready to put in front of users?**

For *how* to deploy, see `DEPLOY_RUNBOOK.md`. For *how to undo*, see `ROLLBACK.md`.

---

## The distinction this document exists to enforce

> **Feature deployed** ≠ **app release ready**

The roadmap currently conflates these. Many capsules record "backend deployed to `runiac-fypp`"
and stop there, while the mobile release that makes the feature reachable never happened. The
result is a growing set of features that are live on the server and invisible to every user.

Two separate states, tracked separately:

| State | Means | Evidence |
|---|---|---|
| **Deployed** | The server-side change is live | Post-deploy verification in `DEPLOY_RUNBOOK.md` §5 |
| **Release ready** | A user can actually reach it on a device | This checklist, fully green |

A capsule may close at *Deployed*. **The app may not be called shippable until *Release ready*.**

### Outstanding-release ledger

Maintain a single list of features that are Deployed but not Release ready, so the gap is one
number rather than an archaeology exercise across capsules. Each entry: feature, deploy date,
what is still needed, blocking or not.

---

## 1. Pre-release gates

Each is pass/fail. A red gate blocks the release.

| Gate | Check | Why |
|---|---|---|
| **App Check debug token** | The debug build's token is registered in the Firebase Console | Unregistered → every App Check-enforced callable fails on that build |
| **App Check coverage decision** | See the open question below | Decision, not cleanup |
| **Privacy consent** | Consent flow reachable and recorded before any GPS capture | GPS is sensitive user data per `AGENTS.md` |
| **Mapbox token** | Supplied at runtime via `--dart-define=MAPBOX_PUBLIC_ACCESS_TOKEN`, **never committed** | Runtime-only by policy |
| **turboSMTP** | Newsletter sending path configured and verified end to end | External dependency with no emulator |
| **Rules parity** | Live ruleset byte-identical to `firestore.rules` | `DEPLOY_RUNBOOK.md` §2 |
| **Index readiness** | All required indexes `READY`, none `CREATING` | A `CREATING` index fails queries at runtime |
| **Live inventory reconciled** | `functions:list` matches `index.ts` | `DEPLOY_RUNBOOK.md` §4 |
| **Governance CI** | Green on the release commit | 14 checks |
| **Backend suites** | `functions` and `tests/firebase-rules` green | ~1,000 + 139 cases |
| **Flutter suite** | `flutter analyze` and `flutter test` green | ~2,400 cases |
| **iOS SPM manifest** | `flutter build ios --config-only` run **after** any `flutter test` / `analyze` | Those commands reset the manifest to iOS 13.0 while Firebase needs 15.0 |
| **No formatter churn** | `git diff --stat` reviewed before commit | The local `dart format` is newer than the repo's and rewrites files it touches |

### Open question — App Check coverage

As of 2026-07-31: **8 callables** enforce App Check; `subscribeNewsletter` disables it
deliberately (public signup endpoint, correct); the remaining exports do not set the option.

This is a decision the project owner must make, not a defect to quietly fix. Enabling
enforcement broadly would reject requests from **already-shipped clients** that do not attach an
App Check token. Resolve it explicitly — either "current coverage is intended" or "extend
coverage, and here is the client-first rollout" — and record the answer here.

---

## 2. Required user flows

Verified on **both** Android and iOS unless noted. Evidence goes in `test-evidence/`, with the
redaction rules in `test-evidence/README.md` applied first.

### Tier 1 — core, both platforms

1. Sign up → sign in → onboarding
2. Start run → track → save activity
3. XP / level / streak reflected
4. Subscription entitlement and premium feature access

### Tier 2 — risk-based platform selection

5. Friends → feed → challenge interaction
6. Profile privacy settings and blocking
7. Errors, network loss, permission denial

### Flows 3 and 4 cannot be proven by screenshots

"The client does not write XP" and "Premium confers no competitive advantage" are **negative**
claims. A screenshot of a correct number does not establish either. Each needs a four-part
bundle:

| # | Evidence | Where |
|---|---|---|
| ① | Observed behaviour | Screenshot, `test-evidence/` |
| ② | Client direct-write **denied** | `tests/firebase-rules/` — deny cases on XP / level / rank / streak / leaderboard fields |
| ③ | Server computes the value | `functions/test/` |
| ④ | Basic and Premium use the identical formula | `functions/test/` |

Inventory what already exists before writing anything new — the rules suite has 139 cases, the
functions suites around 1,000, and `functions/src/progression/progressionAudit.ts` already
persists every XP derivation step to `progressionEvents`. That audit trail is the strongest
single artefact for ②–④.

---

## 3. QA data policy

- Dedicated QA accounts: Basic ×1, Premium ×1, Admin ×1.
- **No real personal data and no real GPS traces.** Synthetic routes only.
- Seed via `functions/package.json` → `leaderboard:seed:emulator`, `feed:fixtures:emulator`.
- Redact before recording evidence, using the same classes as
  `functions/src/errors/sanitize.ts`: coordinate pairs, labelled lat/lon, emails, URL query
  strings, digit runs of 5 or more. Also strip uids, tokens, and App Check debug tokens.

---

## 4. Sign-off

| Item | Owner | State |
|---|---|---|
| Pre-release gates all green | | |
| Tier 1 flows verified, both platforms | **User** | |
| Tier 2 flows verified, platform rationale recorded | **User** | |
| Evidence redacted and filed | | |
| Outstanding-release ledger updated | | |
| Rollback plan reviewed for this release | | `ROLLBACK.md` |

**Manual QA is user-owned.** No agent may mark flow verification complete; an agent prepares
scripts, seeds, and the recording template, then stops.
