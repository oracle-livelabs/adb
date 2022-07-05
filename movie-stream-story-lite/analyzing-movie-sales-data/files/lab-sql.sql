-- Revenge of the Pink Panther
-- INNER JOIN
SELECT 
    c.movie_id, 
    t.day_id,
    COUNT(*)
FROM custsales c 
     INNER JOIN time t ON c.day_id = t.day_id
WHERE t.week_woy = '51'
and c.movie_id = 2527
GROUP BY c.movie_id,t.day_id
ORDER BY t.day_id;

SELECT 
    c.movie_id, 
    t.day_id,
    COUNT(*)
FROM custsales c 
     INNER JOIN time t ON c.day_id = t.day_id
WHERE t.month_name = 'DECEMBER'
  AND t.day_dom between '17' and '22'
and c.movie_id = 2527
GROUP BY c.movie_id,t.day_id
ORDER BY t.day_id;

SELECT 'marty' FROM dual;
 