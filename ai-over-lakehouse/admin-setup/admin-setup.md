# Lab 1: Prepare the PeakGear lab as ADMIN

Estimated Time: 15 minutes

## Introduction

You will prepare a small, bounded schema for the participant and create the
shared read-only connection to the existing Oracle Operations database. This
is the only lab performed as ADMIN.

The Azure and Databricks credentials are deliberately not created here. They
belong to PEAKGEAR&#95;USER and will be created through Data Studio in Lab 3.

### Objectives

In this lab, you will:

* create and grant the least-privileged PeakGear participant;
* create the public read-only Operations database link;
* produce the non-secret Data Studio URL required by Codex; and
* allow PEAKGEAR&#95;USER, not `ADMIN`, to reach the Databricks OAuth endpoint.

### Prerequisites

* You are signed in to Oracle Data Studio as ADMIN.
* You have the assigned event database and its ADMIN sign-in.
* The shared event values are included below and in
  [Event lab values](../assets/event-lab-values.md).
* The default AI profile is already configured by the lab environment. Do not
  create, edit, or validate an AI profile in this workshop.

## Task 1: Run the ADMIN setup

1. In Data Studio, open **SQL Worksheet** and confirm that the header shows
   ADMIN.
2. Open [00-admin-setup.sql](../scripts/00-admin-setup.sql).
3. Read the verification query before every create block. Run a create block
   only when its check shows that the object is absent.
4. The script already contains the event values. Do not replace any placeholders.
5. Run the script in order. A new PEAKGEAR&#95;USER account gets the password
   shown below; an existing account keeps its current password.

| Field | Event value |
|---|---|
| New PEAKGEAR&#95;USER password | Welcome123456 |
| Operations username | PEAKGEAR&#95;OPS |
| Operations password | Welcome123456 |
| Operations hostname | adb.us-ashburn-1.oraclecloud.com |
| Operations port | 1522 |
| Operations service name | mqssyowmqvgac1y&#95;operationalstore&#95;low.adb.oraclecloud.com |
| Databricks ACL host | adb-2242907740736663.3.azuredatabricks.net |

The script performs four business outcomes:

* PEAKGEAR&#95;USER gets only the privileges needed to own views and Analytic
  Views in this lab.
* The shared PEAKGEAR&#95;OPERATIONS&#95;LINK lets the participant read operational
  return events without creating another Operations connection.
* The ADP&#95;URL query returns the single non-secret URL that Codex needs later.
* The Databricks network ACL is granted to the literal database principal
  PEAKGEAR&#95;USER. Never replace it with CURRENT&#95;USER while signed in as `ADMIN`.

## Task 2: Verify the setup

Run the verification statements at the end of the script. The following query
must return a non-zero count:

~~~sql
SELECT COUNT(*) AS operational_return_events
FROM customer_return_events@peakgear_operations_link;
~~~

Still as ADMIN, run this copy-ready query:

~~~sql
SELECT 'https://' ||
       LOWER(REPLACE(p.name, '_', '-')) || '.' ||
       REGEXP_REPLACE(j.public_domain_name, '[^.]+', 'oraclecloudapps', 1, 3)
         AS adp_url
FROM v$pdbs p
CROSS JOIN JSON_TABLE(
  p.cloud_identity,
  '$' COLUMNS (
    public_domain_name VARCHAR2(512) PATH '$.PUBLIC_DOMAIN_NAME'
  )
) j
WHERE p.con_id = SYS_CONTEXT('USERENV', 'CON_ID');
~~~

Copy the ADP&#95;URL result. It is the **Lab Data Studio URL** used in Lab 2 and
Lab 4. It is generated for your assigned database; localhost:8000 is only the
workshop preview, not a database or MCP endpoint.

### Checkpoint

You have all of the following:

* a PEAKGEAR&#95;USER account with the listed grants;
* a working public PEAKGEAR&#95;OPERATIONS&#95;LINK;
* one copied Lab Data Studio URL; and
* an ACL for PEAKGEAR&#95;USER to the Databricks OAuth host on port 443.

## Task 3: Start a new participant session

**Sign out of Data Studio completely, then sign back in as PEAKGEAR&#95;USER.**
A browser refresh is not enough: it can retain the ADMIN database session and
its privileges.

<!-- Screenshot to insert after approved dry run: images/admin-setup-complete.png
     Alt text: SQL Worksheet shows successful PeakGear user and Operations-link
     validation. Event values are owner-approved; do not include unrelated credentials. -->

## Learn More

* [Oracle Data Studio Guide](https://docs.oracle.com/en/cloud/paas/autonomous-database/data-studio-guide/)

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
