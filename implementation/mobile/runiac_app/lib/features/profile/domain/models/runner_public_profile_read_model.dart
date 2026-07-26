import '../../../challenge/domain/models/challenge_enums.dart';

/// Backend-produced public profile contract for a runner other than the
/// signed-in user, as served by the `getRunnerPublicProfile` callable.
///
/// Every value here is a trusted backend output the client only relays. The
/// client never derives level, XP, streak, distance, division, subscription
/// tier, or badge ownership from anything else.
class RunnerPublicProfileReadModel {
  const RunnerPublicProfileReadModel({
    required this.uid,
    this.displayName = '',
    this.avatarInitials = '',
    this.regionLabel = '',
    this.level = 0,
    this.levelProgressFraction = 0,
    this.totalXp,
    this.nextLevelXp,
    this.xpToNextLevel,
    this.isMaxLevel = false,
    this.divisionKey = '',
    this.divisionLabel = '',
    this.longestStreakLabel = '',
    this.totalDistanceLabel = '',
    this.subscriptionStatusLabel = '',
    this.ownedTierIds = const <ChallengeTierId>{},
  });

  final String uid;
  final String displayName;
  final String avatarInitials;
  final String regionLabel;
  final int level;
  final double levelProgressFraction;
  final int? totalXp;
  final int? nextLevelXp;
  final int? xpToNextLevel;

  /// True only when the backend explicitly reported the max level was reached.
  final bool isMaxLevel;
  final String divisionKey;
  final String divisionLabel;
  final String longestStreakLabel;
  final String totalDistanceLabel;

  /// Trusted Basic/Premium tier label. Display only: it never grants access.
  final String subscriptionStatusLabel;

  /// Challenge tiers this runner has earned a badge for.
  final Set<ChallengeTierId> ownedTierIds;

  String get levelBadgeLabel => 'Lv.$level';
}

/// Raised when a runner's public profile cannot be served — the viewer or the
/// runner blocked the other, the runner is suspended, no profile exists, or
/// the backend was unreachable. Carries a message safe to show as-is.
class RunnerPublicProfileFailure implements Exception {
  const RunnerPublicProfileFailure(this.message);

  final String message;

  @override
  String toString() => 'RunnerPublicProfileFailure($message)';
}
