# Query Select AI Agent Views

## Introduction

In this lab, you’ll inspect what happened during an agent run. You will read Select AI Agent history views to see team, task, and tool. You’ll also add a small helper procedure that prints the task, agent, prompt and prompt response for any conversation.

Estimated Time: 10 minutes.

### Objectives

In this lab, you will:

* Create a helper procedure that prints team processing (task → agent → prompt → response).
* Explore the schemas of the Select AI Agent history views.
* Run focused queries on:
    * `USER_AI_AGENT_TOOL_HISTORY`
    * `USER_AI_AGENT_TASK_HISTORY`
    * `USER_AI_AGENT_TEAM_HISTORY`

### Prerequisites

- This lab requires completion of the first two labs in the **Contents** menu on the left.
- Typical grants to run DBMS\_CLOUD\_AI\_AGENT Package are (run as ADMIN once):

```
<copy>
GRANT EXECUTE ON DBMS_CLOUD_AI TO <USER>;
GRANT EXECUTE ON DBMS_CLOUD_AI_AGENT TO <USER>;
</copy>
```
Replace _`USER`_ with your user name.

## Task 1: Create a Procedure to View the Team Processing

You are building a helper procedure that prints a readable timeline of a conversation: team, agent, task, prompt, and final response.

Create the team processing procedure and run it.
```
<copy>
WITH latest_team AS (
  SELECT team_exec_id, team_name, start_date
  FROM user_ai_agent_team_history
  ORDER BY start_date DESC
  FETCH FIRST 1 ROW ONLY
),
latest_task AS (
    SELECT team_exec_id, task_name, agent_name, conversation_params, start_date,
           ROW_NUMBER() OVER (PARTITION BY team_exec_id, task_name, agent_name 
                             ORDER BY start_date DESC) as rn
  FROM user_ai_agent_task_history
)
SELECT
--  team.team_name,
  task.task_name,
  task.agent_name,
  p.prompt,
  p.prompt_response
FROM latest_team team
JOIN latest_task task
  ON team.team_exec_id = task.team_exec_id
 AND task.rn = 1
LEFT JOIN user_cloud_ai_conversation_prompts p
  ON p.conversation_id = JSON_VALUE(task.conversation_params, '$.conversation_id')
ORDER BY task.start_date DESC NULLS LAST,
         p.created     DESC NULLS LAST;
</copy>
```

## Task 2: View the Schema of Select AI Agent Views

You'll inspect columns and data types so you know what you can filter and display.

Run the following script:

```
<copy>
%script

describe USER_AI_AGENT_TOOL_HISTORY;
describe USER_AI_AGENT_TASK_HISTORY;
describe USER_AI_AGENT_TEAM_HISTORY;
</copy>
```

## Task 3: Query the `USER_AI_AGENT_` Views

See each tool call the agent made which tool, with what inputs, and what came back. Review task-level flow: which tasks ran, their order, what inputs were used, what were the results, were there any error messages, and what parameters were used. Summarize each end-to-end run: when it started, their status, and conversation context used.

1. Query `USER_AI_AGENT_TOOL_HISTORY`.

```
<copy>
select * from USER_AI_AGENT_TOOL_HISTORY
order by START_DATE desc
</copy>
```

2. Query `USER_AI_AGENT_TASK_HISTORY`.

```
<copy>
select * from USER_AI_AGENT_TASK_HISTORY
 order by START_DATE desc
</copy>
```

3. Query `USER_AI_AGENT_TEAM_HISTORY`

```
<copy>
select * from USER_AI_AGENT_TEAM_HISTORY
order by START_DATE desc
</copy>
```

You may now proceed to the next lab.

## Learn More

* [Select AI Agents](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agents1.html)
* [Select AI Agents Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [OML Notebooks](https://docs.oracle.com/en/database/oracle/machine-learning/oml-notebooks/index.html)
* [Using Oracle Autonomous Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/index.html)


## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer
* **Contributor:** Mark Hornick, Product Manager; Laura Zhao, Member of Technical Staff
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
