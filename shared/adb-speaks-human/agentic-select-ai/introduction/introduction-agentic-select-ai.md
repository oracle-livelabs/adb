# Introduction

## About this Workshop

In this workshop, you will learn how to use **Oracle Autonomous Database Select AI** to build Agentic AI solutions. Agentic AI refers to autonomous or semi-autonomous software programs designed to interact with their environment, collect and use data, formulate next actions, and perform tasks to achieve specific goals. They are capable of _perceiving_ their environment, _reasoning_ and _planning_ next steps, and _taking action_. You’ll begin by interacting with an agent using the Ask Oracle Chatbot to get a feel for how a user might engage with an application. You will then dive into building the agentic solution from scratch using Select AI Agent.


### Agentic AI Use Case with Select AI

In this workshop, you will use Select AI Agent to build an intelligent system that can automate customer service agent tasks such as interacting with a customer to handle product returns, refunds, and tasks. The workshop introduces the basic agentic system by defining Select AI Agent objects, such as tools, tasks, agents, and agent teams. 

### Sales Return Agent Scenario
Almost everyone who buys something online has had to send it back at some point. Maybe it was damaged when it got there, or maybe they just didn't need it anymore. In this workshop, you'll build a Sales Return Agent that helps you deal with this familiar situation.

The agent will interact with customer to:
* Find out why the item is being returned.
* Update the database to show the return status.
* Optionally, generate a confirmation email to confirm the product return.

You will build this agentic solution step-by-step. You will start by defining functions and tools, then move on to tasks, agents, and finally an agent team.

There are several phases to this solution:
* First, a basic definition that interacts with the customer and updates the order status in a database table.
* Second, refine your agent to make it more personable and generate an email that could be sent to the customer confirming the action.
* Third, define a function to populate a standard email form that accepts parameters.
* Fourth, create a tool supporting retrieval augmented generation (RAG) to give recommendations to the customer.

At the conclusion, you'll see how Select AI Agent can be used to make structured database updates and have natural language interactions with a user while exploring how to create and integrate various types of tools.

### Concepts of Agentic AI with Select AI
Before we begin, let's review some important terms:
* **Agent Team**: Specifies one or more agents and the tasks each performs. An agent team is the unit of agentic solution invocation and engagement.
* **Agent**: An actor with a clearly-defined role that performs tasks using an AI profile-specified LLM.
* **Task**: A step in a process or responsibility assigned to an agent. A task has a clearly defined set of instructions that may rely on one or more tools. (For example, processing a return).
* **Tool**: A resource an agent task uses to affect changes in or perceive information from systems, such as a databases, email servers, web services, and other systems.
* **ReAct Framework (Reasoning and Acting)**: The logic where the agent reasons about the request, chooses tools, performs actions, and evaluates results to accomplish a goal.
<!--* **RAG Tool**: A retrieval mechanism that lets the agent pull in external or domain-specific knowledge to make better decisions.-->

>**NOTE:** This workshop requires access to a Large Language Model (LLM). You can use LLMs from a wide range of AI providers, including OCI GenAI, OpenAI, Azure, and Google Gemini, among others . If you want to use OCI GenAI, ensure that your tenancy is subscribed to one of the following regions (at the time the workshop was last updated): **US Midwest (Chicago)** (default), **Germany Central (Frankfurt)**, **UK South (London)**, **Brazil East (Sao Paulo)**, or **Japan Central (Osaka)** regions in order to run this workshop. See the [OCI documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingregions.htm) for more details. For the current list of regions with **Generative AI**, see [Regions with Generative AI](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm).

### Objectives

In this workshop, you will:

* Configure your Autonomous Database to use AI models for querying data using natural language.
* Use the **Ask Oracle** chatbot to interact with a Sales Return Agent using natural language.
* Build a simple Sales Return Agent that interacts with the user to get needed information, updates a database table with a product return status as needed.
* Refine your AI agent by instructing the agent to have more personable interactions with the customer and and generate an email response to confirm the return.
* Define a function and tool to generate a standard email response to confirm the return.
* Define a RAG tool to get alternative product recommendations for the customer.


You may now proceed to the next lab.

## Learn more

* [Oracle Autonomous Database Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/index.html)
* [Oracle Select AI Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai.html)
* [Oracle Select AI Agent Documentation](https://docs-uat.us.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agents1.html)
* [`DBMS_CLOUD_AI` Package Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html#GUID-000CBBD4-202B-4E9B-9FC2-B9F2FF20F246)
* [Additional Autonomous Database Tutorials](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/tutorials.html)

## Acknowledgements
* **Authors:**
    * Sarika Surampudi, Principal User Assistance Developer
    * Mark Hornick, Product Manager
<!--* **Last Updated By/Date:** Sarika Surampudi, August 2025
-->


Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
