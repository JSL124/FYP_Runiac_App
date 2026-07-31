#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-diff-hygiene"
scanned_paths="git status --short,git diff --check,git diff --cached --check,git diff --name-status"
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

is_complete_run_functions_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/complete-run-cloud-functions-emulator-skeleton\.md`' implementation/roadmap/CURRENT.md
}

is_running_activity_history_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/running-activity-history-user-link\.md`' implementation/roadmap/CURRENT.md
}

is_run_duration_fields_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/run-duration-fields\.md`' implementation/roadmap/CURRENT.md
}

is_cadence_capture_reliability_capsule_active() {
  grep -Eq '^- Current active capsule: `implementation/roadmap/capsules/cadence-capture-reliability-recovery\.md`' implementation/roadmap/CURRENT.md
}

is_cadence_capture_reliability_functions_path() {
  case "$1" in
    functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/test/completeRun.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_adaptive_character_guidance_capsule_active() {
  grep -Eq '^- Current active capsule( in this isolated worktree)?: `implementation/roadmap/capsules/adaptive-character-guidance\.md`' implementation/roadmap/CURRENT.md
}

is_feed_friends_emulator_backend_capsule_active() {
  grep -Eq '^- Current active capsule in this isolated worktree: `implementation/roadmap/capsules/feed-friends-emulator-backend\.md`\.' implementation/roadmap/CURRENT.md
}

is_challenge_distance_system_capsule_active() {
  grep -Eq '^- Newly routed Challenge distance system on 2026-07-13 Asia/Singapore: `implementation/roadmap/capsules/challenge-distance-system\.md`' implementation/roadmap/CURRENT.md
}

is_friends_backend_mvp_capsule_active() {
  grep -Eq '^- Newly routed backed Friends MVP on 2026-07-13 Asia/Singapore: `implementation/roadmap/capsules/friends-backend-mvp\.md`' implementation/roadmap/CURRENT.md
}

is_friends_backend_mvp_path() {
  case "$1" in
    implementation/roadmap/capsules/friends-backend-mvp.md|\
    firestore.rules|\
    firestore.indexes.json|\
    functions/src/friends/*|\
    functions/test/friendsCore.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    tests/firebase-rules/firestore.rules.test.mjs|\
    tests/firebase-rules/friends.firestore.rules.test.mjs|\
    tests/firebase-rules/feed.firestore.rules.test.mjs|\
    tests/firebase-rules/support/firestore_rules_test_support.mjs)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_challenge_distance_system_path() {
  case "$1" in
    implementation/roadmap/capsules/challenge-distance-system.md|\
    implementation/roadmap/snapshots/latest.md|\
    functions/src/challenge/*|\
    functions/test/challenge*.ts|\
    functions/src/notifications/*|\
    functions/src/index.ts|\
    functions/package.json|\
    functions/src/run/completeRun.ts|\
    functions/test/completeRun.test.ts|\
    tests/firebase-rules/challenge.firestore.rules.test.mjs)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_cool_down_stretch_xp_bonus_capsule_active() {
  grep -Eq '^- Newly routed cool-down stretch completion XP bonus on 2026-07-14 Asia/Singapore: `implementation/roadmap/capsules/cool-down-stretch-completion-xp-bonus\.md`' implementation/roadmap/CURRENT.md
}

is_cool_down_stretch_xp_bonus_path() {
  case "$1" in
    implementation/roadmap/capsules/cool-down-stretch-completion-xp-bonus.md|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/run/validateCoolDownPayload.ts|\
    functions/src/run/runCompletionTypes.ts|\
    functions/src/run/runCompletionArtifacts.ts|\
    functions/src/progression/progressionCalculator.ts|\
    functions/src/progression/progressionAudit.ts|\
    functions/src/progression/progressionDisplayReader.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    functions/test/completeCoolDown.test.ts|\
    functions/test/progressionCalculator.test.ts|\
    tests/firebase-rules/firestore.rules.test.mjs|\
    firestore.rules)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_plan_completion_signal_capsule_active() {
  grep -Eq '^- Newly routed plan completion signal on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/plan-completion-signal\.md`' implementation/roadmap/CURRENT.md
}

