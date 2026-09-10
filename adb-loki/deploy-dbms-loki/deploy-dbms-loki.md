# Lab 2: Deploy the DBMS_LOKI Package

## Introduction

In this lab, you will create a DBMS_LOKI package in your Autonomous AI Database instance. This includes creating the exporter schema if it does not already exist, granting the necessary privileges, creating the audit trail wrapper view, and running the provisioning steps that create the tables and PL/SQL package.

*Estimated Lab Time:* 15 minutes

### Objectives

- Create the PROMETHEUS_EXPORTER schema (or reuse from [companion workshop](https://placeholder-url/prometheus-livelab))
- Grant alert log, audit trail, scheduler, and network ACL privileges
- Create the audit trail wrapper view (required for Autonomous AI Database)
- Deploy the DBMS_LOKI package with default log sources

### Prerequisites

- ADMIN access to your Autonomous AI Database instance (via SQLcl or SQL Worksheet)
- The Loki compute instance IP address from [Lab 1](?lab=install-loki)

## Task 1: Create the Exporter Schema

 **Already completed the Prometheus workshop?** If the `PROMETHEUS_EXPORTER` schema already exists, skip to Task 2.

1. Connect to your Autonomous AI Database instance as **ADMIN** using SQL Worksheet or SQLcl.

2. Create the schema:

    ```sql
    
    CREATE USER prometheus_exporter IDENTIFIED BY "<YourStrongPassword>";
    GRANT DWROLE TO prometheus_exporter;
    
    ```

    **Note:** Autonomous AI Database enforces password complexity using a minimum of 12 characters with uppercase, lowercase, digit, and special character.

## Task 2: Grant Privileges

1. While still connected as **ADMIN**, grant th required access to the alert log and audit trail:

    ```sql
    
    -- Alert log access
    GRANT SELECT ON V$DIAG_ALERT_EXT TO prometheus_exporter;

    -- Audit trail access (role-based — required for AUTHID CURRENT_USER)
    GRANT AUDIT_VIEWER TO prometheus_exporter;

    -- Scheduler permission for recurring push job
    GRANT CREATE JOB TO prometheus_exporter;
    
    ```

2. Configure the network ACL so the database can make HTTP calls to Loki:

    ```sql
    
    BEGIN
        DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
            host => '<compute_private_ip>',
            ace  => xs$ace_type(
                privilege_list => xs$name_list('connect', 'http'),
                principal_name => 'PROMETHEUS_EXPORTER',
                principal_type => xs_acl.ptype_db
            )
        );
        COMMIT;
    END;
    /
    
    ```

    Replace `<compute_private_ip>` with your Loki host's IP (e.g., `10.0.0.57`).

     **Note:** In production, always scope the ACL to the specific Loki host IP rather than using a wildcard (`*`). This prevents the exporter schema from connecting to any unauthorized host.

## Task 3: Create the Audit Trail View

On Autonomous AI Database, direct grants on audit objects such as `AUDSYS.UNIFIED_AUDIT_TRAIL` are not permitted. To provide the required access, create a wrapper view owned by the ADMIN user:

1. While still connected as **ADMIN**, run:

    ```sql
    
    CREATE OR REPLACE VIEW admin.v_audit_trail AS
    SELECT event_timestamp, dbusername, action_name, object_schema, object_name,
           TO_CHAR(return_code) AS return_code,
           CAST(sql_text AS VARCHAR2(500)) AS sql_text
    FROM unified_audit_trail;

    GRANT SELECT ON admin.v_audit_trail TO prometheus_exporter;
    
    ```

    **Why use a view?** The `AUDIT_VIEWER` role provides access in interactive SQL, but PL/SQL packages and DBMS_SCHEDULER jobs cannot rely on  role-based privileges; they require direct grants. Because Oracle does not allow direct grants on AUDSYS objects in Autonomous AI Database, an ADMIN-owned view bridges the gap.

## Task 4: Create the Log Source Registry Table

While still connected as **ADMIN**, create the log source registry table. Each log source (alert log, audit trail, custom sources) is stored as a row in this table.

```sql

DECLARE
    v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tables
    WHERE owner = 'PROMETHEUS_EXPORTER' AND table_name = 'LOKI_LOG_SOURCES';
    IF v_cnt > 0 THEN
        DBMS_OUTPUT.PUT_LINE('LOKI_LOG_SOURCES already exists — skipping.');
        RETURN;
    END IF;

    EXECUTE IMMEDIATE '
    CREATE TABLE prometheus_exporter.loki_log_sources (
        source_name     VARCHAR2(128)  NOT NULL,
        source_sql      CLOB           NOT NULL,
        stream_labels   VARCHAR2(500)  NOT NULL,
        timestamp_col   VARCHAR2(128)  NOT NULL,
        message_cols    VARCHAR2(500)  NOT NULL,
        is_enabled      NUMBER(1)      DEFAULT 1 NOT NULL,
        is_builtin      NUMBER(1)      DEFAULT 1 NOT NULL,
        created_by      VARCHAR2(128)  DEFAULT USER,
        created_at      TIMESTAMP      DEFAULT SYSTIMESTAMP,
        CONSTRAINT pk_loki_sources PRIMARY KEY (source_name),
        CONSTRAINT chk_loki_enabled CHECK (is_enabled IN (0, 1)),
        CONSTRAINT chk_loki_builtin CHECK (is_builtin IN (0, 1))
    )';

    DBMS_OUTPUT.PUT_LINE('LOKI_LOG_SOURCES table created.');
END;
/

```

Expected output: `LOKI_LOG_SOURCES table created.`

## Task 5: Create the Watermark and Configuration Tables

1. While still connected as **ADMIN**, create the watermark table. This tracks the last pushed timestamp per source and the engine uses it to send only new entries on each push cycle.

    ```sql
    
    DECLARE
        v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM all_tables
        WHERE owner = 'PROMETHEUS_EXPORTER' AND table_name = 'LOKI_PUSH_WATERMARKS';
        IF v_cnt > 0 THEN
            DBMS_OUTPUT.PUT_LINE('LOKI_PUSH_WATERMARKS already exists — skipping.');
            RETURN;
        END IF;

        EXECUTE IMMEDIATE '
        CREATE TABLE prometheus_exporter.loki_push_watermarks (
            source_name  VARCHAR2(128)  NOT NULL,
            last_pushed  TIMESTAMP      NOT NULL,
            push_count   NUMBER         DEFAULT 0,
            last_error   VARCHAR2(4000),
            updated_at   TIMESTAMP      DEFAULT SYSTIMESTAMP,
            CONSTRAINT pk_loki_watermarks PRIMARY KEY (source_name),
            CONSTRAINT fk_loki_wm_source FOREIGN KEY (source_name)
                REFERENCES prometheus_exporter.loki_log_sources(source_name) ON DELETE CASCADE
        )';

        DBMS_OUTPUT.PUT_LINE('LOKI_PUSH_WATERMARKS table created.');
    END;
    /
    
    ```

2. Create the configuration table. This stores the Loki endpoint URL.

    ```sql
    
    DECLARE
        v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM all_tables
        WHERE owner = 'PROMETHEUS_EXPORTER' AND table_name = 'LOKI_CONFIG';
        IF v_cnt > 0 THEN
            DBMS_OUTPUT.PUT_LINE('LOKI_CONFIG already exists — skipping.');
            RETURN;
        END IF;

        EXECUTE IMMEDIATE '
        CREATE TABLE prometheus_exporter.loki_config (
            config_key   VARCHAR2(128)  NOT NULL,
            config_value VARCHAR2(4000) NOT NULL,
            CONSTRAINT pk_loki_config PRIMARY KEY (config_key)
        )';

        DBMS_OUTPUT.PUT_LINE('LOKI_CONFIG table created.');
    END;
    /
    
    ```

## Task 6: Seed the Default Log Sources

While still connected as **ADMIN**, insert the two default log sources: alert log and unified audit trail.

```sql

DECLARE
    PROCEDURE seed_source(
        p_name VARCHAR2, p_sql CLOB, p_labels VARCHAR2,
        p_ts_col VARCHAR2, p_msg_cols VARCHAR2
    ) IS
        v_exists NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_exists
        FROM prometheus_exporter.loki_log_sources WHERE source_name = p_name;
        IF v_exists = 0 THEN
            INSERT INTO prometheus_exporter.loki_log_sources
                (source_name, source_sql, stream_labels, timestamp_col,
                message_cols, is_enabled, is_builtin, created_by)
            VALUES (p_name, p_sql, p_labels, p_ts_col, p_msg_cols, 1, 1, 'ADMIN');
        END IF;
    END;
BEGIN
    -- 1. Alert log
    seed_source(
        'alert_log',
        q'[SELECT originating_timestamp AS log_ts,
                component_id, TO_CHAR(message_level) AS message_level,
                message_text
        FROM v$diag_alert_ext
        WHERE originating_timestamp > :watermark
        ORDER BY originating_timestamp ASC
        FETCH FIRST 100 ROWS ONLY]',
        'source:alert_log',
        'log_ts',
        'component_id,message_level,message_text'
    );

    -- 2. Unified audit trail (via admin.v_audit_trail view)
    seed_source(
        'audit_trail',
        q'[SELECT event_timestamp AS log_ts,
                dbusername, action_name, object_schema, object_name,
                return_code, sql_text
        FROM admin.v_audit_trail
        WHERE event_timestamp > :watermark
        ORDER BY event_timestamp ASC
        FETCH FIRST 100 ROWS ONLY]',
        'source:audit_trail',
        'log_ts',
        'dbusername,action_name,object_schema,object_name,return_code,sql_text'
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Seed data loaded (2 default log sources).');
END;
/

```

Expected output: `Seed data loaded (2 default log sources).`

## Task 7: Create the Package Specification

While still connected as **ADMIN**, create the DBMS_LOKI package specification. This defines the public API including all procedures and functions customers will call.

```sql

CREATE OR REPLACE PACKAGE prometheus_exporter.dbms_loki AUTHID CURRENT_USER AS

    -- Configuration
    PROCEDURE configure(p_loki_url VARCHAR2);
    FUNCTION get_config(p_key VARCHAR2) RETURN VARCHAR2;

    -- Log source management
    TYPE t_source_info IS RECORD (
        source_name VARCHAR2(128), stream_labels VARCHAR2(500),
        is_enabled NUMBER(1), is_builtin NUMBER(1),
        last_pushed TIMESTAMP, push_count NUMBER, last_error VARCHAR2(4000)
    );
    TYPE t_source_info_tab IS TABLE OF t_source_info;
    FUNCTION list_sources RETURN t_source_info_tab PIPELINED;

    PROCEDURE enable_source(p_source_name VARCHAR2);
    PROCEDURE disable_source(p_source_name VARCHAR2);

    PROCEDURE add_custom_source(
        p_source_name VARCHAR2, p_source_sql CLOB,
        p_stream_labels VARCHAR2, p_timestamp_col VARCHAR2, p_message_cols VARCHAR2
    );
    PROCEDURE remove_custom_source(p_source_name VARCHAR2);

    -- Push operations
    PROCEDURE push_logs;
    PROCEDURE push_source(p_source_name VARCHAR2);

    -- Scheduler
    PROCEDURE start_push(p_interval_secs NUMBER DEFAULT 60);
    PROCEDURE stop_push;
    FUNCTION  is_running RETURN BOOLEAN;

    -- Testing
    PROCEDURE test_push(p_source_name VARCHAR2 DEFAULT NULL);

    -- Internal types (used by package body for DBMS_SQL disambiguation)
    TYPE t_str_tab IS TABLE OF VARCHAR2(128);
    TYPE t_idx_tab IS TABLE OF PLS_INTEGER;

END dbms_loki;
/

```
The AUTHID CURRENT_USER clause is critical because it causes the package to execute with the privileges of the invoking user rather than the package owner. This enables the package to use privileges granted through roles, such as AUDIT_VIEWER, which is necessary for scheduler jobs and package procedures to access the audit trail. Without AUTHID CURRENT_USER, the package would execute with definer's rights and would not be able to leverage role-based privileges.

Expected output: `Package PROMETHEUS_EXPORTER.DBMS_LOKI compiled`

**Note:** The `AUTHID CURRENT_USER` clause is critical because it causes the package to run with the privileges of the invoking user rather than the package owner. This enables the package to use privileges granted through roles, such as `AUDIT_VIEWER`, which is necessary for scheduler jobs and package procedures to access the audit trail. Without `AUTHID CURRENT_USER`, the package would run with definer's rights and would not be able to leverage role-based privileges.

## Task 8: Create the Package Body

While still connected as **ADMIN**, create the package body. This contains the push engine, JSON formatting, watermark management, and all API implementations.

**Note:** Copy and paste the entire code block and run it as a single statement.

```sql

CREATE OR REPLACE PACKAGE BODY prometheus_exporter.dbms_loki AS

    c_job_name CONSTANT VARCHAR2(50) := 'DBMS_LOKI_PUSH_JOB';

    FUNCTION sanitize_json(p_val VARCHAR2) RETURN VARCHAR2 IS
        v_str VARCHAR2(4000);
    BEGIN
        IF p_val IS NULL THEN RETURN ''; END IF;
        v_str := SUBSTR(p_val, 1, 2000);
        v_str := REGEXP_REPLACE(v_str, '[^[:print:][:space:]]', '');
        v_str := REPLACE(v_str, '\', '\\');
        v_str := REPLACE(v_str, '"', '''');
        v_str := REPLACE(v_str, CHR(10), '\n');
        v_str := REPLACE(v_str, CHR(13), '');
        v_str := REPLACE(v_str, CHR(9), ' ');
        RETURN v_str;
    END;

    FUNCTION split_csv(p_csv VARCHAR2) RETURN t_str_tab IS
        v_tab t_str_tab := t_str_tab();
        v_str VARCHAR2(500) := p_csv;
        v_pos PLS_INTEGER;
    BEGIN
        IF p_csv IS NULL THEN RETURN v_tab; END IF;
        LOOP
            v_pos := INSTR(v_str, ',');
            IF v_pos = 0 THEN
                v_tab.EXTEND; v_tab(v_tab.COUNT) := TRIM(v_str); EXIT;
            ELSE
                v_tab.EXTEND; v_tab(v_tab.COUNT) := TRIM(SUBSTR(v_str, 1, v_pos - 1));
                v_str := SUBSTR(v_str, v_pos + 1);
            END IF;
        END LOOP;
        RETURN v_tab;
    END;

    FUNCTION parse_stream_labels(p_labels VARCHAR2) RETURN VARCHAR2 IS
        v_parts  t_str_tab;
        v_result VARCHAR2(4000);
        v_pos    PLS_INTEGER;
    BEGIN
        v_result := '"job":"oracle_adb"';
        v_result := v_result || ',"db_name":"' || SYS_CONTEXT('USERENV','DB_NAME') || '"';
        v_result := v_result || ',"host":"' || SYS_CONTEXT('USERENV','SERVER_HOST') || '"';
        v_parts := split_csv(p_labels);
        FOR i IN 1..v_parts.COUNT LOOP
            v_pos := INSTR(v_parts(i), ':');
            IF v_pos > 0 THEN
                v_result := v_result || ',"'
                    || SUBSTR(v_parts(i), 1, v_pos - 1) || '":"'
                    || SUBSTR(v_parts(i), v_pos + 1) || '"';
            END IF;
        END LOOP;
        RETURN v_result;
    END;

    FUNCTION epoch_ns_from_ts(p_ts TIMESTAMP) RETURN VARCHAR2 IS
        v_epoch NUMBER;
    BEGIN
        v_epoch := (CAST(p_ts AT TIME ZONE 'UTC' AS DATE) - DATE '1970-01-01') * 86400;
        RETURN TO_CHAR(v_epoch, 'FM99999999999') || '000000000';
    END;

    PROCEDURE push_source_internal(
        p_source_name   VARCHAR2, p_source_sql CLOB, p_stream_labels VARCHAR2,
        p_timestamp_col VARCHAR2, p_message_cols VARCHAR2,
        p_loki_url VARCHAR2, p_verbose BOOLEAN DEFAULT FALSE
    ) IS
        v_cur       INTEGER;
        v_rc        INTEGER;
        v_col_cnt   INTEGER;
        v_desc_tab  DBMS_SQL.DESC_TAB;
        v_ts_idx    PLS_INTEGER;
        v_msg_cols  t_str_tab;
        v_msg_idx   t_idx_tab := t_idx_tab();
        v_str_buf   VARCHAR2(4000);
        v_watermark TIMESTAMP;
        v_max_ts    TIMESTAMP := NULL;
        v_values    CLOB;
        v_payload   CLOB;
        v_first     BOOLEAN := TRUE;
        v_count     PLS_INTEGER := 0;
        v_epoch     VARCHAR2(30);
        v_line      VARCHAR2(4000);
        v_labels_json VARCHAR2(4000);
        v_errmsg    VARCHAR2(4000);
        v_req       UTL_HTTP.REQ;
        v_resp      UTL_HTTP.RESP;
        v_resp_body VARCHAR2(4000);
    BEGIN
        BEGIN
            SELECT last_pushed INTO v_watermark
            FROM loki_push_watermarks WHERE source_name = p_source_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_watermark := SYSTIMESTAMP - INTERVAL '5' MINUTE;
                INSERT INTO loki_push_watermarks (source_name, last_pushed, push_count)
                VALUES (p_source_name, v_watermark, 0);
                COMMIT;
        END;

        v_labels_json := parse_stream_labels(p_stream_labels);
        v_msg_cols := split_csv(p_message_cols);

        v_cur := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_cur, p_source_sql, DBMS_SQL.NATIVE);
        DBMS_SQL.BIND_VARIABLE(v_cur, ':watermark', v_watermark);
        DBMS_SQL.DESCRIBE_COLUMNS(v_cur, v_col_cnt, v_desc_tab);

        v_ts_idx := NULL;
        v_msg_idx.EXTEND(v_msg_cols.COUNT);
        FOR i IN 1..v_col_cnt LOOP
            IF UPPER(v_desc_tab(i).col_name) = UPPER(p_timestamp_col) THEN v_ts_idx := i; END IF;
            FOR j IN 1..v_msg_cols.COUNT LOOP
                IF UPPER(v_desc_tab(i).col_name) = UPPER(v_msg_cols(j)) THEN v_msg_idx(j) := i; END IF;
            END LOOP;
        END LOOP;

        FOR i IN 1..v_col_cnt LOOP
            v_str_buf := NULL;
            DBMS_SQL.DEFINE_COLUMN(v_cur, i, v_str_buf, 4000);
        END LOOP;

        v_rc := DBMS_SQL.EXECUTE(v_cur);

        DBMS_LOB.CREATETEMPORARY(v_values, TRUE);
        LOOP
            EXIT WHEN DBMS_SQL.FETCH_ROWS(v_cur) = 0;
            v_count := v_count + 1;

            v_str_buf := NULL;
            DBMS_SQL.COLUMN_VALUE(v_cur, v_ts_idx, v_str_buf);
            BEGIN
                v_epoch := epoch_ns_from_ts(TO_TIMESTAMP(v_str_buf, 'YYYY-MM-DD HH24:MI:SS.FF'));
                IF v_max_ts IS NULL OR TO_TIMESTAMP(v_str_buf, 'YYYY-MM-DD HH24:MI:SS.FF') > v_max_ts THEN
                    v_max_ts := TO_TIMESTAMP(v_str_buf, 'YYYY-MM-DD HH24:MI:SS.FF');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN v_epoch := epoch_ns_from_ts(SYSTIMESTAMP);
            END;

            v_epoch := SUBSTR(v_epoch, 1, LENGTH(v_epoch) - 9) || LPAD(v_count, 9, '0');

            v_line := '';
            FOR j IN 1..v_msg_cols.COUNT LOOP
                BEGIN
                    v_str_buf := NULL;
                    DBMS_SQL.COLUMN_VALUE(v_cur, v_msg_idx(j), v_str_buf);
                    IF v_str_buf IS NOT NULL THEN
                        IF v_line IS NOT NULL THEN v_line := v_line || ' '; END IF;
                        v_line := v_line || LOWER(v_msg_cols(j)) || '=' || sanitize_json(v_str_buf);
                    END IF;
                EXCEPTION WHEN OTHERS THEN NULL;
                END;
            END LOOP;

            IF NOT v_first THEN DBMS_LOB.WRITEAPPEND(v_values, 1, ','); END IF;
            DECLARE
                v_entry VARCHAR2(4000);
            BEGIN
                v_entry := '["' || v_epoch || '","' || sanitize_json(v_line) || '"]';
                DBMS_LOB.WRITEAPPEND(v_values, LENGTH(v_entry), v_entry);
            END;
            v_first := FALSE;
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR(v_cur);

        IF v_count = 0 THEN
            IF p_verbose THEN
                DBMS_OUTPUT.PUT_LINE(p_source_name || ': no new entries since ' ||
                    TO_CHAR(v_watermark, 'YYYY-MM-DD HH24:MI:SS'));
            END IF;
            RETURN;
        END IF;

        DBMS_LOB.CREATETEMPORARY(v_payload, TRUE);
        DECLARE
            v_header VARCHAR2(4000);
            v_footer VARCHAR2(10);
        BEGIN
            v_header := '{"streams":[{"stream":{' || v_labels_json || '},"values":[';
            v_footer := ']}]}';
            DBMS_LOB.WRITEAPPEND(v_payload, LENGTH(v_header), v_header);
            DBMS_LOB.APPEND(v_payload, v_values);
            DBMS_LOB.WRITEAPPEND(v_payload, LENGTH(v_footer), v_footer);
        END;

        v_req := UTL_HTTP.BEGIN_REQUEST(p_loki_url || '/loki/api/v1/push', 'POST');
        UTL_HTTP.SET_HEADER(v_req, 'Content-Type', 'application/json');
        UTL_HTTP.SET_HEADER(v_req, 'Content-Length', DBMS_LOB.GETLENGTH(v_payload));

        DECLARE
            v_offset PLS_INTEGER := 1;
            v_chunk  VARCHAR2(4000);
            v_amount PLS_INTEGER;
        BEGIN
            WHILE v_offset <= DBMS_LOB.GETLENGTH(v_payload) LOOP
                v_amount := LEAST(4000, DBMS_LOB.GETLENGTH(v_payload) - v_offset + 1);
                DBMS_LOB.READ(v_payload, v_amount, v_offset, v_chunk);
                UTL_HTTP.WRITE_TEXT(v_req, v_chunk);
                v_offset := v_offset + v_amount;
            END LOOP;
        END;

        v_resp := UTL_HTTP.GET_RESPONSE(v_req);

        IF v_resp.status_code IN (200, 204) THEN
            IF v_max_ts IS NOT NULL THEN
                UPDATE loki_push_watermarks
                SET last_pushed = v_max_ts, push_count = push_count + v_count,
                    last_error = NULL, updated_at = SYSTIMESTAMP
                WHERE source_name = p_source_name;
                COMMIT;
            END IF;
            IF p_verbose THEN
                DBMS_OUTPUT.PUT_LINE(p_source_name || ': pushed ' || v_count ||
                    ' entries — Status: ' || v_resp.status_code);
            END IF;
        ELSE
            BEGIN UTL_HTTP.READ_TEXT(v_resp, v_resp_body);
            EXCEPTION WHEN OTHERS THEN v_resp_body := 'Unable to read response'; END;
            UPDATE loki_push_watermarks
            SET last_error = 'HTTP ' || v_resp.status_code || ': ' || SUBSTR(v_resp_body, 1, 2000),
                updated_at = SYSTIMESTAMP
            WHERE source_name = p_source_name;
            COMMIT;
            IF p_verbose THEN
                DBMS_OUTPUT.PUT_LINE(p_source_name || ': FAILED — HTTP ' ||
                    v_resp.status_code || ' ' || SUBSTR(v_resp_body, 1, 500));
            END IF;
        END IF;
        UTL_HTTP.END_RESPONSE(v_resp);

        DBMS_LOB.FREETEMPORARY(v_values);
        DBMS_LOB.FREETEMPORARY(v_payload);

    EXCEPTION
        WHEN OTHERS THEN
            v_errmsg := SQLERRM;
            IF DBMS_SQL.IS_OPEN(v_cur) THEN DBMS_SQL.CLOSE_CURSOR(v_cur); END IF;
            UPDATE loki_push_watermarks
            SET last_error = SUBSTR(v_errmsg, 1, 2000), updated_at = SYSTIMESTAMP
            WHERE source_name = p_source_name;
            COMMIT;
            IF p_verbose THEN
                DBMS_OUTPUT.PUT_LINE(p_source_name || ': ERROR — ' || v_errmsg);
            END IF;
    END;

    PROCEDURE configure(p_loki_url VARCHAR2) IS
    BEGIN
        MERGE INTO loki_config c
        USING (SELECT 'loki_url' AS config_key, p_loki_url AS config_value FROM dual) s
        ON (c.config_key = s.config_key)
        WHEN MATCHED THEN UPDATE SET c.config_value = s.config_value
        WHEN NOT MATCHED THEN INSERT (config_key, config_value) VALUES (s.config_key, s.config_value);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Loki URL configured: ' || p_loki_url);
    END;

    FUNCTION get_config(p_key VARCHAR2) RETURN VARCHAR2 IS
        v_val VARCHAR2(4000);
    BEGIN
        SELECT config_value INTO v_val FROM loki_config WHERE config_key = p_key;
        RETURN v_val;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20100, 'DBMS_LOKI not configured. Run: EXEC DBMS_LOKI.CONFIGURE(''http://<loki_host>:3100'')');
    END;

    FUNCTION list_sources RETURN t_source_info_tab PIPELINED IS
        v_rec t_source_info;
    BEGIN
        FOR rec IN (
            SELECT s.source_name, s.stream_labels, s.is_enabled, s.is_builtin,
                w.last_pushed, w.push_count, w.last_error
            FROM loki_log_sources s
            LEFT JOIN loki_push_watermarks w ON s.source_name = w.source_name
            ORDER BY s.is_builtin DESC, s.source_name
        ) LOOP
            v_rec.source_name := rec.source_name; v_rec.stream_labels := rec.stream_labels;
            v_rec.is_enabled := rec.is_enabled; v_rec.is_builtin := rec.is_builtin;
            v_rec.last_pushed := rec.last_pushed; v_rec.push_count := rec.push_count;
            v_rec.last_error := rec.last_error;
            PIPE ROW (v_rec);
        END LOOP;
    END;

    PROCEDURE enable_source(p_source_name VARCHAR2) IS
        v_cnt PLS_INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM loki_log_sources WHERE source_name = p_source_name;
        IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20110, 'Source "' || p_source_name || '" not found.'); END IF;
        UPDATE loki_log_sources SET is_enabled = 1 WHERE source_name = p_source_name;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Source "' || p_source_name || '" enabled.');
    END;

    PROCEDURE disable_source(p_source_name VARCHAR2) IS
        v_cnt PLS_INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM loki_log_sources WHERE source_name = p_source_name;
        IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20110, 'Source "' || p_source_name || '" not found.'); END IF;
        UPDATE loki_log_sources SET is_enabled = 0 WHERE source_name = p_source_name;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Source "' || p_source_name || '" disabled.');
    END;

    PROCEDURE add_custom_source(
        p_source_name VARCHAR2, p_source_sql CLOB,
        p_stream_labels VARCHAR2, p_timestamp_col VARCHAR2, p_message_cols VARCHAR2
    ) IS
        v_cnt PLS_INTEGER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM loki_log_sources WHERE source_name = p_source_name;
        IF v_cnt > 0 THEN RAISE_APPLICATION_ERROR(-20120, 'Source "' || p_source_name || '" already exists.'); END IF;
        IF INSTR(UPPER(p_source_sql), ':WATERMARK') = 0 THEN
            RAISE_APPLICATION_ERROR(-20121, 'Source SQL must contain a :watermark bind variable.');
        END IF;
        INSERT INTO loki_log_sources
            (source_name, source_sql, stream_labels, timestamp_col, message_cols, is_enabled, is_builtin, created_by)
        VALUES (p_source_name, p_source_sql, p_stream_labels, p_timestamp_col, p_message_cols, 1, 0, USER);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Custom source "' || p_source_name || '" registered.');
    END;

    PROCEDURE remove_custom_source(p_source_name VARCHAR2) IS
        v_builtin NUMBER(1);
    BEGIN
        BEGIN
            SELECT is_builtin INTO v_builtin FROM loki_log_sources WHERE source_name = p_source_name;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20130, 'Source "' || p_source_name || '" not found.');
        END;
        IF v_builtin = 1 THEN
            RAISE_APPLICATION_ERROR(-20131, 'Cannot remove built-in source. Use DISABLE_SOURCE instead.');
        END IF;
        DELETE FROM loki_log_sources WHERE source_name = p_source_name;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Custom source "' || p_source_name || '" removed.');
    END;

    PROCEDURE push_source(p_source_name VARCHAR2) IS
        v_rec loki_log_sources%ROWTYPE;
        v_url VARCHAR2(4000);
    BEGIN
        v_url := get_config('loki_url');
        BEGIN
            SELECT * INTO v_rec FROM loki_log_sources
            WHERE source_name = p_source_name AND is_enabled = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20140, 'Source "' || p_source_name || '" not found or disabled.');
        END;
        push_source_internal(v_rec.source_name, v_rec.source_sql, v_rec.stream_labels,
            v_rec.timestamp_col, v_rec.message_cols, v_url, TRUE);
    END;

    PROCEDURE push_logs IS
        v_url VARCHAR2(4000);
    BEGIN
        v_url := get_config('loki_url');
        FOR src IN (SELECT * FROM loki_log_sources WHERE is_enabled = 1 ORDER BY source_name) LOOP
            push_source_internal(src.source_name, src.source_sql, src.stream_labels,
                src.timestamp_col, src.message_cols, v_url, FALSE);
        END LOOP;
    END;

    PROCEDURE start_push(p_interval_secs NUMBER DEFAULT 60) IS
    BEGIN
        DECLARE v_url VARCHAR2(4000);
        BEGIN v_url := get_config('loki_url'); END;

        BEGIN DBMS_SCHEDULER.DROP_JOB(c_job_name, TRUE);
        EXCEPTION WHEN OTHERS THEN NULL; END;

        DBMS_SCHEDULER.CREATE_JOB(
            job_name => c_job_name, job_type => 'PLSQL_BLOCK',
            job_action => 'BEGIN DBMS_LOKI.PUSH_LOGS; END;',
            repeat_interval => 'FREQ=SECONDLY;INTERVAL=' || TO_CHAR(p_interval_secs),
            start_date => SYSTIMESTAMP, enabled => TRUE, auto_drop => FALSE,
            comments => 'DBMS_LOKI continuous log push to Grafana Loki');

        DBMS_OUTPUT.PUT_LINE('Log push job started — interval: ' || p_interval_secs || 's');
        DBMS_OUTPUT.PUT_LINE('Job name: ' || c_job_name);
    END;

    PROCEDURE stop_push IS
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(c_job_name, TRUE);
        DBMS_OUTPUT.PUT_LINE('Log push job stopped.');
    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('No active push job found.');
    END;

    FUNCTION is_running RETURN BOOLEAN IS
        v_state VARCHAR2(100);
    BEGIN
        SELECT state INTO v_state FROM user_scheduler_jobs WHERE job_name = c_job_name;
        RETURN v_state = 'SCHEDULED' OR v_state = 'RUNNING';
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
    END;

    PROCEDURE test_push(p_source_name VARCHAR2 DEFAULT NULL) IS
        v_url VARCHAR2(4000);
    BEGIN
        v_url := get_config('loki_url');
        DECLARE
            v_req  UTL_HTTP.REQ;
            v_resp UTL_HTTP.RESP;
            v_body VARCHAR2(4000);
        BEGIN
            v_req  := UTL_HTTP.BEGIN_REQUEST(v_url || '/ready', 'GET');
            v_resp := UTL_HTTP.GET_RESPONSE(v_req);
            UTL_HTTP.READ_TEXT(v_resp, v_body);
            UTL_HTTP.END_RESPONSE(v_resp);
            DBMS_OUTPUT.PUT_LINE('Loki connectivity: ' || v_resp.status_code || ' ' || v_body);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Loki connectivity FAILED: ' || SQLERRM);
                RETURN;
        END;

        IF p_source_name IS NOT NULL THEN
            push_source(p_source_name);
        ELSE
            FOR src IN (SELECT * FROM loki_log_sources WHERE is_enabled = 1 ORDER BY source_name) LOOP
                push_source_internal(src.source_name, src.source_sql, src.stream_labels,
                    src.timestamp_col, src.message_cols, v_url, TRUE);
            END LOOP;
        END IF;
    END;

END dbms_loki;
/

```

Expected output: `Package Body PROMETHEUS_EXPORTER.DBMS_LOKI compiled`

**Troubleshooting:** If you see `PLS-00307: too many declarations of 'COLUMN_VALUE'`, ensure the package spec (Task 7) includes the `TYPE t_idx_tab IS TABLE OF PLS_INTEGER` declaration. If you see `ORA-00904: "SQLERRM": invalid identifier`, this is a cross-schema compilation issue and the `v_errmsg := SQLERRM` pattern in the exception handler resolves it (already included in the code above).

## Task 9: Verify the Package

1. Confirm both spec and body compiled successfully:

    ```sql
    
    SELECT object_name, object_type, status
    FROM all_objects
    WHERE owner = 'PROMETHEUS_EXPORTER'
    AND object_name = 'DBMS_LOKI';
    
    ```

    Expected: Both `PACKAGE` and `PACKAGE BODY` show `VALID`.

## Task 10: Test Basic Connectivity

1. Connect as **PROMETHEUS_EXPORTER** (switch user in Database Actions or log in directly).

2. Test that the database can reach Loki:

    ```sql
    
    DECLARE
        v_req  UTL_HTTP.REQ;
        v_resp UTL_HTTP.RESP;
        v_body VARCHAR2(4000);
    BEGIN
        v_req  := UTL_HTTP.BEGIN_REQUEST('http://<compute_private_ip>:3100/ready', 'GET');
        v_resp := UTL_HTTP.GET_RESPONSE(v_req);
        UTL_HTTP.READ_TEXT(v_resp, v_body);
        UTL_HTTP.END_RESPONSE(v_resp);
        DBMS_OUTPUT.PUT_LINE('Status: ' || v_resp.status_code || ' Body: ' || v_body);
    END;
    /
    
    ```

    Expected output: `Status: 200 Body: ready`

    **Troubleshooting:** If you get `ORA-24247: network access denied`, the ACL from Task 2 was not applied correctly. Verify the host IP matches your compute instance.

You may now **proceed to the next lab**.

## Acknowledgements

- **Author** - German Viscuso, Product Manager, Oracle Autonomous AI Database
- **Last Updated By/Date** - Vandana Rajamani, Consulting UA Developer, June 2026
