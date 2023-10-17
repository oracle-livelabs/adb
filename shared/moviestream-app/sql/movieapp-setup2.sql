/*

1. Start with base moviestream
2. Update movie and movie similarity to add ratings TODO: Update movie similarity
3. Add movie_recommendations table.  Will be populated inititially with random data
4. Create views that simplify document creation.  
   Change that view to change the customers
5. Create the collections
6. Then, populate them using views and getLandingPageDoc function
7. Note: demo_customers table includes the customers that are displayed in the UX.


*/

/*
1021503	Diaz	Blanca > not churning
1075252	Boone	Esther > not churning
1052678 Kyle	Crosby -> churner

*/

-- Customers used by the demo.  Update this table if nec.   
drop table demo_customers;   
create table demo_customers (
 cust_id number,
 img_url varchar2(1000)
 );

insert into demo_customers (cust_id,img_url) values (1021503,'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/avatarfemale1.png');
insert into demo_customers (cust_id,img_url) values (1075252,'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/avatarfemale2.png');
insert into demo_customers (cust_id,img_url) values (1052678,'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/avatarmale1.png');
commit;

-----------
-- Add some sample data
-- 1. Customer notifications
-- 2. movie recommendations
----------------------------------------------------------------------------------------------------------
-- Add customer notifications.  This will include a notification for churn
drop table customer_notifications;
create table customer_notifications (
    cust_id number,
    notification_id number,
    notification_date date,
    subject varchar2(200),
    message varchar2(4000),
    img_url varchar2(1000),
    type varchar2(25)
);

truncate table customer_notifications;
insert into customer_notifications ( cust_id, notification_id, notification_date, subject, message, img_url, type)
values (1052678, 
        1, 
        to_date('2022-MAR-01', 'YYYY-MON-DD'), 
        'Special Pizza Offer!',
        'You have a special offer at Mama Lucina.  1 FREE PIE',
        'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/pizza.jpg',
        'promotion');

commit;


/*

grant execute on dbms_cloud to moviestream;
grant create table to moviestream;
grant create view to moviestream;
grant all on directory data_pump_dir to moviestream;
grant create procedure to moviestream;
grant create sequence to moviestream;
grant create job to moviestream;

*/
-------------------
-- Start with Base moviestream
-----------------------------------------------------------------------------------------------
-- drop this table with the lab listings

drop table moviestream_labs; -- ignore error if table did not exist
drop table moviestream_log;  -- ignore error if table did not exist

-- Add the log table
create table moviestream_log
   (    execution_time timestamp (6),
        message varchar2(32000 byte)
   );

-- Create the MOVIESTREAM_LABS table that allows you to query all of the labs and their associated scripts
begin
    dbms_cloud.create_external_table(table_name => 'moviestream_labs',
                file_uri_list => 'https://raw.githubusercontent.com/oracle-livelabs/adb/main/movie-stream-story-lite/add-data-scripts/moviestream-lite-labs.json',
                format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
                column_list => 'doc varchar2(30000)'
            );
end;
/

-- Define the scripts found in the labs table.
declare
    b_plsql_script blob;            -- binary object
    c_plsql_script clob;    -- converted to clob
    uri_scripts varchar2(2000) := 'https://raw.githubusercontent.com/oracle-livelabs/adb/main/movie-stream-story-lite/add-data-scripts'; -- location of the scripts
    uri varchar2(2000);
begin

    -- Add privilege to run dbms_cloud
    -- Run a query to get each lab and then create the procedures that generate the output
    for lab_rec in (
        select  json_value (doc, '$.lab_num' returning number) as lab_num,
                json_value (doc, '$.title' returning varchar2(500)) as title,
                json_value (doc, '$.script' returning varchar2(100)) as proc        
        from moviestream_labs ml
        where json_value (doc, '$.script' returning varchar2(100))  is not null
        order by 1 asc
        )
    loop
        -- The plsql procedure DDL is contained in a file in object store
        -- Create the procedure
        dbms_output.put_line(lab_rec.title);
        dbms_output.put_line('....downloading plsql procedure ' || lab_rec.proc);

        -- download the script into this binary variable        
        uri := uri_scripts || '/' || lab_rec.proc || '.sql';

        dbms_output.put_line('....the full uri is ' || uri);        
        b_plsql_script := dbms_cloud.get_object(object_uri => uri);

        dbms_output.put_line('....creating plsql procedure ' || lab_rec.proc);
        -- convert the blob to a varchar2 and then create the procedure
        c_plsql_script :=  to_clob( b_plsql_script );

        -- generate the procedure
        execute immediate c_plsql_script;

    end loop lab_rec;  

    execute immediate 'grant execute on moviestream_write to public';

    exception
        when others then
            dbms_output.put_line('Unable to add the data sets.');
            dbms_output.put_line('');
            dbms_output.put_line(sqlerrm);
 end;
 /

