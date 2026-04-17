#!/usr/bin/env bash
# =============================================================================
# task-cleanup.sh — Clean up stale worktrees (run periodically by GC agent)
# Usage: ./scripts/task-cleanup.sh [--dry-run]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/harness.config.sh"

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " [task-cleanup] Worktree GC$([ "$DRY_RUN" = true ] && echo ' (DRY RUN)' || echo '')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

WORKTREE_ROOT_PATH="${PROJECT_ROOT}/${WORKTREE_ROOT}"

if [[ ! -d "$WORKTREE_ROOT_PATH" ]]; then
  echo " No worktree directory found: $WORKTREE_ROOT_PATH"
  echo " Nothing to clean up."
  exit 0
fi

# Check current worktree status
echo " Current worktrees:"
git -C "$PROJECT_ROOT" worktree list
echo ""

CLEANED=0
KEPT=0

for worktree_path in "$WORKTREE_ROOT_PATH"/*/; do
  [[ -d "$worktree_path" ]] || continue

  task_name="$(basename "$worktree_path")"
  branch_name="${BRANCH_PREFIX:-feature}/${task_name}"

  # Branch already merged/deleted
  if ! git -C "$PROJECT_ROOT" rev-parse --verify "$branch_name" &>/dev/null; then
    echo " [STALE] $task_name — branch not found, marked for removal"
    if [[ "$DRY_RUN" == "false" ]]; then
      git -C "$PROJECT_ROOT" worktree remove --force "$worktree_path" 2>/dev/null || rm -rf "$worktree_path"
      echo "         → removed"
    fi
    (( CLEANED++ )) || true
    continue
  fi

  # Check for recently modified source files (within 7 days)
  recent_file=$(find "$worktree_path" \( -name "*.kt" -o -name "*.ts" -o -name "*.py" -o -name "*.java" \) -mtime -7 2>/dev/null | head -1)
  if [[ -z "$recent_file" ]]; then
    echo " [IDLE]  $task_name — inactive for 7+ days (consider cleanup)"
    (( KEPT++ )) || true
  else
    echo " [ACTIVE] $task_name — work in progress (preserved)"
    (( KEPT++ )) || true
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Result: removed $CLEANED / preserved $KEPT"
[ "$DRY_RUN" = true ] && echo " (DRY RUN — no actual removal)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
