# Oracle RESTful Data Services (ORDS)
    
## Introduction
    
Oracle REST Data Services (ORDS) bridges HTTPS and your Oracle Database. A mid-tier Java application, ORDS provides a Database Management REST API, a web interface for working with your database (SQL Developer Web), the ability to create your own REST APIs, and a PL/SQL Gateway. In addition, ORDS provides a REST interface for your Oracle Database 19c JSON Document Store.
    
Oracle REST Data Services is a Java Enterprise Edition (Java EE) based data service that provides enhanced security, file caching features, and RESTful Web Services. Oracle REST Data Services also increases flexibility through support for deployment in standalone mode, as well as using servers like Oracle WebLogic Server and Apache Tomcat.

Estimated Lab Time: 45 minutes
    
## Task 1: Register schema with ORDS
    
1. On Tools tab, under Oracle Application Express, click **Open APEX**.
    
2. Copy link from browser in your notes:
    
    https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/f?p=4500:1000
    
    - Workspace: demo
    - Username: demo
    - Pasword: DBlearnPTS#20_
    
3. **Sign In**.
    
4. Access SQL Workshop > **RESTful Services**.
    
    *Schema not registered with ORDS
    This schema has not been registered with ORDS RESTful Data Services. To register this schema click Register Schema with ORDS.
    Enable Authorization Required for Metadata Access. Click Save Schema Attributes.
    Schema enabled for use with ORDS RESTful Services and sample RESTful Service successfully installed.*
    
