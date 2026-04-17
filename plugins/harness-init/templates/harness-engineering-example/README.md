# harness-engineering-example

A language-agnostic harness engineering template.
Copy this structure into your project and edit `harness.config.sh` to get started.

Guide: `../../README.md`

---

## Full Flow

```
User: /harness-task PROJ-101 Add todo filter feature

  ┌─────────────── Step 0. Check for existing work ─────────────┐
  │ If worktree .worktrees/PROJ-101 exists → resume              │
  │ Otherwise → start new task                                   │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 1~2. Analysis ──────────────────────────┐
  │ task-id: PROJ-101 / type: feat                               │
  │ "Jira ticket number?" → PROJ-101                             │
  │ "Which phase?" → 1.Development / 2.QA / 3.Hotfix            │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 3. Planning ────────────────────────────┐
  │ Create docs/exec-plans/active/feat-PROJ-101.md               │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 4~5. Preparation ───────────────────────┐
  │ git fetch upstream develop                                   │
  │ task-start.sh PROJ-101                                       │
  │  ├─ Create worktree at .worktrees/PROJ-101                   │
  │  ├─ Skeleton at docs/exec-plans/active/PROJ-101.md           │
  │  ├─ Init logs/sessions/PROJ-101/session.jsonl                │
  │  └─ Preview failure-patterns.md (Feedforward)                │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 6-1. Pre-implementation check ──────────┐
  │ Read golden-principles.md → prevent GP violations            │
  │ Check escalation-policy.md → if high-risk, get approval      │
  │ Check failure-patterns.md → avoid past failure patterns       │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 6-2. Implementation ────────────────────┐
  │ Write code only inside .worktrees/PROJ-101/                  │
  │  ├─ pre-tool-use.sh: warn on edits outside worktree          │
  │  ├─ post-tool-use.sh: session log + quick lint               │
  │  └─ git add + commit                                         │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 7. Validation ──────────────────────────┐
  │ verify-task.sh PROJ-101 (repeatable, no merge)               │
  │  ├─ 01-build.sh  → BUILD_CMD                                │
  │  ├─ 02-test.sh   → TEST_CMD                                 │
  │  ├─ 03-lint.sh   → LINT_CMD                                 │
  │  ├─ 04-security.sh → gitleaks / .env detection               │
  │  └─ 05-docs-freshness.sh → doc freshness                    │
  │                                                              │
  │  On failure: read exec-plan, determine cause                 │
  │   A. Code is wrong → fix code                                │
  │   B. Intentional change → update tests too                   │
  │   3 failures → auto-log to agent-failures.md                 │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Step 7. Completion ──────────────────────────┐
  │ MERGE_STRATEGY="pr":                                         │
  │   push → "Please create a PR" guidance                       │
  │                                                              │
  │ MERGE_STRATEGY="direct":                                     │
  │   task-finish.sh PROJ-101                                    │
  │    ├─ Sync develop                                           │
  │    ├─ merge --no-ff                                          │
  │    ├─ Move exec-plan → completed/                            │
  │    ├─ Auto-commit history.jsonl                              │
  │    └─ Remove worktree                                        │
  └──────────────────────────────────────────────────────────────┘
       ↓
  ┌─────────────── Recurrence Prevention Loop (GC Agent) ───────┐
  │ Same pattern 2x in agent-failures.md →                       │
  │   Promote to golden-principles.md                            │
  │ Same pattern 3x →                                            │
  │   Create structural enforcement exec-plan (ArchUnit, lint)   │
  └──────────────────────────────────────────────────────────────┘
```

---

## File Roles

### Configuration

| File | What it does | When it's used |
|------|-------------|----------------|
| `harness.config.sh` | Centralizes build/test/lint commands, Git Flow settings, and validator toggles | All scripts and validators source this file |
| `.claude/settings.json` | Hook wiring (pre/post-tool-use), dangerous command blocking (force push, rm -rf), skill registration | Automatically read by Claude Code |

### Agent Entry Points

| File | What it does | When it's used |
|------|-------------|----------------|
| `CLAUDE.md` | The first document the agent reads. Under 100 lines, serves as a table of contents. Task entry point table guides "what to read first" | Automatically loaded when the agent enters the project |
| `ARCHITECTURE.md` | Defines layer structure and dependency direction. Rules like "controller must not directly access repository" | Referenced before adding features or refactoring |
| `src/*/CLAUDE.md` (scoped) | Per-directory layer conventions. Only loaded when working in that directory to save context | Add per-layer when source structure is created (e.g. `src/controller/CLAUDE.md`, `src/service/CLAUDE.md`) |

