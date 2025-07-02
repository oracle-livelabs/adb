# Setup Apex Chatbot App workflows

## Introduction



Estimated Time: 60 minutes
 

### Objectives

 

In this lab, you will update the workflow activities of the prebuilt Apex Chatbot app

*  

### Prerequisites (Optional)


This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed


 
## Task 1: Open the prebuilt Apex workflow

1. From within the Apex workspace, navigate to App Builder.

     ![Navigate to App Builder](images/navigate_to_app_builder.png)

2. Click the ATOM 23AI Chat_clone app button.

     ![Apex Application Page](images/apex_application_page.png)

3. Click the Shared Components button.

     ![Shared Components](images/apex_shared_components.png)

4. Click the Workflows link under Workflows and Automations.

     ![Apex Workflows](images/apex_workflows.png)

5. Open the ToolCallingWorkflow via the workflow link.

     ![Open ToolCallingWorkflow](images/apex_workflow_page.png)

## Task 2: Add Select AI tools to the Apex Workflow Activities

1. Expand the Workflows tree on the left, select RAG tool and edit the PL/SQL source.

     ![select RAG Tool](images/apex_tool_calling_workflow_rag_tool.png)

2. Copy the SQL below into the source, validate and save.

    Paste the PL/SQL:

    ```text
        <copy>
                declare
            c_response clob;
            c_sql clob;
            l_has_summary number;
            l_prompt varchar2(4000);
            v_profile_name varchar2(100);
            v_summary_profile_name varchar2(100);
            v_tools_left number;
            
            begin    
            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 1:Get the AI profile for this prompt '
                ,SYSTIMESTAMP
                ,':APP_USER_IN:' || :APP_USER_IN || ' |V_PROMPT:' || :V_PROMPT 
            FROM DUAL;

            v_profile_name := 'GENAI_VECTOR_APEX'; 
            
            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 1:Generate response using prompt and profiles'
                ,SYSTIMESTAMP
                ,'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT 
            FROM DUAL;

            c_response := dbms_cloud_ai.generate(
                            prompt => :V_PROMPT,
                            action => 'narrate',
                            profile_name => 'GENAI_VECTOR_APEX'
                            );

            c_sql := '';

            -- Generate a summary?
            select count(*)
            into l_has_summary
            from ADB_CHAT_CONVERSATIONS
            where id = :CONV_ID 
            and summary is not null;

            if l_has_summary = 0 then
                -- Yes! Generate the summary b/c one does not exist.
                -- get a profile to generate the response. 
                v_summary_profile_name:= 'GENAI';

                if v_summary_profile_name is null then
                    l_prompt := 'Untitiled conversation';            
                else
                    l_prompt := dbms_cloud_ai.generate(
                                prompt => 'Rewrite as a short title : '||:WORKFLOW_PROMPT,
                                action => 'chat',
                                profile_name => v_summary_profile_name
                            );

                end if;
                
                update ADB_CHAT_CONVERSATIONS set summary = l_prompt
                where id = :CONV_ID and summary is null;
            
            end if;

            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 1: check for other tool calls'
                ,SYSTIMESTAMP
                ,':CONV_ID' || :CONV_ID || 'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT  || ' c_sql:' || c_sql 
            FROM DUAL;
            
            :RAG_TOOL := 'false';

            UPDATE ADB_CHAT_CONVERSATIONS_TOOLS
            SET TOOL_APPLIED = 1
            WHERE CONVERSATION_ID = :CONV_ID
            AND    TOOL_ID = 1;

            v_tools_left := 0;

            SELECT COUNT(*) INTO v_tools_left
            FROM ADB_CHAT_CONVERSATIONS_TOOLS
            WHERE CONVERSATION_ID = :CONV_ID
            AND  TOOL_APPLIED = 0;

            IF v_tools_left > 0 THEN
            
                c_response := dbms_cloud_ai.generate(
                                prompt => 'Rewrite to 2000 characters or less and remove anything about weather not available and keep any source references: '|| c_response,
                                action => 'chat',
                                profile_name => 'GENAI'
                            );

                :V_PROMPT :=  :V_PROMPT || ' also use the following which attempts to partially answer the prompt: ' || substr(c_response,1,3000);
                    INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
                    SELECT 'Tool 1: UPDATE V_PROMPT'
                        ,SYSTIMESTAMP
                        ,':CONV_ID' || :CONV_ID || ' |V_PROMPT:' || :V_PROMPT || ' |c_response '  
                    FROM DUAL; 
            ELSE
                INSERT INTO ADB_CHAT_PROMPTS (conv_id, profile_name, prompt, response, asked_on, showsql) 
                VALUES (:CONV_ID, v_profile_name, :WORKFLOW_PROMPT, c_response, systimestamp, c_sql);
                INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
                    SELECT 'Tool 1: INSERT INTO ADB_CHAT_PROMPTS'
                        ,SYSTIMESTAMP
                        ,':CONV_ID ' || :CONV_ID || ' |WORKFLOW_PROMPT:' || :WORKFLOW_PROMPT || ' |c_response ' 
                    FROM DUAL;
            END IF;
        end;

        </copy>
    ```

     ![validate RAG Tool pl/sql](images/apex_tool_calling_workflow_rag_tool_validate.png)

