# legal-documents-and-links

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed)

## Mode / Type

Mode: implementation-approved by the user's explicit request on 2026-07-26 to plan and build both the hosted legal pages and the in-app link wiring.

Type: marketing-site content (git-ignored `website/`) plus a Flutter client capsule that adds one approved dependency and the minimum native query configuration it requires. No Firebase, Firestore, Cloud Functions, rules, or backend-owned value work.

## Status

Status: In progress.

Routed on: 2026-07-26 Asia/Singapore.

Plan of record: `/Users/leejinseo/.claude/plans/twinkly-booping-walrus.md` and this capsule.

## Goal

Publish real Terms of Service, Privacy Policy, Account Deletion, and Cookies documents on the Runiac marketing site, and turn the app's existing non-tappable legal copy into functional links that open those documents in an in-app browser.

Today the copy exists but nothing is reachable:

- `implementation/mobile/runiac_app/lib/features/auth/presentation/widgets/runiac_welcome_auth_body.dart` renders `Terms` and `Privacy Policy` as link-styled `TextSpan`s with no recognizer.
- `implementation/mobile/runiac_app/lib/features/paywall/presentation/premium_paywall_sheet.dart` renders underlined labels with an in-code note that no hosted policy pages exist.
- `website/src/components/Footer.tsx` points its Legal column at `#`.

Store-compliance driver: Apple Guideline 3.1.2 requires functional Terms/EULA and Privacy Policy links inside the app binary on subscription surfaces, and Google Play requires an in-app privacy policy link plus a web-accessible account-deletion request URL for apps that create accounts.

## User Approvals Recorded

- Add the `url_launcher` dependency to `implementation/mobile/runiac_app/pubspec.yaml` (otherwise forbidden by `implementation/AGENTS.md`).
- Edit `ios/Runner/Info.plist` and `android/app/src/main/AndroidManifest.xml` for the query entries `url_launcher` needs (otherwise forbidden native configuration).
- Author real document drafts under Singapore PDPA framing with `admin@runiac.app` as the contact.
- Keep the app's legal URLs in a Dart constants file rather than extending the Firestore `config/paywall` schema.

## Allowed Scope

Website (git-ignored, not covered by Governance CI diff hygiene):

- New `website/src/components/LegalDocument.tsx` presentational component.
- New `website/src/app/legal/terms/page.tsx`, `website/src/app/legal/privacy/page.tsx`, `website/src/app/legal/account-deletion/page.tsx`, `website/src/app/legal/cookies/page.tsx`.
- `website/src/app/globals.css` — one `.legal-page` long-word overflow guard mirroring the existing `.about-page` rule.
- `website/src/components/Footer.tsx` — replace the three `#` placeholders in the Legal column.
- New `website/src/components/__tests__/LegalDocument.test.tsx` unit test.

Flutter client:

- `pubspec.yaml` / `pubspec.lock` — add `url_launcher`.
- `ios/Runner/Info.plist` — append `https`/`http` to the existing `LSApplicationQueriesSchemes` array.
- `android/app/src/main/AndroidManifest.xml` — add the `ACTION_VIEW` + `https` intent to the existing `<queries>` block.
- New `lib/core/legal/runiac_legal_urls.dart` (constants) and `lib/core/legal/runiac_url_opener.dart` (injectable opener seam).
- New `lib/core/widgets/runiac_legal_links_text.dart` shared inline-link widget.
- `lib/features/auth/presentation/widgets/runiac_welcome_auth_body.dart` — use the shared widget.
- `lib/features/paywall/presentation/premium_paywall_sheet.dart` — make the existing footer labels tappable.
- `lib/features/profile/presentation/about_runiac_screen.dart` — two new rows beside the existing licenses row.
- `lib/features/profile/presentation/privacy_safety_screen.dart` — one row linking to the full policy.
- `DESIGN.md` — component sections for the new shared widget and opener seam.
- New and extended widget tests under `test/`.

Governance:

- This capsule document, the `CURRENT.md` routing entry, and the `tools/governance-ci/check-diff-hygiene.sh` registrations this capsule requires.

