# Introduction                                   

## About this Workshop

The goal of this workshop is to build a customizable application starting from a ***simple JSON file***, using an ***Oracle Autonomous JSON Database*** to store the data in ***SODA Document Collections***. The application is using ***NodeJS*** and ***SODA*** on the server-side, and ***OracleJET*** for the interface. There is also an integration with ***Oracle Digital Assistant (ODA)*** and ***Slack***, as well as one with ***OKE***.

The infrastructure of the application is build in Oracle Cloud Infrastructure and will use several resources, as shown in the architecture diagram below.

![architecture-diagram](./images/architecture-diagram.png)

The application presented in the following labs is based on a sample JSON file with data regarding a group of employees and details about them and their skills on certain categories of skills and areas of development. The JSON can be easily updated in order to fit any other business need.

For example, you can build up a JSON with information for an online shop if instead of having details about employees and their skills you have details about products in the shop and product specifications for each of them. Another idea would be to have information regarding the physical stores a company owns as well as the categories of products and the product list for each store.

It's up to you to customize the JSON according to your business need.

Estimated Workshop Time: 14 hours

### About Product/Technology
* ***What are Oracle Autonomous JSON Databases?***

  As stated on [oracle.com](https://www.oracle.com/autonomous-database/autonomous-json-database/), **Oracle Autonomous JSON Databases** are a cloud document database service that makes it easier to develop JSON-centric applications. These offer several functionalities, including the possibility to easily develop _REST APIs_ in popular programming languages such as _NodeJS_, _Java_ and _Python_.

* ***What is SODA and what are SODA Document Collections?***

  **SODA**, or **Simple Oracle Document Access** is a set of NoSQL-style APIs that allow you create and store JSON document collections in Oracle Databases, as well as perform several queries without using SQL or how the documents are actually stored in the database.

* ***What is OracleJET?***

  **OracleJET**, or **Oracle JavaScript Extension Toolkit**, is a modular open source toolkit used by front-end developers & engineers for building websites and user interfaces. OracleJET provides a collection of reusable components in the [OracleJET Cookbook](https://www.oracle.com/webfolder/technetwork/jet/jetCookbook.html) which can be used to customize the interface of an application in any way possible.

* ***What is Oracle Digital Assistant?***

  **Digital assistants** are virtual devices that help users accomplish tasks through natural language conversations, without having to seek out and wade through various apps and web sites. Each digital assistant contains a collection of specialized skills. When a user engages with the digital assistant, the digital assistant evaluates the user input and routes the conversation to and from the appropriate skills.

* ***What is OKE?***

  **Container Engine for Kubernetes (OKE)** or **Kubernetes** is an open-source container orchestration tool for automating the deployment and management of Cloud Native applications.

### Objectives
In this lab, you will:
  * Set up the environment in OCI
  * Provision an Autonomous JSON Database
  * Create an Object Storage Standard Bucket and upload sample JSON
  * Create SODA collections in the database from the sample JSON in Object Storage
  * Use SODA for NodeJS to create API calls to the database and test them using Postman
  * Create a sample OracleJET application
  * Integrate with Oracle Digital Assistant
  * Deploy the application on OKE
  * Put it all together in one single application

### Prerequisites
To complete this lab, you must have:
  * An OCI Account.

You may now [proceed to the next lab](#next).

## Learn More?
* [Oracle Autonomous JSON Databases](https://www.oracle.com/autonomous-database/autonomous-json-database/)
* [SODA](https://docs.oracle.com/en/database/oracle/simple-oracle-document-access/index.html)
* [OracleJET](https://www.oracle.com/webfolder/technetwork/jet/index.html)
* [Oracle Digital Assistant](https://docs.oracle.com/en/cloud/paas/digital-assistant/use-chatbot/order-service-and-provision-instance.html#GUID-EB06833C-7B1C-46F6-B63C-1F23375CEB7E)
* [Overview of Container Engine for Kubernetes](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm)

## Acknowledgements

**Authors** - Giurgiteanu Maria Alexandra, Gheorghe Teodora Sabina, Minoiu (Paraschiv) Laura Tatiana, Digori Gheorghe
**Contributors** - Grama Emanuel
**Last Updated By** - Brianna Ambler, July 2021
