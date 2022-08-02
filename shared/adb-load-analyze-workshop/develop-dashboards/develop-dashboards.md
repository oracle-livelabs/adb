

```
create or replace view sales_dashboard as 
select 
    ce.last_name,
    ce.first_name,
    cs.short_name as customer_segment,
    c.day_id,
    g.name genre,
    m.title,
    m.budget,
    m.gross,
    m.year as released,
    m.cast,
    m.crew,
    m.awards,
    m.nominations,
    1 as views,
    actual_price as sales        
from customer_extension ce, custsales c, genre g, movie m, customer_segment cs
where ce.cust_id = c.cust_id
  and g.genre_id = c.genre_id
  and m.movie_id = c.movie_id
  and ce.segment_id = cs.segment_id;

```