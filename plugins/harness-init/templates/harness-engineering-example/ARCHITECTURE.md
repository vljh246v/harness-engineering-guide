# ARCHITECTURE.md

This file defines the project's layer structure and dependency rules.
The 03-lint.sh validator enforces these rules mechanically.

## Layer Structure

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

## Dependency Direction Rules {#layer-rules}

```
Allowed: API → Application → Domain ← Infrastructure
Forbidden: Domain → Application
Forbidden: Domain → Infrastructure
Forbidden: Application → API
```

**Core principle**: The Domain layer has no outward dependencies.
Infrastructure implements Domain's Port interfaces.

## Package Structure (Kotlin/Spring Example)

```
src/main/kotlin/com/example/
├── api/
│   ├── controller/     # HTTP entry point
│   ├── dto/            # Request/response DTOs
│   └── exception/      # Global exception handling
├── application/
│   └── service/        # Use case orchestration
├── domain/
│   ├── model/          # Business entities
│   ├── port/           # External dependency interfaces
│   └── service/        # Domain logic
└── infrastructure/
    ├── db/             # DB adapters
    ├── external/       # External API adapters
    └── config/         # Configuration
```

## Validator Error Message Example

```
[ARCHITECTURE VIOLATION] src/domain/service/UserDomainService.kt:12
  The domain/ layer is directly importing from the infrastructure/ layer.

  Allowed direction: domain ← infrastructure (via Port interfaces)

  How to fix:
  1. Define an interface in domain/port/
     e.g.: interface UserRepository { fun findById(id: Long): User? }
  2. Implement the interface in infrastructure/db/
  3. In domain/service/, depend only on the Port interface
```

## Cross-Cutting Concerns

Cross-cutting concerns that span layers are handled through **Provider interfaces**:
- Auth (AuthProvider)
- Cache (CacheProvider)
- Event publishing (EventPublisher)
- Feature flags (FeatureFlagProvider)
