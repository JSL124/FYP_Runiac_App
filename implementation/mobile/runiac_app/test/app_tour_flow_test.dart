import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/features/feed/data/static_feed_repository.dart';
import 'package:runiac_app/features/feed/domain/models/feed_display_models.dart';
import 'package:runiac_app/features/feed/domain/repositories/feed_repository.dart';
import 'package:runiac_app/features/feed/presentation/feed_timeline_screen_controller.dart';
import 'package:runiac_app/features/feed/presentation/widgets/feed_post_list.dart';
import 'package:runiac_app/features/feed/presentation/widgets/feed_post_section.dart';
import 'package:runiac_app/features/leaderboard/domain/models/leaderboard_read_model.dart';
import 'package:runiac_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:runiac_app/features/plan/presentation/current_session_generated_plan.dart';
import 'package:runiac_app/features/profile/data/static_user_profile_repository.dart';
import 'package:runiac_app/features/profile/domain/repositories/user_profile_persistence_repository.dart';
import 'package:runiac_app/features/run/presentation/run_launch_screen.dart';
import 'package:runiac_app/features/shell/runiac_shell.dart';
import 'package:runiac_app/features/tutorial/domain/app_tour_seen_store.dart';
import 'package:runiac_app/features/tutorial/domain/models/tutorial_step.dart';
import 'package:runiac_app/features/tutorial/presentation/spotlight_scrim_painter.dart';
import 'package:runiac_app/features/tutorial/presentation/tutorial_anchor_registry.dart';
import 'package:runiac_app/features/you/presentation/current_session_activity_history.dart';

import 'support/fake_runiac_auth_repository.dart';

const _ownerUid = 'test-auth-user-1';

/// This test's purpose is the tour's tab-driving state machine, not the
/// leaderboard map's rendering, so it uses a small, compact anchor (the
/// region-required state message) instead of the full map.
class _CompactAnchorLeaderboardRepository implements LeaderboardRepository {
  const _CompactAnchorLeaderboardRepository();

  @override
  Future<LeaderboardReadModel> loadLeaderboard() async {
    return LeaderboardReadModel(
      status: LeaderboardReadStatus.regionRequired,
      regionLabel: '',
      currentRunnerRankLabel: '',
      entries: const [],
    );
  }

  @override
  Future<LeaderboardReadModel> loadRegion({required String regionId}) async {
    return loadLeaderboard();
  }
}

/// Returns two fixed posts regardless of viewer context. Unlike
/// `StaticFeedRepository`, this is unconditionally non-empty: the shell's
/// real viewer context (the authenticated test uid, no accepted friends)
/// would otherwise filter every `StaticFeedRepository` demo post out,
/// leaving the feed step nothing to spotlight. Two posts (not one) let the
/// `feedFirstPost` coverage below prove only the first card is tagged.
class _NonEmptyFeedRepository implements FeedRepository {
  const _NonEmptyFeedRepository();

  @override
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext) async {
    return FeedReadModel(
      posts: const [
        FeedPostReadModel(
          postId: 'tour-feed-post-1',
          authorUserId: 'tour-author-1',
          authorDisplayName: 'Tour Runner',
          authorAvatarInitials: 'TR',
          authorLevelLabel: 'Level 1',
          relativeTimeLabel: 'Today',
          distanceLabel: '3.0 km',
          paceLabel: '7:00 / km',
          durationLabel: '21 min',
          likeCount: 0,
          commentCount: 0,
          isLikedByViewer: false,
          hasViewerCommented: false,
          canComment: true,
          showsOwnerMenu: false,
          routeThumbnail: FeedRouteThumbnailReadModel(
            thumbnailKey: 'tour-post-thumbnail-1',
            accessibilityLabel: 'A simplified route preview',
          ),
        ),
        FeedPostReadModel(
          postId: 'tour-feed-post-2',
          authorUserId: 'tour-author-2',
          authorDisplayName: 'Second Runner',
          authorAvatarInitials: 'SR',
          authorLevelLabel: 'Level 2',
          relativeTimeLabel: 'Yesterday',
          distanceLabel: '4.0 km',
          paceLabel: '6:50 / km',
          durationLabel: '27 min',
          likeCount: 0,
          commentCount: 0,
          isLikedByViewer: false,
          hasViewerCommented: false,
          canComment: true,
          showsOwnerMenu: false,
          routeThumbnail: FeedRouteThumbnailReadModel(
            thumbnailKey: 'tour-post-thumbnail-2',
            accessibilityLabel: 'A simplified route preview',
          ),
        ),
      ],
    );
  }
}

