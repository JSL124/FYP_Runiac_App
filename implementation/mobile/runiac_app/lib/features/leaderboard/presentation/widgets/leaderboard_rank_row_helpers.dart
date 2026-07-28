import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_level_profile_badge.dart';
import '../models/leaderboard_display_models.dart';

({Color background, Color foreground}) resolveRegionPreviewMedalColors(
  RegionPreviewMedalTone tone,
) {
  return switch (tone) {
    RegionPreviewMedalTone.gold => (
      background: const Color(0xFFFFF2E2),
      foreground: RuniacColors.accentOrange,
    ),
    RegionPreviewMedalTone.silver => (
      background: const Color(0xFFEFF3FB),
      foreground: RuniacColors.textSecondary,
    ),
    RegionPreviewMedalTone.bronze => (
      background: const Color(0xFFFFEBDD),
      foreground: const Color(0xFFB56A36),
    ),
  };
}

class LeaderboardInitialBadge extends StatelessWidget {
  const LeaderboardInitialBadge({
    super.key,
    required this.name,
    required this.levelLabel,
    required this.isCurrentUser,
    this.photoUrl = '',
  });

  final String name;
  final String levelLabel;
  final bool isCurrentUser;

  /// Raw, not-yet-sanitised avatar photo URL for this row. Empty renders the
  /// initials disc.
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('leaderboard_profile_level_badge'),
      width: 38,
      height: 40,
      child: RuniacLevelProfileBadge(
        initials: name,
        levelLabel: levelLabel,
        progressFraction: 0,
        photoUrl: photoUrl,
        size: 34,
        badgeHeight: 13,
        badgeMinWidth: isCurrentUser ? 30 : 24,
        badgeHorizontalPadding: 5,
        badgeFontSize: 8,
        ringStrokeWidth: 3.4,
      ),
    );
  }
}
