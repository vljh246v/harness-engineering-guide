# Agent Failures — Agent Failure Log

Records mistakes made by the agent and the structural responses taken.
This document is the starting point for harness evolution.

## Promotion Policy

- Same pattern **2 recurrences** → add principle to `golden-principles.md`
- Same pattern **3 recurrences** → **structural prevention** via lint/test required
- Monthly review by GC agent

## Failure Log

| ID | Date | Symptom | Root Cause | Remediation | Domain |
|----|------|---------|------------|-------------|--------|
| F-0001 | (example) | Edited code directly on develop without worktree | Ignored worktree rule in CLAUDE.md | Blocked by pre-edit hook (exit 2), core-beliefs #1 | Workflow |
| F-0002 | (example) | .env file included in commit | Used git add -f, bypassed .gitignore | Added git ls-files check in 04-security validator | Security |

> Delete the examples above and record actual failures.

## How to Record

When a new failure occurs, add a row with these fields:

- **ID**: `F-YYYY-MM-DD-N` (increment N for multiple entries on the same day)
- **Symptom**: Externally observable behavior (error message, incorrect behavior)
- **Root Cause**: Structural reason that "try harder" won't fix
- **Remediation**: Specific response — ADR, lint rule, validator, document link, etc.
- **Domain**: Workflow / Security / Architecture / Test / Documentation, etc.

## References

- Promotion targets: `docs/golden-principles.md`
- High-risk changes: `docs/escalation-policy.md`
- Validator history: `logs/validators/history.jsonl`
