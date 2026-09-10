# Source Traceability

Estimated Time: Not applicable

| Workshop element | Source or validation basis | Implementation |
|---|---|---|
| Product recall business scenario | Original `Recall_Agent_HOL.md` concept brief plus July 2026 cleanup request | Batch `B-482`, component lots, supplier sites, stores, purchases, and complaints |
| Native JSON | Oracle AI Database 26ai JSON documentation | `PRODUCTS.ATTRIBUTES`, `COMPONENT_BATCHES.ATTRIBUTES`, `COMPLAINTS.COMPLAINT_DATA`, `JSON_TABLE`, and `JSON_VALUE` |
| Spatial analysis | Oracle AI Database 26ai Spatial Developer Guide | `SDO_GEOMETRY`, spatial indexes, store and supplier-site proximity, and GeoJSON |
| SQL property graph | Oracle AI Database 26ai SQL reference | `RECALL_GRAPH`, component/supplier paths, exposure paths, and `GRAPH_TABLE` |
| Vector search | Oracle AI Vector Search documentation | `VECTOR(384, FLOAT32)` columns, in-database ONNX embeddings, and `VECTOR_DISTANCE` |
| Select AI Agent | Oracle Select AI Agent guide and `DBMS_CLOUD_AI_AGENT` package reference | Owner-local profile, governed recall and spatial package tools, converged role-aware evidence document, investigator, task, and team |
| Protected API delivery | Oracle REST Data Services documentation | PII-safe owner package and authenticated read-only JSON and GeoJSON routes |
| Autonomous identity separation | Autonomous AI Database user-management guidance | `ADMIN`, `RECALL_OWNER`, `RECALL_APP_USER`, and standard database roles |
| Security finale | Deep Data Security source article and Oracle guide | Lab 7 mirrors local end users, regional roles, parent-child grants, and secured vector search |
| Unified capstone | React, Node.js, Leaflet, and Oracle Database documentation | React/Node command center, local-user sign-in, secured JSON/vector/Spatial/Graph evidence, live converged agent answers, and database-session authorization |

## Security Design Traceability

- `ADMIN` performs only the identity and platform-grant bootstrap.
- `RECALL_OWNER` owns all Lab 1 objects. It receives the system privileges required by the Select AI Agent and Deep Data Security labs.
- `RECALL_APP_USER` receives package execution through `RECALL_API_ROLE` and no direct table access.
- Local end users remain distinct from traditional database users. Deep Data Security data roles and grants control their access.
- Complaint-chunk authorization follows the parent complaint, which follows the authorized customer and store, matching the referenced secured-vector pattern.
- `RECALL_REACT_API.ASK_AGENT` assembles product JSON, vector/relational evidence, DDS-filtered Spatial impact, and compact Graph evidence before the owner-side agent handoff.
- `06-runtime-boundary-check.sql` proves the service account can call the approved package but cannot query the customer table directly.
- `00-admin-bootstrap.sql` creates only the owner and shared roles; `00b-admin-runtime-user.sql` creates the service account after its password is chosen.
- `00-admin-agent-prereqs.sql` enables OCI principal use without delegation; OCI IAM remains the external authorization boundary.
- `RECALL_CONTEXT_TOOL` exposes only `RECALL_LAB_API.GET_RECALL_CONTEXT` and does not grant the agent arbitrary SQL access.

## Runtime Validation Status

The LiveLabs structure and markdown have local static validation. Earlier live SQLcl validation covered the smaller five-lab baseline. The July 2026 cleanup expands the seed data and splits the flow into eight focused labs. Run a fresh live database retest before treating the HOL as database-tested. See [Test Results](TEST-RESULTS.md).

## Acknowledgements

- **Author:** Oracle AI World 2026 Product Recall Assistant workshop team
- **Last updated:** July 2026
