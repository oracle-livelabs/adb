create or replace package movieapp as 


    /**********************************************
     * 
     * populate learn-how collection
     *
     */
    procedure populate_learnmore_collection;

    /**********************************************
     * 
     * add sample data to bootstrap the demo
     *
     */
    procedure add_sampledata;

    -- Fetch the landing page json for a customer
    function getLandingPageDoc 
    (
      this_custid in number,
      debug_on boolean default false
    ) 
    return clob;

    /**********************************************
     * 
     * initialize the collections.  Will clear all of them
     *
     */
    procedure initialize_collections;

    /**********************************************
     * 
     * populate landing page collection
     *
     */
    procedure populate_landingpage_collection (
        this_custid number
    );


    /**********************************************
     * 
     * populate movie collection
     *
     */
    procedure populate_movie_collection;

    /**********************************************
     * 
     * populate moviDetails collection
     *
     */
    procedure populate_moviedetails_collection;   

    /**********************************************
     * 
     * populate customer collection
     *
     */
    procedure populate_customer_collection (
        this_custid number
    );

    /**********************************************
     * 
     * populate notification collection
     *
     */
    procedure populate_notification_collection (
        this_custid number
    ) ;

    /**********************************************
     * 
     * publish will update the collections
     *
     */     
    procedure publish (
        this_custid number

    );

    /**********************************************
     * 
     * add the pizza promotion for this customer
     *
     */     
    procedure add_promotion (
        this_custid number

    );

end movieapp;
/

