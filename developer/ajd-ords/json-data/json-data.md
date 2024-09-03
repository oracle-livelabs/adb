# Process JSON Documents
    
## Introduction
    
Unlike relational data, JSON data can be stored, indexed, and queried without any need for a schema that defines the data. Oracle Database supports JSON natively with relational database features, including transactions, indexing, declarative querying, and views.
    
Oracle Database queries are declarative. You can join JSON data with relational data. And you can project JSON data relationally, making it available for relational processes and tools. You can also query, from within the database, JSON data that is stored outside the database in an external table.

Estimated Lab Time: 15 minutes
    
## Task 1: Split JSON array in single entries 
    
1. You may have noticed the big JSON document lists all cats in the world using a JSON array. At the time this lab was created there were 144 cats in the list. You can split that array into individual JSON documents describing one cat using `JSON_TABLE` function.
    
    ````
    select jt.cat from MYJSON,
      JSON_TABLE(JSON_DOCUMENT, '$.results.bindings[*]' COLUMNS
        (cat VARCHAR2(4000) FORMAT JSON PATH '$' )) AS jt;
    ````
    
2. Use SODA APIs from PL/SQL to list all collections.
    
    ````
    DECLARE
        coll_list  SODA_COLLNAME_LIST_T;
    BEGIN
        coll_list := DBMS_SODA.list_collection_names;
        DBMS_OUTPUT.put_line('Number of collections: ' || to_char(coll_list.count));
        DBMS_OUTPUT.put_line('Collection List: ');
        IF (coll_list.count > 0) THEN
            -- Loop over the collection name list
            FOR i IN
                coll_list.first .. coll_list.last
            LOOP
                DBMS_OUTPUT.put_line(coll_list(i));
            END LOOP;  
        ELSE   
            DBMS_OUTPUT.put_line('No collections found');
        END IF;
    END;
    /
    ````
    
3. Use SODA APIs from PL/SQL to create a new collection.
    
    ````
    DECLARE
        collection   SODA_COLLECTION_T;
    BEGIN
        -- Create collection Cats
        collection := DBMS_SODA.create_collection('Cats');
    END;
    /
    ````
    
4. Check collection has been created.
    
    ````
    soda list
    ````
    
5. Insert documents describing each cat in the new collection called Cats.
    
    ````
    DECLARE
        collection   SODA_COLLECTION_T;
        cursor c1 is select jt.cat from MYJSON,
          JSON_TABLE(JSON_DOCUMENT, '$.results.bindings[*]' COLUMNS
          (cat VARCHAR2(4000) FORMAT JSON PATH '$' )) AS jt;
        document     SODA_DOCUMENT_T;
        status       NUMBER;
    BEGIN
        -- Open the collection
        collection := DBMS_SODA.open_collection('Cats');
        FOR cat_doc in c1
        LOOP
          -- Get document from cursor query
          document := SODA_DOCUMENT_T(
                        b_content => utl_raw.cast_to_raw(cat_doc.cat));
          -- Insert document
          status := collection.insert_one(document);
        END LOOP;
    END;
    /
    ````
    
6. Get all records from Cats collection.
    
    ````
    SODA get CATS -all
    
    Collection keys could not be found. 
    No such collection: CATS 
    ````
    
7. Collection names used in SODA APIs are case sensitive. Use the correct name of the collection.
    
    ````
    SODA get Cats -all
    
    144 rows selected.
    ````
    
8. Same detail has to be considered when querying the corresponding table, using double quotes in this case. 
    
    ````
    select ID, json_serialize(JSON_DOCUMENT pretty) document from "Cats"
    ````
    
## Task 2: Retrieve individual fields from JSON documents
    
1. Select one document to view the fields.
    
    ````
    SELECT JSON_Serialize(
             c.JSON_DOCUMENT pretty
           ) oneCat
    FROM "Cats" c where rownum = 1;
    
    ONECAT                                                                                                                                                                                            
    -------------------------------------------------------- 
    {
      "item" :
      {
        "type" : "uri",
        "value" : "http://www.wikidata.org/entity/Q11290753"
      },
      "itemLabel" :
      {
        "xml:lang" : "en",
        "type" : "literal",
        "value" : "Emily"
      }
    }
    ````
    