begin
    add_datasets();
end;
/

-------------------
-- 1. Recreate the movie table using one with ratings.  '
-- 2. Create the movie similarity table
-- 3. Create the movie_recommendations table
------------------------------------------------------------------------------------------------------------------

drop table ext_movie;
-- New movie table that includes ratings
begin
        dbms_cloud.create_external_table(
            table_name => 'ext_movie',
            file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/dev/o/ratings/movies.json',
            format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
            column_list => 'doc varchar2(30000)'
            );
end;
/

drop table movie cascade constraints;
create table movie as
            select
                cast(m.doc.movie_id as number) as movie_id,
                cast(m.doc.title as varchar2(200 byte)) as title,   
                cast(m.doc.budget as number) as budget,
                cast(m.doc.gross as number) gross,
                cast(m.doc.rating as number) rating,
                cast(m.doc.list_price as number) as list_price,
                cast(m.doc.genres as varchar2(4000)) as genres,
                cast(m.doc.sku as varchar2(30 byte)) as sku,   
                cast(m.doc.year as number) as year,
                to_date(m.doc.opening_date, 'YYYY-MM-DD') as opening_date,
                cast(m.doc.views as number) as views,
                cast(m.doc.cast as varchar2(4000 byte)) as cast,
                cast(m.doc.crew as varchar2(4000 byte)) as crew,
                cast(m.doc.studio as varchar2(4000 byte)) as studio,
                cast(m.doc.main_subject as varchar2(4000 byte)) as main_subject,
                cast(m.doc.image_url as varchar2(1000)) as image_url,
                cast(m.doc.awards as varchar2(4000 byte)) as awards,
                cast(m.doc.nominations as varchar2(4000 byte)) as nominations,
                cast(m.doc.runtime as number) as runtime,
                substr(cast(m.doc.summary as varchar2(4000 byte)),1, 4000) as summary
            from ext_movie m;

alter table movie  
add constraint genre_json_chk 
check (genres is json) enable;

drop table ext_movie_similarity;
-- New movie table that includes ratings
begin
        dbms_cloud.create_external_table(
            table_name => 'ext_movie_similarity',
            file_uri_list => 'https://raw.githubusercontent.com/martygubar/data/main/movieplex/scores/similar-movies.json?token=GHSAT0AAAAAABSBCWILTPIK5H3G4EIXUHHGYRGLNHQ',
            format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
            column_list => 'doc varchar2(30000)'
            );
end;
/

drop table movie_similarity cascade constraints;
create table movie_similarity as
            select
                cast(m.doc.movie_id as number) as movie_id,
                cast(m.doc.title as varchar2(200 byte)) as title,   
                cast(m.doc.similar as varchar2(4000 byte)) as similar
            from ext_movie_similarity m;

drop table movie_recommendations;
create table movie_recommendations
   (cust_id number, 
	movie_id number, 
	title varchar2(4000 byte), 
	score number
   );

--
-- Populate movie recommendations with random data

begin    
    for c in (  select cust_id
                from demo_customers )
    loop  
        insert into movie_recommendations (
            cust_id,
            movie_id,
            title,
            score
        ) 
        (
            select c.cust_id,
                   movie_id,
                   title,
                   dbms_random.value(0,1)
                from movie sample (2)         
        );
        commit;    
    end loop;
    
    
end;
/

