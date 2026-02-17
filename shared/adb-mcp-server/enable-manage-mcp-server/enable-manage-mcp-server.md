# Enable and Manage Autonomous AI Database MCP Server

## Introduction

In this lab, you enable, disable, and re-enable the MCP Server for an Oracle Autonomous AI Database Serverless instance. The MCP Server exposes database tools that AI clients can discover and invoke using natural language prompts.

You manage MCP Server using OCI free-form tags and verify its operational state. This lab focuses strictly on lifecycle management of the MCP feature.

This lab establishes the foundation for integrating AI clients with Autonomous AI Database tools.

Estimated Time: X

### Objectives

In this lab, you will:

* Enable MCP Server using OCI free-form tags
* Disable MCP Server
* Re-enable MCP Server

### Prerequisites

This lab requires completion of the previous labs in the **Contents** menu on the left.


## Task 1: Enable MCP Server
To enable MCP Server: 

1. Click the OCI Navigation menu.
2. Navigate to Oracle AI Database.
3. Click Autonomous AI Database.
  ![Access OML User Interface URL](../build-sales-return-agent/images/oml-notebook-url.png)

4. OCI resources are organized by compartments. Select the compartment where your Oracle Autonomous AI Database Serverless instance is provisioned by clicking the **Compartment** field.

    ![The Open dialog box is displayed](../build-sales-return-agent/images/notebook-open-dialog.png " ")

5. Click the Autonomous AI Database Serverless instance you created in the previous lab to enable MCP Server.
6. Scroll to the right on the tools menu and click **Tags** and then click **Add**.
7. Enter the following:
    ```
    Key: adb$feature
    Value: {"name":"mcp_server","enable":true}

    ```
8. Click **Add**. 
MCP Server is enabled for this database instance.

## Task 2: Disable MCP Server

Disabling MCP Server stops new MCP client connections and tool invocations. Any requests already in progress complete successfully. 

You will now modify the same free-form tag created in Task 1.

1. On the **Tags** tab, click the three dots (⋮) next to the **Free-form** tag.

2. Click **Edit**.

3. Modify the **Value** field to:

    ```
    <copy>
      { "name": "mcp_server", "enable": false } 
    </copy>
    ```
4. Click **Update**.

Once the MCP Server is disabled, it stops accepting new client connections.

## Task 3: Re-enable MCP Server

You will now re-enable MCP Server using the same tag.

1. On the **Tags** tab, click the three dots (⋮) next to the **Free-form** tag.

2. Click **Edit**.

3. Modify the **Value** field to:

    ```
    <copy>
      { "name": "mcp_server", "enable": true } 
    </copy>
    ```
4. Click **Update**.


You may now proceed to the next lab.

## Learn More

* [Using Oracle Autonomous AI Database Serverless](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsb/index.html)
* [Oracle Autonomous AI Database MCP Server Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/mcp-server.html#GUID-22D738E1-BC06-47F0-9684-CD698DD8C492)


## Acknowledgements

* **Author:** Sarika Surampudi, Principal User Assistance Developer
* **Contributors:** Chandrakanth Putha, Senior Product Manager; Mark Hornick, Senior Director, Machine Learning and AI Product Management
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
