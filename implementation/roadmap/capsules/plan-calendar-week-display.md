# Plan Calendar-Week Display

## Parent Phase

`implementation/roadmap/phases/phase-01-governance-ci.md` (closed). Routed as an explicitly
user-reported product defect in the Flutter client. No Phase 02 selection is implied or authorized.

## Status

Routed on 2026-08-15 Asia/Singapore after a fresh signup on a Saturday showed that week's Monday,
Wednesday and Friday sessions as `Missed` on the day the plan was created.

## Goal

Make the Home stage map and the You week view agree with the date model the backend already uses,
so a plan created mid-week never reports a session as missed before it has happened. Display only —
no plan generation change, no backend-owned value is computed, and the plan's 28/42-day span is
unchanged.

## Background — the mechanism

`app.dart:964` stamps `startsOnDate` with the day onboarding finished, so a plan is
`durationWeeks * 7` consecutive days from that day. Workout `dayLabel`s are real weekdays, taken
from the days the runner picked in onboarding, so plan week N holds each weekday exactly once and a
label resolves to the one date in that window whose weekday matches:

```
dayOffset = (weekdayOffset(dayLabel) - weekdayOffset(startsOnDate) + 7) % 7
date      = startsOnDate + (weekNumber - 1) * 7 + dayOffset
```

The backend has computed exactly this since `9eab87cd` — `scheduledDateFor` in
`functions/src/plan/planProgressParsing.ts:31`, consumed by plan progress
(`planProgress.ts:235`), plan-bounded streaks (`planBoundedStreakState.ts:122`) and scheduled push
(`scheduledPushReaders.ts:103`). `GeneratedPlanNotificationScheduleBuilder` used the same formula
on the client.

Two display layers did not. Both classified a day by comparing weekday **numbers**:

- `generated_plan_you_display_adapter.dart:700-703` — `isPast = weekdayIndex < currentWeekdayIndex`,
  producing `'Missed'` at `:731`.
- `home_stage_map_model.dart:222` — `todayDayIndex = currentWeekdayIndex - 1`, with `missed` for any
  run stone at a lower slot (`:261-266`).

On a Saturday-start plan, Monday..Friday sort before Saturday, so all five were read as elapsed.
This was not a first-week-only defect: the anchor never moves off Saturday, so the same three
sessions were re-marked missed every Saturday and Sunday for the life of the plan. It also failed in
the opposite direction — on the Monday, the genuinely elapsed Saturday and Sunday rows flipped back
to `Upcoming`. The net effect was that push notifications fired on the correct dates for sessions
the app was simultaneously calling missed.

## Decided display model

Agreed with the user before implementation. Only one surface moves to calendar weeks:

| Surface | Unit | Note |
|---|---|---|
| You week view, seven rows | **Calendar week (Mon..Sun)** | Dates the plan does not cover render blank |
| You week card title / progress | Plan week | `Week N of M` and its completion ratio are unchanged |
| Home stage map | Plan week | Seven stones keyed by plan-day offset; the start weekday is stone 1 |
| Full plan view | Plan week | M rows of exactly seven days, ordered from the start weekday |

The week card therefore shows two date ranges — the plan week behind the progress figure and the
calendar week behind the rows — because on a mid-week-start plan they genuinely differ, and an
unlabelled difference reads as a contradiction.

## Why no backend change

`startsOnDate` is persisted on the plan document
(`firestore_generated_plan_persistence_repository.dart:238`) and read back by the server
(`planProgress.ts:190`, `planBoundedStreakState.ts:89`, `scheduledPushReaders.ts:82`). The server's
date arithmetic was already correct, so the fix is confined to the client. **No Cloud Functions
change, no rules change, no index change, and no deploy.** An app release is the only rollout step.

## Allowed Scope

- New `implementation/mobile/runiac_app/lib/features/plan/domain/services/generated_plan_schedule.dart`
  as the single client source of truth for plan date resolution, mirroring `scheduledDateFor`.
  It absorbs the three duplicated copies of the `week-{n}-{daylabel}-{slug}` id builder and the
  duplicated weekday-offset arithmetic.
- Rebuild the You week view on the current calendar week's seven dates, classify each row by date,
  and render dates outside the plan as a distinct blank state.
- Key Home stage-map stones by plan-day offset and drive `todayDayIndex` from
  `activeGeneratedPlanDayIndexFor`.
