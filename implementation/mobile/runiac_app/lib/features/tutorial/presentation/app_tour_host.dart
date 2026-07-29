import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/characters/runner_character.dart';
import '../domain/app_tour_seen_store.dart';
import 'app_tour_controller.dart';
import 'app_tour_overlay.dart';
import 'tutorial_anchor_registry.dart';

/// Composes the app tour into the shell: provides the [RuniacAppTourScope]
/// descendants use to reach [controller] (e.g. a manual "App tour" replay
/// row) and the [TutorialAnchorScope] every tab's [TutorialAnchor] resolves
/// against, renders the spotlight overlay above [child] when the tour is
/// running, auto-starts the tour once for an eligible brand-new user, and
/// pauses/resumes it around any modal route or sheet the shell presents
/// (e.g. Home's data-consent bottom sheet).
///
/// `seenStore == null` makes the tour completely inert: the overlay never
/// builds and no store call is ever made. This keeps previews and every
/// pre-existing shell test unaffected, since the shell defaults
/// `appTourSeenStore` to `null`.
class AppTourHost extends StatefulWidget {
  const AppTourHost({
    required this.controller,
    required this.seenStore,
    required this.autoStartArmed,
    required this.ownerUid,
    required this.child,
    this.homeRestDaySignal,
    super.key,
  });

  final AppTourController controller;
  final AppTourSeenStore? seenStore;
  final bool autoStartArmed;
  final String? ownerUid;
  final Widget child;

  /// Whether today is a scheduled rest day on the caller's active plan,
  /// forwarded straight through to [AppTourOverlay.isRestDay] every time this
  /// widget rebuilds. The caller (`RuniacShell`) computes this from the exact
  /// same plan/progress inputs and the same production
  /// `buildHomeStageMapModel` derivation the Home tab's own guide bubble uses
  /// (`HomeGuideRequest.isRestDay`) — never re-derived independently — so the
  /// tour can never disagree with what Home itself is showing. `null` means
  /// unknown (no active plan, or this host composed without a Home layer,
  /// e.g. most existing shell tests); the overlay always treats that the same
  /// as "not a rest day".
  final bool? homeRestDaySignal;

  @override
  State<AppTourHost> createState() => _AppTourHostState();
}

