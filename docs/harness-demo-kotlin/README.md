# harness-demo-kotlin

Spring Boot + Kotlin 기반 하네스 엔지니어링 데모 프로젝트.

---

## 폴더 구조

```
harness-demo-kotlin/
│
├── harness.config.sh               ← 프로젝트 설정 (빌드 커맨드, Git Flow, 검증기)
├── CLAUDE.md                       ← 에이전트 진입점 (목차 역할, 100줄 이하)
├── ARCHITECTURE.md                 ← 레이어 규칙
│
├── .claude/
│   ├── settings.json               ← 훅 연결, 권한, 스킬 등록
│   ├── hooks/
│   │   ├── pre-tool-use.sh         ← 워크트리 밖 수정 경고, 위험 명령 차단
│   │   └── post-tool-use.sh        ← 세션 로그 기록, 빠른 린트
│   └── skills/
│       └── harness-task/SKILL.md   ← /harness-task 스킬 (전체 플로우 자동화)
│
├── scripts/
│   ├── task-start.sh               ← 워크트리 생성 + exec-plan 스켈레톤
│   ├── verify-task.sh              ← 검증만 (병합 안 함, 구현 중 반복 실행)
│   ├── task-finish.sh              ← 검증 + 병합 + exec-plan 아카이브
│   ├── task-cleanup.sh             ← 스테일 워크트리 GC
│   └── validators/
│       ├── 01-build.sh
│       ├── 02-test.sh
│       ├── 03-lint.sh
│       ├── 04-security.sh
│       └── 05-docs-freshness.sh
│
├── docs/
│   ├── design-docs/
│   │   ├── index.md                ← ADR 목록 + 템플릿
│   │   ├── core-beliefs.md         ← 팀 핵심 원칙
│   │   ├── ADR-0001-*.md           ← 구조적 결정 + Enforcement
│   │   └── ADR-0002-*.md
│   ├── golden-principles.md        ← 실패에서 승격된 규칙 (GP-001~)
│   ├── agent-failures.md           ← 에이전트 실패 로그 (재발 방지 루프)
│   ├── escalation-policy.md        ← 사람 승인 필수 변경 목록
│   ├── playbooks/                  ← 반복 작업 레시피
│   ├── exec-plans/
│   │   ├── active/                 ← 진행 중 계획 (task-start.sh가 자동 생성)
│   │   ├── completed/              ← 완료된 계획 (task-finish.sh가 자동 이동)
│   │   └── tech-debt-tracker.md    ← 기술 부채 추적
│   └── QUALITY_SCORE.md
│
├── logs/
│   ├── sessions/                   ← 세션 로그 (로컬, gitignore)
│   ├── validators/history.jsonl    ← 검증 이력 (git 추적)
│   └── trends/failure-patterns.md  ← 실패 패턴 (git 추적)
│
└── agents/                         ← Planner/Generator/Evaluator/GC 역할 정의
```

---

## harness.config.sh — 설정의 중심

이 파일 하나에 프로젝트별 설정이 모여 있습니다. 검증기, 스크립트, 훅이 전부 이 파일을 읽습니다.

### 빌드/테스트/린트

```bash
BUILD_CMD="./gradlew compileKotlin compileTestKotlin --quiet"
TEST_CMD="./gradlew test"
LINT_CMD="./gradlew ktlintCheck"
```

다른 언어 프로젝트에 적용할 때는 이 세 줄만 바꾸면 됩니다.

### Git Flow 설정

```bash
GIT_REMOTE="upstream"              # fork 기반이면 upstream, 단일 리포면 origin
MERGE_STRATEGY="pr"                # "pr" = push 후 PR 생성 / "direct" = 로컬 직접 병합

PHASE_DEVELOP_BASE="develop"       # 개발 단계: upstream/develop 기반
PHASE_RELEASE_BASE=""              # QA 단계: release/x.x.x (매번 다르므로 비워두면 물어봄)
PHASE_HOTFIX_BASE="main"           # 핫픽스: upstream/main 기반
```

`/harness-task` 스킬이 작업 시작할 때 "어떤 단계에서 작업하나요?"를 물어보고, 여기 설정에 따라 base 브랜치와 병합 대상을 결정합니다.

#### 실제 Git Flow

```
[개발]
  upstream/develop → feature/<ticket> → push → PR to upstream/develop

[QA]
  upstream/release/x.x.x → feature/<ticket> → push → PR to upstream/release/x.x.x

[핫픽스]
  upstream/main → feature/<ticket> → push → PR to upstream/main
  → 이후 develop, release에도 반영 필요 (안내해줌)
```

`MERGE_STRATEGY="direct"`로 바꾸면 PR 없이 로컬에서 바로 병합하는 데모 모드로 동작합니다.

---

## 워크플로우

