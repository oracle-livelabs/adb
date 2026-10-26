# PeakGear connection field reference

Estimated Time: Reference only; not a timed learner task.

### Objectives

Find public connection settings and obtain protected credentials from your active LiveLabs reservation.

Passwords, SAS tokens, and Databricks OAuth values are not distributed in this
repository or the downloadable Starter Kit. Open LiveLabs **View Login Info**
(**Reservation Information**), then expand **Environment Details**. Copy the
protected values from your own active reservation:

| LiveLabs field | Data Studio field |
|---|---|
| Azure Storage Password | Azure credential: Password |
| Databricks Client ID | Iceberg OAuth2 credential: Client ID |
| Databricks Client Secret | Iceberg OAuth2 credential: Client secret |

If any field is missing or empty, stop and ask the instructor to have the
reservation details completed. Do not use values from screenshots, GitHub
history, another learner, or a previous reservation. Do not paste credentials
into chat, source control, or support screenshots.

## Participant account

Username:

```text
PEAKGEAR_USER
```

The authoritative **Database User** and **Database Password** are in your
LiveLabs **Reservation Information → Environment Details**. The account is
already provisioned. Do not use an example password or your OCI login password.
If the assigned user is not PEAKGEAR_USER, ask the instructor before continuing.

Obtain the database-specific HTTPS origin with the read-only SQL query in
Lab 3, Task 1. Run it in Data Studio while connected to your assigned database
as PEAKGEAR_USER. If access is denied or no URL is returned, ask the instructor;
do not grant privileges or switch to ADMIN. Do not use localhost:8000,
datastudio.oracle.com, or the Operations listener as the MCP connection URL.

## Prepared Operations database link

Use **Operations Database Link** from your reservation. The expected value is:

```text
PEAKGEAR_OPERATIONS_LINK
```

The reservation provisions this link before the workshop starts. Participants
read through it; they do not create a credential or database link.

## Azure storage credential — PEAKGEAR_USER

Credential name:

```text
ADLS_PEAKGEAR_DATA
```

Credential type: **Azure**. Username:

```text
livelab
```

**Password:** copy **Azure Storage Password** from **View Login Info →
Environment Details**, not Database Password or OCI Password.

Storage path:

```text
https://livelab.blob.core.windows.net/digital-demand/peakgear-managed/
```

## Databricks Unity OAuth credential — PEAKGEAR_USER

Credential name:

```text
DBX_PEAKGEAR_OAUTH
```

Credential type: **Iceberg OAuth2**. Token endpoint:

```text
https://adb-2242907740736663.3.azuredatabricks.net/oidc/v1/token
```

**Client ID:** copy **Databricks Client ID** from **View Login Info →
Environment Details**.

**Client secret:** copy **Databricks Client Secret** from the same panel.

Token scope:

```text
all-apis
```

Token refresh rate in seconds:

```text
3600
```

Provider-provisioned Databricks ACL host (port 443, principal PEAKGEAR_USER).
Participants do not create or change this ACL:

```text
adb-2242907740736663.3.azuredatabricks.net
```

## Unity Iceberg catalog — PEAKGEAR_USER

Local catalog name:

```text
DBX_UNITY_PEAKGEAR
```

Catalog type: **Unity** in Data Studio, **ICEBERG_UNITY** in SQL. Endpoint:

```text
https://adb-2242907740736663.3.azuredatabricks.net/api/2.1/unity-catalog/iceberg-rest/v1/catalogs/peakgear
```

Select **DBX_PEAKGEAR_OAUTH** for the catalog credential and
**ADLS_PEAKGEAR_DATA** for the bucket credential. Expected remote schema:
**ICEBERG**; expected tables: **PRODUCTS** and **DIGITAL_CLICKSTREAM_EVENTS**.

## Acknowledgements

* **Author** - Oracle AI Lakehouse workshop team
* **Last Updated By/Date** - Oracle AI Lakehouse workshop team, October 2026
