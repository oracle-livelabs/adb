# Introduction

## About this Workshop

In this workshop, you will learn how to use **Oracle Autonomous AI Database Select AI** to build Agentic AI solutions. Agentic AI refers to autonomous or semi-autonomous software programs designed to interact with their environment, collect and use data, formulate next actions, and perform tasks to achieve specific goals. They are capable of _perceiving_ their environment, _reasoning_ and _planning_ next steps, and _taking action_. You’ll begin by interacting with an agent using the Ask Oracle Chatbot to get a feel for how a user might engage with an application. You will then dive into building the agentic solution from scratch using Select AI Agent.


### Agentic AI Use Case with Select AI

In this workshop, you will use Select AI Agent to build an intelligent system that can automate customer service agent tasks such as interacting with a customer to handle product returns, refunds, and tasks. The workshop introduces the basic agentic system by defining Select AI Agent objects, such as tools, tasks, agents, and agent teams. 

### Sales Return Agent Scenario
Almost everyone who shops online has returned something at some point, whether it arrived damaged or they simply changed their mind. In this workshop, you'll build a Sales Return Agent that automates this common customer service challenge.

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

You'll see how Select AI Agent can be used to make structured database updates and have natural language interactions with a user while exploring how to create and integrate various types of tools.

### Concepts of Agentic AI with Select AI
Before we begin, let's review some important terms:
* **Agent Team**: Defines one or more agents and the tasks each performs. You call an agent team to start and run your agentic solution.
* **Agent**: An actor with a clearly-defined role that performs tasks using an LLM configured by an AI profile.
* **Task**: A step in a process or responsibility assigned to an agent. A task has a clearly defined set of instructions that may rely on one or more tools (for example, processing a sales return).
* **Tool**: A resource that an agent task uses to interact with systems such as databases, email servers, web services, and other applications.
* **ReAct Pattern**: This refers to _reasoning and acting_. This pattern provides the logic where the agent reasons about the request, chooses tools, performs actions, and evaluates results to accomplish a goal.
<!--* **RAG Tool**: A retrieval mechanism that lets the agent pull in external or domain-specific knowledge to make better decisions.-->

>**NOTE:** This workshop requires access to a Large Language Model (LLM). You can use LLMs from a wide range of AI providers, including OCI GenAI, OpenAI, Azure, and Google Gemini, among others. See the [Select AI Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-about.html#GUID-7574F1D1-CE6F-41BC-AE95-6281EB23C7BE) for more details.
If you want to use OCI GenAI, ensure that your tenancy is subscribed to one of the following regions (at the time the workshop was last updated): **US Midwest (Chicago)** (default), **Germany Central (Frankfurt)**, **UK South (London)**, **Brazil East (Sao Paulo)**, or **Japan Central (Osaka)** regions in order to run this workshop.  For the current list of regions with **Generative AI**, see [Regions with Generative AI](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm).


Estimated Time : 1 hour 35 minutes.

### Objectives

In this workshop, you will:

* Configure your Autonomous AI Database to use AI models for querying data using natural language.
* Build a Sales Return Agent that interacts with customers, gathers information, and updates database tables with return status.
* Refine your agent to provide more personable customer interactions and generate email confirmations.
* Define a function and tool to populate a standardized email form.
* Create a RAG tool to provide alternative product recommendations.
* Familiarize with **Ask Oracle** chatbot and interact with a Sales Return Agent using natural language.


You may now proceed to the next lab.

## Learn more

* [Oracle Autonomous AI Database Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/index.html)
* [Oracle Select AI Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai.html)
* [Oracle Select AI Agent Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-agents1.html)
* [`DBMS_CLOUD_AI` Package Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html#GUID-000CBBD4-202B-4E9B-9FC2-B9F2FF20F246)
* [Additional Autonomous AI Database Workshops](https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/livelabs-workshop-cards?p100_workshop_series=222)

## Acknowledgements
* **Authors:** Sarika Surampudi, Principal User Assistance Developer
* **Contributor:** Mark Hornick, Product Manager
* **Last Updated By/Date:** Sarika Surampudi, February 2026


Copyright (c) 2026 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
