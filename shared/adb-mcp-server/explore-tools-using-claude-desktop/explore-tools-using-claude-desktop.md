# Explore Tools in MCP Server with Claude Desktop

## Introduction

In this lab, you use Claude Desktop as an MCP client to interact with the user-defined tools created in Lab 3 and exposed through the Autonomous AI Database MCP Server.

You issue natural language prompts, review tool call requests, approve tool run, and examine structured responses returned by the database.

This lab demonstrates how conversational AI safely interacts with enterprise database tools using the Model Context Protocol (MCP).


Estimated Time: x

### Objectives

In this lab, you will:
* Issue natural language prompts in Claude Desktop
* Review and approve MCP tool requests
* Observe how Claude selects appropriate tools
* Review structured summaries generated from database results

### Prerequisites
- This lab requires the completion of all the preceding labs in the **Contents** menu on the left.

## Task 1: Discover Available Schemas
In this task, you ask Claude to retrieve the list of schemas available in your Autonomous AI Database instance. Claude analyzes your natural language prompt, selects the appropriate tool, and calls the database to load schema information. You review the tool call and examine the formatted results returned from the database.

Claude Desktop should already be running and connected to your MCP Server from the previous lab.

1. In Claude Desktop, click **Menu** → **New Chat**.
![Open New Chat](./images/new-chat.png =70%x*)

2. Issue schema discovery prompt: 

 _What schemas are available in the database?_  
![`LIST_SCHEMA` approval](./images/list_schemas.png =70%x*) 

  Claude determines that the LIST_SCHEMAS tool is required.
3. Review the tool request. Click the drop down and click **Allow once**.
![Allow once](./images/list_schema_allow_once.png =70%x*)
A formatted list of schema names available on your Autonomous AI Database along with a summary at the end is displayed.
![List of schema names](./images/list_schemas_result.png =70%x*)

## Task 2: List Objects in a Schema
In this task, you ask Claude to retrieve the list of database objects within a specific schema. Claude processes your natural language prompt, selects the appropriate tool, and calls the database to load object information. You review the tool call request and examine the structured results returned by the database.

1. Issue object discovery prompt:

  _What objects exist in the `HRM_USER` schema?_

  ![Enter list objects prompt](./images/list_objects.png =70%x*)
2. Claude requests permission to use `LIST_OBJECTS`.
3. Review the tool request. Click the drop down and click **Allow once**. 
  ![LIST_OBJECTS allow once](./images/list_objects_allowonce.png =70%x*)

4. Claude returns object names and types.
  ![Lists objects under the HRM_USERS schema](./images/list_objects_result.png =70%x*)


## Task 3: Retrieve Object Metadata
In this task, you request detailed metadata for a specific database object. Claude processes your prompt, selects the appropriate metadata tool, and calls the database to load structural information about the object. You review the tool call details and analyze the formatted metadata returned in the response.

1. Issue metadata prompt:

  _Show the metadata details of the employees table_
  ![Enter the prompt](./images/get_object_details.png =70%x*)
2. Claude requests permission to use `GET_OBJECT_DETAILS`.
3. Review the tool request. Click the drop down and click **Allow once**.
  ![GET_OBJECT_DETAILS allow once](./images/get_object_details_allowonce.png =70%x*)
4. Claude returns structured metadata.
  ![Structured result for employees table](./images/get_object_details_result.png =70%x*)
5. Issue another metadata retrieval prompt:

  _Show the metadata details of the departments table_
  ![Enter the prompt](./images/get_object_details_another_prompt.png =70%x*)
6. You can see that Claude requests permission to use `GET_OBJECT_DETAILS`. Repeat step 3.
7. Claude returns structured metadata.
  ![Structured result for department table](./images/get_object_details_second_prompt_result.png =70%x*)


## Task 4: Execute a Business Query

In this task, you ask Claude to retrieve business data using a natural language query. Claude processes your request, selects the appropriate SQL tool, and calls the database to load the required data. You review the tool call details and examine the summarized results generated from the database output.

1. Issue analytical prompt:

  _Find all employees working in the Engineering department_
  ![Enter the prompt](./images/execute_sql.png =70%x*)
2. You can see that Claude requests permission to use `EXECUTE_SQL`.
3. Review the tool request. Click the drop down and click **Allow once**.
  ![GET_OBJECT_DETAILS allow once](./images/execute_sql_allowonce.png =70%x*)
4. Claude runs a read-only SQL query and returns summarized results.
  ![Structured result for requested table](./images/execute_sql_result.png =70%x*)

You have now completed the full MCP workflow from tool creation to conversational database interaction.

## Quiz
```quiz score
Q: What happens when you click “Allow once” in Claude Desktop?

- The tool is permanently approved
- The tool runs automatically for all future requests
* The tool runs only for the current request
- The tool is disabled
>“Allow once” permits the tool to run only for the current request. Future requests will require approval again unless set to “Always allow.”

Q: If Claude processes a table from an unexpected schema, what should you do?

- Restart Claude
* Qualify the table name with the schema
- Generate a new token
- Disable EXECUTE_SQL
>If the same table name exists in multiple schemas, specify the schema explicitly (for example, SALES_USER.CUSTOMERS).

Q: Why is manual tool approval important in Claude Desktop?

- It increases SQL performance
- It reduces network latency
- It enables caching
* It enforces governance and control
>Manual approval ensures controlled access to database tools and prevents unintended operations.

Q: Which tool retrieves structured metadata about a table?

* GET_OBJECT_DETAILS
- EXECUTE_SQL
- LIST_SCHEMAS
- LIST_OBJECTS
>GET_OBJECT_DETAILS loads structural metadata such as columns and constraints for a specified table.
```

You may now proceed to the next lab.

## Troubleshooting
If tool calls do not return expected results, review the following checks:

*Issue 1: Claude Does Not Prompt for Database Credentials*

**Possible Cause**

Cached authentication data is interfering.

**Resolution**

1. In Claude, click **Menu** → **Help** → **Troubleshooting** → **Clear Cache and Restart**.
2. Restart Claude.
3. Retry connection.

If needed:

Delete the `.mcp_auth` folder.

Clear browser cookies for:
  ```
  dataaccess.adb.<region>.oraclecloudapps.com
  ```

*Issue 2: Metadata Cannot Be Retrieved*

**Possible Causes**

- Stale session
- Table exists in multiple schemas
- Insufficient privileges

**Resolution**

1. Start a new chat session.
2. Retry the prompt.
3. Qualify the table with schema:
  ```
  Show metadata for SALES_USER.CUSTOMERS
  ```

*Issue 3: Tools Do Not Appear*

Check for the following:

1. MCP Server is enabled (Lab 2).
2. You logged in using the schema user from Lab 3.
3. Tools exist:
  ```
  SELECT tool_name FROM user_cloud_ai_tools;
  ```
4. Restart Claude Desktop after verification.

*Issue 5: Claude Stops Working Mid-Session*

**Possible Causes**

- Session timeout
- MCP reconnection required

**Resolution**

- Restart Claude Desktop.
- Reconnect to MCP Server.
- Reissue the prompt.

## Learn More

* [Select AI Agent](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agent1.html) 
* [Select AI Agent Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [Configure MCP Server in MCP-Compatible AI clients](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/use-mcp-server.html#GUID-B540AEF5-FB92-4091-9519-289C1B52B690)


## Acknowledgements

* **Authors:** Sarika Surampudi, Principal User Assistance Developer
* **Contributors:** Chandrakanth Putha, Senior Product Manager; Mark Hornick, Senior Director, Machine Learning and AI Product Management
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->

Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
