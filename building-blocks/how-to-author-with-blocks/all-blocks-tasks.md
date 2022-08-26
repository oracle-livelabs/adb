# List of Building Blocks and Tasks
## Introduction

Review the list of Building Blocks and Tasks that are currently available. Become a contributor by creating reusable components!
## List of Building Blocks

Building Blocks are exposed to customers. You can use these same blocks in your own workshop by adding the block to your manifest.json file.
| Cloud Service | Block |  File | Description |
|---------------| ---- |  ---- |------------ |
| adb | [Connect with SQL Worksheet](/building-blocks/workshop/freetier/index.html?lab=connect-sql-worksheet.md) | /building-blocks/blocks/adb/connect/connect-sql-worksheet.md | Connect to Autonomous Database using the SQL Worksheet in Database Actions |
| adb | [Load and Analyze Data from REST Services](/building-blocks/workshop/freetier/index.html?lab=load-analyze-rest.md) | /building-blocks/blocks/adb/load-analyze-rest/load-analyze-rest.md | Analyze data sourced from REST services. Using the News API as an example.<ul><li>Create an Account on newsapi.org</li><li>Create a PLSQL function that retrieves news for actors</li><li>Perform a sentiment analysis on the article descriptions</li><li>Find which actors are generating buzz - both good and bad</li></ul> |
| adb | [Use Database Actions Data Loading for Object Store data](/building-blocks/workshop/freetier/index.html?lab=load-data-tools.md) | /building-blocks/blocks/adb/load-data/load-data-tools.md | Use the Database Actions tooling to easily load data from object storage. |
| adb | [Provision ADB using Python API](/building-blocks/workshop/freetier/index.html?lab=provision-python-api.md) | /building-blocks/blocks/adb/provision-python-api/provision-python-api.md | OCI provides a rich set of APIs to interact with its services. Use the python API to provision an autonomous database. |
| adb | [Create an Oracle Autonomous Database (ADW and ATP)](/building-blocks/workshop/freetier/index.html?lab=provision-console.md) | /building-blocks/blocks/adb/provision/provision-console.md | No description found. |
| adb | [Access and Load Partitioned Object Storage Data](/building-blocks/workshop/freetier/index.html?lab=use-partitioned-external-table.md) | /building-blocks/blocks/adb/use-partitioned-external-table/use-partitioned-external-table.md | No description found. |
| oac | [Provision Your Oracle Analytics Cloud (OAC) Instance](/building-blocks/workshop/freetier/index.html?lab=oac-provision.md) | /building-blocks/blocks/oac/provision/oac-provision.md | No description found. |

[Go here for the customer view of Building Blocks](/building-blocks/workshop/freetier/index.html)
## List of Tasks

