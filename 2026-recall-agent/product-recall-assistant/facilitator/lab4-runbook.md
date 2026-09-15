# Lab 7 Facilitator Runbook

Estimated Time: 12 minutes

## Introduction

This runbook prepares and validates the role-aware Deep Data Security finale.

### Objectives

- Prepare local end users without exposing passwords in workshop files.
- Install owner-managed data roles, grants, and the secured agent tool.
- Confirm the three expected retrieval scopes before the event.

## Task 1: Prepare the Identities and Policy

1. As `ADMIN`, run `00-admin-create-end-users.sql`. Enter the existing `RECALL_OWNER` lab password once. The script applies it to all three demonstration users.

    Password reuse is a workshop-only simplification. Production users require distinct credentials or enterprise identity management.

2. As `RECALL_OWNER`, run `01-owner-deepsec-policy.sql`.

3. As `ADMIN`, run `02-admin-assign-data-roles.sql`.

4. Confirm that the script output lists one data-role assignment for each local end user. Learners review this ADMIN-side result in Lab 7 Task 1.

5. Do not grant `GRANT ANY DATA ROLE` to `RECALL_OWNER`. ADMIN performs only the role assignments and owns no recall data or policy objects.

## Task 2: Rehearse the Evidence Boundary

1. Create separate SQLcl connections for all three local end users.

2. Run `03-test-secured-vector.sql` through each connection.

3. Confirm the checkpoint matrix in the learner lab exactly. Treat any additional complaint ID as a release blocker.

## Task 3: Rehearse the Agent

1. Run `04-capture-secured-context.sql` as each end user.

2. Reconnect as `RECALL_OWNER` and run `05-run-secured-agent.sql`.

3. Confirm that model wording can vary but data cannot exceed the captured role scope.

4. Do not run the model call inside the direct-login end-user session. Deep Data Security correctly suppresses the owner OCI principal there. The trusted owner service receives only the role-filtered JSON.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
