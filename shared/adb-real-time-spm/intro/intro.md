# Introduction #

## About this Workshop ##

SQL execution plan changes can sometimes cause performance regressions that have a significant impact on the service levels of an application. Real-time SQL plan management will compare the performance of a new execution plan with the performance of plans previously used by the SQL statement (should any other plans have been used within the last 53 weeks). If an earlier plan is known to perform significantly better, it will be reinstated automatically using a SQL plan baseline.

Estimated time for the entire workshop: 50 minutes

### Objectives
The aim of this workshop is to become familiar with real-time SPM. You will also learn about how to configure the feature.

The steps are:

- Create a test schema
- Run a sample query that performs well
- Induce a plan performance regression
- Run the sample query again, and the performance regression will be repaired
- Reset the test
- Induce a plan performance regression, demonstrating a "runaway" query interrupted by Database Resource Manager
- Run the sample query again, and the performance regression will be repaired

### Prerequisites
- An Oracle Cloud Account - Please view this workshop's LiveLabs landing page to see which environments are supported.

## How it Works

If an execution plan for a known SQL statement canges, real-time SPM compares the performance of the new plan with a previous execution plan (store in the automatic SQL tuning set). A SQL plan baseline will be created for the plan that performs best. This prevents SQL performance regressions caused by plan changes.

## Acknowledgements
* **Author** - Nigel Bayliss, Dec 2024 
* **Last Updated By/Date** - Nigel Bayliss, Dec 2024