class _AppTourHostState extends State<AppTourHost> with WidgetsBindingObserver {
  bool _autoStarted = false;
  bool _lastKnownRunning = false;
  bool? _lastFrontmost;
  bool _settleScheduled = false;
  Timer? _refreshDebounce;
  Timer? _settleTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_handleControllerNotify);
  }

  @override
  void didUpdateWidget(covariant AppTourHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerNotify);
      widget.controller.addListener(_handleControllerNotify);
      _lastKnownRunning = widget.controller.running;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFrontmost();
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    _settleTimer?.cancel();
    widget.controller.removeListener(_handleControllerNotify);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleAnchorRefresh();
    }
  }

  @override
  void didChangeMetrics() {
    _scheduleAnchorRefresh();
  }

  void _scheduleAnchorRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) {
        return;
      }
      unawaited(widget.controller.refreshAnchor());
    });
  }

  void _handleControllerNotify() {
    final runningNow = widget.controller.running;
    if (_lastKnownRunning && !runningNow) {
      unawaited(_recordTourStopped());
    }
    _lastKnownRunning = runningNow;
    if (mounted) {
      setState(() {});
    }
  }

  /// Finishing (Done on the last step) and [AppTourController.skip] both stop
  /// the controller the same way, so both are recorded identically: the tour
  /// is marked completed and disarmed. A manual replay via
  /// [AppTourController.restart] later stopping again just re-writes the same
  /// idempotent state — it never re-arms auto-start.
  Future<void> _recordTourStopped() async {
    final seenStore = widget.seenStore;
    if (seenStore == null) {
      return;
    }
    final uid = widget.ownerUid;
    await seenStore.markCompleted(uid: uid);
    await seenStore.setArmed(uid: uid, armed: false);
  }

  void _syncFrontmost() {
    final route = ModalRoute.of(context);
    final frontmost = route?.isCurrent ?? true;
    final previous = _lastFrontmost;
    _lastFrontmost = frontmost;

    if (!frontmost) {
      widget.controller.pause();
      return;
    }

    if (previous == false) {
      // A blocking modal route/sheet just left the foreground.
      unawaited(_settleThenResumeOrStart());
    } else if (previous == null) {
      // First-ever evaluation, already frontmost: try auto-start once the
      // widget has had a frame to settle.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_maybeAutoStart());
        }
      });
    }
  }

  Future<void> _settleThenResumeOrStart() async {
    if (_settleScheduled) {
      return;
    }
    _settleScheduled = true;
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
      await _waitSettleDelay(widget.controller.settleDelay);
      if (!mounted) {
        return;
      }
      if (widget.controller.running) {
        await widget.controller.resume();
      } else {
        await _maybeAutoStart();
      }
    } finally {
      _settleScheduled = false;
    }
  }

  /// Waits for [duration] via an explicitly cancellable [Timer] rather than
  /// a bare `Future.delayed`, so a widget-tree teardown mid-wait (e.g. the
  /// host's ancestor route is popped) always cancels it in [dispose] instead
  /// of leaving it to fire later — bare `Future.delayed` timers left pending
  /// across a dispose fail widget tests' pending-timer invariant, and in
  /// production would otherwise touch a disposed controller.
  Future<void> _waitSettleDelay(Duration duration) {
    final completer = Completer<void>();
    _settleTimer?.cancel();
    _settleTimer = Timer(duration, () {
      _settleTimer = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> _maybeAutoStart() async {
    if (_autoStarted || !mounted) {
      return;
    }
    final seenStore = widget.seenStore;
    if (seenStore == null || !widget.autoStartArmed) {
      return;
    }
    if (widget.controller.currentTab != 0) {
      return;
    }
    if (!_isFrontmostNow()) {
      return;
    }

    final uid = widget.ownerUid;
    final armed = await seenStore.isArmed(uid: uid);
    if (!mounted || _autoStarted || !armed) {
      return;
    }
    final completed = await seenStore.isCompleted(uid: uid);
    if (!mounted || _autoStarted || completed) {
      return;
    }
    if (!_isFrontmostNow()) {
      return;
    }

    _autoStarted = true;
    await widget.controller.start();
  }

  bool _isFrontmostNow() {
    if (!mounted) {
      return false;
    }
    final route = ModalRoute.of(context);
    return route?.isCurrent ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final showOverlay = controller.running && !controller.paused;
    final anchorScope = TutorialAnchorScope(
      registry: controller.anchors,
      child: Stack(
        children: [
          widget.child,
          if (showOverlay)
            PopScope(
              // Android back must map to skip rather than popping the shell
              // out from under a live overlay.
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  controller.skip();
                }
              },
              child: AppTourOverlay(
                step: controller.currentStep,
                hole: controller.hole,
                useFallbackCopy: controller.useFallbackCopy,
                isRestDay: widget.homeRestDaySignal,
                character:
                    SelectedRunnerCharacterScope.maybeOf(
                      context,
                    )?.selectedOrDefault ??
                    RunnerCharacter.blue,
                stepIndex: controller.stepIndex,
                stepCount: controller.stepCount,
                onNext: () => unawaited(controller.next()),
                onSkip: () => controller.skip(),
              ),
            ),
        ],
      ),
    );
    // `seenStore == null` keeps the whole tour "completely inert" (see class
    // doc): no overlay, no store call, and — matching that same contract —
    // no `RuniacAppTourScope` either, so a manual replay entry point (the
    // Home menu's "App tour" row) never appears somewhere the tour has no
    // persistence to record against. This is also what keeps every
    // pre-existing widget test that composes `HomeStageMap`/other tabs
    // without an `AppTourHost` ancestor at all unaffected, plus any future
    // shell test that explicitly passes `appTourSeenStore: null`.
    if (widget.seenStore == null) {
      return anchorScope;
    }
    return RuniacAppTourScope(controller: controller, child: anchorScope);
  }
}