is_plan_completion_signal_path() {
  case "$1" in
    implementation/roadmap/capsules/plan-completion-signal.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    tools/governance-ci/check-pre-scaffold-scope.sh|\
    functions/src/plan/planProgress.ts|\
    functions/test/planProgressCompletion.test.ts|\
    functions/test/feedCallableSurface.test.ts|\
    functions/package.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_admin_console_leaderboard_oversight_capsule_active() {
  grep -Eq '^- Newly routed admin console Leaderboard Oversight alignment on 2026-07-20 Asia/Singapore: `implementation/roadmap/capsules/admin-console-leaderboard-oversight\.md`' implementation/roadmap/CURRENT.md
}

is_admin_console_leaderboard_oversight_path() {
  case "$1" in
    implementation/roadmap/capsules/admin-console-leaderboard-oversight.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    functions/src/leaderboard/leaderboardTypes.ts|\
    functions/src/leaderboard/monthlyLeaderboard.ts|\
    functions/src/leaderboard/monthlyLeaderboardPlanner.ts|\
    functions/src/leaderboard/monthlyLeaderboardWriter.ts|\
    functions/src/leaderboard/leaderboardAdminCommand.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    functions/test/monthlyLeaderboard.test.ts|\
    functions/test/monthlyLeaderboardWriter.test.ts|\
    functions/test/leaderboardAdminCommand.test.ts|\
    tests/firebase-rules/firestore.rules.test.mjs|\
    firestore.rules|\
    implementation/mobile/runiac_app/lib/features/leaderboard/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_progression_followups_capsule_active() {
  grep -Eq '^- Newly routed progression follow-ups on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/progression-followups\.md`' implementation/roadmap/CURRENT.md
}

is_progression_followups_path() {
  case "$1" in
    implementation/roadmap/capsules/progression-followups.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    functions/src/config/configLoader.ts|\
    functions/src/progression/progressionAudit.ts|\
    functions/src/progression/progressionAuditHelpers.ts|\
    functions/src/leaderboard/monthlyLeaderboard.ts|\
    functions/test/configLoader.test.ts|\
    functions/test/progressionCalculator.test.ts|\
    functions/test/completeRun.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_live_author_level_capsule_active() {
  grep -Eq '^- Newly routed feed live author level on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/feed-live-author-level\.md`' implementation/roadmap/CURRENT.md
}

is_friends_live_level_capsule_active() {
  grep -Eq '^- Newly routed friends live level on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/friends-live-level\.md`' implementation/roadmap/CURRENT.md
}

is_friends_live_level_path() {
  case "$1" in
    implementation/roadmap/capsules/friends-live-level.md|\
    functions/src/progression/profileLevelDisplay.ts|\
    functions/src/friends/friendLevels/core.ts|\
    functions/src/friends/friendLevels/callable.ts|\
    functions/src/friends/friendsDiscovery.ts|\
    functions/test/friendLevels.test.ts|\
    functions/test/friendsCore.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_level_progress_ring_capsule_active() {
  grep -Eq '^- Newly routed level progress ring live fan-out on 2026-07-29 Asia/Singapore: `implementation/roadmap/capsules/level-progress-ring-live-fan-out\.md`' implementation/roadmap/CURRENT.md
}

# Exact paths touched by the level-progress-ring capsule. Deliberately an
# explicit file list, not a directory glob for functions/src/leaderboard/* or
# functions/src/challenge/*: those directories are shared with other capsules'
# negative-space regression probes (see
# tests/governance/backend_functions_scope_test.sh), and this capsule's routing
# bullet is append-only/permanent, so a broad glob would permanently defeat
# those probes. `functions/src/friends/friendsDiscovery.ts` and
# `functions/test/friendsCore.test.ts` are already allowlisted by
# is_friends_live_level_path and are not repeated here.
is_level_progress_ring_path() {
  case "$1" in
    implementation/roadmap/capsules/level-progress-ring-live-fan-out.md|\
    functions/src/leaderboard/leaderboardTypes.ts|\
    functions/src/leaderboard/monthlyLeaderboardPlanner.ts|\
    functions/src/leaderboard/monthlyLeaderboardWriter.ts|\
    functions/src/leaderboard/leaderboardSeedVerification.ts|\
    functions/src/challenge/challengeLobbyCore.ts|\
    functions/src/challenge/challengeLobbySupport.ts|\
    functions/src/friends/friendsTypes.ts|\
    functions/src/friends/friendsCore.ts|\
    functions/src/friends/callable.ts|\
    functions/test/monthlyLeaderboard.test.ts|\
    functions/test/monthlyLeaderboardWriter.test.ts|\
    functions/test/challengeLobby.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_admin_automation_policy_capsule_active() {
  grep -Eq '^- Newly routed admin automation & policy control plane on 2026-07-22 Asia/Singapore: `implementation/roadmap/capsules/admin-automation-policy-control-plane\.md`' implementation/roadmap/CURRENT.md
}

is_admin_automation_policy_path() {
  case "$1" in
    implementation/roadmap/capsules/admin-automation-policy-control-plane.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    tools/governance-ci/check-pre-scaffold-scope.sh|\
    functions/src/config/configLoader.ts|\
    functions/src/config/automationGate.ts|\
    functions/src/moderation/reportAutomation.ts|\
    functions/src/moderation/staleReportSweep.ts|\
    functions/src/errors/errorGroupNotifications.ts|\
    functions/src/leaderboard/monthlyLeaderboard.ts|\
    functions/src/progression/subscriptionExpirySchedule.ts|\
    functions/src/notifications/scheduledPushDispatch.ts|\
    functions/src/index.ts|\
    firestore.rules|\
    functions/package.json|\
    functions/src/challenge/challengeErrors.ts|\
    functions/src/challenge/challengeLobbyCore.ts|\
    functions/src/challenge/callable.ts|\
    functions/test/configLoader.test.ts|\
    functions/test/automationGate.test.ts|\
    functions/test/reportAutomation.test.ts|\
    functions/test/staleReportSweep.test.ts|\
    functions/test/errorGroupNotifications.test.ts|\
    functions/test/challengeLobby.test.ts|\
    tests/firebase-rules/firestore.rules.test.mjs)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_character_premium_access_gating_capsule_active() {
  grep -Eq '^- Newly routed character premium-access gating on 2026-07-24 Asia/Singapore: `implementation/roadmap/capsules/character-premium-access-gating\.md`' implementation/roadmap/CURRENT.md
}

is_character_premium_access_gating_path() {
  case "$1" in
    implementation/roadmap/capsules/character-premium-access-gating.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    functions/src/config/configLoader.ts|\
    functions/test/configLoader.test.ts|\
    firestore.rules|\
    tests/firebase-rules/firestore.config.rules.test.mjs|\
    implementation/mobile/runiac_app/lib/app.dart|\
    implementation/mobile/runiac_app/lib/main.dart|\
    implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart|\
    implementation/mobile/runiac_app/lib/features/onboarding/presentation/character_selection_screen.dart|\
    implementation/mobile/runiac_app/lib/features/paywall/domain/models/character_access_read_model.dart|\
    implementation/mobile/runiac_app/lib/features/paywall/domain/repositories/character_access_repository.dart|\
    implementation/mobile/runiac_app/lib/features/paywall/data/firestore_character_access_repository.dart|\
    implementation/mobile/runiac_app/lib/features/paywall/presentation/current_session_character_access.dart|\
    implementation/mobile/runiac_app/test/character_selection_test.dart|\
    implementation/mobile/runiac_app/test/character_access_read_model_test.dart|\
    implementation/mobile/runiac_app/test/backend_owned_contract_test.dart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_test_suite_regression_hardening_capsule_active() {
  grep -Eq '^- Newly routed test-suite regression hardening on 2026-07-24 Asia/Singapore: `implementation/roadmap/capsules/test-suite-regression-hardening\.md`' implementation/roadmap/CURRENT.md
}

# Test-only QA capsule: regression tests plus two npm-script lines chaining
# the challenge/friends suites into the default `npm test`. Note the feed
# test basenames must be claimed here before the feed-friends-emulator-backend
# basename patterns claim them.
is_test_suite_regression_hardening_path() {
  case "$1" in
    implementation/roadmap/capsules/test-suite-regression-hardening.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    functions/package.json|\
    functions/test/completeCoolDown.test.ts|\
    functions/test/completeRun.test.ts|\
    functions/test/feedContracts.test.ts|\
    functions/test/homeGuideAgentCallableSurface.test.ts|\
    functions/test/monthlyLeaderboardWriter.test.ts|\
    functions/test/progressionAuditHelpers.test.ts|\
    functions/test/reportAutomation.test.ts|\
    tests/firebase-rules/feed.firestore.rules.test.mjs|\
    tests/firebase-rules/firestore.routes-enrollment.rules.test.mjs|\
    tests/firebase-rules/firestore.rules.test.mjs|\
    implementation/mobile/runiac_app/test/app_settings_repository_test.dart|\
    implementation/mobile/runiac_app/test/home_stage_map_model_test.dart|\
    implementation/mobile/runiac_app/test/run_tracking_controller_test.dart|\
    implementation/mobile/runiac_app/test/current_session_user_account_owner_switch_test.dart|\
    implementation/mobile/runiac_app/test/generated_plan_you_display_adapter_weekday_test.dart|\
    implementation/mobile/runiac_app/test/run_summary_local_analysis_merger_test.dart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_live_author_level_path() {
  case "$1" in
    implementation/roadmap/capsules/feed-live-author-level.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    tools/governance-ci/check-pre-scaffold-scope.sh|\
    functions/src/index.ts|\
    functions/package.json|\
    functions/src/feed/authorLevels/core.ts|\
    functions/src/feed/authorLevels/callable.ts|\
    functions/test/feedAuthorLevels.test.ts|\
    functions/test/feedCallableSurface.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_exception_queue_moderation_capsule_active() {
  grep -Eq '^- Newly routed Exception Queue moderation adjudication on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/exception-queue-moderation-adjudication\.md`' implementation/roadmap/CURRENT.md
}

is_exception_queue_moderation_path() {
  case "$1" in
    implementation/roadmap/capsules/exception-queue-moderation-adjudication.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    firestore.rules|\
    functions/package.json|\
    functions/src/index.ts|\
    functions/src/moderation/moderationCommand.ts|\
    functions/src/security/accountStatus.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/challenge/challengeLobbyCore.ts|\
    functions/src/challenge/challengeSettlementCore.ts|\
    functions/src/feed/lifecycle/functions.ts|\
    functions/src/feed/publish/callable.ts|\
    functions/src/friends/friendsBlocks.ts|\
    functions/src/friends/friendsMigration.ts|\
    functions/src/friends/friendsNicknameService.ts|\
    functions/src/friends/friendsRequests.ts|\
    functions/src/friends/friendsResponses.ts|\
    functions/test/accountStatus.test.ts|\
    functions/test/moderationCommand.test.ts|\
    functions/test/challengeLobby.test.ts|\
    functions/test/challengeSettlement.test.ts|\
    functions/test/completeCoolDown.test.ts|\
    functions/test/completeRun.test.ts|\
    functions/test/feedCallableSurface.test.ts|\
    functions/test/feedEmulatorIntegration.test.ts|\
    functions/test/friendsCore.test.ts|\
    tests/firebase-rules/firestore.rules.test.mjs|\
    tests/firebase-rules/feed.firestore.rules.test.mjs|\
    implementation/mobile/runiac_app/lib/features/moderation/data/report_user_writer.dart|\
    implementation/mobile/runiac_app/lib/features/moderation/domain/models/report_user_reason.dart|\
    implementation/mobile/runiac_app/lib/features/moderation/presentation/widgets/report_user_sheet.dart|\
    implementation/mobile/runiac_app/lib/features/friends/presentation/friends_action_sheets.dart|\
    implementation/mobile/runiac_app/lib/features/friends/presentation/friends_screen.dart|\
    implementation/mobile/runiac_app/lib/features/friends/presentation/friends_screen_actions.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_read_model_display_adapter.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/models/leaderboard_display_models.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/runner_achievement_profile_screen.dart|\
    implementation/mobile/runiac_app/test/backend_owned_contract_test.dart|\
    implementation/mobile/runiac_app/test/report_user_sheet_test.dart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_unified_release_criteria_capsule_active() {
  grep -Eq '^- Newly routed unified release criteria on 2026-07-31 Asia/Singapore: `implementation/roadmap/capsules/unified-release-criteria\.md`' implementation/roadmap/CURRENT.md
}

# Documentation-only capsule creating implementation/release/. The directory is
# new and owned entirely by this capsule, so a glob is safe here — unlike the
# shared functions/ and Flutter trees, no other capsule's inactive-capsule
# rejection probe depends on paths under it. No deploy execution, no live
# inventory query, and no functions/ or Flutter source is in scope.
is_unified_release_criteria_path() {
  case "$1" in
    implementation/roadmap/capsules/unified-release-criteria.md|\
    implementation/roadmap/CURRENT.md|\
    implementation/release/*|\
    tools/governance-ci/check-diff-hygiene.sh|\
    tools/governance-ci/check-pre-scaffold-scope.sh)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_repository_consolidation_quality_gates_capsule_active() {
  grep -Eq '^- Newly routed repository consolidation quality gates on 2026-07-31 Asia/Singapore: `implementation/roadmap/capsules/repository-consolidation-quality-gates\.md`' implementation/roadmap/CURRENT.md
}

# Governance/CI-only capsule. It wires the already-present
# tests/cross-system/paywall-config-drift.mjs into run-all-checks.sh through a
# tests/governance wrapper (its two sibling drift guards are already wired in),
# and adds a check that reconciles the filename-enumerated test suite lists in
# functions/package.json and tests/firebase-rules/package.json against the test
# files actually on disk. Deliberately narrow: no functions/ or Flutter source,
# and no directory globs, so that other capsules' inactive-capsule rejection
# probes keep working once this capsule's append-only routing bullet goes stale.
is_repository_consolidation_quality_gates_path() {
  case "$1" in
    implementation/roadmap/capsules/repository-consolidation-quality-gates.md|\
    implementation/roadmap/CURRENT.md|\
    tests/governance/paywall_config_drift_test.sh|\
    tools/governance-ci/check-test-enumeration.sh|\
    tools/governance-ci/run-all-checks.sh|\
    tools/governance-ci/check-diff-hygiene.sh|\
    tools/governance-ci/check-pre-scaffold-scope.sh)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_premium_parity_progression_capsule_active() {
  grep -Eq '^- Newly routed premium parity progression on 2026-07-20 Asia/Singapore: `implementation/roadmap/capsules/premium-parity-progression\.md`' implementation/roadmap/CURRENT.md
}

is_premium_parity_progression_path() {
  case "$1" in
    implementation/roadmap/capsules/premium-parity-progression.md|\
    implementation/roadmap/CURRENT.md|\
    tools/governance-ci/check-diff-hygiene.sh|\
    tools/governance-ci/run-all-checks.sh|\
    tests/cross-system/config-contract-drift.mjs|\
    tests/governance/config_contract_drift_test.sh|\
    functions/src/config/configLoader.ts|\
    functions/src/progression/progressionAudit.ts|\
    functions/src/progression/progressionAuditHelpers.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/leaderboard/monthlyLeaderboardPlanner.ts|\
    functions/src/leaderboard/monthlyLeaderboardOwnerFacts.ts|\
    functions/src/leaderboard/leaderboardMockDataset.ts|\
    functions/src/leaderboard/leaderboardSeedDataset.ts|\
    functions/src/leaderboard/leaderboardSeedOwnership.ts|\
    functions/src/leaderboard/leaderboardSeedVerification.ts|\
    functions/src/leaderboard/leaderboardSeedCleanupAuthorization.ts|\
    functions/test/completeRun.test.ts|\
    functions/test/completeCoolDown.test.ts|\
    functions/test/monthlyLeaderboard.test.ts|\
    functions/test/monthlyLeaderboardWriter.test.ts|\
    functions/test/progressionCalculator.test.ts|\
    functions/test/leaderboardMockDataset.test.ts|\
    functions/test/seedLeaderboardCleanup.test.ts|\
    functions/test/seedLeaderboardMockData.test.ts|\
    docs/pdd/AGENTS.md|\
    docs/pdd/AGENT_ROLES.md|\
    docs/pdd/wireframes/AGENTS.md|\
    docs/pdd/01-application-architecture.md|\
    docs/pdd/03-component-diagram.md|\
    docs/pdd/RUNIAC_PDD_ASSEMBLED_DRAFT.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_friends_emulator_backend_rules_test_path() {
  local path="$1"
  local relative_path
  local basename

  case "$path" in
    tests/firebase-rules/*) relative_path="${path#tests/firebase-rules/}" ;;
    *) return 1 ;;
  esac
  case "$relative_path" in
    */*) return 1 ;;
  esac

  basename="${relative_path##*/}"
  case "$basename" in
    *feed*.mjs) return 0 ;;
    *) return 1 ;;
  esac
}

is_feed_friends_emulator_backend_functions_test_path() {
  local path="$1"
  local relative_path
  local basename

  case "$path" in
    functions/test/*) relative_path="${path#functions/test/}" ;;
    *) return 1 ;;
  esac
  case "$relative_path" in
    */*) return 1 ;;
  esac

  basename="${relative_path##*/}"
  case "$basename" in
    feed*.ts) return 0 ;;
    *) return 1 ;;
  esac
}

is_feed_friends_emulator_backend_path() {
  if is_feed_friends_emulator_backend_rules_test_path "$1" || is_feed_friends_emulator_backend_functions_test_path "$1"; then
    return 0
  fi

  # implementation/roadmap/CURRENT.md is intentionally not claimed here:
  # routing updates to CURRENT.md are governed by the general roadmap
  # allowlist below so routed non-feed capsules can append routing while
  # the Feed capsule is inactive in this worktree's CURRENT.md.
  case "$1" in
    implementation/roadmap/capsules/feed-friends-emulator-backend.md|\
    implementation/roadmap/snapshots/latest.md|\
    firebase.json|firestore.rules|firestore.indexes.json|storage.rules|\
    tests/firebase-rules/package.json|tests/firebase-rules/package-lock.json|\
    functions/src/feed/*|\
    functions/src/index.ts|functions/package.json|functions/package-lock.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac

}

is_adaptive_character_guidance_functions_path() {
  case "$1" in
    functions/package.json|\
    functions/src/index.ts|\
    functions/src/security/appCheck.ts|\
    functions/src/agent/activityFeedbackAgent.ts|\
    functions/src/agent/homeGuideConsent.ts|\
    functions/src/agent/homeGuideAgent.ts|\
    functions/src/agent/homeGuideAgentHandler.ts|\
    functions/src/agent/homeGuideContracts.ts|\
    functions/src/agent/homeGuideEvidence.ts|\
    functions/src/agent/homeGuideModel.ts|\
    functions/src/agent/homeGuideModelOutput.ts|\
    functions/src/agent/homeGuideQuotaCache.ts|\
    functions/src/agent/homeGuideQuotaFingerprint.ts|\
    functions/test/homeGuideAgentCallableSurface.test.ts|\
    functions/test/homeGuideConsent.test.ts|\
    functions/test/homeGuideAgentSurface.test.ts|\
    functions/test/homeGuideEvidence.test.ts|\
    functions/test/homeGuideEvidenceFixtures.ts|\
    functions/test/homeGuideGeneratedCopyPolicy.test.ts|\
    functions/test/homeGuideModel.test.ts|\
    functions/test/homeGuideModelFixtures.ts|\
    functions/test/homeGuideQuotaCache.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_running_activity_history_functions_path() {
  case "$1" in
    functions/package.json|functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateRunPayload.ts|functions/test/completeRun.test.ts|functions/test/completeRunZeroMetrics.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_run_duration_fields_functions_path() {
  case "$1" in
    functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/src/run/validateRunScalarFields.ts|functions/test/completeRun.test.ts|functions/test/completeRunCallableSurface.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_error_reporting_pipeline_capsule_active() {
  grep -Eq '^- Newly routed error reporting pipeline on 2026-07-21 Asia/Singapore: `implementation/roadmap/capsules/error-reporting-pipeline\.md`' implementation/roadmap/CURRENT.md
}

# Routed error reporting pipeline: the new errors module and the Flutter
# observability layer, plus the call sites the three trigger wrappers are
# applied to. The wrapper application is a one-line change per file and does
# not alter any success path, return value, or thrown HttpsError code.
is_error_reporting_pipeline_path() {
  case "$1" in
    implementation/roadmap/capsules/error-reporting-pipeline.md|\
    firestore.rules|\
    functions/package.json|\
    functions/src/index.ts|\
    functions/src/errors/errorGroupStore.ts|\
    functions/src/errors/reportAppError.ts|\
    functions/src/errors/reportBackendError.ts|\
    functions/src/errors/sanitize.ts|\
    functions/src/errors/withErrorReporting.ts|\
    functions/test/reportAppError.test.ts|\
    functions/test/backendErrorReporting.test.ts|\
    functions/src/config/configLoader.ts|\
    functions/src/agent/activityFeedbackAgent.ts|\
    functions/src/agent/homeGuideAgent.ts|\
    functions/src/agent/homeGuideConsent.ts|\
    functions/src/challenge/callable.ts|\
    functions/src/challenge/challengeSettlementSchedule.ts|\
    functions/src/feed/engagement/engagement.ts|\
    functions/src/feed/lifecycle/functions.ts|\
    functions/src/feed/publish/callable.ts|\
    functions/src/feed/thumbnail/callable.ts|\
    functions/src/feedback/submitFeedback.ts|\
    functions/src/friends/callable.ts|\
    functions/src/leaderboard/leaderboardAdminCommand.ts|\
    functions/src/leaderboard/monthlyLeaderboard.ts|\
    functions/src/notifications/deviceRegistry.ts|\
    functions/src/notifications/scheduledPushDispatch.ts|\
    functions/src/progression/subscriptionExpirySchedule.ts|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/run/completeRun.ts|\
    implementation/mobile/runiac_app/lib/app.dart|\
    implementation/mobile/runiac_app/lib/main.dart|\
    implementation/mobile/runiac_app/lib/core/observability/*.dart|\
    implementation/mobile/runiac_app/test/core/observability/*.dart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_admin_role_subscription_expiry_capsule_active() {
  grep -Eq '^- Newly routed admin role and subscription expiry on 2026-07-20 Asia/Singapore: `implementation/roadmap/capsules/admin-role-subscription-expiry\.md`' implementation/roadmap/CURRENT.md
}

is_profile_stats_visibility_capsule_active() {
  grep -Eq '^- Newly routed profile stats visibility on 2026-07-29 Asia/Singapore: `implementation/roadmap/capsules/profile-stats-visibility\.md`' implementation/roadmap/CURRENT.md
}

is_home_guide_plan_brief_capsule_active() {
  grep -Eq '^- Newly routed Home guide plan brief for Basic on 2026-07-29 Asia/Singapore: `implementation/roadmap/capsules/home-guide-plan-brief-basic-tier\.md`' implementation/roadmap/CURRENT.md
}

# Scoped to the shipped default tier of the OpenAI-backed Home guide feature
# key. No callable, handler, quota, or consent code is in scope: the server
# entitlement check already read `config/featureAccess`, so only the default
# the catalog ships with moved.
is_home_guide_plan_brief_path() {
  case "$1" in
    implementation/roadmap/capsules/home-guide-plan-brief-basic-tier.md|\
    functions/src/config/configLoader.ts|\
    functions/test/configLoader.test.ts|\
    functions/test/homeGuideAgentCallableSurface.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_workout_detail_briefing_agent_capsule_active() {
  grep -Eq '^- Newly routed workout detail briefing agent on 2026-07-29 Asia/Singapore: `implementation/roadmap/capsules/workout-detail-briefing-agent\.md`' implementation/roadmap/CURRENT.md
}

# Scoped to the new premium-gated `workoutBriefingAgent` callable that replaces
# the static Coach note card on the planned-workout detail screen. The Flutter
# side of this capsule needs no entry here because `is_forbidden_path` already
# falls through for `implementation/mobile/**`; only the backend surface, the
# feature-key catalog it registers into, and this capsule's own routing files
# are gated. `feedCallableSurface.test.ts` is listed because a new export must
# be added to its expected-export list or the suite fails by design.
is_workout_detail_briefing_agent_path() {
  case "$1" in
    implementation/roadmap/capsules/workout-detail-briefing-agent.md|\
    implementation/roadmap/snapshots/latest.md|\
    functions/package.json|\
    functions/src/index.ts|\
    functions/src/config/configLoader.ts|\
    functions/src/agent/workoutBriefingAgent.ts|\
    functions/src/agent/workoutBriefingAgentHandler.ts|\
    functions/src/agent/workoutBriefingContractFields.ts|\
    functions/src/agent/workoutBriefingContracts.ts|\
    functions/src/agent/workoutBriefingModel.ts|\
    functions/src/agent/workoutBriefingModelOutput.ts|\
    functions/src/agent/workoutBriefingQuota.ts|\
    functions/src/agent/workoutBriefingTypes.ts|\
    functions/test/workoutBriefingAgentCallableSurface.test.ts|\
    functions/test/workoutBriefingContracts.test.ts|\
    functions/test/workoutBriefingModel.test.ts|\
    functions/test/feedCallableSurface.test.ts|\
    functions/test/configLoader.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Scoped to the server-side enforcement of the owner's `publicStatsHidden`
# preference. `firestore.rules` is listed only for the writable-key entry that
# lets the owner store the preference; the projection gate itself lives in
# `core.ts`, which is what actually withholds the hidden values.
is_profile_stats_visibility_path() {
  case "$1" in
    implementation/roadmap/capsules/profile-stats-visibility.md|\
    functions/src/profile/publicProfile/core.ts|\
    functions/src/profile/publicProfile/callable.ts|\
    functions/test/runnerPublicProfile.test.ts|\
    functions/test/runnerPublicProfileEmulatorIntegration.test.ts|\
    firestore.rules)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_first_run_app_tour_capsule_active() {
  grep -Eq '^- Newly routed first-run app tour on 2026-07-29 Asia/Singapore: `implementation/roadmap/capsules/first-run-app-tour\.md`' implementation/roadmap/CURRENT.md
}

# Client-only capsule: its only allowlisted path is its own capsule markdown.
# implementation/mobile/runiac_app/* is already unconditionally allowed below
# and is deliberately not repeated here.
is_first_run_app_tour_path() {
  case "$1" in
    implementation/roadmap/capsules/first-run-app-tour.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Scoped to the canonical Platform Administrator role predicate and the premium
# expiry sweep. The progression/leaderboard/run entries are signature-only
# `nowMs` threading required by the expiry-aware premium check; they are
# behaviour-preserving and covered by the regression run recorded in the
# capsule's Validation section.
is_admin_role_subscription_expiry_path() {
  case "$1" in
    implementation/roadmap/capsules/admin-role-subscription-expiry.md|\
    functions/src/security/roles.ts|\
    functions/src/progression/subscriptionExpiryCore.ts|\
    functions/src/progression/subscriptionExpirySchedule.ts|\
    functions/src/progression/progressionAuditHelpers.ts|\
    functions/src/progression/progressionAudit.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/leaderboard/monthlyLeaderboardOwnerFacts.ts|\
    functions/src/leaderboard/monthlyLeaderboardWriter.ts|\
    functions/src/friends/friendsMigration.ts|\
    functions/test/roles.test.ts|\
    functions/test/progressionAuditHelpers.test.ts|\
    functions/test/subscriptionExpiry.test.ts|\
    functions/test/friendsCore.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    firestore.indexes.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_user_feedback_pipeline_capsule_active() {
  grep -Eq '^- Newly routed user feedback pipeline on 2026-07-19 Asia/Singapore: `implementation/roadmap/capsules/user-feedback-pipeline\.md`' implementation/roadmap/CURRENT.md
}

# Note: the rules test basename contains "feed", so this must be consulted
# before the feed-friends-emulator-backend basename patterns claim it.
is_user_feedback_pipeline_path() {
  case "$1" in
    implementation/roadmap/capsules/user-feedback-pipeline.md|\
    firestore.rules|\
    firestore.indexes.json|\
    functions/src/feedback/*|\
    functions/test/submitFeedback.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    tests/firebase-rules/feedback.firestore.rules.test.mjs|\
    tests/firebase-rules/package.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_website_newsletter_subscription_capsule_active() {
  grep -Eq '^- Newly routed website newsletter subscription on 2026-07-30 Asia/Singapore: `implementation/roadmap/capsules/website-newsletter-subscription\.md`' implementation/roadmap/CURRENT.md
}

# Backend paths touched by the routed website newsletter subscription capsule.
# The website half (hero form, status pages, /admin/newsletter console) lives
# in the separate git-ignored website/ repo and never appears here.
is_website_newsletter_subscription_path() {
  case "$1" in
    implementation/roadmap/capsules/website-newsletter-subscription.md|\
    firestore.rules|\
    firestore.indexes.json|\
    functions/src/newsletter/*|\
    functions/test/newsletter*.ts|\
    functions/test/feedCallableSurface.test.ts|\
    functions/src/index.ts|\
    functions/package.json|\
    tests/firebase-rules/newsletter.firestore.rules.test.mjs|\
    tests/firebase-rules/package.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_engagement_push_capsule_active() {
  grep -Eq '^- Newly routed feed engagement push delivery on 2026-07-31 Asia/Singapore: `implementation/roadmap/capsules/feed-engagement-push-delivery\.md`' implementation/roadmap/CURRENT.md
}

# Backend paths touched by the routed feed engagement push capsule: the new
# sender module and its suite, plus the emitter that calls it and the two
# already-routed files it reuses. Explicit file list rather than a
# `functions/src/feed/*` or `functions/src/notifications/*` glob, because both
# directories are shared with other capsules. `functions/package.json` is
# already unconditionally allowed below.
is_feed_engagement_push_path() {
  case "$1" in
    implementation/roadmap/capsules/feed-engagement-push-delivery.md|\
    functions/src/feed/engagement/engagementPush.ts|\
    functions/src/feed/engagement/engagementNotifications.ts|\
    functions/src/notifications/scheduledPushReaders.ts|\
    functions/test/feedEngagementPush.test.ts|\
    functions/test/feedEngagementNotifications.test.ts|\
    functions/src/notifications/deviceRegistry.ts|\
    functions/test/notificationDevices.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_engagement_notifications_capsule_active() {
  grep -Eq '^- Newly routed feed engagement notifications on 2026-07-30 Asia/Singapore: `implementation/roadmap/capsules/feed-engagement-notifications\.md`' implementation/roadmap/CURRENT.md
}

# Backend paths touched by the routed feed engagement notifications capsule: the
# new inbox emitter module and its suite, the two feed engagement triggers it
# hooks into, the notification kind registry, and the preference reader that
# gains the `socialActivityEnabled` sibling. Deliberately an explicit file list
# rather than a `functions/src/feed/*` or `functions/src/notifications/*` glob:
# both directories are shared with other capsules. `functions/package.json`,
# `firestore.rules`, `tests/firebase-rules/*`, `implementation/roadmap/CURRENT.md`,
# `implementation/roadmap/snapshots/latest.md`, and every
# `implementation/mobile/runiac_app/*` path this capsule touches are already
# unconditionally allowed below and are not repeated here.
is_feed_engagement_notifications_path() {
  case "$1" in
    implementation/roadmap/capsules/feed-engagement-notifications.md|\
    functions/src/feed/engagement/engagementNotifications.ts|\
    functions/src/feed/engagement/engagement.ts|\
    functions/src/notifications/types.ts|\
    functions/src/notifications/scheduledPushReaders.ts|\
    functions/test/feedEngagementNotifications.test.ts|\
    functions/test/feedEngagement.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_review_triage_notification_privacy_quota_capsule_active() {
  grep -Eq '^- Newly routed review-triage on 2026-07-30 Asia/Singapore: `implementation/roadmap/capsules/review-triage-notification-privacy-quota\.md`' implementation/roadmap/CURRENT.md
}

# Paths touched by the routed review-triage capsule: the scheduled push
# planner, the seed-cleanup refresh guard, the error-report redactor, the
# activity-feedback quota default, their tests, the two notification client
# services and their tests, and the rules-suite wiring that had never run the
# friends tests. The website half (apkUrl scheme allowlist) lives in the
# separate git-ignored website/ repo and never appears here.
is_review_triage_notification_privacy_quota_path() {
  case "$1" in
    implementation/roadmap/capsules/review-triage-notification-privacy-quota.md|\
    functions/src/notifications/dispatchPlanner.ts|\
    functions/src/leaderboard/leaderboardSeedMutation.ts|\
    functions/src/errors/sanitize.ts|\
    functions/src/agent/activityFeedbackQuota.ts|\
    functions/src/run/completedAtFreshness.ts|\
    functions/src/run/validateRunPayload.ts|\
    functions/src/run/validateCoolDownPayload.ts|\
    functions/src/run/completeRun.ts|\
    functions/src/run/completeCoolDown.ts|\
    functions/src/notifications/scheduledPushMessagingAdapter.ts|\
    functions/test/notificationScheduledDispatch.test.ts|\
    firebase.json|\
    functions/package.json|\
    functions/test/completedAtFreshness.test.ts|\
    functions/test/notificationDispatch.test.ts|\
    functions/test/reportAppError.test.ts|\
    functions/test/activityFeedbackAgentCallableSurface.test.ts|\
    implementation/mobile/runiac_app/lib/features/notifications/domain/services/notification_registration_service.dart|\
    implementation/mobile/runiac_app/lib/features/notifications/domain/services/plan_notification_delivery_materializer.dart|\
    implementation/mobile/runiac_app/test/notification_registration_service_test.dart|\
    implementation/mobile/runiac_app/test/plan_notification_delivery_materializer_test.dart|\
    implementation/mobile/runiac_app/test/support/fake_notification_services.dart|\
    tests/firebase-rules/package.json)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_feed_author_identity_profile_entry_capsule_active() {
  grep -Eq '^- Newly routed feed author identity overlay and runner profile entry points on 2026-07-27 Asia/Singapore: `implementation/roadmap/capsules/feed-author-identity-and-profile-entry\.md`' implementation/roadmap/CURRENT.md
}

# Backend paths touched by the routed feed author identity capsule. It widens
# the already-deployed getFeedAuthorLevels result with the author's current
# name and routes the runner public profile projection through the same new
# identity reader; it adds no new Function export and changes no authorization.
is_feed_author_identity_profile_entry_path() {
  case "$1" in
    implementation/roadmap/capsules/feed-author-identity-and-profile-entry.md|\
    functions/src/profile/profileIdentityDisplay.ts|\
    functions/src/profile/publicProfile/core.ts|\
    functions/src/feed/authorLevels/core.ts|\
    functions/src/feed/authorLevels/callable.ts|\
    functions/test/feedAuthorLevels.test.ts)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_notification_inbox_delivery_semantics_capsule_active() {
  grep -Eq '^- Newly routed notification inbox delivery semantics on 2026-07-27 Asia/Singapore: `implementation/roadmap/capsules/notification-inbox-delivery-semantics\.md`' implementation/roadmap/CURRENT.md
}

# Client and native paths touched by the routed notification inbox delivery
# capsule. It moves the local plan-notification inbox write from schedule time
# to delivery time, so it spans the notifications feature, the plan-notification
# method channel on both platforms, and the shell/bootstrap wiring. No Cloud
# Functions, rules, or index path belongs to this capsule.
is_notification_inbox_delivery_semantics_path() {
  case "$1" in
    implementation/roadmap/capsules/notification-inbox-delivery-semantics.md|\
    implementation/mobile/runiac_app/lib/features/notifications/*|\
    implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart|\
    implementation/mobile/runiac_app/lib/core/firebase/runiac_firebase_bootstrap.dart|\
    implementation/mobile/runiac_app/ios/Runner/AppDelegate.swift|\
    implementation/mobile/runiac_app/ios/Runner/RuniacPlanNotificationChannel.swift|\
    implementation/mobile/runiac_app/android/app/src/main/kotlin/com/runiac/runiac_app/MainActivity.kt|\
    implementation/mobile/runiac_app/android/app/src/main/kotlin/com/runiac/runiac_app/RuniacPlanNotificationScheduler.kt|\
    implementation/mobile/runiac_app/test/plan_notification_*|\
    implementation/mobile/runiac_app/test/notification_inbox_*|\
    implementation/mobile/runiac_app/test/home_notification_inbox_test.dart|\
    implementation/mobile/runiac_app/test/method_channel_plan_notification_scheduler_test.dart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# Exact paths touched by the routed 8-bit PNG encoding capsule: one new shared
# core helper, the four existing call sites that rasterize a ui.Image into PNG
# bytes the app uploads, and their tests. Client-only by construction — no
# functions/, rules, index, config, or dependency path is or may be listed here.
is_eight_bit_png_encoding_capsule_active() {
  grep -Eq '^- Newly routed 8-bit PNG encoding on 2026-07-28 Asia/Singapore: `implementation/roadmap/capsules/eight-bit-png-encoding\.md`' implementation/roadmap/CURRENT.md
}

is_eight_bit_png_encoding_path() {
  case "$1" in
    implementation/roadmap/capsules/eight-bit-png-encoding.md|\
    implementation/mobile/runiac_app/lib/core/imaging/eight_bit_png.dart|\
    implementation/mobile/runiac_app/lib/core/share/share_card_export_service.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/feed_publish/history_artifact_resolver.dart|\
    implementation/mobile/runiac_app/lib/features/you/presentation/widgets/activity_route_mapbox_snapshot_provider.dart|\
    implementation/mobile/runiac_app/lib/features/profile/data/avatar/avatar_image_encoder.dart|\
    implementation/mobile/runiac_app/test/eight_bit_png_test.dart|\
    implementation/mobile/runiac_app/test/avatar_image_encoder_test.dart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_profile_photo_avatar_capsule_active() {
  grep -Eq '^- Newly routed profile photo avatars on 2026-07-28 Asia/Singapore: `implementation/roadmap/capsules/profile-photo-avatar\.md`' implementation/roadmap/CURRENT.md
}

# Exact paths touched across the full multi-stage profile-photo-avatar plan
# of record, matching this capsule's own Exact Target Files list. Stage 1
# (this registration) is governance-only; later stages land the server
# avatar module, the leaderboard/friends/challenge/feed read fan-in, the
# Flutter avatar widgets and upload flow, and the admin-console takedown
# wiring this predicate pre-authorizes ahead of time. Deliberately NOT a
# directory glob for functions/src/challenge/*, functions/src/leaderboard/*,
# or functions/test/*: those directories are shared with other capsules'
# negative-space regression probes (see tests/governance/backend_functions_scope_test.sh),
# and this capsule's own routing bullet is append-only/permanent, so a broad
# glob here would permanently defeat those other capsules' inactive-capsule
# rejection tests.
is_profile_photo_avatar_path() {
  case "$1" in
    implementation/roadmap/capsules/profile-photo-avatar.md|\
    storage.rules|\
    firestore.rules|\
    firestore.indexes.json|\
    functions/src/index.ts|\
    functions/package.json|\
    functions/src/profile/avatar/*|\
    functions/src/feed/png.ts|\
    functions/src/profile/profileIdentityDisplay.ts|\
    functions/src/profile/publicProfile/core.ts|\
    functions/src/profile/publicProfile/callable.ts|\
    functions/src/friends/friendLevels/core.ts|\
    functions/src/friends/friendLevels/callable.ts|\
    functions/src/feed/authorLevels/core.ts|\
    functions/src/feed/authorLevels/callable.ts|\
    functions/src/challenge/challengeLobbyCore.ts|\
    functions/src/challenge/challengeLobbySupport.ts|\
    functions/src/challenge/callable.ts|\
    functions/src/leaderboard/leaderboardTypes.ts|\
    functions/src/leaderboard/monthlyLeaderboardPlanner.ts|\
    functions/src/leaderboard/monthlyLeaderboardWriter.ts|\
    functions/src/leaderboard/monthlyLeaderboard.ts|\
    functions/src/leaderboard/leaderboardAdminCommand.ts|\
    functions/test/avatarPng.test.ts|\
    functions/test/avatarPaths.test.ts|\
    functions/test/profileAvatar.test.ts|\
    functions/test/profileAvatarEmulatorIntegration.test.ts|\
    functions/test/helpers/avatarEmulatorHelpers.ts|\
    functions/test/runnerPublicProfileEmulatorIntegration.test.ts|\
    functions/test/feedCallableSurface.test.ts|\
    functions/test/runnerPublicProfile.test.ts|\
    functions/test/feedAuthorLevels.test.ts|\
    functions/test/friendLevels.test.ts|\
    functions/test/challengeLobby.test.ts|\
    functions/test/monthlyLeaderboard.test.ts|\
    functions/test/monthlyLeaderboardWriter.test.ts|\
    tests/cross-system/avatar-path-contract-drift.mjs|\
    tests/governance/avatar_path_contract_drift_test.sh|\
    tests/firebase-rules/avatar.storage.rules.test.mjs|\
    tests/firebase-rules/package.json|\
    website/src/lib/actions/admin.ts|\
    website/src/lib/firebase/storage.ts|\
    website/src/lib/firebase/firestore.ts|\
    website/src/lib/firebase/types.ts|\
    website/src/lib/avatarPaths.ts|\
    website/src/lib/admin/types.ts|\
    website/src/lib/admin/live-data.ts|\
    website/src/components/admin/UserManagement.tsx|\
    website/src/components/admin/UserOperationsPanel.tsx|\
    website/src/lib/firebase/__tests__/storage.avatar.test.ts|\
    website/src/lib/firebase/__tests__/firestore.avatar.test.ts|\
    website/src/lib/actions/__tests__/admin.avatar.test.ts|\
    website/src/app/admin/users/page.tsx|\
    implementation/mobile/runiac_app/lib/core/widgets/runiac_avatar_photo.dart|\
    implementation/mobile/runiac_app/lib/core/widgets/runiac_level_profile_badge.dart|\
    implementation/mobile/runiac_app/lib/features/challenge/presentation/widgets/challenge_widgets.dart|\
    implementation/mobile/runiac_app/test/runiac_level_profile_badge_test.dart|\
    implementation/mobile/runiac_app/test/runiac_avatar_photo_test.dart|\
    implementation/mobile/runiac_app/test/challenge_initials_avatar_test.dart|\
    implementation/mobile/runiac_app/pubspec.yaml|\
    implementation/mobile/runiac_app/pubspec.lock|\
    implementation/mobile/runiac_app/ios/Runner/Info.plist|\
    implementation/mobile/runiac_app/lib/features/profile/data/avatar/avatar_image_encoder.dart|\
    implementation/mobile/runiac_app/lib/features/profile/data/avatar/firebase_avatar_upload_gateway.dart|\
    implementation/mobile/runiac_app/lib/features/profile/presentation/widgets/avatar_action_sheet.dart|\
    implementation/mobile/runiac_app/lib/features/profile/presentation/account_edit_profile_screen.dart|\
    implementation/mobile/runiac_app/lib/features/profile/presentation/account_profile_screen.dart|\
    implementation/mobile/runiac_app/test/avatar_image_encoder_test.dart|\
    implementation/mobile/runiac_app/test/account_avatar_upload_test.dart|\
    implementation/mobile/runiac_app/test/haptics_error_moments_test.dart|\
    implementation/mobile/runiac_app/lib/features/challenge/data/firebase_challenge_repository.dart|\
    implementation/mobile/runiac_app/lib/features/challenge/domain/models/challenge_participant_row.dart|\
    implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_friend_picker_screen.dart|\
    implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_lobby_screen.dart|\
    implementation/mobile/runiac_app/lib/features/challenge/presentation/challenge_progress_screen.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/comments/feed_comment_page_loader.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_data_port.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_post_display_mapper.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_test_data_port.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/feed_timeline_page_loader.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_data_port.dart|\
    implementation/mobile/runiac_app/lib/features/feed/data/firebase_feed_repository/firebase_feed_post_mapper.dart|\
    implementation/mobile/runiac_app/lib/features/feed/domain/models/feed_display_models.dart|\
    implementation/mobile/runiac_app/lib/features/feed/presentation/comments/feed_comment_list.dart|\
    implementation/mobile/runiac_app/lib/features/feed/presentation/comments/feed_comment_sheet_models.dart|\
    implementation/mobile/runiac_app/lib/features/feed/presentation/comments/feed_comment_sheet.dart|\
    implementation/mobile/runiac_app/lib/features/feed/presentation/current_session_feed_store.dart|\
    implementation/mobile/runiac_app/lib/features/feed/presentation/current_session_feed.dart|\
    implementation/mobile/runiac_app/lib/features/feed/presentation/widgets/feed_post_section.dart|\
    implementation/mobile/runiac_app/lib/features/friends/data/friend_level_resolver.dart|\
    implementation/mobile/runiac_app/lib/features/friends/domain/models/friends_read_model.dart|\
    implementation/mobile/runiac_app/lib/features/friends/presentation/widgets/friend_row_identity.dart|\
    implementation/mobile/runiac_app/lib/features/home/presentation/home_tab.dart|\
    implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map_header.dart|\
    implementation/mobile/runiac_app/lib/features/home/presentation/stage_map/home_stage_map.dart|\
    implementation/mobile/runiac_app/lib/features/home/presentation/widgets/home_header.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/data/firestore_leaderboard_repository.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/domain/models/leaderboard_read_model.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/leaderboard_read_model_display_adapter.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/models/leaderboard_display_models.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/leaderboard_rank_row_helpers.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/leaderboard_ranking_screen.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/leaderboard_region_preview_sheet.dart|\
    implementation/mobile/runiac_app/lib/features/leaderboard/presentation/widgets/runner_achievement_profile_screen.dart|\
    implementation/mobile/runiac_app/lib/features/profile/data/cloud_functions_runner_public_profile_repository.dart|\
    implementation/mobile/runiac_app/lib/features/profile/data/firestore_user_profile_repository.dart|\
    implementation/mobile/runiac_app/lib/features/profile/domain/models/runner_public_profile_read_model.dart|\
    implementation/mobile/runiac_app/lib/features/profile/domain/models/user_profile_read_model.dart|\
    implementation/mobile/runiac_app/lib/features/profile/presentation/data/account_profile_demo_snapshots.dart|\
    implementation/mobile/runiac_app/lib/features/profile/presentation/open_runner_profile.dart|\
    implementation/mobile/runiac_app/lib/features/profile/presentation/widgets/account_profile_identity.dart|\
    implementation/mobile/runiac_app/lib/features/profile/presentation/widgets/runner_profile_avatar_link.dart|\
    implementation/mobile/runiac_app/lib/features/run/presentation/widgets/share_route_feed_preview.dart|\
    implementation/mobile/runiac_app/lib/features/shell/runiac_shell.dart|\
    implementation/mobile/runiac_app/test/account_profile_read_flow_test.dart|\
    implementation/mobile/runiac_app/test/challenge_lobby_ui_test.dart|\
    implementation/mobile/runiac_app/test/challenge_progress_ui_test.dart|\
    implementation/mobile/runiac_app/test/challenge_realtime_test.dart|\
    implementation/mobile/runiac_app/test/feed_author_level_overlay_test.dart|\
    implementation/mobile/runiac_app/test/feed_author_level_resolver_test.dart|\
    implementation/mobile/runiac_app/test/feed_static_ui_test.dart|\
    implementation/mobile/runiac_app/test/firestore_leaderboard_repository_test.dart|\
    implementation/mobile/runiac_app/test/friends_static_ui_test.dart|\
    implementation/mobile/runiac_app/test/home_stage_map_widget_test.dart|\
    implementation/mobile/runiac_app/test/leaderboard_static_ui_test.dart|\
    implementation/mobile/runiac_app/test/runner_public_profile_screen_test.dart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_android_native_haptics_capsule_active() {
  grep -Eq '^- Newly routed Android native haptics on 2026-07-31 Asia/Singapore: `implementation/roadmap/capsules/android-native-haptics\.md`' implementation/roadmap/CURRENT.md
}

# Client-only capsule: its only allowlisted path is its own capsule markdown.
# implementation/mobile/runiac_app/* — including the Kotlin channel handler, the
# manifest permission, and the JVM unit test — is already unconditionally
# allowed below and is deliberately not repeated here.
is_android_native_haptics_path() {
  case "$1" in
    implementation/roadmap/capsules/android-native-haptics.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_allowed_path() {
  if is_android_native_haptics_path "$1" && is_android_native_haptics_capsule_active; then
    return 0
  fi

  if is_eight_bit_png_encoding_path "$1" && is_eight_bit_png_encoding_capsule_active; then
    return 0
  fi

  if is_profile_photo_avatar_path "$1" && is_profile_photo_avatar_capsule_active; then
    return 0
  fi

  if is_notification_inbox_delivery_semantics_path "$1" && is_notification_inbox_delivery_semantics_capsule_active; then
    return 0
  fi

  if is_error_reporting_pipeline_path "$1" && is_error_reporting_pipeline_capsule_active; then
    return 0
  fi

  if is_feed_author_identity_profile_entry_path "$1" && is_feed_author_identity_profile_entry_capsule_active; then
    return 0
  fi

  if is_user_feedback_pipeline_path "$1" && is_user_feedback_pipeline_capsule_active; then
    return 0
  fi

  if is_website_newsletter_subscription_path "$1" && is_website_newsletter_subscription_capsule_active; then
    return 0
  fi

  if is_feed_engagement_push_path "$1" && is_feed_engagement_push_capsule_active; then
    return 0
  fi

  if is_feed_engagement_notifications_path "$1" && is_feed_engagement_notifications_capsule_active; then
    return 0
  fi

  if is_review_triage_notification_privacy_quota_path "$1" && is_review_triage_notification_privacy_quota_capsule_active; then
    return 0
  fi

  if is_admin_role_subscription_expiry_path "$1" && is_admin_role_subscription_expiry_capsule_active; then
    return 0
  fi

  if is_profile_stats_visibility_path "$1" && is_profile_stats_visibility_capsule_active; then
    return 0
  fi

  if is_first_run_app_tour_path "$1" && is_first_run_app_tour_capsule_active; then
    return 0
  fi

  if is_home_guide_plan_brief_path "$1" && is_home_guide_plan_brief_capsule_active; then
    return 0
  fi

  if is_workout_detail_briefing_agent_path "$1" && is_workout_detail_briefing_agent_capsule_active; then
    return 0
  fi

  if is_share_rank_export_capsule_active && is_share_rank_export_backend_path "$1"; then
    return 0
  fi

  if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
    return 0
  fi

  if is_friends_backend_mvp_path "$1" && is_friends_backend_mvp_capsule_active; then
    return 0
  fi

  if is_challenge_distance_system_path "$1" && is_challenge_distance_system_capsule_active; then
    return 0
  fi

  if is_cool_down_stretch_xp_bonus_path "$1" && is_cool_down_stretch_xp_bonus_capsule_active; then
    return 0
  fi

  if is_plan_completion_signal_path "$1" && is_plan_completion_signal_capsule_active; then
    return 0
  fi

  if is_admin_console_leaderboard_oversight_path "$1" && is_admin_console_leaderboard_oversight_capsule_active; then
    return 0
  fi

  if is_premium_parity_progression_path "$1" && is_premium_parity_progression_capsule_active; then
    return 0
  fi

  if is_exception_queue_moderation_path "$1" && is_exception_queue_moderation_capsule_active; then
    return 0
  fi

  if is_progression_followups_path "$1" && is_progression_followups_capsule_active; then
    return 0
  fi

  if is_feed_live_author_level_path "$1" && is_feed_live_author_level_capsule_active; then
    return 0
  fi

  if is_friends_live_level_path "$1" && is_friends_live_level_capsule_active; then
    return 0
  fi

  if is_level_progress_ring_path "$1" && is_level_progress_ring_capsule_active; then
    return 0
  fi

  if is_admin_automation_policy_path "$1" && is_admin_automation_policy_capsule_active; then
    return 0
  fi

  if is_test_suite_regression_hardening_path "$1" && is_test_suite_regression_hardening_capsule_active; then
    return 0
  fi

  if is_repository_consolidation_quality_gates_path "$1" && is_repository_consolidation_quality_gates_capsule_active; then
    return 0
  fi

  if is_unified_release_criteria_path "$1" && is_unified_release_criteria_capsule_active; then
    return 0
  fi

  if is_character_premium_access_gating_path "$1" && is_character_premium_access_gating_capsule_active; then
    return 0
  fi

  if is_feed_friends_emulator_backend_path "$1"; then
    if is_feed_friends_emulator_backend_capsule_active; then
      return 0
    fi
    return 1
  fi

  case "$1" in
    implementation/roadmap/capsules/run-completion-authoritative-result-recovery.md)
      return 0
      ;;
    implementation/roadmap/capsules/cadence-capture-reliability-recovery.md)
      if is_cadence_capture_reliability_capsule_active; then
        return 0
      fi
      return 1
      ;;
    # Approved: non-operational historical archive (Phase A)
    docs/meta/.aiignore|docs/meta/README.md|docs/meta/RETROSPECTIVE_POLICY.md|docs/meta/RUNIAC_REPOSITORY_EVOLUTION_REPORT.md|tools/governance-ci/check-historical-isolation.sh)
      return 0
      ;;
    implementation/roadmap/capsules/friends-row-add-pending-icons.md)
      return 0
      ;;
    # Approved: routed legal documents and in-app legal link capsule
    implementation/roadmap/capsules/legal-documents-and-links.md)
      return 0
      ;;
    # Approved: routed profile lifetime-stats backend deploy capsule
    implementation/roadmap/capsules/profile-lifetime-stats-backend.md)
      return 0
      ;;
    # Approved: routed Share-my-rank card + Share-rank export-targets capsules,
    # and the routed Share-activity-card real-data export capsule
    implementation/roadmap/capsules/share-my-rank-transparent-card-league-badge.md|\
    implementation/roadmap/capsules/share-rank-card-export-targets.md|\
    implementation/roadmap/capsules/share-activity-card-real-data-export.md|\
    tests/firebase-rules/share-card.storage.rules.test.mjs)
      return 0
      ;;
    # Approved: routed capsule documentation/governance patches only
    docs/meta/REPOSITORY_WORKFLOW_RECORD.md|implementation/roadmap/capsules/repository-workflow-record.md|implementation/roadmap/capsules/flutter-app-shell-baseline.md|implementation/roadmap/capsules/android-ui-smoke-test-evidence.md|implementation/roadmap/capsules/home-dashboard-visual-polish.md|implementation/roadmap/capsules/premium-home-dashboard-static-wireframe-alignment.md|implementation/roadmap/capsules/github-actions-governance-ci-baseline.md|implementation/roadmap/capsules/github-actions-flutter-validation-baseline.md|implementation/roadmap/capsules/home-dashboard-scroll-layout-stability-fix.md|implementation/roadmap/capsules/home-dashboard-reference-layout-alignment.md|implementation/roadmap/capsules/home-dashboard-primary-action-simplification.md|implementation/roadmap/capsules/home-maps-static-read-model-snapshot-readiness.md|implementation/roadmap/capsules/complete-run-progression-contract-plan.md|implementation/roadmap/capsules/complete-run-cloud-functions-emulator-skeleton.md|implementation/roadmap/capsules/run-duration-fields.md|implementation/roadmap/capsules/running-activity-history-user-link.md|implementation/roadmap/capsules/firestore-base-bootstrap-seam.md|implementation/roadmap/capsules/profile-persistence-rules-contract.md|implementation/roadmap/capsules/goal-plan-detail-static-snapshot-shell.md|implementation/roadmap/capsules/goal-plan-detail-header-timeline-alignment.md|implementation/roadmap/capsules/maps-tab-static-placeholder.md|implementation/roadmap/capsules/maps-static-discovery-hierarchy-polish.md|implementation/roadmap/capsules/leaderboard-static-motivation-hierarchy-polish.md|implementation/roadmap/capsules/leaderboard-map-first-landing-shell.md|implementation/roadmap/capsules/leaderboard-help-modal-shell.md|implementation/roadmap/capsules/leaderboard-region-preview-sheet-shell.md|implementation/roadmap/capsules/leaderboard-leagues-popup-shell.md|implementation/roadmap/capsules/leaderboard-static-read-model-snapshot-readiness.md|implementation/roadmap/capsules/flutter-frontend-hygiene-cleanup.md|implementation/roadmap/capsules/flutter-source-structure-refactor.md|implementation/roadmap/capsules/run-tab-static-placeholder.md|implementation/roadmap/capsules/run-tab-fullscreen-map-overlay-alignment.md|implementation/roadmap/capsules/run-controls-and-plan-spacing-polish.md|implementation/roadmap/capsules/run-launch-fullscreen-static-interaction.md|implementation/roadmap/capsules/run-launch-brand-color-polish.md|implementation/roadmap/capsules/run-plan-objective-bottom-sheet.md|implementation/roadmap/capsules/run-static-read-model-snapshot-readiness.md|implementation/roadmap/capsules/weekly-workout-detail-static-snapshot-shell.md|implementation/roadmap/capsules/expert-plan-list-static-snapshot-shell.md|implementation/roadmap/capsules/expert-plan-detail-static-snapshot-shell.md|implementation/roadmap/capsules/you-tab-progress-overview-static.md|implementation/roadmap/capsules/you-plans-static-ui.md|implementation/roadmap/capsules/home-social-dropdown-friends-shell.md|implementation/roadmap/capsules/home-you-state-stability.md|implementation/roadmap/capsules/adaptive-character-guidance.md)
      return 0
      ;;
    # Approved: scaffold-baseline instruction/setup-gate alignment only
    implementation/AGENTS.md|implementation/mobile/AGENTS.md|implementation/traceability/setup-gates.md|implementation/traceability/requirements-map.md)
      return 0
      ;;
    # Approved: scaffold-baseline and Codex-only review instruction cleanup
    AGENTS.md|docs/pdd/AGENTS_CHANGELOG.md|.agents/skills/runiac-review-flow/SKILL.md|.claude/settings.json|tools/agent-review/README.md|tools/agent-review/profiles/runiac/context-policy.yml|tools/agent-review/runner/build_context_packet.sh|tools/agent-review/runner/classify_high_risk_task.sh|tools/agent-review/runner/run_plan_review.sh|tools/agent-review/profiles/runiac/prompts/01_codex_create_plan.md)
      return 0
      ;;
    # Approved: reusable agent-review reference templates only
    tools/agent-review/templates/*.md)
      return 0
      ;;
    implementation/roadmap/CURRENT.md|implementation/roadmap/phases/phase-01-governance-ci.md|implementation/roadmap/snapshots/latest.md|implementation/roadmap/decisions/ADR-003-governance-lite-execution-lanes.md|implementation/roadmap/ci/*|tools/governance-ci/*|.github/workflows/governance-ci.yml)
      return 0
      ;;
    .gitignore)
      return 0
      ;;
    firebase/README.md|firebase/emulators/README.md|firebase/messaging/README.md|firebase.json|firestore.rules|firestore.indexes.json|tests/firebase-rules/.gitignore|tests/firebase-rules/firestore.rules.test.mjs|tests/firebase-rules/support/firestore_rules_test_support.mjs|tests/firebase-rules/package-lock.json|tests/firebase-rules/package.json)
      return 0
      ;;
    tests/governance/backend_functions_scope_test.sh)
      return 0
      ;;
    functions/.gitignore|functions/package-lock.json|functions/package.json|functions/tsconfig.json|functions/src/index.ts|functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/src/run/validateRunScalarFields.ts|functions/src/progression/planBoundedStreakState.ts|functions/src/progression/progressionEventWriter.ts|functions/src/progression/streakCalculator.ts|functions/src/agent/homeGuideAgent.ts|functions/src/agent/homeGuideAgentHandler.ts|functions/src/agent/homeGuideContracts.ts|functions/src/agent/homeGuideEvidence.ts|functions/src/agent/homeGuideModel.ts|functions/src/agent/homeGuideModelOutput.ts|functions/src/agent/homeGuideQuotaCache.ts|functions/src/agent/homeGuideQuotaFingerprint.ts|functions/test/completeRun.test.ts|functions/test/completeRunCallableSurface.test.ts|functions/test/homeGuideAgentCallableSurface.test.ts|functions/test/homeGuideAgentSurface.test.ts|functions/test/homeGuideEvidence.test.ts|functions/test/homeGuideEvidenceFixtures.ts|functions/test/homeGuideModel.test.ts|functions/test/homeGuideModelFixtures.ts|functions/test/homeGuideQuotaCache.test.ts)
      if is_complete_run_functions_capsule_active; then
        return 0
      fi
      if is_running_activity_history_functions_path "$1" && is_running_activity_history_capsule_active; then
        return 0
      fi
      if is_run_duration_fields_functions_path "$1" && is_run_duration_fields_capsule_active; then
        return 0
      fi
      if is_cadence_capture_reliability_functions_path "$1" && is_cadence_capture_reliability_capsule_active; then
        return 0
      fi
      if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
        return 0
      fi
      return 1
      ;;
    functions/test/completeRunZeroMetrics.test.ts)
      if is_running_activity_history_capsule_active; then
        return 0
      fi
      return 1
      ;;
    implementation/mobile/runiac_app/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_share_rank_export_capsule_active() {
  grep -Eq '^- Newly routed Share-rank card export targets on 2026-07-18 Asia/Singapore: `implementation/roadmap/capsules/share-rank-card-export-targets\.md`' implementation/roadmap/CURRENT.md
}

is_share_rank_export_backend_path() {
  case "$1" in
    storage.rules|\
    tests/firebase-rules/share-card.storage.rules.test.mjs|\
    tests/firebase-rules/package.json)
      return 0
      ;;
  esac
  return 1
}

is_legal_documents_and_links_capsule_active() {
  grep -Eq '^Newly routed Legal documents and links capsule on 2026-07-26 Asia/Singapore: `implementation/roadmap/capsules/legal-documents-and-links\.md`' implementation/roadmap/CURRENT.md
}

is_unrelated_mobile_native_artifact() {
  # The routed Share-rank export-targets capsule registers the Instagram Stories
  # Swift channel, which requires editing the Xcode project file.
  if [ "$1" = "implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj" ] \
    && is_share_rank_export_capsule_active; then
    return 1
  fi
  # The routed Legal documents and links capsule adds the user-approved
  # url_launcher dependency, which regenerates the CocoaPods lockfile and can
  # touch the Xcode project file.
  case "$1" in
    implementation/mobile/runiac_app/ios/Podfile.lock|\
    implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj)
      if is_legal_documents_and_links_capsule_active; then
        return 1
      fi
      ;;
  esac
  # The routed Profile photo avatars capsule adds the user-approved
  # image_picker dependency, which regenerates the CocoaPods lockfile and can
  # touch the Xcode project file.
  case "$1" in
    implementation/mobile/runiac_app/ios/Podfile.lock|\
    implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj)
      if is_profile_photo_avatar_capsule_active; then
        return 1
      fi
      ;;
  esac
  case "$1" in
    implementation/mobile/runiac_app/ios/Podfile.lock|\
    implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.pbxproj|\
    implementation/mobile/runiac_app/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/*|\
    implementation/mobile/runiac_app/ios/Runner.xcworkspace/xcshareddata/swiftpm/*|\
    implementation/mobile/runiac_app/ios/**/Package.resolved)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_forbidden_path() {
  if is_profile_photo_avatar_path "$1" && is_profile_photo_avatar_capsule_active; then
    return 1
  fi

  if is_error_reporting_pipeline_path "$1" && is_error_reporting_pipeline_capsule_active; then
    return 1
  fi

  if is_feed_author_identity_profile_entry_path "$1" && is_feed_author_identity_profile_entry_capsule_active; then
    return 1
  fi

  if is_progression_followups_path "$1" && is_progression_followups_capsule_active; then
    return 1
  fi

  if is_feed_live_author_level_path "$1" && is_feed_live_author_level_capsule_active; then
    return 1
  fi

  if is_friends_live_level_path "$1" && is_friends_live_level_capsule_active; then
    return 1
  fi

  if is_level_progress_ring_path "$1" && is_level_progress_ring_capsule_active; then
    return 1
  fi

  if is_admin_automation_policy_path "$1" && is_admin_automation_policy_capsule_active; then
    return 1
  fi

  if is_test_suite_regression_hardening_path "$1" && is_test_suite_regression_hardening_capsule_active; then
    return 1
  fi

  if is_premium_parity_progression_path "$1" && is_premium_parity_progression_capsule_active; then
    return 1
  fi

  if is_exception_queue_moderation_path "$1" && is_exception_queue_moderation_capsule_active; then
    return 1
  fi

  if is_user_feedback_pipeline_path "$1" && is_user_feedback_pipeline_capsule_active; then
    return 1
  fi

  if is_website_newsletter_subscription_path "$1" && is_website_newsletter_subscription_capsule_active; then
    return 1
  fi

  if is_feed_engagement_push_path "$1" && is_feed_engagement_push_capsule_active; then
    return 1
  fi

  if is_feed_engagement_notifications_path "$1" && is_feed_engagement_notifications_capsule_active; then
    return 1
  fi

  if is_review_triage_notification_privacy_quota_path "$1" && is_review_triage_notification_privacy_quota_capsule_active; then
    return 1
  fi

  if is_admin_role_subscription_expiry_path "$1" && is_admin_role_subscription_expiry_capsule_active; then
    return 1
  fi

  if is_profile_stats_visibility_path "$1" && is_profile_stats_visibility_capsule_active; then
    return 1
  fi

  if is_home_guide_plan_brief_path "$1" && is_home_guide_plan_brief_capsule_active; then
    return 1
  fi

  if is_workout_detail_briefing_agent_path "$1" && is_workout_detail_briefing_agent_capsule_active; then
    return 1
  fi

  if is_share_rank_export_capsule_active && is_share_rank_export_backend_path "$1"; then
    return 1
  fi

  if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
    return 1
  fi

  if is_friends_backend_mvp_path "$1" && is_friends_backend_mvp_capsule_active; then
    return 1
  fi

  if is_challenge_distance_system_path "$1" && is_challenge_distance_system_capsule_active; then
    return 1
  fi

  if is_cool_down_stretch_xp_bonus_path "$1" && is_cool_down_stretch_xp_bonus_capsule_active; then
    return 1
  fi

  if is_plan_completion_signal_path "$1" && is_plan_completion_signal_capsule_active; then
    return 1
  fi

  if is_admin_console_leaderboard_oversight_path "$1" && is_admin_console_leaderboard_oversight_capsule_active; then
    return 1
  fi

  if is_feed_friends_emulator_backend_path "$1"; then
    if is_feed_friends_emulator_backend_capsule_active; then
      return 1
    fi
    return 0
  fi

  case "$1" in
    firebase.json|firestore.rules)
      return 1
      ;;
    *.env.example|*.env.*.example)
      return 1
      ;;
    *firebase.json|*.firebaserc|*firebase_options.dart|*google-services.json|*GoogleService-Info.plist|*firestore.rules|*storage.rules)
      return 0
      ;;
    *.env|*.env.*|*service-account*|*credentials*|*ServiceAccount*|*Credentials*)
      return 0
      ;;
    *android/local.properties|*android/key.properties|*.jks|*.keystore|*.p12|*.cer|*.mobileprovision|*.p8)
      return 0
      ;;
    */build/*|build/*|*/.dart_tool/*|*.apk|*.aab|*.ipa|*.xcarchive)
      return 0
      ;;
    firebase/functions/*|firebase/functions/src/*)
      return 0
      ;;
    functions/.gitignore|functions/package-lock.json|functions/package.json|functions/tsconfig.json|functions/src/index.ts|functions/src/run/completeRun.ts|functions/src/run/runCompletionTypes.ts|functions/src/run/validateCadenceAnalysisSeries.ts|functions/src/run/validateRunPayload.ts|functions/src/run/validateRunScalarFields.ts|functions/src/progression/planBoundedStreakState.ts|functions/src/progression/progressionEventWriter.ts|functions/src/progression/streakCalculator.ts|functions/src/agent/homeGuideAgent.ts|functions/src/agent/homeGuideAgentHandler.ts|functions/src/agent/homeGuideContracts.ts|functions/src/agent/homeGuideEvidence.ts|functions/src/agent/homeGuideModel.ts|functions/src/agent/homeGuideModelOutput.ts|functions/src/agent/homeGuideQuotaCache.ts|functions/src/agent/homeGuideQuotaFingerprint.ts|functions/test/completeRun.test.ts|functions/test/completeRunCallableSurface.test.ts|functions/test/homeGuideAgentCallableSurface.test.ts|functions/test/homeGuideAgentSurface.test.ts|functions/test/homeGuideEvidence.test.ts|functions/test/homeGuideEvidenceFixtures.ts|functions/test/homeGuideModel.test.ts|functions/test/homeGuideModelFixtures.ts|functions/test/homeGuideQuotaCache.test.ts)
      if is_complete_run_functions_capsule_active; then
        return 1
      fi
      if is_running_activity_history_functions_path "$1" && is_running_activity_history_capsule_active; then
        return 1
      fi
      if is_run_duration_fields_functions_path "$1" && is_run_duration_fields_capsule_active; then
        return 1
      fi
      if is_cadence_capture_reliability_functions_path "$1" && is_cadence_capture_reliability_capsule_active; then
        return 1
      fi
      if is_adaptive_character_guidance_functions_path "$1" && is_adaptive_character_guidance_capsule_active; then
        return 1
      fi
      return 0
      ;;
    functions/test/completeRunZeroMetrics.test.ts)
      if is_running_activity_history_capsule_active; then
        return 1
      fi
      return 0
      ;;
    functions/*)
      return 0
      ;;
    *package.json)
      case "$1" in
        functions/package.json)
          if is_complete_run_functions_capsule_active || is_running_activity_history_capsule_active; then
            return 1
          fi
          return 0
          ;;
        implementation/*|firebase/*|functions/*)
          return 0
          ;;
      esac
      ;;
  esac

  return 1
}

is_deletion_status() {
  case "$1" in
    " D"|"D "|D)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_pubspec_outside_approved_scaffold() {
  case "$1" in
    implementation/mobile/runiac_app/pubspec.yaml|implementation/mobile/runiac_app/pubspec.lock)
      return 1
      ;;
    *pubspec.yaml|*pubspec.lock)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

diff_check_output="$(git diff --check 2>&1 || true)"
if [ -n "$diff_check_output" ]; then
  fail "Whitespace errors detected by git diff --check: $diff_check_output"
fi

cached_diff_check_output="$(git diff --cached --check 2>&1 || true)"
if [ -n "$cached_diff_check_output" ]; then
  fail "Whitespace errors detected by git diff --cached --check: $cached_diff_check_output"
fi

while IFS= read -r line; do
  [ -n "$line" ] || continue
  status_code="${line:0:2}"
  path="${line:3}"
  case "$path" in
    *' -> '*)
      path="${path##* -> }"
      ;;
  esac

  if ! is_allowed_path "$path"; then
    fail "Unrelated modified path is outside Governance CI scope: $path"
  fi

  if is_unrelated_mobile_native_artifact "$path"; then
    fail "Unrelated iOS/SwiftPM native artifact appears in diff status: $path"
  fi

  if is_forbidden_path "$path" && ! is_deletion_status "$status_code"; then
    fail "Forbidden implementation/config artifact appears in diff status: $path"
  fi

  if is_pubspec_outside_approved_scaffold "$path"; then
    fail "Flutter pubspec artifact appears outside approved scaffold path: $path"
  fi
done < <(git status --short --untracked-files=all)

while IFS=$'\t' read -r status path rest; do
  [ -n "$path" ] || continue
  if [ -n "${rest:-}" ]; then
    path="$rest"
  fi

  if is_unrelated_mobile_native_artifact "$path"; then
    fail "Unrelated iOS/SwiftPM native artifact appears in tracked diff: $path"
  fi

  if is_forbidden_path "$path" && ! is_deletion_status "$status"; then
    fail "Forbidden implementation/config artifact appears in tracked diff: $path"
  fi

  if is_pubspec_outside_approved_scaffold "$path"; then
    fail "Flutter pubspec artifact appears outside approved scaffold path: $path"
  fi
done < <(git diff --name-status)

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Diff has no whitespace errors, unrelated paths, or forbidden implementation/config artifacts; approved Flutter scaffold, Auth config, Functions skeleton, and routed capsule exceptions are allowed only on their explicit paths.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Diff hygiene failed.\n'
printf 'next_step=Remove unrelated or forbidden files, fix whitespace, then rerun once.\n'
exit 1