8. Select the NLSQL tool, edit the PL/SQL source, copy the SQL below into the source, validate and save the PL/SQL.

    Paste the PL/SQL:

    ```text
        <copy>
        declare  
            c_response clob;
            c_sql clob;
            l_has_summary number;
            l_prompt varchar2(4000);
            v_profile_name varchar2(100);
            v_summary_profile_name varchar2(100);
            v_tools_left number;
            
        begin

            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 2:Get the AI profile for this prompt'
                ,SYSTIMESTAMP
                ,':APP_USER_IN:' || :APP_USER_IN || ' |WORKFLOW_PROMPT:' || :WORKFLOW_PROMPT  
            FROM DUAL;
        
            v_profile_name := 'GENAI_SQL_APEX';
            
            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 2:Generate response using prompt and profiles'
                ,SYSTIMESTAMP
                ,'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT  
            FROM DUAL;

            commit;
        
            c_sql := dbms_cloud_ai.generate(
                            prompt => :V_PROMPT,
                            action => 'showsql',
                            profile_name => 'GENAI_SQL_APEX',
                            attributes =>
                                '{
                                    "comments": true
                                }'
                            );

            -- Generate with narrate only if c_sql has value 
            if (c_sql is not null) then
                c_response := dbms_cloud_ai.generate(
                                prompt => :V_PROMPT,
                                action => 'narrate',
                                profile_name => 'GENAI_SQL_APEX',
                                attributes =>
                                '{
                                    "comments": true
                                }'
                                );
                c_response := dbms_cloud_ai.generate(
                                prompt => 'Rewrite to 1000 tokens or less and remove anything about weather not available and keep any source references:  '|| c_response,
                                action => 'chat',
                                profile_name => 'GENAI'
                            );
            end if;

            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS, RESPONSE, showsql) 
            SELECT 'Tool 2: AFTER Generate response using prompt and profiles'
                    ,SYSTIMESTAMP
                    ,'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT ||   'length(c_response):' || length(c_response)
                    ,c_response
                    ,c_sql 
            FROM DUAL;

            commit;
            -- Generate a summary?
            select count(*)
            into l_has_summary
            from ADB_CHAT_CONVERSATIONS
            where id = :CONV_ID 
            and summary is not null;
            

            if l_has_summary = 0 then
                -- Yes! Generate the summary b/c one does not exist.
                -- get a profile to generate the response. 
                v_summary_profile_name:= 'GENAI_SQL_APEX';

                if v_summary_profile_name is null then
                    l_prompt := 'Untitiled conversation';            
                else
                    l_prompt := dbms_cloud_ai.generate(
                                prompt => 'Rewrite as a short title : '||:WORKFLOW_PROMPT,
                                action => 'chat',
                                profile_name => 'GENAI'
                            );

                end if;
                
                update ADB_CHAT_CONVERSATIONS set summary = l_prompt
                where id = :CONV_ID and summary is null;
            
            end if;
        
            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 2: check for other tool calls'
                ,SYSTIMESTAMP
                ,':CONV_ID' || :CONV_ID || 'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT || ' c_sql:' || c_sql 
            FROM DUAL;
            
            COMMIT;
        
            :DATABASE_TOOL := 'false';


            UPDATE ADB_CHAT_CONVERSATIONS_TOOLS
            SET TOOL_APPLIED = 1
            WHERE CONVERSATION_ID = :CONV_ID
            AND    TOOL_ID = 2;

            v_tools_left := 0;
            
            SELECT COUNT(*) INTO v_tools_left
            FROM ADB_CHAT_CONVERSATIONS_TOOLS
            WHERE CONVERSATION_ID = :CONV_ID
            AND  TOOL_APPLIED = 0;

            IF v_tools_left > 0 THEN
                :V_PROMPT :=  :V_PROMPT || ' also use the following which may partially answer the prompt: ' || c_response;
                    INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS, RESPONSE, showsql) 
                    SELECT 'Tool 2: UPDATE V_PROMPT'
                        ,SYSTIMESTAMP
                        ,':CONV_ID ' || :CONV_ID || ' |V_PROMPT:' || :V_PROMPT 
                        ,c_response
                        , c_sql
                    FROM DUAL;
                    COMMIT;
            ELSE
                    INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
                    SELECT 'Tool 2: INSERT INTO ADB_CHAT_PROMPTS'
                        ,SYSTIMESTAMP
                        ,':CONV_ID ' || :CONV_ID || ' |WORKFLOW_PROMPT:' || :WORKFLOW_PROMPT || ' |c_response ' 
                    FROM DUAL;
            
                    INSERT INTO ADB_CHAT_PROMPTS (conv_id, profile_name, prompt, response, asked_on, showsql) 
                    VALUES (:CONV_ID, v_profile_name, :WORKFLOW_PROMPT, c_response, systimestamp, c_sql);
                    COMMIT;
            END IF;
        end;

        </copy>
    ```

    ![select NL2SQL Tool](images/apex_tool_calling_workflow_nl2sql_tool.png)
    ![validate NL2SQL Tool pl/sql](images/apex_tool_calling_workflow_nl2sql_tool_validate.png)

