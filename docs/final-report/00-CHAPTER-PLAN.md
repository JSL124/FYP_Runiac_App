# Runiac Final Project Document — Chapter Plan and Source Traceability

Project: Runiac — A Mobile Application for Wise Workout
Subject: CSCI321 Final Year Project · Group FYP-26-S2-38 · Supervisor: Mr Ee Kiam Keong
Status: working plan, revision 3 (4 August 2026)

## 1. Purpose of this file

This file is not part of the submitted report. It records how the Final Project Document is being built, which prior document and which repository artefact each chapter derives from, and the conventions the chapters follow. It exists so that any claim in the report can be traced either to an earlier project document or to a real file in this repository.

## 2. Governing rule

The report describes **the application as it was actually built**. The four earlier project documents supply structure, framing, requirement numbering and justification, because those were the agreed project commitments. Wherever an earlier document and the implementation disagree, the implementation is authoritative, the report states what was built, and the divergence is recorded in `00-SOURCE-CODE-DRIFT-REGISTER.md`.

## 3. The four source documents

| Document | Size | Structure | Where it goes |
| --- | --- | --- | --- |
| **Project Proposal** (`FYP26S238 ProjectPreparationDocument.pdf`) | 45 pp | 9 sections: team, market survey, project scope, methodology, OS platform, database, languages, software architecture, risk list | **Chapter 1**, as a second version, keeping its section order |
| **PRD** (`FYP26S238_PRD.pdf`) | 102 pp | 12 sections plus annexure; adds business model (§4), functional requirements with use case, sequence and activity diagrams (§5), non-functional requirements (§6), project timeline (§7.4) | §5 and §6 → **Chapter 2**; §4 → **Chapter 8**; §7.4 → Chapter 1 timeline |
| **Preliminary Technical Document** (`FYP26S238 Preliminary Techincal Document.pdf`) | 157 pp | 17 sections; the master consolidation — overview and USP, business model, timeline with Gantt and WBS, functional hierarchy and access levels and dependencies, seven non-functional requirements, risk management, methodology, platform, database with backend-ownership section, user stories, ten use case descriptions, ten use case diagrams, ten sequence diagrams, ten activity diagrams, full system design, conclusion | §4, §5, §10–§14 → **Chapter 2**; §9.3–9.4 → **Chapter 3**; §15.1–15.2 → **Chapter 4**; §15.3–15.4 → **Chapter 5**; §15.5 → **Chapter 6**; §2.6–2.8 → **Chapter 8**; §16 → **Chapter 10** |
| **Project Design Document** (`FYP26S238 Project Design Document.pdf`) | 76 pp | 5 sections: introduction, system architecture design (physical and application), component diagram, wireframes, class diagram | §2 → **Chapter 4**; §3 and §5 → **Chapter 5**; §4 → **Chapter 6** |

Where the Preliminary Technical Document and the PDD cover the same ground — architecture, component and class diagrams, wireframes — the PDD is the later and more detailed version and is preferred, with the PTD used to fill gaps.

## 4. Chapter map

| Ch | Title | Prior-document basis | Repository evidence | Status |
| --- | --- | --- | --- | --- |
| 1 | Introduction | Project Proposal, all 9 sections | `PRD.md` §7.4 timeline; `functions/src`; `firestore.rules`; `website/` | **Drafted** |
| 2 | Requirement Specifications | PTD §4, §5, §10–§14; PRD §5–§6 | `functions/src` constants and validators; `firestore.rules`; `implementation/mobile/runiac_app/lib`; `implementation/traceability/requirements-map.md` | **Drafted** |
| 3 | Database Design | PTD §9.3–9.4 (the only prior coverage; neither document has a real schema chapter) | `firestore.rules` (~1,400 lines, ~58 collections), `firestore.indexes.json` (15 composite indexes), `storage.rules`, TypeScript types under `functions/src` | Written largely from scratch |
| 4 | Architecture Design | PDD §2.1 physical, §2.2 application; PTD §15.1–15.2 | `functions/src/index.ts`, `firebase.json`, `website/`, `docs/pdd/diagrams/*.puml` | Pending |
| 5 | Component Design | PDD §3 component diagram, §5 class diagram; PTD §15.3–15.4 | 19 Flutter feature modules, 26 `functions/src` modules, 32 callables, 6 scheduled, 7 triggers | Pending |
| 6 | User Interface Design | PDD §4 wireframes (4.1–4.13); PTD §15.5 | `docs/user-manual/screenshots/` — ~140 real screenshots across four user states — and `docs/user-manual/RUNIAC_USER_MANUAL.md` | Pending; uses real screenshots, not wireframes |
| 7 | System Testing | No prior coverage; format from the provided sample test report and test case sample | `functions/test` (84 files), `implementation/mobile/runiac_app/test` and `integration_test` (291 files), `test-evidence/` | Partially executed — see §6 |
| 8 | Marketing Plan | PRD §4; PTD §2.6–2.8 | `website/src/lib/site-pricing.ts`, `website/src/lib/admin/paywall-config.ts` | Pending |
| 9 | Future Enhancements | — | `docs/pdd/08-limitations-and-future-work.md`, `implementation/roadmap/roadmap-stretch.md`, the drift register | Pending |
| 10 | Conclusion | PTD §16 | Objectives from the Proposal §3; risk list from Proposal §9; Chapter 7 results | Pending |
| — | Annexes | Proposal annexes A1–A5 (competitor screenshots) | Test scripts, traceability matrix, user manual, admin console guide | Pending |

## 5. Conventions

The role vocabulary is fixed at three roles throughout: **Unregistered User** (the "Guest User" of the earlier documents), **Registered User** (Basic or Premium), and **Platform Administrator**. The Medical Trainer / Expert role described in the Proposal, PRD, PTD and PDD is not part of this project and appears nowhere in the report — including the PDD's §4.13 expert wireframes and the PTD's §15.5.12, which are dropped rather than reproduced.

The feature set is fixed at ten, F1 to F10. The distance-challenge subsystem is documented within F5. The Proposal's original F9, Running Heatmap Visualization, was never built and the slot carries the Runner Level and XP Progression System.

Figures are numbered per chapter as `Figure <chapter>.<n>` and tables as `Table <chapter>.<n>`, matching the numbering style of the provided sample report. Every figure and table carries a caption and is referenced at least once in the body. Screenshots are cited to their path under `docs/user-manual/screenshots/` so they can be regenerated.

## 6. Chapter 7 evidence strategy

The backend test suite splits into two tiers and the report reports each separately rather than merging them.

The **pure-logic tier** — calculation, validation, contract and policy code with no Firebase services attached — was executed for this report. The results are real: 63 of the 84 Cloud Functions test files run to completion, producing 593 passing assertions and no genuine failures.

The **service-integration tier** — the 21 test files requiring the Firebase Emulator Suite — could not be executed in the documentation environment because the emulator JAR download is blocked there. These must be run on a development machine; `testing/LOCAL-TEST-RUN-INSTRUCTIONS.md` has the exact commands. The same applies to the 291 Flutter test files.

Manual test cases covering flows no automated suite can reach — permission prompts, live GPS tracking, push delivery, the paywall path, the admin console — are authored in the sample's table format with Actual Result and P/F/O left for the tester to complete and sign.

## 7. Build and delivery

Chapters are authored as Markdown in `docs/final-report/`, reviewed in batches, then compiled into a single Word document with a generated table of contents, numbered headings, figure and table captions, running headers and page numbers. The compiled document is delivered alongside the Markdown so the source remains editable in the repository.
