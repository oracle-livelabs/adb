# Configure Claude Desktop to Use MCP Server

## Introduction

This lab walks you step-by-step through of setting up Claude Desktop, an advanced AI assistant developed by Anthropic for natural language understanding and productivity support. You will learn how to configure Claude Desktop as an MCP client for Oracle Autonomous AI Database MCP Server. After configuration, Claude Desktop discovers and invokes tools exposed by your database instance.
This lab will install and verify required components and enables natural language interaction between Claude Desktop and Autonomous AI Database tools.

Estimated Time: 15 Minutes

### Objectives

In this lab, you will:

* Install and verify Claude Desktop
* Install and verify Node.js runtime
* Configure Claude Desktop as an MCP Client
* Authenticate Claude Desktop with Autonomous AI Database credentials
* Select and manage tool access through Claude Desktop

### Prerequisites

- This lab requires completion of all previous labs in the **Contents** menu on the left.


## Task 1: Install Claude Desktop

Claude Desktop acts as an MCP client and provides an interface for calling database tools. Install Claude Desktop on your computer based on your operating system:  Windows or Mac. Choose from:

#### On Windows

1. Visit the [Claude Desktop download page](https://support.claude.com/en/articles/10065433-installing-claude-desktop).
2. Download and run the Windows installer (.exe or .msix).
3. Follow the installation wizard instructions.
4. Open the Claude application from your Start Menu or desktop.
5. Sign in to Claude with your Anthropic account (use two-factor authentication if prompted).
6. Test Claude Desktop by asking a simple question.

#### On Mac

1. Visit the [Claude Desktop download page](https://support.claude.com/en/articles/10065433-installing-claude-desktop).
2. Download the .dmg file and open it.
3. Drag the Claude app into your Applications folder.
4. Launch the app and sign in with your Anthropic account.
5. Test the app by asking a simple question.

## Task 2: Install Node.js

Claude Desktop uses Node.js utilities to connect to and interact with the Autonomous AI Database MCP Server. Installing Node.js ensures the tools work correctly for the integration process.

Install Node.js on your computer based on your operating system — Windows or Mac. Choose from:

#### On Windows
1. Go to the [Node.js download page](https://nodejs.org/en/download).
2. Download the Windows Installer (.msi) for the LTS version.
3. Double-click the .msi file and follow the prompts to install, keeping default settings.
4. Open Command Prompt or PowerShell, then type:

    ```
    <copy>
    node -v
    npx -v
    npm -v
    </copy>
    ```

    This should display the installed versions.

#### On Mac
1. Go to the [Node.js download page](https://nodejs.org/en/download).
2. Download the macOS Installer (.pkg) from the Node.js site.
3. Open the .pkg file and follow the on-screen instructions.
4. Enter your Mac password if prompted.
5. Open Terminal and check the installation by running:

    ```
    <copy>
    node -v
    npm -v
    </copy>
    ```
    
    This should display the installed versions.

## Task 3: Obtain Autonomous AI Database MCP Server Endpoint

Recall that you have enabled MCP Server and obtained the database instance OCID. After enabling the MCP server, the database exposes a REST endpoint that you can configure in your MCP-compliant client application.
The endpoint format is as follows:

  ```
  <copy>
  https://dataaccess.adb.<region-identifier>.oraclecloudapps.com/adb/mcp/v1/databases/{database-ocid}
  
  </copy>
  ```

Replace the placeholders with your actual information:

  - {`region-identifier`}: The specific Oracle Cloud region. For example, if your database instance is in Chicago region, the `region-identifier` is `us-chicago-1`.
  - {`database-ocid`}: The OCID of your Autonomous AI Database


## Task 4: Configure Claude Desktop as an MCP client

You'll update the Claude Desktop configuration so it can connect to the Autonomous AI Database MCP Server. You will also edit a configuration file and provide the MCP server configuration details, enabling Claude Desktop to access tools and data from your database.

1. Open the Claude Desktop application.
       - If prompted, sign in using your account credentials.
2. Click **Open Sidebar** on the top left.
3. Click on your username in the left bottom and then click **Settings**.
  ![Claude Desktop main window](../configure-claude-desktop/images/claude-desktop-main.png =70%x*)
4. In **Settings**, under the **Desktop app** section, click **Developer**.
  ![Click Developer under Settings](./images/claude-setting-developer.png =70%x*)
5. Click **Edit Config** to open or edit the `claude_desktop_config` JSON configuration file.
  ![Edit config file](./images/claude-edit-config.png =70%x*)
6. Replace the `{}` in the configuration file with the following JSON configuration to define your MCP server:

    ```
    <copy>
      {
    "mcpServers": {
      "Autonomous_AI_database_mcp_server": {
        "description": "Database containing application-related data",
        "command": "npx",
        "args": [
          "-y",
          "mcp-remote",
          "https://dataaccess.adb.{region-identifier}.oraclecloudapps.com/adb/mcp/v1/databases/{database-ocid}"
        ],
        "transport": "streamable-http"
      }
    }
  }

    </copy>
    ```
    - Replace `{region-identifier}` with your Oracle Cloud region. For example, if your database instance is in Chicago region, the `region-identifier` is `us-chicago-1`.
    - Replace `{database-ocid}` with the OCID of your Autonomous AI Database that you copied in **Lab 2**.
7. **Save** the configuration file.
8. Quit Claude Desktop by clicking the **X** on Claude Desktop screen and ensure it is not running in the background.
       - On Windows, open **Task Manager**, search for any running Claude processes. 
       - Click on the processes and click **End Task** and end all of them.
9. Restart Claude Desktop app. 
10. When prompted, enter your database credentials:
    - Username: **hrm_user**
    - Password: **QwertY#19_95**
    ![Claude Desktop main window](../configure-claude-desktop/images/claude-oauth-authentication.png =70%x*)
11. Claude connects to MCP Server and retrieves available tools for your user profile.

## Task 5: Validate MCP Server is Running
Before proceeding, confirm that the MCP Server is running.
1. Return to Claude Desktop **Settings** → **Desktop app** → **Developer**.
2. You should see "Autonomous\_AI\_database\_mcp\_server" (or the name you assigned in the config) listed as an MCP server and the MCP Server in **running** state.
  ![MCP Server status](./images/claude-mcp-running.png =70%x*)

## Task 6: Review and Control Tool Access

Before you begin using Claude Desktop with your Autonomous AI Database, it's important to review if Claude has successfully retrieved the database tools and manage the tools the MCP client can access. 

To view the available tools and control their permissions, ensuring that only approved tools are accessible through Claude Desktop:

1. In **Settings** → Click **Connectors**  → Click **Configure** next to the MCP server name.
  ![Claude Desktop main window](../configure-claude-desktop/images/claude-connectors-configure.png =70%x*)
2. Click and expand **Other tools**. 
  ![Click Other tools](./images/mcp-connectors-configure-othertools.png =70%x*)
3. Review the tools available to Claude Desktop. 
  ![Claude Desktop main window](../configure-claude-desktop/images/claude-connectors-tools.png =70%x*)
4. By default, all tools require your approval. Here in this lab, leave the defaults.
5. To always allow a tool, click the circled checkmark. 
6. To block a tool, click the lined circle (the tool will not be visible to Claude Desktop).

Claude Desktop is now fully integrated with your Autonomous AI Database.



## Quiz
```quiz score
Q: What component enables Claude Desktop to connect to the MCP Server?

- Oracle SQL Developer
- Python runtime
- Docker Desktop
* Node.js with npx
>Claude uses the npx command (from Node.js) to run the MCP client connector (mcp-remote) and establish communication with the MCP Server.

Q: Where is the MCP configuration stored in Claude Desktop?

- In the Windows Registry
- In the browser cookies
- In the SQL Worksheet
* In the claude_desktop_config.json file
>Claude reads MCP configuration from the claude_desktop_config.json file located in the Claude AppData directory.

Q: What happens if you click “Always Allow” for a tool?

- The tool is permanently disabled
* The tool runs automatically without approval in future requests
- The tool is removed from the list
- The tool runs only once
>“Always Allow” enables automatic tool execution without manual approval for subsequent requests.

```

You may now proceed to the next lab.

## Troubleshooting
If Claude Desktop does not connect or authenticate correctly, review the following checks:


*Claude Does Not Prompt for Database Credentials*

If Claude Desktop does not prompt for database login credentials after restart, the issue is usually caused by cached authentication data.

Try the following steps in order.

#### Option 1: Clear Claude Cache (Recommended First Step)

2. Open Claude Desktop.

3. Click **Menu**.

4. Select **Help**.

5. Click **Troubleshooting**.

6. Choose **Clear Cache and Restart**.

After restart, Claude should prompt for database credentials again.

#### Option 2: Clean MCP Authentication Cache

#### On macOS or Linux, run:

  ```
  <copy>
  rm -rf ~/.mcp_auth
  </copy>
  ```


#### On Windows, delete the folder:

```C:\Users\<your-username>\.mcp_auth```

Then restart Claude Desktop.

#### Option 3: Clear Browser Cookie for MCP Domain

Delete cookies for your MCP server domain:

```dataaccess.adb.{region-identifier}.oraclecloudapps.com```

Example:

```dataaccess.adb.us-chicago-1.oraclecloudapps.com```

Then restart Claude Desktop.

#### Option 4: Reinstall Claude Desktop

If the issue persists:

1. Uninstall Claude Desktop.

2. Delete:

  ```%AppData%\Claude```

3. Reinstall Claude.
4. Restart and try again.

After performing one of the above steps, Claude Desktop prompts you for:

* Database username
* Database password

and then connects to MCP Server successfully.



## Learn More

[Configuring MCP-Compliant clients](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/use-mcp-server.html#GUID-B540AEF5-FB92-4091-9519-289C1B52B690)


## Acknowledgements

* **Authors:** Sarika Surampudi, Principal User Assistance Developer; Dhanish Kumar, Senior Member of Technical Staff
* **Contributors:** Chandrakanth Putha, Senior Product Manager; Mark Hornick, Senior Director, Machine Learning and AI Product Management

Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](https://oracle-livelabs.github.io/adb/shared/adb-15-minutes/introduction/files/gnu-free-documentation-license.txt)
