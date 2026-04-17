# Escalation Policy — 사람 승인이 필요한 변경

에이전트가 **절대 단독으로 진행하면 안 되는** 변경 목록입니다.
아래 카테고리에 해당하는 변경은 반드시 사람의 승인을 받은 후 진행합니다.

---

## 고위험 카테고리

### 1. 데이터베이스 스키마 변경

- 테이블 생성/삭제, 컬럼 변경, 인덱스 추가/삭제
- 마이그레이션 파일 (Flyway, Liquibase, SQL 등)
- ORM 엔티티 매핑 변경

### 2. 인증 / 인가 로직

- 로그인, 세션, 토큰 관련 코드 변경
- 권한 체크 (RBAC, ACL) 로직 변경
- OAuth, SSO 연동 변경

### 3. 보안 설정

- 시크릿, 환경 변수, 인증서 관련 설정
- CORS, CSP, 보안 헤더 변경
- 의존성의 보안 패치 (major version)

### 4. 결제 / 과금

- 결제 SDK 연동 변경
- 금액 계산 로직 변경
- 웹훅 서명 검증 로직

### 5. 외부 API 연동

- 새 외부 서비스 연동 추가
- API 키, 엔드포인트 변경
- Rate limit, 타임아웃 설정 변경

### 6. 빌드 / 배포

- CI/CD 파이프라인 변경
- Dockerfile, K8s manifest 변경
- 배포 스크립트 변경

### 7. 하네스 자체 변경

- 검증기 비활성화 또는 규칙 완화
- CLAUDE.md, golden-principles.md 수정
- pre-edit hook 비활성화

---

## 절차

1. **exec-plan 작성**: `docs/exec-plans/active/<type>-<task-id>.md`에 아래 포함:
   - **Impact**: 이 변경이 영향을 주는 범위
   - **Rollback**: 문제 발생 시 되돌리는 방법
   - **Verification**: 정상 동작 확인 방법

2. **사람 승인**: exec-plan을 사람에게 보여주고 승인 받기

3. **진행**: 승인 후 워크트리에서 구현 → task-finish.sh

4. **긴급 변경**: 승인 없이 진행한 경우 24시간 내 회고 + agent-failures.md 기록

---

## 참고

- 핵심 원칙: `docs/design-docs/core-beliefs.md`
- 실패 기록: `docs/agent-failures.md`
