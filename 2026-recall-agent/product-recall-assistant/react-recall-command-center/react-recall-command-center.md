# Lab 8: Run Secure Returns from One React Application

## Introduction

Kevin now sees the application he asked for: one place for the returns team to review the B-482 scope, ask questions, and decide what to do next. Business users do not need to understand JSON, Spatial indexes, graph paths, vectors, agent tools, or security grants.

David combines the earlier database components without weakening their limits. The signed-in database user drives Deep Data Security filtering. The application receives product JSON, similar complaints, location impact, and graph results already limited to that user. An owner-side bridge calls the assistant only after the authorized document is built.

Tim prepares the React and Node database bridge and the governed response workflow, configures the application, and explores how the three roles use it. The application requests product details, authorized stores, graph paths, similar complaints, and assistant answers through approved packages. Its campaign workspace also lets a recall lead authorize contact, draft a reusable notice, and prepare auditable refund intents. Kevin gets one returns workflow rather than eight disconnected demonstrations.

By the end of the lab, Kevin can compare the Store 101, Northeast, and recall-lead views in one application. Each person receives a different authorized answer to the same B-482 question, based on JSON, Vector Search, Spatial, SQL Property Graph, and Select AI Agent results. The recall lead can also authorize a campaign, review a generic notice template, and approve refund intents for downstream processing. The application sends no messages and transfers no money.

Estimated Time: 45 minutes

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
- Explore how the campaign API enforces contact authorization, role-filtered recipients, human approval, and refund-intent auditing.


### To run the application

- Install Node.js 20 or later and npm on your workstation. npm is included with Node.js.
- Have the workshop's `product-recall-assistant/react-app` files available on your workstation and a current browser.
- Confirm that your workstation can connect to the Autonomous Database service.
- Have your direct database connect string, any required wallet, and the three Lab 7 end-user credentials ready. A SQL Developer Web URL is not a direct connect string.
- Use Task 1 to prepare the bridge packages and grant the required access.

Check these prerequisites before configuring the application. If a package or connection detail is missing, use **Need Help?** to resolve it before continuing.

#### Install Node.js and npm

Use the package manager for your operating system. These commands install Node.js and npm; you do not need to install Oracle Instant Client for this application.

