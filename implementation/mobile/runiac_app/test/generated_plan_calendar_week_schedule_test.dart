import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/models/plan_family.dart';
import 'package:runiac_app/features/plan/domain/services/generated_plan_schedule.dart';
import 'package:runiac_app/features/you/presentation/adapters/generated_plan_you_display_adapter.dart';
import 'package:runiac_app/features/you/presentation/data/goal_plan_demo_snapshots.dart';
import 'package:runiac_app/features/you/presentation/data/weekly_workout_demo_snapshots.dart';

// The You tab's seven-row week view is laid out on the CALENDAR week (Mon..Sun)
// and filled from the plan by date. A plan itself is 7 * durationWeeks
// consecutive days from the day onboarding finished, so it only lines up with a
// calendar week when it starts on a Monday.
//
// Before this was date-driven the rows classified each day by comparing weekday
// numbers, which called a Saturday-start plan's Monday session "Missed" on the
// day the plan was created — and again on the Saturday and Sunday of every week
// after that, because the plan anchor never moves off Saturday.
//
// Calendar anchors used below:
//   2026-08-15 Sat   2026-08-17 Mon   2026-08-18 Tue   2026-08-20 Thu
//   2026-09-11 Fri (last day of a 4-week plan started Sat 2026-08-15)
//   2026-09-14 Mon (last day of a 4-week plan started Tue 2026-08-18)