Listed below are the tasks that you can incorporate into your markdown. You can also use the navigation tree on the left to view the tasks. Again, contribute to the list of tasks!
| Cloud Service | Task |  File | Description |
|---------------| ---- |  ---- |------------ |
| adb | [Connect with SQL Worksheet](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#ConnectwithSQLWorksheet) | /building-blocks/tasks/adb/connect-with-sql-worksheet-body.md | Connect to Autonomous Database using the SQL Worksheet in Database Actions |
| adb | [Create and load JSON Collection from object storage](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#CreateandloadJSONCollectionfromobjectstorage) | /building-blocks/tasks/adb/create-load-json-collection.md | <ul><li>Loads data using DBMS&lowbar;CLOUD.COPY&lowbar;COLLECTION</li><li>Introduces JSON&lowbar;SERIALIZE, JSON&lowbar;VALUE and JSON&lowbar;QUERY (minimal)</li><li>Creates a view over JSON data</li><li>Performs basic JSON queries</li></ul> |
| adb | [Go to Data Load Utility Database Action](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#GotoDataLoadUtilityDatabaseAction) | /building-blocks/tasks/adb/goto-data-load-utility.md | Navigate to data loader. AUTHORS: For expediency, this task uses the ADMIN user/password to open Database Actions. In your workshop, you might want to substitute a different user/password to open Database Actions. |
| adb | [Go to Autonomous Database Service](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#GotoAutonomousDatabaseService) | /building-blocks/tasks/adb/goto-service-body.md | Navigate to ADB using the OCI menu. AUTHORS: For expediency, this task uses the ADMIN user/password to open Database Actions. In your workshop, you might want to substitue a different user/password to open Database Actions. |
| adb | [Go to SQL Worksheet in Database Actions](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#GotoSQLWorksheetinDatabaseActions) | /building-blocks/tasks/adb/goto-sql-worksheet.md | Navigate to SQL Worksheet from the OCI service console.  |
| adb | [Provision Autonomous Database](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#ProvisionAutonomousDatabase) | /building-blocks/tasks/adb/provision-body.md | Provision an ADB. Use the `variables.json` file to update provisioning parameters, including database name, OCPUs, storage and more. |
| adb | [Query JSON arrays](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#QueryJSONarrays) | /building-blocks/tasks/adb/query-json-arrays.md | Use JSON&lowbar;TABLE to convert arrays into rows. |
| adb | [Query simple JSON attributes](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#QuerysimpleJSONattributes) | /building-blocks/tasks/adb/query-json-simple.md | Use dot notation and JSON&lowbar;VALUE to query JSON documents. Creates a view to simplify subsequent access. |
| adb | [Query Object Storage contents with SQL](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#QueryObjectStoragecontentswithSQL) | /building-blocks/tasks/adb/query-object-store-contents-with-sql.md | Use SQL to see listing of object storage files and folders. |
| adb | [Analyze Spatial Data with SQL](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#AnalyzeSpatialDatawithSQL) | /building-blocks/tasks/adb/query-spatial.md | Oracle provides rich support for querying and analyzing spatial data. Run queries to find pizza shops closest to customers. |
| adb | [Using Partitoned External Tables](/building-blocks/how-to-author-with-blocks/index.html?lab=adb#UsingPartitonedExternalTables) | /building-blocks/tasks/adb/use-partitioned-external-table-body.md | Create partitioned external tables over object storage data using a single, simple API call. Then, load that data. Compare performance of external tables and partitioned external tables. |
| iam | [Create an OCI Compartment](/building-blocks/how-to-author-with-blocks/index.html?lab=iam#CreateanOCICompartment) | /building-blocks/tasks/iam/compartment-create-body.md | Create a new compartment using the OCI service console |

## manifest.json Template
The manifest.json template below includes all the tasks that are currently available. You can remove those that you do not plan to use - either directly or thru a Block

```
<copy>
{
  "workshoptitle":"LiveLabs Workshop Template",
  "include": {
     "adb-connect-with-sql-worksheet-body.md":"/building-blocks/tasks/adb/connect-with-sql-worksheet-body.md",
     "adb-create-load-json-collection.md":"/building-blocks/tasks/adb/create-load-json-collection.md",
     "adb-goto-data-load-utility.md":"/building-blocks/tasks/adb/goto-data-load-utility.md",
     "adb-goto-service-body.md":"/building-blocks/tasks/adb/goto-service-body.md",
     "adb-goto-sql-worksheet.md":"/building-blocks/tasks/adb/goto-sql-worksheet.md",
     "adb-provision-body.md":"/building-blocks/tasks/adb/provision-body.md",
     "adb-query-json-arrays.md":"/building-blocks/tasks/adb/query-json-arrays.md",
     "adb-query-json-simple.md":"/building-blocks/tasks/adb/query-json-simple.md",
     "adb-query-object-store-contents-with-sql.md":"/building-blocks/tasks/adb/query-object-store-contents-with-sql.md",
     "adb-query-spatial.md":"/building-blocks/tasks/adb/query-spatial.md",
     "adb-use-partitioned-external-table-body.md":"/building-blocks/tasks/adb/use-partitioned-external-table-body.md",
     "iam-compartment-create-body.md":"/building-blocks/tasks/iam/compartment-create-body.md"
  },
  "help": "livelabs-help-db_us@oracle.com",
  "variables": ["./variables.json"],
  "tutorials": [  
    {
        "title": "Get Started",
        "description": "Get a Free Trial",
        "filename": "https://raw.githubusercontent.com/oracle/learning-library/master/common/labs/cloud-login/cloud-login.md"
    },
    {
        "title": "Provision Autonomous Database",
        "type": "freetier",
        "filename": "/building-blocks/blocks/adb/provision/provision-console.md"
    },
    {
        "title": "Your lab goes here",
        "type": "freetier",
        "filename": "/../../yourlab.md"
    }
  ]
}
</copy>
```