# Complete Product Recall Database Deployment

## Introduction

Run [`00-deploy-all.sql`](00-deploy-all.sql) from an `ADMIN` SQLcl session connected to the workshop Autonomous AI Database. This self-contained entrypoint inventories and removes the existing Product Recall workshop boundary before it downloads and loads the public embedding model and rebuilds the facilitator baseline for Lab 1. It resets only the named workshop identities, roles, data roles, ORDS module, and objects owned by `RECALL_OWNER`. Learners create the Spatial, graph, vector, agent, API, security, and application objects in Labs 2 through 8. It does not depend on the other SQL files in the lab folders.

The script prompts once for a hidden shared deployment password. It uses that value for the workshop owner, runtime user, and three local Deep Data Security users. During Select AI profile setup, accept the documented OCI region and model defaults unless the facilitator has provided approved alternatives. The password is not stored. Do not place it or the connection descriptor in this repository.

The deployment leaves batch `B-482` in its seeded `REVIEW` / `REPORTED` state. Run Lab 1 Task 2 after deployment to open the investigation.

## Estimated Time: 10 minutes

## Run the deployment

1. Connect to the target database as `ADMIN` with SQLcl.
2. Run [`00-deploy-all.sql`](00-deploy-all.sql).
3. Enter the shared deployment password once. It becomes the password for all workshop identities. Accept the default OCI region and model unless the facilitator has provided approved alternatives.
4. Review the final verification output, then complete the labs in order. Labs 2 through 8 create their own feature objects.

The script stops before reset if the database lacks a required feature, the public ONNX model cannot be downloaded, or another workshop identity has an active session. Otherwise, it displays the existing workshop boundary, removes it, and recreates the baseline from scratch.

Database Actions (SQL Developer Web) is suitable for individual lab SQL, but this entrypoint requires SQLcl because it switches between the `ADMIN` and `RECALL_OWNER` sessions with `CONNECT`. If Database Actions reports `SP2-0738` for `ACCEPT` or `CONNECT`, run the deployment with SQLcl instead.

## Acknowledgements

This deployment uses Oracle Database SQL, Spatial, Property Graph, AI Vector Search, Select AI, ORDS, and Deep Data Security features.
