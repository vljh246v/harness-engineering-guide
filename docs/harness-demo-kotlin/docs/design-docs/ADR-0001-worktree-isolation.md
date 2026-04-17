---
name: ADR-0001 워크트리 격리 원칙
verification_status: active
last_verified: 2026-04-15
owner: team
---

# ADR-0001: 워크트리 격리 원칙

## Context

에이전트와 사람 모두 develop/main 브랜치에서 직접 작업할 경우,
실수가 즉시 기본 브랜치를 오염시킵니다.
병렬 작업 시 충돌 위험도 높아집니다.

## Decision

모든 작업은 `task-start.sh`로 생성한 git worktree에서 수행합니다.
기본 브랜치 직접 수정을 금지합니다.

## Consequences

**장점**:
- 실수의 영향 범위가 워크트리에 국한됨
- 병렬 작업 가능 (독립 워크트리)
- 실패 시 워크트리 보존 → 디버깅 가능

**단점**:
- 워크트리 생성/삭제 오버헤드
- 디스크 사용량 증가

## Enforcement

- **훅**: `.claude/hooks/pre-tool-use.sh` — 워크트리 밖 src/ 수정 시 경고
- **스크립트**: `task-finish.sh` — 검증 통과 없이 병합 불가
- **문서**: `docs/design-docs/core-beliefs.md` #1
- **golden-principles**: GP-001