- Give the full plan view real per-week date ranges and per-row dates, order each week from the plan
  start weekday, and mark elapsed weeks `GoalPlanWeekStatus.completed`.
- Re-express the schedule-edit guards as date comparisons inside the workout's own plan week.
- Replace calendar-day arithmetic that used `Duration(days: n)` with `DateTime(y, m, d + n)`.
- Update the affected tests and add date-driven regression and scenario coverage.
- Update this capsule document, `implementation/roadmap/CURRENT.md`, and the routing predicate in
  `tools/governance-ci/check-diff-hygiene.sh`.

## Forbidden Scope

- **No `functions/`, `firestore.rules`, or `firestore.indexes.json` change, and no deploy.** The
  server's date model is already correct; changing it would create exactly the client/server split
  this capsule exists to close.
- **No change to the `week-{n}-{daylabel}-{slug}` scheduled-workout id scheme.** It is the backend
  completion-matching contract (`fallbackWorkoutId`, `planProgressParsing.ts:66`); changing it would
  orphan every recorded completion.
- No `BeginnerAdaptivePlanGenerator` change. A Saturday signup whose preferred days are Mon/Wed/Fri
  waiting until Monday for its first session is correct behaviour, not a defect.
- No `startsOnDate` rewrite and no migration of existing plan documents. The fix is display-only and
  self-heals for plans already in the field.
- No client-side XP, level, rank, streak, or leaderboard computation or mutation.
- No new dependencies, no shell/navigation change, no production service or secret action, and no
  Phase 02 selection.
- No edit inside the isolated `adaptive-character-guidance` worktree, and no change to any existing
  `- Newly routed …` or `- Current active capsule …` line.

## Exact Target Files

- `implementation/roadmap/capsules/plan-calendar-week-display.md`
- `implementation/roadmap/CURRENT.md`
- `tools/governance-ci/check-diff-hygiene.sh` (routing predicate only)
- `implementation/mobile/runiac_app/lib/features/plan/domain/services/generated_plan_schedule.dart` (new)
- `implementation/mobile/runiac_app/lib/features/you/presentation/adapters/generated_plan_you_display_adapter.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/data/you_overview_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/data/goal_plan_demo_snapshots.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/weekly_plan_day_row.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/widgets/generated_weekly_plan_card.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/goal_plan_detail_screen.dart`
- `implementation/mobile/runiac_app/lib/features/you/presentation/you_tab.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map_model.dart`
- `implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart`
- `implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart`
- `implementation/mobile/runiac_app/lib/features/notifications/domain/services/generated_plan_notification_schedule_builder.dart`
- `implementation/mobile/runiac_app/test/generated_plan_calendar_week_schedule_test.dart` (new)
- `implementation/mobile/runiac_app/test/generated_plan_calendar_week_scenarios_test.dart` (new)
- `implementation/mobile/runiac_app/test/home_stage_map_model_test.dart`
- `implementation/mobile/runiac_app/test/home_stage_map_widget_test.dart`
- `implementation/mobile/runiac_app/test/you_generated_plan_session_activation_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_stone_targeting_test.dart`
- `implementation/mobile/runiac_app/test/app_tour_qa_launcher_test.dart`
- `implementation/mobile/runiac_app/test/plan_progress_read_model_test.dart`

## Required Tests

- The existing `generated_plan_notification_schedule_builder_test.dart` must pass **unchanged**.
  That file was the only client code already using the correct formula, so its untouched suite
  passing is the evidence that the extracted helper agrees with the server.
- A parity test asserting the helper matches an independent restatement of `scheduledDateFor` for
  all 7 start weekdays x 7 labels across multiple week numbers.
- Regression tests for the reported case and for its inverse: nothing missed before it happens, and
  genuinely elapsed sessions still missed.
- Scenario tests that pump the production `RuniacApp` with only the date moved, walking a Saturday
  signup day by day and a Tuesday signup to its final Monday.

## Required Validation

- `flutter analyze` clean.
- `flutter test --no-pub` green. The pre-change baseline on `main` is recorded so no failure is
  attributed to this capsule.
- `./tools/governance-ci/run-all-checks.sh` PASS.
- `git diff --check` clean.
- Real-screen simulator evidence for all three surfaces.
- A6_REVIEW, since the change touches the client/server date contract.
- A12_QA_TEST, since the deliverable is user-visible schedule correctness.

