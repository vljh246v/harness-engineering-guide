# harness-engineering-example

언어와 프레임워크에 종속되지 않는 하네스 엔지니어링 범용 템플릿입니다.
이 구조를 자기 프로젝트에 복사하고 `harness.config.sh`만 수정하면 바로 사용할 수 있습니다.

가이드 문서: `../../README.md`

---

## 전체 플로우

```
사용자: /harness-task PROJ-101 Todo 필터 기능 추가

  ┌─────────────── Step 0. 기존 작업 확인 ───────────────┐
  │ 워크트리 .worktrees/PROJ-101 이 이미 있으면 → 이어하기 │
  │ 없으면 → 새 작업 시작                                 │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 1~2. 분석 ──────────────────────┐
  │ task-id: PROJ-101 / type: feat                        │
  │ "Jira 티켓 번호?" → PROJ-101                          │
  │ "어떤 단계?" → 1.개발 / 2.QA / 3.핫픽스              │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 3. 계획 ────────────────────────┐
  │ docs/exec-plans/active/feat-PROJ-101.md 생성          │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 4~5. 준비 ──────────────────────┐
  │ git fetch upstream develop                           │
  │ task-start.sh PROJ-101                                │
  │  ├─ .worktrees/PROJ-101 워크트리 생성                  │
  │  ├─ docs/exec-plans/active/PROJ-101.md 스켈레톤       │
  │  ├─ logs/sessions/PROJ-101/session.jsonl 초기화       │
  │  └─ failure-patterns.md 미리보기 (Feedforward)       │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 6-1. 구현 전 체크 ──────────────┐
  │ golden-principles.md 읽기 → GP 위반 방지             │
  │ escalation-policy.md 확인 → 고위험이면 사람 승인     │
  │ failure-patterns.md 확인 → 과거 실패 패턴 회피       │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 6-2. 구현 ──────────────────────┐
  │ .worktrees/PROJ-101/ 안에서만 코드 작성               │
  │  ├─ pre-tool-use.sh: 워크트리 밖 수정 경고           │
  │  ├─ post-tool-use.sh: 세션 로그 + 빠른 린트          │
  │  └─ git add + commit                                │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 7. 검증 ────────────────────────┐
  │ verify-task.sh PROJ-101 (반복 실행, 병합 안 함)       │
  │  ├─ 01-build.sh  → BUILD_CMD                        │
  │  ├─ 02-test.sh   → TEST_CMD                         │
  │  ├─ 03-lint.sh   → LINT_CMD                         │
  │  ├─ 04-security.sh → gitleaks / .env 감지            │
  │  └─ 05-docs-freshness.sh → 문서 최신화              │
  │                                                      │
  │  실패 시: exec-plan 읽고 원인 판단                    │
  │   A. 코드 잘못 → 코드 수정                           │
  │   B. 의도적 변경 → 테스트도 수정                      │
  │   3회 실패 → agent-failures.md 자동 기록             │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 7. 완료 ────────────────────────┐
  │ MERGE_STRATEGY="pr":                                 │
  │   push → "PR 생성해주세요" 안내                      │
  │                                                      │
  │ MERGE_STRATEGY="direct":                             │
  │   task-finish.sh PROJ-101                             │
  │    ├─ develop 동기화                                  │
  │    ├─ merge --no-ff                                   │
  │    ├─ exec-plan → completed/ 이동                     │
  │    ├─ history.jsonl 자동 커밋                         │
  │    └─ 워크트리 삭제                                   │
  └───────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── 재발 방지 루프 (GC 에이전트) ────────┐
  │ agent-failures.md에서 같은 패턴 2회 →                │
  │   golden-principles.md에 원칙 승격                   │
  │ 같은 패턴 3회 →                                      │
  │   구조적 강제 exec-plan 생성 (ArchUnit, 린트 등)     │
  └───────────────────────────────────────────────────────┘
```

---

## 파일별 역할

### 설정

| 파일 | 뭘 하는가 | 언제 쓰이는가 |
|------|-----------|--------------|
| `harness.config.sh` | 빌드/테스트/린트 커맨드, Git Flow 설정, 검증기 활성화 여부를 한 곳에서 관리 | 모든 스크립트와 검증기가 이 파일을 source해서 읽음 |
| `.claude/settings.json` | 훅 연결 (pre/post-tool-use), 위험 명령 차단 (force push, rm -rf), 스킬 등록 | Claude Code가 자동으로 읽음 |

