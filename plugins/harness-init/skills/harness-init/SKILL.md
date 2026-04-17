---
name: harness-init
description: Use when initializing a new harness-based project or applying harness infrastructure to an existing project. Triggered by /harness-init command.
argument-hint: "[project-name]"
disable-model-invocation: true
---

# /harness-init — Initialize a Harness Project

Creates a new project based on the `harness-engineering-example` template,
or applies harness infrastructure to an existing project.

Template source: `${CLAUDE_PLUGIN_ROOT}/templates/harness-engineering-example/`

---

## Step 1. Choose Mode

Ask the user:

```
How would you like to apply the harness?
  1. New project   — create full harness in an empty directory
  2. Existing project — add harness infrastructure to an existing project
```

- **New project**: proceed to Step 2
- **Existing project**: ask for the project path. Verify the path exists with `ls`. Proceed to Step 3.

---

## Step 2. Project Name (New Project Mode)

- If `$ARGUMENTS` is not empty, use it as the project name
- If empty, ask: "Project name? (this becomes the directory name)"
- Create location: `$(pwd)/{project-name}/` under the current working directory
- If the directory already exists:
  ```
  {project-name}/ already exists.
    1. Switch to existing project mode (keep existing files, add harness only)
    2. Cancel
  ```

---

## Step 3. Language/Framework Selection

```
Which language/framework are you using?
  1. Kotlin      (Spring Boot)
  2. Python      (FastAPI)
  3. TypeScript   (Express / Node.js)
  4. Go           (net/http stdlib)
  5. Other        (manual input)
```

- Options 1~4: use the preset data below.
- Option 5: proceed to the "Other (manual input)" flow → go to Step 3-1.

---

## Step 3-1. Other (Manual Input) Flow

If the user selected option 5 "Other", ask these questions in order:

1. **Language**: "Which programming language? (e.g. Rust, Scala, C#)"
2. **Framework**: "Framework? (enter 'none' if not applicable, e.g. Actix-web, Play Framework, ASP.NET)"
3. **Build command**: "Build command? (enter 'none' if no build step, e.g. cargo build)"
4. **Test command**: "Test command? (e.g. cargo test)"
5. **Lint command**: "Lint command? (e.g. cargo clippy)"
6. **Layer structure**: "List your project layers, up to 4 (e.g. handler / service / repository / model)"
7. **Source path**: "Source code root path? (e.g. src/, lib/, internal/)"

Fill in the preset variables from the user's responses:

```
LANGUAGE="{user input}"
FRAMEWORK="{user input, empty string if 'none'}"
BUILD_CMD="{user input, echo '[SKIP] no build step' if 'none'}"
TEST_CMD="{user input}"
LINT_CMD="{user input}"
LAYERS="{user input layers}"
LAYER_ARROW="{layers joined with →}"
PERMISSIONS=[extracted from user input commands, e.g. cargo → "Bash(cargo *)"]
```

From here, Steps 4~10 proceed identically to presets.

**When editing ARCHITECTURE.md:**
- Package structure: create a directory tree from the user's path + layers
- Rules: generate typical dependency rules based on layer names:
  - "{first layer} must not directly access {third layer}"
  - "{last layer} has no external dependencies"
  - "Business logic belongs only in {second layer}"

---

## Preset Data

### Kotlin (Spring Boot)

```
FRAMEWORK="Spring Boot"
LANGUAGE="Kotlin"
BUILD_CMD="./gradlew compileKotlin compileTestKotlin --quiet"
TEST_CMD="./gradlew test"
LINT_CMD="./gradlew ktlintCheck"
LAYERS="controller / service / repository / domain"
LAYER_ARROW="controller → service → repository → domain"
PERMISSIONS=["Bash(./gradlew *)"]
```

**Package structure:**
```
src/main/kotlin/com/example/{project}/
├── controller/       # @RestController — HTTP request/response handling
├── service/          # @Service — business rules, validation
├── repository/       # @Repository — data storage/retrieval
└── domain/           # data class — pure models (no dependencies)
```

**Rules:**
- `controller` must not directly inject `repository`
- `domain` must not contain Spring annotations
- Business logic belongs only in `service`
- Validation (`require`, `check`) only in the `service` layer

### Python (FastAPI)

```
FRAMEWORK="FastAPI"
LANGUAGE="Python"
BUILD_CMD="echo '[SKIP] Python needs no build step'"
TEST_CMD="pytest"
LINT_CMD="ruff check ."
LAYERS="router / service / repository / schema"
LAYER_ARROW="router → service → repository → schema"
PERMISSIONS=["Bash(pytest)", "Bash(ruff *)"]
```

**Package structure:**
```
app/
├── router/           # @router — HTTP endpoint definitions
├── service/          # Business logic, validation
├── repository/       # Data storage/retrieval (SQLAlchemy, etc.)
└── schema/           # Pydantic models — request/response schemas
```

