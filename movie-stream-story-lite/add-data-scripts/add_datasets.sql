create or replace procedure add_datasets
as 

    user_name       varchar2(100) := 'moviestream';
    uri_landing     varchar2(1000) := 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_landing/o';
    uri_gold        varchar2(1000) := 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o';
    uri_sandbox     varchar2(1000) := 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_sandbox/o';    
--    uri_sandbox     varchar2(1000) := 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_sandbox/o';    

    csv_format      varchar2(1000) := '{"dateformat":"YYYY-MM-DD", "skipheaders":"1", "delimiter":",", "ignoreblanklines":"true", "removequotes":"true", "blankasnull":"true", "trimspaces":"lrtrim", "truncatecol":"true", "ignoremissingcolumns":"true"}';
    pipe_format     varchar2(1000) := '{"dateformat":"YYYY-MM-DD", "skipheaders":"1", "delimiter":"|", "ignoreblanklines":"true", "removequotes":"true", "blankasnull":"true", "trimspaces":"lrtrim", "truncatecol":"true", "ignoremissingcolumns":"true"}';
    json_format     varchar2(1000) := '{"skipheaders":"0", "delimiter":"\\n", "ignoreblanklines":"true"}';
    parquet_format  varchar2(1000) := '{"type":"parquet",  "schema": "all"}';
    type table_array IS VARRAY(24) OF VARCHAR2(30); 
    table_list table_array := table_array( 'ext_genre',
                                            'ext_movie',
                                            'ext_customer_contact',
                                            'ext_customer_extension',
                                            'ext_customer_promotions',
                                            'ext_customer_segment',
                                            'ext_moviestream_churn',
                                            'ext_pizza_location',
                                            'ext_potential_churners',
                                            'ext_custsales',
                                            'json_movie_data_ext',
                                            'custsales',
                                            'custsales_promotions',
                                            'customer_contact',
                                            'customer_extension',
                                            'customer_promotions',
                                            'customer',
                                            'genre',
                                            'movie',
                                            'moviestream_churn',
                                            'customer_segment',
                                            'pizza_location',
                                            'customer_nearest_pizza',
                                            'time');
    start_time date := sysdate;
    l_found number;



