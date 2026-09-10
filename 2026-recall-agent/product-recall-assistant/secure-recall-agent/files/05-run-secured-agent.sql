whenever sqlerror exit sql.sqlcode rollback
set serveroutput on size unlimited
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Summarize Captured Role Contexts
prompt Connect as RECALL_OWNER.
prompt ============================================================

declare
    l_answer clob;
begin
    for r in (
        select end_user_name, context_json
        from (
            select end_user_name,
                   json_serialize(context_json returning clob) as context_json,
                   row_number() over (
                       partition by end_user_name order by created_at desc
                   ) as rn
            from recall_authorized_requests
            where batch_id = 'B-482'
        )
        where rn = 1
        order by case end_user_name
                     when 'STORE_101_USER' then 1
                     when 'REGION_NE_USER' then 2
                     when 'RECALL_LEAD_USER' then 3
                     else 4
                 end
    ) loop
        l_answer := recall_agent_bridge.summarize_context(r.context_json);
        dbms_output.put_line('=== ' || r.end_user_name || ' ===');
        dbms_output.put_line(dbms_lob.substr(l_answer, 32767, 1));
    end loop;
end;
/