---------------
-- Create movie details view.  It includes similar movies
--------------------------------------------------------------------------------------------------------------
create or replace view v_movie_details as
select json_object (
        'movie_id' : m.movie_id,
        'title' : m.title,
        'rating' : m.rating,
        'genres' : m.genres format json,
        'year' : m.year,
        'cast' : m.cast format json,
        'studio' : m.studio format json,
        'list_price' : m.list_price,
        'crew' : m.crew format json,
        'awards' : m.awards format json,
        'main_subject' : m.main_subject,
        'image_url': m.image_url,
        'runtime' : m.runtime,
        'summary' : m.summary,
        'similar' : ms.similar format json
        returning clob
    ) as doc
from movie m, movie_similarity ms
where m.movie_id = ms.movie_id;

-------------------------------
-- ranking of genre/movies by customer
-- Used to populate shelves
-----------------------------------------------------------------------------------------------------------
create or replace view v_movie_recommendations as
 with recommendations as (
    -- start with recommendations
    select r.cust_id,
           r.movie_id,
           m.title,
           json_value(m.genres, '$[0]') as genre,
           r.score as movie_score
    from movie m, movie_recommendations r
    where r.movie_id = m.movie_id
),
genre_list as (
    -- rank the genres
    select cust_id,
           genre,
           sum(movie_score) as genre_score
    from recommendations
    group by cust_id, genre
    order by cust_id, genre
),
genre_rank as (
    select cust_id,
           genre,
           genre_score,
           rank() over (partition by cust_id order by genre_score desc) as genre_rank
    from genre_list  
),
final_rank as (
select r.cust_id, 
       g.genre_rank,
       g.genre_score,
       g.genre,
       r.movie_id,
       r.movie_score,
       rank() over (partition by r.cust_id, g.genre order by r.movie_score desc) as movie_rank
from genre_rank g, recommendations r
where g.genre = r.genre
  and g.cust_id = r.cust_id
)
select cust_id, genre_rank, genre_score, genre, movie_id, movie_score, movie_rank
from final_rank
where movie_rank <= 10
and genre_rank <= 5
order by cust_id, genre_rank asc, movie_rank asc;

-----------------
-- Views that simplify collection updates
-------------------------------------------------------------------------------------------------
create or replace view v_customer_collection as
 select json_object ('cust_id' : c.cust_id, 
                    'first_name' : c.first_name,
                    'last_name' : c.last_name,
                    'img_url' : d.img_url,
                    'city' : c.city,
                    'state_province' : c.state_province,
                    'yrs_customer' : c.yrs_customer,
                    'gender' : c.gender,
                    'education' : c.education) as doc
                from customer c, demo_customers d
                where c.cust_id = d.cust_id;

 
--
-- View to simplify customer notifications collection update
--                
create or replace view v_customer_notifications as
    select json_object (f
        'cust_id' : cust_id,
        'date' : to_char(notification_date, 'Mon DD, YYYY'),
        'subject' : subject,
        'message' : message,
        'img_url' : img_url,
        'type' : type
    ) as doc
    from customer_notifications;                

-------------------------------------
-- function that returns the landing page for a cust_id
----------------------------------------------------------------------------------------------
create or replace function getLandingPageDoc 
(
  this_custid in number,
  debug_on boolean default false
) 
return clob
as 

    pageJson clob;   -- json for the page
    q_result clob;
    found number;
    e_bad_custid EXCEPTION;
    PRAGMA exception_init( e_bad_custid, -20001 );
    this_row number := 0;

begin
    /*
        The page will be cached into the landingPage collection for this customer
        The procedure will:
            1. Retrieve top level info: customer info, notifications
            2. Get the list of genres
            3. Get "Popular on.... shelves"
            4. Finally, get the recommended genres/movies

    */
    -- check for valid customer.
    select count(*)
    into found
    from customer
    where cust_id = this_custid;

    if found = 0 then
        raise_application_error(-20001,'Invalid cust_id'); 
    end if;

    -- Start with notifications
    if debug_on then 
        moviestream_write('Fetch notifications');
    end if;

    
    with num_notifications as (
        select count(*) as notification_count
        from customer_notifications
        where cust_id = this_custid    
    )
    select json_object(
            key 'cust_id' is this_custid,
            key 'notification_count' is notification_count
            )
    into q_result
    from num_notifications          
    ;

    -- Drop the final '}'
    pageJson := substr(q_result, 1, length(q_result)-1) || ',' ;
    --    moviestream_write(pageJson);


    -- Add genres
