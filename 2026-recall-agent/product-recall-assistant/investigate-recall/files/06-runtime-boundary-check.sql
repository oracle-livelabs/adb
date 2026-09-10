whenever sqlerror exit sql.sqlcode rollback
set serveroutput on
set feedback on
set long 100000

prompt ============================================================
prompt Product Recall Assistant - Runtime Boundary Check
prompt Connect as RECALL_APP_USER before running this script.
prompt ============================================================

begin
    if user != 'RECALL_APP_USER' then
        raise_application_error(
            -20003,
            'Wrong user: connect as RECALL_APP_USER.'
        );
    end if;
end;
/

prompt --- Approved package access should succeed ---

select recall_owner.recall_lab_api.get_recall_context('B-482')
       as recall_context;

prompt --- Direct customer-table access must fail ---

declare
    l_count number;
begin
    begin
        execute immediate
            'select count(*) from recall_owner.customers'
            into l_count;

        raise_application_error(
            -20004,
            'Boundary failure: RECALL_APP_USER can read CUSTOMERS directly.'
        );
    exception
        when others then
            if sqlcode in (-942, -1031) then
                dbms_output.put_line(
                    'PASS: direct table access is blocked for RECALL_APP_USER.'
                );
            else
                raise;
            end if;
    end;
end;
/

prompt Runtime boundary check complete.
