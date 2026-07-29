import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_background_sequence.dart';
import 'package:runiac_app/features/home/presentation/stage_map/home_stage_map_model.dart';
import 'package:runiac_app/features/tutorial/presentation/qa/app_tour_qa_launcher.dart';
import 'package:runiac_app/features/you/presentation/adapters/generated_plan_you_display_adapter.dart';

void main() {
  group('buildAppTourQaApp', () {
    test('stays debug-only: returns null in release mode even when the '
        'surface name matches', () {
      expect(
        buildAppTourQaApp(releaseMode: true, surface: appTourQaSurfaceName),
        isNull,
      );
    });

    test('returns null when the surface name does not match', () {
      expect(
        buildAppTourQaApp(releaseMode: false, surface: 'some_other_surface'),
        isNull,
      );
      expect(buildAppTourQaApp(releaseMode: false, surface: ''), isNull);
    });

    test(
      'builds the app tour surface with an active seeded plan when not in '
      'release mode and the surface matches',
      () {
        final app = buildAppTourQaApp(
          releaseMode: false,
          surface: appTourQaSurfaceName,
        );

        expect(app, isNotNull);
        final runiacApp = app as RuniacApp;
        expect(runiacApp.showSplash, isFalse);
        expect(runiacApp.showAuth, isFalse);
        expect(runiacApp.showOnboarding, isFalse);
        expect(runiacApp.enableForegroundGps, isFalse);
        expect(runiacApp.appTourSeenStore, isNotNull);

        final planStore = runiacApp.currentSessionGeneratedPlanStore;
        expect(planStore, isNotNull);
        expect(planStore!.hasActivePlan, isTrue);

        final plan = planStore.activePlan!;
        // Multi-week: more than one week, so the tour's stone-cluster
        // spotlight can be verified across the plan, not just a single week.
        expect(plan.weeks.length, greaterThan(1));

        // A genuine mix of running and rest days: fewer running workouts
        // than the 7 day slots in a week means at least one rest day.
        expect(plan.weeks.first.workouts.length, lessThan(7));
        expect(plan.weeks.first.workouts, isNotEmpty);
      },
    );
  });

  group('buildAppTourQaGeneratedPlanStore', () {
    test(
      'seeds an active plan whose current stage-map week always resolves '
      'a current stone, regardless of which real weekday it runs on',
      () {
        final store = buildAppTourQaGeneratedPlanStore();

        expect(store.hasActivePlan, isTrue);
        final plan = store.activePlan!;
        expect(plan.weeks.length, greaterThan(1));
        expect(plan.weeks.first.workouts.length, lessThan(7));
        expect(plan.startsOnDate, isNotNull);

        // `isEligibleCurrentSessionGeneratedPlan` (checked by
        // `setActivePlan`) already guarantees the plan is displayable and
        // has at least one running session in week 1.
        expect(plan.canStartPlannedRun, isTrue);
        expect(plan.isBlocked, isFalse);
      },
    );

    test(
      'builds a HomeStageMapModel with a non-null current week and at '
      'least one current stone, exactly the condition '
      '_buildStoneClusterAnchor (home_stage_map.dart) requires to render '
      'the homeStoneCluster spotlight instead of falling back',
      () {
        final plan = buildAppTourQaGeneratedPlanStore().activePlan!;

        // Mirrors `HomeTabState._buildStageMapModel` (home_tab.dart) exactly,
        // using real "today" the same way the QA surface does (it never
        // overrides `youProgressToday`).
        final activeWeek = activeGeneratedPlanWeekFor(
          plan,
          currentDate: DateTime.now(),
        );
        final activeWeekNumber =
            activeWeek?.weekNumber ?? plan.weeks.first.weekNumber;
        final activeWeekdayIndex = activeGeneratedPlanWeekdayFor(
          plan,
          currentDate: DateTime.now(),
        );
        final model = buildHomeStageMapModel(
          plan: plan,
          completedScheduledWorkoutIds: const <String>{},
          activeWeekNumber: activeWeekNumber,
          currentWeekdayIndex: activeWeekdayIndex,
          backgroundSequence: homeStageBackgroundSequence(
            planId: plan.id,
            weekCount: plan.weeks.length,
          ),
        );

        expect(model.currentWeekIndex, isNotNull);
        final section = model.sections[model.currentWeekIndex!];
        expect(
          section.stones.any((stone) => stone.isCurrent),
          isTrue,
          reason:
              'no stone in the active week is marked current, so '
              'homeStoneCluster would degrade to fallback copy on device',
        );
      },
    );
  });
}