--    moviestream_write('Fetch genres');
    select json_object(key 'genres' is
        json_arrayagg(genre order by genre_rank asc) 
        ) as genres

    into q_result    
    from v_movie_recommendations 
    where movie_rank = 1
      and cust_id = this_custid;

    -- Drop the {}'
    pageJson := pageJson || substr(q_result, 2, length(q_result)-2) || ',' ;
--    moviestream_write(pageJson);

    -- Start shelves
    pageJson := pageJson || '"shelves": [';

    ------
    -- Popular on MovieStream
    ------
--    moviestream_write('Fetch Popular on MovieStream');

    with v_top_movies_now as (
        select movie_id,
               count(*) as num_views
        from custsales
        where day_id in (select max(day_id) from time)
        group by movie_id
        order by 2 desc
        fetch first 10 rows only
    )
    select json_object (
        key 'row' is 0,
        key 'name' is 'Popular on MovieStream',
        key 'movies' is
            json_arrayagg (
                    json_object (
                        key 'position' is rownum,
                        key 'movie_id' is t.movie_id,
                        key 'title' is m.title,
                        key 'year' is m.year,
                        key 'popularity' is m.views,
                        key 'rating' is m.rating,
                        key 'image_url' is m.image_url,
                        key 'genres' is m.genres 
                    )
                )
        )
    into q_result
    from v_top_movies_now t, movie m
    where t.movie_id = m.movie_id
    ;

    pageJson := pageJson ||q_result || ',';

    ----------
    -- Popular in your area
    ----------
--    moviestream_write('Fetch Popular in your area');
    with v_top_movies_nearby as (    
        select movie_id,
               count(*) as num_views
        from custsales
        where day_id in (select max(day_id) from time)
        -- add location
        and cust_id in (
                select /*+ LEADING(a) USE_NL(a b) INDEX(a CUSTOMER_SIDX) */ b.cust_id
                from customer_contact a, customer_contact b
                where a.cust_id = this_custid
                and sdo_nn(
                     latlon_to_geometry(b.loc_lat, b.loc_long),
                     latlon_to_geometry(a.loc_lat, a.loc_long),
                     'sdo_num_res=1000') = 'TRUE'    
            )
        group by movie_id
        order by 2 desc
        fetch first 10 rows only
    )
    select json_object (
        key 'row' is 1,
        key 'name' is 'Popular in Your Area',
        key 'movies' is
            json_arrayagg (
                    json_object (
                        key 'position' is rownum,
                        key 'movie_id' is t.movie_id,
                        key 'title' is m.title,
                        key 'year' is m.year,
                        key 'popularity' is m.views,
                        key 'rating' is m.rating,
                        key 'image_url' is m.image_url,
                        key 'genres' is m.genres 
                    )
                )
        )
    into q_result
    from v_top_movies_nearby t, movie m
    where t.movie_id = m.movie_id
    ;

    pageJson := pageJson ||q_result || ',';

    --------------------------
    -- Award winners
    --------------------------
--    moviestream_write('Award winners');

    with v_award_winners as (    
        select movie_id
        from movie
        where instr(awards, 'Best Picture') > 0
        order by views desc
        fetch first 10 rows only
        )
    select json_object (
        key 'row' is 2,
        key 'name' is 'Award Winners',
        key 'movies' is
            json_arrayagg (
                    json_object (
                        key 'position' is rownum,
                        key 'movie_id' is t.movie_id,
                        key 'title' is m.title,
                        key 'year' is m.year,
                        key 'popularity' is m.views,
                        key 'rating' is m.rating,
                        key 'image_url' is m.image_url,
                        key 'genres' is m.genres 
                    )
                )
        )
    into q_result
    from v_award_winners t, movie m
    where t.movie_id = m.movie_id
    ;

    pageJson := pageJson || q_result;

    -----------------------------
    -- genres with movies
    -----------------------------
