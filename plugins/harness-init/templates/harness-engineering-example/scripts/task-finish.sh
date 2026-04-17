#!/usr/bin/env bash
# =============================================================================
# task-finish.sh — Merge to BASE_BRANCH only if validation passes
# Usage: ./scripts/task-finish.sh <task-name>
# Example: ./scripts/task-finish.sh feat-login
#
# Note: If any validator fails, the merge is blocked.
#       On failure, the worktree is preserved for debugging.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/harness.config.sh"

TASK_NAME="${1:-}"
if [[ -z "$TASK_NAME" ]]; then
  echo "[ERROR] task-finish.sh: please provide a task-name"
  echo "  Usage: ./scripts/task-finish.sh <task-name>"
  exit 1
fi

BRANCH_NAME="${BRANCH_PREFIX:-feature}/${TASK_NAME}"
WORKTREE_PATH="${PROJECT_ROOT}/${WORKTREE_ROOT}/${TASK_NAME}"
SESSION_LOG="${PROJECT_ROOT}/${LOG_DIR}/sessions/${TASK_NAME}/session.jsonl"
VALIDATOR_HISTORY="${PROJECT_ROOT}/${LOG_DIR}/validators/history.jsonl"
mkdir -p "$(dirname "$VALIDATOR_HISTORY")"

log_event() {
  local event="$1"
  local extra="${2:-}"
  local entry="{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"${event}\",\"task\":\"${TASK_NAME}\""
  [[ -n "$extra" ]] && entry="${entry},${extra}"
  entry="${entry}}"
  echo "$entry" >> "$SESSION_LOG"
}

log_validator() {
  local name="$1"
  local result="$2"
  local error="${3:-}"
  local entry="{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"task\":\"${TASK_NAME}\",\"validator\":\"${name}\",\"result\":\"${result}\""
  [[ -n "$error" ]] && entry="${entry},\"error\":$(echo "$error" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')"
  entry="${entry}}"
  echo "$entry" >> "$VALIDATOR_HISTORY"
}

# Check worktree exists
if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "[ERROR] Worktree not found: $WORKTREE_PATH"
  echo "  Make sure you ran task-start.sh first."
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " [task-finish] Task: $TASK_NAME"
echo " Worktree: $WORKTREE_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

VALIDATORS_DIR="$SCRIPT_DIR/validators"
PASSED=0
FAILED=0
FAILED_VALIDATORS=()

# =============================================================================
# Run validators in sequence
# =============================================================================
run_validator() {
  local validator_script="$1"
  local validator_name
  validator_name="$(basename "$validator_script" .sh)"

  echo "  ▶ $validator_name ..."

  local start_ms
  start_ms=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo "0")

  local output
  local exit_code=0

  set +e
  output=$(bash "$validator_script" "$WORKTREE_PATH" "$PROJECT_ROOT" 2>&1)
  exit_code=$?
  set -e

  local end_ms
  end_ms=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo "0")
  local duration_ms=$(( end_ms - start_ms ))

  if [[ $exit_code -eq 0 ]]; then
    echo "    ✓ PASS (${duration_ms}ms)"
    log_event "validator" "\"name\":\"${validator_name}\",\"result\":\"pass\",\"duration_ms\":${duration_ms}"
    log_validator "$validator_name" "pass"
    (( PASSED++ )) || true
  else
    echo ""
    echo "    ✗ FAIL (${duration_ms}ms)"
    echo ""
    echo "$output" | sed 's/^/    /'
    echo ""
    log_event "validator" "\"name\":\"${validator_name}\",\"result\":\"fail\",\"duration_ms\":${duration_ms}"
    log_validator "$validator_name" "fail" "$output"
    FAILED_VALIDATORS+=("$validator_name")
    (( FAILED++ )) || true
  fi
}

# Run validators in order
for validator in \
  "$VALIDATORS_DIR/01-build.sh" \
  "$VALIDATORS_DIR/02-test.sh" \
  "$VALIDATORS_DIR/03-lint.sh" \
  "$VALIDATORS_DIR/04-security.sh" \
  "$VALIDATORS_DIR/05-docs-freshness.sh"; do
  if [[ -f "$validator" ]]; then
    run_validator "$validator"
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Validation result: PASS $PASSED / FAIL $FAILED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# =============================================================================
# On failure — block merge
# =============================================================================
if [[ $FAILED -gt 0 ]]; then
  echo ""
  echo " [BLOCKED] Merge blocked due to the following validator failures:"
  for v in "${FAILED_VALIDATORS[@]}"; do
    echo "   • $v"
  done
  echo ""
  echo " Worktree preserved:"
  echo "   cd $WORKTREE_PATH"
  echo ""
  echo " ┌─────────────────────────────────────────────────────┐"
  echo " │ Next steps: determine the failure cause              │"
  echo " │                                                     │"
  echo " │ A. Your code is wrong (broke existing behavior)     │"
  echo " │    → fix code in worktree → re-run task-finish.sh   │"
  echo " │                                                     │"
  echo " │ B. Intentional change (policy/spec changed)         │"
  echo " │    → update tests too → re-run task-finish.sh       │"
  echo " │                                                     │"
  echo " │ If unsure:                                          │"
  echo " │    → check docs/exec-plans/active/ for the plan     │"
  echo " │    → check docs/escalation-policy.md                │"
  echo " └─────────────────────────────────────────────────────┘"
  echo ""
  echo " For validation-only checks:"
  echo "   ./scripts/verify-task.sh $TASK_NAME"
  echo ""

  log_event "task_finish" "\"result\":\"blocked\",\"failed_validators\":$(printf '%s\n' "${FAILED_VALIDATORS[@]}" | python3 -c 'import sys,json; print(json.dumps([l.strip() for l in sys.stdin]))')"
  exit 1
