# Product Recall Assistant React App

This folder is a standalone React and Node.js application for Lab 8. It serves the React interface and the database API from one port.

## Prerequisites

- Node.js 20 or later and npm.
- Network access to the Autonomous Database service.
- Labs 1 through 7 completed, including the three Deep Data Security users.
- The wallet files and wallet download password, when using a wallet TNS alias.

## Prepare the database

As `RECALL_OWNER`, run the Lab 8 bridge script before starting the application:

```sql
@product-recall-assistant/react-recall-command-center/files/05-prepare-react-app.sql
```

The script creates the invoker-rights application API and the owner-owned definer-rights bridges used for approved graph, vector, Spatial, JSON, and Select AI Agent operations. `RECALL_REACT_API.ASK_AGENT` assembles one role-filtered evidence document before the agent runs.

## Install and configure

From the repository root:

```bash
cd product-recall-assistant/react-app
npm install
cp .env.example .env
```

Edit `.env` with either an ADB TLS database connect string or a wallet TNS alias:

```text
PORT=3001
ORACLE_CONNECT_STRING=gendev_high
ORACLE_CONFIG_DIR=/absolute/path/to/wallet
ORACLE_WALLET_LOCATION=/absolute/path/to/wallet
ORACLE_WALLET_PASSWORD=wallet-download-password
COOKIE_SECURE=false
```

For a direct TLS connection, use the database connection string from the Autonomous Database **Database connection** dialog and leave the wallet directory values empty. `ORACLE_CONNECT_STRING` must be a database connect string or wallet alias, never an ORDS HTTPS URL.

## Run locally

Start the React development experience and Node API together:

```bash
npm run dev:all
```

Open [http://localhost:3001](http://localhost:3001). The application uses one port for the UI and API. Restart it after changing `.env`.

For a production-style local run:

```bash
npm run build
npm start
```

## Application logins

The browser login is intentionally limited to these Lab 7 local Deep Data Security users:

- `STORE_101_USER`
- `REGION_NE_USER`
- `RECALL_LEAD_USER`

Enter the password assigned by the Lab 7 setup. Never use `RECALL_OWNER` or `ADMIN` as an application login. `RECALL_OWNER` is only used to run the database setup scripts; `ADMIN` is only used for database bootstrap and grants. The application stores the selected end-user database session and all secured routes execute in that session before invoking the approved definer-rights bridges.

The workshop uses local database users so the database security behavior is visible. In production, an IdM or OCI IAM login can establish the trusted identity, but the database-side authorization result is the same.

The secured agent receives four sections assembled in the active end-user session: product JSON, vector and relational complaint evidence, Spatial impact and response-center summaries, and a compact Graph component/supplier trace with role-specific store/customer counts. The same agent team therefore produces different answers for the three logins without granting the agent SQL access.

## Troubleshooting

- `NJS-530` or an unresolved host usually means an ORDS URL was used instead of the ADB database connect string, or the wallet directory is incorrect.
- `NJS-505` usually means the wallet password does not match the wallet files. Update `ORACLE_WALLET_PASSWORD` and restart the application.
- A login failure for `RECALL_OWNER` is expected. Use one of the three Lab 7 end users.
- An agent `ORA-01031` error means the database bridge script or Lab 7 security setup needs to be rerun by `RECALL_OWNER`. The bridge must use the profile bound to the registered agent; it must not call `DBMS_CLOUD_AI.SET_PROFILE` for an end-user session.
- If port 3001 is busy, stop the earlier application process before running `npm run dev:all`.
