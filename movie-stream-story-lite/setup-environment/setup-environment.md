# Setup Environment
## Introduction

This workshop will focus on the analytics behind MovieStream. There are few steps required prior to doing these analytics, including:
* Provisioning your Autonomous Database
* Creating a user
* Creating tables and views
* Loading data from object storage

These setup steps have been automated using a predefined OCI Cloud Stack Template that contains all the resources you need. You'll use OCI Resource Manager to deploy this template and make your environment available in just a few minutes. You can use Resource Manager for your own projects - [check out the documentation](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm) for more details.

Check out the [Load and Analyze Your Data with Autonomous Database](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=582) to learn more about provisioning Autonomous Database and loading data.

Estimated Time: 10 minutes.

### Objectives

Learn how to
* Run the stack to perform all the prerequisites required to analyze data. 

## (Optional) Task 1: Create OCI compartment
[](include:iam-compartment-create-body.md)

## Task 2: Create an IAM policy enabling access to OCI Generative AI

**Note:** Select AI supports many AI providers and LLMs ([see list here](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/select-ai-about.html#GUID-FDAEF22A-5DDF-4BAE-A465-C1D568C75812)). This workshop uses **OCI Generative AI** as your AI provider.

[](include:create-genai-policy.md)

## Task 3: Provision ADB and load data using an OCI Cloud Stack
[](include:stack-provision-adb.md)


## Acknowledgements
  * **Author** - Marty Gubar, Product Management
  * **Contributors** -  Marty Gubar, Product Management
* **Last Updated By/Date** - Marty Gubar, Product Management, May 2025