fi

# =============================================================================
# All passed — branch by MERGE_STRATEGY
# =============================================================================
REMOTE="${GIT_REMOTE:-origin}"
STRATEGY="${MERGE_STRATEGY:-direct}"

EXEC_PLAN_DIR="${PROJECT_ROOT}/docs/exec-plans"
COMPLETED_DIR="${EXEC_PLAN_DIR}/completed"
mkdir -p "$COMPLETED_DIR"

archive_exec_plan() {
  for plan in "$EXEC_PLAN_DIR/active/"*"${TASK_NAME}"*; do
    [[ -f "$plan" ]] || continue
    mv "$plan" "$COMPLETED_DIR/"
    echo " [ARCHIVE] $(basename "$plan") → completed/"
  done
}

if [[ "$STRATEGY" == "pr" ]]; then
  # ===========================================================================
  # PR mode: include exec-plan cleanup in feature branch, then push
  # ===========================================================================
  echo ""
  echo " [ARCHIVE] Cleaning up exec-plan (including in feature branch)..."
  archive_exec_plan

  # Commit cleanup in worktree (feature branch)
  cd "$WORKTREE_PATH"
  git add "$PROJECT_ROOT/logs/validators/history.jsonl" "$EXEC_PLAN_DIR/" 2>/dev/null || true
  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "chore: $TASK_NAME validation log + exec-plan cleanup" --quiet
  fi

  echo " [PUSH] Pushing feature branch..."

  git push "${REMOTE}" "$BRANCH_NAME" 2>&1 || {
    echo "[BLOCKED] Push failed. Check ${REMOTE} remote configuration."
    exit 1
  }

  log_event "task_finish" "\"result\":\"pushed\",\"strategy\":\"pr\",\"validators_passed\":${PASSED}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " [PR REQUIRED]"
  echo ""
  echo "   origin/$BRANCH_NAME → $REMOTE/$BASE_BRANCH"
  echo ""
  echo " Clean up worktree after PR merge:"
  echo "   ./scripts/task-cleanup.sh"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

else
  # ===========================================================================
  # Direct mode: merge locally then clean up
  # ===========================================================================
  echo ""
  echo " [SYNCING] Syncing $BASE_BRANCH..."

  git -C "$PROJECT_ROOT" checkout "$BASE_BRANCH"

  # Sync if remote exists
  if git -C "$PROJECT_ROOT" remote | grep -q "^${REMOTE}$"; then
    if ! git -C "$PROJECT_ROOT" fetch "$REMOTE" "$BASE_BRANCH"; then
      echo "[BLOCKED] Failed to fetch $REMOTE/$BASE_BRANCH. Check network/permissions/remote configuration"
      exit 1
    fi
    if ! git -C "$PROJECT_ROOT" merge --ff-only "$REMOTE/$BASE_BRANCH"; then
      echo "[BLOCKED] Local $BASE_BRANCH cannot fast-forward to $REMOTE/$BASE_BRANCH"
      echo "          Resolve $BASE_BRANCH conflicts and try again."
      exit 1
    fi
  else
    echo " [INFO] No $REMOTE remote — local-only mode"
  fi

  echo " [MERGING] $BRANCH_NAME → $BASE_BRANCH ..."
  git -C "$PROJECT_ROOT" merge "$BRANCH_NAME" --no-ff -m "merge: $TASK_NAME"

  echo " [CLEANUP] Removing worktree..."
  git -C "$PROJECT_ROOT" worktree remove "$WORKTREE_PATH"
  git -C "$PROJECT_ROOT" branch -d "$BRANCH_NAME" 2>/dev/null || true

  # After merge, clean up exec-plan + auto-commit on develop
  archive_exec_plan
  cd "$PROJECT_ROOT"
  git add logs/validators/history.jsonl docs/exec-plans/ 2>/dev/null || true
  if ! git diff --cached --quiet 2>/dev/null; then
    git commit -m "chore: $TASK_NAME validation log + exec-plan cleanup" --quiet
  fi

  log_event "task_finish" "\"result\":\"success\",\"strategy\":\"direct\",\"validators_passed\":${PASSED}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " [SUCCESS] $TASK_NAME completed and merged"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
