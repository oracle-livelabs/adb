I need to develop an Oracle Hands-On-Lab workshop for 2026 AI World using Oracle 26ai Database with Autonomous.  The lab will be given to entry to mid-level audience and will be roughly 90 minutes total. Of the 90 minutes, 15 minutes is the intro, 60 minutes for the workship, 15 final discussion or questions.  Let's break each of the 60 minute sections down into a build up hands on lab.  Start with generating data, showcase the core converged features, building agents, build ORDS restful services for api's, deploy sample app. Lastly, we will showcase how Deep Data Security comes into play in ensuring Agents only reveal the right data and audit of the sessions to ensure proper guidrails and observabilities are captured.

Product Recall Assistant: Find Who Is Affected Fast

What if building an enterprise AI agent did not require five different data platforms?
In this hands-on lab, you will build a Product Recall Assistant using Oracle Database as the foundation for JSON documents, vector search, graph relationships, operational data, and agent workflows. Using a realistic product quality scenario, your assistant will answer urgent business questions such as: “Batch B-482 has a quality issue. Which stores received it? Which customers may be affected? What complaints are related? What action should we take first?”
Developers will see how to build an AI-powered workflow without stitching together separate systems for documents, vectors, graph, and transactions. DBAs and data teams will see how Oracle Database simplifies the architecture by keeping trusted business data, semantic search, relationship analysis, security, and governance together in one platform.
By the end of the lab, you will have a working assistant that investigates affected products, connects evidence across the supply chain, and recommends action using trusted business data without managing a patchwork of specialized databases.

At the very end, we will introduce the users with Oracle Deep Data Security enforcements with local users/roles.
Use this as reference: https://medium.com/@thomas.minne/securing-vector-search-with-deep-data-security-in-oracle-ai-database-c2fe0c4dd736 on how to add security within the database and enterprise.

Business problem from “Can the agent find affected customers?” to “Can the agent answer safely based on who is asking?”
Example:
“Batch B-482 has a quality issue. Which stores received it, which customers may be affected, and what action should we take first?”
Different users should receive different answers:
Store associate: sees affected products for their store, but not customer PII or companywide exposure.
Regional manager: sees affected stores in their region and summary customer counts.
Recall response lead: sees full affected store list, customer contact workflow, and complaint detail.
Developer / app service account: can call approved procedures and views, but cannot query everything directly.
DBA: can administer the environment, but sensitive application data can still be protected through separation-of-duty controls when using Database Vault.
That gives the lab a very clear “before and after” experience.

Technologies to feature
1. Database roles, privileges, and secure views
Use standard database access control to show least privilege.
Attendees create or use roles such as:
STORE\_USER
 REGIONAL\_MANAGER
 RECALL\_LEAD
 AI\_APP\_USER
Then expose only the right data through views or APIs.
Example:
RECALL\_EVENTS\_VIEW
 AFFECTED\_STORES\_VIEW
 CUSTOMER\_CONTACT\_SAFE\_VIEW
 AUTHORIZED\_RECALL\_CONTEXT\_VIEW

## Lab 5: Unified Oracle APEX Recall Command Center

The final workshop experience will use Oracle APEX instead of a learner-managed Python runtime or separate application tier. Every learner receives an importable APEX 24.2 application export named `f105.sql`.

The 60-minute hands-on block is divided into five 12-minute labs:

1. Investigate relational, JSON, vector, graph, and spatial evidence.
2. Build the Select AI Agent.
3. Publish authenticated JSON and GeoJSON APIs with ORDS.
4. Apply Deep Data Security to three local end users.
5. Import and run the unified APEX Recall Command Center.

The APEX application includes:

- Oracle APEX Accounts authentication with a visible signed-in user.
- `STORE_101_USER`, `REGION_NE_USER`, and `RECALL_LEAD_USER` application accounts.
- `APEX_LANG.MESSAGE` text messages for translated role labels.
- Dashboard cards for affected stores, units, customers, and semantic complaint matches.
- A native Oracle Spatial map whose store markers change by persona.
- Shipment detail, JSON-derived complaint evidence, and the priority recall action.
- A role-aware agent-answer panel.
- One `RECALL_SECURED_TEAM` Select AI Agent demonstration across the store, regional, and recall-lead roles. Each role supplies a different database-authorized context and receives a scoped answer.
- An application audit timeline for dashboard views and agent requests.

The security flow remains explicit:

```text
Local Deep Data Security user session
    -> role-filtered JSON and GeoJSON capture
    -> trusted RECALL_OWNER Select AI Agent summary
    -> APEX account with the same identity name
    -> APP_USER-filtered views and package
    -> dashboard, map, answer, and audit
```

APEX runs application SQL through its parsing schema and managed connection pool. The application does not claim that an APEX login alone creates `ORA_END_USER_CONTEXT`. Deep Data Security makes the disclosure decision in the direct local-end-user session. A trusted `RECALL_OWNER` session then invokes the same Select AI Agent team once for each role and stores the three scoped answers. APEX retrieves only the latest secured capture and agent answer whose end-user name matches the authenticated `APEX$SESSION.APP_USER`.

The final result gives attendees one application that visibly ties together operational SQL, native JSON, AI Vector Search, Oracle Spatial, Select AI Agent, Deep Data Security, APEX authentication, and audit evidence.
