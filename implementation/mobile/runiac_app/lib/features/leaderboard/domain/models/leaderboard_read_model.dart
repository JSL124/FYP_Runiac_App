/// Backend-produced leaderboard display contract.
///
/// Rank, score, XP, monthly XP, level, division, and region values are
/// read-only backend outputs for the Flutter client.
enum LeaderboardReadStatus {
  data,
  empty,
  unranked,
  regionRequired,
  ineligiblePremium,
  ineligibleMinRuns,
  updating,
}

class LeaderboardReadModel {
  LeaderboardReadModel({
    this.status = LeaderboardReadStatus.data,
    this.regionId = '',
    this.homeRegionId = '',
    required this.regionLabel,
    this.divisionKey = 'tier_01',
    this.divisionLabel = 'Iron League',
    this.isHomeRegion = true,
    required this.currentRunnerRankLabel,
    required List<LeaderboardRowReadModel> entries,
    List<LeaderboardRowReadModel> nearbyEntries =
        const <LeaderboardRowReadModel>[],
    this.periodEndsAt,
    this.periodLabel,
    this.refreshLabel,
    this.snapshotId = '',
  }) : entries = List.unmodifiable(entries),
       nearbyEntries = List.unmodifiable(nearbyEntries);

  final LeaderboardReadStatus status;
  final String regionId;
  final String homeRegionId;
  final String regionLabel;
  final String divisionKey;
  final String divisionLabel;
  final bool isHomeRegion;
  final String currentRunnerRankLabel;
  final List<LeaderboardRowReadModel> entries;
  final List<LeaderboardRowReadModel> nearbyEntries;
  final DateTime? periodEndsAt;
  final String? periodLabel;
  final String? refreshLabel;

  /// Backend-owned id of the snapshot these entries were read from. It is the
  /// only handle a viewer has for another runner on this board: the entries
  /// themselves carry no uid, so `getRunnerPublicProfile` resolves the owner
  /// server-side from (`snapshotId`, `rankLabel`). Empty for static/demo
  /// sources.
  final String snapshotId;
}

/// Backend-produced leaderboard row display contract.
class LeaderboardRowReadModel {
  const LeaderboardRowReadModel({
    required this.userId,
    required this.displayName,
    required this.rankLabel,
    required this.scoreLabel,
    this.levelLabel = '',
    this.divisionLabel = '',
    this.regionLabel = '',
    this.isCurrentUser = false,
  });

  final String userId;
  final String displayName;
  final String rankLabel;
  final String scoreLabel;
  final String levelLabel;
  final String divisionLabel;
  final String regionLabel;
  final bool isCurrentUser;
}