### `/harness-task`로 시작하는 전체 흐름

```
/harness-task Todo 필터 기능 추가

  → "Jira 티켓 번호?" → PROJ-203 (없으면 타임스탬프 자동 생성)
  → "어떤 단계?" → 1. 개발 / 2. QA / 3. 핫픽스
  → exec-plan 스켈레톤 생성 (docs/exec-plans/active/)
  → upstream 동기화 → 워크트리 생성 → failure-patterns 미리보기
  → 구현 → verify-task.sh (반복) → push + PR 안내
  → 완료 후 exec-plan을 completed/로 이동
```

### 스크립트별 역할

| 스크립트 | 하는 일 | 언제 쓰는가 |
|----------|---------|------------|
| `task-start.sh <id>` | 워크트리 + exec-plan 스켈레톤 + 세션 로그 초기화 | 작업 시작할 때 |
| `verify-task.sh <id>` | 검증기 5개 실행, 결과만 보여줌 (병합 안 함) | 구현 중에 수시로 |
| `task-finish.sh <id>` | 검증 + 병합 + exec-plan 아카이브 + 로그 자동 커밋 | 작업 끝나서 병합할 때 |
| `task-cleanup.sh` | 7일 이상 비활성 워크트리 정리 | GC 에이전트가 주기적으로 |

`verify-task.sh`를 따로 뺀 이유: `task-finish.sh`는 통과하면 바로 병합까지 해버리니까, "아직 작업 중인데 지금 상태 괜찮나?" 확인만 하고 싶을 때 쓸 수가 없거든요.

---

## docs/ — 지식 베이스

리포지터리 안에 있는 것만 에이전트에게 존재합니다. Slack이나 Confluence에 있는 건 없는 거나 마찬가지입니다.

### 재발 방지 루프

에이전트가 같은 실수를 반복하면 하네스가 스스로 단단해지는 구조입니다.

```
에이전트 실수 발생
  → agent-failures.md에 기록
  → 같은 패턴 2회 → golden-principles.md에 원칙 승격
  → 같은 패턴 3회 → 린트/검증기/훅으로 구조적 차단
```

| 문서 | 역할 |
|------|------|
| `agent-failures.md` | 실패 기록 (증상, 근본 원인, 대응) |
| `golden-principles.md` | 실패에서 승격된 "하지 말 것" 규칙 (GP-001~) |
| `escalation-policy.md` | DB 스키마, 인증, 결제 등 에이전트가 혼자 건드리면 안 되는 영역 |

### ADR (Architecture Decision Records)

"왜 이렇게 하기로 했는지" + "어떻게 강제하는지"를 기록합니다.

```
docs/design-docs/
├── index.md                        ← ADR 목록 + 새 ADR 템플릿
├── core-beliefs.md                 ← 팀 핵심 원칙
├── ADR-0001-worktree-isolation.md  ← Enforcement: pre-edit hook + task-finish.sh
└── ADR-0002-validation-pipeline.md ← Enforcement: 5개 검증기
```

핵심은 **Enforcement 섹션**입니다. 결정을 문서에만 써두면 무시됩니다. 어떤 린트 규칙으로, 어떤 검증기로 강제하는지까지 적어야 의미가 있습니다.

### 기타

| 문서 | 역할 |
|------|------|
| `playbooks/` | 반복 작업 레시피 (체크리스트, 실패에서 유래) |
| `exec-plans/active/` | 진행 중 계획 (task-start.sh가 스켈레톤 자동 생성) |
| `exec-plans/completed/` | 완료된 계획 아카이브 (task-finish.sh가 자동 이동) |
| `exec-plans/tech-debt-tracker.md` | 보류 중인 기술 부채 |
| `QUALITY_SCORE.md` | 도메인별 품질 현황 |

---

## 검증기

| # | 검증기 | 설정 | 체크 내용 |
|---|--------|------|-----------|
| 01 | build | `BUILD_CMD` | 컴파일 성공 |
| 02 | test | `TEST_CMD` | 테스트 전부 통과 |
| 03 | lint | `LINT_CMD` | 코드 스타일 |
| 04 | security | gitleaks / 패턴 매칭 | 시크릿, .env 노출 |
| 05 | docs-freshness | 파일 변경 감지 | 문서 최신화 |

검증기 오류 메시지에는 파일명, 라인 번호, 수정 방법이 포함됩니다. 에이전트가 메시지만 읽고 스스로 고칠 수 있어야 한다는 원칙입니다.

---

## 시작하기

```bash
./setup.sh                              # 최초 1회: gradle wrapper + git init
./scripts/task-start.sh PROJ-101         # 워크트리 생성
```

또는 `/harness-task` 스킬로 시작:

```
/harness-task PROJ-101 Todo 완료 상태 필터 추가
```
