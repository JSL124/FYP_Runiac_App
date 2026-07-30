import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/feed/domain/models/feed_display_models.dart';
import 'package:runiac_app/features/feed/domain/repositories/feed_repository.dart';
import 'package:runiac_app/features/feed/presentation/current_session_feed.dart';
import 'package:runiac_app/features/feed/presentation/feed_comment_intent_controller.dart';
import 'package:runiac_app/features/feed/presentation/feed_timeline_screen_controller.dart';

void main() {
  testWidgets(
    'a notification intent for an already-loaded post opens its comment '
    'sheet without refreshing or paging',
    (WidgetTester tester) async {
      final repository = _FakeFeedTimelineRepository(
        initialPosts: [_post('visible-post')],
      );
      final intent = FeedCommentIntentController();
      addTearDown(intent.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentSessionFeed(
              repository: repository,
              viewerContext: const FeedViewerContext(
                currentUserId: 'runner-current',
                acceptedFriendUserIds: <String>{},
              ),
              commentIntent: intent,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      intent.request('visible-post');
      await tester.pumpAndSettle();

      expect(find.text('Comments'), findsOneWidget);
      expect(repository.refreshCalls, 0);
      expect(repository.loadMoreCalls, 0);
      expect(intent.pendingPostId, isNull);
    },
  );

  testWidgets(
    'a notification intent for an unresolved post refreshes then pages '
    'before showing the not-found message and opening no sheet',
    (WidgetTester tester) async {
      final repository = _FakeFeedTimelineRepository(
        initialPosts: [_post('other-post')],
      );
      final intent = FeedCommentIntentController();
      addTearDown(intent.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentSessionFeed(
              repository: repository,
              viewerContext: const FeedViewerContext(
                currentUserId: 'runner-current',
                acceptedFriendUserIds: <String>{},
              ),
              commentIntent: intent,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      intent.request('missing-post');
      await tester.pumpAndSettle();

      expect(repository.refreshCalls, 1);
      expect(repository.loadMoreCalls, 2);
      expect(
        find.text('That post is no longer in your feed.'),
        findsOneWidget,
      );
      expect(find.text('Comments'), findsNothing);
      expect(intent.pendingPostId, isNull);
    },
  );

  test(
    'a pending intent is cleared when the signed-in owner changes, so it '
    'cannot auto-open a sheet for the previous account\'s post',
    () {
      final intent = FeedCommentIntentController();
      addTearDown(intent.dispose);
      final sessionStore = CurrentSessionFeedStore(ownerUid: 'runner-a');
      addTearDown(sessionStore.dispose);
      final controller = FeedTimelineScreenController(
        _FakeFeedTimelineRepository(initialPosts: const []),
        null,
        null,
        intent,
      );
      addTearDown(controller.dispose);
      controller.attachSession(sessionStore);

      intent.request('post-owned-by-runner-a');
      expect(intent.pendingPostId, 'post-owned-by-runner-a');

      sessionStore.syncOwner('runner-b');
      final cleared = controller.clearForOwnerChange();

      expect(cleared, isTrue);
      expect(intent.pendingPostId, isNull);
    },
  );
}

FeedPostReadModel _post(String postId) => FeedPostReadModel(
  postId: postId,
  authorUserId: 'friend',
  authorDisplayName: 'Friend Runner',
  authorAvatarInitials: 'FR',
  authorLevelLabel: 'Level 3',
  relativeTimeLabel: 'Now',
  distanceLabel: '2.0 km',
  paceLabel: '7:00 / km',
  durationLabel: '14 min',
  likeCount: 0,
  commentCount: 0,
  isLikedByViewer: false,
  hasViewerCommented: false,
  canComment: true,
  showsOwnerMenu: false,
  routeThumbnail: const FeedRouteThumbnailReadModel(
    thumbnailKey: 'notification-tap-through',
    accessibilityLabel: 'Private route preview',
  ),
);

/// A minimal production-shaped [FeedTimelineRepository] that never actually
/// grows its post list on `loadMore`, so an unresolved postId stays
/// unresolved after paging — used to exercise the refresh-then-page-then-
/// give-up resolution order in [FeedTimelineScreenController.openCommentsForPostId].
class _FakeFeedTimelineRepository implements FeedTimelineRepository {
  _FakeFeedTimelineRepository({required List<FeedPostReadModel> initialPosts})
    : _posts = List<FeedPostReadModel>.of(initialPosts);

  final List<FeedPostReadModel> _posts;
  bool _exhausted = false;
  int refreshCalls = 0;
  int loadMoreCalls = 0;

  @override
  FeedTimelineState get currentState => FeedTimelineState(
    posts: _posts,
    source: FeedTimelineSource.server,
    refreshing: false,
    exhausted: _exhausted,
  );

  @override
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext) =>
      loadInitial(viewerContext);

  @override
  Future<FeedTimelineState> loadInitial(
    FeedViewerContext viewerContext,
  ) async => currentState;

  @override
  Future<FeedTimelineState> refresh() async {
    refreshCalls += 1;
    return currentState;
  }

  @override
  Future<FeedTimelineState> loadMore() async {
    loadMoreCalls += 1;
    // Exhaust after two pages so the controller's maxAdditionalPages bound
    // (rather than exhaustion) is what the first test below observes, while
    // still proving the loop terminates instead of paging forever.
    if (loadMoreCalls >= 2) {
      _exhausted = true;
    }
    return currentState;
  }

  @override
  Future<FeedTimelineState> reconcileAccess() async => currentState;

  @override
  Future<void> setLike({
    required String postId,
    required bool isLiked,
  }) async {}

  @override
  Future<void> createComment(FeedCommentMutation mutation) async {}

  @override
  Future<void> updateComment(FeedCommentMutation mutation) async {}

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {}

  @override
  Future<void> reportPost(String postId) async {}

  @override
  Future<void> deletePost(String postId) async {}

  @override
  Future<Uint8List> readThumbnail(String postId) async => Uint8List(0);

  @override
  void dispose() {}
}
