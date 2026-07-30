# website-newsletter-subscription

## Parent Phase / Lane

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed), as an explicitly user-routed Backend Guarded Lane full-stack capsule under ADR-002 Emulator First and ADR-003.

## Status

Routed and implemented on 2026-07-30 Asia/Singapore, and — with separate explicit user authorization — committed, pushed, and deployed to production `runiac-fypp` the same day. All five functions (`subscribeNewsletter`, `confirmNewsletterSubscription`, `unsubscribeNewsletter`, `newsletterCampaignQueued`, `sweepUnconfirmedSubscribers`) were created as new `asia-southeast1` deployments, `firestore.rules` (the four deny-all newsletter blocks) was released, and the `newsletterSubscribers` `status`+`createdAt` composite index was deployed. The Trigger Email extension integration was verified end to end with a real send. Local evidence at ship time: `functions` build clean with the newsletter `node:test` suite 40/40 on in-memory ports, Governance CI PASS, and the deny-all rules test written and registered but NOT executed (it needs the Firestore emulator suite; that remains the one unverified validation item). The backend branch is `feat-newsletter-subscription` (PR Runiac_App#46, first commit `154dfac6`); the website half shipped on the same-named branch in the separate `FYP-website_v2` repository (PR #19, first commit `c34c8ff`). Codex PR review follow-ups (transactional confirm/unsubscribe, resumable campaign fan-out via lease+cursor, re-subscribe retention-clock refresh, production export-guard registration, website audit-log atomicity, test-send status polling, and a client-side Functions-emulator connection) land as additional commits on those same branches.

## Goal

Replace the dummy hero email form on the marketing website with a real, provider-agnostic double opt-in newsletter subscription, entirely decoupled from the mobile app's `users` collection: a visitor submits an email through a new unauthenticated callable, receives a confirmation link via the Firebase Trigger Email extension, and can later unsubscribe through a one-click link. A separate `/admin/newsletter` console (in the git-ignored `website/` repo) lets a Platform Administrator list subscribers, compose and test-send, and queue a campaign send, all through command documents rather than direct writes, mirroring the existing admin-command pattern.

## Contract Summary

- `subscribeNewsletter` (onCall, region `asia-southeast1`, unauthenticated allowed — the website has no signed-in user and no App Check, so this callable is deliberately not App Check enforced): request is `{email}` plus an empty honeypot field the client never populates; a filled honeypot is silently accepted-and-dropped rather than rejected, to avoid teaching bots which signal failed. Rate limited to 5 submissions per hour per hashed IP via a transactional `newsletterRateLimits/{hashedIp}` counter document. On success, writes a `newsletterSubscribers/{sha256(emailLower)}` document in `pending` status with a random confirmation token (stored only as its sha256 hash) and a `mail` collection document addressed to the raw email, so the Trigger Email extension sends the confirmation link without this repo depending on any specific email provider.
- `confirmNewsletterSubscription` (onRequest GET, `subscriberId` + raw `token` query params): recomputes the token hash, compares against the stored hash, flips status to `confirmed`, and 302-redirects to the website's `/newsletter/confirmed` (or `/newsletter/invalid` on mismatch/expiry) status page. `unsubscribeNewsletter` (onRequest GET, same `subscriberId` + raw token shape, its own token) flips status to `unsubscribed` and redirects to `/newsletter/unsubscribed`. Neither handler ever renders subscriber data; both only redirect.
- `newsletterCampaignQueued` (onDocumentWritten trigger on a queued campaign command document) fans a campaign out into per-subscriber `mail` collection docs, using a `newsletterCampaigns/{campaignId}/deliveries/{subscriberId}` document `create()` as an idempotency lock so a retried trigger invocation cannot double-send. This is the same command-document-plus-trigger shape already used by `moderationCommand.ts` and `leaderboardAdminCommand.ts`, chosen for the same reason: the Next.js admin console has no way to call an `onCall` callable from a server action, only to write a Firestore document the trigger then observes.
- `sweepUnconfirmedSubscribers` (daily schedule, `asia-southeast1`) deletes `pending` subscribers older than 30 days and stale `newsletterRateLimits` documents past their window. Needs one new `newsletterSubscribers` composite index on `status` + `createdAt` to back the sweep query.
- Firestore collections: `newsletterSubscribers` (doc id `sha256(emailLower)`, so re-subscribing the same address is idempotent by construction), `newsletterCampaigns` (with a `deliveries` subcollection), `newsletterRateLimits`, and the shared `mail` collection the Trigger Email extension watches. All four are deny-all to clients in `firestore.rules`; every read and write is Admin SDK only, from the callable, the two `onRequest` handlers, the trigger, or the schedule.
- Newsletter subscribers are a completely separate list from the mobile app's `users` collection: no shared document id, no cross-reference, no code path linking a subscriber to an app account. This capsule adds zero mobile app surface.
- App Check is deliberately not enforced on `subscribeNewsletter`, unlike every callable the mobile app calls. The website has no App Check attestation available to it, so the trade-off is accepted and compensated with the honeypot field, the hashed-IP rate limit, and double opt-in (a bot can enqueue a `pending` row and a confirmation email, but cannot reach `confirmed` status or receive campaign mail without controlling the mailbox).

## Allowed Scope

- `implementation/roadmap/capsules/website-newsletter-subscription.md` (this file).
- `firestore.rules` (newsletter deny-all block for the four collections above).
- `firestore.indexes.json` (the `newsletterSubscribers` `status`+`createdAt` composite index).
- `functions/src/newsletter/*` (the five functions — `subscribeNewsletter`, `confirmNewsletterSubscription`, `unsubscribeNewsletter`, `newsletterCampaignQueued`, `sweepUnconfirmedSubscribers` — and their shared helpers: token hashing, rate-limit counter, honeypot check).
- `functions/test/newsletter*.ts` (in-memory-port `node:test` coverage for the five functions).
- `functions/src/index.ts` (the five new export lines only).
- `functions/package.json` (only to register the new test files in the `npm test` file list).
- `tests/firebase-rules/newsletter.firestore.rules.test.mjs` (deny-all coverage for the four collections against the Firestore emulator).
- `tests/firebase-rules/package.json` (only to register that rules test).
- The website half of this feature — the hero form, `/newsletter/confirmed|unsubscribed|invalid` status pages, and the `/admin/newsletter` console — lives entirely in the separate, git-ignored `website/` repository and never appears in this repo's diffs; it is out of this repo's governance scope by construction, not by exemption.

## Forbidden Scope

- No production `runiac-fypp` deploy of any kind without separate explicit authorization.
- No commit or push under this capsule.
- No installing the Firebase Trigger Email extension and no other Firebase project configuration change (extension install, secret creation, IAM change) — the `mail` collection contract is implemented against, but the extension itself is not provisioned by this capsule.
- No client-side write of any backend-owned value (subscriber status, token hash, rate-limit counters, campaign delivery state).
- No linkage of any kind to the `users` collection or any mobile app surface.
- No new dependencies and no secrets.
- No edits inside the isolated `adaptive-character-guidance` worktree.

## Validation

- `functions`: `npm run build` clean; the new `newsletter*` `node:test` suite passes on an in-memory ephemeral port.
- `tests/firebase-rules`: newsletter deny-all suite passes against the running Firestore emulator alongside the existing rules-test family.
- Governance CI (`./tools/governance-ci/run-all-checks.sh`) PASS with this capsule routed and its allowlist wired.