9. Select the LLM Chat tool, edit the PL/SQL source, copy the SQL below into the source, validate and save the PL/SQL.

    Paste the PL/SQL:

    ```text
        <copy>

        declare 
            c_response clob;
            c_sql clob;
            l_has_summary number;
            l_prompt varchar2(4000);
            v_profile_name varchar2(100);
            v_summary_profile_name varchar2(100);
            v_tools_left number;
        begin
        
            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 3:Get the AI profile for this prompt'
                ,SYSTIMESTAMP
                ,':APP_USER_IN:' || :APP_USER_IN || ' |V_PROMPT:' || :V_PROMPT  
            FROM DUAL;

        
            v_profile_name := 'GENAI'; 
            
            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 3:Generate response using prompt and profiles'
                ,SYSTIMESTAMP
                ,'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT  
            FROM DUAL;

            COMMIT;

            c_response := dbms_cloud_ai.generate(
                                prompt =>  :V_PROMPT,
                                action => 'chat',
                                profile_name => 'GENAI'
                            );

            -- Generate a summary?
            select count(*)
            into l_has_summary
            from ADB_CHAT_CONVERSATIONS
            where id = :CONV_ID 
            and summary is not null;
            

            if l_has_summary = 0 then
                -- Yes! Generate the summary b/c one does not exist.
                -- get a profile to generate the response. 
                v_summary_profile_name:= 'GENAI';

                if v_summary_profile_name is null then
                    l_prompt := 'Untitiled conversation';            
                else
                    l_prompt := dbms_cloud_ai.generate(
                                prompt => 'Rewrite as a short title : '||:V_PROMPT,
                                action => 'chat',
                                profile_name => 'GENAI'
                            );

                end if;
                
                update ADB_CHAT_CONVERSATIONS set summary = l_prompt
                where id = :CONV_ID and summary is null;
            
            end if;

            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 3: check for other tool calls'
                ,SYSTIMESTAMP
                ,':CONV_ID' || :CONV_ID || 'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT ||  ' c_sql:' || c_sql 
            FROM DUAL;
            
        
            
        
            :LLM_TOOL := 'false';

            UPDATE ADB_CHAT_CONVERSATIONS_TOOLS
            SET TOOL_APPLIED = 1
            WHERE CONVERSATION_ID = :CONV_ID
            AND    TOOL_ID = 3;

            v_tools_left := 0;
            
            SELECT COUNT(*) INTO v_tools_left
            FROM ADB_CHAT_CONVERSATIONS_TOOLS
            WHERE CONVERSATION_ID = :CONV_ID
            AND  TOOL_APPLIED = 0;

        COMMIT;

            c_response := dbms_cloud_ai.generate(
                                prompt => 'Rewrite to 2000 characters or less and remove anything about weather not available and keep any source references:  '|| c_response,
                                action => 'chat',
                                profile_name => 'GENAI'
                            );
        COMMIT;                  
            IF v_tools_left > 0 THEN
                :V_PROMPT :=  :V_PROMPT || ' also using this information ' || c_response;
                    INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
                    SELECT 'Tool 3: UPDATE V_PROMPT'
                        ,SYSTIMESTAMP
                        ,':CONV_ID ' || :CONV_ID || ' |V_PROMPT:' || :V_PROMPT || ' |c_response ' || c_response
                    FROM DUAL;
            ELSE
                INSERT INTO ADB_CHAT_PROMPTS (conv_id, profile_name, prompt, response, asked_on, showsql) 
                VALUES (:CONV_ID, v_profile_name, :WORKFLOW_PROMPT, c_response, systimestamp, c_sql);

                INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
                    SELECT 'Tool 3: INSERT INTO ADB_CHAT_PROMPTS'
                        ,SYSTIMESTAMP
                        ,':CONV_ID ' || :CONV_ID || ' |WORKFLOW_PROMPT:' || :WORKFLOW_PROMPT || ' |c_response ' 
                    FROM DUAL;
            END IF;
        end;

        </copy>
    ```

    ![select llm chat Tool](images/apex_tool_calling_workflow_llm_chat_tool.png)
    ![validate llm chat Tool pl/sql](images/apex_tool_calling_workflow_llm_chat_tool_validate.png)


