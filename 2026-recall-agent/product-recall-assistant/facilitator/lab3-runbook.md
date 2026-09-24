# Lab 6 Facilitator Runbook

## Introduction

This runbook prepares the authenticated ORDS routes used in Lab 6.

Estimated Time: 15 minutes

### Objectives

- Publish the read-only ORDS module.
- Provide the correct HTTPS API base URL.
- Verify credentials and PII remain outside responses.

## Task 1: Prepare the API

1. Run `01-extend-recall-api.sql` as `RECALL_OWNER`.

2. Run `02-publish-ords.sql` as `ADMIN`.

3. Verify that anonymous access returns `401`.

4. Verify that authenticated access returns the expected context, 120 store GeoJSON features, and 25 component-site GeoJSON features.

## Task 2: Rehearse the Learner Test

1. Run `03-test-api.sh` without placing the runtime password in shell history.

2. Confirm `120/2400/600`, complaints `9001`, `9002`, `9006`, `9003`, and `9007`, 120 store features, and 25 component-site features.

3. Confirm the responses contain no customer names or email addresses.

## Task 3: Time the Path

1. Target four minutes for the owner API extension.

2. Target three minutes for the ORDS publication boundary.

3. Target five minutes for authentication and response checks.

4. Explain that Lab 8 supplies the final React/Node application. Learners run the Node API and React development server locally; no Python server is required.

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
