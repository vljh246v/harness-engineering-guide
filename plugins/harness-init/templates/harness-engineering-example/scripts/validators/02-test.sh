#!/usr/bin/env bash
# =============================================================================
# 02-test.sh — Run tests and verify all pass
# Args: $1=worktree path, $2=project root
# =============================================================================
set -euo pipefail

WORKTREE_PATH="${1:-$(pwd)}"
PROJECT_ROOT="${2:-$(pwd)}"

source "$PROJECT_ROOT/harness.config.sh"

if [[ "$ENABLE_TEST_CHECK" != "true" ]]; then
  echo "[SKIP] Test check disabled (ENABLE_TEST_CHECK=false)"
  exit 0
fi

echo "[TEST] Running tests..."
echo "  Command: $TEST_CMD"
echo "  Path:    $WORKTREE_PATH"

cd "$WORKTREE_PATH"

set +e
output=$(eval "$TEST_CMD" 2>&1)
exit_code=$?
set -e

if [[ $exit_code -ne 0 ]]; then
  # Attempt to extract failed test cases
  failed_tests=$(echo "$output" | grep -E "(FAIL|FAILED|ERROR|✗|×)" | head -10 || true)

  cat <<EOF

[TEST FAILURE] validators/02-test.sh
  Command: $TEST_CMD
  Exit code: $exit_code

  Failed tests:
$(echo "${failed_tests:-'(check the output above)'}" | sed 's/^/  /')

  Full output (last 30 lines):
$(echo "$output" | tail -30 | sed 's/^/  /')

  How to fix:
  1. Check the failed test cases
  2. Compare what the test expects vs the actual implementation
  3. For new features: write tests alongside the feature code
  4. For refactoring: modify only the implementation, not the test logic

  Reference: logs/trends/failure-patterns.md (recurring failure patterns)

EOF
  exit 1
fi

echo "[TEST] All tests passed"
