#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-agent-governance"
scanned_paths="AGENTS.md"
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

require_text() {
  local pattern="$1"
  local label="$2"
  if ! grep -Fq -- "$pattern" AGENTS.md; then
    fail "Missing AGENTS.md governance text: $label"
  fi
}

if [ ! -f AGENTS.md ]; then
  fail "Missing root AGENTS.md"
else
  require_text '## Commit Protocol' 'commit protocol'
  require_text '## Non-Negotiable Runiac Rules' 'non-negotiable Runiac rules'
  require_text '## Path Protection' 'path protection'
  require_text '## Roadmap Context Protocol' 'roadmap context protocol'
  require_text 'docs/pdd/diagrams/' 'canonical PDD diagram path'
  require_text 'Root `diagrams/` is legacy/reference-only' 'legacy root diagrams boundary'
  require_text 'The client must not directly calculate or write XP, level, rank, streak, leaderboard score, weekly XP, or monthly XP.' 'backend-owned progression rule'
  require_text 'Basic/Premium feature access uses `subscriptionStatus`.' 'subscriptionStatus access rule'
  require_text 'Operational and governance access uses `userRole`.' 'userRole governance rule'
  require_text 'Platform Administrator is the governance and CRUDS role.' 'Platform Administrator governance authority'
  require_text 'Read `implementation/roadmap/CURRENT.md` first (always).' 'roadmap first-read rule'

  for heading in \
    '## Commit Protocol' \
    '## Non-Negotiable Runiac Rules' \
    '## Path Protection' \
    '## Roadmap Context Protocol'; do
    count="$(grep -Fc -- "$heading" AGENTS.md || true)"
    if [ "$count" -ne 1 ]; then
      fail "AGENTS.md heading should appear exactly once: $heading (found $count)"
    fi
  done
fi

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=Root agent governance retains required constraints and canonical ownership rules.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Root agent governance is missing required constraints or contains conflicting duplicate headings.\n'
printf 'next_step=Route the finding to A6_REVIEW and A8_OUTPUT_CHECKER before editing governance instructions.\n'
exit 1
