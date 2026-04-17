#!/usr/bin/env bash
# =============================================================================
# task-start.sh — Create an isolated worktree for a new task
# Usage: ./scripts/task-start.sh <task-name>
# Example: ./scripts/task-start.sh feat-login
#          ./scripts/task-start.sh fix-auth-bug
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/harness.config.sh"

TASK_NAME="${1:-}"
if [[ -z "$TASK_NAME" ]]; then
  echo "[ERROR] task-start.sh: please provide a task-name"
  echo "  Usage: ./scripts/task-start.sh <task-name>"
  exit 1
fi

BRANCH_NAME="${BRANCH_PREFIX:-feature}/${TASK_NAME}"
WORKTREE_PATH="${PROJECT_ROOT}/${WORKTREE_ROOT}/${TASK_NAME}"
SESSION_DIR="${PROJECT_ROOT}/${LOG_DIR}/sessions/${TASK_NAME}"
SESSION_LOG="${SESSION_DIR}/session.jsonl"

# =============================================================================
# 1. Check for existing worktree
# =============================================================================
if [[ -d "$WORKTREE_PATH" ]]; then
  echo "[WARN] Worktree already exists: $WORKTREE_PATH"
  echo "  Continuing with existing worktree."
  echo ""
  echo "[INFO] Worktree path: $WORKTREE_PATH"
  echo "[INFO] Session log: $SESSION_LOG"
  exit 0
fi

# =============================================================================
# 2. Create worktree
# =============================================================================
echo "[INFO] Creating worktree..."
echo "  Task:   $TASK_NAME"
echo "  Branch: $BRANCH_NAME"
echo "  Path:   $WORKTREE_PATH"
echo ""

mkdir -p "$(dirname "$WORKTREE_PATH")"
git -C "$PROJECT_ROOT" worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH"

# =============================================================================
# 3. Initialize session log
# =============================================================================
mkdir -p "$SESSION_DIR"

log_event() {
  echo "{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"$1\"$([ $# -gt 1 ] && echo ",$2" || echo "")}" >> "$SESSION_LOG"
}

log_event "task_start" \
  "\"task\":\"${TASK_NAME}\",\"branch\":\"${BRANCH_NAME}\",\"worktree\":\"${WORKTREE_PATH}\""

# =============================================================================
# 4. Auto-generate exec-plan skeleton
# =============================================================================
EXEC_PLAN_DIR="${PROJECT_ROOT}/docs/exec-plans/active"
EXEC_PLAN_FILE="${EXEC_PLAN_DIR}/${TASK_NAME}.md"

mkdir -p "$EXEC_PLAN_DIR"

if [[ ! -f "$EXEC_PLAN_FILE" ]]; then
  cat > "$EXEC_PLAN_FILE" << PLAN
---
task_id: ${TASK_NAME}
type: feat
status: in-progress
created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
owner: (author)
---

# ${TASK_NAME}

## Background and Goal

[Describe the task goal here]

## Implementation Steps

- [ ] 1. Assess impact scope (check related files)
- [ ] 2. Implement
- [ ] 3. Write/update tests
- [ ] 4. Validate with verify-task.sh
- [ ] 5. Merge with task-finish.sh

## Scope

[List affected layers/files]

## Completion Criteria

- [ ] All 5 validators pass
- [ ] Existing tests pass

## References

- ARCHITECTURE.md
- docs/golden-principles.md
- logs/trends/failure-patterns.md
PLAN

  log_event "exec_plan_created" "\"path\":\"${EXEC_PLAN_FILE}\""
  echo "[INFO] exec-plan created: $EXEC_PLAN_FILE"
else
  echo "[INFO] exec-plan already exists: $EXEC_PLAN_FILE"
fi

# =============================================================================
# 5. Failure patterns preview
# =============================================================================
FAILURE_PATTERNS="${PROJECT_ROOT}/${LOG_DIR}/trends/failure-patterns.md"
if [[ -f "$FAILURE_PATTERNS" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " [FEEDFORWARD] Review recent failure patterns:"
  echo " $FAILURE_PATTERNS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  # Preview key content (first 20 lines)
  head -20 "$FAILURE_PATTERNS"
  echo "  ..."
  echo ""
fi

# =============================================================================
# 6. Done
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " [SUCCESS] Worktree created"
echo ""
echo " Next steps:"
echo "   cd $WORKTREE_PATH   ← work in this directory"
echo ""
echo " When finished:"
echo "   cd $PROJECT_ROOT"
echo "   ./scripts/task-finish.sh $TASK_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
