# Lab 8: Run Secure Returns from One React Application

## Introduction

Kevin now sees the application he asked for: one place for the returns team to review the B-482 scope, ask questions, and decide what to do next. Business users do not need to understand JSON, Spatial indexes, graph paths, vectors, agent tools, or security grants.

David combines the earlier database components without weakening their limits. The signed-in database user drives Deep Data Security filtering. The application receives product JSON, similar complaints, location impact, and graph results already limited to that user. An owner-side bridge calls the assistant only after the authorized document is built.

Tim prepares the React and Node database bridge, configures the application, and verifies the three roles. The application requests product details, authorized stores, graph paths, similar complaints, and assistant answers through approved packages. Kevin gets one returns workflow rather than eight disconnected demonstrations.

By the end of the lab, Kevin can compare the Store 101, Northeast, and recall-lead views in one application. Each person receives a different authorized answer to the same B-482 question, based on JSON, Vector Search, Spatial, SQL Property Graph, and Select AI Agent results.

Estimated Time: 25 minutes

### Objectives

In this lab, you will:

- Prepare the database bridge for the React/Node application.
- Configure and run the application against your Autonomous Database.
- Sign in as all three Deep Data Security local users.
- Compare role-filtered counts, maps, product evidence, and complaints.
- Run free-text vector searches against the authorized complaint evidence.
- Explore the `RECALL_GRAPH` component and supplier trace plus DDS-filtered store and customer exposure paths in the Oracle Graph Visualization Library.
- Ask the Select AI Agent questions through the secured database session.
- Compare converged agent answers grounded in JSON, Vector, Spatial, and Graph evidence.
- Explain how local database users map to a production IdM design.


### To run the application

- Node.js 20 or later and npm are installed on the lab workstation.
- The workstation can connect to the Autonomous Database service.

## Task 1: Prepare the Database Connection for the Application

Kevin needs the application to call approved packages, not internal tables. David separates user-session retrieval from the owner-side assistant call; Tim prepares the bridge. 

1. Start with the prepared database bridge.

    The backend deployment creates `RECALL_REACT_API`, the shared `RECALL_GRAPH_API` property-graph boundary, the DDS-filtered downstream graph projection and secured store GeoJSON function, role-filtered Spatial impact and compact Graph evidence for the agent, and the owner-side question-answering bridge. It also creates `RECALL_SECURED_TEAM` with its converged question-answering instruction.

    The bridge is intentionally split. The local user has `EXECUTE` on the approved `RECALL_REACT_API` package, not unrestricted access to `DBMS_CLOUD_AI_AGENT`. The package call runs as the local user long enough for DDS to materialize the authorized JSON, vector, Spatial, and Graph sections, then the definer-rights bridge calls `DBMS_CLOUD_AI_AGENT.RUN_TEAM` with that combined document. The registered responder agent carries the `RECALL_AGENT_PROFILE` binding, so the runtime does not call `DBMS_CLOUD_AI.SET_PROFILE` in the local user session.

    The grant boundary is visible in the prepared package grants:

    ```sql
    <copy>
    -- ADMIN grants the agent framework to the owner once.
    grant execute on dbms_cloud_ai_agent to recall_owner;

    -- The application users receive the approved package boundary.
    grant execute on recall_owner.recall_react_api to recall_end_user_login;
    </copy>
    ```

    Run these two grants as `ADMIN`. The schema-qualified package name is required because `RECALL_REACT_API` belongs to `RECALL_OWNER`. The local user therefore requests `RUN_TEAM` indirectly through `RECALL_REACT_API`; the user is never granted direct agent-framework access.

2. Confirm that the bridge packages are valid.

    ```sql
    <copy>
    select object_name,
           object_type,
           status
    from   user_objects
    where  object_name in (
               'RECALL_AGENT_BRIDGE',
               'RECALL_GRAPH_API',
               'RECALL_REACT_API',
               'RECALL_VECTOR_BRIDGE'
           )
    order  by object_name, object_type;
    </copy>
    ```

    The package status must be `VALID`. The React application uses `RECALL_REACT_API` for identity, product metadata, secured store GeoJSON, the DDS-filtered downstream graph projection, free-text vector searches, and agent questions. It uses `RECALL_GRAPH_API` for the shared component and supplier trace from `RECALL_GRAPH`, `RECALL_VECTOR_BRIDGE` for owner-side embedding inference only, and `RECALL_SECURE_API.GET_SECURED_CONTEXT` for role-filtered JSON evidence.

3. Confirm that the React package exposes the required functions.

    ```sql
    <copy>
    select procedure_name
    from   user_procedures
    where  object_name = 'RECALL_REACT_API'
    order  by procedure_name;
    </copy>
    ```

    Confirm `ASK_AGENT`, `CURRENT_IDENTITY`, `PRODUCT_CONTEXT`, `SEARCH_VECTOR_EVIDENCE`, `SECURED_GRAPH`, and `SECURED_STORES`. The separate graph package exposes `CONTEXT` for the shared supplier trace.

## Task 2: Configure the Application

Kevin needs a usable returns application. David keeps connection details outside the code; Tim configures the runtime.

