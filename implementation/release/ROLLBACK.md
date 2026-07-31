# Rollback

What to do when a deploy goes wrong. Companion to `DEPLOY_RUNBOOK.md`.

**"Roll back in reverse order" is not a procedure.** Reversibility differs per change type, and
two of the seven types are not reversible at all. Find your change type below.

---

## Decide first: roll back, or roll forward?

| Situation | Action |
|---|---|
| Change is reversible and the failure is understood | **Roll back**, then fix offline |
| Change is reversible but rolling back breaks a dependent change already deployed | **Roll forward** with a fix |
| Change is not reversible (data migration, client release) | **Roll forward only** |
| Cause unknown and users are actively affected | Roll back the most recent reversible layer to stop the bleeding, then diagnose |

Record the decision and its reason. A rollback that is not written down becomes tomorrow's stale
deploy record.

---

## Per change type

### Rules — loosening
**Reversible.** Redeploy the prior ruleset.

Fetch the prior ruleset by `createTime` from the Rules API, confirm it is the version you intend,
and deploy it. Do **not** reconstruct it by hand-editing `firestore.rules` — that risks shipping
unrelated committed-but-undeployed changes, the exact hazard `DEPLOY_RUNBOOK.md` §2 guards
against.

### Rules — tightening
**Reversible, with a caveat that cannot be undone.** Redeploy the prior ruleset as above.

Requests denied while the tightened rules were live are gone. If those were writes, the client
may have surfaced an error and discarded user input. Check whether the affected flow retries or
queues, and whether users need to be told.

### Index addition
**Reversible with cost.** An index can be deleted, but re-adding means rebuilding from scratch.

Before deleting, confirm no deployed function still queries it — a missing index is a runtime
query failure, not a graceful degradation. Usually the right move is to leave the index in place
and roll back the function instead. An unused index costs storage; a missing one costs
correctness.

### Function — new export
**Reversible.** Redeploy the previous version, or delete the function if it is genuinely new.

If it is new and nothing calls it yet, deleting is clean. If a shipped client already calls it,
deleting turns a bug into a hard failure — redeploy the prior version instead.

Scheduled functions: a broken schedule is **silent**. There is no caller to raise an error. After
rolling back a scheduled function, confirm the next fire actually succeeded rather than assuming
it did.

### Function — signature change
**Conditional.** Reversible only if no client has adopted the new shape.

If clients have adopted it, rolling back the server breaks them. Roll forward with a handler that
accepts both shapes, then retire the old one once adoption allows.

### Data migration
**Not reversible.** Do not attempt to "undo" by running a reverse migration against production.

Plan a forward fix. Use the backup taken as a pre-condition to determine correct values, write a
new idempotent correction script, prove it on emulators, and deploy it as its own change with its
own authorization.

### Client release
**Not reversible.** Installs already on devices stay there.

You can halt a staged rollout, which stops further exposure but does nothing for users already
updated. Recovery is a new build through review. Because of this, the server side must remain
compatible with the previous client version until adoption of the new one is sufficient — that
is why `RELEASE_CHECKLIST.md` gates a client release on every server pre-condition being
satisfied first.

---

## After any rollback

1. Re-run post-deploy verification (`DEPLOY_RUNBOOK.md` §5) against the rolled-back state — a
   rollback is a deploy and deserves the same evidence.
2. Confirm the live ruleset is byte-identical to whichever `firestore.rules` version is now
   intended.
3. Check `errorGroups` for fingerprints that appeared during the incident and confirm they stop.
4. Record in the capsule: what was deployed, what failed, which layer was rolled back, what
   remains broken, and what the forward fix is.
5. Update the outstanding-release ledger in `RELEASE_CHECKLIST.md` if the rollback re-opened a
   feature that had been considered shipped.

---

## What makes rollback hard here

Worth stating plainly, because it shapes every decision above:

- **There is no staging project.** Production is the first place a change meets real data.
- **Rules deploys are whole-file.** There is no partial rules rollback.
- **The client cannot be recalled.** Mobile is the one layer with no undo.

The practical consequence: push risk toward the layers that *can* be rolled back. Prefer a
server-side feature flag or a `config/*` document over a client-side constant, so that disabling
a misbehaving feature is a Firestore edit rather than an app store release.
