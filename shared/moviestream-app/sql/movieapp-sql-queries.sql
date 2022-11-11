-- Use SQL to query collection
select m.doc.movie_id,
       m.doc.title
from "movieCollection" m;

-- Find Robert De Niro movies
select m.doc.movie_id,
       m.doc.title,
       m.doc.year
from "movieCollection" m
where m.doc.cast like '%De Niro%'
order by m.doc.year asc
;

-- Do our customers like his movies?
with deniro_movies as (
    select m.doc.movie_id,
           m.doc.title,
           m.doc.year
    from "movieCollection" m
    where m.doc.cast like '%De Niro%'
)
select d.title,
       count(*) as num_views
from deniro_movies d, custsales c
where d.movie_id = c.movie_id
group by d.title
order by 2 desc
;

-- create a view - will expose it to query tools
create or replace view v_movie_sales as
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
  and m.id = c.movie_id
;


