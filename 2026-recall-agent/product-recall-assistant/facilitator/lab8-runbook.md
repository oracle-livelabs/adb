# Lab 8 Facilitator Runbook

## Introduction

This runbook prepares and rehearses the standalone React/Node command center used in Lab 8. Legacy application artifacts are archived and are not part of the learner workshop flow.

Estimated Time: 22 minutes

### Objectives

- Prepare the database bridge package for the React application.
- Start or deploy the React/Node application against the lab Autonomous Database.
- Demonstrate all three Deep Data Security local-user experiences.
- Demonstrate one secured agent team using JSON, Vector, Spatial, and Graph evidence.
- Explain how the local-user demonstration maps to an IdM or OCI IAM deployment.

## Task 1: Prepare the Database Bridge

1. Connect as `RECALL_OWNER` and run `05-prepare-react-app.sql` from the Lab 8 directory.

2. Confirm `RECALL_AGENT_BRIDGE` and `RECALL_REACT_API` are `VALID`.

3. Confirm `RECALL_REACT_API` exposes `ASK_AGENT`, `CURRENT_IDENTITY`, `PRODUCT_CONTEXT`, and `SECURED_STORES`. `ASK_AGENT` internally assembles product JSON, vector/relational evidence, role-filtered Spatial impact, and compact Graph evidence; the helper functions are intentionally not granted as separate end-user retrieval endpoints.

4. Verify that `RECALL_SECURED_TEAM` is enabled and that `RECALL_AGENT_PROFILE` is available before starting the application.

## Task 2: Start the Application

1. In `product-recall-assistant/react-app`, run `npm install` and copy `.env.example` to `.env`.

2. Set `ORACLE_CONNECT_STRING` to the TLS database connection string copied from the Autonomous Database **Database connection** dialog, or to a wallet TNS alias such as `gendev_high`. Do not use the ORDS HTTPS URL. For a wallet alias, set `ORACLE_CONFIG_DIR`, `ORACLE_WALLET_LOCATION`, and the wallet download password. The application accepts only the three Lab 7 Deep Data Security users; `RECALL_OWNER` is never an application login.

3. Run `npm run dev:all` and open `http://localhost:3001`. The Node API and React UI share one port. Restart the application after any `.env` change.

4. For a production-style local check, run `npm run build` followed by `npm start`, then open `http://localhost:3001`.

## Task 3: Rehearse the Three User Views

1. Sign in as `STORE_101_USER`. Confirm one store, 12 units, five customers, complaint `9001`, and one authorized store marker.

2. Sign out and sign in as `REGION_NE_USER`. Confirm 24 stores, 453 units, 120 customers, complaints `9001`, `9002`, and `9006`, and the Northeast map footprint.

3. Sign out and sign in as `RECALL_LEAD_USER`. Confirm 120 stores, 2,400 units, 600 customers, complaints `9001`, `9002`, `9006`, `9003`, and `9007`, and the full continental U.S. map footprint.

4. Ask the same Select AI Agent question for each user. Point out that the answer changes because the database session and combined JSON, vector, Spatial, and Graph context change, not because the browser is filtering the results.

## Task 4: Explain Local Users Versus IdM

1. State that the workshop uses local database users so `ORA_END_USER_CONTEXT` and Deep Data Security behavior can be inspected directly.

2. Explain that a production solution can authenticate with enterprise IdM or OCI IAM and propagate the trusted identity through the application tier.

3. Emphasize that the database-side experience is the same in both designs: the end-user identity is established before the approved package calls run, and the map, counts, complaints, and agent answer remain role-specific.

4. Confirm that the Node server never exposes unrestricted SQL, the owner password, or the OCI resource principal to the browser. It retrieves the four secured evidence sections in the local-user session, then passes only the combined document to the owner-side agent bridge.

5. Ask these cross-feature questions while switching personas:

    - `Which response regions and centers should this role prioritize, and why?`
    - `Which component lots and supplier sites are connected to this recall?`
    - `Which complaint evidence supports the spatial and graph pattern visible to me?`

   Confirm that the same team uses shared component/supplier trace but role-specific Spatial and downstream Graph counts. In the graph panel, start at `Distance: 1 hop`, then increase to five hops to reveal the raw graph path incrementally. Use `Filter` to focus on Components, Sub-components, Suppliers, Supplier sites, Stores, or Customers. Filtered nodes retain their shortest path back to `B-482`; the graph no longer uses aggregate category boxes.

6. Target five minutes for application startup, five minutes for persona switching, five minutes for converged agent questions and the identity explanation, and seven minutes for troubleshooting and discussion.

## Troubleshooting Notes

- A blank browser page usually means the consolidated server is not running. Run `npm run dev:all` and open port `3001`.
- A missing end-user context indicates the login is not using one of the Lab 7 local users or the database bridge is not using the selected user session.
- A dashboard package error indicates `05-prepare-react-app.sql` must be rerun as `RECALL_OWNER`.
- A failed agent call usually means `RECALL_AGENT_PROFILE` or `RECALL_SECURED_TEAM` is not enabled, or the old bridge still calls `DBMS_CLOUD_AI.SET_PROFILE` from a Deep Data Security end-user session. Rerun `05-prepare-react-app.sql` as `RECALL_OWNER`.
- An agent answer that omits Spatial or Graph evidence usually means the pre-Lab 8 bridge is still installed. Rerun `05-prepare-react-app.sql` as `RECALL_OWNER`, reconnect the application users, and repeat the cross-feature questions.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