begin   

    -- Start
    moviestream_write ('begin');
    -- initialize
    moviestream_write('** dropping tables **');

    -- Loop over tables and drop if found
    for i in 1 .. table_list.count loop
        begin
            select count(*)
            into l_found
            from user_tables
            where lower(table_name) = table_list(i);

            if l_found > 0 then                
                moviestream_exec ( 'drop table ' || table_list(i), true );
            end if;
        exception
            when others then
                moviestream_write(' - ...... failed to drop table ' || table_list(i));
        end;
    end loop;
    
    moviestream_write('** remove spatial metadata **');
    delete from user_sdo_geom_metadata
    where table_name in ('CUSTOMER_CONTACT','PIZZA_LOCATION');
    commit;


    -- Create a time table  over 2 years.  Used to densify time series calculations
    moviestream_write('** create time table **');

    moviestream_exec ( 'create table time as
    select trunc (to_date(''20210101'',''YYYYMMDD'')-rownum) as day_id
    from dual connect by rownum < 732');

    moviestream_write(' - populate time table');
    moviestream_exec ( 'alter table time
        add (
            day_name as (to_char(day_id, ''fmDAY'')),
            day_dow as ((cast(to_char(day_id, ''fmD'') as number))),
            day_dom as ((cast(to_char(day_id, ''fmDD'') as number))),
            day_doy as ((cast(to_char(day_id, ''fmDDD'') as number))),
            week_wom as ((cast(to_char(day_id, ''fmW'') as number))),
            week_woy as ((cast(to_char(day_id, ''fmWW'') as number))),
            month_moy as ((cast(to_char(day_id, ''fmMM'') as number))),
            month_name as (to_char(day_id, ''fmMONTH'')),
            month_aname as (to_char(day_id, ''fmMON'')),
            quarter_name as (''Q''||to_char(day_id, ''fmQ'')||''-''||to_char(day_id, ''fmYYYY'')),
            quarter_qoy as ((cast(to_char(day_id, ''fmQ'') as number))),
            year_name as ((cast(to_char(day_id, ''fmYYYY'') as number)))
        )');

    -- Using public buckets  so credentials are not required
    -- Create external tables then do a CTAS
    -- BASE DATA SETS
    begin
        moviestream_write(' ** create temporary external tables ** ');
        moviestream_write(' - ext_genre');
        dbms_cloud.create_external_table(
            table_name => 'ext_genre',
            file_uri_list => uri_gold || '/genre/*.csv',
            format => csv_format,
            column_list => 'genre_id number, name varchar2(30)'
            );

        moviestream_write(' - ext_customer_segment');
        dbms_cloud.create_external_table(
            table_name => 'ext_customer_segment',
            file_uri_list => uri_landing || '/customer_segment/*.csv',
            format => csv_format,
            column_list => 'segment_id number, name varchar2(100), short_name varchar2(100)'
            );

        moviestream_write(' - ext_potential_churner');            
        dbms_cloud.create_external_table(
            table_name => 'ext_potential_churners',
            file_uri_list => uri_sandbox || '/potential_churners/*.csv',
            format => csv_format,
            column_list => 'cust_id number, will_churn number, prob_churn number'
            );             

        moviestream_write(' - ext_movie'); 
        dbms_cloud.create_external_table(
            table_name => 'ext_movie',
            file_uri_list => uri_gold || '/movie/*.json',
            format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
            column_list => 'doc varchar2(30000)'
            );

        moviestream_write(' - ext_custsales');
        dbms_cloud.create_external_table(
            table_name => 'ext_custsales',
            file_uri_list => uri_gold || '/custsales/*.parquet',
            format => parquet_format,
            column_list => 'MOVIE_ID NUMBER(20,0),
                            LIST_PRICE BINARY_DOUBLE,
                            DISCOUNT_TYPE VARCHAR2(4000 BYTE),
                            PAYMENT_METHOD VARCHAR2(4000 BYTE),
                            GENRE_ID NUMBER(20,0),
                            DISCOUNT_PERCENT BINARY_DOUBLE,
                            ACTUAL_PRICE BINARY_DOUBLE,
                            DEVICE VARCHAR2(4000 BYTE),
                            CUST_ID NUMBER(20,0),
                            OS VARCHAR2(4000 BYTE),
                            DAY_ID date,
                            APP VARCHAR2(4000 BYTE)'
        ); 

        moviestream_write(' - ext_pizza_location');       
        dbms_cloud.create_external_table(
            table_name => 'ext_pizza_location',
            file_uri_list => uri_landing || '/pizza_location/*.csv',
            format => csv_format,
            column_list => 'PIZZA_LOC_ID NUMBER,
                            LAT NUMBER,
                            LON NUMBER,
                            CHAIN_ID NUMBER,
                            CHAIN VARCHAR2(30 BYTE),
                            ADDRESS VARCHAR2(250 BYTE),
                            CITY VARCHAR2(250 BYTE),
                            STATE VARCHAR2(26 BYTE),
                            POSTAL_CODE VARCHAR2(38 BYTE),
                            COUNTY VARCHAR2(250 BYTE)'
            ); 

        moviestream_write(' - ext_customer_contact');  
        dbms_cloud.create_external_table(
            table_name => 'ext_customer_contact',
            file_uri_list => uri_gold || '/customer_contact/*.csv',
            format => csv_format,
            column_list => 'CUST_ID                  NUMBER,         
                            LAST_NAME                VARCHAR2(200 byte), 
                            FIRST_NAME               VARCHAR2(200 byte), 
                            EMAIL                    VARCHAR2(500 byte), 
                            STREET_ADDRESS           VARCHAR2(400 byte), 
                            POSTAL_CODE              VARCHAR2(10 byte), 
                            CITY                     VARCHAR2(100 byte), 
                            STATE_PROVINCE           VARCHAR2(100 byte), 
                            COUNTRY                  VARCHAR2(400 byte), 
                            COUNTRY_CODE             VARCHAR2(2 byte), 
                            CONTINENT                VARCHAR2(400 byte),
                            YRS_CUSTOMER             NUMBER, 
                            PROMOTION_RESPONSE       NUMBER,         
                            LOC_LAT                  NUMBER,         
                            LOC_LONG                 NUMBER' 

            ); 

        moviestream_write(' - ext_customer_extension');
        dbms_cloud.create_external_table(
            table_name => 'ext_customer_extension',
            file_uri_list => uri_landing || '/customer_extension/*.csv',
            format => csv_format,
            column_list => 'CUST_ID                      NUMBER,         
                            LAST_NAME                    VARCHAR2(200 byte),
                            FIRST_NAME                   VARCHAR2(200 byte), 
                            EMAIL                        VARCHAR2(500 byte),
                            AGE                          NUMBER,         
                            COMMUTE_DISTANCE             NUMBER,         
                            CREDIT_BALANCE               NUMBER,         
                            EDUCATION                    VARCHAR2(40 byte),
                            FULL_TIME                    VARCHAR2(40 byte),
                            GENDER                       VARCHAR2(20 byte), 
                            HOUSEHOLD_SIZE               NUMBER,         
                            INCOME                       NUMBER,         
                            INCOME_LEVEL                 VARCHAR2(20 byte), 
                            INSUFF_FUNDS_INCIDENTS       NUMBER,         
                            JOB_TYPE                     VARCHAR2(200 byte),
                            LATE_MORT_RENT_PMTS          NUMBER,         
                            MARITAL_STATUS               VARCHAR2(8 byte),
                            MORTGAGE_AMT                 NUMBER,         
                            NUM_CARS                     NUMBER,         
                            NUM_MORTGAGES                NUMBER,         
                            PET                          VARCHAR2(40 byte), 
                            RENT_OWN                     VARCHAR2(40 byte), 
                            SEGMENT_ID                   NUMBER,
                            WORK_EXPERIENCE              NUMBER,         
                            YRS_CURRENT_EMPLOYER         NUMBER,         
                            YRS_RESIDENCE                NUMBER'
            );


        moviestream_write(' - ext_customer_promotions');
        dbms_cloud.create_external_table(
            table_name => 'ext_customer_promotions',
            file_uri_list => uri_sandbox || '/customer_promotions/*.csv',
            format => csv_format,
            column_list => 'CUST_ID NUMBER, 
                            LAST_NAME VARCHAR2(200 BYTE), 
                            FIRST_NAME VARCHAR2(200 BYTE), 
                            EMAIL VARCHAR2(500 BYTE), 
                            STREET_ADDRESS VARCHAR2(400 BYTE), 
                            POSTAL_CODE VARCHAR2(10 BYTE), 
                            CITY VARCHAR2(100 BYTE), 
                            STATE_PROVINCE VARCHAR2(100 BYTE), 
                            COUNTRY VARCHAR2(400 BYTE), 
                            COUNTRY_CODE VARCHAR2(2 BYTE), 
                            CONTINENT VARCHAR2(400 BYTE), 
                            YRS_CUSTOMER NUMBER, 
                            PROMOTION_RESPONSE NUMBER, 
                            LOC_LAT NUMBER, 
                            LOC_LONG NUMBER, 
                            AGE NUMBER, 
                            COMMUTE_DISTANCE NUMBER, 
                            CREDIT_BALANCE NUMBER, 
                            EDUCATION VARCHAR2(40 BYTE), 
                            FULL_TIME VARCHAR2(40 BYTE), 
                            GENDER VARCHAR2(20 BYTE), 
                            HOUSEHOLD_SIZE NUMBER, 
                            INCOME NUMBER, 
                            INCOME_LEVEL VARCHAR2(20 BYTE), 
                            INSUFF_FUNDS_INCIDENTS NUMBER, 
                            JOB_TYPE VARCHAR2(200 BYTE), 
                            LATE_MORT_RENT_PMTS NUMBER, 
                            MARITAL_STATUS VARCHAR2(8 BYTE), 
                            MORTGAGE_AMT NUMBER, 
                            NUM_CARS NUMBER, 
                            NUM_MORTGAGES NUMBER, 
                            PET VARCHAR2(40 BYTE), 
                            RENT_OWN VARCHAR2(40 BYTE), 
                            SEGMENT_ID NUMBER, 
                            WORK_EXPERIENCE NUMBER, 
                            YRS_CURRENT_EMPLOYER NUMBER, 
                            YRS_RESIDENCE NUMBER'
            );        

        moviestream_write(' - ext_moviestream_churn');
        dbms_cloud.create_external_table(
            table_name => 'ext_moviestream_churn',
            file_uri_list => uri_sandbox || '/moviestream_churn/*.csv',
            format => csv_format,
            column_list => 'CUST_ID NUMBER, 
                            IS_CHURNER NUMBER, 
                            AGE NUMBER, 
                            CITY VARCHAR2(100 BYTE), 
                            CREDIT_BALANCE NUMBER, 
                            EDUCATION VARCHAR2(40 BYTE), 
                            EMAIL VARCHAR2(500 BYTE), 
                            FIRST_NAME VARCHAR2(200 BYTE), 
                            GENDER VARCHAR2(20 BYTE), 
                            HOUSEHOLD_SIZE NUMBER, 
                            INCOME_LEVEL VARCHAR2(20 BYTE), 
                            JOB_TYPE VARCHAR2(200 BYTE), 
                            LAST_NAME VARCHAR2(200 BYTE), 
                            LOC_LAT NUMBER, 
                            LOC_LONG NUMBER, 
                            MARITAL_STATUS VARCHAR2(8 BYTE), 
                            YRS_CUSTOMER NUMBER, 
                            YRS_RESIDENCE NUMBER, 
                            GENRE_ACTION NUMBER, 
                            GENRE_ADVENTURE NUMBER, 
                            GENRE_ANIMATION NUMBER, 
                            GENRE_BIOGRAPHY NUMBER, 
                            GENRE_COMEDY NUMBER, 
                            GENRE_CRIME NUMBER, 
                            GENRE_DOCUMENTARY NUMBER, 
                            GENRE_DRAMA NUMBER, 
                            GENRE_FAMILY NUMBER, 
                            GENRE_FANTASY NUMBER, 
                            GENRE_FILM_NOIR NUMBER, 
                            GENRE_HISTORY NUMBER, 
                            GENRE_HORROR NUMBER, 
                            GENRE_MUSICAL NUMBER, 
                            GENRE_MYSTERY NUMBER, 
                            GENRE_NEWS NUMBER, 
                            GENRE_REALITY_TV NUMBER, 
                            GENRE_ROMANCE NUMBER, 
                            GENRE_SCI_FI NUMBER, 
                            GENRE_SPORT NUMBER, 
                            GENRE_THRILLER NUMBER, 
                            GENRE_WAR NUMBER, 
                            GENRE_WESTERN NUMBER, 
                            AGG_NTRANS_M3 NUMBER, 
                            AGG_NTRANS_M4 NUMBER, 
                            AGG_NTRANS_M5 NUMBER, 
                            AGG_NTRANS_M6 NUMBER, 
                            AGG_SALES_M3 NUMBER, 
                            AGG_SALES_M4 NUMBER, 
                            AGG_SALES_M5 NUMBER, 
                            AGG_SALES_M6 NUMBER, 
                            AVG_DISC_M3 NUMBER, 
                            AVG_DISC_M3_11 NUMBER, 
                            AVG_DISC_M3_5 NUMBER, 
                            AVG_NTRANS_M3_5 NUMBER, 
                            AVG_SALES_M3_5 NUMBER, 
                            DISC_PCT_DIF_M3_5_M6_11 NUMBER, 
                            DISC_PCT_DIF_M3_5_M6_8 NUMBER, 
                            SALES_PCT_DIF_M3_5_M6_8 NUMBER, 
                            TRANS_PCT_DIF_M3_5_M6_8 NUMBER'
            );        

        moviestream_write('** external tables created. **') ;


        --  Create tables from external tables

        moviestream_write('** create tables from external tables and drop external tables **');
        moviestream_write(' - create pizza_locations');
        moviestream_exec ( 'create table pizza_location as select * from ext_pizza_location');
        moviestream_exec ( 'drop table ext_pizza_location');

        moviestream_write(' - create genre');
        moviestream_exec ( 'create table genre as select * from ext_genre' );
        moviestream_exec ( 'drop table ext_genre' );

        moviestream_write(' - create customer_segment');
        moviestream_exec ( 'create table customer_segment as select * from ext_customer_segment' );
        moviestream_exec ( 'drop table ext_customer_segment' );

        moviestream_write(' - create customer_contact');
        moviestream_exec ( 'create table customer_contact as select * from ext_customer_contact' );
        moviestream_exec ( 'drop table ext_customer_contact' );

        moviestream_write(' - create customer_extension');
        moviestream_exec ( 'create table customer_extension as select * from ext_customer_extension' );
        moviestream_exec ( 'drop table ext_customer_extension' );

        moviestream_write(' - create movie');
        moviestream_exec ( 'create table movie as
            select
                cast(m.doc.movie_id as number) as movie_id,
                cast(m.doc.title as varchar2(200 byte)) as title,   
                cast(m.doc.budget as number) as budget,
                cast(m.doc.gross as number) gross,
                cast(m.doc.list_price as number) as list_price,
                cast(m.doc.genre as varchar2(4000)) as genres,
                cast(m.doc.sku as varchar2(30 byte)) as sku,   
                cast(m.doc.year as number) as year,
                to_date(m.doc.opening_date, ''YYYY-MM-DD'') as opening_date,
                cast(m.doc.views as number) as views,
                cast(m.doc.cast as varchar2(4000 byte)) as cast,
                cast(m.doc.crew as varchar2(4000 byte)) as crew,
                cast(m.doc.studio as varchar2(4000 byte)) as studio,
                cast(m.doc.main_subject as varchar2(4000 byte)) as main_subject,
                cast(m.doc.awards as varchar2(4000 byte)) as awards,
                cast(m.doc.nominations as varchar2(4000 byte)) as nominations,
                cast(m.doc.runtime as number) as runtime,
                substr(cast(m.doc.summary as varchar2(4000 byte)),1, 4000) as summary
            from ext_movie m' );
        moviestream_exec ( 'drop table ext_movie' );     

        moviestream_write(' - create custsales');
        moviestream_exec ( 'create table custsales as select * from ext_custsales' );
        moviestream_exec ( 'drop table ext_custsales' );

        moviestream_write(' - create moviestream_churn');
        moviestream_exec ( 'create table moviestream_churn as select * from ext_moviestream_churn' );
        moviestream_exec ( 'drop table ext_moviestream_churn' );


        -- Table combining the two independent ones
        moviestream_write(' - create combined customer');
        moviestream_exec ( 'create table CUSTOMER
                as
                select  cc.CUST_ID,                
                        cc.LAST_NAME,              
                        cc.FIRST_NAME,             
                        cc.EMAIL,                  
                        cc.STREET_ADDRESS,         
                        cc.POSTAL_CODE,            
                        cc.CITY,                   
                        cc.STATE_PROVINCE,         
                        cc.COUNTRY,                
                        cc.COUNTRY_CODE,           
                        cc.CONTINENT,              
                        cc.YRS_CUSTOMER,           
                        cc.PROMOTION_RESPONSE,     
                        cc.LOC_LAT,                
                        cc.LOC_LONG,               
                        ce.AGE,                    
                        ce.COMMUTE_DISTANCE,       
                        ce.CREDIT_BALANCE,         
                        ce.EDUCATION,              
                        ce.FULL_TIME,              
                        ce.GENDER,                 
                        ce.HOUSEHOLD_SIZE,         
                        ce.INCOME,                 
                        ce.INCOME_LEVEL,           
                        ce.INSUFF_FUNDS_INCIDENTS, 
                        ce.JOB_TYPE,               
                        ce.LATE_MORT_RENT_PMTS,    
                        ce.MARITAL_STATUS,         
                        ce.MORTGAGE_AMT,           
                        ce.NUM_CARS,               
                        ce.NUM_MORTGAGES,          
                        ce.PET,                    
                        ce.RENT_OWN,    
                        ce.SEGMENT_ID,           
                        ce.WORK_EXPERIENCE,        
                        ce.YRS_CURRENT_EMPLOYER,   
                        ce.YRS_RESIDENCE
                from CUSTOMER_CONTACT cc, CUSTOMER_EXTENSION ce
                where cc.cust_id = ce.cust_id' );

        moviestream_write(' - create customer_promotions');
        moviestream_exec ( 'create table customer_promotions as select * from ext_customer_promotions' );
        moviestream_exec ( 'drop table ext_customer_promotions' );   

        moviestream_write(' - create custsales_promotions');
        moviestream_exec ( '
           create table custsales_promotions as
           select *
           from custsales c
           where c.cust_id in (select p.cust_id from customer_promotions p)' );

        -- View combining data
        moviestream_write('** done creating tables from external tables **');
        moviestream_write(' - create view v_custsales');
        moviestream_exec ( 'CREATE OR REPLACE VIEW v_custsales AS
                SELECT
                    cs.day_id,
                    c.cust_id,
                    c.last_name,
                    c.first_name,
                    c.city,
                    c.state_province,
                    c.country,
                    c.continent,
                    c.age,
                    c.commute_distance,
                    c.credit_balance,
                    c.education,
                    c.full_time,
                    c.gender,
                    c.household_size,
                    c.income,
                    c.income_level,
                    c.insuff_funds_incidents,
                    c.job_type,
                    c.late_mort_rent_pmts,
                    c.marital_status,
                    c.mortgage_amt,
                    c.num_cars,
                    c.num_mortgages,
                    c.pet,
                    c.promotion_response,
                    c.rent_own,
                    c.work_experience,
                    c.yrs_current_employer,
                    c.yrs_customer,
                    c.yrs_residence,
                    c.loc_lat,
                    c.loc_long,   
                    cs.app,
                    cs.device,
                    cs.os,
                    cs.payment_method,
                    cs.list_price,
                    cs.discount_type,
                    cs.discount_percent,
                    cs.actual_price,
                    1 as transactions,
                    s.short_name as segment,
                    g.name as genre,
                    m.title,
                    m.budget,
                    m.gross,
                    m.genres,
                    m.sku,
                    m.year,
                    m.opening_date,
                    m.cast,
                    m.crew,
                    m.studio,
                    m.main_subject,
                    nvl(json_value(m.awards,''$.size()''),0) awards,
                    nvl(json_value(m.nominations,''$.size()''),0) nominations,
                    m.runtime
                FROM
                    genre g, customer c, custsales cs, customer_segment s, movie m
                WHERE
                    cs.movie_id = m.movie_id
                AND  cs.genre_id = g.genre_id
                AND  cs.cust_id = c.cust_id
                AND  c.segment_id = s.segment_id' );

        -- Add constraints and indexes
        moviestream_write('** creating constraints and indexes **');

        moviestream_exec ( 'alter table genre add constraint pk_genre_id primary key("GENRE_ID")' );

        moviestream_exec ( 'alter table customer add constraint pk_customer_cust_id primary key("CUST_ID")' );
        moviestream_exec ( 'alter table customer_extension add constraint pk_custextension_cust_id primary key("CUST_ID")' );
        moviestream_exec ( 'alter table customer_contact add constraint pk_custcontact_cust_id primary key("CUST_ID")' );
        moviestream_exec ( 'alter table customer_segment add constraint pk_custsegment_id primary key("SEGMENT_ID")' );

        moviestream_exec ( 'alter table movie add constraint pk_movie_id primary key("MOVIE_ID")' );
        moviestream_exec ( 'alter table movie add CONSTRAINT movie_cast_json CHECK (cast IS JSON)' );
        moviestream_exec ( 'alter table movie add CONSTRAINT movie_genre_json CHECK (genres IS JSON)' );
        moviestream_exec ( 'alter table movie add CONSTRAINT movie_crew_json CHECK (crew IS JSON)' );
        moviestream_exec ( 'alter table movie add CONSTRAINT movie_studio_json CHECK (studio IS JSON)' );
        moviestream_exec ( 'alter table movie add CONSTRAINT movie_awards_json CHECK (awards IS JSON)' );
        moviestream_exec ( 'alter table movie add CONSTRAINT movie_nominations_json CHECK (nominations IS JSON)' );

        moviestream_exec ( 'alter table pizza_location add constraint pk_pizza_loc_id primary key("PIZZA_LOC_ID")' );

        moviestream_exec ( 'alter table time add constraint pk_day primary key("DAY_ID")' );

        moviestream_exec ( 'alter table customer_promotions add constraint customer_promotions_pk primary key(cust_id)' );
        moviestream_exec ( 'alter table custsales_promotions add primary key (cust_id, movie_id, day_id)' );

        -- foreign keys
        moviestream_exec ( 'alter table custsales add constraint fk_custsales_movie_id foreign key("MOVIE_ID") references movie("MOVIE_ID")' );
        moviestream_exec ( 'alter table custsales add constraint fk_custsales_cust_id foreign key("CUST_ID") references customer("CUST_ID")' );
        moviestream_exec ( 'alter table custsales add constraint fk_custsales_day_id foreign key("DAY_ID") references time("DAY_ID")' );
        moviestream_exec ( 'alter table custsales add constraint fk_custsales_genre_id foreign key("GENRE_ID") references genre("GENRE_ID")' );
        moviestream_exec ( 'alter table custsales_promotions add constraint fk_custsales_promotions_cust_id foreign key(cust_id) references customer_promotions(cust_id)' );
        moviestream_exec ( 'alter table custsales_promotions add constraint fk_custsales_promotions_movie_id foreign key(movie_id) references movie(movie_id)' );

        moviestream_write('- finished creating constraints and indexes.');
     end;

     -- ADD SQL-LAB REQUIREMENTS
     begin
        moviestream_write('** adding SQL Lab requirements **');
        moviestream_write('- create view vw_movie_sales_fact');
        moviestream_exec ( 'CREATE OR REPLACE VIEW vw_movie_sales_fact AS
                            SELECT
                            m.day_id,
                            t.day_name,
                            t.day_dow,
                            t.day_dom,
                            t.day_doy,
                            t.week_wom,
                            t.week_woy,
                            t.month_moy,
                            t.month_name,
                            t.month_aname,  
                            t.quarter_name,  
                            t.year_name,  
                            c.cust_id as customer_id,
                            c.state_province,
                            c.country,
                            c.continent,
                            g.name as genre,
                            m.app,
                            m.device,
                            m.os,
                            m.payment_method,
                            m.list_price,
                            m.discount_type,
                            m.discount_percent,
                            m.actual_price,
                            m.genre_id,
                            m.movie_id
                            FROM custsales m
                            INNER JOIN time t ON m.day_id = t.day_id
                            INNER JOIN customer c ON m.cust_id = c.cust_id
                            INNER JOIN genre g ON m.genre_id = g.genre_id' );

        moviestream_write('- create json table');                                            
        dbms_cloud.create_external_table (
            table_name => 'json_movie_data_ext',
            file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/moviestream_gold/o/movie/*.json',
            column_list => 'doc varchar2(32000)',
            field_list => 'doc char(30000)',
            format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true')
            );            

     end;

     -- SPATIAL UPDATES.  DEPENDENT PIZZA_LOCATION AND CUSTOMER_CONTACT TABLES
     -- DEFINED PREVIOUSLY
     begin

        -- function
        moviestream_write('** adding spatial requirements **');
        moviestream_write('- create function latlon_to_geometry');
        moviestream_exec ( '
            CREATE OR REPLACE FUNCTION latlon_to_geometry (
               latitude   IN  NUMBER,
               longitude  IN  NUMBER
            ) RETURN sdo_geometry
               DETERMINISTIC
               IS
               BEGIN
               --first ensure valid lat/lon input
               IF latitude IS NULL OR longitude IS NULL
               OR latitude NOT BETWEEN -90 AND 90
               OR longitude NOT BETWEEN -180 AND 180 THEN
                 RETURN NULL;
               ELSE
               --return point geometry
                RETURN sdo_geometry(
                        2001, --identifier for a point geometry
                        4326, --identifier for lat/lon coordinate system
                        sdo_point_type(
                         longitude, latitude, NULL),
                        NULL, NULL);
               END IF;
               END;
        ' );

        begin
            -- SPATIAL METADATA UPDATES
            moviestream_write('- add spatial metadata');

            insert into user_sdo_geom_metadata values (
             'CUSTOMER_CONTACT',
             user||'.LATLON_TO_GEOMETRY(loc_lat,loc_long)',
              sdo_dim_array(
                  sdo_dim_element('X', -180, 180, 0.05), --longitude bounds and tolerance in meters
                  sdo_dim_element('Y', -90, 90, 0.05)),  --latitude bounds and tolerance in meters
              4326 --identifier for lat/lon coordinate system
                );
             commit;
        exception
            when others then
                moviestream_write(' - unable to update spatial metadata for customer_contact');             
                moviestream_write(' - .... ' || sqlerrm);                 
        end;

        begin        
            insert into user_sdo_geom_metadata values (
             'PIZZA_LOCATION',
             user||'.LATLON_TO_GEOMETRY(lat,lon)',
              sdo_dim_array(
                  sdo_dim_element('X', -180, 180, 0.05),
                  sdo_dim_element('Y', -90, 90, 0.05)),
              4326
               );
               
            commit;
        exception
            when others then
                moviestream_write(' - unable to update spatial metadata for pizza_location');             
                moviestream_write(' - .... ' || sqlerrm);                 
        end;

        -- Add spatial indexes
        begin
            moviestream_write('- create spatial indexes');
            moviestream_exec ( 'CREATE INDEX customer_sidx ON customer_contact (latlon_to_geometry(loc_lat,loc_long)) INDEXTYPE IS mdsys.spatial_index_v2 PARAMETERS (''layer_gtype=POINT'')' );            
        exception
            when others then
                moviestream_write(' - .... unable to create spatial index on customer_contact');             
                moviestream_write(' - .... ' || sqlerrm);                 
        end;    

        begin
            moviestream_write('- create spatial indexes');
            moviestream_exec ( 'CREATE INDEX pizza_location_sidx ON pizza_location (latlon_to_geometry(lat,lon)) INDEXTYPE IS mdsys.spatial_index_v2 PARAMETERS (''layer_gtype=POINT'')' );     
        exception
            when others then
                moviestream_write(' - .... unable to create spatial index on pizza_location');             
                moviestream_write(' - .... ' || sqlerrm);                 
        end;    

     end;
     
     -- CREATE GRAPH (ASYNC JOB)
     moviestream_write('- create async job that creates and populates the graph');
     begin
        dbms_scheduler.create_job (
           job_name             => 'create_graph',
           job_type             => 'STORED_PROCEDURE',
           job_action           => 'add_graph',
           start_date           => current_timestamp,
           enabled              => true
           );
     end;

     
     moviestream_write('done.');
     moviestream_write('Total time(m):  ' || to_char((sysdate - start_time ) * 1440, '99.99'));
     
 
end add_datasets;
/