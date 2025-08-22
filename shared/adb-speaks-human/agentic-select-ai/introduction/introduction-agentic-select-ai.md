# Introduction

## About this Workshop

In this workshop, you will learn how to use **Oracle Autonomous Database Select AI** to build Agentic AI solutions. using natural language prompts.
Agentic AI refers to AI systems that not only answer questions but also _plan_, _reason_, and _take actions_ using structured steps.


### Agentic AI Use Case with Select AI

In this workshop, Select AI helps you build an intelligent system that can automate customer service agents for tasks such as product returns, refunds, and order updates.

### Sales Return Agent Scenario
Almost everyone who buys something online has had to send it back at some point. Maybe it was damanged when it got there, or maybe they just didn't need it anymore. In this workshop, you'll build a Sales Return Agent that helps you deal with this familiar situation.

The agent will talk to the customer to:
* Find out why the item is being returned.
* Update the database to show the return status.
* Optionally, generate a confirmation email to confirm the product return.

You will build this agentic solution one step at a time. You will start by defining functions and tools, then move on to tasks, agents, and finally an agent team. Each layer provides new capabilities that make the solution more like a real-world return routine.

There are two parts to this solution:
* Core return handling: The agent talks to the customer and makes changes to the database table.
* Better experience: The agent becomes more personable by generating a standard email response to confirm the return.

At the conclusion, you'll see how Select AI can use structured database updates and natural language interactions to make the return process seamless and human-like.

### Concepts of Agentic AI with Select AI
Before we begin, let's review some important terms:
* **Agent**: An AI worker that performs a specific role.
* **Agent Team**: A group of agents working together on a broader task.
* **Task**: A step or responsibility assigned to an agent (For example, processing a return).
* **Tool**: A resource an agent uses, such as a database function, SQL query, or API call.
* **ReAct Framework (Reasoning and Acting)**: The logic where the agent reasons about the request, chooses tools, and performs actions step by step.
* **RAG Tool**: A retrieval mechanism that lets the agent pull in external or domain-specific knowledge to make better decisions.

**NOTE:** This workshop requires access to a Large Language Model (LLM). You can use LLMs from OCI GenAI, OpenAI, Azure, or Google Gemini. If you want to use OCI GenAI, ensure that your tenancy is subscribed to one of the following regions (at the time the workshop was last updated): **US Midwest (Chicago)** (default), **Germany Central (Frankfurt)**, **UK South (London)**, **Brazil East (Sao Paulo)**, or **Japan Central (Osaka)** regions in order to run this workshop. See the [OCI documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingregions.htm) for more details. For the current list of regions with **Generative AI**, see [Regions with Generative AI](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm).

### Objectives

In this workshop, you will:

* Configure your Autonomous Database to leverage AI models for querying data using natural language.
* Use the **Ask Oracle** chatbot to chat with your data in your own language.
* Build a Sales Return Agent that updates the database with product return status, chats with the customer, and processes the return.
* Refine your AI agent by providing personable interactions and generate an email response to confirm the return.
* Define a function and tool to generate a standard email response to confirm the return.


You may now proceed to the next lab.

## Learn more

* [Oracle Autonomous Database Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/index.html)
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
