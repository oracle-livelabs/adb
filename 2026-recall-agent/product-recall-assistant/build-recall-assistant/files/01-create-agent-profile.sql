whenever sqlerror exit sql.sqlcode rollback
set serveroutput on
set feedback on

prompt ============================================================
prompt Product Recall Assistant - Create Owner AI Profile
prompt Connect as RECALL_OWNER. Facilitator setup only.
prompt ============================================================

accept recall_region char default 'us-chicago-1' prompt 'OCI region [us-chicago-1]: '
accept recall_model char default 'meta.llama-3.3-70b-instruct' prompt 'OCI model [meta.llama-3.3-70b-instruct]: '

begin
    if user != 'RECALL_OWNER' then
        raise_application_error(
            -20021,
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
    dbms_cloud_ai.drop_profile(
        'RECALL_AGENT_PROFILE',
        force => true
    );
end;
/

declare
    l_attributes clob;
begin
    select json_object(
               'provider' value 'oci',
               'credential_name' value 'OCI$RESOURCE_PRINCIPAL',
               'model' value '&recall_model',
               'region' value '&recall_region',
               'oci_apiformat' value 'GENERIC',
               'temperature' value 0,
               'max_tokens' value 1024
               returning clob
           )
    into   l_attributes;

    dbms_cloud_ai.create_profile(
        profile_name => 'RECALL_AGENT_PROFILE',
        attributes   => l_attributes,
        status      => 'ENABLED',
        description =>
            'LLM profile for the Product Recall Assistant workshop.'
    );

    dbms_cloud_ai.set_profile('RECALL_AGENT_PROFILE');
end;
/

select profile_name, status
from   user_cloud_ai_profiles
where  profile_name = 'RECALL_AGENT_PROFILE';

prompt RECALL_AGENT_PROFILE is ready.
prompt RECALL_AGENT_PROFILE is active in this session.
