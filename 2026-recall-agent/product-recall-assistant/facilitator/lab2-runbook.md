# Lab 5 Facilitator Runbook

## Introduction

Prepare, validate, and recover the Product Recall Assistant Select AI Agent lab.

Estimated Time: 20 minutes

### Objectives

- Configure the OCI principal and owner-local AI profile.
- Verify the custom package tool signature.
- Register and run the recall agent team.
- Preserve the ADMIN, owner, and runtime identity boundaries.

## Task 1: Prepare Lab 5

1. Confirm that OCI IAM limits the database resource principal to approved Generative AI operations.

2. Connect as `ADMIN` and run `build-recall-assistant/files/00-admin-agent-prereqs.sql` once.

3. Disconnect `ADMIN`. Do not use it for learner tasks or agent ownership.

4. Connect as `RECALL_OWNER` and run `build-recall-assistant/files/01-create-agent-profile.sql`.

5. Supply the approved Generative AI region and model when prompted. The profile uses the database compartment by default.

6. Confirm that `RECALL_AGENT_PROFILE` shows `ENABLED`.

7. Run `build-recall-assistant/files/lab2-solution.sql`.

8. Check the answer. Expect 120 stores, 2,400 units, 600 exposed customers, 25 component batches, 25 supplier or sub-vendor sites, complaints 9001/9002/9006/9003/9007, and quarantine first.

## Task 2: Validate Security Boundaries

1. Confirm that `RECALL_OWNER` owns the profile, tool, agent, task, and team.

2. Confirm that the resource-principal grant uses `grant_option => false`.

3. Confirm that the custom tool calls only `RECALL_LAB_API.GET_RECALL_CONTEXT`.

4. Confirm that the tool payload contains no customer names or email addresses.

5. Do not grant a built-in SQL tool to the recall agent.

## Task 3: Recover the Lab

1. Run `build-recall-assistant/files/lab2-reset.sql` as `RECALL_OWNER`.

2. Rerun `02-register-recall-agent.sql` and `03-run-recall-agent.sql`.

3. If OCI returns `ORA-20404`, inspect every profile value without column truncation. Confirm the region supports the model. Omit `oci_compartment_id` when the model uses the database compartment.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