## Forbidden Scope

- No Firestore `config/paywall` schema change. `PaywallFooterConfig` keeps exactly its current fields, so `tests/cross-system/fixtures/paywall-config-defaults.json`, `website/src/lib/admin/paywall-config.ts`, and `website/src/components/admin/PaywallConfigEditor.tsx` stay untouched and the paywall drift pin stays green.
- No Firebase, Firestore rules, Cloud Functions, Storage, App Check, or deploy work.
- No account-deletion implementation. The Account Deletion page documents the request path only; building an in-app deletion flow is a separate capsule.
- No consent-state persistence (`acceptedTermsVersion` or equivalent).
- No new `UserProfileManageAction` enum value or MANAGE-row plumbing; the About screen carries the entries.
- No sitemap, robots, or `metadataBase` introduction on the website.
- No XP, level, rank, streak, leaderboard, or subscription-privilege logic.
- No change to the adaptive-character-guidance or home-social-dropdown-friends-shell capsule surfaces.
- No staging, commit, push, or deployment.

## Exact Target Files

- `implementation/roadmap/capsules/legal-documents-and-links.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh`
- `implementation/mobile/runiac_app/pubspec.yaml`
- `implementation/mobile/runiac_app/pubspec.lock`
- `implementation/mobile/runiac_app/ios/Runner/Info.plist`
- `implementation/mobile/runiac_app/android/app/src/main/AndroidManifest.xml`
- `implementation/mobile/runiac_app/lib/core/legal/runiac_legal_urls.dart`
- `implementation/mobile/runiac_app/lib/core/legal/runiac_url_opener.dart`
- `implementation/mobile/runiac_app/lib/core/widgets/runiac_legal_links_text.dart`
- `implementation/mobile/runiac_app/lib/features/auth/presentation/widgets/runiac_welcome_auth_body.dart`
- `implementation/mobile/runiac_app/lib/features/paywall/presentation/premium_paywall_sheet.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/about_runiac_screen.dart`
- `implementation/mobile/runiac_app/lib/features/profile/presentation/privacy_safety_screen.dart`
- `implementation/mobile/runiac_app/DESIGN.md`
- `implementation/mobile/runiac_app/test/runiac_legal_links_text_test.dart`
- `implementation/mobile/runiac_app/test/about_runiac_screen_test.dart`
- `implementation/mobile/runiac_app/test/premium_paywall_sheet_test.dart`
- `implementation/mobile/runiac_app/test/privacy_safety_screen_test.dart`
- `website/**` per Allowed Scope (git-ignored; listed for review completeness only)

Possible regenerated native artifacts: `implementation/mobile/runiac_app/ios/Podfile.lock` and `implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj`. Both are registered against this capsule in `check-diff-hygiene.sh`.

## Required Tests

- `implementation/mobile/runiac_app/test/runiac_legal_links_text_test.dart` — each span taps through to the expected URL via a recording fake opener; recognizers are disposed on teardown.
- `implementation/mobile/runiac_app/test/about_runiac_screen_test.dart` — the Terms and Privacy rows exist and open the expected URLs.
- `implementation/mobile/runiac_app/test/premium_paywall_sheet_test.dart` — the footer labels are tappable and open the expected URLs.
- `implementation/mobile/runiac_app/test/privacy_safety_screen_test.dart` — the policy row opens the expected URL.
- `website/src/components/__tests__/LegalDocument.test.tsx` — title, effective date, and every section heading render.

## Required Validation

- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS.
- `cd implementation/mobile/runiac_app && flutter test` PASS.
- `cd website && npm run lint`, `npm run test:unit`, `npm run build` PASS.
- `git diff --check` PASS.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- A5_WIRE review, because user-facing copy and navigation targets change.
- A6_REVIEW and A13_SECURITY_RULES lens on the Privacy Policy's data-collection claims: the document must describe only what the app actually collects, and must not overstate or understate the derived-metrics-only payload sent to the agent callables.

## Recorded Validation (2026-07-26)

