# Lab 8 Facilitator Runbook

## Introduction

This runbook prepares and rehearses the React/Node command center and governed campaign workflow used in Lab 8. Legacy application artifacts are archived and are not part of the learner workshop flow.

Estimated Time: 45 minutes

### Objectives

- Prepare the database bridge package for the React application.
- Start or deploy the React/Node application against the lab Autonomous Database.
- Demonstrate all three Deep Data Security local-user experiences.
- Demonstrate one secured agent team using JSON, Vector, Spatial, and Graph evidence.
- Demonstrate role-filtered campaign audiences, explicit contact authorization, review, approval, and refund-intent auditing.
- Explain how the local-user demonstration maps to an IdM or OCI IAM deployment.

## Task 1: Prepare the Database Bridge

1. Sign in to SQL Developer Web as `ADMIN` and run the Lab 8 setup block. It fetches the current `05-prepare-react-app.sql` deployment from Object Storage and executes it with `RECALL_OWNER` as the current schema. The block installs both the React bridge and campaign schema.

2. Confirm `RECALL_AGENT_BRIDGE`, `RECALL_REACT_API`, `RECALL_CAMPAIGN_BRIDGE`, and `RECALL_CAMPAIGN_API` are `VALID`.

3. Confirm `RECALL_REACT_API` exposes `ASK_AGENT`, `CURRENT_IDENTITY`, `PRODUCT_CONTEXT`, and `SECURED_STORES`. `ASK_AGENT` internally assembles product JSON, vector/relational evidence, role-filtered Spatial impact, and compact Graph evidence; the helper functions are intentionally not granted as separate end-user retrieval endpoints.

4. Verify that `RECALL_SECURED_TEAM` and `RECALL_CAMPAIGN_TEAM` are enabled and that `RECALL_AGENT_PROFILE` is available before starting the application.

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

## Task 5: Rehearse the Governed Campaign

1. Sign in as `RECALL_LEAD_USER` and open **Recall Campaign**. Explain that the API uses the active local database identity and Deep Data Security to derive eligible purchases.
2. Authorize contact and review the automatically generated generic template. Change its channel or tone and regenerate it if time allows. Emphasize that only generic recall facts and placeholders go to the campaign agent; customer details are merged after generation.
3. Generate a personalized draft for one authorized purchase, review the refund calculation, then approve the campaign. Confirm approval creates audit rows and `READY_FOR_PROCESSING` refund intents only; there is no outbound message or payment integration.
4. Sign out and repeat the audience check as `REGION_NE_USER` and `STORE_101_USER`. Confirm each audience remains within the active user's data grant.
5. Target five minutes for application startup, five minutes for persona switching, five minutes for converged agent questions and the identity explanation, ten minutes for the campaign flow, and the remaining time for troubleshooting and discussion.

## Troubleshooting Notes

- A blank browser page usually means the consolidated server is not running. Run `npm run dev:all` and open port `3001`.
- A missing end-user context indicates the login is not using one of the Lab 7 local users or the database bridge is not using the selected user session.
- A dashboard or campaign package error indicates that the hosted setup script is outdated or did not complete. Confirm its v7 marker matches the Lab 8 block and inspect `ALL_ERRORS` as `ADMIN` before rerunning the combined deployment.
- `ORA-24344` means an object was created with compilation errors. Query `ALL_ERRORS` as `ADMIN` for `RECALL_OWNER` objects and fix the reported source line before rerunning the deployment; the package body may be `INVALID` even though installation completed.
- `ORA-03405` from `DBMS_CLOUD_REPO.INSTALL_SQL` means the hosted script was not accepted as a sequence of complete install statements. Publish the current v7 source, ensure each SQL statement ends with `/` on its own line, and exclude SQL*Plus-only commands before rerunning the Lab 8 block.
- A failed agent call usually means `RECALL_AGENT_PROFILE`, `RECALL_SECURED_TEAM`, or `RECALL_CAMPAIGN_TEAM` is not enabled, or an older bridge calls `DBMS_CLOUD_AI.SET_PROFILE` from a Deep Data Security end-user session. Verify the existing Lab 7 profile and teams before rerunning deployment.
- An agent answer that omits Spatial or Graph evidence usually means an older Lab 8 bridge is installed. Confirm all bridge package bodies are `VALID`, reconnect the application users, and repeat the cross-feature questions.
- `ORA-00904` for `RECALL_CAMPAIGN_API.STATUS` means the combined v7 deployment is missing or stale. Check `ALL_PROCEDURES` for `RECALL_CAMPAIGN_API.STATUS` and package validity under `RECALL_OWNER`.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
