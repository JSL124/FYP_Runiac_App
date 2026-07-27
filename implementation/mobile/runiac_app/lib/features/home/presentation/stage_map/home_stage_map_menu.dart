part of 'home_stage_map.dart';

/// Fraction of [_HomeStageMapState._menuController] the panel shell uses to
/// grow in. The remaining tail belongs to the staggered rows.
const Interval _kHomeMenuShellInterval = Interval(
  0,
  0.75,
  curve: Curves.easeOutCubic,
);

/// Per-row start offset for the open stagger. Row `i` runs over
/// `Interval(i * offset, i * offset + 0.5)`.
const double _kHomeMenuRowStagger = 0.125;
const double _kHomeMenuRowSpan = 0.5;

/// Always-visible pill below the profile badge that toggles the Menu.
/// Navigation trigger only — reads and writes no social data. The caret shares
/// the panel's controller so the rotation and the panel can never disagree
/// about state.
class _HomeMenuTrigger extends StatefulWidget {
  const _HomeMenuTrigger({
    required this.open,
    required this.animation,
    required this.onTap,
  });

  final bool open;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  State<_HomeMenuTrigger> createState() => _HomeMenuTriggerState();
}

class _HomeMenuTriggerState extends State<_HomeMenuTrigger> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) {
      return;
    }
    setState(() {
      _pressed = pressed;
    });
  }

  void _handleTap() {
    RuniacHapticsScope.maybeOf(context)?.selection();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Menu',
      button: true,
      expanded: widget.open,
      child: ExcludeSemantics(
        child: GestureDetector(
          key: const ValueKey<String>('homeMenuTrigger'),
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _handleTap,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1,
            duration: Duration(milliseconds: _pressed ? 90 : 140),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: Duration(milliseconds: _pressed ? 90 : 140),
              curve: Curves.easeOut,
              padding: const EdgeInsets.fromLTRB(14, 7, 10, 7),
              decoration: _homeStageControlDecoration(
                borderRadius: BorderRadius.circular(999),
                fillAlpha: _pressed ? 1 : 0.92,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  RotationTransition(
                    turns: Tween<double>(
                      begin: 0,
                      end: 0.5,
                    ).animate(widget.animation),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact dropdown card below the Home header. The first row is a read-only
/// streak readout; the rest are destinations that forward to the caller's
/// navigation callbacks. No social or notification data is read or written
/// here — the counts arrive as plain values from [HomeStageMap].
class _HomeMenuPanel extends StatelessWidget {
  const _HomeMenuPanel({
    required this.animation,
    required this.streakCount,
    required this.streakLoading,
    required this.unreadNotificationCount,
    required this.onNotifications,
    required this.onFriends,
    required this.onChallenge,
  });

  final Animation<double> animation;
  final int streakCount;
  final bool streakLoading;
  final int unreadNotificationCount;
  final VoidCallback onNotifications;
  final VoidCallback onFriends;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // Closing collapses every stagger back onto one curve: the choice has
        // already been made, so drawing it out only adds latency.
        final closing = animation.status == AnimationStatus.reverse;
        final t = animation.value;
        final shell = closing
            ? Curves.easeInCubic.transform(t)
            : _kHomeMenuShellInterval.transform(t);

        double rowProgress(int index) {
          if (closing) {
            return shell;
          }
          final start = index * _kHomeMenuRowStagger;
          return Interval(
            start,
            start + _kHomeMenuRowSpan,
            curve: Curves.easeOutCubic,
          ).transform(t);
        }

        Widget row(int index, Widget child) {
          final progress = rowProgress(index);
          return Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - progress)),
              child: child,
            ),
          );
        }

        return Opacity(
          opacity: shell.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -6 * (1 - shell)),
            child: Transform.scale(
              scale: 0.92 + 0.08 * shell,
              alignment: Alignment.topRight,
              // Nothing that is still mostly invisible should accept a tap:
              // neither the rows mid-reveal nor anything during the exit.
              child: IgnorePointer(
                ignoring: closing || shell < 0.5,
                child: Container(
                  key: const ValueKey<String>('homeMenuPanel'),
                  width: 208,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: RuniacColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: RuniacColors.cardBorder,
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: RuniacColors.softCardShadow,
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      row(
                        0,
                        _HomeMenuStreakRow(
                          streakCount: streakCount,
                          loading: streakLoading,
                        ),
                      ),
                      const _HomeMenuDivider(),
                      row(
                        1,
                        _HomeMenuItem(
                          icon: Icons.notifications_none,
                          label: 'Notifications',
                          badgeCount: unreadNotificationCount,
                          onTap: onNotifications,
                        ),
                      ),
                      row(
                        2,
                        _HomeMenuItem(
                          icon: Icons.people_outline,
                          label: 'Friends',
                          onTap: onFriends,
                        ),
                      ),
                      row(
                        3,
                        _HomeMenuItem(
                          icon: Icons.emoji_events_outlined,
                          label: 'Challenge',
                          onTap: onChallenge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeMenuDivider extends StatelessWidget {
  const _HomeMenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: RuniacColors.border,
      indent: 14,
      endIndent: 14,
    );
  }
}

/// Read-only streak readout. Deliberately not tappable: there is no
/// streak-only detail surface to open, and the tinted background plus the
/// divider below mark it as status rather than a destination.
class _HomeMenuStreakRow extends StatelessWidget {
  const _HomeMenuStreakRow({required this.streakCount, required this.loading});

  final int streakCount;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final label = loading ? 'Day streak …' : '$streakCount day streak';
    final semanticsLabel = loading
        ? 'Current streak loading'
        : 'Current streak, $streakCount ${streakCount == 1 ? 'day' : 'days'}';
    return Semantics(
      container: true,
      label: semanticsLabel,
      readOnly: true,
      child: ExcludeSemantics(
        child: Container(
          key: const ValueKey<String>('homeMenuStreakRow'),
          color: RuniacColors.sectionSurface,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFFF8A34),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMenuItem extends StatelessWidget {
  const _HomeMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: badgeCount > 0 ? '$label, $badgeCount unread' : label,
      button: true,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(icon, color: RuniacColors.primaryBlue, size: 20),
                      if (badgeCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: _UnreadBadge(count: badgeCount),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
