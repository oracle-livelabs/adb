<!--
    {
        "name":"Query simple JSON attributes",
        "description":"Use dot notation and JSON_VALUE to query JSON documents. Creates a view to simplify subsequent access."
    }
-->
Oracle Database offers a wide range of SQL functions that help you analyze JSON data ([see documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/adjsn/query-json-data.html#GUID-119E5069-77F2-45DC-B6F0-A1B312945590) for details). The SQL capabilities include simple extraction of JSON attributes using dot notation, array and object manipulation, JSON aggregations and more.  

1. Use simple dot notation to extract fields in tabular format. 
    
    The movie collection includes `title` and `year` attributes. Your SQL can use dot notation to navigate the JSON path. For example, `m.json_document.title` refers to table `m` (`movie_collection`), the `json_document` column, and the `title` JSON attribute. Copy and paste the following SQL into the worksheet and click run to view Meryl Streep's movies:
    ```
    <copy>
    select 
        m.json_document.title,
        m.json_document.year       
    from movie_collection m
    where cast like '%Meryl Streep%'
    ;
    </copy>
    ```

    Below are the Meryl Streep movies and the year that they were released:
    ![Meryl Streep movies](images/adb-query-json-meryl-streep.png)

2. Simplify subsequent queries against the movie collection by using a view. The view will allow tools and applications to access JSON data as if it were tabular data. The view definition extracts from the JSON documents both simple fields (using the `JSON_VALUE` function) and complex arrays (using the `JSON_QUERY` function). Copy and past the following SQL into the worksheet.

    ```
    <copy>
    -- Create a view over the collection to make queries easy
    create or replace view movie as
    select
        json_value(json_document, '$.movie_id' returning number) as movie_id,
        json_value(json_document, '$.title') as title,
        json_value(json_document, '$.budget' returning number) as budget,
        json_value(json_document, '$.list_price' returning number) as list_price,
        json_value(json_document, '$.gross' returning number) as gross,
        json_query(json_document, '$.genre' returning varchar2(400)) as genre,
        json_value(json_document, '$.sku' returning varchar2(30)) as sku,
        json_value(json_document, '$.year' returning number) as year, 
        json_value(json_document, '$.opening_date' returning date) as opening_date,
        json_value(json_document, '$.views' returning number) as views, 
        json_query(json_document, '$.cast' returning varchar2(4000)) as cast,
        json_query(json_document, '$.crew' returning varchar2(4000)) as crew,
        json_query(json_document, '$.studio' returning varchar2(4000)) as studio,
        json_value(json_document, '$.main_subject' returning varchar2(400)) as main_subject,
        json_query(json_document, '$.awards' returning varchar2(4000)) as awards,
        json_query(json_document, '$.nominations' returning varchar2(4000)) as nominations,
        json_value(json_document, '$.runtime' returning number) as runtime, 
        json_value(json_document, '$.summary' returning varchar2(10000)) as summary 
    from movie_collection
    ;
    </copy>
    ```
    Each JSON attribute is now exposed as a column - similar to any table column.

3. Query the view by copying and pasting the following SQL into the worksheet:

    ```
    <copy>
    select *
    from movie
    where rownum < 10;
    </copy>
    ```
    ![Tabular and array-based data](images/adb-create-json-view.png)

    Most of the data is in tabular format. However, several of the fields are arrays. For example, there are multiple genres and cast members associated with each movie.