- `cd implementation/mobile/runiac_app && flutter analyze --no-pub` PASS (no issues).
- `cd implementation/mobile/runiac_app && flutter test` PASS (2,173/2,173).
- `cd website && npm run lint` PASS (one pre-existing unrelated warning in `Problem.tsx`).
- `cd website && npm run test:unit` PASS (77 passed, 9 skipped).
- `cd website && npm run build` PASS; `/legal/terms`, `/legal/privacy`, `/legal/account-deletion`, `/legal/cookies` all present in the route manifest and all served HTTP 200 from `next start`, with the homepage footer linking to three of them.
- `node tests/cross-system/paywall-config-drift.mjs` PASS — confirms the paywall config schema was left untouched.
- `git diff --check` PASS.
- `./tools/governance-ci/run-all-checks.sh` PASS (all 11 checks).
- Native artifacts: no `ios/Podfile.lock` or `ios/Runner.xcodeproj/project.pbxproj` churn appeared, because only `flutter pub get`/`analyze`/`test` were run. The registered exemption stays in place for the first iOS build.

## Simulator QA (2026-07-26, iPhone 17 Pro / iOS 26.5)

Build installed from `flutter build ios --simulator --debug`; `url_launcher` confirmed registered in `ios/Runner/GeneratedPluginRegistrant.m`.

- About Runiac → `Terms of Service`: PASS. Opens `SFSafariViewController` (in-app browser, in-process) at `fyp-website-v2.vercel.app`. Screenshot captured.
- About Runiac → `Privacy Policy`: PASS. Browser closes back to About, and the row reopens it.
- Privacy & Safety → `Read our full Privacy Policy`: PASS.
- Premium paywall footer → `Terms of service`: PASS, and the accessibility tree now reports both footer labels as `Button` (previously plain text), which is the Guideline 3.1.2 requirement. Screenshot captured.
- Welcome/auth inline consent links: PARTIAL. Both render correctly and the accessibility tree exposes them with role `Link` (recognizers attached at runtime), but a completed tap-through was not captured on device. Covered by `test/runiac_legal_links_text_test.dart`.
- All four pages return HTTP 404 in the browser because the site has not been redeployed yet. This is expected and is the remaining blocker for content QA.

No `ios/Podfile.lock` or `ios/Runner.xcodeproj/project.pbxproj` churn resulted from the builds; the registered diff-hygiene exemption remains unused but in place.

### QA incidents to note

- Another Claude Code session working in the `orca-workspaces/FYP-Runiac-sandlance` worktree was running `flutter run` against the shared iPhone 17 simulator and reinstalled its own build over this one mid-QA. QA was moved to a dedicated iPhone 17 Pro simulator.
- Before that was discovered, automated taps on the shared simulator landed on unintended controls while the app was pointed at production Firebase (`run_local.sh` uses production defines). The account was signed out once, and a `You left the challenge` result screen appeared. Home subsequently still showed the 42K challenge as active with time remaining, but the account's challenge state should be confirmed by the user.

Outstanding before closure: the Vercel deployment of the four pages, then a content re-check of the four in-app entry points.

## Required Evidence

- Command output for the validation list above.
- Simulator screenshots of all four in-app entry points opening their pages (welcome, paywall, About Runiac, Privacy & Safety).
- The confirmed production hostname used in `runiac_legal_urls.dart`.

## Rollback Conditions

- Revert if `url_launcher` cannot be added without further native churn beyond `Podfile.lock` and `project.pbxproj`.
- Revert if the document drafts would require legal claims that cannot be verified against actual app behaviour.
- Revert if `run-all-checks.sh` cannot pass with the registrations in this capsule alone.

## Known Caveats

- The document drafts are prepared for a Final Year Project and are not legal advice. Each published page states this.
- The in-app account-deletion path is not implemented. The Account Deletion page describes the email request path only and is a knowingly incomplete answer to the Google Play requirement until a deletion flow ships.

## Exit Criteria

- [ ] Target files completed.
- [ ] Required tests or validation completed.
- [ ] Required evidence recorded.
- [ ] Snapshot updated if state changed.
- [ ] CURRENT.md updated if active capsule, phase, gate status, or forbidden scope changed.
