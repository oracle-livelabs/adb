# Lab 1 Facilitator Runbook

Estimated Time: 20 minutes

## Purpose

Use this runbook to prepare, time, and recover Lab 1.

## Preflight

The July 7, 2026 read-only qualification passed for `admin_gendev_iad`. Review [the recorded test results](../TEST-RESULTS.md) before continuing.

1. Connect to the new Autonomous AI Database as `ADMIN`.
2. Run `investigate-recall/files/00-admin-bootstrap.sql` once.
3. Confirm that `RECALL_OWNER`, `RECALL_API_ROLE`, and `RECALL_END_USER_LOGIN` exist. Verify that `DBA_ROLE_PRIVS` grants `SPATIAL_ADMIN` to `RECALL_OWNER` and that `DBA_PROXIES` lists `SPATIAL$PROXY_USER` as its proxy.
4. Disconnect `ADMIN`. Do not create application data in the `ADMIN` schema.
5. Connect as `RECALL_OWNER`.
6. Run `investigate-recall/files/01-owner-setup.sql`.
7. Run `investigate-recall/files/00-environment-check.sql`.
8. Run `investigate-recall/files/lab1-solution.sql` in SQLcl.
9. Run `investigate-recall/files/01a-generated-data-check.sql`. Confirm every seed table has at least 100 rows, then confirm 120 stores, 2,400 units, 600 customers, 25 component batches, and 25 supplier sites.
10. When the runtime password is available, reconnect as `ADMIN` and run `investigate-recall/files/00b-admin-runtime-user.sql`.
11. Connect as `RECALL_APP_USER` and run `investigate-recall/files/06-runtime-boundary-check.sql`.
12. Confirm package execution succeeds and direct access to `RECALL_OWNER.CUSTOMERS` fails.
13. Reconnect as `RECALL_OWNER` and run `investigate-recall/files/lab1-reset.sql` before learners enter.

## Identity Boundary

- `ADMIN` creates users, roles, and platform grants only.
- `RECALL_OWNER` owns all data and application objects.
- `RECALL_APP_USER` receives no object-creation privilege or tablespace quota.
- Lab 7 will create local Deep Data Security end users named `STORE_101_USER`, `REGION_NE_USER`, and `RECALL_LEAD_USER`.
- Lab 7 will create separate data roles for store, regional, and recall-lead authorization.

## Timing

| Minute | Checkpoint |
|---:|---|
| 0-2 | The case row contains native JSON with workflow state `REPORTED`. |
| 2-4 | `JSON_TRANSFORM` opens the case and the batch becomes `INVESTIGATING`. |
| 4-7 | Recall scope counts match. |
| 7-10 | Product, component, and complaint JSON evidence matches. |

## Recovery

- If a learner falls more than three minutes behind, provide `lab1-solution.sql`.
- If the case is already open, run `lab1-reset.sql` to restore `REVIEW` and `REPORTED`.
- If other JSON output differs, restore the seeded values from the owner setup.
- If a learner needs the full checkpoint, provide `03-converged-investigation.sql`.

## Publication Gate

Do not publish the lab until the SQL runs on the exact event release update and a new learner completes the core path in 10 minutes or less. Confirm the `ADMIN`, owner, service-account, and future Deep Data Security boundaries during the same rehearsal.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
