# Workshop Identity and Security Model

Estimated Time: 5 minutes

## Purpose

The workshop separates database administration, data ownership, application runtime, and business-user authorization. This boundary keeps `ADMIN` out of the application data path and prepares the later Deep Data Security lab.

## Identity Matrix

| Identity | Identity type | Purpose | Owns data? |
|---|---|---|---|
| `ADMIN` | Autonomous Database administrator | Creates users and grants platform privileges | No |
| `RECALL_OWNER` | Database user and schema | Owns tables, views, packages, graph metadata, and security policies | Yes |
| `RECALL_APP_USER` | Database service user | Calls approved packages through `RECALL_API_ROLE` | No |
| `STORE_101_USER` | Deep Data Security local end user | Sees authorized data for store 101 | No |
| `REGION_NE_USER` | Deep Data Security local end user | Sees authorized Northeast regional data | No |
| `RECALL_LEAD_USER` | Deep Data Security local end user | Sees companywide recall response data | No |

## Standard Database Roles

- `RECALL_API_ROLE` grants the application service account `CREATE SESSION` and approved package execution.
- `RECALL_END_USER_LOGIN` supplies `CREATE SESSION` for local Deep Data Security end users during the demonstration.
- `ADMIN` grants `SPATIAL_ADMIN` to `RECALL_OWNER` and allows the platform-managed `SPATIAL$PROXY_USER` to connect through it. These privileges support Spatial Studio without granting the Autonomous Database `ADMIN` role.

These are standard database roles. They do not express row- or column-level data authorization.

Lab 1 connects as `RECALL_OWNER` and opens the focal case with a visible `JSON_TRANSFORM` update. This learner-facing SQL changes both the native JSON workflow state and the relational status columns. Production applications should place that command behind a validated transaction API. `RECALL_LAB_API` exposes approved read operations and is the only package granted through `RECALL_API_ROLE`.

## OCI Principal Boundary

Lab 2 enables OCI principal authentication for `RECALL_OWNER` with delegation disabled. OCI IAM must restrict the Autonomous AI Database resource principal to the approved Generative AI compartment and operations. Database privileges alone do not limit what that external principal can call.

The Lab 5 learner agent receives no built-in SQL tool. Its approved tools return recall and spatial evidence without customer PII. The Lab 8 application agent also receives no SQL tool: `RECALL_REACT_API.ASK_AGENT` assembles product JSON, vector and relational evidence, DDS-filtered Spatial impact, and a compact Graph trace before calling the owner-side agent bridge.

## Deep Data Security Roles

Lab 7 creates these locally managed data roles:

- `RECALL_STORE_101_DATA_ROLE`
- `RECALL_REGION_NE_DATA_ROLE`
- `RECALL_LEAD_DATA_ROLE`

The store grant is the root authorization decision. Customer access follows visible stores, complaint access follows visible customers, and vector-chunk access follows visible complaints. Shared component and supplier-site grants expose recall-wide component trace evidence without exposing customer identity. The same similarity query returns complaint `9001` for the store role. It returns `9001`, `9002`, and `9006` for the Northeast role. The recall lead receives `9001`, `9002`, `9006`, `9003`, and `9007`.

`RECALL_OWNER` retains the only OCI resource principal and owns the agent profile, teams, secured packages, and data grants. `RECALL_APP_USER` receives no OCI principal. Local end users receive `CREATE SESSION` and package execution only through the standard `RECALL_END_USER_LOGIN` role inherited by their data role.

Lab 7 uses two trusted stages. `RECALL_SECURE_API`, with invoker rights, materializes the role-filtered JSON in the local end-user session. The owner-side `RECALL_SECURED_TEAM` then summarizes that captured JSON in a separate session with OCI access. The responder has no SQL or retrieval tool, so it cannot expand beyond the captured role scope.

Lab 8 deploys the React/Node application. It authenticates the local end user and keeps that database session active for role-filtered data, GeoJSON, and the downstream graph projection. The property graph panel combines the narrow definer-rights `RECALL_GRAPH_API` projection for shared component and supplier trace with `RECALL_REACT_API.SECURED_GRAPH`, which runs in the active end-user session and returns only DDS-authorized stores and customers. For an agent question, the invoker-rights `RECALL_REACT_API.ASK_AGENT` materializes product JSON, vector/relational evidence, role-filtered Spatial impact, and compact Graph evidence in that session, then calls the owner-owned definer-rights `RECALL_AGENT_BRIDGE` for Select AI Agent execution. The browser receives no owner password, OCI principal, or unrestricted table access.

The workshop uses direct local database end-user login to make `ORA_END_USER_CONTEXT` visible. A production deployment can use IdM or OCI IAM with supported identity propagation; the database-side data-role behavior remains the same.

## Workshop Simplification

`RECALL_OWNER` receives Deep Data Security policy privileges so attendees can build the grants without moving application data. `ADMIN` creates local end users and assigns their data roles because `RECALL_OWNER` intentionally does not receive `GRANT ANY DATA ROLE`. A production deployment should consider a dedicated security-policy administrator and application-propagated end-user contexts.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
