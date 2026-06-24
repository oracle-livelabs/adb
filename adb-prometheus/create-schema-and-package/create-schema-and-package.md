# Lab 1: Create the Exporter Schema and PL/SQL Package

## Introduction

In this lab, you will create a dedicated database schema for the Prometheus exporter and build the PL/SQL package that queries Oracle performance views and outputs metrics in Prometheus exposition format.

*Estimated Lab Time:* 15 minutes

### Objectives

- Create the `PROM_EXPORTER` schema with appropriate grants
- Build the `PROM_METRICS_PKG` PL/SQL package
- Validate the function output

### Prerequisites

- ADMIN access to your Autonomous AI Database instance (via SQLcl or SQL Worksheet)

## Task 1: Create the PROM\_EXPORTER Schema

1. Connect to your Autonomous AI Database instance as **ADMIN** using SQLcl or SQL Worksheet.

2. Run the following SQL to create the user and grant the necessary privileges:


    ```sql
    -- Create the user
    CREATE USER prom_exporter IDENTIFIED BY "<YourStrongPassword>";
    ```

    **Note:** Autonomous AI Database enforces password complexity. You need to use a minimum of 12 characters with uppercase, lowercase, digit, and special character.


    ```sql
    -- Grant the base role
    GRANT DWROLE TO prom_exporter;

    -- Grant SELECT on performance views
    GRANT SELECT ON V$SYSSTAT TO prom_exporter;
    GRANT SELECT ON V$SESSION TO prom_exporter;
    GRANT SELECT ON V$PGASTAT TO prom_exporter;
    GRANT SELECT ON V$PROCESS TO prom_exporter;
    GRANT SELECT ON V$SYSMETRIC TO prom_exporter;
    GRANT SELECT ON V$WAITCLASSMETRIC TO prom_exporter;
    GRANT SELECT ON DBA_TABLESPACE_USAGE_METRICS TO prom_exporter;

    -- Grant access to ACD_ cross-container views (Autonomous AI Database specific)
    GRANT ALL ON ACD_V$SYSMETRIC TO prom_exporter;
    GRANT ALL ON ACD_V$WAITCLASSMETRIC TO prom_exporter;
    ```

    **Note:** The `ACD_V$` views are cross-container views specific to Autonomous AI Database. They require `GRANT ALL` instead of `GRANT SELECT`. These views provide the real-time system metrics and wait class data that the standard `V$` equivalents may not populate on Autonomous AI Database.

## Task 2: Enable the Schema for ORDS

1. Connect as **PROM\_EXPORTER** (switch the user in your SQL client or log in directly as `prom_exporter`).

    **Important:** `ORDS.ENABLE_SCHEMA` must be run by the target schema itself, not by ADMIN.

2. Run the following PL/SQL block:

    ```sql
    BEGIN
        ORDS.ENABLE_SCHEMA(
            p_enabled             => TRUE,
            p_schema              => 'PROM_EXPORTER',
            p_url_mapping_type    => 'BASE_PATH',
            p_url_mapping_pattern => 'prom_exporter',
            p_auto_rest_auth      => FALSE
        );
        COMMIT;
    END;
    /
    ```

    **Note:** Setting `p_auto_rest_auth => FALSE` makes the endpoint publicly accessible initially. You will secure it with OAuth2 in [Lab 3](?lab=secure-with-oauth2).

## Task 3: Create the PL/SQL Package

1. Still connected as **PROM\_EXPORTER**, create the package specification:

    ```sql
    CREATE OR REPLACE PACKAGE prom_metrics_pkg AS
        FUNCTION generate RETURN CLOB;
    END prom_metrics_pkg;
    /
    ```