--    moviestream_write('genre->movie recommendations');

    for rec in (
        with v_movie_recs as (    
            select genre_rank,
                   genre,
                   movie_id,
                   movie_rank
            from v_movie_recommendations
            where cust_id = this_custid
            order by genre_rank asc, movie_rank asc
            )
        select json_object (
            key 'row' is genre_rank + 2,
            key 'name' is genre,
            key 'movies' is
                json_arrayagg (
                        json_object (
                            key 'position' is t.movie_rank -1,
                            key 'movie_id' is t.movie_id,
                            key 'title' is m.title,
                            key 'year' is m.year,
                            key 'popularity' is m.views,
                            key 'rating' is m.rating,
                            key 'image_url' is m.image_url,
                            key 'genres' is m.genres 
                        ) order by t.movie_rank asc
                    )

            ) as doc
        from v_movie_recs t, movie m
        where t.movie_id = m.movie_id
        group by genre, genre_rank
        order by genre_rank asc
    )
    loop
 --       moviestream_write(rec.doc);        
        pageJson :=  pageJson || ', ' || rec.doc  ;   

    end loop
    ;

    -- End shelves and doc
    pageJson := pageJson || '] }';

    return pageJson;

    EXCEPTION
        WHEN others THEN
        raise;
        return sqlerrm;    

--    moviestream_write(pageJson);

end getLandingPageDoc;
/



-------------
-- Create the collections
------------------------------------------------------------------------------------------------------------
declare
    l_status  number := 0;
    type t_jsonCollections is table of varchar2(30) index by pls_integer;
    l_jsonCollections t_jsonCollections;
    l_metadata varchar2(1000);
    l_collection    soda_collection_t;
   
begin

    l_metadata := '        
        {
         "contentColumn" : { 
           "name" : "DOC"
         },
         "keyColumn" : { 
           "name" : "ID", 
           "assignmentMethod" : "CLIENT",           
         },  
         "versionColumn" : { 
            "name" : "VERSION", 
            "method" : "UUID" 
         }, 
         "lastModifiedColumn" : { 
            "name" : "LAST_MODIFIED" 
         },
         "creationTimeColumn" : { 
            "name" : "CREATED_ON"
         }
        }';        
        
    l_jsonCollections(1) := 'landingPage';
    l_jsonCollections(2) := 'movieCollection';
    l_jsonCollections(3) := 'movieDetailsCollection';
    l_jsonCollections(4) := 'customerCollection';
    l_jsonCollections(5) := 'notificationCollection';
    
    -- Recreate the collections
    for i in l_jsonCollections.first .. l_jsonCollections.last
    loop
        dbms_output.put_line('drop ' || l_jsonCollections(i));
        dbms_output.put_line('..success = ' || dbms_soda.drop_collection(l_jsonCollections(i)));
        dbms_output.put_line('create ' || l_jsonCollections(i));        
        l_collection := dbms_soda.create_collection(
                collection_name => l_jsonCollections(i), 
                metadata => l_metadata);                
    end loop;
    commit;

end;
/

----------------------
-- populate landing page collection
----------------------

declare
    l_collection    soda_collection_t;
    l_doc    soda_document_t;
    l_thePage clob;
    n       number;
    l_docKey  varchar2(100);
    l_collection_name varchar2(100) := 'landingPage';
begin


    l_collection := dbms_soda.open_collection(
                collection_name => l_collection_name);

    for l_custrec in (
        select cust_id
        from demo_customers
        )
    loop
   
        l_docKey := to_char(l_custrec.cust_id);
        l_thePage := getLandingPageDoc(l_custrec.cust_id);
        
        if l_thePage is null then
            continue;
        end if;
               
        -- Create documents.
        l_doc := soda_document_t(
                key => l_docKey,
                b_content => utl_raw.cast_to_raw(l_thePage)
                );
                                                  
        n := l_collection.save(l_doc);
        dbms_output.put_line('Status: ' || n);
        commit;

    end loop;
end;
/

--
-- Movie collection
--
declare
    coll    soda_collection_t;
    md      varchar2(4000);
    doca    soda_document_t;
    thePage clob;
    n       number;
    docKey  varchar2(100);
    colname varchar2(100) := 'movieCollection';
