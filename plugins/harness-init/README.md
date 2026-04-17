# harness-init

Harness engineering scaffolding for Claude Code.

## What It Does

Initialize a new harness-based project or apply harness infrastructure to an existing project. Supports 4 language presets: Kotlin, Python, TypeScript, Go.

Two modes:
- **New project**: Creates a directory with full harness infrastructure
- **Existing project**: Adds harness infrastructure to an existing codebase (never touches application code)

## Skills

### harness-init

Run `/harness-init [project-name]` to:

1. Choose mode (new project or existing)
2. Select language/framework preset
3. Copy template + apply language-specific configuration
4. Generate project-specific CLAUDE.md, ARCHITECTURE.md, harness.config.sh

```text
> /harness-init my-api-server

Claude: "Which language/framework are you using?"
  1. Kotlin (Spring Boot)
  2. Python (FastAPI)
  3. TypeScript (Express)
  4. Go (net/http)
  5. Other (manual input)

User: "1"

Claude: [generates harness files + applies Kotlin preset]

[HARNESS-INIT] Done!
  Project  : my-api-server
  Language : Kotlin (Spring Boot)
  Location : /path/to/my-api-server
```

## Supported Presets

| Language | Framework | Build | Test | Lint |
|----------|-----------|-------|------|------|
| Kotlin | Spring Boot | `./gradlew compileKotlin` | `./gradlew test` | `./gradlew ktlintCheck` |
| Python | FastAPI | (skip) | `pytest` | `ruff check .` |
| TypeScript | Express | `npm run build` | `npm test` | `npm run lint` |
| Go | net/http | `go build ./...` | `go test ./...` | `golangci-lint run` |
| Other | Manual input | Manual input | Manual input | Manual input |

Any language/framework works — the 4 presets are shortcuts, not limitations.

## Installation

```bash
# Register the marketplace (one time)
claude plugin marketplace add https://github.com/vljh246v/harness-engineering-guide

# Install the plugin
claude plugin install harness-init@harness-engineering-guide
```

## What Gets Generated

```text
my-project/
├── .claude/          ← hooks, skills, settings (language-specific permissions)
├── agents/           ← planner, generator, evaluator, gc agent definitions
├── docs/             ← knowledge base (ADRs, golden-principles, escalation-policy)
├── logs/             ← session logs, failure patterns, validator history
├── scripts/          ← task-start.sh, verify-task.sh, task-finish.sh, validators
├── harness.config.sh ← BUILD/TEST/LINT commands (preset-configured)
├── CLAUDE.md         ← agent entry point (language-specific)
├── ARCHITECTURE.md   ← layer structure (language-specific)
└── README.md         ← project overview
```

## Adding New Language Presets

Edit `skills/harness-init/SKILL.md`:
1. Add a new preset data block
2. Add a new option in Step 3
3. Add package structure + rules for Step 7
4. Bump version in `plugin.json`
