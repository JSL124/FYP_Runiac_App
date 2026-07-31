# Deploy Runbook

How to get a change into `runiac-fypp` safely. Companions: `RELEASE_CHECKLIST.md` (is the *app*
ready to ship) and `ROLLBACK.md` (how to undo).

**This runbook is procedure, not authorization.** `firebase deploy` and `flutter build` are
classified high-risk in `tools/agent-review/runner/classify_high_risk_task.sh`. Every deploy
needs explicit user authorization for that specific change.

---

## 0. Environments

| Environment | Project | Used for |
|---|---|---|
| Local emulator | `demo-*` (e.g. `demo-runiac-feed`, `demo-runiac-integration`) | All development and automated tests. ADR-002 Emulator First. |
| Production | `runiac-fypp` | The only live environment. There is no staging project. |

**There is no staging tier.** Treat that as a real constraint: a change that cannot be validated
against emulators cannot be validated before production. Where that is unacceptable, the answer
is a feature flag or a config document, not a hopeful deploy.

All Cloud Functions are single-region: `region: "asia-southeast1"` appears once per export
(61 of 61 as of 2026-07-31).

---

## 1. There is no fixed deploy order

An earlier draft of this runbook prescribed `rules → indexes → functions → client` with "roll
back in reverse". That is wrong and was removed:

- Indexes must finish **building** before a function that queries them is deployed. Build is
  asynchronous and can take minutes to hours.
- Deploying **tightened** rules first can lock out clients that are already in users' hands.
- Data migrations are not undone by running the sequence backwards.

Derive the order per change from the matrix below, and record the derivation in the capsule.

### Change-type compatibility matrix

| Change type | Pre-condition | Post-condition | Reversible? |
|---|---|---|---|
| **Rules — loosening** | Confirm no currently-shipped client depends on the denial | Smoke the newly allowed path | Yes — redeploy the prior ruleset |
| **Rules — tightening** | **Confirm no unshipped-client lockout.** Enumerate which shipped app versions still write the field being restricted | Regression-check existing flows | Yes, but requests denied in the interim are not recoverable |
| **Index addition** | — | **Wait for state `READY`** before deploying any function that depends on it | Yes, but rebuild cost on re-add |
| **Function — new export** | Dependent indexes `READY`; dependent rules already deployed | Invoke smoke; watch error rate | Yes — delete or redeploy prior |
| **Function — signature change** | **Is the shipped client compatible?** If not, ship the client first and deploy the server change only once adoption is sufficient | Verify both old and new client shapes work | Conditional — depends on client adoption |
| **Data migration** | Backup taken; script proven idempotent on emulator | Verification query returns expected counts | **No — plan a forward fix, not a rollback** |
| **Client release** | Every server-side pre-condition above satisfied | Store review, staged rollout | Only by halting rollout — shipped installs stay shipped |

Two orderings follow directly from the matrix and are worth stating:

- **Rules tightening + client change** → client first, rules second.
- **Index + function that uses it** → index first, wait for `READY`, function second.

---

## 2. Pre-deploy: diff the live ruleset

*Promoted from `implementation/roadmap/capsules/profile-stats-visibility.md:68`, where this was
recorded once as prose. It is a data-loss guard, not a nicety.*

`firebase deploy --only firestore:rules` **replaces the entire ruleset**. If the working tree
contains a committed-but-undeployed rules change from some other capsule, that change ships too
— silently, as a side effect of your deploy.

Before any rules deploy:

1. Fetch the live ruleset from the Firebase Rules API and note its `createTime`.
2. Diff it against `firestore.rules` in the working tree.
3. **The only differences must be the lines your change intends.** If anything else appears,
   stop and find out who owns it.

Record the live `createTime` and the diff summary in the capsule before proceeding. The
reference entry reads: *"the live ruleset (`createTime 2026-07-28T12:28:05Z`) was fetched and
diffed against the working tree before deploying … The only difference was this capsule's 18
added lines."*

The same reasoning applies to `storage.rules`.

---

## 3. Deploy inventory

`functions/src/index.ts` is a re-export barrel — 61 symbols as of 2026-07-31. It gives you
**names only**. A deploy decision needs more:

| Column | Source |
|---|---|
| Export name | `functions/src/index.ts` |
| Trigger type | `onCall` / `onRequest` / `onSchedule` / `onDocument*` in the defining module |
| Region | `region:` in the defining module (all `asia-southeast1` today) |
| App Check | `enforceAppCheck:` in the defining module |
| Auth required | whether the handler reads `request.auth` |
| Related rules | collections the handler writes |
| Related indexes | composite queries the handler issues |
| **Live state** | **not derivable from source — see §4** |

Scheduled functions deserve separate attention: they have no caller to smoke-test, so a broken
schedule is silent until the next fire. Six modules declare `onSchedule` handlers.

### Known App Check position (2026-07-31)

- **8 callables** enforce App Check through `shouldEnforceAppCheck()`.
- **1** disables it deliberately: `newsletter/subscribeNewsletter.ts:64`
  (`enforceAppCheck: false, invoker: "public"`) — correct for a public signup endpoint.
- The remaining exports do not set the option.

This is recorded, not judged. Whether the unset exports should enforce App Check is an open
release-gate question in `RELEASE_CHECKLIST.md`; changing it could break already-shipped clients
and is a decision, not a cleanup.

---

## 4. Live inventory — approval-gated, read-only

Source presence is **not** deployment evidence. The roadmap has already drifted on exactly this:
`CURRENT.md` once recorded `completeRun` and `completeCoolDown` as "NOT deployed" while both were
`ACTIVE` in production.

With explicit user approval, and read-only:

```bash
firebase functions:list --project runiac-fypp
firebase firestore:indexes --project runiac-fypp
```

Reconcile the result against `functions/src/index.ts`. Three outcomes matter:

- **In source, not live** — never deployed, or deleted out from under us.
- **Live, not in source** — an orphan still serving traffic. Investigate before deleting.
- **Both** — compare `updateTime` against the commit that last touched the module.

Run this reconciliation before any release, and whenever a capsule claims a deploy status. It is
the structural fix for stale deploy records.

---

## 5. Post-deploy verification

*Also promoted from `capsules/profile-stats-visibility.md:70-74`.*

For every deploy, record:

- **Rules** — re-fetch the live ruleset and confirm it is byte-identical to the repository's
  `firestore.rules`. Note the new `createTime`.
- **Functions** — for each deployed function, record region, `updateTime`, and state (expect
  `ACTIVE`).
- **Indexes** — confirm `READY`, not `CREATING`.
- **Backward compatibility** — state explicitly why already-shipped clients still work. The
  reference entry: *"`statsHidden` is an added field that older shipped clients ignore, and
  `publicStatsHidden` is a new writable key no shipped client writes yet."*
- **Errors** — check the `errorGroups` collection for new fingerprints after the deploy.

If a deploy leaves the mobile release outstanding, say so in the same breath — that is the
distinction `RELEASE_CHECKLIST.md` exists to keep honest.

---

## 6. Recording the deploy

Every deploy gets an entry in the capsule that authorized it, containing: date and timezone, the
exact `--only` scope, the derivation of the order from §1, the pre-deploy ruleset diff from §2,
the post-deploy verification from §5, and what remains outstanding.

Write it as a dated record, not as present-tense state. `CURRENT.md` → `## Canonical Current
State` is the only place that describes the present.
