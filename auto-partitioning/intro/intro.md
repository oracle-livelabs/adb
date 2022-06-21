# Introduction #

## About this Workshop ##

Automatic partitioning in Autonomous Database analyzes your application workload and automatically applies partitioning to your tables and indexes to improve performance or to allow better management of large tables.

Finding appropriate partitioning strategies requires deep knowledge of the application workload and the data distribution. When you perform manual partitioning, you must analyze your workload and make choices about how to apply partitioning to tables and indexes to improve the performance of applications. Automatic partitioning enables Autonomous Database users to benefit from partitioning without performing manual schema and workload analysis.

Automatic partitioning uses a single-column partition key combined with single-level partitioning. Automatic partitioning does not support more complex partitioning strategies such as multi-column partitioned tables or composite partitioning as of today.

Automatic partitioning chooses from the following partition methods:

- AUTOMATIC INTERVAL: This choice is best suited for ranges of partition key values. This is an internal-only partitioning method.
- LIST AUTOMATIC: This partitioning method applies to distinct partition key values.
- HASH: Applies partitioning on the partition key's hash values.

The workshop is designed to be used in a 19c Autonomous Database (ADB) instance where a table needs to be larger than 5 GBytes to be considered for auto partitioning. In non-free ADB services, tables must be at least 64GB. This workshop will not work in a 21c Always Free Autonomous Database as of today.

Estimated time for the entire workshop: 100 minutes

### Objectives
The aim of this workshop is to become familiar with automatic partitioning and the several automated tasks executed by it. You furthermore will learn about the controls of automatic partitioning to optimally leverage it for your environment to improve performance.

The steps are:

- Create a 5GB non-partitioned table called APART, filled with random data
- Run a test workload on the APART table
- Run the auto partitioning _validate_ API to confirm that the table meets auto partitioning requirements
- Execute the auto partitioning _recommend_ task in report-only mode. The task will build a partitioned copy of the table and compare performance before vs. after partitioning.
- Use the _apply_ API to implement the auto partition recommendation. The APART table will be transformed into an ONLINE ALTER TABLE operation so that the production workload is not interrupted. 

### Prerequisites
- An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.

## How it Works

Automatic partitioning analyses the workload for selected candidate tables.

- By default, automatic partitioning uses the workload information collected in an Autonomous Database for analysis. 
- Depending on the size of the workload, a sample of queries might be considered.

Automatic partitioning evaludates partition schemes based on workload analysis and quantification and verification of the performance benefits:

- Candidate empty partition schemes with synthesized statistics are created internally and analyzed for performance.
- The candidate scheme with the highest estimated IO reduction is chosen as the optimal partitioning strategy and is internally implemented to test and verify performance.
- If a candidate partition scheme improves performance beyond specified performance and regression criteria, automatic partitioning is recommended.
- The recmmonded automatic partitioning scheme can be implemented automatically in an online manner. Alternatively you can choose to manually invoke the apply of the recommended automatic partitioning scheme after reviewing the benefits of the recommendation yourself.


## Acknowledgements
* **Author** - Nigel Bayliss, Dec 2021 
* **Contributor** - Hermann Baer
* **Last Updated By/Date** - Nigel Bayliss, Jan 2021