### 에이전트 진입점

| 파일 | 뭘 하는가 | 언제 쓰이는가 |
|------|-----------|--------------|
| `CLAUDE.md` | 에이전트가 제일 먼저 읽는 지도. 100줄 이하 목차 역할. 작업 유형별 진입점 표로 "뭘 먼저 읽을지" 안내 | 에이전트가 프로젝트에 진입할 때 자동으로 읽힘 |
| `ARCHITECTURE.md` | 레이어 구조와 의존성 방향 정의. "controller에서 repository 직접 접근 금지" 같은 규칙 | 기능 추가, 리팩터링 전에 에이전트가 참고 |
| `src/*/CLAUDE.md` (스코프) | 디렉토리별 레이어 규약. 해당 디렉토리에서 작업할 때만 읽혀서 컨텍스트 낭비를 줄임 | 실제 프로젝트에 소스 구조가 생기면 레이어별로 추가 (예: `src/controller/CLAUDE.md`, `src/service/CLAUDE.md`) |

> **스코프 CLAUDE.md**: 이 템플릿에는 `src/` 디렉토리가 없으므로 스코프 CLAUDE.md가 포함되어 있지 않습니다. 실제 프로젝트에 적용할 때 레이어별로 추가하세요. 가이드: [README.md Section 5 — 레버 1: 시스템 프롬프트](../../README.md#레버-1-시스템-프롬프트-claudemd)

### 스킬

| 파일 | 뭘 하는가 | 언제 쓰이는가 |
|------|-----------|--------------|
| `.claude/skills/harness-task/SKILL.md` | `/harness-task` 명령 전체 플로우 정의: 분석 → 계획 → 워크트리 → 구현 → 검증 → 병합. Git Flow 분기, 실패 대응 로직, 이어하기(resume) 포함 | 사용자가 `/harness-task ...`를 입력할 때 |
| `.claude/skills/code-review/SKILL.md` | 코드 리뷰 체크리스트 | `/code-review` 호출 시 |
| `.claude/skills/debugging/SKILL.md` | 체계적 버그 추적 절차 | `/debugging` 호출 시 |

### 훅 (실시간 가드레일)

| 파일 | 뭘 하는가 | 언제 쓰이는가 |
|------|-----------|--------------|
| `.claude/hooks/pre-tool-use.sh` | Bash/Edit/Write 실행 **전에** 자동 호출. ① 워크트리 밖 src/ 수정 시 경고 ② force push 차단 ③ rm -rf / 차단 ④ 세션 로그 기록 | 에이전트가 도구를 쓸 때마다 자동 |
| `.claude/hooks/post-tool-use.sh` | Edit/Write 실행 **후에** 자동 호출. ① 세션 로그에 파일 변경 기록 ② QUICK_LINT=true면 빠른 린트 | 에이전트가 파일을 수정할 때마다 자동 |

### 스크립트 (워크플로우 강제)

| 파일 | 뭘 하는가 | 언제 쓰이는가 |
|------|-----------|--------------|
| `scripts/task-start.sh` | ① 워크트리 생성 (`git worktree add`) ② exec-plan 스켈레톤 자동 생성 ③ 세션 로그 초기화 ④ failure-patterns.md 미리보기 출력 | 작업 시작할 때 |
| `scripts/verify-task.sh` | 검증기 5개 실행하고 결과만 보여줌. **병합 안 함.** history.jsonl에 기록 | 구현 중에 수시로 (현재 상태 확인용) |
| `scripts/task-finish.sh` | ① 검증기 5개 실행 ② MERGE_STRATEGY에 따라 분기: `"pr"` → push + PR 안내 / `"direct"` → 로컬 병합 ③ exec-plan을 completed/로 이동 ④ history.jsonl 자동 커밋 | 작업 완료 시 (최종 관문) |
| `scripts/task-cleanup.sh` | 병합 완료되거나 7일 이상 비활성 워크트리 정리 | GC 에이전트가 주기적으로, 또는 수동 |

### 검증기

모든 검증기는 `harness.config.sh`를 읽어서 실행하므로 언어에 종속되지 않습니다.
실패 시 파일명, 라인 번호, 수정 방법을 포함한 **에이전트용 오류 메시지**를 출력합니다.

| 파일 | 뭘 하는가 | 읽는 설정 |
|------|-----------|-----------|
| `validators/01-build.sh` | 컴파일/빌드 성공 여부 | `BUILD_CMD` |
| `validators/02-test.sh` | 테스트 전부 통과 여부 | `TEST_CMD` |
| `validators/03-lint.sh` | 코드 스타일 준수 여부 | `LINT_CMD` |
| `validators/04-security.sh` | 시크릿 노출 감지 (gitleaks 또는 패턴 매칭) + git에 포함된 .env 파일 감지 | `SECURITY_SCAN_CMD` |
| `validators/05-docs-freshness.sh` | CLAUDE.md 줄 수 초과, 새 서비스 추가 시 문서 업데이트 여부, exec-plan 정리 상태 | — |

### 문서 (지식 베이스)

| 파일 | 뭘 하는가 | 누가 작성하는가 |
|------|-----------|----------------|
| `docs/design-docs/core-beliefs.md` | 팀 핵심 원칙 (격리, 검증 우선, 리포지터리 = 단일 진실 원천) | 팀이 프로젝트 시작 시 작성 |
| `docs/design-docs/index.md` | ADR 목록 + 새 ADR 작성 템플릿 | ADR 추가할 때마다 업데이트 |
| `docs/design-docs/ADR-XXXX-*.md` | 구조적 결정 + **Enforcement 섹션** (어떤 린트/검증기/훅으로 강제하는지) | 중요한 설계 결정을 내릴 때 |
| `docs/escalation-policy.md` | 에이전트가 혼자 건드리면 안 되는 영역 (DB 스키마, 인증, 결제, 보안 등) | **프로젝트 시작 시 반드시 채움** |
| `docs/golden-principles.md` | agent-failures에서 2회 반복된 실패가 승격된 "하지 말 것" 규칙 (GP-001~) | 처음엔 비워둬도 됨. 실패가 쌓이면 채워짐 |
| `docs/agent-failures.md` | 에이전트 실패 기록 (증상, 근본 원인, 대응, 도메인). 재발 방지 루프의 시작점 | /harness-task가 3회 실패 시 자동 기록 + 사람이 수동 기록 |
| `docs/playbooks/` | 반복적인 고위험 작업의 단계별 레시피 (체크리스트가 실제 실패에서 유래) | 같은 유형의 실수가 반복되면 만듦 |
| `docs/exec-plans/active/` | 진행 중인 작업 계획. task-start.sh가 스켈레톤 자동 생성 | task-start.sh + /harness-task |
| `docs/exec-plans/completed/` | 완료된 계획 아카이브. task-finish.sh가 자동 이동 | task-finish.sh |
| `docs/exec-plans/tech-debt-tracker.md` | "나중에 고치자"고 보류한 기술 부채. 해결 시 행 삭제 + `refs: TD-XXX` 커밋 | 사람이 수동 |
| `docs/QUALITY_SCORE.md` | 도메인별 품질 현황 (빌드 안정성, 테스트 통과율 등) | GC 에이전트 또는 수동 |

### 로그 (관측 가능성)

| 파일 | 뭘 하는가 | git 추적 |
|------|-----------|----------|
| `logs/sessions/<task>/session.jsonl` | 에이전트의 모든 행동을 타임스탬프와 함께 기록 (task_start, tool_use, validator 결과 등) | ❌ 로컬만 (gitignore) |
| `logs/validators/history.jsonl` | 모든 검증기 실행 결과 (pass/fail, 에러 내용). GC 에이전트가 분석 | ✅ 팀 공유 |
| `logs/trends/failure-patterns.md` | 최근 30일 검증기 실패 통계 + 추천 개선사항. task-start.sh가 Feedforward로 출력 | ✅ 팀 공유 |

### 에이전트 역할 정의

| 파일 | 뭘 하는가 |
|------|-----------|
| `agents/planner-agent.md` | 사용자 요청을 상세 실행 계획(exec-plan)으로 확장 |
| `agents/generator-agent.md` | exec-plan을 보고 워크트리에서 코드 구현 |
| `agents/evaluator-agent.md` | Generator와 독립적으로 verify-task.sh로 검증 (자기 평가 금지) |
| `agents/gc-agent.md` | 주기적으로 실행: ① failure-patterns 업데이트 ② 3-strike 승격 감지 ③ 스테일 워크트리 정리 ④ 문서 드리프트 감지 |

---

## 적용 방법

### 1. 복사

```bash
cp -r harness-engineering-example/ my-project/
cd my-project/
```

### 2. harness.config.sh 수정 (유일하게 필수)

```bash
PROJECT_NAME="my-project"

# Git Flow
GIT_REMOTE="upstream"              # fork 기반이면 upstream, 단일 리포면 origin
MERGE_STRATEGY="pr"                # "pr" = push+PR / "direct" = 로컬 직접 병합

PHASE_DEVELOP_BASE="develop"
PHASE_RELEASE_BASE=""              # 비워두면 매번 물어봄
PHASE_HOTFIX_BASE="main"

# 프로젝트 언어에 맞게
BUILD_CMD="./gradlew compileKotlin"     # Kotlin
# BUILD_CMD="npm run build"            # TypeScript
# BUILD_CMD="go build ./..."           # Go
TEST_CMD="./gradlew test"
LINT_CMD="./gradlew ktlintCheck"
```

### 3. 브랜치 / 커밋 / PR 규칙 설정

`harness.config.sh`에 팀 컨벤션을 넣어야 에이전트가 일관된 커밋과 PR을 만듭니다. 안 채우면 자기 맘대로 합니다.

```bash
# 브랜치 네이밍
BRANCH_PREFIX="feature"                      # feature/<task-id> 형태

# 커밋 메시지 (Conventional Commits)
COMMIT_TEMPLATE="<type>: <task-id> <요약>"
# 예: "feat: PROJ-101 Todo 필터 기능 추가"

# PR 규칙
PR_TITLE_TEMPLATE="<type>: <task-id> <요약>"
# PR_BODY_TEMPLATE=""              # 비워두면 exec-plan 내용을 자동으로 채움
# PR_REVIEWERS="팀원1,팀원2"       # 비워두면 안내하지 않음
# PR_LABELS="feature,backend"      # 비워두면 안내하지 않음
```

스스로 물어보세요:
- 우리 팀의 커밋 메시지 규칙이 뭔가? (Conventional Commits, Jira 번호 필수 등)
- PR 제목에 티켓 번호가 들어가야 하나?
- 기본 리뷰어가 정해져 있나?
- PR에 라벨을 붙이는 규칙이 있나?

### 4. 프로젝트 시작 시 채워야 하는 문서

| 문서 | 언제 | 어떻게 |
|------|------|--------|
| `docs/escalation-policy.md` | **지금 바로** | 에이전트가 혼자 건드리면 안 되는 영역을 정해둠 |
| `docs/design-docs/core-beliefs.md` | **지금 바로** | 팀 핵심 원칙 3~5개 작성 |
| `ARCHITECTURE.md` | **지금 바로** | 레이어 구조와 의존성 방향 정의 |
| `docs/golden-principles.md` | 나중에 | 실패가 쌓이면 자연스럽게 채워짐. 알고 있는 위험 패턴은 시드로 넣어도 됨 |
| `docs/playbooks/` | 나중에 | 같은 유형의 실수가 3번 반복되면 레시피로 만듦 |
| `docs/agent-failures.md` | 자동 | /harness-task 3회 실패 시 자동 기록 + 사람이 수동 추가 |

#### escalation-policy.md 작성 팁

이런 질문을 던져보세요:
- 이 프로젝트에서 장애로 이어질 수 있는 변경이 뭔가?
- 에이전트가 실수하면 되돌리기 어려운 작업이 뭔가?
- 팀에서 반드시 리뷰를 거쳐야 하는 코드 영역이 어딘가?

#### golden-principles.md 작성 팁

처음부터 쓰려고 하지 마세요. 이미 알고 있는 위험 패턴만 시드로 넣어두면 됩니다:

```markdown
### GP-001: controller에서 repository를 직접 주입하지 않는다
- 왜: 레이어 규칙 위반
- 대신: service를 거쳐서 접근
- 강제: (아직 문서만 — 반복되면 ArchUnit으로 격상)
```

"강제" 항목이 "문서만"인 원칙은 3회 재발하면 린트/테스트로 격상해야 합니다.

### 4. 작업 시작

```bash
/harness-task PROJ-101 로그인 토큰 버그 수정
```

또는 수동:

```bash
./scripts/task-start.sh PROJ-101
# ... 구현 ...
./scripts/verify-task.sh PROJ-101   # 구현 중 반복 검증
./scripts/task-finish.sh PROJ-101   # 최종 병합
```

---

## 재발 방지 루프

하네스가 스스로 단단해지는 메커니즘입니다.

```
에이전트 실수 → agent-failures.md 기록
  → 2회 반복 → golden-principles.md에 원칙 승격 (GP-XXX)
  → 3회 반복 → GC 에이전트가 구조적 강제 exec-plan 생성
              → ArchUnit/린트/검증기로 물리적 차단
```

| 단계 | 누가 | 뭘 하는가 |
|------|------|-----------|
| 기록 | /harness-task (3회 실패 시 자동) 또는 사람 | agent-failures.md에 행 추가 |
| 승격 | GC 에이전트 또는 사람 | golden-principles.md에 GP-XXX 추가 (왜/대신/강제) |
| 강제 | GC 에이전트가 exec-plan 생성 → 사람 승인 → /harness-task로 구현 | 린트 규칙, ArchUnit, 검증기, pre-commit hook 등 |

---

## Git Flow 지원

`MERGE_STRATEGY="pr"`일 때 `/harness-task`가 작업 단계를 물어봅니다.

| 단계 | base 브랜치 | 병합 대상 |
|------|------------|-----------|
| 개발 | `PHASE_DEVELOP_BASE` (기본: develop) | upstream/develop에 PR |
| QA/릴리즈 | `PHASE_RELEASE_BASE` (비워두면 물어봄) | upstream/release/x.x.x에 PR |
| 핫픽스 | `PHASE_HOTFIX_BASE` (기본: main) | upstream/main에 PR → develop, release에도 반영 안내 |

`MERGE_STRATEGY="direct"`면 PR 없이 로컬에서 직접 병합합니다 (데모/개인 프로젝트용).

---

## 적용 체크리스트

프로젝트에 하네스를 단계별로 도입할 때 참고하세요.

### 1단계 — 에이전트에게 규칙 알려주기

- [ ] `CLAUDE.md` 작성 (100줄 이하, 목차 역할)
- [ ] `harness.config.sh` 설정 (BUILD_CMD, TEST_CMD, LINT_CMD)
- [ ] `.claude/hooks/pre-tool-use.sh` 훅 (워크트리 외부 수정 경고)
- [ ] 기본 검증기 1개 이상 (최소 `validators/02-test.sh`)

### 2단계 — 작업 격리 + 점진적 공개

- [ ] `scripts/task-start.sh` / `task-finish.sh` 워크트리 플로우
- [ ] 스킬 1개 이상 (`.claude/skills/`)
- [ ] `CLAUDE.md`에 작업 유형별 진입점 표 추가
- [ ] `docs/design-docs/core-beliefs.md` 팀 핵심 원칙 작성

### 3단계 — 검증 파이프라인 + 관측 가능성

- [ ] 5개 검증기 모두 구성 (`validators/01~05`)
- [ ] `scripts/verify-task.sh` 분리 (구현 중 반복 검증)
- [ ] `task-start.sh`에서 exec-plan 스켈레톤 자동 생성
- [ ] `logs/sessions/` 세션 로그 활성화
- [ ] `ARCHITECTURE.md` 레이어 규칙 정의

### 4단계 — 구조적 강제 + 지식 관리

- [ ] ADR 패턴 도입 (`docs/design-docs/index.md` + Enforcement 섹션)
- [ ] `docs/golden-principles.md` 작성 (초기 원칙 3~5개 시드)
- [ ] `docs/playbooks/` 반복 고위험 작업 레시피
- [ ] 멀티에이전트 정의 (`agents/planner, generator, evaluator`)
- [ ] 스코프 CLAUDE.md — 레이어별 `CLAUDE.md` 추가 (예: `src/controller/CLAUDE.md`에 "service만 호출, repository 직접 접근 금지"). 해당 디렉토리 작업 시에만 로드되어 컨텍스트를 절약함
- [ ] `docs/exec-plans/tech-debt-tracker.md` 기술 부채 관리
- [ ] Git hooks (Conventional Commits, develop/main 커밋 차단)
- [ ] `harness.config.sh`에 브랜치/커밋/PR 규칙 설정

### 5단계 — 자율 진화

- [ ] `docs/agent-failures.md` + `docs/golden-principles.md` 재발 방지 루프 운영
- [ ] `docs/escalation-policy.md` 고위험 변경 정의
- [ ] GC 에이전트 운영 (`failure-patterns.md` 자동 업데이트, 3-strike 승격)
- [ ] 승격 정책 운영 (2회 → 원칙, 3회 → 구조적 강제)
- [ ] `docs/exec-plans/completed/` 아카이브 운영
- [ ] `docs/QUALITY_SCORE.md` 도메인별 품질 추적
- [ ] CI 워크플로우 (자동 검증 + 에스컬레이션 체크)
