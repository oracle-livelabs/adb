# PeakGear event lab values

These shared values are included with the event owner's approval for this
one-off workshop. Use them only for this event, not for another environment.
The source credentials below come from the owner-confirmed working mount script.

## Participant account

Username:

```text
PEAKGEAR_USER
```

The authoritative **Database User** and **Database Password** are in your
LiveLabs **Reservation Information → Environment Details**. The account is
already provisioned. Do not use an example password or your OCI login password.
If the assigned user is not PEAKGEAR_USER, ask the instructor before continuing.

Obtain the database-specific HTTPS origin from the reserved database's
Database Actions URL, as described in Lab 2, Task 3. No ADMIN login or SQL lookup
is required. Do not use localhost:8000, datastudio.oracle.com, or the Operations
listener as the MCP connection URL.

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

Password:

```text
tFODcOQJpwaApm/p3wEqAdYIbvq9/N/jlMsbd2EMz6KwAyXps2+7D1TWLOvBQ8fCPOxaCXznM/YD+AStYElH9Q==
```

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

Client ID:

```text
5c47dc63-f693-4820-a40b-4b08c3709f34
```

Client secret:

```text
dose7b979ac313c1063af5d4cdf09b1ee8fb
```

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
