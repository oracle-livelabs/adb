# Introduction #

## About this Workshop ##

Automatic indexing in Autonomous Database analyzes your application workload and automatically manages indexes to improve performance.

Manually creating indexes requires deep knowledge of the data model, how applications behave, and the characteristics of the data in the database. In the past, DBAs were responsible for making choices about which indexes to create, and then sometimes the DBAs did not revise their choices or maintain indexes as the conditions changed. As a result, opportunities for improvement were lost, and the use of unnecessary indexes could become a performance liability.

Automatic indexing enables Autonomous Database users to benefit from indexing without the risks inherent in making changes without analyzing the effect changes will make to the application workload.

The workshop is designed to be used in a 19c Autonomous Database instance.

Estimated time for the entire workshop: 60 minutes

<<<<<<< HEAD
### Workshop Objectives
The aim of this workshop is to become familiar with automatic indexing and the automated tasks executed by it. The steps are:
=======
### Objectives
The aim of this workshop is to become familiar with automatic indexing and the automated tasks executed by it. 

The steps are:
>>>>>>> a018cc9f104bbed582ed765f303e03c7bdfa08d6

- Prepare a database user and create a simple application schema
- Enable automatic indexing
- Run an application workload
- Allow time for automatic indexes to complete its analysis and create new indexes
- View the automatic index report
- Explore details of the automatic indexing process
- Learn basic configuration options

<<<<<<< HEAD
### Lab Breakdown

- Lab 1: Provision an Autonomous Database Instance
- Lab 2: Create an Application Schema and Prepare for Auto Indexing
- Lab 3: Execute an Application Workload
- Lab 4: View the Auto Indexing Report
- Lab 5: View Automatic Indexing Details
- Lab 6: Configuring and Controlling Automatic Indexing

=======
>>>>>>> a018cc9f104bbed582ed765f303e03c7bdfa08d6
### Prerequisites
- An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.

## How it Works

Workload information collected in an Autonomous Database for analysis. Indexes are created based on workload analysis with verification and quantification of performance benefits:

- SQL statement predicate usage information is used to identify candidate indexes.
- Candidate indexes are created internally, hidden from the application workload.
- Internally, application workload SQL is test executed with the candidate indexes and analyzed for performance.
- Indexes that improve performance beyond internally specified performance and regression criteria are made visible to the application workload.
- SQL plan baselines prevent execution plan changes for SQL statements that do not benefit from an otherwise-beneficial index.


## Acknowledgements
* **Author** - Nigel Bayliss, Jun 2022 
* **Last Updated By/Date** - Nigel Bayliss, Jul 2022