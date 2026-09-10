# Lab 5: Answer with Evidence: Build the Recall Assistant

## Introduction

Marcus Lee, a Recall Desk Coordinator, is fielding questions faster than a person can open separate reports, maps, and supplier records. He needs an answer he can trust, not a fluent guess that invents a count, names a hidden customer, or recommends an action that the evidence does not support.

Your mission is to give Marcus a grounded conversation for batch `B-482`. You will register two package functions as Select AI Agent tools: one for recall facts and one for spatial impact. The language model decides which approved tool to use and writes the response, while the database supplies the facts. That separation is the differentiator: the agent can reason over the request without receiving unrestricted SQL access or permission to invent recall details.

By the end of the lab, one conversation will answer five investigation questions using the approved context and spatial tools. The guardrail check will show that the agent can report recall evidence without retrieving customer names or contact details. Lab 8 will extend this same pattern with one role-filtered document containing JSON, vector, spatial, and graph evidence.

This lab establishes the agent privilege boundary used by the rest of the workshop. `RECALL_OWNER` owns the AI profile, tools, and agent metadata and holds the direct `EXECUTE` privilege needed to run `DBMS_CLOUD_AI_AGENT`. A runtime business user does not receive unrestricted SQL, the owner credential, or direct access to that metadata. Later labs place Deep Data Security in front of this same agent path. The three Lab 7 local users receive only the approved application and security package grants needed to request a governed answer.

Estimated Time: 18 minutes

### Objectives

In this lab, you will:

- Inspect the PL/SQL function exposed to Select AI Agent.
- Register two custom tools, one agent, one task, and one team.
- Create one conversation and run a five-question recall investigation.
- Compare the response with the approved recall and spatial outputs.
- Verify that the agent cannot retrieve customer names or contact details through its tool.

## Task 1: Inspect the Approved Tool Boundary

1. Review the Select AI Agent framework.

    ![Oracle Select AI Agent framework showing tools, tasks, agents, and agent teams](images/oracle-select-ai-agent-framework.png)

    This framework separates the approved database functions into governed tools that an agent can call as part of a task and team.

2. Confirm your identity and inspect the package function signature.

    ```sql
    <copy>
    select user as connected_user;

    select object_name,
           argument_name,
           position,
           in_out,
           data_type
    from   user_arguments
    where  package_name = 'RECALL_LAB_API'
    order  by object_name, sequence;
    </copy>
    ```

    Continue only when the connected user is `RECALL_OWNER`. The function accepts one `VARCHAR2` batch ID. It returns a `CLOB`.

3. Call both approved tool functions directly.

    ```sql
    <copy>
    select recall_lab_api.get_recall_context('B-482') as recall_context;

    select recall_lab_api.get_spatial_impact('B-482') as spatial_impact;
    </copy>
    ```

    The first JSON contains counts, component lots, supplier sites, complaint IDs, and approved actions. The second summarizes affected stores by region, response-radius coverage, and nearest response centers. Neither function returns customer names or email addresses, and neither provides unrestricted table access.

4. Confirm that the facilitator-prepared profile has status `ENABLED`.

    ```sql
    <copy>
    select profile_name, status
    from   user_cloud_ai_profiles
    where  profile_name = 'RECALL_AGENT_PROFILE';
    </copy>
    ```

    Stop and ask the facilitator for help if no enabled row appears.

    The profile omits `oci_compartment_id`, so Autonomous Database uses its own compartment. Its `region` points to a region that offers the selected model.

## Task 2: Register or Reuse the Tools and Investigator

1. Ensure the recall context function is registered as a custom Select AI Agent tool. The block creates it only when it is missing, so it is safe to rerun after a previous Lab 5 attempt.

    ```sql
    <copy>
    declare
        l_exists number;
    begin
        select count(*)
        into   l_exists
        from   user_ai_agent_tools
        where  tool_name = 'RECALL_CONTEXT_TOOL';

        if l_exists = 0 then
            dbms_cloud_ai_agent.create_tool(
                tool_name  => 'RECALL_CONTEXT_TOOL',
                attributes => q'~{
                  "instruction":"Retrieve trusted recall evidence for one batch identifier. Pass only the batch identifier, such as B-482. Treat the returned JSON as authoritative for exposure, component lots, supplier sites, complaints, actions, and customer-contact authorization.",
                  "function":"RECALL_LAB_API.GET_RECALL_CONTEXT",
                  "tool_inputs":[
                    {
                      "name":"P_BATCH_ID",
                      "description":"Product batch identifier, for example B-482"
                    }
                  ]
                }~'
            );
            dbms_output.put_line('Created RECALL_CONTEXT_TOOL.');
        else
            dbms_output.put_line('RECALL_CONTEXT_TOOL already exists; using the registered tool.');
        end if;
    end;
    /
    </copy>
    ```

