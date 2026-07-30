import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/profile/data/static_user_profile_repository.dart';
import 'package:runiac_app/features/profile/domain/repositories/user_profile_persistence_repository.dart';
import 'package:runiac_app/features/auth/data/non_production_auth_repository.dart';
import 'package:runiac_app/features/challenge/presentation/challenge_invitations_screen.dart';
import 'package:runiac_app/features/home/presentation/home_tab.dart';
import 'package:runiac_app/features/home/presentation/widgets/home_header.dart';
import 'package:runiac_app/features/notifications/domain/models/notification_inbox_item.dart';
import 'package:runiac_app/features/notifications/domain/repositories/notification_inbox_repository.dart';
import 'package:runiac_app/features/notifications/presentation/notification_inbox_page.dart';

void main() {
  testWidgets(
    'Home notification bell hides badge at zero and caps unread count',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HomeHeader(
                  unreadNotificationCount: 0,
                  onNotifications: () {},
                  onProfile: () {},
                ),
                HomeHeader(
                  unreadNotificationCount: 120,
                  onNotifications: () {},
                  onProfile: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
      expect(find.text('99+'), findsOneWidget);
      final badgeText = tester.widget<Text>(find.text('99+'));
      expect(badgeText.style?.color, Colors.white);
    },
  );

  testWidgets(
    'Home bell opens notification inbox instead of account settings',
    (WidgetTester tester) async {
      final repository = InMemoryNotificationInboxRepository(
        items: [
          NotificationInboxItem(
            id: 'item-1',
            title: 'Run reminder',
            body: 'Your easy run is ready.',
            createdAt: DateTime.utc(2026, 7, 8, 5),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeTab(
            authRepository: const NonProductionAuthRepository(),
            profileRepository: const StaticUserProfileRepository(),
            profilePersistenceRepository:
                const NoopUserProfilePersistenceRepository(),
            notificationInboxRepository: repository,
            enableForegroundGps: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification Center'), findsNothing);

      // The bell now lives inside the Home Menu panel.
      await tester.tap(find.bySemanticsLabel('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationInboxPage), findsOneWidget);
      expect(find.text('Run reminder'), findsOneWidget);
      expect(find.text('Notification Center'), findsNothing);
    },
  );

  testWidgets(
    'a tapped feed-engagement item pops the inbox and calls '
    'onOpenFeedPostComments instead of the challenge router',
    (WidgetTester tester) async {
      final repository = InMemoryNotificationInboxRepository(
        items: [
          NotificationInboxItem(
            id: 'item-1',
            title: 'New like',
            body: 'A friend liked your run.',
            createdAt: DateTime.utc(2026, 7, 8, 5),
            data: const {
              'kind': 'feed_post_liked',
              'route': 'feedComments',
              'postId': 'post-42',
            },
          ),
        ],
      );
      String? openedPostId;

      await tester.pumpWidget(
        MaterialApp(
          home: HomeTab(
            authRepository: const NonProductionAuthRepository(),
            profileRepository: const StaticUserProfileRepository(),
            profilePersistenceRepository:
                const NoopUserProfilePersistenceRepository(),
            notificationInboxRepository: repository,
            enableForegroundGps: false,
            onOpenFeedPostComments: (postId) => openedPostId = postId,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationInboxPage), findsOneWidget);

      await tester.tap(find.text('New like'));
      await tester.pumpAndSettle();

      expect(openedPostId, 'post-42');
      // The inbox route was popped before the callback fired, so it must no
      // longer be on the stack (the comment sheet opens on the Feed tab,
      // not stacked underneath the inbox).
      expect(find.byType(NotificationInboxPage), findsNothing);
      expect(find.byType(ChallengeInvitationsScreen), findsNothing);
    },
  );

  testWidgets(
    'a tapped challenge item still reaches the challenge router unchanged',
    (WidgetTester tester) async {
      final repository = InMemoryNotificationInboxRepository(
        items: [
          NotificationInboxItem(
            id: 'item-2',
            title: 'Challenge invite',
            body: 'A friend invited you to a challenge.',
            createdAt: DateTime.utc(2026, 7, 8, 5),
            data: const {
              'kind': 'challenge_invitation_received',
              'challengeId': 'challenge-1',
            },
          ),
        ],
      );
      String? openedPostId;

      await tester.pumpWidget(
        MaterialApp(
          home: HomeTab(
            authRepository: const NonProductionAuthRepository(),
            profileRepository: const StaticUserProfileRepository(),
            profilePersistenceRepository:
                const NoopUserProfilePersistenceRepository(),
            notificationInboxRepository: repository,
            enableForegroundGps: false,
            onOpenFeedPostComments: (postId) => openedPostId = postId,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Challenge invite'));
      await tester.pumpAndSettle();

      expect(openedPostId, isNull);
      expect(find.byType(ChallengeInvitationsScreen), findsOneWidget);
    },
  );
}
