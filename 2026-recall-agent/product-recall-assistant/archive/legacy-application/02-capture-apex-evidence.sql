whenever sqlerror exit sql.sqlcode rollback
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Capture APEX Evidence
prompt Connect as one Lab 7 local end user.
prompt Run once as each of the three personas.
prompt ============================================================

declare
    l_end_user varchar2(128);
begin
    select json_value(
               ora_end_user_context,
               '$.USERNAME' returning varchar2(128)
           )
    into l_end_user
    from dual;

    if l_end_user not in (
        'STORE_101_USER', 'REGION_NE_USER', 'RECALL_LEAD_USER'
    ) then
        raise_application_error(
            -20065,
            'Use an actual Lab 7 local end-user connection before capturing APEX evidence.'
        );
    end if;
end;
/

declare
    l_request_id number;
begin
    l_request_id := recall_secure_api.capture_secured_context('B-482');
    dbms_output.put_line('Captured request ID: ' || l_request_id);
end;
/

select json_value(ora_end_user_context, '$.USERNAME') as end_user,
       json_value(recall_secure_api.get_secured_context('B-482'),
                  '$.affectedStoreCount' returning number) as stores,
       json_value(recall_secure_api.get_secured_context('B-482'),
                  '$.unitsSent' returning number) as units,
       json_value(recall_secure_api.get_secured_context('B-482'),
                  '$.customerExposureCount' returning number) as customers,
       json_value(recall_secure_api.get_secured_context('B-482'),
                  '$.semanticComplaints.size()' returning number) as complaints,
       json_value(recall_secure_api.get_secured_stores('B-482'),
                  '$.features.size()' returning number) as map_stores
from dual;

prompt The APEX dashboard can now display this persona.