10. Select the Weather API tool, edit the PL/SQL source, copy the SQL below into the source, validate and save the PL/SQL.

    Paste the PL/SQL:

    ```text
        <copy>
        declare
            c_response clob;
            c_sql clob;
            l_has_summary number;
            l_prompt varchar2(4000);
            v_profile_name varchar2(100);
            v_summary_profile_name varchar2(100);
            v_tools_left number;
            v_prompt_latitude varchar2(100);
            v_prompt_longitude varchar2(100);
        begin
        

        /**
        ** Find Longitude of place in prompt and store
        ** Find Latitude of place in prompmt and store
        **/ 

            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 4:Get the AI profile for this prompt '
                ,SYSTIMESTAMP
                ,':APP_USER_IN:' || :APP_USER_IN || ' |V_PROMPT:' || :V_PROMPT 
            FROM DUAL;

            -- Get the AI profile for this prompt. It will choose from the list of profiles that were selected by the user

            v_profile_name := 'GENAI_VECTOR_APEX'; 
            
            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 4:Generate response using prompt and profiles'
                ,SYSTIMESTAMP
                ,'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT  
            FROM DUAL;
        
        with latitude 
        as
        (
        SELECT DBMS_CLOUD_AI.GENERATE(

            prompt => 'I the need latitude from the following prompt only return one number 
                Prompt: ' || :V_PROMPT,--:WORKFLOW_PROMPT,
            profile_name => 'GENAI',
            action       => 'chat') as latitude_value
            FROM dual
        ),
        longitude 
        as
        (
        SELECT DBMS_CLOUD_AI.GENERATE(

            prompt => 'I the need longitude from the following prompt only return one number 
                Prompt: ' || :V_PROMPT,--:WORKFLOW_PROMPT,
            profile_name => 'GENAI',
            action       => 'chat') as longitude_value
            FROM dual
        ),
        weatherCall
        as
        (
        select apex_web_service.make_rest_request(
            p_url            => 'https://api.open-meteo.com/v1/forecast?latitude=' || latitude_value || '&longitude=' || longitude_value || '&daily=temperature_2m_max,temperature_2m_min&current=apparent_temperature,temperature_2m,relative_humidity_2m&forecast_days=3&temperature_unit=fahrenheit',
            p_http_method    => 'GET') weatherJSON
        from latitude,longitude  
        )
        SELECT DBMS_CLOUD_AI.GENERATE(
                                    prompt => :V_PROMPT || ' using the info: ' || weatherJSON,
                                    profile_name => 'GENAI',
                                    action       => 'chat') into c_response
            FROM weatherCall;
            
            -- Generate a summary?
            select count(*)
            into l_has_summary
            from ADB_CHAT_CONVERSATIONS
            where id = :CONV_ID 
            and summary is not null;
            
            if l_has_summary = 0 then
                -- Yes! Generate the summary b/c one does not exist.
                -- get a profile to generate the response. 
                v_summary_profile_name:= 'GENAI';

                if v_summary_profile_name is null then
                    l_prompt := 'Untitiled conversation';            
                else
                    l_prompt := dbms_cloud_ai.generate(
                                prompt => 'Rewrite as a short title : '||:WORKFLOW_PROMPT,
                                action => 'chat',
                                profile_name => v_summary_profile_name
                            );

                end if;
                
                update ADB_CHAT_CONVERSATIONS set summary = l_prompt
                where id = :CONV_ID and summary is null;
            
            end if;

            INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
            SELECT 'Tool 4: check for other tool calls'
                ,SYSTIMESTAMP
                ,':CONV_ID' || :CONV_ID || 'v_profile_name:' || v_profile_name || ' |V_PROMPT:' || :V_PROMPT  || ' c_sql:' || c_sql 
            FROM DUAL;
            
            :WEATHER_TOOL := 'false';

            UPDATE ADB_CHAT_CONVERSATIONS_TOOLS
            SET TOOL_APPLIED = 1
            WHERE CONVERSATION_ID = :CONV_ID
            AND    TOOL_ID = 4;

            v_tools_left := 0;

            SELECT COUNT(*) INTO v_tools_left
            FROM ADB_CHAT_CONVERSATIONS_TOOLS
            WHERE CONVERSATION_ID = :CONV_ID
            AND  TOOL_APPLIED = 0;

            IF v_tools_left > 0 THEN
            
                c_response := dbms_cloud_ai.generate(
                                prompt => 'Rewrite to 3000 characters or less and remove anything about weather not available and keep any source references:  '|| c_response,
                                action => 'chat',
                                profile_name => 'GENAI'
                            );

                :V_PROMPT :=  :V_PROMPT || ' use this information ' || substr(c_response,1,3000);
                    INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
                    SELECT 'Tool 4: UPDATE V_PROMPT'
                        ,SYSTIMESTAMP
                        ,':CONV_ID' || :CONV_ID || ' |V_PROMPT:' || :V_PROMPT || ' |c_response '  
                    FROM DUAL;
            
            ELSE

                INSERT INTO ADB_CHAT_PROMPTS (conv_id, profile_name, prompt, response, asked_on, showsql) 
                VALUES (:CONV_ID, v_profile_name, :WORKFLOW_PROMPT, c_response, systimestamp, c_sql);
                INSERT INTO WORKFLOW_LOG (STEP, STARTTIME, PARAMETERS)
                    SELECT 'Tool 4: INSERT INTO ADB_CHAT_PROMPTS'
                        ,SYSTIMESTAMP
                        ,':CONV_ID ' || :CONV_ID || ' |WORKFLOW_PROMPT:' || :WORKFLOW_PROMPT || ' |c_response ' 
                    FROM DUAL;
            
            END IF;
            
        end;
        </copy>
    ```

    ![select Weather API Tool](images/apex_tool_calling_workflow_weather_api_tool.png)
    ![validate Weather API Tool pl/sql](images/apex_tool_calling_workflow_weather_api_tool_validate.png)

You may proceed to the next lab
## Acknowledgements


* **Author**
    * **Jadd Jennings**, Principal Cloud Architect, NACIE

* **Contributors**


* **Last Updated By/Date**
    * **Jadd Jennings**, Principal Cloud Architect, NACIE, June 2025