begin
    -- Create a collection and print its metadata
              
    coll := dbms_soda.open_collection(
                collection_name => colname);                
         
    for c in (  select doc
                from ext_movie )
    loop        
    
        -- Create documents.       
        docKey := json_value(c.doc, '$.movie_id');
    
        -- Create documents.
        doca := soda_document_t(
                    key => docKey, 
                    b_content => utl_raw.cast_to_raw(c.doc)
                    );        
                                                  
        n := coll.save(doca);
        commit;

    end loop;
end;
/

--
-- Movie details collection
--
declare
    coll    soda_collection_t;
    md      varchar2(4000);
    doca    soda_document_t;
    thePage clob;
    n       number;
    docKey  varchar2(100);
    colname varchar2(100) := 'movieDetailsCollection';
begin

    coll := dbms_soda.open_collection(
                collection_name => colname);                
                         
    for c in (  select doc
                from v_movie_details )
    loop            
        -- Create documents.
        docKey := json_value(c.doc, '$.movie_id');    
        doca := soda_document_t(
                    key => docKey, 
                    b_content => utl_raw.cast_to_raw(c.doc)
                    );
                                                  
        n := coll.save(doca);
        -- dbms_output.put_line('Status: ' || n);
        commit;

    end loop;
end;
/

--
-- Customer
--
declare
    coll    soda_collection_t;
    md      varchar2(4000);
    doca    soda_document_t;
    thePage clob;
    n       number;
    docKey  varchar2(100);
    colname varchar2(100) := 'customerCollection';
begin
        
    coll := dbms_soda.open_collection(
                collection_name => colname);
                
    for c in (  select doc
                from v_customer_collection )
    loop        
        docKey := json_value(c.doc, '$.cust_id');
    
        -- Create documents.
        doca := soda_document_t(
                    key => docKey, 
                    b_content => utl_raw.cast_to_raw(c.doc)
                    );
                                                  
        n := coll.save(doca);
        -- dbms_output.put_line('Status: ' || n);
        commit;

    end loop;
end;
/

--
-- Notifications
--
declare
    coll    soda_collection_t;
    md      varchar2(4000);
    doca    soda_document_t;
    thePage clob;
    n       number;
    docKey  varchar2(100);
    colname varchar2(100) := 'notificationCollection';
begin
    
    coll := dbms_soda.open_collection(
                collection_name => colname
                );                         
    for c in (  select doc
                from v_customer_notifications )
    loop            
        -- Create documents.
        docKey := json_value(c.doc, '$.cust_id');
        
        doca := soda_document_t(   
                    key => docKey,
                    b_content => utl_raw.cast_to_raw(c.doc)
                    );
                                                  
        n := coll.save(doca);
        commit;

    end loop;
end;
/


-- Open up access w/o authentication....
begin
  ords.delete_privilege_mapping('oracle.soda.privilege.developer', '/soda/*');
  commit;
end;
/

--curl -i --user B7fSMrWEa8ujI7petdSPTg..:493VFEgqeJCoHNf_Ptt8YA.. --data "grant_type=client_credentials" https://ihsf7opuc2w9rzc-db202202031659.adb.us-phoenix-1.oraclecloudapps.com/ords/moviestream/oauth/token
--curl -i --u "moviestream:bigdataPM2019%21" https://ihsf7opuc2w9rzc-db202202031659.adb.us-phoenix-1.oraclecloudapps.com/ords/moviestream/soda/latest/


