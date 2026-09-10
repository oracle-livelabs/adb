whenever sqlerror exit sql.sqlcode rollback
set serveroutput on size unlimited
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Generate Trusted APEX Answers
prompt Connect as RECALL_OWNER after all three persona captures.
prompt ============================================================

declare
    l_answer clob;
begin
    for r in (
        select request_id, end_user_name,
               json_serialize(context_json returning clob) as context_json
        from (
            select request_id, end_user_name, context_json,
                   row_number() over (
                       partition by end_user_name, batch_id
                       order by created_at desc
                   ) as rn
            from recall_authorized_requests
            where batch_id = 'B-482'
            and end_user_name in (
                'STORE_101_USER', 'REGION_NE_USER', 'RECALL_LEAD_USER'
            )
        )
        where rn = 1
        order by end_user_name
    ) loop
        l_answer := recall_agent_bridge.summarize_context(r.context_json);
        update recall_authorized_requests
        set agent_answer = l_answer
        where request_id = r.request_id;
        dbms_output.put_line('Generated answer for ' || r.end_user_name);
    end loop;
    commit;
end;
/

prompt Trusted answers are ready for APEX.
