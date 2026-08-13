# Chapter 10: Conclusion

## 10.1 Assessment Against the Project Objectives

Chapter 1 set six objectives. Each is assessed below against what was actually built, with the evidence named rather than asserted.

**To collect running activity reliably from a smartphone.** *Met.* The client records GPS route, distance, pace, duration, and active and paused time independently, with cadence estimated natively from the phone's motion sensors on both platforms. Tracking survives loss of connectivity and the application being backgrounded, using a foreground service on Android and a Live Activity on iOS. Beyond the objective, iOS additionally imports completed workouts from Apple Health with their heart-rate aggregates.

**To interpret activity for a beginner rather than merely display it.** *Met.* Every run produces a server-generated summary, and post-run reflection is written in plain language rather than presented as a table. Three AI-assisted surfaces were delivered where one was planned, each constrained so that generated text cannot offer medical advice or reference competitive standing, with deterministic copy as both the free tier and the failure fallback.

**To generate a health-aware weekly plan and adapt it.** *Met.* Sixteen onboarding steps resolve into a safety band, a starting level and a plan style, which shape the generated plan. Adaptive estimates refine later sessions from observed performance. The plan's rest days are not merely presentational: they feed the streak calculation as protected dates, so following the plan, including resting, preserves the streak.

**To sustain engagement through habit mechanics.** *Met.* Reminders, streaks with milestone rewards, and a visible experience and level system were delivered, and the reward design consistently favours consistency over intensity. The protected-rest-day rule is the clearest expression of the objective: the system rewards following the plan rather than running the most.

**To provide competition a beginner can meaningfully enter.** *Met, at reduced scope.* The leaderboard ranks users within a Singapore planning area and a league division, served from pre-aggregated records refreshed hourly. The original design was a grid-tile territorial ownership game, and it was abandoned during implementation. The delivered feature is a ranking board rather than a territory game, so the motivational intent survived while the mechanic changed.

**To hold the system to fairness and safety.** *Met, and demonstrable.* Every trusted field is server-owned and rejected at both the callable and rules layers. Premium and Basic pass through the identical experience formula onto the identical board. This is the one objective the project can prove rather than claim: it is verified by executed automated tests reported in Chapter 7.

Against the ten functional requirements, F1 through F6 and F8 through F10 were delivered, several beyond their original specification. **F7 was delivered in a different shape from the one specified.** Community route sharing happens through the Activity Feed, where a runner publishes a completed run and every other runner sees its route. The separate route library the earlier documents described, with browsing, searching and saving, was not built: its collection stores no coordinates and its screens have no navigation entry point. Two specified capabilities were not built: Android Health Connect and Apple Sign-In. Chapter 9 carries all three.

## 10.2 Assessment Against the Risk Register

The Project Proposal identified eighteen risks. Two are worth drawing out, because the register did its job in a way that changed the project.

**R17 held that the territorial game may be too complex to implement within the timeline. It was scored High likelihood and High impact, and it was realised.** The proposal's own mitigation was to adopt a grid-tile model instead of polygon computation. During implementation even that proved more than the timeline could absorb alongside the rest of the feature set, and F8 was redesigned from an ownership game into a level-based regional ranking leaderboard. The motivational property the feature existed for, namely localised and achievable competition, was preserved at a fraction of the implementation cost. F9 followed: the running heatmap depended on the same tile data and was replaced by the experience progression system, which the leaderboard needed anyway in order to group runners fairly.

This is the single most consequential decision in the project, and it was made because a risk register written in April predicted it and the team acted on the prediction rather than defending the original design.

**R14 held that the gamification mechanics may prove less engaging than predicted. It was addressed structurally.** Every progression value is configuration rather than code, held in an administrator-editable document with version history and a validating loader that falls back to compiled defaults. The experience formula, caps, level bands and leaderboard eligibility can all be retuned without a release.

Of the remainder, R1, R8 and R17's downstream effects are the ones left partially mitigated, and each appears in Chapter 9. R3 turned out asymmetric: the wearable API risk was mitigated as designed on iOS through a single abstracted interface, and did not arise on Android because Health Connect was not implemented.

## 10.3 Technical Challenges

**Deciding what the client is allowed to be trusted with.** The most consequential technical decision was to make every field that matters server-owned, and to enumerate those fields in both the callable validator and the security rules so that neither path is open. This was more work than trusting the client and validating loosely, and it constrained the client's design throughout. It is also what makes the fairness claim testable: had entitlement been enforced by hiding controls, no automated test could demonstrate the property and Chapter 2's central claim would rest on a reading of the source.

