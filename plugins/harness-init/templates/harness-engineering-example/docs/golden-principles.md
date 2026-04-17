# Golden Principles — Accumulated Rules for the Agent

A list of principles promoted from repeated failures in `agent-failures.md`.
Each principle originates from an actual failure and is structurally enforced where possible.

## Promotion Criteria

- Same pattern 2+ times in `agent-failures.md` → add principle here
- Same pattern 3+ times → automated enforcement via lint/test/validator required

---

## Principles

### GP-001: Do not modify source code without a worktree

- **Why**: Editing outside a worktree directly contaminates develop/main
- **Instead**: Run `./scripts/task-start.sh <task-id>` and work inside the worktree
- **Enforcement**: `.claude/hooks/pre-tool-use.sh` — checks worktree status before src/ file edits

### GP-002: Do not commit .env or secret files to git

- **Why**: Once in git history, complete removal is extremely difficult
- **Instead**: Add to `.gitignore` + use environment variables or a secrets manager
- **Enforcement**: `04-security.sh` — detects committed .env files via `git ls-files`

### GP-003: Do not add business logic without tests

- **Why**: Untested code silently breaks on the next change
- **Instead**: Include tests in the same commit as the feature code
- **Enforcement**: `02-test.sh` — all tests must pass

### GP-004: Do not bypass validators

- **Why**: Code merged by bypassing validators burdens the entire team
- **Instead**: Fix the code if a validator fails. If the validator itself is wrong, fix the validator and document it
- **Enforcement**: `task-finish.sh` — merge is blocked without passing all validators

> When adding a new principle, assign `GP-{N+1}` and always fill in **Why / Instead / Enforcement**.
> If **Enforcement** is "documentation only", it must be escalated to structural enforcement after 3 recurrences.
