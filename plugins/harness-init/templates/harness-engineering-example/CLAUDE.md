# CLAUDE.md

A map for the agent. Keep this file under 100 lines.
See linked documents for details.

## Project

[Describe your project here]

## Task Entry Points

| Task | Read first |
|------|-----------|
| New feature | `ARCHITECTURE.md` → `docs/golden-principles.md` |
| Bug fix | `logs/trends/failure-patterns.md` → `docs/agent-failures.md` |
| Refactoring | `ARCHITECTURE.md` → `docs/design-docs/index.md` |
| High-risk change | `docs/escalation-policy.md` → requires human approval |
| Harness improvement | `docs/design-docs/core-beliefs.md` → `docs/golden-principles.md` |

## Workflow

```
task-start.sh → (auto-generate exec-plan) → implement → verify-task.sh → task-finish.sh
```

- Start: `./scripts/task-start.sh <task-id>`
- Mid-check: `./scripts/verify-task.sh <task-id>`
- Finish: `./scripts/task-finish.sh <task-id>`

## Build & Test

Config: `harness.config.sh`

## Key Documents

| Document | Role |
|----------|------|
| `ARCHITECTURE.md` | Layer structure + dependency direction |
| `docs/design-docs/core-beliefs.md` | Core team principles |
| `docs/golden-principles.md` | Rules promoted from failures (GP-001~) |
| `docs/agent-failures.md` | Agent failure log + recurrence prevention |
| `docs/escalation-policy.md` | Changes requiring human approval |
| `docs/design-docs/index.md` | ADR list + template |
| `docs/QUALITY_SCORE.md` | Per-domain quality status |
| `docs/exec-plans/active/` | In-progress task plans |

## Prohibitions

→ See `docs/golden-principles.md`

## Logs & Observability

- Session logs: `logs/sessions/<task>/session.jsonl`
- Failure patterns: `logs/trends/failure-patterns.md`
- Validator history: `logs/validators/history.jsonl`
