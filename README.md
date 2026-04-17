# harness-engineering-guide

Harness engineering guide + tooling.

## Structure

| Directory | Description |
|-----------|-------------|
| `docs/guide.md` | Comprehensive harness engineering guide (educational material) |
| `docs/harness-engineering-example/` | Language-agnostic harness template |
| `docs/harness-demo-kotlin/` | Kotlin/Spring Boot applied demo |
| `plugins/harness-init/` | `/harness-init` plugin (4 language presets + manual input) |

## Plugin Installation

```bash
# Register marketplace (one time)
claude plugin marketplace add https://github.com/vljh246v/harness-engineering-guide

# Install plugin
claude plugin install harness-init@harness-engineering-guide
```

## Usage

```bash
# Set up harness in a new project
/harness-init my-api-server

# Apply harness to an existing project
/harness-init
```

## Getting Started

1. Read the [Harness Engineering Guide](docs/guide.md)
2. Review the [template structure](docs/harness-engineering-example/)
3. Check the [Kotlin demo](docs/harness-demo-kotlin/)
4. Set up your project with `/harness-init`
