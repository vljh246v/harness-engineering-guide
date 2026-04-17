#!/usr/bin/env bash
# =============================================================================
# 04-security.sh — Secret/vulnerability scan (language-agnostic)
# Args: $1=worktree path, $2=project root
#
# Tools (priority order):
#   1. gitleaks (brew install gitleaks)
#   2. truffleHog
#   3. Direct pattern matching (fallback)
# =============================================================================
set -euo pipefail

WORKTREE_PATH="${1:-$(pwd)}"
PROJECT_ROOT="${2:-$(pwd)}"

source "$PROJECT_ROOT/harness.config.sh"

if [[ "$ENABLE_SECURITY_CHECK" != "true" ]]; then
  echo "[SKIP] Security check disabled (ENABLE_SECURITY_CHECK=false)"
  exit 0
fi

echo "[SECURITY] Running security scan..."
echo "  Path: $WORKTREE_PATH"

cd "$WORKTREE_PATH"

ISSUES_FOUND=0
ISSUES_DETAIL=""

# =============================================================================
# 1. Secret scan with gitleaks
# =============================================================================
if command -v gitleaks &>/dev/null; then
  echo "  Tool: gitleaks"
  output=$(gitleaks detect --source . --no-git --exit-code 1 2>&1 || true)
  if echo "$output" | grep -q "leaks found"; then
    ISSUES_FOUND=1
    ISSUES_DETAIL="${ISSUES_DETAIL}\n  [gitleaks]\n$(echo "$output" | sed 's/^/    /')"
  fi
else
  # Fallback: direct pattern matching
  echo "  Tool: pattern matching (gitleaks not installed)"

  # Hardcoded password/token patterns
  patterns=(
    "password\s*=\s*['\"][^'\"]{8,}"
    "secret\s*=\s*['\"][^'\"]{8,}"
    "api_key\s*=\s*['\"][^'\"]{8,}"
    "private_key\s*=\s*-----BEGIN"
    "-----BEGIN RSA PRIVATE KEY-----"
    "-----BEGIN EC PRIVATE KEY-----"
  )

  for pattern in "${patterns[@]}"; do
    matches=$(grep -rn --include="*.kt" --include="*.java" --include="*.ts" --include="*.py" \
      --include="*.yaml" --include="*.yml" --include="*.json" \
      --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="build" \
      -E "$pattern" . 2>/dev/null || true)
    if [[ -n "$matches" ]]; then
      ISSUES_FOUND=1
      ISSUES_DETAIL="${ISSUES_DETAIL}\n  Pattern: $pattern\n$(echo "$matches" | head -5 | sed 's/^/    /')"
    fi
  done
fi

# =============================================================================
# 2. Detect .env files in git (committed or staged)
# =============================================================================
# Check .env files already committed to git
tracked_env=$(git ls-files 2>/dev/null | grep -E "\.env$|\.env\." || true)
# Check .env files staged but not yet committed
staged_env=$(git diff --cached --name-only 2>/dev/null | grep -E "\.env$|\.env\." || true)

env_files="${tracked_env}${tracked_env:+$'\n'}${staged_env}"
env_files=$(echo "$env_files" | sort -u | grep -v '^$' || true)

if [[ -n "$env_files" ]]; then
  ISSUES_FOUND=1
  ISSUES_DETAIL="${ISSUES_DETAIL}\n  [WARNING] .env files found in git:\n$(echo "$env_files" | sed 's/^/    /')"
fi

# =============================================================================
# Result
# =============================================================================
if [[ $ISSUES_FOUND -ne 0 ]]; then
  cat <<EOF

[SECURITY FAILURE] validators/04-security.sh

  Security issues found:
$(echo -e "$ISSUES_DETAIL")

  How to fix:
  1. Move hardcoded secrets to environment variables or a secrets manager
     e.g.: System.getenv("API_KEY"), os.environ["API_KEY"]
  2. Add .env files to .gitignore
  3. If already committed: git history cleanup is needed (notify the team)

  Recommendations:
  - Add .env* pattern to .gitignore
  - Use: Vault, AWS Secrets Manager, or environment variables

EOF
  exit 1
fi

echo "[SECURITY] Security scan passed"
