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


-- Install base moviestream
-- Install the setup file from github 

-- CONNECT As MOVIESTREAM user
begin
    --
    -- Add/modify data required for the demo
    --
    -- Customers used by the demo.  Update this table if nec.   

    workshop.add_dataset('ALL');
    workshop.write('Add/modify demo data', 1);

    -- Drop demo tables if they exist
    for t in (
        select table_name
        from user_tables
        where table_name in (
            'DEMO_CUSTOMERS',
            'LEARN_MORE',
            'NOTIFICATIONS',
            'EXT_MOVIE',
            'MOVIE',
            'EXT_MOVIE_SIMILARITY',
            'MOVIE_SIMILARITY',
            'EXT_BROKEN_MOVIES',
            'MOVIE_RECOMMENDATIONS' )
        )
    loop
        workshop.write('dropping ' || t.table_name);
        workshop.exec('drop table ' || t.table_name || ' cascade constraints');
    end loop;
    
    workshop.write('Create tables',1);

end;
/


-- Customers on the top screen
create table demo_customers (
     cust_id number,
     img_url varchar2(1000)
     );

-- Pointers to tutorials, etc.
create table learn_more (
    id number,
    title varchar2(400),
    description varchar2(1000),
    link_title varchar2(400),
    link_description varchar2(400),
    link varchar2(400)
); 

-- Customer notifications.  This will include a notification for churn
create table notifications (
    cust_id number primary key,
    notification_id number,
    notification_date date,
    subject varchar2(200),
    message varchar2(4000),
    img_url varchar2(1000),
    type varchar2(25)
);

-- Updated movie table with ratings
begin
    dbms_cloud.create_external_table(
        table_name => 'ext_movie',
        file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/dev/o/ratings/movies.json',
        format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
        column_list => 'doc varchar2(30000)'
        );
end;
/

create table movie as
    select
        cast(m.doc.movie_id as number) as movie_id,
        cast(m.doc.title as varchar2(200 byte)) as title,   
        cast(m.doc.budget as number) as budget,
        cast(m.doc.gross as number) gross,
        cast(m.doc.rating as number) rating,
        cast(m.doc.list_price as number) as list_price,
        cast(m.doc.genre as varchar2(4000)) as genres,
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

/*
    Table used for finding movies that are similar to one another:
    "If you liked....
 */

begin
        dbms_cloud.create_external_table(
            table_name => 'ext_movie_similarity',
            file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/dev/o/similar/similar-movies.json',
            format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
            column_list => 'doc varchar2(30000)'
            );
end;
/

create table movie_similarity as
            select
                cast(m.doc.movie_id as number) as movie_id,
                cast(m.doc.title as varchar2(200 byte)) as title,   
                cast(m.doc.similar as varchar2(4000 byte)) as similar
            from ext_movie_similarity m;

/*
 * Broken movies will be filtered and not presented in the application
*/
begin
   dbms_cloud.create_external_table(
        table_name => 'ext_broken_movies',
        file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/dev/o/broken/broken-images.csv',
        format => '{"delimiter":",", "ignoreblanklines":"true", "trimspaces":"lrtrim", "truncatecol":"true", "ignoremissingcolumns":"true"}',
        column_list => 'movie_id number'
        ); 
end;
/
create table broken_movies (movie_id number);

-- New movie table includes ratings
begin
    dbms_cloud.create_external_table(
        table_name => 'ext_movie',
        file_uri_list => 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/dev/o/ratings/movies.json',
        format => json_object('skipheaders' value '0', 'delimiter' value '\n','ignoreblanklines' value 'true'),
        column_list => 'doc varchar2(30000)'
        );
end;
/

-- movie recommendations populated by graph
create table movie_recommendations
   (cust_id number, 
	movie_id number, 
	title varchar2(4000 byte), 
	score number
   );

begin
    workshop.write('populate demo tables');
end;
/

/*
1021503	Diaz	Blanca > not churning
1075252	Boone	Esther > not churning
1010303	Emilio	Welch  -> churner

*/
insert into demo_customers (cust_id,img_url) values (1021503,'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/avatarfemale1.png');
insert into demo_customers (cust_id,img_url) values (1075252,'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/avatarfemale2.png');
insert into demo_customers (cust_id,img_url) values (1010303,'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/avatarmale1.png');
commit;


