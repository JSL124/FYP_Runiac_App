#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-roadmap-routing"
current_file="implementation/roadmap/CURRENT.md"
snapshot_file="implementation/roadmap/snapshots/latest.md"
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

if [ ! -f "$current_file" ]; then
  fail "Missing roadmap current file: $current_file"
  active_phase=""
else
  active_phase_count="$(grep -Ec '^- Current phase: `[^`]+`$' "$current_file" || true)"
  if [ "$active_phase_count" -ne 1 ]; then
    fail "CURRENT.md must name exactly one active phase; found $active_phase_count"
    active_phase=""
  else
    active_phase="$(sed -n 's/^- Current phase: `\(.*\)`$/\1/p' "$current_file")"
    if [ ! -f "$active_phase" ]; then
      fail "Active phase file is missing: $active_phase"
    fi
  fi
fi

if [ ! -f "$snapshot_file" ]; then
  fail "Missing roadmap snapshot file: $snapshot_file"
fi

if [ -f "$current_file" ]; then
  for required in \
    '1. `implementation/roadmap/CURRENT.md`' \
    '2. Active phase document listed above' \
    '3. Relevant ADRs listed below' \
    '4. `implementation/roadmap/snapshots/latest.md`'; do
    if ! grep -Fq -- "$required" "$current_file"; then
      fail "Missing required reading-order entry in CURRENT.md: $required"
    fi
  done

  if grep -Eq 'Current phase: `implementation/roadmap/phases/phase-00' "$current_file"; then
    fail "Stale Phase 00 active phase routing remains after closure"
  fi

  if ! grep -Fq 'Current active capsule: Capsule 2 - Governance CI implementation' "$current_file"; then
    fail "CURRENT.md does not route to Capsule 2 - Governance CI implementation"
  fi

  if ! grep -Fq 'Do not run Flutter, Firebase, npm, build, test, deploy, scaffold, or init commands.' "$current_file"; then
    fail "CURRENT.md missing explicit forbidden-scope language"
  fi
fi

if [ -n "${active_phase:-}" ] && [ -f "$active_phase" ]; then
  if ! grep -Eq 'Governance CI|governance CI|Phase 01' "$active_phase"; then
    fail "Active phase file does not appear to describe Phase 01 Governance CI: $active_phase"
  fi

  if ! grep -Eq 'Do not run|Forbidden|forbidden|scaffold|Flutter|Firebase|npm|build|deploy' "$active_phase"; then
    fail "Active phase file missing explicit forbidden-scope language: $active_phase"
  fi
fi

if [ -f "$snapshot_file" ]; then
  if ! grep -Eq '[0-9a-f]{7,40}' "$snapshot_file"; then
    fail "Snapshot file missing commit hash: $snapshot_file"
  fi
fi

scanned_paths="$current_file,${active_phase:-<missing-active-phase>},$snapshot_file"

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Active phase, reading order, snapshot metadata, and forbidden-scope routing are deterministic.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Roadmap routing is incomplete or stale.\n'
printf 'next_step=Update roadmap routing artifacts, then rerun once.\n'
exit 1
