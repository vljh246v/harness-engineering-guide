#!/usr/bin/env bash
# =============================================================================
# setup.sh — 최초 1회 실행 (Gradle wrapper 생성 + git 초기화)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " harness-demo-kotlin 초기 설정"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Gradle wrapper JAR 생성
if [[ ! -f "gradle/wrapper/gradle-wrapper.jar" ]]; then
  echo "[1/3] Gradle wrapper 생성 중..."
  if command -v gradle &>/dev/null; then
    gradle wrapper --gradle-version 8.7 --quiet
    echo "      완료"
  else
    echo "[ERROR] gradle이 설치되어 있지 않습니다."
    echo "        brew install gradle 또는 sdk install gradle"
    exit 1
  fi
else
  echo "[1/3] Gradle wrapper 이미 존재함 — 건너뜀"
fi

chmod +x gradlew

# 2. git 초기화
if [[ ! -d ".git" ]]; then
  echo "[2/3] git 초기화 중..."
  git init
  git checkout -b develop 2>/dev/null || git checkout -b develop
  git add .
  git commit -m "chore: 초기 프로젝트 설정"
  echo "      완료 (develop 브랜치 생성)"
else
  echo "[2/3] git 이미 초기화됨 — 건너뜀"
fi

# 3. 스크립트 실행 권한
echo "[3/3] 스크립트 권한 설정..."
find scripts -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
find .claude/hooks -name "*.sh" -exec chmod +x {} + 2>/dev/null || true
echo "      완료"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 설정 완료!"
echo ""
echo " 다음 단계:"
echo "   ./scripts/task-start.sh PROJ-101   # 워크트리 생성"
echo "   /harness-task PROJ-101             # 스킬로 작업 시작"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
