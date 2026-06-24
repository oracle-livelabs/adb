# Lab 2: Create the ORDS REST Endpoint

## Introduction

In this lab, you will create the ORDS module, template, and handler that expose the PL/SQL function as a Prometheus-compatible HTTP endpoint. The key technique is using `source_type_media`, which streams raw content with a custom content type, bypassing ORDS's default JSON wrapping.

*Estimated Lab Time:* 10 minutes

### Objectives

- Create an ORDS module, template, and GET handler
- Understand how `source_type_media` enables custom content types
- Validate the endpoint returns Prometheus exposition format

### Prerequisites

- Completion of [Lab 1](?lab=create-schema-and-package)

## Task 1: Create the ORDS Module, Template, and Handler

1. Connect as **PROM\_EXPORTER** in Database Actions SQL Worksheet.

2. Run the following PL/SQL block to create the complete REST endpoint:

    ```sql
    BEGIN
        ORDS.DEFINE_MODULE(
            p_module_name    => 'prometheus',
            p_base_path      => '/prom/v1/',
            p_items_per_page => 0,
            p_status         => 'PUBLISHED',
            p_comments       => 'Prometheus-compatible metrics exporter'
        );

        ORDS.DEFINE_TEMPLATE(
            p_module_name => 'prometheus',
            p_pattern     => 'metrics',
            p_priority    => 0,
            p_etag_type   => 'NONE',
            p_etag_query  => NULL,
            p_comments    => 'Prometheus /metrics scrape endpoint'
        );

        ORDS.DEFINE_HANDLER(
            p_module_name    => 'prometheus',
            p_pattern        => 'metrics',
            p_method         => 'GET',
            p_source_type    => ORDS.source_type_media,
            p_source         => q'[SELECT 'text/plain; version=0.0.4; charset=utf-8',
                                          prom_metrics_pkg.generate()
                                   FROM dual]',
            p_items_per_page => 0,
            p_comments       => 'Returns metrics in Prometheus exposition format'
        );

        COMMIT;
    END;
    /
    ```

    **How It Works:** The `ORDS.source_type_media` handler expects a SQL query returning exactly **two columns**: (1) the content type string and (2) a BLOB or CLOB payload. ORDS streams the content as-is with the specified content type. This is what enables serving `text/plain` Prometheus format instead of the default JSON response.

## Task 2: Verify the ORDS Definitions

1. Run the following queries to confirm the module, template, and handler were created:

    ```sql
    SELECT name, uri_prefix, status FROM user_ords_modules;
    SELECT id, module_id, uri_template FROM user_ords_templates;
    SELECT id, template_id, source_type, method FROM user_ords_handlers;
    ```

2. You should see the `prometheus` module with `/prom/v1/` prefix, the `metrics` template, and a `GET` handler with `resource/lob` source type.

## Task 3: Identify Your Endpoint URL

Your ORDS endpoint URL on ADB-D follows this pattern:

`https://<scan-hostname>/ords/<DB_NAME>/prom_exporter/prom/v1/metrics`


To find your specific values:

1. In the OCI Console, navigate to your Autonomous AI Database and look at the **DB Connection** details. The SCAN hostname appears in the connection strings (e.g., `host-xxxxx-scan.fleetsubnet.adbvcn.oraclevcn.com`).

2. The DB\_NAME is the segment after `/ords/` in your Database Actions URL. You can also retrieve it with:

    ```bash
    oci db autonomous-database get \
      --autonomous-database-id <your_adb_ocid> \
      --query 'data."connection-urls"."sql-dev-web-url"' \
      --raw-output
    ```

3. Note your full endpoint URL as you will use it throughout the remaining labs.

## Task 4: Test the Endpoint (from a Compute Instance in the VCN)

1. If you have SSH access to any compute instance in the same VCN/subnet as your ADB-D, run:

    ```bash
    curl -k https://<scan-hostname>/ords/<DB_NAME>/prom_exporter/prom/v1/metrics
    ```

