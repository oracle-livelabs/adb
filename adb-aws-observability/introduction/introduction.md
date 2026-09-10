# Getting Started with Oracle Database@AWS Observability Using AWS Native Services

## Introduction

Using Autonomous AI Database on Oracle Database@AWS, you can provision Dedicated Exadata Infrastructure and Autonomous VM Clusters within Amazon Web Service (AWS) that will host Multicloud deployments of Autonomous AI Database. 
Monitoring is a critical aspect of maintaining the health, performance, and availability of Oracle Database@AWS. Amazon CloudWatch provides a fully managed observability service that enables you to collect, analyze, and act upon operational data in real time. Oracle Database@AWS provides the capability to monitor your resources using Amazon EventBridge.

By the end of this workshop, you will learn how metrics from your Autonomous AI Database are surfaced in AWS CloudWatch, how to build monitoring dashboards, how to set up proactive alarms, and how to capture database lifecycle events using Amazon EventBridge.

*Estimated Workshop Time:* 30 minutes

### Objectives

In this lab, you will learn how to:

- Locate and explore Oracle Database@AWS performance metrics within AWS CloudWatch.
- Build custom AWS CloudWatch Dashboards to visualize key database health and performance indicators.
- Configure CloudWatch Alarms to proactively notify you of potential issues based on database metrics.
- Use Amazon EventBridge to capture database events (e.g., start, stop, backup completion).
- Route database events to AWS CloudWatch Logs for centralized logging and analysis.

### Prerequisites

- An Oracle Database@AWS environment must be pre-provisioned. This lab does not cover the provisioning of the network, Exadata Infrastructure, or the Autonomous Database itself. For detailed instructions on provisioning, please complete the [Introduction to Oracle Database@AWS](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=4203) LiveLab first.
- Familiarity with Oracle Database concepts.
- Basic understanding of the AWS Management Console, specifically CloudWatch and EventBridge.
- Familiarity with available Autonomous AI Database Metrics on AWS: See [CloudWatch](https://docs.oracle.com/en-us/iaas/Content/database-at-aws-exadata-awsmn/awsmn-monitor-cloudwatch.html).

You may now **proceed to the next lab**.

## Acknowledgements

- **Author**: - German Viscuso, Director of Developer Community, Autonomous AI Database
- **Adapted By**: Vandana Rajamani, Consulting UA Developer, July 2026
- **Last Updated By/Date**: - Vandana Rajamani, Consulting UA Developer, July 2026
