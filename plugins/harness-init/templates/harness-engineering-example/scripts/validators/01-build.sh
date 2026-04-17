#!/usr/bin/env bash
# =============================================================================
# 01-build.sh — Verify build success
# Args: $1=worktree path, $2=project root
# =============================================================================
set -euo pipefail

WORKTREE_PATH="${1:-$(pwd)}"
PROJECT_ROOT="${2:-$(pwd)}"

source "$PROJECT_ROOT/harness.config.sh"

if [[ "$ENABLE_BUILD_CHECK" != "true" ]]; then
  echo "[SKIP] Build check disabled (ENABLE_BUILD_CHECK=false)"
  exit 0
fi

echo "[BUILD] Running build..."
echo "  Command: $BUILD_CMD"
echo "  Path:    $WORKTREE_PATH"

cd "$WORKTREE_PATH"

set +e
output=$(eval "$BUILD_CMD" 2>&1)
exit_code=$?
set -e

if [[ $exit_code -ne 0 ]]; then
  cat <<EOF

[BUILD FAILURE] validators/01-build.sh
  Command: $BUILD_CMD
  Exit code: $exit_code

  Error output:
$(echo "$output" | head -30 | sed 's/^/  /')

  How to fix:
  1. Check the file name and line number in the error above
  2. For compile errors, fix the indicated file
  3. For dependency errors, check the build file (build.gradle.kts, package.json, etc.)
  Reference: ARCHITECTURE.md, docs/design-docs/core-beliefs.md

EOF
  exit 1
fi

echo "[BUILD] Build succeeded"