1. Open a terminal in the React application folder and install the dependencies.

    ```bash
    <copy>
    cd product-recall-assistant/react-app
    npm install
    cp .env.example .env
    </copy>
    ```

2. Edit `.env` and set the Autonomous Database connect string. Do not put a database password in `.env`; the password is entered into the sign-in form.

    ```text
    <copy>
    # Option A: paste the TLS connection string from ADB Database connection.
    ORACLE_CONNECT_STRING=tcps://your-adb-host:1522/your-service-name
    # Option B: use a TNS alias from an extracted ADB wallet.
    # ORACLE_CONNECT_STRING=gendev_high
    # ORACLE_CONFIG_DIR=/absolute/path/to/wallet
    # ORACLE_WALLET_LOCATION=/absolute/path/to/wallet
    # ORACLE_WALLET_PASSWORD=wallet-download-password
    COOKIE_SECURE=false
    </copy>
    ```

    Use the same connect string that works for the Lab 7 local end-user SQLcl connections. The Node API uses the database user selected in the browser form and the password submitted with that form.

    Use the TLS connection string copied from the Autonomous Database **Database connection** dialog, or use the service alias from the wallet's `tnsnames.ora` file. Do not paste the ORDS HTTPS URL from Lab 6. For a wallet/TNS alias connection, the directory must contain `tnsnames.ora` and `ewallet.pem`.

3. Review the application flow:

    ```text
    Browser persona login
        -> Node opens a database session as the selected local end user
        -> Oracle establishes ORA_END_USER_CONTEXT and the assigned data role
        -> RECALL_REACT_API returns role-filtered product and map data
        -> RECALL_GRAPH_API returns shared `RECALL_GRAPH` component/vendor trace
        -> RECALL_REACT_API returns DDS-filtered store/customer graph paths
        -> RECALL_SECURE_API returns role-filtered JSON and default vector evidence
        -> RECALL_REACT_API computes role-filtered spatial impact and graph evidence
        -> RECALL_REACT_API embeds free-text searches and ranks only visible complaint vectors
        -> RECALL_REACT_API.ASK_AGENT calls the owner-owned definer-rights bridge
        -> RECALL_AGENT_BRIDGE calls Select AI Agent with one combined JSON document
    ```

    The Node server uses the selected local user for all secured retrieval, including agent questions. `RECALL_REACT_API` runs as invoker rights in the held DDS session, materializes the authorized JSON, vector, Spatial, and Graph evidence, and then calls the owner-owned definer-rights `RECALL_AGENT_BRIDGE` for Select AI Agent execution. The browser receives no owner password, OCI resource principal, or unrestricted SQL.

    **Read this as a security demonstration:** the user does not receive a copy of the owner’s privileges. The user calls the approved package, DDS applies the user’s data grants, and only the resulting combined document crosses the definer-rights boundary to `RUN_TEAM`. A store user and a recall lead execute the same application code and same agent team; their answers differ because the database supplied different authorized JSON, vector, Spatial, and downstream Graph evidence.

## Task 3: Run the React Application

Kevin needs a working command center that turns approved evidence into clear next actions. David defines that experience; Tim starts or deploys it.