2. Run a dot-notation query to get values from two of the fields in the JSON documents.
    
    ````
    select c.JSON_DOCUMENT.itemLabel.value catName, 
           c.JSON_DOCUMENT.item.value catURL 
    from "Cats" c;
    
    ...
    FÃ©licette
    ...
    ````
    
3. Some of the cats have names with accented vowels, and these are not displayed correctly. We need ton convert the Unicode 5.0 Universal character set UTF-8 encoding form into ISO 8859-1 West European 8-bit character set.
    
    ````
    select convert(c.JSON_DOCUMENT.itemLabel.value,'WE8ISO8859P1','AL32UTF8') catName, 
           c.JSON_DOCUMENT.item.value catURL 
    from "Cats" c;
    
    ...
    Félicette
    ...
    ````
    
## Task 3: Join JSON fields with relational data
    
1. Create a new table that will be used to store relational structured data.
    
    ````
    CREATE TABLE "CATFOOD"
    ("ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOT NULL ENABLE,
    "BRAND" VARCHAR2(255) NOT NULL ENABLE,
    "NAME" VARCHAR2(255) NOT NULL ENABLE,
    "CAT_ID" VARCHAR2(255),
    CONSTRAINT "CATFOOD_ID_PK" PRIMARY KEY ("ID")
    );
    ````
    
2. This query is used to generate 144 cat food names for our pet shop online business.
    
    ````
    select rownum, 'PetShop' brand, A.one || B.two || C.three || D.four name from
    (select column_value one from table(sys.dbms_debug_vc2coll('Diet', 'Dry', 'Vegan', 'Energy'))) A
    CROSS JOIN
    (select column_value two from table(sys.dbms_debug_vc2coll('Fish ', 'Meat ', 'Milk '))) B
    CROSS JOIN
    (select column_value three from table(sys.dbms_debug_vc2coll('Meow', 'Feline', 'Kitty', 'Whiskers'))) C
    CROSS JOIN
    (select column_value four from table(sys.dbms_debug_vc2coll('Snacks', 'Treats', 'Chews'))) D;
    ````
    
3. Cat food relational data is joined with unstructured information we extract from JSON documents.
    
    ````
    select rownum, c.ID from "Cats" c;
    ````
    
4. Resulted records can be stored in a materialized view, or inserted in a table.

    ````    
    -- Generate 144 food names for every cat

    insert into CATFOOD (BRAND, NAME, CAT_ID)
    select f.brand, f.name, c.CID 
      from ( select rownum id, 'PetShop' brand, A.one || B.two || C.three || D.four name from
              (select column_value one from 
                table(sys.dbms_debug_vc2coll('Diet', 'Dry', 'Vegan', 'Energy'))) A
              CROSS JOIN
              (select column_value two from 
                table(sys.dbms_debug_vc2coll('Fish ', 'Meat ', 'Milk '))) B
              CROSS JOIN
              (select column_value three from 
                table(sys.dbms_debug_vc2coll('Meow', 'Feline', 'Kitty', 'Whiskers'))) C
              CROSS JOIN
              (select column_value four from 
                table(sys.dbms_debug_vc2coll('Snacks', 'Treats', 'Chews'))) D 
           ) f, (select rownum RID, id CID  from "Cats") c
      where f.id = c.RID;
    
    144 rows inserted.
    ````
    
5. Verify all records were created successfully.
    
    ````
    select * from CATFOOD;
    ````
    
6. `ID` fields we extracted from JSON documents and inserted into `CATFOOD` are considered relational data now. We can join JSON document fields with relational data again, using that column as the matching key.
    
    ````
    select c.ID catId,
           convert(c.JSON_DOCUMENT.itemLabel.value,'WE8ISO8859P1','AL32UTF8') catName, 
           cf.BRAND foodBrand,
           cf.NAME foodName
    from "Cats" c inner join CATFOOD cf
      on c.ID = cf.CAT_ID;
    ````
    
## Acknowledgements
    
- **Author** - Valentin Leonard Tabacaru
- **Last Updated By/Date** - Valentin Leonard Tabacaru, Principal Product Manager, DB Product Management, Sep 2020
