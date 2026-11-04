# PeakGear connection field reference

Estimated Time: Reference only; not a timed learner task.

### Objectives

Find the provisioned credential names and public connection settings.

LiveLabs provisioning creates both source credentials for PEAKGEAR_USER in
the assigned database before the workshop starts:

| Existing credential | Select in Data Studio | Purpose |
|---|---|---|
| DBX_PEAKGEAR_OAUTH | Iceberg catalog credentials | Authenticate to Databricks Unity Catalog |
| ADLS_PEAKGEAR_DATA | Bucket credentials | Read Iceberg data in Azure Blob Storage |

Learners select these existing credentials in Lab 2. They do not create,
replace, or enter source credentials. If either name is missing, stop and ask
the instructor to repair the reservation.

Protected source values stay in the private provisioning workflow. They are
not distributed in this repository or the downloadable Starter Kit.

## Participant account

Username:

```text
PEAKGEAR_USER
```

Use **Database User** and **Database Password** from your active LiveLabs
**View Login Info → Environment Details** for Data Studio sign-in and MCP
setup. The database password remains a learner input; it is separate from
the preconfigured source credentials and the OCI login password.

Obtain the database-specific HTTPS origin with the read-only SQL query in
Lab 3, Task 1 as PEAKGEAR_USER. If access fails or no URL is returned, ask the
instructor. Use the returned origin for MCP, not localhost or the Operations
database listener.

## Prepared Operations database link

Use **Operations Database Link** from your reservation. The expected value is:

```text
PEAKGEAR_OPERATIONS_LINK
```

The reservation provisions this link before the workshop starts. Participants
read through it; they do not create a credential or database link.

## Unity Iceberg catalog

Local catalog name:

```text
DBX_UNITY_PEAKGEAR
```

Catalog type: **Unity** in Data Studio, **ICEBERG_UNITY** in SQL. Public endpoint:

```text
https://adb-2242907740736663.3.azuredatabricks.net/api/2.1/unity-catalog/iceberg-rest/v1/catalogs/peakgear
```

Select **DBX_PEAKGEAR_OAUTH** for the catalog credential and
**ADLS_PEAKGEAR_DATA** for the bucket credential. Expected remote schema:
**ICEBERG**; expected tables: **PRODUCTS** and **DIGITAL_CLICKSTREAM_EVENTS**.

The provider validates the saved credentials before releasing the reservation.
Contact the instructor if a credential is unavailable.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, November 2026
