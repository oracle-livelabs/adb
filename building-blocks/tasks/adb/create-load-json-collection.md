<!---
{
    "name":"Create and load JSON Collection from object storage",
    "description":"<ul><li>Loads data using DBMS_CLOUD.COPY_COLLECTION</li><li>Introduces JSON_SERIALIZE, JSON_VALUE and JSON_QUERY (minimal)</li><li>Creates a view over JSON data</li><li>Performs basic JSON queries</li></ul>"
}
--->
### What is JSON?
JSON provides a language independent, flexible and powerful data model. It was derived from JavaScript, but many modern programming languages include code to generate and parse JSON-format data. For more information see here: [https://en.wikipedia.org/wiki/JSON](https://en.wikipedia.org/wiki/JSON). No wonder that it is such a popular storage format for developers.

Oracle SQL allows you to analyze JSON data - including complex data types like arrays - in combination with structured tabular data.

### Movie JSON data
Our movie data set has a series of columns that contain different types of details about movies. Each movie has a **crew** associated with it and that crew is comprised of **jobs**, such as "producer," "director," "writer," along with the names of the individuals. Each movie also has a list of award nominations and wins. An example of how this information is organized is shown below:
adb-json-movie

![JSON example](images/adb-json-movie.png " ")

You can see that JSON data is organized very differently than typical warehouse data. There is a single entry for "producer" but the corresponding key "names" actually has multiple values. This is referred to as an **array** - specifically a JSON array.

1. Use the Autonomous Database ``DBMS_CLOUD.COPY_COLLECTION`` procedure to create and load the movie collection from object storage. Copy and paste the following PL/SQL into the SQL worksheet and click run:
    ```
    <copy>
    -- create and load movie json collection from a public bucket on object storage
    begin
    dbms_cloud.copy_collection (
        collection_name => 'MOVIE_COLLECTION',
        file_uri_list   => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o/movie/*.json',
        format          => '{ignoreblanklines:true}'
    );
    end;
    /
    </copy>
    ```

    ![Create JSON movie collection](images/adb-create-json-collection.png)

    This single step creates a table called `MOVIE_COLLECTION` and populates it with JSON documents. You can access this table thru SQL, Oracle Database API for MongoDB, SODA REST and more.

> **Note:** There is extra metadata captured for SODA collections that is not removed by dropping the table directly using SQL ``drop table``. To properly drop a collection, use PL/SQL function [`DMBS_SODA.DROP_COLLECTION`](https://docs.oracle.com/en/database/oracle/oracle-database/18/adsdp/using-soda-pl-sql.html#GUID-D29C4FFF-D093-4C1B-889A-5C29B63756C6).

2. Let's take a look at the documents. The documents are stored in a highly optimized binary format. Use the `JSON_SERIALIZE` function to view the JSON text. Copy and paste the following SQL into the worksheet and click **Run**:
    ```
    <copy>
    select json_serialize(json_document) as json
    from movie_collection
    where rownum < 10
    ;
    </copy>
    ```

    Your result will look similar to the following:

    ![Simple JSON query](images/adb-simple-query-json.png)
