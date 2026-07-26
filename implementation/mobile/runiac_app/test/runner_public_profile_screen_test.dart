import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:runiac_app/features/challenge/domain/models/challenge_enums.dart';
import 'package:runiac_app/features/leaderboard/presentation/models/leaderboard_display_models.dart';
import 'package:runiac_app/features/leaderboard/presentation/widgets/runner_achievement_profile_screen.dart';
import 'package:runiac_app/features/profile/data/cloud_functions_runner_public_profile_repository.dart';
import 'package:runiac_app/features/profile/domain/models/runner_public_profile_read_model.dart';
import 'package:runiac_app/features/profile/domain/repositories/runner_public_profile_repository.dart';
import 'package:runiac_app/features/profile/presentation/widgets/account_challenge_badge_case.dart';

const _rankRow = RunnerAchievementProfileSnapshot(
  name: 'Jinseo_main',
  initial: 'J',
  regionRankLabel: '#1 Jurong East, Singapore',
  levelBadgeLabel: 'Lv.8',
  divisionLevelLabel: 'Silver · Level 8',
  totalDistanceLabel: 'Not shared',
  bestStreakLabel: 'Not shared',
  badges: <RunnerAchievementBadgeSnapshot>[],
  rankLabel: '#1',
  regionLabel: 'Jurong East, Singapore',
  divisionLabel: 'Silver',
  snapshotId: 'monthly_jurong-east_tier_03_2026-07',
);

/// A row that carries a uid outright — the only other addressable form.
const _rankRowWithUid = RunnerAchievementProfileSnapshot(
  name: 'Jinseo_main',
  initial: 'J',
  regionRankLabel: '#1 Jurong East, Singapore',
  levelBadgeLabel: 'Lv.8',
  divisionLevelLabel: 'Silver · Level 8',
  totalDistanceLabel: 'Not shared',
  bestStreakLabel: 'Not shared',
  badges: <RunnerAchievementBadgeSnapshot>[],
  uid: 'runner-a',
  rankLabel: '#1',
  regionLabel: 'Jurong East, Singapore',
  divisionLabel: 'Silver',
);

/// A demo row with neither a uid nor a snapshot — nothing to resolve.
const _previewRow = RunnerAchievementProfileSnapshot(
  name: 'Jinseo_main',
  initial: 'J',
  regionRankLabel: '#1 Jurong East, Singapore',
  levelBadgeLabel: 'Lv.8',
  divisionLevelLabel: 'Silver · Level 8',
  totalDistanceLabel: 'Not shared',
  bestStreakLabel: 'Not shared',
  badges: <RunnerAchievementBadgeSnapshot>[],
  rankLabel: '#1',
  regionLabel: 'Jurong East, Singapore',
);

const _publicProfile = RunnerPublicProfileReadModel(
  uid: 'runner-a',
  displayName: 'Jinseo_main',
  avatarInitials: 'JI',
  regionLabel: 'Jurong East, Singapore',
  level: 8,
  levelProgressFraction: 0.975,
  totalXp: 780,
  nextLevelXp: 800,
  xpToNextLevel: 20,
  divisionKey: 'tier_03',
  divisionLabel: 'Silver League',
  longestStreakLabel: '4 days',
  totalDistanceLabel: '69.8 km',
  subscriptionStatusLabel: 'Basic',
  ownedTierIds: <ChallengeTierId>{ChallengeTierId.k250},
);

class _FakeRunnerPublicProfileRepository
    implements RunnerPublicProfileRepository {
  _FakeRunnerPublicProfileRepository({this.profile, this.failure});

  final RunnerPublicProfileReadModel? profile;
  final RunnerPublicProfileFailure? failure;
  final requestedPayloads = <Map<String, Object?>>[];

  @override
  Future<RunnerPublicProfileReadModel?> loadRunnerPublicProfile({
    required RunnerPublicProfileQuery query,
  }) async {
    requestedPayloads.add(query.toPayload());
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
    return profile;
  }
}

Widget _screen(
  RunnerPublicProfileRepository repository, {
  RunnerAchievementProfileSnapshot row = _rankRow,
}) {
  return MaterialApp(
    home: RunnerAchievementProfileScreen(
      profile: row,
      onBack: () {},
      publicProfileRepository: repository,
    ),
  );
}