> **Scoped CLAUDE.md**: This template does not include a `src/` directory, so no scoped CLAUDE.md files are present. Add them per-layer when applying to a real project. Guide: [README.md Section 5](../../README.md)

### Skills

| File | What it does | When it's used |
|------|-------------|----------------|
| `.claude/skills/harness-task/SKILL.md` | Defines the full `/harness-task` flow: analysis → planning → worktree → implementation → validation → merge. Includes Git Flow branching, failure handling, and resume logic | When the user runs `/harness-task ...` |
| `.claude/skills/code-review/SKILL.md` | Code review checklist | On `/code-review` |
| `.claude/skills/debugging/SKILL.md` | Systematic bug tracking procedure | On `/debugging` |

### Hooks (Real-Time Guardrails)

| File | What it does | When it's used |
|------|-------------|----------------|
| `.claude/hooks/pre-tool-use.sh` | Auto-called **before** Bash/Edit/Write. ① Warns on src/ edits outside worktree ② Blocks force push ③ Blocks rm -rf / ④ Logs to session | Every time the agent uses a tool |
| `.claude/hooks/post-tool-use.sh` | Auto-called **after** Edit/Write. ① Logs file changes to session ② Quick lint if QUICK_LINT=true | Every time the agent modifies a file |

### Scripts (Workflow Enforcement)

| File | What it does | When it's used |
|------|-------------|----------------|
| `scripts/task-start.sh` | ① Create worktree (`git worktree add`) ② Auto-generate exec-plan skeleton ③ Init session log ④ Preview failure-patterns.md | At task start |
| `scripts/verify-task.sh` | Run all 5 validators and show results. **No merge.** Logs to history.jsonl | Repeatedly during implementation (status check) |
| `scripts/task-finish.sh` | ① Run all 5 validators ② Branch by MERGE_STRATEGY: `"pr"` → push + PR guidance / `"direct"` → local merge ③ Move exec-plan to completed/ ④ Auto-commit history.jsonl | At task completion (final gate) |
| `scripts/task-cleanup.sh` | Clean up merged or 7+ day inactive worktrees | GC agent runs periodically, or manual |

### Validators

All validators read `harness.config.sh` so they are language-agnostic.
On failure, they output **agent-friendly error messages** with file name, line number, and fix instructions.

| File | What it does | Config read |
|------|-------------|-------------|
| `validators/01-build.sh` | Build/compile success | `BUILD_CMD` |
| `validators/02-test.sh` | All tests pass | `TEST_CMD` |
| `validators/03-lint.sh` | Code style compliance | `LINT_CMD` |
| `validators/04-security.sh` | Secret detection (gitleaks or pattern matching) + .env in git | `SECURITY_SCAN_CMD` |
| `validators/05-docs-freshness.sh` | CLAUDE.md line count, doc update on new service, exec-plan cleanup | — |

### Documentation (Knowledge Base)

| File | What it does | Who writes it |
|------|-------------|---------------|
| `docs/design-docs/core-beliefs.md` | Core team principles (isolation, validation first, repository = single source of truth) | Team writes at project start |
| `docs/design-docs/index.md` | ADR list + new ADR template | Updated when adding an ADR |
| `docs/design-docs/ADR-XXXX-*.md` | Structural decisions + **Enforcement section** (which lint/validator/hook enforces it) | On significant design decisions |
| `docs/escalation-policy.md` | Areas the agent must not touch alone (DB schema, auth, payment, security, etc.) | **Must fill at project start** |
| `docs/golden-principles.md` | "Don't do this" rules promoted from 2+ failures in agent-failures.md (GP-001~) | Can start empty. Grows as failures accumulate |
| `docs/agent-failures.md` | Agent failure log (symptom, root cause, remediation, domain). Starting point for the recurrence prevention loop | Auto-logged by /harness-task on 3 failures + manual entries |
| `docs/playbooks/` | Step-by-step recipes for recurring high-risk tasks (checklists derived from actual failures) | Created when the same type of mistake repeats |
| `docs/exec-plans/active/` | In-progress task plans. task-start.sh auto-generates skeletons | task-start.sh + /harness-task |
| `docs/exec-plans/completed/` | Completed plan archive. task-finish.sh auto-moves | task-finish.sh |
| `docs/exec-plans/tech-debt-tracker.md` | Deferred tech debt. Delete row on fix + `refs: TD-XXX` in commit | Manual |
| `docs/QUALITY_SCORE.md` | Per-domain quality status (build stability, test pass rate, etc.) | GC agent or manual |

