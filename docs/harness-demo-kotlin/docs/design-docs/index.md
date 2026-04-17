# Architecture Decision Records (ADR)

구조적 결정과 그 근거를 기록합니다.

## ADR 목록

| ID | 제목 | 상태 | 최종 검증 |
|----|------|------|-----------|
| ADR-0001 | [워크트리 격리 원칙](ADR-0001-worktree-isolation.md) | 적용 중 | — |
| ADR-0002 | [5단계 검증 파이프라인](ADR-0002-validation-pipeline.md) | 적용 중 | — |

## 새 ADR 작성

1. `ADR-{N+1}-{kebab-case-제목}.md` 파일 생성
2. 아래 템플릿 사용
3. 이 index.md에 행 추가

## 템플릿

```markdown
---
name: ADR-XXXX 제목
verification_status: draft | active | superseded
last_verified: YYYY-MM-DD
owner: (작성자)
---

# ADR-XXXX: 제목

## Context

왜 이 결정이 필요한가?

## Decision

무엇을 결정했는가?

## Consequences

이 결정의 장단점은?

## Enforcement

이 결정은 어떻게 강제되는가?

- 검증기: (해당 validator 이름)
- 린트 규칙: (해당 규칙명)
- 훅: (해당 hook)
- 문서: (관련 docs/ 경로)
```