void main() {
  group('saturday signup', () {
    test('shows no missed session on the day the plan is created', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 15),
      );

      expect(display, isNotNull);
      // The rows are this calendar week, Mon 10 Aug .. Sun 16 Aug.
      expect(
        display!.scheduleRows.map((row) => row.date),
        [for (var day = 10; day <= 16; day++) DateTime(2026, 8, day)],
      );
      // Mon..Fri are before the plan exists: blank, not rest, not missed.
      expect(
        display.scheduleRows.where((row) => row.isOutsidePlan).map(
          (row) => row.date,
        ),
        [for (var day = 10; day <= 14; day++) DateTime(2026, 8, day)],
      );
      expect(
        display.scheduleRows.where((row) => row.isOutsidePlan).every(
          (row) => row.title.isEmpty && row.status.isEmpty,
        ),
        isTrue,
      );
      // Saturday is the plan's first day and the only "today".
      expect(
        display.scheduleRows.where((row) => row.isToday).single.date,
        DateTime(2026, 8, 15),
      );
      expect(
        display.scheduleRows.map((row) => row.status),
        isNot(contains('Missed')),
      );
    });

    test('labels the plan week and the calendar week separately', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 15),
      );

      // Progress counts the plan week (15–21 Aug) while the rows below show the
      // calendar week (10–16 Aug). Both ranges are stated so the difference
      // reads as a fact rather than a contradiction.
      expect(display!.progressLabel, 'Week 1 of 4');
      expect(display.planWeekRangeLabel, '15–21 Aug');
      expect(display.calendarWeekRangeLabel, '10–16 Aug');
    });

    test('rows roll to the next calendar week once sunday ends', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 17),
      );

      expect(
        display!.scheduleRows.map((row) => row.date),
        [for (var day = 17; day <= 23; day++) DateTime(2026, 8, day)],
      );
      // Every day of this week is inside the plan now, so nothing is blank.
      expect(display.scheduleRows.any((row) => row.isOutsidePlan), isFalse);
      final monday = display.scheduleRows.first;
      expect(monday.isToday, isTrue);
      expect(monday.title, contains('Monday Run'));
      expect(monday.status, startsWith('Upcoming · '));
      // Sat/Sun belong to plan week 2 — one calendar week can straddle two.
      expect(display.scheduleRows[5].planWeekNumber, 2);
      expect(display.scheduleRows[6].planWeekNumber, 2);
      expect(display.scheduleRows.first.planWeekNumber, 1);
    });

    test('still marks a genuinely elapsed session as missed', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      // Thursday 20 Aug: the Monday (17th) and Wednesday (19th) sessions of
      // plan week 1 really have been and gone.
      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 20),
      );

      expect(_statusOn(display!, DateTime(2026, 8, 17)), 'Missed');
      expect(_statusOn(display, DateTime(2026, 8, 19)), 'Missed');
      expect(_statusOn(display, DateTime(2026, 8, 21)), startsWith('Upcoming'));
    });

    test('completed sessions are still read from backend progress', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 20),
        planProgress: GeneratedPlanProgressDisplay(
          completedScheduledWorkoutIds: const [
            'week-1-mon-monday-run',
          ],
        ),
      );

      expect(_statusOn(display!, DateTime(2026, 8, 17)), 'Completed');
      expect(_statusOn(display, DateTime(2026, 8, 19)), 'Missed');
    });

    test('blanks the tail of the calendar week the plan ends in', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      // A 4-week plan from Sat 15 Aug ends on Fri 11 Sep.
      expect(
        generatedPlanLastDate(plan, start: DateTime(2026, 8, 15)),
        DateTime(2026, 9, 11),
      );
      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 9, 11),
      );

      expect(
        display!.scheduleRows.where((row) => row.isOutsidePlan).map(
          (row) => row.date,
        ),
        [DateTime(2026, 9, 12), DateTime(2026, 9, 13)],
      );
    });
  });

  group('tuesday signup', () {
    test('blanks only the monday of the week it starts in', () {
      final plan = _plan(startsOnDate: '2026-08-18');

      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 18),
      );

      expect(
        display!.scheduleRows.where((row) => row.isOutsidePlan).map(
          (row) => row.date,
        ),
        [DateTime(2026, 8, 17)],
      );
      expect(
        display.scheduleRows.where((row) => row.isToday).single.date,
        DateTime(2026, 8, 18),
      );
    });

    test('runs through the monday of the week it ends in', () {
      final plan = _plan(startsOnDate: '2026-08-18');

      // 4 weeks from Tue 18 Aug is 28 days, ending Mon 14 Sep.
      expect(
        generatedPlanLastDate(plan, start: DateTime(2026, 8, 18)),
        DateTime(2026, 9, 14),
      );
      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 9, 14),
      );

      expect(display!.scheduleRows.first.date, DateTime(2026, 9, 14));
      expect(display.scheduleRows.first.isOutsidePlan, isFalse);
      expect(display.scheduleRows.first.isToday, isTrue);
      expect(
        display.scheduleRows.skip(1).every((row) => row.isOutsidePlan),
        isTrue,
      );
    });
  });

  group('reschedule guards', () {
    test('allows moving to a later date inside the same plan week', () {
      final plan = _plan(startsOnDate: '2026-08-15');
      // Plan week 1's Wednesday session is 19 Aug — four days after the
      // Saturday the plan was created, even though Wednesday sorts before
      // Saturday in weekday order.
      final detail = _detailFor(plan, weekNumber: 1, dayLabel: 'Wed');

      final updated = rescheduleGeneratedPlanSnapshot(
        plan,
        detail,
        const WorkoutScheduleEditSelection(
          weekdayIndex: DateTime.thursday,
          dayLabel: 'Thu',
          timeLabel: '8:00 AM',
        ),
        currentDate: DateTime(2026, 8, 15),
      );

      expect(updated, isNotNull);
      expect(
        updated!.weeks.first.workouts.map((workout) => workout.dayLabel),
        containsAll(<String>['Thu']),
      );
    });

    test('refuses a target date that has already passed', () {
      final plan = _plan(startsOnDate: '2026-08-15');
      final detail = _detailFor(plan, weekNumber: 1, dayLabel: 'Fri');

      // On Thursday 20 Aug, plan week 1's Monday is 17 Aug — behind us.
      final updated = rescheduleGeneratedPlanSnapshot(
        plan,
        detail,
        const WorkoutScheduleEditSelection(
          weekdayIndex: DateTime.monday,
          dayLabel: 'Mon',
          timeLabel: '8:00 AM',
        ),
        currentDate: DateTime(2026, 8, 20),
      );

      expect(updated, isNull);
    });

    test('marks elapsed weekdays of the plan week as unavailable', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      final friday = _detailFor(plan, weekNumber: 1, dayLabel: 'Fri');

      // Saturday and Sunday of plan week 1 are 15 and 16 Aug: today and
      // tomorrow. Only today is unavailable; every day after it is offerable
      // unless another session already owns it. Weekday order would instead
      // have blocked Mon..Sat, i.e. everything but Sunday.
      final occupied = friday.occupiedScheduleWeekdays;
      expect(occupied, contains(DateTime.saturday));
      expect(occupied, isNot(contains(DateTime.sunday)));
      expect(occupied, contains(DateTime.monday));
      expect(occupied, contains(DateTime.wednesday));
      expect(occupied, isNot(contains(DateTime.tuesday)));
    });
  });

  group('full plan view', () {
    test('lists plan weeks of seven days ordered from the start weekday', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      final goalPlan = generatedGoalPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 15),
      );

      expect(goalPlan!.weeks, hasLength(4));
      expect(
        goalPlan.weeks.map((week) => week.dateRangeLabel),
        const [
          '15–21 Aug',
          '22–28 Aug',
          '29 Aug – 4 Sep',
          '5–11 Sep',
        ],
      );
      expect(
        goalPlan.weeks.first.dailyPlan.map((day) => day.weekday),
        const [
          'Saturday',
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
        ],
      );
      expect(
        goalPlan.weeks.first.dailyPlan.map((day) => day.dateLabel),
        const [
          '15 Aug',
          '16 Aug',
          '17 Aug',
          '18 Aug',
          '19 Aug',
          '20 Aug',
          '21 Aug',
        ],
      );
      // Never blank: a plan week is always exactly the plan's own seven days.
      expect(
        goalPlan.weeks.every((week) => week.dailyPlan.length == 7),
        isTrue,
      );
    });

    test('marks elapsed plan weeks completed', () {
      final plan = _plan(startsOnDate: '2026-08-15');

      final goalPlan = generatedGoalPlanDisplayFromSnapshot(
        plan,
        // 29 Aug is the first day of plan week 3.
        currentDate: DateTime(2026, 8, 29),
      );

      expect(
        goalPlan!.weeks.map((week) => week.status),
        const [
          GoalPlanWeekStatus.completed,
          GoalPlanWeekStatus.completed,
          GoalPlanWeekStatus.current,
          GoalPlanWeekStatus.goalWeek,
        ],
      );
    });
  });

  group('date resolution', () {
    test('matches the backend formula for every start weekday and label', () {
      // Independent restatement of `scheduledDateFor` in
      // functions/src/plan/planProgressParsing.ts. Both sides must place a
      // workout on the same calendar date or the app will mark sessions missed
      // that the server still counts, and vice versa.
      for (var startOffset = 0; startOffset < 7; startOffset++) {
        // 2026-08-10 is a Monday, so adding startOffset walks Mon..Sun.
        final start = DateTime(2026, 8, 10 + startOffset);
        for (var labelOffset = 0; labelOffset < 7; labelOffset++) {
          final label = kGeneratedPlanWeekdayLabels[labelOffset];
          for (final weekNumber in const [1, 2, 4]) {
            final expected = start.add(
              Duration(
                days:
                    (weekNumber - 1) * 7 +
                    ((labelOffset - startOffset + 7) % 7),
              ),
            );
            expect(
              generatedPlanScheduledDate(
                start: start,
                weekNumber: weekNumber,
                dayLabel: label,
              ),
              expected,
              reason: 'start $start, label $label, week $weekNumber',
            );
            // And the resolved date really does carry the label's weekday.
            expect(generatedPlanWeekdayLabelOf(expected), label);
          }
        }
      }
    });

    test('a plan week window holds each weekday exactly once', () {
      final start = DateTime(2026, 8, 15);
      final labels = [
        for (var day = 0; day < 7; day++)
          generatedPlanWeekdayLabelOf(start.add(Duration(days: day))),
      ];

      expect(labels.toSet(), kGeneratedPlanWeekdayLabels.toSet());
    });

    test('undated plans fall back to the current calendar week', () {
      final plan = _plan(startsOnDate: null);

      // With no anchor there is nothing to offset from, so plan week 1 is made
      // to coincide with the calendar week and the rows behave exactly as they
      // did before dates existed.
      expect(
        generatedPlanAnchorDate(plan, today: DateTime(2026, 8, 15)),
        DateTime(2026, 8, 10),
      );
      final display = generatedYouPlanDisplayFromSnapshot(
        plan,
        currentDate: DateTime(2026, 8, 15),
      );
      expect(display!.scheduleRows.any((row) => row.isOutsidePlan), isFalse);
      expect(_statusOn(display, DateTime(2026, 8, 10)), 'Missed');
    });
  });
}