/*
-- REST access to customer 
-- moviestream-dev
--curl -X GET https://g9d1f2d8d1f91d1-moviedev.adb.us-ashburn-1.oraclecloudapps.com/ords/moviestream/soda/latest/landingPage/1265736
--curl -X GET https://g9d1f2d8d1f91d1-moviedev.adb.us-ashburn-1.oraclecloudapps.com/ords/moviestream/soda/latest/movieCollection/1216
-- adwc4pm
-- curl -X GET https://ihsf7opuc2w9rzc-db202202031659.adb.us-phoenix-1.oraclecloudapps.com/ords/moviestream/soda/latest



-- ADWC4PM
mongosh 'mongodb://moviestream:bigdataPM2019%23@IHSF7OPUC2W9RZC-DB202202031659.adb.us-phoenix-1.oraclecloudapps.com:27017/moviestream?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
mongosh 'mongodb://moviestream:ironMan_3_pg@G9D1F2D8D1F91D1-MOVIEDEV.adb.us-ashburn-1.oraclecloudapps.com:27017/moviestream?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'

-- Newer clients
mongosh 'mongodb://moviestream:ironMan_3_pg@G9D1F2D8D1F91D1-MOVIEDEV.adb.us-ashburn-1.oraclecloudapps.com:27017/moviestream?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true'
-- older services (on a different port)
mongosh 'mongodb://moviestream:ironMan_3_pg@G9D1F2D8D1F91D1-MOVIEDEV.adb.us-ashburn-1.oraclecloudapps.com:27016/moviestream?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false'




curl -i -k --user XSiVSsTwo34kpVDFcb6I-A..:FpT1BM5-khtK28Q7UrDZCA.. --data "grant_type=client_credentials" https://ihsf7opuc2w9rzc-db202202031659.adb.us-phoenix-1.oraclecloudapps.com/ords/moviestream/oauth/token


-- add the movie collection using steps above
curl -X GET -u 'moviestream:bigdataPM2019#' https://ihsf7opuc2w9rzc-mongo.adb.us-phoenix-1.oraclecloudapps.com/ords/moviestream/soda/latest/movieCollection/C56D8515E6674F6ABFE8AAB461CAC81A

curl -X PUT -u 'moviestream:bigdataPM2019#' \
"https://example-db.adb.us-phoenix-1.oraclecloudapps.com/ords/admin/soda/latest/fruit"

*/

-- churn score
with cust_churn as (
    select 
        cs.cust_id,
        max(l.prob_churn) as prob_churn,
        count(*) as views    
    from custsales cs, latest_potential_churners l
    where l.will_churn = 1
    and l.cust_id = cs.cust_id
    group by cs.cust_id
)
select 
    round(prob_churn * views) as score,
    cc.views,
    cc.prob_churn,
    cc.cust_id,
    c.first_name,
    c.last_name,
    c.gender,
    c.state_province       
from customer c, cust_churn cc
where c.cust_id = cc.cust_id
and country = 'United States' 
order by 1 desc
fetch first 10 rows only
;

-- Save Kyle!  The other top potential churners need another offer.  Local pizza places are an hour away
-- 1052678	Kyle	Crosby	Male	Massachusetts
SELECT a.cust_id, b.chain, b.address, b.city, b.state,
       round( sdo_nn_distance(1), 1 ) distance_km
FROM customer_contact a, pizza_location b
WHERE a.cust_id = 1052678
AND sdo_nn(
     latlon_to_geometry(b.lat, b.lon),
     latlon_to_geometry(a.loc_lat, a.loc_long),
     'sdo_num_res=1 unit=KM',
     1 ) = 'TRUE';     
     
select * from customer_notifications;

declare
    this_custid number := 1052678;
begin
    -- Update the notifcations table
    merge into customer_notifications c using
        ( SELECT 
                a.cust_id as cust_id,
                1 as NOTIFICATION_ID,
                sysdate as NOTIFICATION_DATE,
                'Special Pizza Offer!' as subject,
                'You have a special offer for 1 FREE PIE at ' ||
                    b.chain || '!\n' ||  
                    b.address || ', ' ||
                    b.city as message, 
                'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/pizza.jpg' as img_url,
                'promotion' as type
            FROM customer_contact a, pizza_location b
            WHERE a.cust_id = this_custid
            AND sdo_nn(
                 latlon_to_geometry(b.lat, b.lon),
                 latlon_to_geometry(a.loc_lat, a.loc_long),
                 'sdo_num_res=1 unit=KM',
                 1 ) = 'TRUE'
        ) s
    on (s.cust_id = c.cust_id)
    when matched then update set c.notification_date = S.notification_date,
                                 c.notification_id = S.notification_id,
                                 c.subject = s.subject,
                                 c.message = s.message,
                                 c.img_url = s.img_url,
                                 c.type = s.type
    when not matched then insert (cust_id,
                                  notification_id,
                                  notification_date,
                                  subject,
                                  message,
                                  img_url,
                                  type) 
                        values (s.cust_id,
                                s.notification_id,
                                s.notification_date,
                                s.subject,
                                s.message,
                                s.img_url,
                                s.type);
    end;
    
    -- Update the collection