5. Expand Modules > oracle.example.hr. Select **employees/**. Copy Full URL and paste in a new bowser tab:
     
    https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/momo/hr/employees/
    
6. A JSON document listing all employees is displayed. Close this browser tab, and go back to ORDS RESTful Services modules.
    
7. Expand **employees/** and review **GET** Handler Definition. Review Source query.
    
8. At this moment, no authentication is required to retrieve data via ORDS. Click **oracle.example.hr** under Modules. Review Resource Templates Protected by Privilege column: Template not protected by any privilege.
    
## Task 2: Create a new ORDS module
    
1. Create a new ORDS module to provide remote access to our Pet Shop data via REST APIs. Click Modules. Click **Create Module**.
    
    - Module Name: demo.catfood
    - Base Path: /cats/
    
2. **Create Module**.
    
3. Create a new ORDS template inside the new module to list our Pet Shop cat food items. Under Resource Templates, click **Create Template**.
    
    - URI Template: catfood/
    
4. **Create Template**.
    
5. Create a new handler that can be used to retrieve data using HTTP GET method. Under Resource Handlers, click **Create Handler**.
    
    - Method: GET
    - Source Type: Collection query
    - Pagination Size: 10
    - Source: `select id, brand, name, cat_id from catfood`
    
6. **Create Handler**.
    
7. Verify your new module, template, and handler are working properly. Copy Full URL value and paste in a new bowser tab:
    
    https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/ 
    
8. Verify pagination is working properly. Click last URL from JSON document for next page: 
    
    https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/?offset=10 
    
9. If JSON documents are displayed correctly in your browser, it means ORDS works and your new Pet Shop module is ready.
    
## Task 3: Provision ADW to be used as client
    
1. Login to OCI Console, to create a new Autonomous Data Warehouse (ADW) instance. Click on hamburger menu ≡, then **Autonomous Data Warehouse** under Oracle Database. **Create Autonomous Database**.
    
    - Select a compartment: [Your Compartment]
    - Display name: [Your Initials]-ADW (e.g. VLT-ADW)
    - Database name: [Your Initials]ADW (e.g. VLTADW)
    - Choose a workload type: Data Warehouse
    - Choose a deployment type: Serverless
    - Choose database version: 19c
    - OCPU count: 1
    - Storage (TB): 1
    - Auto scaling: enabled
    
2. Under Create administrator credentials:
    
    - Password: DBlearnPTS#20_
    
3. Under Choose network access:
    
    - Access Type: Allow secure access from everywhere
    
    - Choose a license type: Bring Your Own License (BYOL)
    
4. **Create Autonomous Database**.
    
5. Wait for Lifecycle State to become Available.
    
6. Open SQL Developer Web on Tools tab, and login to ADW as ADMIN user.
    
    https://kndl0dsxmmt29t1-vltadw.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/_sdw/?nav=worksheet
    
    - Username: admin
    - Password: DBlearnPTS#20_
    
## Task 4: Create ACL for ADMIN to Catfood
    
1. Your new ADW instance requires an Access Control List (ACL) to be able to connect to your AJD instance via HTTP (or HTTPS). If you omit this step, you will receive the following error:
    
    ````
    ORA-29273: HTTP request failed ORA-24247: network access denied by access control list (ACL)
    ````
    
2. Create the ACL in ADW as ADMIN user.
    
    ````
    BEGIN
      DBMS_NETWORK_ACL_ADMIN.append_host_ace (
        host       => 'kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com',
        ace        => xs$ace_type(privilege_list => xs$name_list('http','connect','resolve'),
                                  principal_name => 'ADMIN',
                                  principal_type => xs_acl.ptype_db));
    END;
    /
    ````
    
## Task 5: Retrieve AJD Catfood records via REST
    
1. From ADW, send a request to AJD to provide Catfood records via REST.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
    BEGIN
      utl_http.set_wallet('');
    
      vcRequestBody := 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/';
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
      
      utl_http.read_text(httpResp, vcBuffer);
      utl_http.end_response(httpResp);
    
      dbms_output.put_line(vcBuffer);
    END;
    ````
    
2. This is the answer provided by AJD, in JSON format:
    
    ````
    {"items":[{"id":1,"brand":"PetShop","name":"DietFish
    MeowSnacks","cat_id":"64D44979B6EC4F55BF7DDA60BD485E03"},{"id":2,"brand":"PetSho
    p","name":"DietFish
    MeowTreats","cat_id":"29005EC062AE4F1DBFB681EBF8FB1768"},{"id":3,"brand":"PetSho
    p","name":"DietFish
    MeowChews","cat_id":"BEC6C1F860854F27BF68BF938D2CD844"},{"id":4,"brand":"PetShop
    ","name":"DietFish
    FelineSnacks","cat_id":"925AC22540154F5ABF3678CE864FB430"},{"id":5,"brand":"PetS
    hop","name":"DietFish
    FelineTreats","cat_id":"C3CC91ABFA944FEEBF893404511C756C"},{"id":6,"brand":"PetS
    hop","name":"DietFish
    FelineChews","cat_id":"968D797BB0B44FE4BFA89CAA4F0EB6B5"},{"id":7,"brand":"PetSh
    op","name":"DietFish
    KittySnacks","cat_id":"DC8AD22C21414F32BFF20E9A4586D8C4"},{"id":8,"brand":"PetSh
    op","name":"DietFish
    KittyTreats","cat_id":"348F312DC7E34FCCBF159FEA348E40B9"},{"id":9,"brand":"PetSh
    op","name":"DietFish
    KittyChews","cat_id":"4F0613C37B004FE2BF61E9FA71FA2D0F"},{"id":10,"brand":"PetSh
    op","name":"DietFish
    WhiskersSnacks","cat_id":"15D421E3FC164F11BFAEAE0D83178C95"}],"hasMore":true,"li
    mit":10,"offset":0,"count":10,"links":[{"rel":"self","href":"https://kndl0dsxmmt
    29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/"},{"rel
    ":"describedby","href":"https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecl
    oudapps.com/ords/demo/metadata-catalog/cats/catfood/"},{"rel":"first","href":"ht
    tps://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats
    /catfood/"},{"rel":"next","href":"https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-
    1.oraclecloudapps.com/ords/demo/cats/catfood/?offset=10"}]}
    ````
    
    >**Note** : Please note this is just the first page from the cat food records list, with the first 10 items.
    
3. You can use `JSON_SERIALIZE` function to display the response in a pretty format.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
    BEGIN
      utl_http.set_wallet('');
    
      vcRequestBody := 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/';
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
      
      utl_http.read_text(httpResp, vcBuffer);
      utl_http.end_response(httpResp);
      
      SELECT json_serialize(
             c.JSON_DOCUMENT pretty
           ) into vcBuffer
      FROM (select vcBuffer JSON_DOCUMENT from dual) c;
      
      dbms_output.put_line(vcBuffer);
    END;
    ````
    
4. This is a nicer output. However, formatting the JSON document is not necessary for two database instances communicating via REST calls.
    
    ````
    {
      "items" :
      [
        {
          "id" : 1,
          "brand" : "PetShop",
          "name" : "DietFish MeowSnacks",
          "cat_id" : "64D44979B6EC4F55BF7DDA60BD485E03"
        },
        {
          "id" : 2,
          "brand" : "PetShop",
          "name" : "DietFish MeowTreats",
          "cat_id" : "29005EC062AE4F1DBFB681EBF8FB1768"
        },
        {
          "id" : 3,
          "brand" : "PetShop",
          "name" : "DietFish MeowChews",
          "cat_id" : "BEC6C1F860854F27BF68BF938D2CD844"
        },
        {
          "id" : 4,
          "brand" : "PetShop",
          "name" : "DietFish FelineSnacks",
          "cat_id" : "925AC22540154F5ABF3678CE864FB430"
        },
        {
          "id" : 5,
          "brand" : "PetShop",
          "name" : "DietFish FelineTreats",
          "cat_id" : "C3CC91ABFA944FEEBF893404511C756C"
        },
        {
          "id" : 6,
          "brand" : "PetShop",
          "name" : "DietFish FelineChews",
          "cat_id" : "968D797BB0B44FE4BFA89CAA4F0EB6B5"
        },
        {
          "id" : 7,
          "brand" : "PetShop",
          "name" : "DietFish KittySnacks",
          "cat_id" : "DC8AD22C21414F32BFF20E9A4586D8C4"
        },
        {
          "id" : 8,
          "brand" : "PetShop",
          "name" : "DietFish KittyTreats",
          "cat_id" : "348F312DC7E34FCCBF159FEA348E40B9"
        },
        {
          "id" : 9,
          "brand" : "PetShop",
          "name" : "DietFish KittyChews",
          "cat_id" : "4F0613C37B004FE2BF61E9FA71FA2D0F"
        },
        {
          "id" : 10,
          "brand" : "PetShop",
          "name" : "DietFish WhiskersSnacks",
          "cat_id" : "15D421E3FC164F11BFAEAE0D83178C95"
        }
      ],
      "hasMore" : true,
      "limit" : 10,
      "offset" : 0,
      "count" : 10,
      "links" :
      [
        {
          "rel" : "self",
          "href" :
    "https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/c
    ats/catfood/"
        },
        {
          "rel" : "describedby",
          "href" :
    "https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/m
    etadata-catalog/cats/catfood/"
        },
        {
          "rel" : "first",
          "href" :
    "https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/c
    ats/catfood/"
        },
        {
          "rel" : "next",
          "href" :
    "https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/c
    ats/catfood/?offset=10"
        }
      ]
    }
    ````
    
5. Select individual JSON items with the `JSON_TABLE` function.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
    BEGIN
      utl_http.set_wallet('');
    
      vcRequestBody := 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/';
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
      
      utl_http.read_text(httpResp, vcBuffer);
      utl_http.end_response(httpResp);
    
      for cf in ( select jt.catfood from (select vcBuffer JSON_DOCUMENT from dual) c,
        JSON_TABLE(c.JSON_DOCUMENT, '$.items[*]' COLUMNS
          (catfood VARCHAR2(4000) FORMAT JSON PATH '$' )) AS jt ) loop  
      dbms_output.put_line('Catfood Item: ' || cf.catfood);
      end loop;
    END;
    ````
    
6. These are individual cat food items, also in JSON format.
    
    ````
    Catfood Item: {"id":1,"brand":"PetShop","name":"DietFish
    MeowSnacks","cat_id":"64D44979B6EC4F55BF7DDA60BD485E03"}
    Catfood Item: {"id":2,"brand":"PetShop","name":"DietFish
    MeowTreats","cat_id":"29005EC062AE4F1DBFB681EBF8FB1768"}
    Catfood Item: {"id":3,"brand":"PetShop","name":"DietFish
    MeowChews","cat_id":"BEC6C1F860854F27BF68BF938D2CD844"}
    Catfood Item: {"id":4,"brand":"PetShop","name":"DietFish
    FelineSnacks","cat_id":"925AC22540154F5ABF3678CE864FB430"}
    Catfood Item: {"id":5,"brand":"PetShop","name":"DietFish
    FelineTreats","cat_id":"C3CC91ABFA944FEEBF893404511C756C"}
    Catfood Item: {"id":6,"brand":"PetShop","name":"DietFish
    FelineChews","cat_id":"968D797BB0B44FE4BFA89CAA4F0EB6B5"}
    Catfood Item: {"id":7,"brand":"PetShop","name":"DietFish
    KittySnacks","cat_id":"DC8AD22C21414F32BFF20E9A4586D8C4"}
    Catfood Item: {"id":8,"brand":"PetShop","name":"DietFish
    KittyTreats","cat_id":"348F312DC7E34FCCBF159FEA348E40B9"}
    Catfood Item: {"id":9,"brand":"PetShop","name":"DietFish
    KittyChews","cat_id":"4F0613C37B004FE2BF61E9FA71FA2D0F"}
    Catfood Item: {"id":10,"brand":"PetShop","name":"DietFish
    WhiskersSnacks","cat_id":"15D421E3FC164F11BFAEAE0D83178C95"}
    ````

## Task 6: Store first 10 records from AJD locally on ADW
    
1. Create a table called `CATFOOD_R` in ADW to store data retrieved from AJD.
    
    ````
    CREATE TABLE "CATFOOD_R"
    ("ID" NUMBER NOT NULL ENABLE,
    "BRAND" VARCHAR2(255) NOT NULL ENABLE,
    "NAME" VARCHAR2(255) NOT NULL ENABLE,
    "CAT_ID" VARCHAR2(255),
    CONSTRAINT "CATFOOD_ID_PK" PRIMARY KEY ("ID")
    );
    ````
    
2. Extract fields from individual JSON items for the first page we retrieved. We added a `DELETE` line in the procedure to clean the table before all data is inserted, avoiding redundant information.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
    BEGIN
      utl_http.set_wallet('');
    
      delete from CATFOOD_R;
    
      vcRequestBody := 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/';
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
      
      utl_http.read_text(httpResp, vcBuffer);
      utl_http.end_response(httpResp);
    
      for cf in ( select jt.* from (select vcBuffer JSON_DOCUMENT from dual) c,
        JSON_TABLE(c.JSON_DOCUMENT, '$.items[*]' 
          COLUMNS (row_number FOR ORDINALITY,
                   id NUMBER PATH '$.id',
                   brand VARCHAR(255) PATH '$.brand',
                   name VARCHAR(255) PATH '$.name',
                   cat_id VARCHAR(255) PATH '$.cat_id')
        ) AS jt ) loop
     
        dbms_output.put_line('RowNum: ' || cf.row_number || ' Id: ' || cf.id || ' Brand: ' || cf.brand || ' Name: ' || cf.name || ' Cat Id: ' || cf.cat_id);
        insert into CATFOOD_R values (cf.id, cf.brand, cf.name, cf.cat_id);
    
      end loop;
      commit;
    END;
    ````
    
3. Verify that these 10 rows from the first page are stored correctly.
    
    ````
    select * from CATFOOD_R;
    ````
    
## Task 7: Read all records from AJD via REST
    
1. Now we can read all pages and insert data into `CATFOOD_R` table. This procedure verifies if there is a next page link, and if true, it makes new requests in a loop, until no next page is retrieved.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
      vcRelNext varchar2(1) := 'Y';
    BEGIN
      utl_http.set_wallet('');
      
      delete from CATFOOD_R;
    
      vcRequestBody := 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/cats/catfood/';
      
      while vcRelNext = 'Y' loop
      
        httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
        utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
        utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
        httpResp := utl_http.get_response(httpReq);
      
        utl_http.read_text(httpResp, vcBuffer);
        utl_http.end_response(httpResp);
      
        for cf in ( select jt.* from (select vcBuffer JSON_DOCUMENT from dual) c,
          JSON_TABLE(c.JSON_DOCUMENT, '$.items[*]' 
            COLUMNS (row_number FOR ORDINALITY,
                     id NUMBER PATH '$.id',
                     brand VARCHAR(255) PATH '$.brand',
                     name VARCHAR(255) PATH '$.name',
                     cat_id VARCHAR(255) PATH '$.cat_id')
          ) AS jt ) loop
     
          dbms_output.put_line('RowNum: ' || cf.row_number || ' Id: ' || cf.id || ' Brand: ' 
                              || cf.brand || ' Name: ' || cf.name || ' Cat Id: ' || cf.cat_id);
          insert into CATFOOD_R values (cf.id, cf.brand, cf.name, cf.cat_id);
    
        end loop;
      
      begin
      select jt.href into vcRequestBody from (select vcBuffer JSON_DOCUMENT from dual) c,
          JSON_TABLE(c.JSON_DOCUMENT, '$.links[*]' 
            COLUMNS (rel VARCHAR(40) PATH '$.rel',
                     href VARCHAR(255) PATH '$.href')
          ) AS jt where jt.rel = 'next';
      exception WHEN NO_DATA_FOUND THEN vcRequestBody := 'none';
      end;
    
      dbms_output.put_line('Next page: ' || vcRequestBody);
    
      if vcRequestBody = 'none' then
        vcRelNext := 'N';
      end if;
      
      end loop;      
      commit;
    END;
    ````
    
2. Verify all 144 rows have been retrieved from AJD, and properly inserted in the local table in ADW instance.
    
    ````
    select * from CATFOOD_R;
    ````
    
## Acknowledgements
    
- **Author** - Valentin Leonard Tabacaru
- **Last Updated By/Date** - Valentin Leonard Tabacaru, Principal Product Manager, DB Product Management, Sep 2020
