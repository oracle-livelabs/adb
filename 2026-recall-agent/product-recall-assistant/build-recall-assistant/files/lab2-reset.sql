whenever sqlerror exit sql.sqlcode rollback
set serveroutput on

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(
            -20024,
            'Wrong user: connect as RECALL_OWNER.'
        );
    end if;

    dbms_cloud_ai_agent.drop_team(
        'RECALL_ASSISTANT_TEAM',
        force => true
    );
    dbms_cloud_ai_agent.drop_task(
        'INVESTIGATE_RECALL_TASK',
        force => true
    );
    dbms_cloud_ai_agent.drop_tool(
        'RECALL_CONTEXT_TOOL',
        force => true
    );
    dbms_cloud_ai_agent.drop_agent(
        'RECALL_INVESTIGATOR',
        force => true
    );
end;
/

prompt Lab 5 agent objects removed. RECALL_AGENT_PROFILE remains.
