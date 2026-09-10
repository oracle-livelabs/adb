whenever sqlerror exit sql.sqlcode rollback
set feedback on
set serveroutput on
set long 100000
set longchunksize 100000

prompt ============================================================
prompt Product Recall Assistant - Capture Authorized Context
prompt Connect as one Lab 7 local end user.
prompt ============================================================

declare
    l_request_id number;
begin
    l_request_id := recall_secure_api.capture_secured_context('B-482');
    dbms_output.put_line('Captured request ID: ' || l_request_id);
end;
/

prompt The owner-side agent can now consume this materialized context.