/// Returns two fixed posts, but only after a delay shorter than the
/// controller's `preferredAnchorWindow` (800ms by default) — simulating the
/// real feed screen, whose whole-list container (`feedPostList`) mounts on
/// the first frame while the first post card (`feedFirstPost`) only exists
/// once this future resolves. Used to prove the higher-priority
/// `feedFirstPost` candidate is still selected even though the lower-priority
/// `feedPostList` fallback is already mounted and would otherwise win the
/// very first poll tick.
class _LateFirstPostFeedRepository implements FeedRepository {
  const _LateFirstPostFeedRepository();

  @override
  Future<FeedReadModel> loadFeed(FeedViewerContext viewerContext) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const _NonEmptyFeedRepository().loadFeed(viewerContext);
  }
}

/// Advances the fake clock in explicit ticks rather than `pumpAndSettle`.
///
/// The controller's anchor poll waits via plain `Future.delayed` timers
/// without necessarily scheduling a new frame while waiting, so
/// `pumpAndSettle` (which stops as soon as no frame is scheduled) can return
/// before a poll loop actually concludes. Ticking a fixed number of 100ms
/// frames — matching the controller's default poll interval — advances those
/// timers deterministically regardless of frame-scheduling.
Future<void> _pumpTourSettle(WidgetTester tester, {int ticks = 50}) async {
  for (var i = 0; i < ticks; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Advances the tour via the Next/Done button's own `onPressed` callback
/// rather than a simulated screen tap.
///
/// This test suite's focus is the tour's tab-driving state machine, not the
/// pixel geometry of every screen it visits, so most steps advance this way.
/// See [_tapNextByTap] for the one step that exercises a real screen tap.
Future<void> _tapNext(WidgetTester tester) async {
  final button = tester.widget<FilledButton>(
    find.byKey(const ValueKey('appTourNextButton')),
  );
  button.onPressed!();
  await _pumpTourSettle(tester);
}

/// Advances the tour via a real `tester.tap()` on the Next button.
///
/// Used on the Leaderboard step specifically: its anchor is a full-bleed
/// tab background, the exact shape that once placed `AppTourOverlay`'s
/// speech bubble off-screen. A real tap proves the button is actually
/// reachable now that oversized holes degrade to the no-hole layout.
Future<void> _tapNextByTap(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('appTourNextButton')));
  await _pumpTourSettle(tester);
}

Future<void> _tapSkip(WidgetTester tester) async {
  final button = tester.widget<TextButton>(
    find.byKey(const ValueKey('appTourSkipButton')),
  );
  button.onPressed!();
  await _pumpTourSettle(tester);
}

String _bubbleText(WidgetTester tester) {
  return tester
      .widget<Text>(find.byKey(const ValueKey('appTourBubbleBody')))
      .data!;
}

/// Reads the "N of M" phrasing off the step-progress cue's `Semantics`
/// label. The cue itself renders as a compact segmented indicator, not
/// literal text, so its rendered "text" for test purposes is what assistive
/// tech would announce.
String? _stepCounter(WidgetTester tester) {
  final finder = find.byKey(const ValueKey('appTourStepCounter'));
  if (finder.evaluate().isEmpty) {
    return null;
  }
  return tester.widget<Semantics>(finder).properties.label;
}

bool _slotOffstage(WidgetTester tester, int index) {
  return tester
      .widget<Offstage>(find.byKey(ValueKey<String>('runiac-shell-slot-$index')))
      .offstage;
}

SpotlightScrimPainter _scrimPainter(WidgetTester tester) {
  return tester
      .widget<CustomPaint>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is SpotlightScrimPainter,
        ),
      )
      .painter as SpotlightScrimPainter;
}