2. You should see the raw Prometheus exposition format text —which is the same output as the SQL `SELECT` test, but now served over HTTPS by ORDS.

    **Note:** The `-k` flag disables certificate verification (Autonomous AI Database uses a self-signed certificate for internal ORDS). If you do not have a compute instance yet, do not worry as you will create one in [Lab 4](?lab=deploy-prometheus-grafana).

    ```
    # HELP oracledb_sysstat Oracle system statistics.
    # TYPE oracledb_sysstat gauge
    oracledb_sysstat{stat="logons current"} 5
    oracledb_sysstat{stat="opened cursors current"} 24
    oracledb_sysstat{stat="user commits"} 140104
    oracledb_sysstat{stat="user rollbacks"} 37
    oracledb_sysstat{stat="user calls"} 93009
    oracledb_sysstat{stat="session logical reads"} 462954733
    oracledb_sysstat{stat="consistent gets"} 412816435
    oracledb_sysstat{stat="physical reads"} 6014954
    oracledb_sysstat{stat="db block changes"} 41256427
    oracledb_sysstat{stat="physical writes"} 327585
    oracledb_sysstat{stat="redo writes"} 0
    oracledb_sysstat{stat="parse count (total)"} 3775097
    oracledb_sysstat{stat="parse count (hard)"} 83755
    oracledb_sysstat{stat="execute count"} 61083226
    oracledb_sysstat{stat="bytes sent via SQL*Net to client"} 50494962
    oracledb_sysstat{stat="bytes received via SQL*Net from client"} 16006644
    # HELP oracledb_wait_class_time_secs Wait time seconds (last 60s).
    # TYPE oracledb_wait_class_time_secs gauge
    # HELP oracledb_wait_class_wait_count Wait count (last 60s).
    # TYPE oracledb_wait_class_wait_count gauge
    oracledb_wait_class_time_secs{wait_class="Other"} 1.008
    oracledb_wait_class_wait_count{wait_class="Other"} 10442
    oracledb_wait_class_time_secs{wait_class="Application"} .0006
    oracledb_wait_class_wait_count{wait_class="Application"} 4
    oracledb_wait_class_time_secs{wait_class="Configuration"} 0
    oracledb_wait_class_wait_count{wait_class="Configuration"} 0
    oracledb_wait_class_time_secs{wait_class="Administrative"} 0
    oracledb_wait_class_wait_count{wait_class="Administrative"} 0
    oracledb_wait_class_time_secs{wait_class="Concurrency"} .0082
    oracledb_wait_class_wait_count{wait_class="Concurrency"} 149
    oracledb_wait_class_time_secs{wait_class="Commit"} 0
    oracledb_wait_class_wait_count{wait_class="Commit"} 0
    oracledb_wait_class_time_secs{wait_class="Network"} .0019
    oracledb_wait_class_wait_count{wait_class="Network"} 86
    oracledb_wait_class_time_secs{wait_class="User I/O"} .0251
    oracledb_wait_class_wait_count{wait_class="User I/O"} 231
    oracledb_wait_class_time_secs{wait_class="System I/O"} .057
    oracledb_wait_class_wait_count{wait_class="System I/O"} 446
    oracledb_wait_class_time_secs{wait_class="Scheduler"} 0
    oracledb_wait_class_wait_count{wait_class="Scheduler"} 0
    oracledb_wait_class_time_secs{wait_class="Cluster"} .0023
    oracledb_wait_class_wait_count{wait_class="Cluster"} 40
    oracledb_wait_class_time_secs{wait_class="Queueing"} 0
    oracledb_wait_class_wait_count{wait_class="Queueing"} 0
    # HELP oracledb_sysmetric Oracle system metric.
    # TYPE oracledb_sysmetric gauge
    oracledb_sysmetric{metric="Buffer Cache Hit Ratio"} 99.1516
    oracledb_sysmetric{metric="Physical Reads Per Sec"} 1.3162
    oracledb_sysmetric{metric="Physical Writes Per Sec"} .5165
    oracledb_sysmetric{metric="Redo Generated Per Sec"} 1514.5618
    oracledb_sysmetric{metric="User Commits Per Sec"} .0666
    oracledb_sysmetric{metric="User Calls Per Sec"} 15.4282
    oracledb_sysmetric{metric="Logical Reads Per Sec"} 155.1483
    oracledb_sysmetric{metric="Hard Parse Count Per Sec"} .1666
    oracledb_sysmetric{metric="Host CPU Utilization (%)"} 15.7211
    oracledb_sysmetric{metric="Network Traffic Volume Per Sec"} 637.6208
    oracledb_sysmetric{metric="Current Logons Count"} 125
    oracledb_sysmetric{metric="SQL Service Response Time"} .0215
    oracledb_sysmetric{metric="Database Wait Time Ratio"} 8.4386
    oracledb_sysmetric{metric="Database CPU Time Ratio"} 91.5614
    oracledb_sysmetric{metric="Executions Per Sec"} 14.1953
    oracledb_sysmetric{metric="Average Active Sessions"} .0283
    # HELP oracledb_sessions_total Session count by status.
    # TYPE oracledb_sessions_total gauge
    oracledb_sessions_total{status="INACTIVE",type="USER"} 4
    oracledb_sessions_total{status="ACTIVE",type="USER"} 1
    # HELP oracledb_tablespace_used_pct Tablespace used percent.
    # TYPE oracledb_tablespace_used_pct gauge
    oracledb_tablespace_used_pct{tablespace="DATA"} .12
    oracledb_tablespace_used_pct{tablespace="DBFS_TS"} .28
    oracledb_tablespace_used_pct{tablespace="SYSAUX"} 11.83
    oracledb_tablespace_used_pct{tablespace="SYSTEM"} 4.55
    oracledb_tablespace_used_pct{tablespace="TEMP"} .01
    oracledb_tablespace_used_pct{tablespace="UNDOTBS1"} .01
    # HELP oracledb_pga_bytes PGA memory statistics.
    # TYPE oracledb_pga_bytes gauge
    oracledb_pga_bytes{stat="total PGA inuse"} 21925888
    oracledb_pga_bytes{stat="total PGA allocated"} 28938240
    oracledb_pga_bytes{stat="maximum PGA allocated"} 338446336
    # HELP oracledb_process_count Current process count.
    # TYPE oracledb_process_count gauge
    oracledb_process_count 4
    ```

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - German Viscuso, Product Manager, Oracle Autonomous AI Database
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, June 2026
