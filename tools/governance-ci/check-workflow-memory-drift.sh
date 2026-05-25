#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-workflow-memory-drift"
scanned_paths="git diff --name-only,git diff --cached --name-only"

changed_paths=()
while IFS= read -r path; do
  [ -n "$path" ] || continue
  changed_paths+=("$path")
done < <(
  {
    git diff --name-only
    git diff --cached --name-only
  } | sort -u
)

pass() {
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'message=No workflow-memory drift signal detected.\n'
  exit 0
}

warn() {
  printf 'CHECK %s WARN\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'changed_workflow_paths=%s\n' "$1"
  printf 'message=Workflow-impacting files changed. Review whether workflow memory, snapshot metadata, or capsule closure state needs a human-approved update.\n'
  printf 'next_step=If relevant, route a documentation/governance patch. Do not auto-update docs/meta, CURRENT.md, snapshots, or capsules.\n'
  exit 0
}

is_workflow_path() {
  case "$1" in
    AGENTS.md|docs/AGENTS.md|docs/meta/AGENTS.md)
      return 0
      ;;
    implementation/roadmap/CURRENT.md|implementation/roadmap/snapshots/latest.md)
      return 0
      ;;
    implementation/roadmap/capsules/*|implementation/roadmap/decisions/*)
      return 0
      ;;
    implementation/traceability/setup-gates.md|implementation/traceability/requirements-map.md)
      return 0
      ;;
    tools/governance-ci/*|tools/agent-review/*)
      return 0
      ;;
    docs/meta/ARTIFACT_INVENTORY_SCHEMA.md|docs/meta/META_KNOWLEDGE_ARCHITECTURE.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_review_satisfying_path() {
  case "$1" in
    docs/meta/REPOSITORY_WORKFLOW_RECORD.md)
      return 0
      ;;
    implementation/roadmap/CURRENT.md|implementation/roadmap/snapshots/latest.md)
      return 0
      ;;
    implementation/roadmap/capsules/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_current_or_snapshot() {
  case "$1" in
    implementation/roadmap/CURRENT.md|implementation/roadmap/snapshots/latest.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

join_by_comma() {
  local joined=""
  local path
  for path in "$@"; do
    if [ -z "$joined" ]; then
      joined="$path"
    else
      joined="$joined,$path"
    fi
  done
  printf '%s' "$joined"
}

if [ "${#changed_paths[@]}" -eq 0 ]; then
  pass
fi

workflow_paths=()
review_satisfying_paths=()
self_changed=0
runner_changed=0
self_bootstrap_only=1

for path in "${changed_paths[@]}"; do
  if is_workflow_path "$path"; then
    workflow_paths+=("$path")
  fi

  if is_review_satisfying_path "$path"; then
    review_satisfying_paths+=("$path")
  fi

  case "$path" in
    tools/governance-ci/check-workflow-memory-drift.sh)
      self_changed=1
      ;;
    tools/governance-ci/run-all-checks.sh)
      runner_changed=1
      ;;
    *)
      self_bootstrap_only=0
      ;;
  esac
done

# While this detector is first added, the new script is untracked and therefore
# absent from git diff --name-only. Pairing that new file with the runner entry
# is the only bootstrap case suppressed here.
if [ "$runner_changed" -eq 1 ] &&
  [ -f tools/governance-ci/check-workflow-memory-drift.sh ] &&
  ! git ls-files --error-unmatch tools/governance-ci/check-workflow-memory-drift.sh >/dev/null 2>&1; then
  self_changed=1
fi

if [ "${#workflow_paths[@]}" -eq 0 ]; then
  pass
fi

# Bootstrapping this detector requires changing the detector and runner together.
# Keep this narrow so other tools/governance-ci changes still surface drift warnings.
if [ "$self_changed" -eq 1 ] && [ "$runner_changed" -eq 1 ] && [ "$self_bootstrap_only" -eq 1 ]; then
  pass
fi

if [ "${#changed_paths[@]}" -eq 1 ] && is_current_or_snapshot "${changed_paths[0]}"; then
  warn "$(join_by_comma "${workflow_paths[@]}")"
fi

if [ "${#review_satisfying_paths[@]}" -gt 0 ]; then
  pass
fi

warn "$(join_by_comma "${workflow_paths[@]}")"