- **macOS:** In Terminal, install [Homebrew](https://brew.sh/) if it is not already installed, then run:

    ```bash
    <copy>
    brew install node
    node --version
    npm --version
    </copy>
    ```

- **Windows:** Open PowerShell or Windows Terminal and install the Node.js LTS package with [Windows Package Manager](https://learn.microsoft.com/windows/package-manager/winget/):

    ```powershell
    <copy>
    winget install --id OpenJS.NodeJS.LTS --exact
    </copy>
    ```

    Close and reopen the terminal, then verify the installation:

    ```powershell
    <copy>
    node --version
    npm --version
    </copy>
    ```

Both checks should print version numbers. Confirm that Node.js is version 20 or later before continuing.

## Task 1: Prepare the Database Connection for the Application

Kevin needs the application to call approved packages, not internal tables. David separates user-session retrieval from the owner-side assistant call; Tim prepares the bridge.

1. As `ADMIN`, grant the agent framework to the owner and install the Lab 8 bridge script from Object Storage. The install runs with `RECALL_OWNER` as the current schema, so the packages and agent team belong to `RECALL_OWNER` while you stay connected as `ADMIN`.

    ```sql
    <copy>
    grant execute on dbms_cloud_ai_agent to recall_owner;

    declare
        l_script clob;
        l_marker constant varchar2(100) := '-- Product Recall Assistant - Lab 8 application and governed response setup v7';
    begin
        if sys_context('USERENV', 'SESSION_USER') != 'ADMIN' then
            raise_application_error(-20002, 'Connect as ADMIN before running this setup.');
        end if;

        l_script := to_clob(dbms_cloud.get_object(
            credential_name => null,
            object_uri => 'https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/database/05-prepare-react-app.sql'
        ));

        if dbms_lob.substr(l_script, length(l_marker), 1) != l_marker then
            raise_application_error(-20001,
                'The hosted Lab 8 setup script is not the current version. Contact your workshop provider.');
        end if;

        execute immediate 'alter session set current_schema = RECALL_OWNER';
        begin
            dbms_cloud_repo.install_sql(content => l_script, stop_on_error => true);
        exception
            when others then
                execute immediate 'alter session set current_schema = ADMIN';
                raise;
        end;
        execute immediate 'alter session set current_schema = ADMIN';
    end;
    /
    </copy>
    ```

    The script creates the application bridge and the governed response campaign in one install. For the command center, it creates `RECALL_REACT_API`, the shared `RECALL_GRAPH_API` property-graph boundary, the DDS-filtered downstream graph projection and secured store GeoJSON function, role-filtered Spatial impact and compact Graph evidence for the agent, and the owner-side question-answering bridge. It also creates `RECALL_SECURED_TEAM` with its converged question-answering instruction and grants the application role access to the approved packages.

    For the campaign workspace, it creates a separate campaign policy, campaign/recipient/audit/refund-intent tables, `RECALL_CAMPAIGN_TEAM`, and the `RECALL_CAMPAIGN_API` and `RECALL_CAMPAIGN_BRIDGE` packages. Contact starts disabled. The API uses the signed-in database identity and Deep Data Security to determine which purchases can enter the audience. A recall lead must authorize contact and approve the draft. The campaign agent receives generic recall facts and placeholders; the application merges customer details only after the reusable template is returned. Approval records audit events and creates refund intents marked for downstream processing. No email or SMS is sent and no payment is made.

    The bridge is intentionally split. The local user has `EXECUTE` on the approved `RECALL_REACT_API` package, not unrestricted access to `DBMS_CLOUD_AI_AGENT`. The package call runs as the local user long enough for DDS to materialize the authorized JSON, vector, Spatial, and Graph sections, then the definer-rights bridge calls `DBMS_CLOUD_AI_AGENT.RUN_TEAM` with that combined document. The registered responder agent carries the `RECALL_AGENT_PROFILE` binding, so the runtime does not call `DBMS_CLOUD_AI.SET_PROFILE` in the local user session.

    The setup script grants `EXECUTE` on `RECALL_REACT_API` to `RECALL_END_USER_LOGIN`; do not run a separate grant for that package. The local user requests `RUN_TEAM` indirectly through `RECALL_REACT_API` and is never granted direct agent-framework access.

2. As `ADMIN`, confirm that the application and campaign packages and bodies are present and valid under `RECALL_OWNER`.

    ```sql
    <copy>
    select object_name,
           object_type,
           status
    from   all_objects
    where  owner = 'RECALL_OWNER'
    and    object_name in (
               'RECALL_AGENT_BRIDGE',
               'RECALL_GRAPH_API',
               'RECALL_REACT_API',
               'RECALL_CAMPAIGN_API',
               'RECALL_CAMPAIGN_BRIDGE',
               'RECALL_VECTOR_BRIDGE'
           )
    order  by object_name, object_type;
    </copy>
    ```

    Expect **12 rows**: a `PACKAGE` and `PACKAGE BODY` for each of the six names above, all `VALID`. A result containing only valid rows is insufficient if any package is missing. If fewer than 12 rows appear, note the missing packages and use **Need Help?** to resolve the setup issue before configuring the application. The React application uses `RECALL_REACT_API` for identity, product metadata, secured store GeoJSON, the DDS-filtered downstream graph projection, free-text vector searches, and agent questions. It uses `RECALL_GRAPH_API` for the shared component and supplier trace from `RECALL_GRAPH`, `RECALL_VECTOR_BRIDGE` for owner-side embedding inference only, and `RECALL_SECURE_API.GET_SECURED_CONTEXT` for role-filtered JSON evidence. The campaign uses `RECALL_CAMPAIGN_API` for persona-scoped status, authorization, drafting, personalization, and approval; `RECALL_CAMPAIGN_BRIDGE` owns the protected campaign operations.

3. As `ADMIN`, confirm that the React package exposes the required functions under `RECALL_OWNER`. `USER_PROCEDURES` shows only the connected user's own packages, so use `ALL_PROCEDURES` here.

    ```sql
    <copy>
    select procedure_name
    from   all_procedures
    where  owner = 'RECALL_OWNER'
    and    object_name = 'RECALL_REACT_API'
    order  by procedure_name;
    </copy>
    ```

    Confirm `ASK_AGENT`, `CURRENT_IDENTITY`, `PRODUCT_CONTEXT`, `SEARCH_VECTOR_EVIDENCE`, `SECURED_GRAPH`, and `SECURED_STORES`. The separate graph package exposes `CONTEXT` for the shared supplier trace. If these are missing from `ALL_PROCEDURES`, recheck that `RECALL_REACT_API` and its package body are `VALID` in `ALL_OBJECTS` for `RECALL_OWNER`; do not continue to application configuration until the package is present and valid.

4. As `ADMIN`, confirm that the campaign package exposes the functions the application calls.

    ```sql
    <copy>
    select procedure_name
    from   all_procedures
    where  owner = 'RECALL_OWNER'
    and    object_name = 'RECALL_CAMPAIGN_API'
    order  by procedure_name;
    </copy>
    ```

    Confirm `STATUS`, `AUTHORIZE_CONTACT`, `DRAFT_CAMPAIGN`, `CUSTOMER_OPTIONS`, `PERSONALIZE_CAMPAIGN`, and `APPROVE_CAMPAIGN`. The application calls `STATUS` when you open **Recall Campaign**. If a name is missing, the hosted setup script may be an older version; resolve the deployment before continuing.

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

2. Get a database connect string. The SQL Developer Web link opens a browser-based SQL tool; it is not the database connect string that the Node.js application needs. You cannot reliably derive the database service name from that link.

    If you can open the OCI Console, go to **Oracle AI Database**, open the matching Autonomous Database, select **Database connection**, choose **TLS** under **TLS Authentication**, and copy the connection string for the service you will use. See Oracle's [instructions for obtaining a TLS connection string](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/connect-jdbc-thin-tls.html). If TLS is unavailable, use the wallet and TNS alias provided for this workshop instead.

    If you only have the SQL Developer Web link and cannot access the OCI Console, ask your workshop provider for the database TLS connection string or wallet. Do not substitute the SQL Developer Web URL or guess the host, port, or service name.

3. Edit `.env` and set the Autonomous Database connect string. Do not put a database password in `.env`; the password is entered into the sign-in form.

    ```text
    <copy>
    # Option A: TLS connection string for this workshop environment.
    ORACLE_CONNECT_STRING=(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=dog47xjfczr2h91_atp238504_medium.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))
    # Option B: use a TNS alias from an extracted ADB wallet.
    # ORACLE_CONNECT_STRING=gendev_high
    # ORACLE_CONFIG_DIR=/absolute/path/to/wallet
    # ORACLE_WALLET_LOCATION=/absolute/path/to/wallet
    # ORACLE_WALLET_PASSWORD=wallet-download-password
    COOKIE_SECURE=false
    </copy>
    ```

    This connection string is for the workshop environment used in this lab. For a different database environment, replace it with the TLS connection string shown in that database's OCI **Database connection** page. The Node API uses the database user selected in the browser form and the password submitted with that form; do not add a database password to `.env`.

    For a wallet/TNS alias connection, set `ORACLE_CONNECT_STRING` to the service alias from the wallet's `tnsnames.ora` file. Do not paste the ORDS HTTPS URL from Lab 6. The wallet directory must contain `tnsnames.ora` and `ewallet.pem`.

4. Review the application flow:

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

Choose one local mode: Step 1 for development or Step 2 for a production-style build. They are alternatives and use the same port.

1. **Development mode:** start the API and React development server together.

    ```bash
    <copy>
    npm run dev:all
    </copy>
    ```

    Open [http://localhost:3001](http://localhost:3001). The Node server and React development middleware share this single origin.

2. **Alternative production-style local mode:** if your workshop development process from Step 1 is running, stop it with Ctrl+C in its terminal first. Then build the React application and start the Node server as one process.

    ```bash
    <copy>
    npm run build
    npm start
    </copy>
    ```

    Open [http://localhost:3001](http://localhost:3001) after the production build. The Node server serves the generated `dist` folder and the API routes from the same origin.

3. If port `3001` is already in use by your workshop process from an earlier attempt, stop that process in its terminal before restarting your chosen mode. Do not stop unrelated processes; record the port conflict if you cannot identify it as your workshop process. Changes to `.env` do not take effect until the server restarts.

4. **Optional: deploy to an application host.** You can skip this step if you are running locally. If you have access to an application host, copy the `react-app` directory to that host, set `ORACLE_CONNECT_STRING`, `PORT`, and `COOKIE_SECURE=true` in its environment, run `npm ci`, `npm run build`, and start it with `npm start` behind the host's HTTPS reverse proxy. Allow the host to reach the Autonomous Database service and keep the database password out of source files and environment templates.

## Task 4: Compare the Three User Views

Kevin checks whether the same application respects each job. David relies on the signed-in identity; Tim compares the three results.

1. Sign in as `STORE_101_USER` with the credentials you used in Lab 7.

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

## Task 6: Explore the Governed Recall Campaign

Kevin needs the team to prepare a customer response without letting an AI model decide who qualifies or sending a message before a person reviews it. The campaign workspace uses the same database identity and application session as the rest of the command center, then adds explicit contact authorization, a reusable draft, a human approval, and an audit trail.

1. Sign in as `RECALL_LEAD_USER` and open **Recall Campaign**. Review the policy state before acting. Contact is disabled until the recall lead authorizes it.
2. Select **Authorize customer contact**. The authorized workspace creates a generic notice draft using the default `EMAIL` channel and `PROFESSIONAL` tone. Change the channel or tone and select **Regenerate generic draft** to explore the options.
3. Review the generic template. It contains campaign facts and placeholders, not customer names or email addresses. The campaign package obtains eligible purchases in the active Deep Data Security session; customer details are merged only after the agent returns the generic template.
4. Select one authorized customer order and choose **Generate for selected customer**. Review the personalized preview, deterministic refund amount, and approved refund steps. Selecting a customer creates a draft record for that one authorized purchase; it does not send a notice.
5. Select **Approve campaign and create refund intents**. The database records the lead's approval, updates the campaign and recipient statuses, and creates one `READY_FOR_PROCESSING` refund intent for each eligible purchase in the approved campaign. This prepares records for a later payment integration; it does not transfer funds.
6. Sign out and repeat the campaign view as `REGION_NE_USER` and `STORE_101_USER`. Compare the eligible audience with the recall lead's. Each audience follows the active database identity and its Lab 7 data grant.

As `RECALL_OWNER`, inspect the audit trail and refund intents after approval:

    ```sql
    select campaign_id, batch_id, status, recipient_count, total_refund,
           template_source, approved_by
    from   recall_campaigns
    order  by campaign_id desc;

    select campaign_id, purchase_id, refund_amount, status
    from   recall_refund_intents
    order  by refund_intent_id desc;

    select action_name, actor_name, detail_text, created_at
    from   recall_campaign_audit
    order  by audit_id desc
    fetch first 10 rows only;
    ```

The campaign boundary is: database policy and Deep Data Security determine the audience; Select AI Agent drafts generic language; the application merges authorized customer facts; the recall lead reviews and approves; database packages record the decision and create refund intents. The workshop does not send customer messages or move money.

You have completed the workshop. The React and Node application brings together database-enforced access, live evidence and agent answers, and a human-governed response workflow in one place.

## Conclusion

Kevin's requirements now appear in one returns application. Each signed-in user can see the B-482 records that apply to their role, view the related locations and suppliers, ask the assistant a question without receiving broader access, and prepare only the response actions their role permits.

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
