Product Recall Assistant - Lab 8 application package

Requirements: Node.js 20 or later, npm, and the completed Lab 8 database setup.
The combined setup script must be installed while connected as RECALL_OWNER,
after ADMIN grants that schema EXECUTE on DBMS_CLOUD_AI_AGENT.

1. Extract react-app-package.zip. It creates a react-app folder.
2. In a terminal, enter that folder and install the locked dependencies:

   cd react-app
   node --version
   npm ci
   cp .env.example .env

   In PowerShell, use `Copy-Item .env.example .env` for the last command.

3. Edit .env and set ORACLE_CONNECT_STRING to the complete Autonomous Database
   TLS connect string, or to a wallet TNS alias. Do not use the SQL Developer Web
   or ORDS URL as a database connect string. Do not put the database password in
   .env; enter the Lab 7 end-user password in the application sign-in form.
4. Start the application with `npm start`, then open http://localhost:3001.

If port 3001 is already in use, stop the earlier app or run `PORT=3002 npm start`
and open http://localhost:3002. In PowerShell, run `$env:PORT=3002` before
`npm start`.

The archive excludes .env, node_modules, and development source. Keep your local
.env and wallet files private.