**Rules:**
- `router` must not directly access `repository`
- `schema` must not import SQLAlchemy
- Business logic belongs only in `service`
- Use `Depends()` for dependency injection

### TypeScript (Express)

```
FRAMEWORK="Express"
LANGUAGE="TypeScript"
BUILD_CMD="npm run build"
TEST_CMD="npm test"
LINT_CMD="npm run lint"
LAYERS="controller / service / repository / model"
LAYER_ARROW="controller → service → repository → model"
PERMISSIONS=["Bash(npm *)"]
```

**Package structure:**
```
src/
├── controller/       # Express Router — HTTP request/response handling
├── service/          # Business logic, validation
├── repository/       # Data storage/retrieval (TypeORM/Prisma, etc.)
└── model/            # TypeScript interfaces — pure type definitions
```

**Rules:**
- `controller` must not call the DB directly
- `model` must not import framework modules
- Business logic belongs only in `service`
- Use interfaces for dependency inversion

### Go (net/http)

```
FRAMEWORK="net/http"
LANGUAGE="Go"
BUILD_CMD="go build ./..."
TEST_CMD="go test ./..."
LINT_CMD="golangci-lint run"
LAYERS="handler / service / repository / model"
LAYER_ARROW="handler → service → repository → model"
PERMISSIONS=["Bash(go *)", "Bash(golangci-lint *)"]
```

**Package structure:**
```
internal/
├── handler/          # http.Handler — HTTP request/response handling
├── service/          # Business logic, validation
├── repository/       # Data storage/retrieval
└── model/            # Pure structs — domain models
cmd/
└── server/
    └── main.go       # Entry point
```

**Rules:**
- `handler` must not directly import `repository`
- `model` package has no external dependencies
- Business logic belongs only in `service`
- Use interfaces for dependency injection

---

## Step 4. Copy Template

Template source: `${CLAUDE_PLUGIN_ROOT}/templates/harness-engineering-example/`

### New Project Mode

```bash
cp -r "${CLAUDE_PLUGIN_ROOT}/templates/harness-engineering-example/" "{target-path}/"
```

### Existing Project Mode

Copy each file from the manifest individually.

**Copy manifest:**

```
.claude/hooks/pre-tool-use.sh
.claude/hooks/post-tool-use.sh
.claude/settings.json
.claude/skills/harness-task/SKILL.md
.claude/skills/code-review/SKILL.md
.claude/skills/debugging/SKILL.md
.claude/skills/test-generation/SKILL.md
agents/evaluator-agent.md
agents/gc-agent.md
agents/generator-agent.md
agents/planner-agent.md
docs/agent-failures.md
docs/design-docs/ADR-0001-worktree-isolation.md
docs/design-docs/ADR-0002-validation-pipeline.md
docs/design-docs/core-beliefs.md
docs/design-docs/index.md
docs/escalation-policy.md
docs/exec-plans/active/.gitkeep
docs/exec-plans/completed/.gitkeep
docs/exec-plans/tech-debt-tracker.md
docs/golden-principles.md
docs/playbooks/README.md
docs/QUALITY_SCORE.md
docs/references/.gitkeep
logs/sessions/.gitkeep
logs/trends/failure-patterns.md
logs/validators/history.jsonl
scripts/task-start.sh
scripts/task-finish.sh
scripts/task-cleanup.sh
scripts/verify-task.sh
scripts/validators/01-build.sh
scripts/validators/02-test.sh
scripts/validators/03-lint.sh
scripts/validators/04-security.sh
scripts/validators/05-docs-freshness.sh
harness.config.sh
CLAUDE.md
ARCHITECTURE.md
README.md
.gitignore
```

For each file:
- **Does not exist**: create parent directories, then copy
- **Already exists**: ask the user:
  ```
  {filepath} already exists.
    1. Skip (keep existing)
    2. Overwrite (replace with harness version)
    3. Merge (keep existing content + add harness content)
    4. Show diff (compare before deciding)
  ```
  **Merge (option 3) behavior:**
  - `.gitignore`: append harness-specific entries (`.worktrees/`, `logs/sessions/`, `.env`, `.DS_Store`, etc.) without duplicates
  - `.claude/settings.json`: merge harness hooks/skills/permissions entries into existing JSON. Keep existing entries + add new ones. Confirm individually on conflicting keys
  - Other text files: append harness content after a separator (`# --- harness ---`)
  - Confirm individually on conflicting keys

**Protected paths (never touch):**
```
src/, app/, internal/, cmd/
build.gradle*, settings.gradle*
package.json, package-lock.json, tsconfig.json
go.mod, go.sum
requirements.txt, pyproject.toml
Dockerfile, docker-compose*
.gitignore (existing)
```

---

## Step 5. Edit harness.config.sh

**Transformation rules:**

1. First-line comment:
   ```bash
   # harness.config.sh — {LANGUAGE} / {FRAMEWORK} project harness configuration
   ```

