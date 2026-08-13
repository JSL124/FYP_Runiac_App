# Handoff — Chapters 3 to 6

**Read this first.** It carries everything needed to write Chapters 3, 4, 5 and 6 without re-deriving what earlier sessions already established.

Last updated: 5 August 2026

---

## 1. Where the report stands

| Chapter | Status | File |
| --- | --- | --- |
| 1 Introduction | **Done** | `ch01-introduction.md` |
| 2 Requirement Specifications | **Done** | `ch02-requirement-specifications.md` |
| 3 Database Design | **To write** | — |
| 4 Architecture Design | **To write** | — |
| 5 Component Design | **To write** | — |
| 6 User Interface Design | **To write** | — |
| 7 System Testing | **Done** | `ch07-system-testing.md` |
| 8 Marketing Plan | **Done** | `ch08-marketing-plan.md` |
| 9 Future Enhancements | **Done** | `ch09-future-enhancements.md` |
| 10 Conclusion | **Done** | `ch10-conclusion.md` |
| Annex F Test Scripts | **Done** — 75 scripts | `annex-f-test-scripts.md` |

Compiled output is `Runiac_Final_Project_Document_DRAFT.docx`, currently 117 pages.

Chapters 3 to 6 were deliberately held back because each needs diagrams, **which the user is drawing themselves**. Write the prose so that it stands on its own and reference each figure by number with a caption; the user drops the images in.

---

## 2. Ground rules — do not renegotiate these

These were settled with the user across earlier sessions.

**Write from the code, not from the earlier documents.** The Project Proposal, PRD, Preliminary Technical Document and Project Design Document supply structure and requirement numbering. Where any of them disagrees with the implementation, the implementation wins and the divergence is recorded in `00-SOURCE-CODE-DRIFT-REGISTER.md`.

**Three roles only.** Unregistered User, Registered User (Basic / Premium), Platform Administrator. **The Medical Trainer/Expert role does not exist in this project** — it appears in all four earlier documents and in the PDD's §4.13 wireframes, and it must appear nowhere in the report.

**Ten features, F1 to F10.** The distance-challenge subsystem is documented inside F5. The Proposal's original F9 was a running heatmap that was never built; the slot carries the XP progression system.

**Never invent evidence.** Chapter 7 reports only executed results. If something cannot be verified, say so plainly rather than filling a gap.

**Prose over bullets.** The chapters are written in flowing prose with tables where they earn their place. Match the voice of Chapters 1, 2 and 7 — the user has reviewed and kept that style.

---

## 3. Build pipeline

`build-docx.js` (in this folder) converts the chapter Markdown into the Word document. It lives in the repo so any session can rebuild.

```bash
# from a working copy of docs/final-report/
node build-docx.js                       # writes Runiac_Final_Project_Document_DRAFT.docx
CHAPTERS=ch03-database-design.md node build-docx.js   # single-chapter preview
```

The chapter list is the `chapters` array near the bottom of the script — add `ch03-…` through `ch06-…` in order between chapter 2 and chapter 7.

Conventions the script already handles: `#`/`##`/`###` become numbered headings, pipe tables become Word tables with weighted column widths, a line that is entirely `*italic*` becomes a centred caption, and `<br>` inside a table cell becomes a line break. A table whose first cell is `Objective` or `Tester's Name` is rendered without a shaded header band.

To verify a build, convert to PDF and look at it:

```bash
python /root/.claude/skills/docx/scripts/office/soffice.py --headless --convert-to pdf Runiac_Final_Project_Document_DRAFT.docx
pdftoppm -jpeg -r 80 -f 40 -l 42 Runiac_Final_Project_Document_DRAFT.pdf page
```

Figure and table numbering restarts per chapter: `Figure 3.1`, `Table 3.1`. Every figure and table needs a caption line and at least one mention in the body.

---

## 4. Sources per chapter