create or replace package body movieapp as


    /**********************************************
     * 
     * initialize the collections.  Will clear all of them
     *
     */
    procedure initialize_collections is
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
        l_jsonCollections(6) := 'learnMoreCollection';

        -- Recreate the collections
        for i in l_jsonCollections.first .. l_jsonCollections.last
        loop
            dbms_output.put_line('drop ' || l_jsonCollections(i));
            dbms_output.put_line('..success = ' || dbms_soda.drop_collection(l_jsonCollections(i)));
            dbms_output.put_line('create ' || l_jsonCollections(i));        
            l_collection := dbms_soda.create_collection(
                    collection_name => l_jsonCollections(i), 
                    metadata => l_metadata);                
            commit;
        end loop;


    end initialize_collections;


    /**********************************************
     * 
     * publish will update the collections
     *
     */     
    procedure publish (
        this_custid number

    )   is 
        begin

            populate_notification_collection(this_custid);
            populate_landingpage_collection(this_custid);

    end publish;

    /**********************************************
     * 
     * add the pizza promotion for this customer
     *
     */     
    procedure add_promotion (
        this_custid number

    )   is 
        begin 
            -- Update the notifcations table
            merge into notifications c using
                ( SELECT 
                        a.cust_id as cust_id,
                        1 as NOTIFICATION_ID,
                        sysdate as NOTIFICATION_DATE,
                        'Special Pizza Offer!' as subject,
                        'You have a special offer for 1 FREE PIE at ' ||
                            b.chain || '!  ' ||  
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

            commit;

        end add_promotion;



    /**********************************************
     * 
     * add sample data to bootstrap the demo
     *
     */     
    procedure add_sampledata is 
        begin           
            -- movie recommendations
            moviestream_write('add movie recommendation sample data');
            delete movie_recommendations;
            commit;

            -- notifications;
            delete notifications;
            commit;
            insert into notifications ( cust_id, notification_id, notification_date, subject, message, img_url, type)
            values (1021503, 
                    1, 
                    to_date('2022-MAR-01', 'YYYY-MON-DD'), 
                    'Special Pizza Offer!',
                    'You have a special offer at Mama Lucina.  1 FREE PIE',
                    'https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream_app/o/img/pizza.jpg',
                    'promotion');

            commit;

            populate_learnmore_collection;
            populate_movie_collection;
            populate_moviedetails_collection;

            for c in (  select cust_id
                        from demo_customers )
            loop  
/*                insert into movie_recommendations (
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
*/
                insert into movie_recommendations (
                    cust_id,
                    movie_id,
                    title,
                    score
                ) 
                (
                    select cust_id, movie_id, title, score
                    from ( 
                        select 
                            c.cust_id,
                            movie_id, 
                            title, 
                            dbms_random.value(0,1) as score
                        from movie
                        where views <= 2000
                        order by dbms_random.value )
                    where rownum <= 100                    
                );
                commit;    

                -- populate collections for this customer
                populate_notification_collection(c.cust_id);
                populate_customer_collection(c.cust_id);
                populate_landingpage_collection(c.cust_id);
            end loop;




        end add_sampledata;

    /**********************************************
     * 
     * Returns the json for a customer's landing page    
     *
     */     
    function getLandingPageDoc 
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
            from notifications
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

        if debug_on then
            moviestream_write(pageJson);
        end if;


        -- Add genres

        if debug_on then
            moviestream_write('Fetch genres');
        end if;

        select json_object(key 'genres' is
            json_arrayagg(genre order by genre_rank asc) 
            ) as genres

        into q_result    
        from v_movie_recommendations 
        where movie_rank = 1
          and cust_id = this_custid;

        -- Drop the {}'
        pageJson := pageJson || substr(q_result, 2, length(q_result)-2) || ',' ;

        if debug_on then
            moviestream_write(pageJson);
        end if;

        -- Start shelves
        pageJson := pageJson || '"shelves": [';

        ------
        -- Popular on MovieStream
        ------
        if debug_on then
            moviestream_write('Fetch Popular on MovieStream');
        end if;

        with v_top_movies_now as (
            select movie_id,
                   count(*) as num_views
            from custsales
            where day_id in (select day_id from time where to_char(day_id, 'YYYY-MON') = '2020-MAR' order by day_id desc fetch first 7 rows only)
              and movie_id not in (select movie_id from broken_movies)
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
                            key 'runtime' is m.runtime,
                            key 'image_url' is m.image_url,
                            key 'genres' is m.genres 
                        )
                    )
            )
        into q_result
        from v_top_movies_now t, movie m
        where t.movie_id = m.movie_id
        order by dbms_random.value
        ;

        pageJson := pageJson ||q_result || ',';

        ----------
        -- Popular in your area
        ----------
        if debug_on then
            moviestream_write('Fetch Popular in your area');
        end if;

        with v_top_movies_now as (
            select movie_id,
                   count(*) as num_views
            from custsales
            where day_id in (select day_id from time where to_char(day_id, 'YYYY-MON') = '2020-MAR' order by day_id desc fetch first 7 rows only)
              and movie_id not in (select movie_id from broken_movies)
            group by movie_id
            order by 2 desc
            fetch first 10 rows only
        ),        
        v_top_movies_nearby as (    
            select movie_id,
                   count(*) as num_views
            from custsales
            where day_id in (select max(day_id) from time)
            -- add location
            and cust_id in (
                    select  /*+ LEADING(a) USE_NL(a b) INDEX(a CUSTOMER_SIDX) */ b.cust_id
                    from customer_contact a, customer_contact b
                    where a.cust_id = this_custid
                    and sdo_nn(
                         latlon_to_geometry(b.loc_lat, b.loc_long),
                         latlon_to_geometry(a.loc_lat, a.loc_long),
                         'sdo_num_res=1000') = 'TRUE'    
                )
            and movie_id not in (select t.movie_id from v_top_movies_now t) -- remove movies that are top in moviestream now
            and movie_id not in (select movie_id from broken_movies)
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
                            key 'runtime' is m.runtime,
                            key 'genres' is m.genres 
                        )
                    )
            )
        into q_result
        from v_top_movies_nearby t, movie m
        where t.movie_id = m.movie_id
        order by dbms_random.value
        ;

        pageJson := pageJson ||q_result || ',';

        --------------------------
        -- Award winners
        --------------------------
        if debug_on then
            moviestream_write('Award winners');
        end if;

        with v_award_winners as (    
            select movie_id
            from movie
            where instr(awards, 'Best Picture') > 0
              and movie_id not in (select movie_id from broken_movies)
              and year > 1966
            order by dbms_random.value 
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
                            key 'runtime' is m.runtime,
                            key 'genres' is m.genres 
                        )
                    )
            )
        into q_result
        from v_award_winners t, movie m
        where t.movie_id = m.movie_id
        order by dbms_random.value
        ;

        pageJson := pageJson || q_result;

        -----------------------------
        -- genres with movies
        -----------------------------
        if debug_on then
            moviestream_write('genre->movie recommendations');
        end if;

        for rec in (
            with v_movie_recs as (    
                select genre_rank,
                       genre,
                       movie_id,
                       movie_rank
                from v_movie_recommendations
                where cust_id = this_custid
                  and movie_id not in (select movie_id from broken_movies)
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
                                key 'runtime' is m.runtime,
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
            if debug_on then
                moviestream_write(rec.doc);        
            end if;

            pageJson :=  pageJson || ', ' || rec.doc  ;   

        end loop
        ;

        -- End shelves and doc
        pageJson := pageJson || '] }';

        if debug_on then
            moviestream_write(pageJson);
        end if;


        return pageJson;

        EXCEPTION
            WHEN others THEN
            raise;
            return sqlerrm;    


    end getLandingPageDoc;


    function is_valid_custid (
        this_custid number
    ) return boolean 
    is
        found number;
        e_bad_custid EXCEPTION;
        PRAGMA exception_init( e_bad_custid, -20001 );

    begin
        -- check for valid customer.
        select count(*)
        into found
        from customer
        where cust_id = this_custid;

        if found = 0 then
            return false;
        end if;

        return true;

        EXCEPTION
            WHEN others THEN
            return false;   

    end is_valid_custid;


    /**********************************************
     * 
     * populate landing page collection
     *
     */
    procedure populate_landingpage_collection (
        this_custid number
    )

    is
        l_collection    soda_collection_t;
        l_doc           soda_document_t;
        l_thePage       clob;
        n               number;
        l_docKey        varchar2(100);
        l_collection_name varchar2(100) := 'landingPage';
    begin

        if not is_valid_custid (this_custid) then
            moviestream_write('in procedure:  populate_landingpage_collection');
            moviestream_write('cust_id ' || this_custid || ' is invalid');
            return;
        end if;

        l_collection := dbms_soda.open_collection(
                    collection_name => l_collection_name);

        for l_custrec in (
            select cust_id
            from demo_customers
            where cust_id = this_custid
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
    end populate_landingpage_collection;


    /**********************************************
     * 
     * populate movie collection
     *
     */
    procedure populate_movie_collection 
    as

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
    end populate_movie_collection;


    /**********************************************
     * 
     * populate moviDetails collection
     *
     */
    procedure populate_moviedetails_collection as
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
    end populate_moviedetails_collection;


    /**********************************************
     * 
     * populate customer collection
     *
     */
    procedure populate_customer_collection (
        this_custid number
    ) as
        coll    soda_collection_t;
        md      varchar2(4000);
        doca    soda_document_t;
        thePage clob;
        n       number;
        docKey  varchar2(100);
        colname varchar2(100) := 'customerCollection';
    begin

        if not is_valid_custid (this_custid) then
            return;
        end if;

        coll := dbms_soda.open_collection(
                    collection_name => colname);

        for c in (  select doc
                    from v_customer_collection
                    where to_number(json_value(doc, '$.cust_id')) = this_custid)
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
    end populate_customer_collection;

    /**********************************************
     * 
     * populate learn-how collection
     *
     */
    procedure populate_learnmore_collection  as
        coll    soda_collection_t;
        md      varchar2(4000);
        doca    soda_document_t;
        thePage clob;
        n       number;
        docKey  varchar2(100);
        colname varchar2(100) := 'learnMoreCollection';
    begin

        coll := dbms_soda.open_collection(
                    collection_name => colname);

        for c in (  
            select json_object(
                key 'id' is id,
                key 'title' is title,
                key 'description' is description,
                key 'linkTitle' is link_title,
                key 'linkDescription' is link_description,
                key 'link' is link
            ) as doc
            from learn_more
            order by id asc
        )
        loop        
            docKey := json_value(c.doc, '$.title');

            -- Create documents.
            doca := soda_document_t(
                        key => docKey, 
                        b_content => utl_raw.cast_to_raw(c.doc)
                        );

            n := coll.save(doca);
            -- dbms_output.put_line('Status: ' || n);
            commit;

        end loop;
    end populate_learnmore_collection;

    /**********************************************
     * 
     * populate notification collection
     *
     */
    procedure populate_notification_collection (
        this_custid number
    ) is
        coll    soda_collection_t;
        md      varchar2(4000);
        doca    soda_document_t;
        thePage clob;
        n       number;
        docKey  varchar2(100);
        colname varchar2(100) := 'notificationCollection';
    begin

        if not is_valid_custid (this_custid) then
            return;
        end if;

        coll := dbms_soda.open_collection(
                    collection_name => colname
                    );                         

        for c in (  select doc
                    from v_notification_collection
                    where cust_id = this_custid
                )
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
    end populate_notification_collection;


end movieapp;

/

grant soda_app to package movieapp;