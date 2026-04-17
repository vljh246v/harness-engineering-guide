#!/usr/bin/env bash
# =============================================================================
# verify-task.sh — Run validation only (no merge)
# Usage: ./scripts/verify-task.sh <task-name>
#
# Run repeatedly during implementation to check current status.
# Unlike task-finish.sh, this only shows results without merging.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/harness.config.sh"

TASK_NAME="${1:-}"
if [[ -z "$TASK_NAME" ]]; then
  echo "[ERROR] verify-task.sh: please provide a task-name"
  echo "  Usage: ./scripts/verify-task.sh <task-name>"
  exit 1
fi

WORKTREE_PATH="${PROJECT_ROOT}/${WORKTREE_ROOT}/${TASK_NAME}"
VALIDATOR_HISTORY="${PROJECT_ROOT}/${LOG_DIR}/validators/history.jsonl"
mkdir -p "$(dirname "$VALIDATOR_HISTORY")"

if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "[ERROR] Worktree not found: $WORKTREE_PATH"
  echo "  Make sure you ran task-start.sh first."
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " [verify-task] Task: $TASK_NAME (validation only — no merge)"
echo " Worktree: $WORKTREE_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

VALIDATORS_DIR="$SCRIPT_DIR/validators"
PASSED=0
FAILED=0
FAILED_VALIDATORS=()

log_validator() {
  local name="$1"
  local result="$2"
  local error="${3:-}"
  local entry="{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"task\":\"${TASK_NAME}\",\"validator\":\"${name}\",\"result\":\"${result}\",\"mode\":\"verify\""
  [[ -n "$error" ]] && entry="${entry},\"error\":$(echo "$error" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))' 2>/dev/null || echo '""')"
  entry="${entry}}"
  echo "$entry" >> "$VALIDATOR_HISTORY"
}

for validator in \
  "$VALIDATORS_DIR/01-build.sh" \
  "$VALIDATORS_DIR/02-test.sh" \
  "$VALIDATORS_DIR/03-lint.sh" \
  "$VALIDATORS_DIR/04-security.sh" \
  "$VALIDATORS_DIR/05-docs-freshness.sh"; do

  [[ -f "$validator" ]] || continue

  validator_name="$(basename "$validator" .sh)"
  echo "  ▶ $validator_name ..."

  start_ms=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo "0")

  set +e
  output=$(bash "$validator" "$WORKTREE_PATH" "$PROJECT_ROOT" 2>&1)
  exit_code=$?
  set -e

  end_ms=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo "0")
  duration_ms=$(( end_ms - start_ms ))

  if [[ $exit_code -eq 0 ]]; then
    echo "    ✓ PASS (${duration_ms}ms)"
    log_validator "$validator_name" "pass"
    (( PASSED++ )) || true
  else
    echo ""
    echo "    ✗ FAIL (${duration_ms}ms)"
    echo ""
    echo "$output" | sed 's/^/    /'
    echo ""
    log_validator "$validator_name" "fail" "$output"
    FAILED_VALIDATORS+=("$validator_name")
    (( FAILED++ )) || true
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Validation result: PASS $PASSED / FAIL $FAILED"

if [[ $FAILED -gt 0 ]]; then
  echo ""
  echo " Failed validators:"
  for v in "${FAILED_VALIDATORS[@]}"; do
    echo "   • $v"
  done
fi

echo ""
echo " This command only runs validation. To merge:"
echo "   ./scripts/task-finish.sh $TASK_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[[ $FAILED -gt 0 ]] && exit 1 || exit 0