2. Create the package body:

    ```sql
    CREATE OR REPLACE PACKAGE BODY prom_metrics_pkg AS

        PROCEDURE append(p_clob IN OUT NOCOPY CLOB, p_line VARCHAR2) IS
        BEGIN
            DBMS_LOB.WRITEAPPEND(p_clob, LENGTH(p_line) + 1, p_line || CHR(10));
        END;

        FUNCTION wait_class_name(p_id NUMBER) RETURN VARCHAR2 IS
        BEGIN
            RETURN CASE p_id
                WHEN 0 THEN 'Other'
                WHEN 1 THEN 'Application'
                WHEN 2 THEN 'Configuration'
                WHEN 3 THEN 'Administrative'
                WHEN 4 THEN 'Concurrency'
                WHEN 5 THEN 'Commit'
                WHEN 6 THEN 'Idle'
                WHEN 7 THEN 'Network'
                WHEN 8 THEN 'User I/O'
                WHEN 9 THEN 'System I/O'
                WHEN 10 THEN 'Scheduler'
                WHEN 11 THEN 'Cluster'
                WHEN 12 THEN 'Queueing'
                ELSE 'Unknown_' || p_id
            END;
        END;

        FUNCTION generate RETURN CLOB IS
            v_clob  CLOB;
            v_val   NUMBER;
            v_name  VARCHAR2(200);
            v_wc    VARCHAR2(60);
        BEGIN
            DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

            -- 1. System statistics (V$SYSSTAT)
            append(v_clob, '# HELP oracledb_sysstat Oracle system statistics.');
            append(v_clob, '# TYPE oracledb_sysstat gauge');
            FOR rec IN (
                SELECT name, value FROM v$sysstat
                WHERE name IN (
                    'logons current','opened cursors current','user commits',
                    'user rollbacks','physical reads','physical writes',
                    'redo writes','parse count (total)','parse count (hard)',
                    'execute count','user calls','session logical reads',
                    'db block changes','consistent gets',
                    'bytes sent via SQL*Net to client',
                    'bytes received via SQL*Net from client')
            ) LOOP
                append(v_clob, 'oracledb_sysstat{stat="' || rec.name || '"} ' || rec.value);
            END LOOP;

            -- 2. Wait class metrics (ACD_V$WAITCLASSMETRIC)
            append(v_clob, '# HELP oracledb_wait_class_time_secs Wait time seconds (last 60s).');
            append(v_clob, '# TYPE oracledb_wait_class_time_secs gauge');
            append(v_clob, '# HELP oracledb_wait_class_wait_count Wait count (last 60s).');
            append(v_clob, '# TYPE oracledb_wait_class_wait_count gauge');
            FOR rec IN (
                SELECT "WAIT_CLASS#" AS wc_num,
                       ROUND(time_waited / 100, 4) AS time_waited_secs,
                       wait_count
                FROM acd_v$waitclassmetric
            ) LOOP
                v_wc := wait_class_name(rec.wc_num);
                IF v_wc <> 'Idle' THEN
                    append(v_clob, 'oracledb_wait_class_time_secs{wait_class="' || v_wc || '"} ' || rec.time_waited_secs);
                    append(v_clob, 'oracledb_wait_class_wait_count{wait_class="' || v_wc || '"} ' || rec.wait_count);
                END IF;
            END LOOP;

            -- 3. System metrics (ACD_V$SYSMETRIC, 60-second interval)
            append(v_clob, '# HELP oracledb_sysmetric Oracle system metric.');
            append(v_clob, '# TYPE oracledb_sysmetric gauge');
            FOR rec IN (
                SELECT metric_name, value FROM acd_v$sysmetric
                WHERE group_id = 2
                  AND metric_name IN (
                      'Buffer Cache Hit Ratio','SQL Service Response Time',
                      'Database CPU Time Ratio','Database Wait Time Ratio',
                      'Executions Per Sec','Hard Parse Count Per Sec',
                      'Logical Reads Per Sec','Physical Reads Per Sec',
                      'Physical Writes Per Sec','User Commits Per Sec',
                      'User Calls Per Sec','Current Logons Count',
                      'Average Active Sessions','Host CPU Utilization (%)',
                      'Redo Generated Per Sec','Network Traffic Volume Per Sec')
            ) LOOP
                append(v_clob, 'oracledb_sysmetric{metric="' || rec.metric_name || '"} ' || ROUND(rec.value, 4));
            END LOOP;

            -- 4. Sessions by status and type
            append(v_clob, '# HELP oracledb_sessions_total Session count by status.');
            append(v_clob, '# TYPE oracledb_sessions_total gauge');
            FOR rec IN (
                SELECT status, type, COUNT(*) AS cnt
                FROM v$session GROUP BY status, type
            ) LOOP
                append(v_clob, 'oracledb_sessions_total{status="' || rec.status || '",type="' || rec.type || '"} ' || rec.cnt);
            END LOOP;

            -- 5. Tablespace usage
            append(v_clob, '# HELP oracledb_tablespace_used_pct Tablespace used percent.');
            append(v_clob, '# TYPE oracledb_tablespace_used_pct gauge');
            FOR rec IN (
                SELECT tablespace_name, ROUND(used_percent, 2) AS used_pct
                FROM dba_tablespace_usage_metrics
            ) LOOP
                append(v_clob, 'oracledb_tablespace_used_pct{tablespace="' || rec.tablespace_name || '"} ' || rec.used_pct);
            END LOOP;

            -- 6. PGA memory statistics
            append(v_clob, '# HELP oracledb_pga_bytes PGA memory statistics.');
            append(v_clob, '# TYPE oracledb_pga_bytes gauge');
            FOR rec IN (
                SELECT name, value FROM v$pgastat
                WHERE name IN ('total PGA allocated','total PGA inuse','maximum PGA allocated')
            ) LOOP
                append(v_clob, 'oracledb_pga_bytes{stat="' || rec.name || '"} ' || rec.value);
            END LOOP;

            -- 7. Process count
            append(v_clob, '# HELP oracledb_process_count Current process count.');
            append(v_clob, '# TYPE oracledb_process_count gauge');
            SELECT COUNT(*) INTO v_val FROM v$process;
            append(v_clob, 'oracledb_process_count ' || v_val);

            RETURN v_clob;
        END generate;

    END prom_metrics_pkg;
    /
    ```

## Task 4: Validate the Function Output

1. Run the following query to test the function:

    ```sql
    SELECT prom_metrics_pkg.generate() FROM dual;
    ```

2. You should see output in Prometheus exposition format with proper `# HELP`, `# TYPE` headers and metric lines with labels. Verify you see data in all sections, especially `oracledb_wait_class_time_secs` (with labels like `User I/O`, `System I/O`) and `oracledb_sysmetric` (with metrics like `Average Active Sessions`, `Buffer Cache Hit Ratio`).

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - German Viscuso, Product Manager, Oracle Autonomous AI Database
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, June 2026
