# CLAUDE.md — harness-demo-kotlin

에이전트를 위한 지도(Map). 이 파일은 100줄 이하를 유지합니다.

## 프로젝트

Todo 관리 REST API (Spring Boot + Kotlin). 하네스 엔지니어링 데모 프로젝트.

## 작업 유형별 진입점

| 작업 | 먼저 읽을 문서 |
|------|---------------|
| 새 기능 추가 | `ARCHITECTURE.md` → `docs/golden-principles.md` |
| 버그 수정 | `logs/trends/failure-patterns.md` → `docs/agent-failures.md` |
| 리팩터링 | `ARCHITECTURE.md` → `docs/design-docs/index.md` |
| 고위험 변경 | `docs/escalation-policy.md` → 사람 승인 필수 |
| 하네스 개선 | `docs/design-docs/core-beliefs.md` → `docs/golden-principles.md` |

## 개발 플로우

브랜치: `develop` (base) → `feature/<TICKET_KEY>`  
**main / develop 브랜치 직접 수정 금지**

```
task-start.sh → (exec-plan 자동 생성) → 구현 → verify-task.sh → task-finish.sh
```

- 시작: `./scripts/task-start.sh <task-id>`
- 중간 검증: `./scripts/verify-task.sh <task-id>`
- 완료: `./scripts/task-finish.sh <task-id>`

## 빌드 & 테스트

설정: `harness.config.sh`

```bash
./gradlew compileKotlin compileTestKotlin   # 빌드
./gradlew test                               # 테스트
./gradlew ktlintCheck                        # 린트
```

## 핵심 문서

| 문서 | 역할 |
|------|------|
| `ARCHITECTURE.md` | 레이어: controller → service → repository → domain |
| `docs/design-docs/core-beliefs.md` | 팀 핵심 원칙 |
| `docs/golden-principles.md` | 실패에서 승격된 규칙 (GP-001~) |
| `docs/agent-failures.md` | 에이전트 실패 로그 + 재발 방지 |
| `docs/escalation-policy.md` | 사람 승인 필수 변경 목록 |
| `docs/design-docs/index.md` | ADR 목록 + 템플릿 |
| `docs/QUALITY_SCORE.md` | 도메인별 품질 현황 |
| `docs/exec-plans/active/` | 진행 중인 작업 계획 |

## 금지 사항

→ `docs/golden-principles.md` 참고

## 로그

- 세션: `logs/sessions/<task>/session.jsonl`
- 실패 패턴: `logs/trends/failure-patterns.md`
- 검증 이력: `logs/validators/history.jsonl`