insert into learn_more (
    id,
    title,
    description,
    link_title,
    link_description,
    link
) values (
    10,
    'Welcome to Oracle MovieStream',
    'Get an overview about MovieStream and how they''re using Oracle Cloud and Autononomous Database',
    'MovieStream Overview',
    'Learn About MovieStream',
    'https://www.oracle.com/database/technologies/datawarehouse-bigdata/oracle-moviestream.html'
);

insert into learn_more (
    id,
    title,
    description,
    link_title,
    link_description,
    link
) values (
    20,
    'Modern App Development',
    'Use ADB as a JSON document store to drive modern applications',
    'Learn How with LiveLab',
    'Develop with Oracle SODA and MongoDB APIs',
    'https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=831'
);

insert into learn_more (
    id,
    title,
    description,
    link_title,
    link_description,
    link
) values (
    30,
    'Popular on MovieStream',
    'Use Oracle Analytic SQL for top movies',
    'Learn How With Live SQL',
    'Analytic SQL',
    'https://livesql.oracle.com/apex/f?p=590:49:0::NO:RP,49:P49_TYPES:T'
);

insert into learn_more (
    id,
    title,
    description,
    link_title,
    link_description,
    link
) values (
    40,
    'Popular Near You',
    'Combine Oracle SQL and Spatial analytics for top movies near you',
    'Learn How With LiveLabs',
    'Analytic SQL and Spatial',
    'https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=889'
);

insert into learn_more (
    id,
    title,
    description,
    link_title,
    link_description,
    link
) values (
    50,
    'Movie Recommendations',
    'Use Graph Analytics to produce movie recommendations',
    'Learn How With LiveLabs',
    'Graph Analytics',
    'https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=889'
);

insert into learn_more (
    id,
    title,
    description,
    link_title,
    link_description,
    link
) values (
    60,
    'Specialize Offers',
    'Use Oracle Machine Learning to predict churn and localize offers with Oracle Spatial',
    'Learn How With LiveLabs',
    'Machine Learning and Spatial Analytics',
    'https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=889'
);

commit;

insert into broken_movies (movie_id)
(select movie_id from ext_broken_movies);
commit;

insert into broken_movies (movie_id)
    (select movie_id from movie where image_url is null);
commit;   


/*
 *  Create views that simplify JSON document creation
 */

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
      and json_value(m.genres, '$[0]') != 'Unknown'
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
 select 
    d.cust_id,
    json_object ('cust_id' : c.cust_id, 
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
create or replace view v_notification_collection as
    select
        cust_id,
        json_object (
            'cust_id' : cust_id,
            'date' : to_char(notification_date, 'Mon DD, YYYY'),
            'subject' : subject,
            'message' : message,
            'img_url' : img_url,
            'type' : type
    ) as doc
    from notifications;       

/*
    Install demo PLSQL packages
*/

declare
    l_git varchar2(4000);
    l_repo_name varchar2(100) := 'adb';
    l_owner varchar2(100) := 'martygubar';
    l_package_file varchar2(200) := 'shared/moviestream-app/sql/movieapp-package.sql';
begin
    workshop.write('Add demo PLSQL packages', 1);
    -- get a handle to github
    l_git := dbms_cloud_repo.init_github_repo(
                repo_name       => l_repo_name,
                owner           => l_owner );

    -- install the package header
    dbms_cloud_repo.install_file(
        repo        => l_git,
        file_path   => l_package_file,
        stop_on_error => false);

end;
/


/*
 * Update the collections that cache results
 */
workshop.write('Create JSON collections', 1); 
exec movieapp.initialize_collections;
workshop.write('Add sample data', 1); 
exec movieapp.add_sampledata;
 

/*
 *  View used by OAC
 */ 
 workshop.write('Create OAC view', 1); 
CREATE OR REPLACE VIEW V_MOVIE_SALES AS 
  select    
    m.doc.title || '(' || m.doc.year || ')' as title,
    c.day_id as day,
    c.actual_price as sales,
    1 as views,
    c.device as device,    
    m.doc.cast,
    m.doc.crew,
    m.doc.awards,
    m.doc.nominations
from "movieCollection" m, custsales c, genre g
where c.genre_id = g.genre_id
  and m.id = c.movie_id;

 
/*
 * Open up access w/o authentication....
 */


begin
  workshop.write('Open access to moviestream via REST w/o authentication', 1);
  ords.delete_privilege_mapping('oracle.soda.privilege.developer', '/soda/*');
  commit;
end;
/

BEGIN
    workshop.write('Done.')
end;
/

