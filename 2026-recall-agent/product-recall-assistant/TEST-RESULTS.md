# Test Results

Estimated Time: Not applicable

## Current Validation Status

This record replaces the earlier five-lab baseline. The July 2026 workshop now contains eight focused labs:

1. JSON evidence
2. Oracle Spatial
3. SQL Property Graph
4. AI Vector Search
5. Select AI Agent
6. ORDS API delivery
7. Deep Data Security
8. React/Node command center

## Generated Data Validation

- On July 10, 2026, `01-owner-setup.sql` completed on Oracle AI Database 26ai through the saved owner connection.
- `admin_gendev_iad` granted `SPATIAL_ADMIN` to `RECALL_OWNER` as a default role. It also enabled the required Spatial proxy connection.
- `DBA_PROXIES` returned the expected owner and `SPATIAL$PROXY_USER` pair with authentication `NO`.
- `01a-generated-data-check.sql` confirmed at least 100 rows in all 22 seed tables. Counts range from 100 to 1,001.
- On July 13, Oracle 26ai executed the new JSON seed, `JSON_TRANSFORM` open, and reset expressions in standalone SQL checks.
- Oracle 26ai also parsed both guarded table updates inside a savepoint; the validation rolled back without changing shared data.
- The shared schema was not rebuilt for this check because that would replace artifacts from Labs 2 through 8.
- The validated `B-482` scope includes:
  - 120 affected stores
  - 2,400 shipped units
  - 600 potentially exposed customers
  - 25 component batches
  - 25 supplier or sub-vendor sites
  - 5 top semantic complaints: `9001`, `9002`, `9006`, `9003`, and `9007`
- Earlier live SQL checks passed for native JSON, SQL Property Graph, deterministic vector ranking, Spatial coverage, and these role scopes:
  - `STORE_101_USER`: 1 store, 12 units, 5 customers, complaint `9001`
  - `REGION_NE_USER`: 24 stores, 453 units, 120 customers, complaints `9001`, `9002`, and `9006`
  - `RECALL_LEAD_USER`: 120 stores, 2,400 units, 600 customers, complaints `9001`, `9002`, `9006`, `9003`, and `9007`
- The public GenDev ORDS health route returned `HTTP 401 Unauthorized` and the expected JSON body. Anonymous callers cannot access the module.
- Rerunning the Lab 7 owner policy restored 60 `USER_DATA_GRANTS` rows, including the shared response-center reference grant used by Lab 8 Spatial evidence. The Task 1 filter returned 14 grant-to-role rows.
- `RECALL_SECURE_API` compiled valid. ADMIN verified all three end-user data-role assignments.
- Fresh Lab 7 sessions use top-ranked cosine results below a `0.70` cosine-distance ceiling. Each persona receives only its approved complaint IDs, even when model-specific distances vary.
- The identity preflight rejected a schema-user connection with `ORA-20045`.
- Fresh Lab 7 sessions hold the current persona scopes. The regional secured result contains `24/453/120` and 24 map rows.
- The Lab 7 security checks passed all metric, complaint, map, and answer checks.
- Deterministic inland metro clusters keep every store and supplier site inside continental U.S. bounds. Spatial coverage includes all 120 affected stores.
- On July 13, an isolated Oracle 26ai scratch-table test promoted numeric coordinates with `SDO_GEOMETRY(longitude, latitude)`.
- The test created a valid `MDSYS.SPATIAL_INDEX_V2` index and confirmed that Oracle generated SRID `4326` metadata automatically.
- Validation removed every scratch object and its generated metadata. The test changed no shared workshop tables.
- The repository now defers `RECALL_GRAPH` creation until Lab 3 Task 1. A clean end-to-end rebuild remains a publication check.
- On July 13, the owner setup created six valid graph-supporting indexes. Lab 3 refreshed `RECALL_GRAPH` in GenDev; live graph checks returned 25 component paths and 600 exposure paths.
- On July 14, the graph-only Lab 3 setup recreated `RECALL_GRAPH` successfully against the prepared GenDev schema and returned all 15 expected graph labels.
- The Lab 4 ONNX model path now replaces the deterministic vectors. A fresh live run with the Object Storage URI and credential remains a publication check.
- On July 16, the ADMIN vector-grant script ran successfully in GenDev. `RECALL_OWNER` created and removed a temporary credential, confirming the owner-scoped `DBMS_CLOUD` path.
- Lab 5 registered enabled `RECALL_CONTEXT_TOOL` and `RECALL_SPATIAL_TOOL` tools, investigator, task, and team. One live conversation completed all five turns without a failed turn.
- The spatial agent turn returned 120 affected stores within the 25-kilometer response radius across five regions: Atlantic 33, Midwest 33, Northeast 24, South 15, and West 15.
- The transcript returned the approved case, scope, component timing, vector complaints, first action, and executive handoff.
- The JSON context exposes `customerContactAuthorized: false`. The agent reported that customer contact remains unauthorized and executed no action.
- The package retains `ASK_RECALL_AGENT` only as a compatibility wrapper around `GET_AUTHORIZED_AGENT_ANSWER`.
- The Lab 8 bridge now assembles a combined product JSON, vector/relational, DDS-filtered Spatial, and compact Graph evidence document before `RUN_TEAM`. A fresh live check should confirm the three personas receive different converged answers while the shared component/supplier trace remains common.
- On July 23, SQLcl reran the Lab 7 owner policy and Lab 8 bridge as `RECALL_OWNER`. All four bridge packages compiled `VALID`; `USER_DATA_GRANTS` returned 60 assignments, including `DG_RESPONSE_CENTERS_READ` for all three data roles.
- The same-day read-only persona smoke test passed through the application packages: `STORE_101_USER` returned `1/5/1`, `REGION_NE_USER` returned `24/120/24`, and `RECALL_LEAD_USER` returned `120/600/120` for graph stores, graph customers, and map features. The corrected `SECURED_GRAPH` no longer depends on the owner-only `RECALL_AFFECTED_STORES_V` view.

## Remaining Manual Check

- Start the React/Node application and sign in as each persona. Confirm that the live counts, map, complaint evidence, and agent answer match the Lab 7 checkpoints.
- Ask the same Spatial/Graph questions as all three personas and confirm that response regions, centers, stores, customers, and complaint evidence remain role-specific while component and supplier trace stays shared.
- Rehearse the clean Lab 1 through Lab 3 path. Confirm Lab 1 has no graph, then create `RECALL_GRAPH` and run all three graph traversals in Lab 3.
- Run Lab 4 with the Object Storage URI for `all-MiniLM-L12-v2.onnx`, then confirm all complaint chunks and query rows contain 384-dimensional embeddings.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
