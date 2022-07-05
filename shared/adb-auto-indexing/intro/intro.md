# Introduction #

## About this Workshop ##

Automatic partitioning in Autonomous Database analyzes your application workload and automatically manages indexes to improve performance.

Creating indexes manually requires deep knowledge of the data model, application, and data distribution. In the past, DBAs were responsible for making choices about which indexes to create, and then sometimes the DBAs did not revise their choices or maintain indexes as the conditions changed. As a result, opportunities for improvement were lost, and the use of unnecessary indexes could become a performance liability.

Automatic indexing enables Autonomous Database users to benefit from indexing without the risks inherent in making changes without analyzing the effect changes will make to the application workload.

The workshop is designed to be used in a 19c Autonomous Database (ADB) instance.

Estimated time for the entire workshop: 60 minutes

### Objectives
The aim of this workshop is to become familiar with automatic indexing and the automated tasks executed by it. 

The steps are:

- Prepare a database user and create a simple application schema
- Enable automatic indexing
- Run an application workload
- Allow time for automatic indexes to complete its analysis and create new indexes
- View the automatic index report
- Explore details of the automatic indexing process
- Learn basic configuration options

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