## Evidence (2026-08-15)

**Baseline.** `flutter test --no-pub` on unmodified `main`: `+2704: All tests passed!`. The seven
baseline failures recorded elsewhere in `CURRENT.md` are stale; the suite was already green, so
every failure observed during this work was caused by this capsule and was fixed within it.

**After.** `flutter analyze` — `No issues found!`. `flutter test --no-pub` — `+2731: All tests
passed!` (2704 baseline + 27 new: 16 schedule regressions, 10 scenarios, 1 stage-map case).
`./tools/governance-ci/run-all-checks.sh` — `All Governance CI checks passed.`

**Server parity.** `generated_plan_notification_schedule_builder_test.dart` and
`plan_notification_sync_service_test.dart` passed without modification after the private date math
was replaced by the shared helper.

**Real screens.** iPhone 17 simulator, `--dart-define=RUNIAC_QA_SURFACE=app_tour`, which stamps
`startsOnDate` with the real current date. Run on Saturday 2026-08-15 with the generated six-week
Consistency Base plan on Mon/Wed/Fri:

- Home stage map — the character stands on stone 1 and the week reads `Sat, Sun, Mon, Tue, Wed,
  Thu, Fri` from the bottom up, with no missed markers. Week 2 repeats the same rotation.
- You > Plans — header `Week 1 of 6 · 15–21 Aug`, row list headed `This week · 10–16 Aug`,
  `Mon 10`..`Fri 14` blank, `Sat 15` highlighted as today, `Sun 16` rest. No `Missed` anywhere.
- Full plan — six weeks of exactly seven days: `15–21 Aug`, `22–28 Aug`, `29 Aug – 4 Sep`,
  `5–11 Sep`, `12–18 Sep`, `19–25 Sep`. Week 1 expands to `Saturday 15 Aug` .. `Friday 21 Aug` with
  the sessions on 17, 19 and 21 Aug.

**Scenario walk** (`generated_plan_calendar_week_scenarios_test.dart`, production `RuniacApp` with
only the date moved):

| Date | Expected | Result |
|---|---|---|
| Sat 15 Aug, signup day | Mon–Fri blank, no `Missed`, both date ranges labelled | PASS |
| Sun 16 Aug | same calendar week held | PASS |
| Mon 17 Aug | rows roll to 17–23 Aug, no blanks, Monday session is today | PASS |
| Thu 20 Aug | Mon 17 and Wed 19 missed, Fri 21 not | PASS |
| Sat 22 Aug | plan week advances to `Week 2 of 6 · 22–28 Aug`, rows stay on 17–23 Aug | PASS |
| Fri 25 Sep, last plan day | Sat 26 and Sun 27 blank | PASS |
| Tue 18 Aug signup | only Mon 17 blank | PASS |
| Mon 28 Sep, last plan day | Monday in plan, Tue–Sun blank | PASS |
| Home map, Sat 15 Aug | `todayDayIndex` 0, labels Sat..Fri, no missed | PASS |
| Home map, Thu 20 Aug | slots 2 and 4 missed, slot 6 future | PASS |

## Defects found and fixed while implementing

- **Schedule-edit guards used weekday order.** `rescheduleGeneratedPlanSnapshot` rejected any target
  whose weekday number was not greater than today's, so on a Saturday a runner could not move a
  session to the Monday two days later. Both the guard and the editor's unavailable-day set are now
  date comparisons inside the workout's own plan week.
- **`add(Duration(days: n))` is not safe for calendar-day arithmetic.** A duration is absolute time,
  so across a daylight-saving change it lands on 23:00 or 01:00 rather than midnight. These dates
  are map keys compared with `==`, so in a DST timezone a day would silently stop matching its own
  schedule entry. Replaced with `DateTime(y, m, d + n)` and a UTC-normalised day count.
- **The full plan view offered an Edit action on elapsed weeks.** `canEditSchedule` was
  `!isCurrentWeekToday`, true for nearly every row including past weeks, where the reschedule call
  could only ever return null. It is now `date.isAfter(today)`.

## Rollout

Client-only. The change ships with the next app release; nothing is deployed. Existing plans need no
migration — the corrected classification applies on first render.
