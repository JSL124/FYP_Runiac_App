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
  /// server-side from (`snapshotId`, `rankLabel`, `buildId`). Empty for
  /// static/demo sources. The build id lives on each row, not here: top and
  /// nearby rows come from different documents that a refresh rewrites in
  /// separate batches, so one board-level build id would mislabel whichever
  /// half was read first.
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
    this.buildId = '',
  });

  final String userId;
  final String displayName;
  final String rankLabel;
  final String scoreLabel;
  final String levelLabel;
  final String divisionLabel;
  final String regionLabel;
  final bool isCurrentUser;

  /// Backend-owned id of the aggregation run that produced the document this
  /// row was read from — the snapshot for a top row, the rank projection for a
  /// nearby row. Paired with `rankLabel` it pins a public-profile lookup to
  /// the exact board build the runner saw, so a row read across a refresh
  /// resolves to nobody instead of to whoever inherited its rank.
  final String buildId;
}
