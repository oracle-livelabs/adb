# User Authentication for ORDS
    
## Introduction
    
It is not wise to allow public access to your web services. Therefore we need to protect access to all RESTful Services.
    
ORDS, including SODA for REST, uses role-based access control, to secure services. ORDS supports many different authentication mechanisms. JSON document store REST services are intended to be used in server-to-server interactions. Therefore, two-legged OAuth (the client-credentials flow) is the recommended authentication mechanism to use with the JSON document store REST services. However, other mechanisms such as HTTP basic authentication, are also supported.
    
These are the two kinds of authentication supported by RESTful Services:
    
- First Party Authentication. This is authentication intended to be used by the party who created the RESTful Service, enabling an APEX application to easily consume a protected RESTful Service. The application must be located with the RESTful Service, i.e. it must be located in the same Oracle Application Express workspace. The application must use the standard Oracle Application Express authentication.
- Third Party Authentication. This is authentication intended to be used by third party applications not related to the party who created the RESTful Service. Third party authentication relies on the OAuth 2.0 protocol.

Estimated Lab Time: 15 minutes
    
## Task 1: Create new ORDS service with authentication
    
1. Open SQL Developer Web on Tools tab, and login to AJD as DEMO user.
    
    https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/_sdw/?nav=worksheet
    
    - Username: demo
    - Password: DBlearnPTS#20_
    
2. Create new ORDS service using a PL/SQL block of code.
    
    ````
    BEGIN
    ords.create_service(
          p_module_name => 'demo.auth-catfood' ,
          p_base_path  => '/auth-cats/',
          p_pattern =>  'catfood/' ,
          p_items_per_page => 10,
          p_source  =>  'select id, brand, name, cat_id from catfood');
    commit;
    END;
    ````
    
3. Create a new Oracle REST Data Services role using `CREATE_ROLE` function. At the same time, create a new privilege, too. After the role is created, it can be associated with any Oracle REST Data Services privilege. We associate it with the new **demo.auth-catfood-priv** privilege.
    
    ````
    BEGIN
      ords.create_role('Cat Admin');     
     
      ords.create_privilege(
          p_name => 'demo.auth-catfood-priv',
          p_role_name => 'Cat Admin',
          p_label => 'Cat Food Data',
          p_description => 'Provide access to cat food brand and name data');
      commit;
    END;
    ````
    
4. Create a new privilege mapping for your JSON document store, so users can no longer access the web service without authentication.
    
    ````
    BEGIN
     ords.create_privilege_mapping(
          p_privilege_name => 'demo.auth-catfood-priv',
          p_pattern => '/auth-cats/catfood/*');     
      commit;
    END;
    ````
    
5. The code we run has the effect that, by default, a user must have the application-server role **Cat Admin** to access the JSON document store **catfood** collection. Create an OAuth client registration, called **Cat Client Credentials**.
    
    ````
    BEGIN 
     oauth.create_client(
          p_name => 'Cat Client Credentials',
          p_grant_type => 'client_credentials',
          p_privilege_names => 'demo.auth-catfood-priv',
          p_support_email => 'support@example.com');
     commit;
    END;
    ````
    
6. Grant your **Cat Client Credentials** OAuth client the specified **Cat Admin** role, enabling this client to perform two-legged OAuth to access privileges requiring the role.
    
    ````
    BEGIN 
     oauth.grant_client_role(
         'Cat Client Credentials',
         'Cat Admin');
     commit;
    END;
    ````
    
7. Copy Full URL of your JSON document store **catfood** collection and paste in a new bowser tab to test the new secure configuration.
    
    https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/auth-cats/catfood/
    
8. You should receive this message:
    
    > **401 Unauthorized**
    
9. Try the same connection from Cloud Shell:
    
    ````
    curl -i -k https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/auth-cats/catfood/ | grep 401
    ````
    
10. Same message will be received.
    
## Task 2: Authenticate to new ORDS service with token
    
1. Open SQL Developer Web on Tools tab, and login to AJD as DEMO user. Retrieve your OAuth client registration details from `USER_ORDS_CLIENTS` view. These fields are required to request an authentication token for the client.
    
    ````
    select client_id, client_secret from user_ords_clients where name = 'Cat Client Credentials';
    ````
    
2. Use Cloud Shell to request the authentication token. User `--user <client_id>:<client_secret>` you retrieved from the previous query.
    
    ````
    curl -i --user S3t0Of0Ss98_6RWZFfTWjA..:R54mUH7ovnTWbTmA3CqKrA.. --data "grant_type=client_credentials" https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/oauth/token
    
    {"access_token":"ANsWPB_IKwh50_n13pYXEA","token_type":"bearer","expires_in":3600}
    ````
    
