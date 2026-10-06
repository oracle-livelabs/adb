# PeakGear event lab values

These shared values are included with the event owner's approval for this
one-off workshop. Use them only for this event, not for another environment.
The source credentials below come from the owner-confirmed working mount script.

## Participant account

Username:

```text
PEAKGEAR_USER
```

Password for a **new account created by Lab 1**:

```text
Welcome123456
```

Lab 1 does not reset an existing account's password. If the account already
exists, use its current password.

The **Lab Data Studio URL** is the ADP_URL result from Lab 1, generated for the
assigned Autonomous AI Database. Do not use localhost:8000 or the Operations
database listener as the MCP connection URL.

## Operations database — ADMIN setup

Credential name:

```text
PEAKGEAR_OPS_CREDENTIAL
```

Username:

```text
PEAKGEAR_OPS
```

Password:

```text
Welcome123456
```

Hostname:

```text
adb.us-ashburn-1.oraclecloud.com
```

Port:

```text
1522
```

Service name:

```text
mqssyowmqvgac1y_operationalstore_low.adb.oraclecloud.com
```

Public database link:

```text
PEAKGEAR_OPERATIONS_LINK
```

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

Databricks ACL host (port 443, principal PEAKGEAR_USER):

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
