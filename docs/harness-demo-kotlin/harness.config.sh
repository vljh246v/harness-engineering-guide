#!/usr/bin/env bash
# =============================================================================
# harness.config.sh — Kotlin / Spring Boot 프로젝트 하네스 설정
# =============================================================================

PROJECT_NAME="harness-demo-kotlin"

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
# 브랜치 & 커밋 규칙
# =============================================================================

# 기본 브랜치 (스크립트 하위 호환용 — /harness-task가 단계에 따라 덮어씀)
BASE_BRANCH="develop"

# 브랜치 네이밍 (task-start.sh가 사용)
BRANCH_PREFIX="feature"            # feature/<task-id> 형태로 생성됨

# 커밋 메시지 규칙 (Conventional Commits)
COMMIT_TEMPLATE="<type>: <task-id> <요약>"

# PR 규칙
PR_TITLE_TEMPLATE="<type>: <task-id> <요약>"
# PR_BODY_TEMPLATE=""              # 비워두면 exec-plan 내용을 자동으로 채움
# PR_REVIEWERS=""                  # 예: "팀원1,팀원2"
# PR_LABELS=""                     # 예: "feature,backend"

# 워크트리 루트 (프로젝트 내부)
WORKTREE_ROOT=".worktrees"

# 로그 디렉토리
LOG_DIR="logs"

# =============================================================================
# 빌드/테스트/린트 커맨드
# =============================================================================
BUILD_CMD="./gradlew compileKotlin compileTestKotlin --quiet"
TEST_CMD="./gradlew test"
LINT_CMD="./gradlew ktlintCheck"

# =============================================================================
# 보안 스캔
# =============================================================================
SECURITY_SCAN_CMD="${SECURITY_SCAN_CMD:-gitleaks detect --source . --no-git 2>/dev/null || true}"

# =============================================================================
# 검증기 활성화 여부
# =============================================================================
ENABLE_BUILD_CHECK="${ENABLE_BUILD_CHECK:-true}"
ENABLE_TEST_CHECK="${ENABLE_TEST_CHECK:-true}"
ENABLE_LINT_CHECK="${ENABLE_LINT_CHECK:-true}"
ENABLE_SECURITY_CHECK="${ENABLE_SECURITY_CHECK:-true}"
ENABLE_DOCS_CHECK="${ENABLE_DOCS_CHECK:-true}"

# =============================================================================
# 아키텍처 문서
# =============================================================================
ARCHITECTURE_DOC="ARCHITECTURE.md"