2. Ensure the spatial impact function is registered as a second governed tool. The block creates it only when it is missing.

    ```sql
    <copy>
    declare
        l_exists number;
    begin
        select count(*)
        into   l_exists
        from   user_ai_agent_tools
        where  tool_name = 'RECALL_SPATIAL_TOOL';

        if l_exists = 0 then
            dbms_cloud_ai_agent.create_tool(
                tool_name  => 'RECALL_SPATIAL_TOOL',
                attributes => q'~{
                  "instruction":"Retrieve the governed spatial impact summary for one batch identifier. Pass only the batch identifier, such as B-482. Use the returned JSON as authoritative for affected stores by region, units by region, response-radius coverage, and nearest response-center assignments.",
                  "function":"RECALL_LAB_API.GET_SPATIAL_IMPACT",
                  "tool_inputs":[
                    {
                      "name":"P_BATCH_ID",
                      "description":"Product batch identifier, for example B-482"
                    }
                  ]
                }~'
            );
            dbms_output.put_line('Created RECALL_SPATIAL_TOOL.');
        else
            dbms_output.put_line('RECALL_SPATIAL_TOOL already exists; using the registered tool.');
        end if;
    end;
    /
    </copy>
    ```

3. Ensure the investigator agent is registered. The block creates it only when it is missing. Its role requires approved tool use and prohibits invented PII.

    ```sql
    <copy>
    declare
        l_exists number;
    begin
        select count(*)
        into   l_exists
        from   user_ai_agents
        where  agent_name = 'RECALL_INVESTIGATOR';

        if l_exists = 0 then
            dbms_cloud_ai_agent.create_agent(
                agent_name => 'RECALL_INVESTIGATOR',
                attributes => q'~{
                  "profile_name":"RECALL_AGENT_PROFILE",
                  "role":"You are a product recall investigator. Use RECALL_CONTEXT_TOOL for recall facts and RECALL_SPATIAL_TOOL for geographic questions. If a question needs both, call each approved tool once. After the required tools return, write the final answer immediately. Never call an unapproved tool. Report only facts in the tool results. Never invent customer names, contact details, component lots, suppliers, or actions.",
                  "enable_human_tool":false
                }~'
            );
            dbms_output.put_line('Created RECALL_INVESTIGATOR.');
        else
            dbms_output.put_line('RECALL_INVESTIGATOR already exists; using the registered agent.');
        end if;
    end;
    /
    </copy>
    ```

4. Run [`02-register-recall-agent.sql`](files/02-register-recall-agent.sql) when you want to refresh the complete registration. It safely drops only existing named Lab 5 objects, then recreates both tools, the agent, the task, and the sequential team in dependency order.

    The first three blocks leave existing backend-registered definitions unchanged. The canonical script is the controlled refresh path when those definitions need to be rebuilt.

    The verification queries should return five enabled objects:

    | Object | Name |
    |---|---|
    | Tool | `RECALL_CONTEXT_TOOL` |
    | Tool | `RECALL_SPATIAL_TOOL` |
    | Agent | `RECALL_INVESTIGATOR` |
    | Task | `INVESTIGATE_RECALL_TASK` |
    | Team | `RECALL_ASSISTANT_TEAM` |

## Task 3: Run a Grounded Recall Conversation

1. Activate the owner-local profile in the current session.

    ```sql
    <copy>
    begin
        dbms_cloud_ai.set_profile('RECALL_AGENT_PROFILE');
    end;
    /

    select dbms_cloud_ai.get_profile as active_profile;
    </copy>
    ```

    Confirm that the result names `RECALL_OWNER.RECALL_AGENT_PROFILE`.

    This owner-local `SET_PROFILE` call is correct for this task because the connected session is the profile owner. It is not copied into the later React runtime path. Lab 8 keeps the local end-user session intact and uses the profile binding stored on the registered agent when the owner-side bridge calls `RUN_TEAM`.

2. Review [`03-run-recall-agent.sql`](files/03-run-recall-agent.sql) before running it. Follow these three values in the script:

    - `l_conversation_id` stores the conversation created by `DBMS_CLOUD_AI.CREATE_CONVERSATION`.
    - `l_params` stores that ID as `{"conversation_id":"..."}`.
    - Every `DBMS_CLOUD_AI_AGENT.RUN_TEAM` call receives the same `l_params`, so all five questions use one conversation.

    The script also prints the conversation ID and the complete question-and-answer transcript.