void main() {
  testWidgets('shows the runner backend-owned public profile values', (
    WidgetTester tester,
  ) async {
    final repository = _FakeRunnerPublicProfileRepository(
      profile: _publicProfile,
    );

    await tester.pumpWidget(_screen(repository));
    await tester.pumpAndSettle();

    // The viewer never held a uid: the row is addressed by the entry it came
    // from, and the backend resolves the owner.
    expect(repository.requestedPayloads, <Map<String, Object?>>[
      <String, Object?>{
        'snapshotId': 'monthly_jurong-east_tier_03_2026-07',
        'rankLabel': '#1',
      },
    ]);
    expect(find.text('Jinseo_main'), findsOneWidget);
    expect(find.text('BASIC'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Jurong East, Singapore'), findsOneWidget);
    expect(find.text('Lv.8'), findsWidgets);
    expect(find.text('Lv.9'), findsOneWidget);
    expect(find.text('20 XP to level up'), findsOneWidget);
    expect(find.text('780 / 800 XP'), findsOneWidget);
    expect(find.text('4 days'), findsOneWidget);
    expect(find.text('Max streak'), findsOneWidget);
    expect(find.text('69.8 km'), findsOneWidget);
    expect(find.text('Total distance'), findsOneWidget);
    expect(find.byType(AccountChallengeBadgeCase), findsOneWidget);
    expect(
      tester
          .widget<AccountChallengeBadgeCase>(
            find.byType(AccountChallengeBadgeCase),
          )
          .ownedTierIds,
      <ChallengeTierId>{ChallengeTierId.k250},
    );
  });

  testWidgets('never renders the account-only sections of a profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _screen(_FakeRunnerPublicProfileRepository(profile: _publicProfile)),
    );
    await tester.pumpAndSettle();

    for (final accountOnly in [
      'RUNNING SETUP',
      'MANAGE',
      'Edit profile',
      'Settings',
      'Privacy & Safety',
      'Notifications',
      'Watch & Health Apps',
      'About Runiac',
      'Feedback',
      'Current goal',
      'Preferred unit',
      'Weekly rhythm',
      'Experience',
    ]) {
      expect(find.text(accountOnly), findsNothing, reason: accountOnly);
    }
  });

  testWidgets('shows the failure message and no earned badges when denied', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _screen(
        _FakeRunnerPublicProfileRepository(
          failure: const RunnerPublicProfileFailure(
            'This runner profile is not available.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This runner profile is not available.'), findsOneWidget);
    expect(
      tester
          .widget<AccountChallengeBadgeCase>(
            find.byType(AccountChallengeBadgeCase),
          )
          .ownedTierIds,
      isEmpty,
    );
    // The rank-row facts still label the screen.
    expect(find.text('Jinseo_main'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
  });

  testWidgets('keeps the leaderboard row values when no backend is wired', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _screen(const UnavailableRunnerPublicProfileRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jinseo_main'), findsOneWidget);
    expect(find.text('Not shared'), findsNWidgets(2));
    expect(
      find.text('Only public running achievements are shown.'),
      findsOneWidget,
    );
  });

  testWidgets('addresses a row that already carries a uid by that uid', (
    WidgetTester tester,
  ) async {
    final repository = _FakeRunnerPublicProfileRepository(
      profile: _publicProfile,
    );

    await tester.pumpWidget(_screen(repository, row: _rankRowWithUid));
    await tester.pumpAndSettle();

    expect(repository.requestedPayloads, <Map<String, Object?>>[
      <String, Object?>{'uid': 'runner-a'},
    ]);
  });

  testWidgets('never calls the backend for a row with nothing to resolve', (
    WidgetTester tester,
  ) async {
    final repository = _FakeRunnerPublicProfileRepository(
      profile: _publicProfile,
    );

    await tester.pumpWidget(_screen(repository, row: _previewRow));
    await tester.pumpAndSettle();

    expect(repository.requestedPayloads, isEmpty);
    expect(find.text('Not shared'), findsNWidgets(2));
  });

  group('Cloud Functions runner public profile repository', () {
    test('maps the callable payload into the read model', () async {
      Map<String, Object?>? sentPayload;
      final repository = CloudFunctionsRunnerPublicProfileRepository(
        callable: (payload) async {
          sentPayload = payload;
          return <Object?, Object?>{
            'uid': 'runner-a',
            'displayName': 'Jinseo_main',
            'avatarInitials': 'JI',
            'regionLabel': 'Jurong East, Singapore',
            'level': 8,
            'levelProgressPercent': 97.5,
            'totalXp': 780,
            'nextLevelXp': 800,
            'xpToNextLevel': 20,
            'isMaxLevel': false,
            'divisionKey': 'tier_03',
            'divisionLabel': 'Silver League',
            'longestStreakLabel': '4 days',
            'totalDistanceLabel': '69.8 km',
            'subscriptionStatusLabel': 'Basic',
            'ownedBadgeTierIds': <Object?>['250K', 'not-a-tier'],
          };
        },
      );

      final profile = await repository.loadRunnerPublicProfile(
        query: const RunnerPublicProfileQuery.leaderboardEntry(
          snapshotId: 'monthly_jurong-east_tier_03_2026-07',
          rankLabel: '#3',
        ),
      );

      expect(sentPayload, <String, Object?>{
        'snapshotId': 'monthly_jurong-east_tier_03_2026-07',
        'rankLabel': '#3',
      });
      expect(profile!.uid, 'runner-a');
      expect(profile.displayName, 'Jinseo_main');
      expect(profile.levelBadgeLabel, 'Lv.8');
      expect(profile.levelProgressFraction, closeTo(0.975, 0.0001));
      expect(profile.xpToNextLevel, 20);
      expect(profile.subscriptionStatusLabel, 'Basic');
      // An id this build does not know is skipped, never thrown on.
      expect(profile.ownedTierIds, <ChallengeTierId>{ChallengeTierId.k250});
    });

    test('reports an unusable response as a failure', () async {
      final repository = CloudFunctionsRunnerPublicProfileRepository(
        callable: (_) async => 'unexpected',
      );

      expect(
        () => repository.loadRunnerPublicProfile(
          query: const RunnerPublicProfileQuery.uid('runner-a'),
        ),
        throwsA(isA<RunnerPublicProfileFailure>()),
      );
    });
  });
}