### Logs (Observability)

| File | What it does | Git tracked |
|------|-------------|-------------|
| `logs/sessions/<task>/session.jsonl` | Timestamped log of all agent actions (task_start, tool_use, validator results, etc.) | No (local only, gitignored) |
| `logs/validators/history.jsonl` | All validator run results (pass/fail, error content). Analyzed by GC agent | Yes (shared with team) |
| `logs/trends/failure-patterns.md` | Last 30 days validator failure stats + recommended improvements. task-start.sh shows this as Feedforward | Yes (shared with team) |

### Agent Role Definitions

| File | What it does |
|------|-------------|
| `agents/planner-agent.md` | Expands user requests into detailed execution plans (exec-plans) |
| `agents/generator-agent.md` | Reads exec-plan and implements code in the worktree |
| `agents/evaluator-agent.md` | Independently validates Generator output via verify-task.sh (no self-evaluation) |
| `agents/gc-agent.md` | Periodic tasks: ① Update failure-patterns ② Detect 3-strike promotions ③ Clean stale worktrees ④ Detect doc drift |

---

## Getting Started

### 1. Copy

```bash
cp -r harness-engineering-example/ my-project/
cd my-project/
```

### 2. Edit harness.config.sh (the only required step)

```bash
PROJECT_NAME="my-project"

# Git Flow
GIT_REMOTE="upstream"              # "upstream" for forks, "origin" for single-repo
MERGE_STRATEGY="pr"                # "pr" = push+PR / "direct" = local merge

PHASE_DEVELOP_BASE="develop"
PHASE_RELEASE_BASE=""              # leave empty to prompt each time
PHASE_HOTFIX_BASE="main"

# Set for your language
BUILD_CMD="./gradlew compileKotlin"     # Kotlin
# BUILD_CMD="npm run build"            # TypeScript
# BUILD_CMD="go build ./..."           # Go
TEST_CMD="./gradlew test"
LINT_CMD="./gradlew ktlintCheck"
```

### 3. Set branch / commit / PR rules

Put your team conventions in `harness.config.sh` so the agent produces consistent commits and PRs. Without this, it will make its own choices.

```bash
# Branch naming
BRANCH_PREFIX="feature"                      # Creates feature/<task-id>

# Commit message (Conventional Commits)
# Task type becomes the prefix: feat, fix, refactor, chore, docs
# Example: "feat: PROJ-101 Add todo filter feature"
COMMIT_TEMPLATE="<type>: <task-id> <summary>"

# PR rules
PR_TITLE_TEMPLATE="<type>: <task-id> <summary>"
# PR_BODY_TEMPLATE=""              # Leave empty to auto-fill from exec-plan
# PR_REVIEWERS="alice,bob"         # Leave empty to skip
# PR_LABELS="feature,backend"      # Leave empty to skip
```

Ask yourself:
- What is our team's commit message convention? (Conventional Commits, Jira number required, etc.)
- Should PR titles include ticket numbers?
- Are there default reviewers?
- Are there labeling rules for PRs?

### 4. Documents to fill at project start

| Document | When | How |
|----------|------|-----|
| `docs/escalation-policy.md` | **Right now** | Define areas the agent must not touch alone |
| `docs/design-docs/core-beliefs.md` | **Right now** | Write 3~5 core team principles |
| `ARCHITECTURE.md` | **Right now** | Define layer structure and dependency direction |
| `docs/golden-principles.md` | Later | Grows naturally from failures. Seed with known risk patterns |
| `docs/playbooks/` | Later | Create recipes when the same mistake repeats 3 times |
| `docs/agent-failures.md` | Automatic | Auto-logged on /harness-task 3 failures + manual entries |

#### Tips for escalation-policy.md

Ask these questions:
- What changes in this project could lead to an outage?
- What tasks would be hard to reverse if the agent makes a mistake?
- What code areas must go through team review?

#### Tips for golden-principles.md

Don't try to write everything upfront. Seed with risk patterns you already know:

```markdown
### GP-001: Do not inject repository directly from controller
- Why: Layer rule violation
- Instead: Access through service
- Enforcement: (documentation only for now — escalate to ArchUnit after 3 recurrences)
```

