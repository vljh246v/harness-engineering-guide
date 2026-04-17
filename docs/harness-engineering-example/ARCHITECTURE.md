# ARCHITECTURE.md

이 파일은 프로젝트의 레이어 구조와 의존성 규칙을 정의합니다.
03-lint.sh 검증기가 이 규칙을 기계적으로 강제합니다.

## 레이어 구조

```
┌─────────────────────────────────────────────────────────────┐
│                        API Layer                            │
│              (Controller, DTO, Exception)                   │
├─────────────────────────────────────────────────────────────┤
│                    Application Layer                        │
│                      (Service)                              │
├─────────────────────────────────────────────────────────────┤
│                      Domain Layer                           │
│                (Model, Port, DomainService)                 │
├─────────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                       │
│           (Adapter, Repository, Config, External)           │
└─────────────────────────────────────────────────────────────┘
```

## 의존성 방향 규칙 {#layer-rules}

```
허용: API → Application → Domain ← Infrastructure
금지: Domain → Application
금지: Domain → Infrastructure
금지: Application → API
```

**핵심 원칙**: Domain 레이어는 외부에 의존하지 않습니다.
Infrastructure는 Domain의 Port 인터페이스를 구현합니다.

## 패키지 구조 (Kotlin/Spring 예시)

```
src/main/kotlin/com/example/
├── api/
│   ├── controller/     # HTTP 진입점
│   ├── dto/            # 요청/응답 DTO
│   └── exception/      # 전역 예외 처리
├── application/
│   └── service/        # 유스케이스 조합
├── domain/
│   ├── model/          # 비즈니스 엔티티
│   ├── port/           # 외부 의존성 인터페이스
│   └── service/        # 도메인 로직
└── infrastructure/
    ├── db/             # DB 어댑터
    ├── external/       # 외부 API 어댑터
    └── config/         # 설정
```

## 검증기 오류 메시지 예시

```
[ARCHITECTURE VIOLATION] src/domain/service/UserDomainService.kt:12
  domain/ 레이어에서 infrastructure/ 레이어를 직접 import하고 있습니다.

  허용된 방향: domain ← infrastructure (Port 인터페이스를 통해)

  수정 방법:
  1. domain/port/ 에 인터페이스를 정의하세요
     예: interface UserRepository { fun findById(id: Long): User? }
  2. infrastructure/db/ 에서 해당 인터페이스를 구현하세요
  3. domain/service/에서는 Port 인터페이스만 의존하세요
```

## Cross-Cutting Concerns

레이어를 가로지르는 공통 관심사는 **Providers 인터페이스**를 통해 처리합니다:
- 인증/인가 (AuthProvider)
- 캐시 (CacheProvider)
- 이벤트 발행 (EventPublisher)
- 피처 플래그 (FeatureFlagProvider)
