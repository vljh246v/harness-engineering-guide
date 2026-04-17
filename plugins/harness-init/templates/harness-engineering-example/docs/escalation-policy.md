# Escalation Policy — Changes Requiring Human Approval

A list of changes that the agent **must never proceed with alone**.
Changes in the categories below require human approval before proceeding.

---

## High-Risk Categories

### 1. Database Schema Changes

- Table create/drop, column changes, index add/remove
- Migration files (Flyway, Liquibase, SQL, etc.)
- ORM entity mapping changes

### 2. Authentication / Authorization Logic

- Login, session, token-related code changes
- Permission check (RBAC, ACL) logic changes
- OAuth, SSO integration changes

### 3. Security Configuration

- Secrets, environment variables, certificate settings
- CORS, CSP, security header changes
- Security patches for dependencies (major version)

### 4. Payment / Billing

- Payment SDK integration changes
- Amount calculation logic changes
- Webhook signature verification logic

### 5. External API Integration

- Adding new external service integrations
- API key, endpoint changes
- Rate limit, timeout configuration changes

### 6. Build / Deployment

- CI/CD pipeline changes
- Dockerfile, K8s manifest changes
- Deployment script changes

### 7. Harness Self-Modification

- Disabling validators or relaxing rules
- Modifying CLAUDE.md, golden-principles.md
- Disabling pre-edit hooks

---

## Procedure

1. **Write exec-plan**: Include the following in `docs/exec-plans/active/<type>-<task-id>.md`:
   - **Impact**: Scope affected by this change
   - **Rollback**: How to revert if something goes wrong
   - **Verification**: How to confirm correct behavior

2. **Human approval**: Show the exec-plan to a human and get approval

3. **Proceed**: After approval, implement in the worktree → task-finish.sh

4. **Emergency changes**: If proceeding without approval, hold a retrospective within 24 hours + log in agent-failures.md

---

## References

- Core principles: `docs/design-docs/core-beliefs.md`
- Failure log: `docs/agent-failures.md`
