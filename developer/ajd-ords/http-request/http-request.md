# Retrieve Data from Web Service
    
## Introduction
    
The `UTL_HTTP` package makes Hypertext Transfer Protocol (HTTP) callouts from SQL and PL/SQL. You can use it to access data on the Internet over HTTP.
    
When the package fetches data from a Web site using HTTPS, it requires Oracle Wallet Manager which can be created by either Oracle Wallet Manager or the orapki utility. Non-HTTPS fetches do not require an Oracle wallet.

Estimated Lab Time: 30 minutes
    
## Task 1: Retrieve query results from Wikidata
    
1. Login SQL Deveveloper Web as DEMO user. Use the existing browser tab, or a direct link. For the direct link, use SQL Developer Web link copied from browser in the previous section, and change 'admin' with 'demo'.
    
    https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/_sdw/?nav=worksheet
    
    - Username: demo
    - Password: DBlearnPTS#20_
    
2. Run this procedure to test Wikidata API from SQL Developer Web SQL Worksheet:
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
    BEGIN
      utl_http.set_wallet('');
    
      vcRequestBody := utl_url.escape('#Cats
    SELECT ?item ?itemLabel 
    WHERE 
    {
      ?item wdt:P31 wd:Q146.
      SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    }', TRUE);
    
      vcRequestBody := 'https://query.wikidata.org/sparql?query=' || vcRequestBody;
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
      
      utl_http.read_text(httpResp, vcBuffer);
      utl_http.end_response(httpResp);
    
      dbms_output.put_line(vcBuffer);
    END;
    ````
    
3. URLs can only be sent over the Internet using the ASCII character-set. Since URLs often contain characters outside the ASCII set, the URL has to be converted into a valid ASCII format. URL encoding replaces unsafe ASCII characters with a "%" followed by two hexadecimal digits. URLs cannot contain spaces or next lines. 
    
4. `UTL_URL.ESCAPE` function is used to convert the SPARQL query into the URL format required by the `UTL_HTTP` package.
    
5. Our code will retrieve a JSON document with a list of all known cats in the world, however it is incomplete because the `UTL_HTTP.READ_TEXT` buffer is smaller than the document.
    
## Task 2: Retrieve JSON document line by line
    
1. For big JSON documents, it is a good idea to retrieve them line by line, using a loop cycle. In this case we print the lines in the loop cycle as they are retrieved.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
    BEGIN
      utl_http.set_wallet('');
    
      vcRequestBody := utl_url.escape('#Cats
    SELECT ?item ?itemLabel 
    WHERE 
    {
      ?item wdt:P31 wd:Q146.
      SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    }', TRUE);
    
      vcRequestBody := 'https://query.wikidata.org/sparql?query=' || vcRequestBody;
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
    
      LOOP
        utl_http.read_line(httpResp, vcBuffer, TRUE);
        dbms_output.put_line(vcBuffer);
      END LOOP;
        
      utl_http.end_response(httpResp);
    
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        utl_http.end_response(httpResp);
    END;
    ````
    
2. Another way is to store the retrieved lines in a local buffer called `entireDoc`, and print the entire document once finished.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
      entireDoc clob;
    BEGIN
      utl_http.set_wallet('');
    
      vcRequestBody := utl_url.escape('#Cats
    SELECT ?item ?itemLabel 
    WHERE 
    {
      ?item wdt:P31 wd:Q146.
      SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    }', TRUE);
    
      vcRequestBody := 'https://query.wikidata.org/sparql?query=' || vcRequestBody;
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
    
      LOOP
        utl_http.read_line(httpResp, vcBuffer, TRUE);
        entireDoc := concat(entireDoc,vcBuffer);
      END LOOP;
        
      utl_http.end_response(httpResp);
    
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        utl_http.end_response(httpResp);
    
    dbms_output.put_line(entireDoc);
    
    END;
    ````
    
3. In the second case, the entire document has all line breaks removed, but they are not important.
    
## Task 3: Insert documents in collections
    
1. Once we have the entire JSON document in a local buffer, we can store it in our collection. Create a new collection called MYJSON. Use SODA APIs to create this new document collection.
    
    ````
    soda create MYJSON
    ````
    
2. Use SODA APIs to list all document collections.
    
    ````
    soda list
    ````
    
3. Run SODA APIs to insert a new document in your collection.
    
    ````
    soda insert MYJSON {
      "business": "Pet Shop",
      "established": 2020,
      "description": "Animal supplies and pet accessories",
      "location": {
        "country": "Spain",
        "city": "Torremolinos",
        "region": "EMEA"
        },
      "products":[
        "treats",
        "food",
        "collars",
        "leashes"
      ]
    }
    
    Failed to execute: soda insert MYJSON { 
    ````
    
4. This last command failed because line breaks are not allowed. When using SODA APIs from SQL Developer Web, you have to write the entire document in one line.
    
    ````
    soda insert MYJSON {"business": "Pet Shop", "established": 2020, "description": "Animal supplies and pet accessories", "location":{ "country": "Spain", "city": "Torremolinos", "region": "EMEA" }, "products":[ "treats", "food", "collars", "leashes" ]}
    
    Json String inserted successfully.
    ````
    
## Task 4: Retrieve documents from collections
    
1. JSON documents can be retrieved with SODA APIs using query-by-example. This method allows you to specify some fields in the document, and will return all documents matching those fields.
    
    ````
    SODA get MYJSON -f {"business": "Pet Shop"}
    ````
    
2. Another way is to retrieve the keys from all documents.
    
    ````
    SODA get MYJSON -all
    ````
    
3. Once you have the key, you can get the entire document matching that key.
    
    ````
    SODA get MYJSON -k 8415920273DB46DF933911B2EF3289F2
    ````
    
4. All collections have a corresponding relational table with the same name. When you query directly the columns of the table in SQL Developer Web, the content of the JSON document is not displayed, because it is stored as BLOB.
    
    ````
    select ID, JSON_DOCUMENT from MYJSON;
    ````
    
5. You need to use `JSON_QUERY` function, with `PRETTY` attribute to display the contents of the JSON document and line breaks. This works in SQL*Plus.
    
    ````
    select ID, json_query(JSON_DOCUMENT, '$' pretty) document from MYJSON;
    ````
    
6. You can do the same in SQL Developer Web, but using JSON_SERIALIZE function.
    
    ````
    select ID, json_serialize(JSON_DOCUMENT pretty) document from MYJSON;
    ````
    
## Task 5: Insert big JSON document in collection
    
1. SODA APIs can be used also from PL/SQL to create, drop, and list document collections. Also to insert documents in collections. We have changes the last part of our precedure to insert that big JSON document retrieved from Wikidata into MYJSON collection.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
      entireDoc clob;
      collection  SODA_COLLECTION_T;
      b_doc  SODA_DOCUMENT_T;
      status  NUMBER;
    BEGIN
      utl_http.set_wallet('');
    
      -- Convert query to ASCII format for URL
      vcRequestBody := utl_url.escape('#Cats
    SELECT ?item ?itemLabel 
    WHERE 
    {
      ?item wdt:P31 wd:Q146.
      SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    }', TRUE);
    
      -- Add query to web service endpoint URL
      vcRequestBody := 'https://query.wikidata.org/sparql?query=' || vcRequestBody;
      
      -- Perform request
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
    
      -- Add every line in the response to entire document
      LOOP
        utl_http.read_line(httpResp, vcBuffer, TRUE);
        entireDoc := concat(entireDoc,vcBuffer);
      END LOOP;
    
      utl_http.end_response(httpResp);
    
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        utl_http.end_response(httpResp);
      
      -- Print entire document  
      dbms_output.put_line(entireDoc);
        
        -- Open the collection
        collection := DBMS_SODA.open_collection('MYJSON');
        -- Create BLOB document
        b_doc := SODA_DOCUMENT_T(
                   b_content => utl_raw.cast_to_raw(entireDoc));
        -- Insert document
        status := collection.insert_one(b_doc);   
    END;
    /
    ````
    
2. Verify a new document has been inserted in the collection.
    
    ````
    SODA get MYJSON -all
    ````
    
3. Use the last key to retrieve the contents of the JSON file, with SODA APIs.
    
    ````
    SODA get MYJSON -k AADAD67676E54F41BF134AC780130E0E
    ````
    
## Acknowledgements
    
- **Author** - Valentin Leonard Tabacaru
- **Last Updated By/Date** - Valentin Leonard Tabacaru, Principal Product Manager, DB Product Management, Sep 2020
