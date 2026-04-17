#!/usr/bin/env bash
# =============================================================================
# harness.config.sh
# 프로젝트별 하네스 설정 — 언어/빌드툴에 맞게 이 파일만 수정하세요
# =============================================================================

# 프로젝트 이름 (로그, 워크트리 경로에 사용)
PROJECT_NAME="my-project"

# =============================================================================
# Git Flow 설정
# =============================================================================

# upstream remote 이름 (fork 기반이면 "upstream", 단일 리포면 "origin")
GIT_REMOTE="upstream"

# 병합 방식 ("pr" = push 후 PR 생성, "direct" = 로컬에서 직접 merge)
MERGE_STRATEGY="pr"

# 단계별 base 브랜치
PHASE_DEVELOP_BASE="develop"           # 개발: upstream/develop 기반
PHASE_RELEASE_BASE=""                  # QA: release/x.x.x (매번 다르므로 빈 값 → 사용자에게 물어봄)
PHASE_HOTFIX_BASE="main"              # 핫픽스: upstream/main 기반

# =============================================================================
# 브랜치 & 커밋 규칙 — 프로젝트에 맞게 수정하세요
# =============================================================================

# 기본 브랜치 (스크립트 하위 호환용 — /harness-task가 단계에 따라 덮어씀)
BASE_BRANCH="develop"

# 브랜치 네이밍 (task-start.sh가 사용)
BRANCH_PREFIX="feature"            # feature/<task-id> 형태로 생성됨

# 커밋 메시지 규칙 (Conventional Commits)
# task type이 커밋 prefix가 됨: feat, fix, refactor, chore, docs
# 예: "feat: PROJ-101 Todo 필터 기능 추가"
COMMIT_TEMPLATE="<type>: <task-id> <요약>"

# PR 규칙 — /harness-task가 PR 안내 시 사용
PR_TITLE_TEMPLATE="<type>: <task-id> <요약>"
# PR_BODY_TEMPLATE=""              # 비워두면 exec-plan 내용을 자동으로 채움
# PR_REVIEWERS=""                  # 예: "팀원1,팀원2" (비워두면 안내하지 않음)
# PR_LABELS=""                     # 예: "feature,backend" (비워두면 안내하지 않음)

# 워크트리 루트 디렉토리
WORKTREE_ROOT=".worktrees"

# 로그 디렉토리
LOG_DIR="./logs"

# =============================================================================
# 빌드/테스트/린트 커맨드 — 프로젝트 언어에 맞게 설정
# =============================================================================

# --- Kotlin / Spring Boot ---
# BUILD_CMD="./gradlew build -x test"
# TEST_CMD="./gradlew test"
# LINT_CMD="./gradlew ktlintCheck"

# --- Java / Maven ---
# BUILD_CMD="mvn compile -q"
# TEST_CMD="mvn test"
# LINT_CMD="mvn checkstyle:check"

# --- TypeScript / Node.js ---
# BUILD_CMD="npm run build"
# TEST_CMD="npm test"
# LINT_CMD="npm run lint"

# --- Python ---
# BUILD_CMD="pip install -r requirements.txt -q"
# TEST_CMD="pytest"
# LINT_CMD="ruff check ."

# --- Go ---
# BUILD_CMD="go build ./..."
# TEST_CMD="go test ./..."
# LINT_CMD="golangci-lint run"

# 기본값 (미설정 시 사용)
BUILD_CMD="${BUILD_CMD:-echo '[SKIP] BUILD_CMD not configured'}"
TEST_CMD="${TEST_CMD:-echo '[SKIP] TEST_CMD not configured'}"
LINT_CMD="${LINT_CMD:-echo '[SKIP] LINT_CMD not configured'}"

# =============================================================================
# 보안 스캔 설정
# =============================================================================

# gitleaks 사용 (설치 필요: brew install gitleaks)
SECURITY_SCAN_CMD="${SECURITY_SCAN_CMD:-gitleaks detect --source . --no-git 2>/dev/null || true}"

# =============================================================================
# 검증기 활성화 여부 (true/false)
# =============================================================================
ENABLE_BUILD_CHECK="${ENABLE_BUILD_CHECK:-true}"
ENABLE_TEST_CHECK="${ENABLE_TEST_CHECK:-true}"
ENABLE_LINT_CHECK="${ENABLE_LINT_CHECK:-true}"
ENABLE_SECURITY_CHECK="${ENABLE_SECURITY_CHECK:-true}"
ENABLE_DOCS_CHECK="${ENABLE_DOCS_CHECK:-true}"

# =============================================================================
# 아키텍처 레이어 규칙 (ARCHITECTURE.md에 상세 정의)
# =============================================================================
ARCHITECTURE_DOC="ARCHITECTURE.md"