/

select * from customer_notifications;
desc customer_notifications;

merge into customer_notifications c using
    ( SELECT 
            a.cust_id as cust_id,
            1 as NOTIFICATION_ID,
            sysdate as NOTIFICATION_DATE,
            'Special Pizza Offer!' as subject,
            'You have a special offer for 1 FREE PIE at ' ||
                b.chain || '!\n' ||  
                b.address || ', ' ||
                b.city as message, 
            'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/pizza.jpg' as img_url,
            'promotion' as type
        FROM customer_contact a, pizza_location b
        WHERE a.cust_id = 1052678
        AND sdo_nn(
             latlon_to_geometry(b.lat, b.lon),
             latlon_to_geometry(a.loc_lat, a.loc_long),
             'sdo_num_res=1 unit=KM',
             1 ) = 'TRUE'
    ) s
on (s.cust_id = c.cust_id)
when matched then update set c.notification_date = S.notification_date,
                             c.notification_id = S.notification_id,
                             c.subject = s.subject,
                             c.message = s.message,
                             c.img_url = s.img_url,
                             c.type = s.type
when not matched then insert (cust_id,
                              notification_id,
                              notification_date,
                              subject,
                              message,
                              img_url,
                              type) 
                    values (s.cust_id,
                            s.notification_id,
                            s.notification_date,
                            s.subject,
                            s.message,
                            s.img_url,
                            s.type);
commit;

truncate table CUSTOMER_NOTIFICATIONS;
select * from CUSTOMER_NOTIFICATIONS;


declare
    this_custid number := 1052678;
    coll    soda_collection_t;
    md      varchar2(4000);
    doca    soda_document_t;
    l_json  clob;
    n       number;
    docKey  varchar2(100);
    n_colname varchar2(100) := 'notificationCollection';
    l_colname varchar2(100) := 'landingPage';
begin
    -- Update the notifcations table
    merge into customer_notifications c using
        ( SELECT 
                a.cust_id as cust_id,
                1 as NOTIFICATION_ID,
                sysdate as NOTIFICATION_DATE,
                'Special Pizza Offer!' as subject,
                'You have a special offer for 1 FREE PIE at ' ||
                    b.chain || '!\n' ||  
                    b.address || ', ' ||
                    b.city as message, 
                'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/pizza.jpg' as img_url,
                'promotion' as type
            FROM customer_contact a, pizza_location b
            WHERE a.cust_id = this_custid
            AND sdo_nn(
                 latlon_to_geometry(b.lat, b.lon),
                 latlon_to_geometry(a.loc_lat, a.loc_long),
                 'sdo_num_res=1 unit=KM',
                 1 ) = 'TRUE'
        ) s
    on (s.cust_id = c.cust_id)
    when matched then update set c.notification_date = S.notification_date,
                                 c.notification_id = S.notification_id,
                                 c.subject = s.subject,
                                 c.message = s.message,
                                 c.img_url = s.img_url,
                                 c.type = s.type
    when not matched then insert (cust_id,
                                  notification_id,
                                  notification_date,
                                  subject,
                                  message,
                                  img_url,
                                  type) 
                        values (s.cust_id,
                                s.notification_id,
                                s.notification_date,
                                s.subject,
                                s.message,
                                s.img_url,
                                s.type);
    end;
    
    -- Update the notification collection
    coll := dbms_soda.open_collection(
                collection_name => n_colname);
    select doc
    into l_json
    from v_customer_notifications
    where cust_id = this_custid;
                
    -- Create documents.
    docKey := json_value(c.doc, this_custid);        
    doca := soda_document_t(   
                key => docKey,
                b_content => utl_raw.cast_to_raw(l_json)
                );
                                                  
    n := coll.save(doca);
    commit;
    
    -- update the landing page
    

    end loop;                

/
