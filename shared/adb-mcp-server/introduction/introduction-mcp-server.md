# Introduction

## About this Workshop

In this workshop, you learn how to use Oracle Autonomous AI Database as a **Model Context Protocol (MCP) Server**. You configure your database instance to expose tools, create custom tools using Select AI Agent with PL/SQL and Python, and configure MCP-compatible AI clients such as Claude Desktop and the Cline extension in Visual Studio Code. You then use these clients to perform database-driven tasks using the tools you defined.


### Business Use Case

Enterprise AI applications increasingly require secure and governed access to operational data, metadata, and database logic. Traditional integration approaches often require custom APIs, middleware layers, or manual orchestration, which increases complexity and operational overhead.

Oracle Autonomous AI Database MCP Server provides a standardized and managed interface that enables AI agents and client applications to interact directly with database tools using the Model Context Protocol (MCP). The MCP Server exposes both built-in and user-defined tools that are dynamically discoverable by AI clients. These tools support workflows such as schema discovery, metadata exploration, and SQL query execution through natural language prompts.

Because the MCP Server integrates with Oracle Cloud Identity, authorization, governance, auditing, and compliance frameworks, it provides secure and scalable AI integration without requiring customers to deploy or maintain separate MCP infrastructure.

### Concepts of Autonomous AI Database MCP Server
Before we begin, let's review some important concepts:

**What Is Autonomous AI Database MCP Server?**

Autonomous AI Database MCP Server is a managed, multi-tenant server that provides standardized access to database tools and capabilities through MCP. Each Autonomous AI Database instance includes its own MCP Server endpoint that AI clients can use to access tools and database functionality.

The MCP Server supports dynamic lifecycle management of tools. Developers can create, update, or delete tools using Select AI Agent frameworks, and MCP clients automatically discover available tools. This architecture supports rapid AI solution development while maintaining enterprise-level governance and security controls. 

**What Is an MCP Client?**

An MCP client is an application that connects to an MCP Server and invokes tools exposed by the server. MCP clients provide the user-facing interface that enables AI-driven workflows and natural language interaction with enterprise data and services exposed through MCP server.

The client sends request to the MCP Server, connects to the server to invoke tools, perform tasks, and retrieve structured results that can be summarized or analyzed by large language models. An MCP client can be used to manage and control workflows, databases, or AI models, while the server handles the heavy lifting and resource management.

Examples of MCP clients used in this workshop include:
- Claude Desktop
- Visual Studio Code with the Cline extension


Estimated Time: x

### Objectives

In this workshop, you will:

* Configure Autonomous AI Database for MCP Server access
* Create and register tools using Select AI Agent framework
* Integrate Autonomous AI Database MCP Server with MCP-compatible clients
* Use MCP clients to explore database schemas, objects, metadata, and business data


You may now proceed to the next lab.

## Learn more

* [Oracle Autonomous AI Database Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/index.html)
* [Oracle Autonomous AI Database MCP Server Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/mcp-server.html#GUID-22D738E1-BC06-47F0-9684-CD698DD8C492)
* [Oracle Select AI Agent Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agents1.html)
* [`DBMS_CLOUD_AI_AGENT` Package Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-agent-package.html)
* [Additional Autonomous AI Database Workshops](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/livelabs-workshop-cards?p100_workshop_series=222)

## Acknowledgements
* **Authors:** Sarika Surampudi, Principal User Assistance Developer; Dhanish Kumar, Member Technical Staff
* **Contributors:** Chandrakanth Putha, Senior Product Manager; Mark Hornick, Senior Director, Machine Learning and AI Product Management*
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