2. Set PROJECT_NAME:
   ```bash
   PROJECT_NAME="{project-name}"
   ```

3. **Remove the language example comment block** — delete from:
   ```
   # --- Kotlin / Spring Boot ---
   ```
   through:
   ```
   LINT_CMD="${LINT_CMD:-echo '[SKIP] LINT_CMD not configured'}"
   ```

4. **Set BUILD/TEST/LINT directly** — no fallbacks:
   ```bash
   BUILD_CMD="{preset BUILD_CMD}"
   TEST_CMD="{preset TEST_CMD}"
   LINT_CMD="{preset LINT_CMD}"
   ```

5. Keep all other settings (Git Flow, branches, security, validators) **as-is**

---

## Step 6. Edit CLAUDE.md

**Transformation rules:**

1. Title: `# CLAUDE.md — {project-name}`

2. Project section:
   ```markdown
   ## Project

   {FRAMEWORK} + {LANGUAGE} project. [Describe your project here]
   ```

3. Rename "Workflow" section to "Development Flow" and add branch info:

   Section title: `## Development Flow`

   Body:
   - First line: `Branch: \`develop\` (base) → \`feature/<TICKET_KEY>\``
   - Second line: `**Do not directly modify main / develop branches**`
   - Code block (plain text): `task-start.sh → (auto-generate exec-plan) → implement → verify-task.sh → task-finish.sh`
   - Keep the start/mid-check/finish list as-is

4. Add code block to "Build & Test" section:

   Below `Config: \`harness.config.sh\`` add a bash code block:
   - `{BUILD_CMD}   # build`
   - `{TEST_CMD}    # test`
   - `{LINT_CMD}    # lint`

5. Update ARCHITECTURE.md description in "Key Documents" table:
   ```
   | `ARCHITECTURE.md` | Layers: {LAYER_ARROW} |
   ```

6. Keep all other sections **as-is**

---

## Step 7. Edit ARCHITECTURE.md

**Transformation rules:**

1. Layer diagram (ASCII box) — **keep as-is**
2. Dependency direction rules — **keep as-is**
3. Cross-Cutting Concerns — **keep as-is**

4. **Replace the "Package Structure" section with the preset's package structure** — title matches the language:
   - Kotlin: `## Package Structure`
   - Python: `## Package Structure`
   - TypeScript: `## Package Structure`
   - Go: `## Package Structure`

   Use the package structure from the preset data above.

5. **Validator error message example — keep as-is** (language-agnostic)

6. **Add "Rules" section** (add if missing, replace if present):
   ```markdown
   ## Rules

   - {preset rule 1}
   - {preset rule 2}
   - {preset rule 3}
   - {preset rule 4}
   ```

---

## Step 8. Edit README.md

1. Reflect the project name in the title
2. Add language/framework context
3. Replace build commands with preset values
4. Keep the rest of the workflow description as-is

---

## Step 9. Edit .claude/settings.json

**Transformation rules:**

Keep hooks, skills, and deny list **as-is**.

Remove unnecessary language tools from `permissions.allow` and keep only what's needed:

- **Always keep**: `Bash(./scripts/*)`, `Bash(git *)`
- **Kotlin**: add `Bash(./gradlew *)`
- **Python**: add `Bash(pytest)`, `Bash(ruff *)`
- **TypeScript**: add `Bash(npm *)`
- **Go**: add `Bash(go *)`, `Bash(golangci-lint *)`

---

## Step 10. Finish

1. Set script permissions:
   ```bash
   chmod +x {target}/.claude/hooks/*.sh
   chmod +x {target}/scripts/*.sh
   chmod +x {target}/scripts/validators/*.sh
   ```

2. Print completion message:
   ```
   [HARNESS-INIT] Done!

     Project  : {project-name}
     Language : {LANGUAGE} ({FRAMEWORK})
     Location : {absolute-path}

     Modified files:
       - harness.config.sh     (BUILD/TEST/LINT configured)
       - CLAUDE.md             (project description + build examples)
       - ARCHITECTURE.md       (layer structure + package paths)
       - README.md             (project name + language)
       - .claude/settings.json (language-specific permissions)

     Next steps:
       1. cd {project-path}
       2. Review harness.config.sh — verify that BUILD_CMD, TEST_CMD, LINT_CMD
          match your project's actual build/test/lint tools.
          Presets are a starting point; you may need to adjust.
       3. Review ARCHITECTURE.md and adjust layer names
       4. Review docs/escalation-policy.md (define high-risk areas)
       5. Review docs/design-docs/core-beliefs.md (team principles)
       6. Test with /harness-task TEST-001 sample feature
   ```

---

## Notes

- Template source path must always use `${CLAUDE_PLUGIN_ROOT}/templates/harness-engineering-example/`
- Never touch the existing project's application code (src/, build files, etc.)
- Do not auto-commit in git-initialized projects — let the user decide
- All documentation and comments are written in English
- Guide the user to review key documents after generation
