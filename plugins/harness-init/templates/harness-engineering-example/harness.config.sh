#!/usr/bin/env bash
# =============================================================================
# harness.config.sh
# Project-level harness configuration — edit this file for your language/build tool
# =============================================================================

# Project name (used in logs, worktree paths)
PROJECT_NAME="my-project"

# =============================================================================
# Git Flow Settings
# =============================================================================

# upstream remote name ("upstream" for fork-based, "origin" for single-repo)
GIT_REMOTE="upstream"

# Merge strategy ("pr" = push then create PR, "direct" = merge locally)
MERGE_STRATEGY="pr"

# Phase-specific base branches
PHASE_DEVELOP_BASE="develop"           # Development: based on upstream/develop
PHASE_RELEASE_BASE=""                  # QA: release/x.x.x (varies per release, empty = prompt user)
PHASE_HOTFIX_BASE="main"              # Hotfix: based on upstream/main

# =============================================================================
# Branch & Commit Rules — adjust for your project
# =============================================================================

# Default branch (backward compat for scripts — /harness-task overrides per phase)
BASE_BRANCH="develop"

# Branch naming (used by task-start.sh)
BRANCH_PREFIX="feature"            # Creates feature/<task-id> branches

# Commit message rules (Conventional Commits)
# Task type becomes the commit prefix: feat, fix, refactor, chore, docs
# Example: "feat: PROJ-101 Add todo filter feature"
COMMIT_TEMPLATE="<type>: <task-id> <summary>"

# PR rules — used by /harness-task when guiding PR creation
PR_TITLE_TEMPLATE="<type>: <task-id> <summary>"
# PR_BODY_TEMPLATE=""              # Leave empty to auto-fill from exec-plan
# PR_REVIEWERS=""                  # e.g. "alice,bob" (leave empty to skip)
# PR_LABELS=""                     # e.g. "feature,backend" (leave empty to skip)

# Worktree root directory
WORKTREE_ROOT=".worktrees"

# Log directory
LOG_DIR="./logs"

# =============================================================================
# Build/Test/Lint Commands — set for your project language
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

# Defaults (used when not configured)
BUILD_CMD="${BUILD_CMD:-echo '[SKIP] BUILD_CMD not configured'}"
TEST_CMD="${TEST_CMD:-echo '[SKIP] TEST_CMD not configured'}"
LINT_CMD="${LINT_CMD:-echo '[SKIP] LINT_CMD not configured'}"

# =============================================================================
# Security Scan Settings
# =============================================================================

# gitleaks (install: brew install gitleaks)
SECURITY_SCAN_CMD="${SECURITY_SCAN_CMD:-gitleaks detect --source . --no-git 2>/dev/null || true}"

# =============================================================================
# Validator Toggles (true/false)
# =============================================================================
ENABLE_BUILD_CHECK="${ENABLE_BUILD_CHECK:-true}"
ENABLE_TEST_CHECK="${ENABLE_TEST_CHECK:-true}"
ENABLE_LINT_CHECK="${ENABLE_LINT_CHECK:-true}"
ENABLE_SECURITY_CHECK="${ENABLE_SECURITY_CHECK:-true}"
ENABLE_DOCS_CHECK="${ENABLE_DOCS_CHECK:-true}"

# =============================================================================
# Architecture Layer Rules (detailed in ARCHITECTURE.md)
# =============================================================================
ARCHITECTURE_DOC="ARCHITECTURE.md"