| Chapter | Prior document | Repository evidence |
| --- | --- | --- |
| 3 Database Design | PTD §9.3–9.4 only — no earlier document has a real schema chapter, so this is largely written from scratch | `firestore.rules`, `firestore.indexes.json`, `storage.rules`, TypeScript types under `functions/src` |
| 4 Architecture Design | PDD §2.1 physical, §2.2 application; PTD §15.1–15.2 | `functions/src/index.ts`, `firebase.json`, `website/`, `docs/pdd/diagrams/*.puml` |
| 5 Component Design | PDD §3 component diagram, §5 class diagram; PTD §15.3–15.4 | 19 Flutter feature modules, 26 `functions/src` modules, the native method channels |
| 6 User Interface Design | PDD §4 wireframes; PTD §15.5 | `docs/user-manual/screenshots/` and `docs/user-manual/RUNIAC_USER_MANUAL.md` |

The four source PDFs are attached in the conversation history; ask the user to re-attach if a new thread needs them.

Existing diagram sources are in `docs/pdd/diagrams/` — `application-architecture.puml`, `physical-architecture.puml`, `component-diagram.puml`, `class-diagram.puml` and their rendered PNGs. **These are the old design-time diagrams.** They still broadly describe the system but predate several changes; check each against the code before reusing, and expect the user to supply updated renders.

---

## 5. Verified facts to reuse

Established from the code across earlier sessions. Re-verify anything load-bearing, but do not start from zero.

**Scale.** Flutter client ~640 Dart files across 19 feature modules. Cloud Functions ~184 TypeScript files, `asia-southeast1`, Node 22, ESM — 32 callables, 6 scheduled functions, 7 event triggers. Firestore ~58 top-level collections, 15 composite indexes. Next.js 16 App Router website with 13 admin sections. Around 640 automated test files in total.

**The trust model — the strongest thing to write about in Chapter 3.** `firestore.rules` runs to roughly 1,400 lines, closes with a deny-all catch-all, and carries a large explicit backend-owned key list. Only a handful of collections are client-writable at all. `users/{uid}` is readable by its owner and writable by no client. `userProfiles/{uid}` is owner-writable except for the enumerated backend-owned keys, which is how experience, level, streak and division stay protected while a nickname stays editable.

**Progression model.** 20 base + 10 per whole kilometre + 5 per whole ten active minutes + 20 plan bonus; capped at 100 per activity and 200 per Singapore day; streak milestones at 3/7/14/30 days paying 30/90/220/600 and exempt from both caps. Ten level bands to a maximum of level 100. Ten leagues, Iron through Challenger.

**Leaderboard.** Monthly only, keyed `YYYY-MM` on Singapore time. Regions are Singapore planning areas. Aggregation runs hourly under a lease document and publishes snapshots, per-user rank documents and current views. Ordering is score descending, ties broken deterministically.

**Feature access is published configuration, not code.** `config/featureAccess` is deep-merged over compiled defaults. As published: `advancedAnalysis`, `activityFeedback` and `workoutBriefing` are Premium; **`aiHomeCoach`, `shareRouteToFeed` and `shareCards` are Basic**. Two of these differ from the compiled defaults — see `ch02` §2.4 Table 2.2, which states both. A seventh key, `healthWorkoutImport`, was retired on 2026-08-13 because `65b41c49` had already deleted the import surface it gated — removed from the compiled catalog and deleted from the live document the same day. Do not cite it as a delivered entitlement.

**Client architecture.** No state-management package: hand-rolled `ChangeNotifier` stores behind `InheritedWidget`/`InheritedNotifier` "CurrentSession" scopes, with the composition root in `features/shell/runiac_shell.dart`. No routing package: one `MaterialApp` with imperative `Navigator.push`. Repository interfaces in `domain/` with Firebase and static implementations, which is what makes offline and demo builds possible.