**Getting time right.** A surprising amount of difficulty concentrated in dates. Streaks, daily experience caps and leaderboard periods all depend on what day it is, and a user's device cannot be trusted to answer that. The system settles it on Singapore local time computed server-side, clamps a future completion timestamp to server time so that it cannot select a favourable cap day or leaderboard month, and re-derives the streak baseline from validated history rather than trusting the stored value. Each of these is a small piece of code guarding against a class of error that would otherwise be silent and permanent.

**Making a language model safe to put in front of beginners.** Generated guidance about running is one prompt away from generated guidance about injury, which the project must not provide. The answer was defence at three points: prompt constraints forbidding medical language, competitive references and unsupported numeric claims; schema-constrained responses; and post-generation validators that re-check the output before it is stored, with deterministic copy as the fallback. The prompts additionally instruct the model to treat user-controlled plan text as display data rather than instruction, which is a defence against prompt injection through a field the user themselves fills in.

**Cross-platform development was not write-once.** Nine native method channels were needed, covering cadence estimation, the Android foreground service, the iOS Live Activity, haptics, notification permissions, plan reminder scheduling, Apple Health import and Instagram sharing. The framework unified the interface rather than the platform.

**Testing what cannot be reached.** Twenty-one of eighty-four backend test files require the Firebase emulator, and the documentation environment could not provide it. Rather than report an untested suite as passing, the suite was split into tiers and each tier reported separately. That is why Chapter 7 reports 556 assertions from 63 files rather than a rounder figure.

## 10.4 Teamwork Challenges

**Coordinating five people across one codebase without a shared mental model.** The team's answer was unusual for a student project: a written governance system inside the repository. Instruction files defined working modes, protected paths, review gates and commit protocol; design documentation, implementation planning and production source were kept in separate directory trees under explicit rules; and any change touching architecture, security, roles, entitlements or the progression and leaderboard model required an additional review pass before commit. Automated governance checks ran before commits.

The cost was real. The discipline slowed individual changes, and the instruction system itself needed maintenance. In exchange, a change to the experience formula or the security rules could not be made casually by whoever happened to be in that file, which for a system whose central claim is fairness was the right trade.

**Documentation drifting from implementation.** Four project documents were produced before and during development, and the system moved underneath them. By the time this report was written, the proposal described a territorial game that did not exist, the requirements described weekly experience that was never stored, and every document described a Medical Trainer/Expert role that was never built. Reconstructing what was actually delivered required reading the code rather than the documents. The accompanying drift register exists because that reconstruction found enough divergence to need a systematic record.

**Two corrections during report preparation illustrate the same lesson.** Apple HealthKit integration was initially recorded as not delivered, because it appears nowhere in the Flutter dependency manifest; it is a native Swift method channel. The F7 route library was initially recorded as delivered, because the collection, the rules and the interface all exist. The absence of any test then prompted a closer look, which found no publication path and demonstration data behind the maps screen, and manual execution later found that the screen cannot be reached at all. In both cases the document was wrong in the direction that a casual reading of the repository would suggest.

## 10.5 What the Team Learnt

**A risk register is only useful if it is acted on.** R17 was scored High/High in April and realised in July. What mattered was accepting, when the time came, that the original design had to go. A register kept as a document to submit rather than as a plan to follow would have given the team no benefit.

**Important properties should be built so that they can be tested.** Fairness and anti-tampering were designed as declarative, centralised rules, with server-owned field lists and configuration-driven entitlement. That decision is why Chapter 7 can report them as verified. Where a claim matters, the architecture should be chosen so that the claim can be demonstrated.

**Absence of tests is evidence about the code.** F7 had no tests. The natural response is to schedule test writing; the more useful response was to ask why the gap existed, which revealed that the feature was incomplete. An untested area deserves investigation before it is scheduled for coverage.

**Documents describe a moment in time, and the code is the system.** Every one of the four prior documents was accurate when written and inaccurate by delivery. Writing this report code-first, and recording every divergence rather than restating the plan, produced a more useful and more defensible document.

**Scope discipline is what made completion possible.** All ten feature slots were delivered within a single semester by a five-person team, and that was achievable only because the two most expensive features were cut down when the evidence said they were too expensive.