3. Run [`03-run-recall-agent.sql`](files/03-run-recall-agent.sql) once as `RECALL_OWNER`. You do not need to copy or run the five questions individually. The script activates the profile, creates one conversation, and submits these five questions through that same conversation:

    ```sql
    <copy>
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
    </copy>
    ```

    | Turn | Investigation question | Converged evidence |
    |---:|---|---|
    | 1 | What is the approved scope for `B-482`? | Relational counts and case state |
    | 2 | What is the spatial impact for the field team? | Spatial regions, radius, and response centers |
    | 3 | Which suspect or watch component lots and supplier sites matter? | JSON component trace and timestamps |
    | 4 | Which complaint IDs support the thermal-risk pattern? | Vector-ranked complaint evidence |
    | 5 | What action, authorization, and spatial coverage belong in the handoff? | Both governed tools |

    Each turn calls the same Select AI Agent team and uses the same conversation. The team selects `RECALL_CONTEXT_TOOL`, `RECALL_SPATIAL_TOOL`, or both based on the question. Read the printed transcript after the script finishes, and confirm that each answer remains grounded in approved database evidence.

4. Compare the answer with the checkpoint.

    | Grounded fact | Expected value |
    |---|---|
    | Investigation case | `CASE-B482-2026` |
    | Status | `INVESTIGATING` |
    | Affected stores | 120 |
    | Units sent | 2,400 |
    | Potentially exposed customers | 600 |
    | Stores within 25-kilometer response radius | 120 |
    | Component batches | 25 |
    | Supplier sites | 25 |
    | Related complaints | `9001`, `9002`, `9006`, `9003`, `9007` |
    | First action | Quarantine remaining inventory and stop sales |
    | Customer contact authorized | `false` |

    The wording can vary because the model generates prose. The facts must match the database tool output.

## Task 4: Verify the Guardrail

1. Review what the agent can call.

    ```sql
    <copy>
    select tool_name, status, description
    from   user_ai_agent_tools
    where  tool_name in (
               'RECALL_CONTEXT_TOOL',
               'RECALL_SPATIAL_TOOL'
           )
    order  by tool_name;

    select task_name, attribute_name, attribute_value
    from   user_ai_agent_task_attributes
    where  task_name = 'INVESTIGATE_RECALL_TASK'
    order  by attribute_name;
    </copy>
    ```

2. Explain the current boundary:

    - The agent can call two definer-rights package functions.
    - The context function returns approved counts, component lots, supplier sites, complaint IDs, and the first action.
    - The spatial function returns regional store counts, response-radius coverage, and nearest response centers.
    - Neither function returns customer PII.
    - The agent has no SQL tool and cannot decide to query arbitrary tables.
    - Lab 7 will add requester-specific Deep Data Security authorization inside this path.

    The important distinction is between **who can execute the agent framework** and **what evidence the agent receives**. The owner-owned bridge has the agent framework privilege. The approved package functions define the only evidence boundary. Lab 7 makes JSON and vector retrieval run under the requesting end-user context, and Lab 8 adds role-filtered spatial impact and graph relationship evidence before the combined document crosses the definer-rights bridge.

You have completed Lab 5. Lab 6 will publish this workflow through ORDS. Lab 7 will apply DDS to the retrieval path, and Lab 8 will combine JSON, vector, Spatial, and Graph evidence for the secured application agent.

## Troubleshooting

| Symptom | Likely cause | Recovery |
|---|---|---|
| `RECALL_AGENT_PROFILE` does not exist | The prepared workshop environment is incomplete | Ask the facilitator to verify the backend deployment. |
| OCI endpoint or authorization error | The prepared profile or IAM configuration is incomplete | Ask the facilitator to verify the backend deployment and approved OCI configuration. |
| Conversation ID is null or invalid | No conversation exists | Run `03-run-recall-agent.sql`; it creates and passes the ID. |
| A tool or agent is missing after the checks | A partial registration remains | Run `02-register-recall-agent.sql`; it safely refreshes the named Lab 5 objects. |
| `GET_SPATIAL_IMPACT` is missing | The package predates the spatial agent tool | Run the updated `01-extend-recall-api.sql`, then rerun `02-register-recall-agent.sql`. |
| Answer omits a checkpoint | The agent skipped the tool | Tighten the task instruction and confirm the tool status. |
| Answer includes customer names | The approved package changed | Stop the lab and inspect `RECALL_LAB_API`; the Lab 5 tool must not return PII. |

For fast recovery, run [`lab2-reset.sql`](files/lab2-reset.sql). Then run [`lab2-solution.sql`](files/lab2-solution.sql).

## Learn More

- [Examples of using Select AI Agent](https://docs.oracle.com/en/database/oracle/oracle-database/26/selai/examples-using-select-ai-agent1.html)
- [DBMS_CLOUD_AI_AGENT package](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-ai-agent-package.html)
- [Enable a resource principal for a database user](https://docs.oracle.com/en-us/iaas/autonomous-database-shared/doc/resource-principal.html)

## Acknowledgements

- **Author:** Oracle AI World 2026 Product Recall Assistant workshop team
- **Last updated:** July 2026
