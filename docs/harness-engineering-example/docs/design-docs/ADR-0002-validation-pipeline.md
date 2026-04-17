---
name: ADR-0002 5단계 검증 파이프라인
verification_status: active
last_verified: 2026-04-15
owner: team
---

# ADR-0002: 5단계 검증 파이프라인

## Context

코드 병합 전 검증이 선택적이면, 에이전트가 검증을 건너뛰거나
"나중에 고치겠다"며 문제 있는 코드를 병합할 수 있습니다.

## Decision

`task-finish.sh`가 5개 검증기를 순서대로 실행하며,
하나라도 실패하면 병합을 차단합니다.

| 순서 | 검증기 | 설정 변수 |
|------|--------|-----------|
| 1 | 01-build.sh (빌드) | `BUILD_CMD` |
| 2 | 02-test.sh (테스트) | `TEST_CMD` |
| 3 | 03-lint.sh (린트) | `LINT_CMD` |
| 4 | 04-security.sh (보안) | `SECURITY_SCAN_CMD` |
| 5 | 05-docs-freshness.sh (문서) | — |

각 검증기는 `harness.config.sh`의 설정을 읽으므로
프로젝트 언어/프레임워크에 무관하게 동작합니다.

## Consequences

**장점**:
- 검증 우회 불가 (task-finish.sh가 유일한 병합 경로)
- 에이전트용 오류 메시지 포함 → 자가 수정 가능
- 구현 중 반복 검증 가능 (`verify-task.sh`)

**단점**:
- 전체 검증에 시간 소요
- 검증기 자체의 버그 가능성

## Enforcement

- **스크립트**: `task-finish.sh` — 전부 통과해야 병합
- **스크립트**: `verify-task.sh` — 검증만 별도 실행 (병합 안 함)
- **설정**: `harness.config.sh` — `ENABLE_*_CHECK`로 개별 비활성화 가능
- **문서**: `docs/design-docs/core-beliefs.md` #2
- **golden-principles**: GP-004
