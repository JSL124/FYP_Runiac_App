#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

check_name="check-pre-scaffold-scope"
scanned_paths="."
failures=0

fail() {
  failures=$((failures + 1))
  printf 'finding=%s\n' "$1"
}

while IFS= read -r path; do
  fail "Forbidden scaffold/config marker found: $path"
done < <(
  find . \
    -path './.git' -prune -o \
    -type f \( \
      -name 'pubspec.yaml' -o \
      -name 'firebase.json' -o \
      -name '.firebaserc' -o \
      -name 'google-services.json' -o \
      -name 'GoogleService-Info.plist' -o \
      -name 'firebase_options.dart' \
    \) -print
)

while IFS= read -r path; do
  fail "Forbidden app package marker found: $path"
done < <(
  find . \
    -path './.git' -prune -o \
    -path './node_modules' -prune -o \
    -path './.next' -prune -o \
    -path './dist' -prune -o \
    -type f -name 'package.json' \( \
      -path './implementation/*' -o \
      -path './firebase/*' -o \
      -path './functions/*' \
    \) -print
)

while IFS= read -r path; do
  fail "Forbidden production source marker found: $path"
done < <(
  find . \
    -path './.git' -prune -o \
    -type f \( \
      -path './implementation/mobile/*/lib/*.dart' -o \
      -path './implementation/mobile/*/android/*' -o \
      -path './implementation/mobile/*/ios/*' -o \
      -path './firebase/functions/src/*' -o \
      -path './firebase/firestore.rules' -o \
      -path './firebase/storage.rules' \
    \) -print
)

if [ "$failures" -eq 0 ]; then
  printf 'CHECK %s PASS\n' "$check_name"
  printf 'scanned_paths=%s\n' "$scanned_paths"
  printf 'message=No Flutter scaffold, Firebase config, production source/config, or app package markers found.\n'
  exit 0
fi

printf 'CHECK %s FAIL\n' "$check_name"
printf 'scanned_paths=%s\n' "$scanned_paths"
printf 'message=Pre-scaffold boundary markers were found.\n'
printf 'next_step=Remove unauthorized scaffold/config/source files or route the finding to A6_REVIEW and A8_OUTPUT_CHECKER.\n'
exit 1