Principles with "documentation only" Enforcement must be escalated to lint/test after 3 recurrences.

### 4. Start Working

```bash
/harness-task PROJ-101 Fix login token bug
```

Or manually:

```bash
./scripts/task-start.sh PROJ-101
# ... implement ...
./scripts/verify-task.sh PROJ-101   # repeat during implementation
./scripts/task-finish.sh PROJ-101   # final merge
```

---

## Recurrence Prevention Loop

The mechanism by which the harness strengthens itself over time.

```
Agent mistake → log in agent-failures.md
  → 2 recurrences → promote to golden-principles.md (GP-XXX)
  → 3 recurrences → GC agent creates structural enforcement exec-plan
              → block via ArchUnit/lint/validator
```

| Stage | Who | What |
|-------|-----|------|
| Log | /harness-task (auto on 3 failures) or human | Add row to agent-failures.md |
| Promote | GC agent or human | Add GP-XXX to golden-principles.md (Why/Instead/Enforcement) |
| Enforce | GC agent creates exec-plan → human approves → /harness-task implements | Lint rule, ArchUnit, validator, pre-commit hook, etc. |

---

## Git Flow Support

When `MERGE_STRATEGY="pr"`, `/harness-task` asks which work phase.

| Phase | Base branch | Merge target |
|-------|------------|-------------|
| Development | `PHASE_DEVELOP_BASE` (default: develop) | PR to upstream/develop |
| QA/Release | `PHASE_RELEASE_BASE` (prompt if empty) | PR to upstream/release/x.x.x |
| Hotfix | `PHASE_HOTFIX_BASE` (default: main) | PR to upstream/main → also propagate to develop, release |

When `MERGE_STRATEGY="direct"`, merges locally without PR (for demos/personal projects).

---

## Adoption Checklist

Use this for incremental harness adoption in your project.

### Stage 1 — Tell the agent the rules

- [ ] Write `CLAUDE.md` (under 100 lines, table of contents role)
- [ ] Configure `harness.config.sh` (BUILD_CMD, TEST_CMD, LINT_CMD)
- [ ] Add `.claude/hooks/pre-tool-use.sh` hook (warn on edits outside worktree)
- [ ] At least 1 validator (minimum `validators/02-test.sh`)

### Stage 2 — Task isolation + progressive disclosure

- [ ] `scripts/task-start.sh` / `task-finish.sh` worktree flow
- [ ] At least 1 skill (`.claude/skills/`)
- [ ] Add task entry point table to `CLAUDE.md`
- [ ] Write `docs/design-docs/core-beliefs.md` core team principles

### Stage 3 — Validation pipeline + observability

- [ ] Configure all 5 validators (`validators/01~05`)
- [ ] Separate `scripts/verify-task.sh` (repeat validation during implementation)
- [ ] Auto-generate exec-plan skeleton in `task-start.sh`
- [ ] Enable `logs/sessions/` session logging
- [ ] Define layer rules in `ARCHITECTURE.md`

### Stage 4 — Structural enforcement + knowledge management

- [ ] Adopt ADR pattern (`docs/design-docs/index.md` + Enforcement section)
- [ ] Write `docs/golden-principles.md` (seed with 3~5 initial principles)
- [ ] `docs/playbooks/` recipes for recurring high-risk tasks
- [ ] Multi-agent definitions (`agents/planner, generator, evaluator`)
- [ ] Scoped CLAUDE.md — per-layer `CLAUDE.md` (e.g. `src/controller/CLAUDE.md` with "call service only, no direct repository access"). Loaded only when working in that directory to save context
- [ ] `docs/exec-plans/tech-debt-tracker.md` tech debt management
- [ ] Git hooks (Conventional Commits, block commits to develop/main)
- [ ] Branch/commit/PR rules in `harness.config.sh`

### Stage 5 — Autonomous evolution

- [ ] `docs/agent-failures.md` + `docs/golden-principles.md` recurrence prevention loop
- [ ] `docs/escalation-policy.md` high-risk change definitions
- [ ] GC agent operation (`failure-patterns.md` auto-update, 3-strike promotion)
- [ ] Promotion policy operation (2x → principle, 3x → structural enforcement)
- [ ] `docs/exec-plans/completed/` archive operation
- [ ] `docs/QUALITY_SCORE.md` per-domain quality tracking
- [ ] CI workflow (automated validation + escalation check)
