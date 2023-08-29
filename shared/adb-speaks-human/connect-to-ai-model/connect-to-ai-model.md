# Allow users to connect to your LLM
## Introduction

You can use different large language models (LLM) with Autonomous Database. In this lab, you will enable the user **MOVIESTREAM** to use the LLM that you set up in the previous lab.

Estimated Time: 10 minutes.

### Objectives

Learn how to
* As ADMIN, enable users to connect to the LLM REST endpoint
* Grant users privileges to use the AI SQL APIs

### Prerequisites
- This lab requires completion of the Setup Environment lab in the Contents menu on the left.


## Task 1: Log into SQL Worksheet 
[](include:adb-connect-with-sql-worksheet-body.md)

## Task 2: Give MOVIESTREAM user permissions use AI SQL
The first thing you need to do is give the **MOVIESTREAM** user permissions to make REST calls to **api.open.com**. This is done by adding the user to the network Access Control List. For more details, you can [check out the `dbms_network_acl_admin` documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html#GUID-254AE700-B355-4EBC-84B2-8EE32011E692).

Then, you will give permissions to the **MOVIESTREAM** user to use the AI SQL by granting access to the `DBMS_CLOUD_AI` package.

1. Open access to the LLM's rest endpoint. For our workshop, specify **api.openai.com** and the principal_name **MOVIESTREAM**.

    ```
    <copy>
    begin
    dbms_network_acl_admin.append_host_ace (
      host         => 'api.openai.com',
      lower_port   => 443,
      upper_port   => 443,
      ace          => xs$ace_type(
          privilege_list => xs$name_list('http'),
          principal_name => 'MOVIESTREAM',
          principal_type => xs_acl.ptype_db));
    end;
    /
    </copy>
    ```

2. Next, give **MOVIESTREAM** privileges to use the `DBMS_CLOUD_AI`:

    ```
    <copy>
    grant execute on dbms_cloud_ai to moviestream;
    </copy>
    ```



## Acknowledgements
  * **Author** - Marty Gubar, Product Management
  * **Contributors** -  Marty Gubar, Product Management
* **Last Updated By/Date** - Marty Gubar, Product Management, August 2023