String _statusOn(GeneratedYouPlanDisplay display, DateTime date) {
  return display.scheduleRows.firstWhere((row) => row.date == date).status;
}

WeeklyWorkoutDetailSnapshot _detailFor(
  BeginnerAdaptivePlanSnapshot plan, {
  required int weekNumber,
  required String dayLabel,
}) {
  final goalPlan = generatedGoalPlanDisplayFromSnapshot(
    plan,
    currentDate: DateTime(2026, 8, 15),
  );
  final week = goalPlan!.weeks[weekNumber - 1];
  return week.dailyPlan
      .map((day) => day.workoutDetail)
      .whereType<WeeklyWorkoutDetailSnapshot>()
      .firstWhere((detail) => detail.scheduleDayLabel == dayLabel);
}

/// Four-week plan running Monday, Wednesday and Friday.
BeginnerAdaptivePlanSnapshot _plan({required String? startsOnDate}) {
  return BeginnerAdaptivePlanSnapshot(
    id: 'calendar-week-plan',
    title: 'Beginner Plan',
    subtitle: 'Four weeks',
    planKind: BeginnerAdaptivePlanKind.onboardingBased,
    sourceLabel: 'Onboarding based',
    startsOnDate: startsOnDate,
    durationWeeks: 4,
    safetyBand: BeginnerPlanSafetyBand.clear,
    templateKind: BeginnerPlanTemplateKind.standardBeginnerStart,
    family: PlanFamily.consistencyBase,
    familyCategory: PlanFamilyCategory.developing,
    familyReason: 'reason',
    supportStyleLabel: 'Clear weekly plan',
    weeklyFrequencyLabel: '3 sessions / week',
    preferredScheduleLabel: 'Mon · Wed · Fri',
    sessionDurationLabel: '30 minutes',
    safetyNote: 'Keep it easy.',
    weeks: [
      for (var weekNumber = 1; weekNumber <= 4; weekNumber++)
        BeginnerAdaptivePlanWeek(
          weekNumber: weekNumber,
          title: 'Week $weekNumber',
          focus: 'Focus $weekNumber',
          workouts: [
            _workout(dayLabel: 'Mon', title: 'Monday Run'),
            _workout(dayLabel: 'Wed', title: 'Wednesday Run'),
            _workout(dayLabel: 'Fri', title: 'Friday Run'),
          ],
        ),
    ],
  );
}

BeginnerAdaptiveWorkout _workout({
  required String dayLabel,
  required String title,
}) {
  return BeginnerAdaptiveWorkout(
    dayLabel: dayLabel,
    title: title,
    durationMinutes: 25,
    kind: BeginnerWorkoutKind.easyRun,
    intensity: BeginnerPlanIntensity.gentle,
    description: 'Description',
    steps: const <String>[],
    supportiveNote: 'You can do this.',
    detail: BeginnerAdaptiveWorkoutDetail(
      metrics: const <BeginnerAdaptiveWorkoutMetric>[],
      breakdown: const <BeginnerAdaptiveWorkoutBreakdownStep>[],
      effortGuide: 'Easy effort',
      coachNotes: const <String>[],
    ),
  );
}
