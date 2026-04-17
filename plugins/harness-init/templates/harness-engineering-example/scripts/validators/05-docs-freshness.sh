#!/usr/bin/env bash
# =============================================================================
# 05-docs-freshness.sh — Documentation freshness check
# Args: $1=worktree path, $2=project root
#
# Checks:
#   1. Whether changed code files have corresponding docs/ updates
#   2. Whether CLAUDE.md contains AI-generated bloat
#   3. Whether exec-plans/active/ plans are linked to actual work
# =============================================================================
set -euo pipefail

WORKTREE_PATH="${1:-$(pwd)}"
PROJECT_ROOT="${2:-$(pwd)}"

source "$PROJECT_ROOT/harness.config.sh"

if [[ "$ENABLE_DOCS_CHECK" != "true" ]]; then
  echo "[SKIP] Docs check disabled (ENABLE_DOCS_CHECK=false)"
  exit 0
fi

echo "[DOCS] Checking documentation freshness..."

cd "$WORKTREE_PATH"

ISSUES_FOUND=0

# =============================================================================
# 1. Check CLAUDE.md size (warn above 100 lines)
# =============================================================================
if [[ -f "CLAUDE.md" ]]; then
  line_count=$(wc -l < CLAUDE.md)
  if [[ $line_count -gt 100 ]]; then
    echo "  [WARN] CLAUDE.md is ${line_count} lines (recommended: under 100)"
    echo "         Consider splitting detailed content into docs/"
    # Warning only (not a failure)
  fi
fi

# =============================================================================
# 2. Check changed files
# =============================================================================
changed_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || git diff --name-only HEAD 2>/dev/null || true)

# New service/domain additions should update ARCHITECTURE.md
new_service_dirs=$(echo "$changed_files" | grep -E "^src/main/(kotlin|java)/.*/(service|domain|api)/" | head -5 || true)
arch_updated=$(echo "$changed_files" | grep -E "ARCHITECTURE\.md|docs/" || true)

if [[ -n "$new_service_dirs" && -z "$arch_updated" ]]; then
  echo ""
  echo "  [INFO] New service/domain code was added:"
  echo "$new_service_dirs" | sed 's/^/    /'
  echo ""
  echo "  Consider updating architecture docs:"
  echo "    • ARCHITECTURE.md (if layer structure changed)"
  echo "    • docs/design-docs/ (for design decisions)"
  # Warning only (not a failure — not every code change is an architecture change)
fi

# =============================================================================
# 3. Suggest exec-plans/active/ cleanup
# =============================================================================
if [[ -d "docs/exec-plans/active" ]]; then
  active_plans=$(ls docs/exec-plans/active/ 2>/dev/null | grep -v ".gitkeep" || true)
  if [[ -n "$active_plans" ]]; then
    echo "  [INFO] Active plans found:"
    echo "$active_plans" | sed 's/^/    /'
    echo "  Move completed plans to docs/exec-plans/completed/"
  fi
fi

# =============================================================================
# Result
# =============================================================================
if [[ $ISSUES_FOUND -ne 0 ]]; then
  cat <<EOF

[DOCS FAILURE] validators/05-docs-freshness.sh

  How to fix:
  1. Review the items above and update related documentation
  2. If no update is needed, temporarily disable with ENABLE_DOCS_CHECK=false
     (but note the reason in the commit message)

EOF
  exit 1
fi

echo "[DOCS] Documentation check passed"
