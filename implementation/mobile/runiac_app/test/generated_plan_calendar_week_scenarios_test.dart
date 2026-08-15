import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_map.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_map_model.dart';
import 'package:runiac_app/features/plan/domain/models/beginner_adaptive_plan_snapshot.dart';
import 'package:runiac_app/features/plan/domain/repositories/generated_plan_persistence_repository.dart';
import 'package:runiac_app/features/plan/domain/services/beginner_adaptive_plan_generator.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';

import 'support/fake_runiac_auth_repository.dart';
import 'support/plan_family_test_drafts.dart';

// End-to-end walk of the reported bug through the real rendered surfaces,
// one calendar date at a time.
//
// A runner signs up on Saturday 15 Aug 2026 and the generator gives them the
// six-week Consistency Base plan on Mon/Wed/Fri — the exact plan the simulator
// produced when this was reported. Every scenario below pumps the production
// `RuniacApp` with that plan and only the date moved, then reads what the
// runner would actually see.
//
// Calendar anchors: 15 Aug 2026 Sat, 17 Aug Mon, 20 Aug Thu, 22 Aug Sat,
// 25 Sep Fri (last day of the plan), 18 Aug Tue, 28 Sep Mon.

void main() {
  group('saturday signup, day by day', () {
    testWidgets('day 1 (Sat 15 Aug): the week ahead is blank, not missed', (
      tester,
    ) async {
      await _openPlans(tester, _saturdayPlan(), on: DateTime(2026, 8, 15));

      // This is the regression. Before the fix these five rows read
      // "25 min Comfortable Run · Missed" on the day the plan was created.
      expect(find.text('Missed'), findsNothing);
      _expectBlank(const [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
      ]);
      expect(find.text('Rest Day'), findsNWidgets(2)); // Sat 15 and Sun 16

      // Both scopes are on screen and labelled, because they disagree today.
      expect(find.text('Week 1 of 6'), findsOneWidget);
      expect(find.text('15–21 Aug'), findsOneWidget);
      expect(find.text('This week · 10–16 Aug'), findsOneWidget);
      _expectDayNumbers(const ['10', '11', '12', '13', '14', '15', '16']);
    });

    testWidgets('day 2 (Sun 16 Aug): still the same calendar week', (
      tester,
    ) async {
      await _openPlans(tester, _saturdayPlan(), on: DateTime(2026, 8, 16));

      expect(find.text('Missed'), findsNothing);
      expect(find.text('This week · 10–16 Aug'), findsOneWidget);
      _expectDayNumbers(const ['10', '11', '12', '13', '14', '15', '16']);
    });

    testWidgets('day 3 (Mon 17 Aug): rows roll over and the first run lands', (
      tester,
    ) async {
      await _openPlans(tester, _saturdayPlan(), on: DateTime(2026, 8, 17));

      // Sunday midnight passed, so the seven rows are the next calendar week.
      expect(find.text('This week · 17–23 Aug'), findsOneWidget);
      _expectDayNumbers(const ['17', '18', '19', '20', '21', '22', '23']);
      // Every day of this week is inside the plan now.
      expect(
        find.byKey(const ValueKey('weekly_plan_outside_plan_1')),
        findsNothing,
      );
      expect(find.text('Missed'), findsNothing);
      // The Monday session the old build called missed two days ago is today's.
      expect(find.text('25 min Comfortable Run'), findsWidgets);
      expect(find.textContaining('Upcoming · '), findsWidgets);
    });

    testWidgets('day 6 (Thu 20 Aug): genuinely elapsed sessions read missed', (
      tester,
    ) async {
      await _openPlans(tester, _saturdayPlan(), on: DateTime(2026, 8, 20));

      // Mon 17 and Wed 19 have been and gone without a run. The fix must not
      // suppress these — it only stops days that have NOT happened yet.
      expect(find.text('Missed'), findsNWidgets(2));
      expect(
        find.byKey(const ValueKey('weekly_plan_missed_${DateTime.monday}')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('weekly_plan_missed_${DateTime.wednesday}')),
        findsOneWidget,
      );
      // Friday 21 is still ahead.
      expect(
        find.byKey(const ValueKey('weekly_plan_missed_${DateTime.friday}')),
        findsNothing,
      );
    });

    testWidgets('day 8 (Sat 22 Aug): plan week advances, rows do not', (
      tester,
    ) async {
      await _openPlans(tester, _saturdayPlan(), on: DateTime(2026, 8, 22));

      // The plan anchor is Saturday, so plan week 2 opens today...
      expect(find.text('Week 2 of 6'), findsOneWidget);
      expect(find.text('22–28 Aug'), findsOneWidget);
      // ...while the rows stay on the calendar week until Monday. This is the
      // week where the old build produced its second crop of phantom misses:
      // plan week 2's Mon/Wed/Fri are 24/26/28 Aug, and they are not even on
      // screen, let alone missed.
      expect(find.text('This week · 17–23 Aug'), findsOneWidget);
    });

    testWidgets('last day (Fri 25 Sep): the weekend after the plan is blank', (
      tester,
    ) async {
      await _openPlans(tester, _saturdayPlan(), on: DateTime(2026, 9, 25));

      expect(find.text('Week 6 of 6'), findsOneWidget);
      expect(find.text('This week · 21–27 Sep'), findsOneWidget);
      _expectBlank(const [DateTime.saturday, DateTime.sunday]);
      expect(
        find.byKey(const ValueKey('weekly_plan_outside_plan_${DateTime.friday}')),
        findsNothing,
      );
    });
  });

  group('tuesday signup', () {
    testWidgets('only the monday before the plan is blank', (tester) async {
      await _openPlans(tester, _tuesdayPlan(), on: DateTime(2026, 8, 18));

      _expectBlank(const [DateTime.monday]);
      expect(
        find.byKey(const ValueKey('weekly_plan_outside_plan_${DateTime.tuesday}')),
        findsNothing,
      );
      expect(find.text('Missed'), findsNothing);
      expect(find.text('Week 1 of 6'), findsOneWidget);
      expect(find.text('18–24 Aug'), findsOneWidget);
    });

    testWidgets('the final week runs to monday and blanks the rest', (
      tester,
    ) async {
      // 18 Aug + 41 days = Mon 28 Sep, the 42nd and last day of a six-week plan.
      await _openPlans(tester, _tuesdayPlan(), on: DateTime(2026, 9, 28));

      expect(find.text('Week 6 of 6'), findsOneWidget);
      expect(find.text('This week · 28 Sep – 4 Oct'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('weekly_plan_outside_plan_${DateTime.monday}')),
        findsNothing,
      );
      _expectBlank(const [
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ]);
    });
  });

  group('home stage map', () {
    testWidgets('the journey starts on the first stone with nothing behind', (
      tester,
    ) async {
      final model = await _homeStageModel(
        tester,
        _saturdayPlan(),
        on: DateTime(2026, 8, 15),
      );

      expect(model.todayDayIndex, 0);
      expect(model.characterDayIndex, 0);
      final week1 = model.sections.first.stones;
      expect(
        week1.map((stone) => stone.dayLabel),
        const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      );
      expect(week1.where((stone) => stone.isMissed), isEmpty);
      // Week 2 repeats the same rotation, so the map reads consistently as the
      // runner walks up it.
      expect(
        model.sections[1].stones.map((stone) => stone.dayLabel),
        const ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      );
    });

    testWidgets('elapsed run stones are marked missed once they pass', (
      tester,
    ) async {
      final model = await _homeStageModel(
        tester,
        _saturdayPlan(),
        on: DateTime(2026, 8, 20),
      );

      // Thursday is plan day 5 of a Saturday-start week.
      expect(model.todayDayIndex, 5);
      final week1 = model.sections.first.stones;
      // Slots 2 (Mon 17) and 4 (Wed 19) are the runs that really elapsed.
      expect(week1[2].state, HomeStageStoneState.missed);
      expect(week1[4].state, HomeStageStoneState.missed);
      // Friday's run is slot 6, still ahead.
      expect(week1[6].state, HomeStageStoneState.future);
    });
  });
}

