import 'challenge_enums.dart';
import 'challenge_parse.dart';

/// A privacy-safe participant row for lobby and progress surfaces.
///
/// Identity is limited to the backend-authored `displayNameSnapshot` and
/// `avatarInitialsSnapshot`; the raw uid is retained only to resolve
/// [isCurrentUser] and to order the roster (You first). No routes, coordinates,
/// run timestamps, or activity history are ever exposed here. `creditedMeters`
/// is the backend-owned value read back verbatim.
class ChallengeParticipantRow {
  const ChallengeParticipantRow({
    required this.uid,
    required this.displayNameSnapshot,
    required this.avatarInitialsSnapshot,
    required this.levelLabelSnapshot,
    required this.role,
    required this.status,
    required this.creditedMeters,
    required this.reward,
    required this.isCurrentUser,
    this.avatarUrlSnapshot = '',
    this.levelProgressPercentSnapshot = 0,
  });

  /// Backend uid. Not for display — used only for self-detection and ordering.
  final String uid;
  final String displayNameSnapshot;
  final String avatarInitialsSnapshot;

  /// Raw, not-yet-sanitised avatar photo URL resolved live from the
  /// participant's profile, exactly like [levelLabelSnapshot]. Empty is the
  /// common case (no photo set), so unlike the other snapshot fields this is
  /// never parsed through [ChallengeParse.string]/[ChallengeParse.optionalString]
  /// (both reject an empty string) — see [fromMap].
  final String avatarUrlSnapshot;

  /// Backend-owned level label (e.g. `Lv.2`) read back verbatim for display.
  /// May be empty when the backend cannot resolve a level; callers fall back
  /// to the display-only `Lv.0` placeholder.
  final String levelLabelSnapshot;

  /// Backend-owned progress toward the next level, 0..100, resolved live from
  /// the participant's profile alongside [levelLabelSnapshot]. Surfaces divide
  /// it by 100 to paint the XP ring around the roster avatar. Read back
  /// verbatim; never computed on the client. `0` — an empty ring — is the
  /// normal case for a profile with no progress on record, so like
  /// [avatarUrlSnapshot] this is parsed leniently rather than strictly.
  final int levelProgressPercentSnapshot;
  final ChallengeParticipantRole role;
  final ChallengeParticipantStatus status;
  final int creditedMeters;
  final ChallengeRewardStatus reward;
  final bool isCurrentUser;

  bool get hasLeft => status == ChallengeParticipantStatus.left;

  static ChallengeParticipantRow fromMap(
    Map<String, Object?> map, {
    required String? currentUid,
  }) {
    final uid = ChallengeParse.string(map, 'uid');
    return ChallengeParticipantRow(
      uid: uid,
      displayNameSnapshot: ChallengeParse.string(map, 'displayNameSnapshot'),
      avatarInitialsSnapshot:
          ChallengeParse.string(map, 'avatarInitialsSnapshot'),
      levelLabelSnapshot: ChallengeParse.string(map, 'levelLabelSnapshot'),
      role: ChallengeParticipantRole.parse(ChallengeParse.string(map, 'role')),
      status:
          ChallengeParticipantStatus.parse(ChallengeParse.string(map, 'status')),
      creditedMeters: ChallengeParse.integer(map, 'creditedMeters'),
      reward: ChallengeRewardStatus.parse(ChallengeParse.string(map, 'reward')),
      isCurrentUser: currentUid != null && currentUid == uid,
      avatarUrlSnapshot: _avatarUrlSnapshot(map),
      levelProgressPercentSnapshot: _levelProgressPercentSnapshot(map),
    );
  }

  /// Lenient read of `avatarUrlSnapshot`: unlike every other field here, an
  /// empty string is the NORMAL case (no photo set), not a malformed
  /// response, so this never throws — a missing or non-string value simply
  /// resolves to `''`, the same as an explicitly empty one.
  static String _avatarUrlSnapshot(Map<String, Object?> map) {
    final value = map['avatarUrlSnapshot'];
    return value is String ? value : '';
  }

  /// Lenient read of `levelProgressPercentSnapshot`, for the same reason as
  /// [_avatarUrlSnapshot]: a participant whose profile carries no progress is
  /// normal, not a malformed response, and so is a response from a backend
  /// revision predating this field. Both resolve to `0` (an empty ring) rather
  /// than throwing. Clamped to 0..100 so a corrupt stored value cannot
  /// overdraw the ring.
  static int _levelProgressPercentSnapshot(Map<String, Object?> map) {
    final value = map['levelProgressPercentSnapshot'];
    if (value is! num || !value.isFinite) {
      return 0;
    }
    return value.round().clamp(0, 100);
  }
}
