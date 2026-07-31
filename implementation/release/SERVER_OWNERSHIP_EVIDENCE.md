# Server-Ownership Evidence Inventory

The ②③④ half of the T1-3 / T1-4 evidence bundle defined in `RELEASE_CHECKLIST.md`
§"T1-3 and T1-4 cannot be proven by screenshots". Screenshots (①) are user-owned and
produced during manual QA; this file is the code-side half, and it is an **inventory of
what already exists**, not a plan for new tests.

**Result: no new tests are required.** Every claim below maps to a test case that already
exists and already executes in CI. The two things a QA run must still do are the
production-config checks in §4 — those are state, not code, so no test can stand in for
them.

Line numbers are anchors as measured on `main` @ `8f0adb21`. If a cited case moves, the
claim it supports is what matters — re-locate by test name, not by line.

---

## 1. Why these suites count as evidence at all

A test only proves something if it runs. Both enumerations that gate these suites are
themselves guarded:

- `tools/governance-ci/check-test-enumeration.sh` fails CI if a suite file exists but is
  absent from the `functions/package.json` / `tests/firebase-rules/package.json` script
  lists. This gap has bitten this repository before — the Friends rules suite had never
  executed in CI (`capsules/review-triage-notification-privacy-quota.md` fix #8).
- All eight progression/leaderboard suites cited below are enumerated today (verified
  against the five `functions/package.json` scripts).
- The rules suites run under `firebase emulators:exec` against `demo-runiac-feed`, wired
  into the `backend-emulator-tests` CI job.

Counts as executed on `main` @ `8f0adb21`, run locally on 2026-07-31:

| Suite | Result |
|---|---|
| `tests/firebase-rules` | **147 pass / 0 fail**, 17 `describe` suites across 12 files |
| `functions` (5 emulator batches) | **1,082 pass / 0 fail** (712 / 134 / 25 / 177 / 34) |

The rules figure is the runner's executed-case count and is slightly higher than the 139
`it(...)` declarations counted statically, because at least one block is parameterized —
`feed.storage.rules.test.mjs:92` expands one declaration into eight cases.
`firestore.rules.test.mjs` alone declares 60 of the 139.

---

## 2. ② Client direct-write is denied

The deny surface is centralised, not scattered: `firestore.rules` declares one
`backendOwnedKeys()` list (`firestore.rules:21-126`) naming every server-owned field —
`xp`, `totalXp`, `weeklyXp`/`weeklyXP`, `monthlyXp`/`monthlyXP`, `streak`, `streakCount`,
`longestStreak`, `level`, `rank`, `leaderboardScore`, `scoreXp`, `divisionKey`,
`subscriptionStatus`, `subscriptionPrivilegeState`, `userRole`,
`expertPlanPublicationState`, and the
`highestPaidStreakMilestoneDays` ledger that would otherwise let an owner re-earn every
streak milestone bonus.

| Claim | Case | Asserts |
|---|---|---|
| No client write to any named progression field | `tests/firebase-rules/firestore.rules.test.mjs:555-600` | One payload carrying `xp`, `weeklyXP`, `monthlyXP`, `streak`, `streakCount`, `level`, `rank`, `leaderboardScore`, `validationStatus`, `expertPlanPublicationState` — `assertFails`; and a second payload zeroing the same fields also `assertFails` (writing *down* is denied too) |
| Field-by-field, not just as a bundle | `tests/firebase-rules/firestore.catalog.rules.test.mjs:31-54` | Separate `assertFails` per field: `xp`, `streak`, `level`, `rank`, `leaderboardScore`, plus a `leaderboardSnapshots` write carrying `rank` |
| Deleting a backend-owned field is denied | `tests/firebase-rules/firestore.rules.test.mjs:66-103` | `xp: deleteField()`, `totalXpLabel: deleteField()` `assertFails` alongside `totalXp`, `monthlyXp`, `monthlyXpLabel`, `level`, `divisionKey`, `nextLevelProgressPercent`, `monthlyXpAfter` |
| Streak state specifically | `tests/firebase-rules/firestore.rules.test.mjs:675-696` | `streakCount`, `streakUpdatedAt`, and `streakCount: deleteField()` all `assertFails` |
| Role and tier cannot be self-granted | `tests/firebase-rules/firestore.rules.test.mjs:106-127` | `userRole` and `subscriptionStatus` writes `assertFails` |
| Leaderboard collections are read-only to clients | `tests/firebase-rules/firestore.rules.test.mjs:170-242` | Reads of own `leaderboardCurrentViews` / `leaderboardUserRanks` succeed, another user's fail; writes to `leaderboardCurrentViews`, `leaderboardAggregationLocks`, `leaderboardSeedRuns`, `leaderboardAdminCommands` all `assertFails`, and `leaderboardAdminCommands` is not even readable |
| Backend-owned plan progress | `tests/firebase-rules/firestore.rules.test.mjs:446-464` | Owner may read; every client `set`/`update`/`delete` `assertFails` |

**Positive controls are present**, which is what makes the denials meaningful rather than a
blanket lockout: `firestore.rules.test.mjs:58-63` confirms an owner *can* write safe
profile fields, and `:170-210` confirms leaderboard views are readable.

---

## 3. ③ The server computes the value

`functions/src/progression/progressionAudit.ts` persists every derivation step to
`progressionEvents`, so the claim is provable from the stored record and not only from the
returned display value. Exactly two callables award XP — `functions/src/run/completeRun.ts`
and `functions/src/run/completeCoolDown.ts` — confirmed by tracing every importer of the
progression writer. `challengeLobbyCore.ts` and `featureEntitlement.ts` import only the
`isPremiumSubscription` *detector*, never the writer, so challenges award no XP and need no
parity case.

| Claim | Case | Asserts |
|---|---|---|
| XP derivation is server-recorded, step by step | `functions/test/completeRun.test.ts:152-192` | `progressionEvents` doc holds `baseCompletionXp` 20, `distanceXp` 40, `durationXp` 15, `dailyXpBefore`/`dailyXpAfter`, `previousTotalXp`/`nextTotalXp`, `monthlyXpBefore`/`monthlyXpAfter`, `previousLevel`/`nextLevel` — alongside the `userProfiles` fields |
| Client-authored progression fields are ignored | `functions/test/completeRun.test.ts:1683-1707` | Pre-seeded `xp: 999`, `rank: 3`, `leaderboardScore: 999` stay at 999 while the server writes `totalXp: 60`, `monthlyXp: 60` |
| The formula itself | `functions/test/progressionCalculator.test.ts` (35 cases) | Level thresholds (Lv.2 at 100 XP, Lv.20 at 2400, Lv.100 at 53600, clamped at `maxLevel`), 100-XP activity cap, Asia/Singapore daily cap and its date derivation, streak milestone selection and the already-paid ledger, bonus rounding and flooring |
| Config drives the formula, not the client | `functions/test/completeRun.test.ts:1750+` | Seeding `config/progression.xpPerKilometer: 20` doubles `distanceXp` from 30 to 60 for the same payload |
| Streak state is server-derived | `functions/test/completeRun.test.ts:660-1078`, `functions/test/streakExpiry.test.ts` (6 cases) | Consecutive-day increment, rest-day continuation, missed-day reset, lifetime longest streak surviving a reset, no double-increment on duplicate `clientRunSessionId`, no regression when an older run syncs late |
| Cool-down bonus is server-computed | `functions/test/completeCoolDown.test.ts:185-405` | Bonus derived from the *credited daily-capped* run XP rather than the raw pre-cap value; reduced then zeroed as the daily cap fills; idempotent on replay |
| Leaderboard score is server-aggregated | `functions/test/monthlyLeaderboard.test.ts` (13), `functions/test/monthlyLeaderboardWriter.test.ts` (16), `functions/test/levelUpLeaderboard.integration.test.ts` (2) | Ranking plan construction, malformed-row rejection, emulator-backed writer behaviour |
| Premium status is server-derived, with expiry | `functions/test/progressionAuditHelpers.test.ts` (10 cases) | `subscriptionExpiresAt` handling incl. the boundary instant, unparseable values, and the legacy capitalised `'Premium'` status |
| Replay cannot inflate anything | `functions/test/completeRun.test.ts:1569`, `:1649`, `:1988` | Idempotent on duplicate session id; a changed payload under a reused id is rejected; the streak bonus is never paid twice |

---

## 4. ④ Basic and Premium use the identical formula

Every XP-awarding path has an explicit parity case, and each one also has its suppression
counterpart tested, so the two directions are distinguishable in the suite rather than
conflated.

| Path | Parity case | Suppression counterpart |
|---|---|---|
| Run XP + leaderboard credit | `functions/test/completeRun.test.ts:1683` — premium earns `xpDelta` 60 with `countsTowardLeaderboard: true`, identical to basic | `:1710` (`premiumEarnsXp: false` → `xpDelta` 0, reason `premium_no_progression`) |
| Streak milestone bonus | no separate parity case, and none is needed: `progressionAudit.ts:89,117-120` gates the bonus on the *same single* `suppress` flag as the base XP, so with `premiumEarnsXp: true` the milestone computation never reads the tier at all | `:1926` (bonus suppressed together with the base) |
| Cool-down bonus | `functions/test/completeCoolDown.test.ts:406` — "a premium runner must earn the same stretch bonus a basic runner earns" | `:429` |
| Leaderboard inclusion (emulator) | `functions/test/monthlyLeaderboardWriter.test.ts:149` — premium included by default when `config/leaderboard` is absent | `:175` (`excludePremium: true` → `status: 'ineligible_premium'`) |
| Ranking order (pure) | `functions/test/monthlyLeaderboard.test.ts:121` — "ranks a premium runner by default, ordering by score alone" | `:88-114` |

### The two production preconditions QA must record

Parity is the **default**, not a hard invariant — it is configuration, and the
configuration is editable from the admin console
(`website/src/components/admin/GamificationRules.tsx:369`). No test can prove what the
production documents currently hold, so a QA run must read them and record the values:

| Document | Field | Required value | Code default |
|---|---|---|---|
| `config/progression` | `premiumEarnsXp` | `true`, or the document absent | `functions/src/config/configLoader.ts:120` → `true` |
| `config/leaderboard` | `excludePremium` | `false`, or the document absent | `functions/src/config/configLoader.ts:137-142` → `false` |

Both defaults are mirrored on the website side
(`website/src/lib/admin/config-validation.ts:125` and `:146`), and the mirror is guarded:
`tests/governance/config_contract_drift_test.sh` compares `DEFAULT_PROGRESSION_CONFIG` and
`DEFAULT_LEADERBOARD_CONFIG` across the two codebases on every CI run, so the admin console
cannot drift away from what the Functions actually apply.

Two things to state plainly in the evidence record rather than leave implicit:

1. **The divergence path makes Premium worse, never better.** `premiumEarnsXp: false`
   zeroes a premium runner's XP; there is no configuration that pays a premium runner
   *more*. The non-negotiable rule is "paying changes the scoring formula in neither
   direction", so the suppression path is a deviation in the harmless direction — but it is
   still a deviation, and it must be confirmed off in production rather than assumed off.
2. **The two flags interact.** `configLoader.ts:139-141` records it: setting
   `excludePremium: true` without also clearing `premiumEarnsXp` would rank premium runners
   at a permanent zero rather than removing them from the board.

---

## 5. What this inventory does not establish

Stated so the bundle is not over-read:

- **Nothing about the shipped client build.** These are server and rules tests. That the
  installed app does not *attempt* a forbidden write is shown by ① plus the rules denial,
  not by ③.
- **`advancedAnalysis` has no server-side gate** and is out of scope here — it is computed
  on-device from the user's own run data, so there is no server-held value to withhold.
  `RELEASE_CHECKLIST.md` §T1-4 already records why that is defensible.
- **Emulator, not production.** The rules cases run against `demo-runiac-feed`. Live-rules
  drift is a deploy-time check, covered by `DEPLOY_RUNBOOK.md`, not by this inventory.

---

## 6. Re-running the evidence

Both suites need JDK 21 for the Firebase emulators; on macOS the shell default is often
older, which fails with a Java version error before any test runs.

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
(cd functions && npm test)              # 1,082 cases, 5 emulator batches
(cd tests/firebase-rules && npm test)   # 147 cases under the emulator
./tools/governance-ci/run-all-checks.sh # incl. check-test-enumeration.sh
```

`functions`' `test` script already chains `npm run build`, so no separate compile step is
needed — the Functions emulator loads `lib/`, not `src/`.

Record the run date, the commit, and the pass counts in the QA evidence record
(`QA_EVIDENCE_TEMPLATE.md`) rather than in this file — this file describes the mapping,
which changes only when the tests do.