Future<void> _openPlans(
  WidgetTester tester,
  BeginnerAdaptivePlanSnapshot plan, {
  required DateTime on,
}) async {
  // Taller than the default 800x600 surface so all seven schedule rows clear
  // the bottom navigation bar.
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final store = CurrentSessionGeneratedPlanStore();
  expect(store.setActivePlan(plan), isTrue);
  await tester.pumpWidget(
    RuniacApp(
      showSplash: false,
      enableForegroundGps: false,
      authRepository: _signedOutAuth(),
      currentSessionGeneratedPlanStore: store,
      generatedPlanPersistenceRepository:
          const NoopGeneratedPlanPersistenceRepository(),
      youProgressToday: on,
    ),
  );
  await tester.tap(find.byTooltip('You'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Plans'));
  await tester.pumpAndSettle();
}

Future<HomeStageMapModel> _homeStageModel(
  WidgetTester tester,
  BeginnerAdaptivePlanSnapshot plan, {
  required DateTime on,
}) async {
  final store = CurrentSessionGeneratedPlanStore();
  expect(store.setActivePlan(plan), isTrue);
  await tester.pumpWidget(
    RuniacApp(
      showSplash: false,
      enableForegroundGps: false,
      authRepository: _signedOutAuth(),
      currentSessionGeneratedPlanStore: store,
      generatedPlanPersistenceRepository:
          const NoopGeneratedPlanPersistenceRepository(),
      youProgressToday: on,
    ),
  );
  await tester.pumpAndSettle();
  return tester.widget<HomeStageMap>(find.byType(HomeStageMap)).model!;
}

/// A signed-out session: the shell still renders You and Home from the
/// in-memory plan store, with no Firebase involved.
FakeRuniacAuthRepository _signedOutAuth() {
  final authRepository = FakeRuniacAuthRepository();
  addTearDown(authRepository.dispose);
  return authRepository;
}

void _expectBlank(List<int> weekdayIndexes) {
  for (final weekdayIndex in weekdayIndexes) {
    expect(
      find.byKey(ValueKey('weekly_plan_outside_plan_$weekdayIndex')),
      findsOneWidget,
      reason: 'weekday $weekdayIndex should render as an out-of-plan blank',
    );
  }
}

void _expectDayNumbers(List<String> dayNumbers) {
  for (final dayNumber in dayNumbers) {
    expect(
      find.text(dayNumber),
      findsWidgets,
      reason: 'row for day $dayNumber should be on screen',
    );
  }
}

/// The production six-week Mon/Wed/Fri plan, created on Saturday 15 Aug 2026.
BeginnerAdaptivePlanSnapshot _saturdayPlan() => _plan('2026-08-15');

/// The same plan created on Tuesday 18 Aug 2026.
BeginnerAdaptivePlanSnapshot _tuesdayPlan() => _plan('2026-08-18');

BeginnerAdaptivePlanSnapshot _plan(String startsOnDate) {
  final plan = const BeginnerAdaptivePlanGenerator()
      .generate(planFamilyDevelopingDraft())
      .withStartsOnDate(startsOnDate);
  // Guard the fixture: these scenarios only mean anything against a six-week
  // Mon/Wed/Fri plan, which is what onboarding produced when this was reported.
  expect(plan.weeks, hasLength(6));
  expect(plan.preferredScheduleLabel, 'Mon · Wed · Fri');
  return plan;
}
