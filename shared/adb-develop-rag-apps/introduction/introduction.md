# Introduction

## About this Workshop

In this workshop, you will learn how to use **Autonomous AI Database Select AI (Select AI)** with **Retrieval Augmented Generation (RAG)** to augment your natural language prompt by retrieving content from your specified vector store using semantic similarity search. This reduces hallucinations by using your specific and up-to-date content and provides more relevant natural language responses to your prompts.

> **NOTE:** This workshop requires access to a Large Language Model (LLM). You can use LLMs from OCI GenAI, OpenAI, Azure, or Google Gemini. If you want to use OCI GenAI, ensure that your tenancy is subscribed to one of the following regions (at the time the workshop was last updated): **US Midwest (Chicago)**, **Germany Central (Frankfurt)**, **EU Sovereign Central (Frankfurt)**, **UK South (London)**, **Brazil East (Sao Paulo)**, **Japan Central (Osaka)**, **US West (Phoenix)**, **US East (Ashburn)**, **UAE East (Dubai)**, **Saudi Arabia Central (Riyadh)**, or **India South (Hyderabad)** regions in order to run this workshop. See the [OCI documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingregions.htm) for more details. For the current list of regions with **Generative AI**, see [Regions with Generative AI](https://docs.oracle.com/en-us/iaas/Content/generative-ai/overview.htm).

Watch the video below on how to simplify developing AI Retrieval Augmented Generation (RAG) apps with Autonomous AI Database Select AI.

[](youtube:LsjYT_tQDpM)

### About Select AI

Use natural language to interact with your database and LLMs through SQL to enhance user productivity and develop AI-based applications. Select AI simplifies and automates using generative AI, whether generating, running, and explaining SQL from a natural language prompt, using retrieval augmented generation with vector stores, generating synthetic data, or chatting with the LLM.

Estimated Time: 1 hour

### What is Retrieval Augmented Generation (RAG)?

Select AI with RAG augments your natural language prompt by retrieving content from your specified vector store using semantic similarity search. This reduces hallucinations by using your specific and up-to-date content and provides more relevant natural language responses to your prompts.

Select AI automates the Retrieval Augmented Generation (RAG) process. This technique retrieves data from enterprise sources using AI vector search and augments user prompts for your specified large language model (LLM). By leveraging information from enterprise data stores, RAG reduces hallucinations and generates grounded responses.

RAG uses AI vector search on a vector index to find semantically similar data for the specified question. Vector store processes vector embeddings, which are mathematical representations of various data points like text, images, and audio. These embeddings capture the meaning of the data, enabling efficient processing and analysis. For more details on vector embeddings and AI vector search, see Overview of AI vector search.

Select AI integrates with AI vector search available in Oracle Autonomous AI Database 26ai for similarity search using vector embeddings.

### What is Natural Language Processing?

Natural language processing is the ability of a computer application to understand human language as it is spoken and written. It is a component of artificial intelligence (AI).

### What is Generative AI?

Generative AI enables users to quickly generate new content based on a variety of inputs. Inputs and outputs to these models can include text, images, sounds, animation, 3D models, and other types of data.

### Objectives

In this workshop, you will:

* Configure your Autonomous AI Database to leverage a generative AI model for querying data using natural language
* Use vector search to find the relevant content based on a similarity ranking
* Use **`Select AI`** to query data using natural language and vector search
* Learn about PL/SQL APIs that help integrate AI with your application
* Use the Select AI demo application to chat with your data in your own language

### Oracle MovieStream Business Scenario

The workshop's business scenario is based on Oracle MovieStream - a fictitious movie streaming service that is similar to services to which you currently subscribe. You'll be able to ask questions about movies, customers who watch movies, and the movies they decide to watch.

### Oracle MovieStream Internal Support Website

Oracle MovieStream business has an internal website with support information. We're going to make it easy to ask questions from that support site using vectors. You can access the website by clicking the following URL:

https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/support-site/index.html

![The oracle moviestream internal web site support web site](./images/support-site.png =85%x*)

You may now proceed to the next lab.

## Learn more

* [Oracle Autonomous AI Database Documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/autonomous-intro-adb.html#GUID-8EAA5AE6-397D-4E9A-9BD0-3E37A0345E24)
* [Select AI with Retrieval Augmented Generation (RAG)](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-retrieval-augmented-generation.html#GUID-6B2A810B-AED5-4767-8A3B-15C853F567A2)
* [Overview of Oracle AI Vector Search](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/overview-ai-vector-search.html#GUID-746EAA47-9ADA-4A77-82BB-64E8EF5309BE)

## Acknowledgements
* **Authors:**
    * Marty Gubar, Product Manager
    * Lauran K. Serhal, Consulting User Assistance Developer
* **Last Updated By/Date:** Lauran K. Serhal, November 2025

Data about movies in this workshop were sourced from **Wikipedia**.

Copyright (c) 2025 Oracle Corporation.

Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled [GNU Free Documentation License](files/gnu-free-documentation-license.txt)
