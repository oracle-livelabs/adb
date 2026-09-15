whenever sqlerror exit sql.sqlcode rollback
set serveroutput on size unlimited
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Test the APEX Security Boundary
prompt Connect as RECALL_OWNER after importing application 105.
prompt ============================================================

declare
    procedure test_persona(
        p_user              in varchar2,
        p_expected_stores   in number,
        p_expected_units    in number,
        p_expected_customers in number,
        p_expected_complaints in varchar2
    ) is
        l_stores    number;
        l_units     number;
        l_customers number;
        l_map_rows  number;
        l_complaints varchar2(200);
        l_context   clob;
        l_stores_geojson clob;
        l_answer    clob;
    begin
        select json_serialize(context_json returning clob),
               json_serialize(stores_geojson returning clob),
               agent_answer
        into   l_context, l_stores_geojson, l_answer
        from (
            select context_json, stores_geojson, agent_answer
            from recall_authorized_requests
            where end_user_name = p_user
            and batch_id = 'B-482'
            order by created_at desc
        )
        where rownum = 1;

        select json_value(l_context, '$.affectedStoreCount' returning number),
               json_value(l_context, '$.unitsSent' returning number),
               json_value(l_context, '$.customerExposureCount' returning number),
               json_value(l_stores_geojson, '$.features.size()' returning number)
        into   l_stores, l_units, l_customers, l_map_rows
        from   dual;

        select listagg(to_char(complaint_id), ',')
                   within group (order by distance, complaint_id)
        into   l_complaints
        from   json_table(
                   l_context,
                   '$.semanticComplaints[*]'
                   columns (
                       complaint_id number path '$.complaintId',
                       distance     number path '$.distance'
                   )
               );

        if l_stores != p_expected_stores
           or l_units != p_expected_units
           or l_customers != p_expected_customers
           or l_map_rows != p_expected_stores
           or nvl(l_complaints, '-') != p_expected_complaints
           or l_answer is null then
            raise_application_error(-20064, 'APEX persona checkpoint failed for ' || p_user);
        end if;

        dbms_output.put_line(
            p_user || ': ' || l_stores || ' stores, ' || l_units ||
            ' units, ' || l_customers || ' customers, ' || l_map_rows ||
            ' map rows, complaints ' || l_complaints
        );
    end test_persona;
begin
    test_persona('STORE_101_USER', 1, 12, 5, '9001');
    test_persona('REGION_NE_USER', 24, 453, 120, '9001,9002,9006');
    test_persona(
        'RECALL_LEAD_USER', 120, 2400, 600, '9001,9002,9006,9003,9007'
    );
end;
/

prompt All latest APEX evidence captures passed.
