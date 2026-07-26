import '../models/runner_public_profile_read_model.dart';

/// How a viewer addresses the runner whose public profile they are opening.
///
/// A leaderboard row carries no uid — the backend snapshot deliberately omits
/// it so the board cannot be read as a uid directory — so a viewer names the
/// runner by the entry they tapped, and the backend resolves the owner.
class RunnerPublicProfileQuery {
  /// A uid the viewer already legitimately holds (their own, or one a future
  /// friends/feed surface supplies).
  const RunnerPublicProfileQuery.uid(this.uid)
    : snapshotId = '',
      rankLabel = '';

  /// One entry of a backend-owned leaderboard snapshot.
  const RunnerPublicProfileQuery.leaderboardEntry({
    required this.snapshotId,
    required this.rankLabel,
  }) : uid = '';

  final String uid;
  final String snapshotId;
  final String rankLabel;

  /// False when neither form is addressable, which is the case for demo and
  /// preview rows that have no backing runner at all.
  bool get isResolvable =>
      uid.isNotEmpty || (snapshotId.isNotEmpty && rankLabel.isNotEmpty);

  /// The callable payload. Exactly one form is sent; the backend rejects any
  /// mixed or partial shape.
  Map<String, Object?> toPayload() {
    if (uid.isNotEmpty) {
      return <String, Object?>{'uid': uid};
    }
    return <String, Object?>{'snapshotId': snapshotId, 'rankLabel': rankLabel};
  }
}

/// Read-only seam for another runner's public profile projection.
abstract interface class RunnerPublicProfileRepository {
  /// Loads the public running-achievement projection for [query], or `null`
  /// when this build has no backend source wired (previews and tests).
  ///
  /// Throws [RunnerPublicProfileFailure] when a source is wired but the
  /// profile cannot be served.
  Future<RunnerPublicProfileReadModel?> loadRunnerPublicProfile({
    required RunnerPublicProfileQuery query,
  });
}

/// No-backend source used by previews, widget tests, and the static build.
/// Returns `null` so the caller keeps whatever it already knows about the
/// runner instead of showing an error for a missing backend.
class UnavailableRunnerPublicProfileRepository
    implements RunnerPublicProfileRepository {
  const UnavailableRunnerPublicProfileRepository();

  @override
  Future<RunnerPublicProfileReadModel?> loadRunnerPublicProfile({
    required RunnerPublicProfileQuery query,
  }) async {
    return null;
  }
}