Widget _buildHarness({
  required FakeRuniacAuthRepository authRepository,
  required AppTourSeenStore? seenStore,
  bool autoStartArmed = false,
  FeedRepository feedRepository = const StaticFeedRepository(),
}) {
  // The You tab (visited by the tour) asserts a CurrentSessionActivityHistoryScope
  // ancestor; a fresh store per pump matches `shell_tab_lifecycle_test.dart`.
  final activityHistoryStore = CurrentSessionActivityHistoryStore(
    ownerUid: _ownerUid,
  );
  addTearDown(activityHistoryStore.dispose);
  return MaterialApp(
    home: CurrentSessionActivityHistoryScope(
      store: activityHistoryStore,
      child: CurrentSessionGeneratedPlanScope(
        store: CurrentSessionGeneratedPlanStore(),
        child: RuniacShell(
          authRepository: authRepository,
          feedRepository: feedRepository,
          leaderboardRepository: const _CompactAnchorLeaderboardRepository(),
          profileRepository: const StaticUserProfileRepository(),
          profilePersistenceRepository:
              const NoopUserProfilePersistenceRepository(),
          enableForegroundGps: false,
          appTourSeenStore: seenStore,
          appTourAutoStartArmed: autoStartArmed,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'auto-starts on Home, drives every tab, never opens Run, and finishes '
    'via Done leaving the store completed and disarmed',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      addTearDown(authRepository.dispose);
      final seenStore = InMemoryAppTourSeenStore();
      await seenStore.setArmed(uid: _ownerUid, armed: true);

      await tester.pumpWidget(
        _buildHarness(
          authRepository: authRepository,
          seenStore: seenStore,
          autoStartArmed: true,
        ),
      );
      await _pumpTourSettle(tester);

      // Step 0: welcome, on Home, no anchor.
      expect(_stepCounter(tester), '1 of 12');
      expect(
        _bubbleText(tester),
        "Hi, I'm Bolt — your running buddy. Give me 30 seconds and I'll "
        'show you around.',
      );
      expect(_slotOffstage(tester, 0), isFalse);

      // Steps 1-6: home-today-stone, home-stone-days, home-rest-streak,
      // home-stone-detail, home-level-avatar, home-menu — all Home.
      await _tapNext(tester); // -> step 1
      await _tapNext(tester); // -> step 2
      await _tapNext(tester); // -> step 3
      await _tapNext(tester); // -> step 4
      await _tapNext(tester); // -> step 5
      await _tapNext(tester); // -> step 6
      expect(_stepCounter(tester), '7 of 12');
      expect(_slotOffstage(tester, 0), isFalse);

      // Step 7: run-button. Tapping the Run tooltip's screen position must
      // never reach the underlying nav item and open the run flow — the
      // overlay's opaque scrim sits above it and only nudges the bubble.
      await _tapNext(tester); // -> step 7 (run-button)
      expect(_stepCounter(tester), '8 of 12');
      expect(find.byType(RunLaunchScreen), findsNothing);
      await tester.tap(find.byTooltip('Run'));
      await tester.pump();
      expect(find.byType(RunLaunchScreen), findsNothing);

      // Step 8: feed. See `FeedPostList tags only the first post card...`
      // below for the `feedFirstPost` anchor's own coverage — this suite's
      // focus is the tour's tab-driving state machine, not feed content.
      await _tapNext(tester);
      expect(_stepCounter(tester), '9 of 12');
      expect(_slotOffstage(tester, 1), isFalse);

      // Step 9: leaderboard.
      await _tapNext(tester);
      expect(_stepCounter(tester), '10 of 12');
      expect(_slotOffstage(tester, 3), isFalse);

      // Step 10: you. Advanced via a real tap while anchored on the
      // Leaderboard tab's full-bleed hole (see `_tapNextByTap`).
      await _tapNextByTap(tester);
      expect(_stepCounter(tester), '11 of 12');
      expect(_slotOffstage(tester, 4), isFalse);

      // Step 11: finish, back on Home; button now reads Done.
      await _tapNext(tester);
      expect(_stepCounter(tester), '12 of 12');
      expect(_slotOffstage(tester, 0), isFalse);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('appTourNextButton')),
            )
            .child,
        isA<Text>().having((text) => text.data, 'data', 'Done'),
      );

      // Done: overlay is gone, and the store is completed + disarmed.
      await _tapNext(tester);
      expect(find.byKey(const ValueKey('appTourNextButton')), findsNothing);
      expect(await seenStore.isCompleted(uid: _ownerUid), isTrue);
      expect(await seenStore.isArmed(uid: _ownerUid), isFalse);

      // Re-pumping a fresh shell against the same (now-completed) store never
      // shows the overlay again.
      final freshAuthRepository = FakeRuniacAuthRepository()..emitSignedIn();
      addTearDown(freshAuthRepository.dispose);
      await tester.pumpWidget(
        _buildHarness(
          authRepository: freshAuthRepository,
          seenStore: seenStore,
          autoStartArmed: true,
        ),
      );
      await _pumpTourSettle(tester);
      expect(find.byKey(const ValueKey('appTourNextButton')), findsNothing);
    },
  );

  testWidgets(
    'skip on an early step disarms and completes the store and removes the '
    'overlay',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      addTearDown(authRepository.dispose);
      final seenStore = InMemoryAppTourSeenStore();
      await seenStore.setArmed(uid: _ownerUid, armed: true);

      await tester.pumpWidget(
        _buildHarness(
          authRepository: authRepository,
          seenStore: seenStore,
          autoStartArmed: true,
        ),
      );
      await _pumpTourSettle(tester);
      expect(find.byKey(const ValueKey('appTourNextButton')), findsOneWidget);

      await _tapNext(tester); // advance one step before skipping
      await _tapSkip(tester);

      expect(find.byKey(const ValueKey('appTourNextButton')), findsNothing);
      expect(await seenStore.isCompleted(uid: _ownerUid), isTrue);
      expect(await seenStore.isArmed(uid: _ownerUid), isFalse);
    },
  );

  testWidgets('appTourSeenStore null keeps the tour completely inert', (
    tester,
  ) async {
    final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
    addTearDown(authRepository.dispose);

    await tester.pumpWidget(
      _buildHarness(
        authRepository: authRepository,
        seenStore: null,
        autoStartArmed: true,
      ),
    );
    await _pumpTourSettle(tester);

    expect(find.byKey(const ValueKey('appTourNextButton')), findsNothing);
    expect(find.byKey(const ValueKey('appTourSkipButton')), findsNothing);
  });

  testWidgets(
    'FeedPostList tags only the first post card with feedFirstPost, at a '
    'size well under the whole-screen fallback',
    (tester) async {
      final registry = TutorialAnchorRegistry();
      final controller = FeedTimelineScreenController(
        const _NonEmptyFeedRepository(),
        const FeedViewerContext(
          currentUserId: 'viewer',
          acceptedFriendUserIds: <String>{},
        ),
      );
      addTearDown(controller.dispose);
      // Awaited fully before the first pump: this test's purpose is proving
      // `feed_post_list.dart`'s wrap is correct (exactly one live
      // `feedFirstPost` anchor, on the first card only), not the app tour
      // controller's separate anchor-polling timing.
      await controller.refresh();

      // A tall viewport (unlike the default 800x600 test surface, which is
      // wider than it is tall) keeps this a stable, non-fragile comparison:
      // a single post card's fixed content height is a large fraction of a
      // short/wide surface but a small fraction of a normal, tall phone-like
      // one — the shape that actually matters for a spotlight hole.
      const size = Size(400, 1600);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: TutorialAnchorScope(
            registry: registry,
            child: Scaffold(body: FeedPostList(controller: controller)),
          ),
        ),
      );
      await tester.pump();

      // Both posts render, but only one carries the anchor id — if the wrap
      // ever leaked onto a second card, the shared GlobalKey would already
      // have thrown a duplicate-key error during this pump.
      expect(find.byType(FeedPostSection), findsNWidgets(2));

      final firstPostRect = registry.rectFor(TutorialAnchorId.feedFirstPost);
      expect(firstPostRect, isNotNull);

      final screenArea = size.width * size.height;
      final firstPostArea = firstPostRect!.width * firstPostRect.height;
      // A usable spotlight target, not a whole-screen fallback.
      expect(firstPostArea, lessThan(screenArea * 0.5));
    },
  );

  testWidgets(
    'feed step waits for the higher-priority feedFirstPost anchor to mount '
    'rather than settling for the already-mounted feedPostList container',
    (tester) async {
      final authRepository = FakeRuniacAuthRepository()..emitSignedIn();
      addTearDown(authRepository.dispose);
      final seenStore = InMemoryAppTourSeenStore();
      await seenStore.setArmed(uid: _ownerUid, armed: true);

      // Keeps the default test surface's width (unlike the `FeedPostList`-
      // only test above, which also narrows the width): the app tour
      // overlay's speech bubble overflows on a narrow viewport. Only the
      // height is stretched to a normal, tall phone-like proportion so a
      // single post card — a large fraction of the default 800x600
      // surface's short height — is a small, meaningful fraction here.
      const size = Size(800, 1600);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildHarness(
          authRepository: authRepository,
          seenStore: seenStore,
          autoStartArmed: true,
          // `feedPostList` (the whole-list container) mounts on the very
          // first frame; `feedFirstPost` only appears once this repository's
          // 400ms-delayed future resolves — well inside the controller's
          // default 800ms preferred window, so the primary candidate must
          // still win.
          feedRepository: const _LateFirstPostFeedRepository(),
        ),
      );
      await _pumpTourSettle(tester);

      // welcome(0) -> home-today-stone(1) -> home-stone-days(2)
      // -> home-rest-streak(3) -> home-stone-detail(4) -> home-level-avatar(5)
      // -> home-menu(6) -> run-button(7) -> feed(8).
      for (var i = 0; i < 8; i++) {
        await _tapNext(tester);
      }
      expect(_stepCounter(tester), '9 of 12');

      // `feedPostList` is full-bleed: if it had won instead of the primary
      // `feedFirstPost` candidate, `AppTourOverlay`'s oversized-hole rule
      // (>=70% of screen area) would degrade the step to a null hole
      // (plain full-screen dim) — this is exactly the regression this poll
      // ordering fixes. A non-null, materially-smaller-than-screen hole here
      // proves `feedFirstPost` resolved instead.
      final hole = _scrimPainter(tester).hole;
      expect(hole, isNotNull);
      final screenArea = size.width * size.height;
      final holeArea = hole!.width * hole.height;
      expect(holeArea, lessThan(screenArea * 0.5));
    },
  );
}
