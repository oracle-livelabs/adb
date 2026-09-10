whenever sqlerror exit sql.sqlcode rollback
set serveroutput on size unlimited
set feedback on
set long 100000
set longchunksize 100000

prompt ============================================================
prompt Product Recall Assistant - Run the Agent Team
prompt Connect as RECALL_OWNER.
prompt ============================================================

declare
    l_conversation_id  varchar2(128);
    l_params           clob;
    l_answer           clob;
    type question_list is table of varchar2(4000) index by pls_integer;
    type answer_list is table of clob index by pls_integer;
    l_questions question_list;
    l_answers   answer_list;
    l_failure_count number := 0;

    procedure ask_question(
        p_question_no in number,
        p_question    in varchar2
    ) is
    begin
        l_questions(p_question_no) := p_question;
        begin
            l_answer := dbms_cloud_ai_agent.run_team(
                team_name   => 'RECALL_ASSISTANT_TEAM',
                user_prompt => p_question,
                params      => l_params
            );
            l_answers(p_question_no) := l_answer;
        exception
            when others then
                l_failure_count := l_failure_count + 1;
                l_answers(p_question_no) := to_clob(
                    'TURN FAILED: ' || sqlerrm
                );
        end;
    end ask_question;
begin
    if user != 'RECALL_OWNER' then
        raise_application_error(
            -20023,
            'Wrong user: connect as RECALL_OWNER.'
        );
    end if;

    dbms_cloud_ai.set_profile('RECALL_AGENT_PROFILE');

    l_conversation_id := dbms_cloud_ai.create_conversation(
        attributes => q'~{
          "title":"AI World 2026 Product Recall Lab",
          "retention_days":1,
          "conversation_length":5
        }~'
    );

    select json_object(
               'conversation_id' value l_conversation_id
               returning clob
           )
    into   l_params;

    ask_question(
        1,
        'What is the current approved recall scope for batch B-482? ' ||
        'State the case, status, affected stores, shipped units, exposed ' ||
        'customers, component batches, supplier sites, and first action.'
    );

    ask_question(
        2,
        'Use RECALL_SPATIAL_TOOL for the same B-482 investigation. Summarize ' ||
        'affected stores and units by region, state whether all affected stores ' ||
        'are within the 25 kilometer response radius, and name the nearest ' ||
        'response-center assignments.'
    );

    ask_question(
        3,
        'Within that same B-482 investigation, prioritize the two highest-risk ' ||
        'SUSPECT lots and up to three WATCH lots. Name their supplier or ' ||
        'sub-vendor sites and summarize the relevant production, receipt, and ' ||
        'installation timing in no more than ten lines.'
    );

    ask_question(
        4,
        'Which complaint IDs provide the strongest evidence of an overheating ' ||
        'or electrical-odor pattern for B-482? Use only the approved context.'
    );

    ask_question(
        5,
        'This is an analysis-only question. Call both approved tools once. ' ||
        'According to their results, what is the first response action, is ' ||
        'customer contact authorized yet, and what spatial coverage should the ' ||
        'field team know? Summarize only facts established in this conversation ' ||
        'and the database tool output.'
    );

    dbms_output.put_line('Conversation: ' || l_conversation_id);
    dbms_output.put_line(
        'Active profile: ' || dbms_cloud_ai.get_profile
    );

    for i in 1 .. 5 loop
        dbms_output.put_line('');
        dbms_output.put_line('============================================================');
        dbms_output.put_line('Question ' || i || ':');
        dbms_output.put_line(l_questions(i));
        dbms_output.put_line('');
        dbms_output.put_line('Agent answer:');
        dbms_output.put_line(dbms_lob.substr(l_answers(i), 32767, 1));
    end loop;

    if l_failure_count > 0 then
        raise_application_error(
            -20024,
            l_failure_count || ' conversation turn(s) failed. Review the transcript.'
        );
    end if;
end;
/

prompt Expected multi-turn conversation checkpoints:
prompt   investigation case CASE-B482-2026
prompt   status INVESTIGATING
prompt   120 stores, 2,400 units, 600 potentially exposed customers
prompt   spatial summary includes regional counts, nearest response centers,
prompt   and 120 stores within the 25-kilometer response radius
prompt   25 component batches from 25 supplier/sub-vendor sites
prompt   complaints 9001, 9002, 9006, 9003, 9007
prompt   quarantine remaining inventory and stop sales first
prompt   customer contact is not authorized