3. Use the authentication token to connect to the web service and access the JSON document store **catfood** collection.
    
    ````
    curl -i -H "Authorization: Bearer ANsWPB_IKwh50_n13pYXEA" https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/auth-cats/catfood/
    ````
    
4. We can do the same from PL/SQL. Open SQL Developer Web on Tools tab, and login to ADW as ADMIN user.
    
    https://kndl0dsxmmt29t1-vltadw.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/_sdw/?nav=worksheet
    
    - Username: admin
    - Password: DBlearnPTS#20_
    
5. Try to connect to the web service and access the JSON document store **catfood** collection from AJD with NO authentication.
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
    BEGIN
      utl_http.set_wallet('');
    
      vcRequestBody := 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/auth-cats/catfood/';
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      
      httpResp := utl_http.get_response(httpReq);
      
      utl_http.read_text(httpResp, vcBuffer);
      utl_http.end_response(httpResp);
      
      SELECT JSON_Serialize(
             c.JSON_DOCUMENT pretty
           ) into vcBuffer
      FROM (select vcBuffer JSON_DOCUMENT from dual) c;
      
      dbms_output.put_line(vcBuffer);
    END;
    ````
    
6. It fails, and the same message is received.
    
    ````
    ...
    <title>Unauthorized</title>
    ...
    401
    ...
    Unauthorized
    ...
    Access to this resource is protected. Please <a
    href="https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/d
    emo/sign-in/?r=auth-cats%2Fcatfood%2F" style="font-weight: 500;">sign in</a> to
    access this resource.
    ...
    ````
    
7. We need to add some extra steps to our PL/SQL code for the authentication.
    
## Task 3: Use authentication token in PL/SQL to retrieve data
    
1. Connect to the web service and access the JSON document store **catfood** collection from AJD with authentication. `APEX_WEB_SERVICE.OAUTH_AUTHENTICATE` procedure performs OAUTH autentication and requests an OAuth access token. `APEX_WEB_SERVICE.OAUTH_GET_LAST_TOKEN` function returns the OAuth access token received in the last `OAUTH_AUTHENTICATE` call. Returns NULL when the token is already expired or `OAUTH_AUTHENTICATE` has not been called.  
    
    ````
    DECLARE
      vcRequestBody clob;
      httpReq  utl_http.req;
      httpResp utl_http.resp;
      vcBuffer clob;
      vcToken varchar2(255);
    BEGIN
      utl_http.set_wallet('');
      
      apex_web_service.oauth_authenticate(p_token_url => 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/oauth/token',
                                         p_client_id => 'S3t0Of0Ss98_6RWZFfTWjA..',
                                         p_client_secret => 'R54mUH7ovnTWbTmA3CqKrA..',
                                         p_wallet_path => '');
      vcToken:= apex_web_service.oauth_get_last_token;
    
    
      vcRequestBody := 'https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/auth-cats/catfood/';
      
      httpReq := utl_http.begin_request (vcRequestBody, 'GET','HTTP/1.1');
      utl_http.set_header(httpReq, 'User-Agent', 'Mozilla/4.0');
      utl_http.set_header(httpReq, 'Accept', 'application/sparql-results+json');
      utl_http.set_header(httpReq, 'Authorization', 'Bearer ' || vcToken);
      
      httpResp := utl_http.get_response(httpReq);
      
      utl_http.read_text(httpResp, vcBuffer);
      utl_http.end_response(httpResp);
      
      dbms_output.put_line(vcBuffer);
    END;
    ````
    
2. The code will retrieve the first 10 items in a JSON document.
    
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
    29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords/demo/auth-cats/catfood/"},
    {"rel":"describedby","href":"https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.ora
    clecloudapps.com/ords/demo/metadata-catalog/auth-cats/catfood/"},{"rel":"first",
    "href":"https://kndl0dsxmmt29t1-vltajd.adb.eu-frankfurt-1.oraclecloudapps.com/ords
    /demo/auth-cats/catfood/"},{"rel":"next","href":"https://kndl0dsxmmt29t1-vltajd.ad
    b.eu-frankfurt-1.oraclecloudapps.com/ords/demo/auth-cats/catfood/?offset=10"}]}
    ````
    
## Acknowledgements
    
- **Author** - Valentin Leonard Tabacaru
- **Last Updated By/Date** - Valentin Leonard Tabacaru, Principal Product Manager, DB Product Management, Sep 2020