**Nine native method channels** — worth a subsection in Chapter 5, since no earlier document mentions them: cadence estimation from phone motion, the Android foreground tracking service, the iOS Live Activity, haptics, notification permissions, plan reminder scheduling, Apple Health import, and Instagram Story sharing.

---

## 6. Corrections earlier sessions got wrong — do not repeat

**A Flutter dependency manifest is not evidence of absence.** Apple HealthKit integration was initially recorded as "not delivered" because nothing appears in `pubspec.yaml`. It is a native Swift method channel with the HealthKit entitlement declared in `ios/Runner/Runner.entitlements`. Always check `ios/Runner/`, `android/app/src/main/` and method-channel registrations before declaring a platform capability missing.

**An absent test can be evidence about the code.** F7 community route sharing had no tests. Investigating why revealed the feature is incomplete: `sharedRoutes` stores no route geometry, no code path sets `visibilityStatus` to `published`, and the maps screen reads `maps_route_demo_snapshots.dart`. Chapter 2 §2.6.7 states this; Chapter 6 must not present the maps screens as live community content.

**The workout briefing agent *is* wired to the client** — `weekly_workout_detail_cards.dart:169` constructs it, and there are four user-manual screenshots. An earlier draft from another thread claimed it was built but not deployed; that is wrong.

**Distinguish compiled defaults from published configuration.** The code default for `shareRouteToFeed` and `aiHomeCoach` is Premium; the published value for both is Basic. The default is only a fallback for a missing or invalid document.

---

## 7. Chapter 3 — suggested outline and first commands

Chapter 3 has the least prior material and the most raw evidence, so start here.

**Suggested structure.** Introduction and design principles; the collection inventory grouped by concern; the trust boundary — backend-owned fields and what a client may write; per-collection detail for the fifteen or so collections that matter, each with document key, main fields, ownership and access; the progression audit ledger as its own subsection, since `progressionEvents` is where the fairness story becomes visible; indexes and query patterns; Cloud Storage layout; configuration documents; and trade-offs including denormalisation and the absence of relational joins.

**Figures the user will need to draw.** An entity-relationship or collection-relationship diagram; a trust-boundary diagram showing client-writable versus backend-owned; and possibly a document-lifecycle diagram for an activity from submission through award to leaderboard contribution.

**First commands.** Run these on the device VM at `/sessions/<session>/mnt/FYP_Runiac`:

```bash
# collection inventory
grep -oE "match /[a-zA-Z0-9_]+/\{" firestore.rules | sort -u

# which collections a client can write at all
grep -nE "allow (create|update|write)" firestore.rules | grep -v "if false" | head -40

# the backend-owned key list
grep -n -A40 "backendOwnedKeys" firestore.rules | head -60

# composite indexes
python3 -c "import json;d=json.load(open('firestore.indexes.json'));[print(i['collectionGroup'], [f['fieldPath'] for f in i['fields']]) for i in d['indexes']]"

# storage layout
grep -nE "match /" storage.rules
```

Then read the TypeScript types under `functions/src` for the field-level detail — the rules give access control, the types give shape.

---

## 8. Open items the user still owes

These are tracked in the finished chapters and should not be re-asked unless the user raises them.

The manual test scripts in Annex F are authored but not executed; `Runiac_Test_Execution_Log.xlsx` is the workbook for capturing results, and `SAMPLE_How_To_Fill_Test_Scripts.docx` is the guide for the team. When filled results arrive, update Chapter 7 Tables 7.9 and 7.10 and the §7.9.1 conclusion.

298 of the automated test files await execution on a development machine; `testing/LOCAL-TEST-RUN-INSTRUCTIONS.md` has the commands.

The monthly price decision in Chapter 8 §8.4.8 — keep S$5.99 or reduce to S$4.99 — needs team sign-off.

Twelve diagrams referenced in Chapter 2 need redrawing; the list with the required change for each is at the end of `00-SOURCE-CODE-DRIFT-REGISTER.md`.
