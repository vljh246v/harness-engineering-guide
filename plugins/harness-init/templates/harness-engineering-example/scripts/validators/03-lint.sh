#!/usr/bin/env bash
# =============================================================================
# 03-lint.sh — Lint check (code style + architecture rules)
# Args: $1=worktree path, $2=project root
# =============================================================================
set -euo pipefail

WORKTREE_PATH="${1:-$(pwd)}"
PROJECT_ROOT="${2:-$(pwd)}"

source "$PROJECT_ROOT/harness.config.sh"

if [[ "$ENABLE_LINT_CHECK" != "true" ]]; then
  echo "[SKIP] Lint check disabled (ENABLE_LINT_CHECK=false)"
  exit 0
fi

echo "[LINT] Running lint..."
echo "  Command: $LINT_CMD"
echo "  Path:    $WORKTREE_PATH"

cd "$WORKTREE_PATH"

set +e
output=$(eval "$LINT_CMD" 2>&1)
exit_code=$?
set -e

if [[ $exit_code -ne 0 ]]; then
  cat <<EOF

[LINT FAILURE] validators/03-lint.sh
  Command: $LINT_CMD
  Exit code: $exit_code

  Lint errors:
$(echo "$output" | head -40 | sed 's/^/  /')

  How to fix:
  1. Check the files and line numbers above
  2. For auto-fixable issues:
     - Kotlin: ./gradlew ktlintFormat
     - TypeScript: npm run lint -- --fix
     - Python: ruff check . --fix
  3. For architecture violations: see ARCHITECTURE.md#layer-rules

  Lint config locations:
  - Kotlin: .editorconfig, ktlint settings
  - TypeScript: .eslintrc, tsconfig.json
  - Python: pyproject.toml [tool.ruff]

EOF
  exit 1
fi

echo "[LINT] Lint passed"