1. Start the API and React development server together.

    ```bash
    <copy>
    npm run dev:all
    </copy>
    ```

    Open [http://localhost:3001](http://localhost:3001). The Node server and React development middleware share this single origin.

2. For a production-style local run, build the React application and start the Node server as one process.

    ```bash
    <copy>
    npm run build
    npm start
    </copy>
    ```

    Open [http://localhost:3001](http://localhost:3001) after the production build. The Node server serves the generated `dist` folder and the API routes from the same origin.

3. If port `3001` is already running from an earlier attempt, stop that workshop process and run `npm run dev:all` again. Changes to `.env` do not take effect until the server restarts.

4. To deploy on an application host, copy the `react-app` directory to that host, set `ORACLE_CONNECT_STRING`, `PORT`, and `COOKIE_SECURE=true` in its environment, run `npm ci`, `npm run build`, and start it with `npm start` behind the host's HTTPS reverse proxy. Allow the host to reach the Autonomous Database service and keep the database password out of source files and environment templates.

## Task 4: Compare the Three User Views

Kevin checks whether the same application respects each job. David relies on the signed-in identity; Tim compares the three results.

1. Sign in as `STORE_101_USER` with the shared Lab 7 password.

    Confirm the header shows the store associate role. The expected result is:

    | Evidence | Store user |
    |---|---:|
    | Visible stores | 1 |
    | Units | 12 |
    | Customers | 5 |
    | Priority complaints | `9001` |

    The map shows only the authorized Store 101 location. The complaint list shows only complaint `9001`.

    The property graph shows the shared batch-to-component-batch-to-supplier-site trace and the downstream store/customer paths authorized for the signed-in user. Store 101 users see one store and five customer vertices; the Northeast user sees 24 stores and 120 customers; the recall lead sees 120 stores and 600 customers. The customer vertices contain only the authorized customer's name and identifier; email addresses are not returned.

    Use the graph **Distance** selector to control how much of the raw `RECALL_GRAPH` is visible at once. It starts at one hop from `B-482` and supports one through five hops. Use the **Filter** selector to show all vertices or focus on Components, Sub-components, Suppliers, Supplier sites, Stores, or Customers. Filtered views retain the shortest path back to `B-482`, so the selected evidence remains connected; the application no longer replaces categories with aggregate boxes.

    The agent receives a compact form of the same graph evidence: the batch-to-component-to-supplier path pattern, shared component and supplier counts, and the active role's authorized store/customer relationship counts. This keeps graph reasoning useful without sending the entire visualization payload to the model.

    In **Vector evidence**, the initial rows are ranked with the stored `HEAT_ODOR` query vector. Enter a phrase such as `burning smell and early shutoff` to run a new local-model embedding search. The embedding is generated by the owner-side model bridge, but complaint rows are ranked in the active end-user session, so DDS still limits the results.

2. Sign out and sign in as `REGION_NE_USER`.

    Confirm the header changes to Northeast regional manager. The expected result is:

    | Evidence | Northeast user |
    |---|---:|
    | Visible stores | 24 |
    | Units | 453 |
    | Customers | 120 |
    | Priority complaints | `9001`, `9002`, `9006` |

    The map and graph show the authorized Northeast footprint. Complaint `9003` remains hidden because its customer is outside the regional grant. The graph likewise excludes stores and customers outside the active DDS role.

3. Sign out and sign in as `RECALL_LEAD_USER`.

    Confirm the header changes to recall response lead. The expected result is:

    | Evidence | Recall lead |
    |---|---:|
    | Visible stores | 120 |
    | Units | 2,400 |
    | Customers | 600 |
    | Priority complaints | `9001`, `9002`, `9006`, `9003`, `9007` |

    The map and graph show the full authorized continental U.S. footprint. Shared component and supplier-site facts remain available to every persona because they describe recall evidence, while downstream store and customer vertices are still produced from the active DDS-filtered session. The agent receives the same distinction: shared component/supplier trace plus role-specific spatial and exposure evidence.

4. Compare the experience with the database session, not the browser selection. The Node API reads the active end-user identity from `ORA_END_USER_CONTEXT` after login. The same application code and same SQL package calls produce different results because the database applies different data grants.

## Task 5: Ask the Assistant

Kevin asks the final business question. David assembles only the JSON, Vector Search, Spatial, and SQL Property Graph results that the user may see; Tim sends that document to the assistant.

1. While signed in as each persona, ask a question from the chat panel:

    - `What is the authorized recall scope for B-482?`
    - `Which complaint evidence should I review first?`
    - `What action should this team take next?`

2. Confirm that each answer stays inside the active persona scope. The agent can summarize only the four sections assembled by `RECALL_REACT_API`: product JSON, authorized vector/relational evidence, authorized Spatial impact, and Graph evidence. It cannot query tables, retrieve hidden complaints, or expand a store user into company totals.

    The call chain is: `local user -> RECALL_REACT_API (invoker rights) -> DDS data grants -> JSON + vector + Spatial + Graph evidence -> RECALL_AGENT_BRIDGE (definer rights) -> DBMS_CLOUD_AI_AGENT.RUN_TEAM`. The local user needs only the approved package grant. `RECALL_OWNER` retains the direct agent-framework grant and the configured profile/resource-principal access.

3. Ask converged questions that require more than one feature:

    - `Which response regions and centers should this role prioritize, and why?`
    - `Which component lots and supplier sites are connected to this recall?`
    - `Which complaint evidence supports the spatial and graph pattern visible to me?`

    The answer should combine only the sections relevant to the question. A store user receives Store 101 spatial and exposure evidence; a regional manager receives the Northeast footprint; the recall lead receives the full authorized footprint.

4. Explain the IdM equivalence:

    - **Workshop login:** the React form receives a local database username and password.
    - **Production login:** an IdM or OCI IAM flow authenticates the person and passes the trusted identity to the application tier.
    - **Database result:** both paths establish an end-user context and data role before secured SQL runs.
    - **Visible behavior:** the map, counts, complaints, and agent answer remain role-specific in both designs.

5. Sign out at the end of the test. The Node server closes the held database session and removes the browser session cookie.

You have completed the Product Recall Assistant. The React and Node application shows database-enforced user access and live Select AI Agent answers.

## Conclusion

Kevin's requirements now appear in one returns application. Each signed-in user can see the B-482 records that apply to their role, view the related locations and suppliers, and ask the assistant a question without receiving broader access.

David keeps the application rules in Oracle AI Database: packages provide the data, Deep Data Security applies the user scope, and the owner-side bridge calls the assistant only after that filtering. The application does not need to duplicate those rules or combine results from separate JSON, vector, Spatial, or graph databases. Tim brings the results together in React.

## Learn More

- [Oracle Deep Data Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/)
- [node-oracledb documentation](https://node-oracledb.readthedocs.io/en/latest/)
- [React documentation](https://react.dev/)
- [Leaflet documentation](https://leafletjs.com/)

## Acknowledgements

- **Author:** Tim Cline, Product Management Architect
- Contributors: David Start, Director and Kevin Lazarz, Senior Manager
- **Last updated:** October 2026
