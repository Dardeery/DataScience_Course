
-- old solution 
select b.id,count(p.id) 
from passengers p,buses b 
where b.origin=p.origin and b.destination=p.destination 
    and cast(p.time as time)<=cast(b.time as time)
    group by 1
    order by 1




-- 1st part 
-- all trains all passengers can take 
SELECT *
FROM passengers p
LEFT JOIN buses b ON b.origin = p.origin AND b.destination = p.destination
    AND CAST(b.time AS TIME) > CAST(p.time AS TIME)



Returned value: 
+----+--------+--------+-------+------+--------+--------+-------+
| 44 | Berlin |  Paris | 20:00 |   22 | Berlin |  Paris | 21:40 |
| 40 | Berlin |  Paris | 06:15 |   20 | Berlin |  Paris | 06:20 |
| 40 | Berlin |  Paris | 06:15 |   21 | Berlin |  Paris | 14:00 |
| 40 | Berlin |  Paris | 06:15 |   22 | Berlin |  Paris | 21:40 |
| 41 | Berlin |  Paris | 06:50 |   21 | Berlin |  Paris | 14:00 |
| 41 | Berlin |  Paris | 06:50 |   22 | Berlin |  Paris | 21:40 |
| 42 | Berlin |  Paris | 07:12 |   21 | Berlin |  Paris | 14:00 |
| 42 | Berlin |  Paris | 07:12 |   22 | Berlin |  Paris | 21:40 |
| 43 | Berlin |  Paris | 12:03 |   21 | Berlin |  Paris | 14:00 |
| 43 | Berlin |  Paris | 12:03 |   22 | Berlin |  Paris | 21:40 |
|  2 |  Paris | Madrid | 13:31 | NULL |   NULL |   NULL |  NULL |
|  1 |  Paris | Madrid | 13:30 |   30 |  Paris | Madrid | 13:30 |
| 11 | Warsaw | Berlin | 22:31 | NULL |   NULL |   NULL |  NULL |
| 10 | Warsaw |  Paris | 10:00 | NULL |   NULL |   NULL |  NULL |
+----+--------+--------+-------+------+--------+--------+-------+





-- 2nd part
-- first train a passenger can take 

SELECT p.id AS pid, MIN(CAST(b.time AS TIME)) AS bus_dept_time
FROM passengers p
LEFT JOIN buses b ON b.origin = p.origin AND b.destination = p.destination
    AND CAST(b.time AS TIME) > CAST(p.time AS TIME)
GROUP BY p.id


Returned value: 
+----+----------+
| 11 |     NULL |
| 10 |     NULL |
|  2 |     NULL |
| 40 | 06:20:00 |
| 42 | 14:00:00 |
| 41 | 14:00:00 |
| 44 | 21:40:00 |
|  1 | 13:30:00 |
| 43 | 14:00:00 |
+----+----------+


SELECT 
id, count(*)
FROM (SELECT p.id AS pid, MIN(CAST(b.time AS TIME)) AS bus_dept_time
FROM passengers p
LEFT JOIN buses b ON b.origin = p.origin AND b.destination = p.destination
    AND CAST(b.time AS TIME) > CAST(p.time AS TIME)
GROUP BY p.id) min_pas
LEFT JOIN passengers p
ON min_pas.pid=p.id
LEFT JOIN p.origin=b.origin and b.destination=b.destination and p.time<b.time
GROUP BY 1
ORDER BY 1




WITH assigned_passenger AS (
SELECT p.id AS pid, MIN(CAST(b.time AS TIME)) AS bus_dept_time
FROM passengers p
LEFT JOIN buses b ON b.origin = p.origin AND b.destination = p.destination
    AND CAST(b.time AS TIME) >= CAST(p.time AS TIME)
GROUP BY p.id
)
SELECT b.id, COUNT(bus_dept_time)
FROM assigned_passenger ap
LEFT JOIN passengers p ON ap.pid=p.id
LEFT JOIN buses b ON (b.origin=p.origin and p.destination=b.destination)
and ap.bus_dept_time= b.time
group by b.id
order by b.id




--3rd part 


; WITH assigned_passenger AS (
    SELECT p.id  pid, MIN(CAST(b.time AS TIME)) AS bus_dept_time
    FROM passengers p
    LEFT JOIN buses b ON b.origin = p.origin AND b.destination = p.destination
        AND CAST(b.time AS TIME) >= CAST(p.time AS TIME)
    GROUP BY p.id
)
SELECT b.id, COUNT(bus_dept_time)
FROM assigned_passenger ap
LEFT JOIN passengers p ON ap.pid = p.id
LEFT JOIN buses b ON (p.origin = b.origin AND p.destination = b.destination) 
    AND (ap.bus_dept_time = CAST(b.time AS TIME) OR bus_dept_time IS NULL)
GROUP BY b.id



-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------
-- ------------------------------------------------


ref: 
https://stackoverflow.com/questions/53137307/advanced-sql-analytical-question-using-time-conversion-logic


SELECT * FROM buses;

Returned value: 
+----+--------+--------+-------+
| 10 | Warsaw | Berlin | 10:55 |
| 20 | Berlin |  Paris | 06:20 |
| 21 | Berlin |  Paris | 14:00 |
| 22 | Berlin |  Paris | 21:40 |
| 30 |  Paris | Madrid | 13:30 |
+----+--------+--------+-------+


SELECT * FROM passengers; 

Returned value: 
+----+--------+--------+-------+
|  1 |  Paris | Madrid | 13:30 |
|  2 |  Paris | Madrid | 13:31 |
| 10 | Warsaw |  Paris | 10:00 |
| 11 | Warsaw | Berlin | 22:31 |
| 40 | Berlin |  Paris | 06:15 |
| 41 | Berlin |  Paris | 06:50 |
| 42 | Berlin |  Paris | 07:12 |
| 43 | Berlin |  Paris | 12:03 |
| 44 | Berlin |  Paris | 20:00 |
+----+--------+--------+-------+

expected output;

p.id
1 > null
2> null 
10> null 
11 > nnull 
40 > 20
41 > 21
42 > 21 
43 > 21 
44 > 22 


b.id  sum pass
10 > 0
20 > 1
21 > 3
22 > 1 
30 > 0 



-- final correct results-- 

select b.id,
	 count(sub2.pass_id) passengers_on_board 
	 from buses b
			left outer join 
			(select min(sub.) as time,
					 sub.id1 pass_id, 
					 sub.org,
					  sub.des 
						from 
								(select p.id id1, 
										b.id id2,
									    b.origin org,
									    b.destination des,
									    p.time t1 ,
									    b.time  
									    from buses b join passengers p 
								on b.origin = p.origin and b.destination = p.destination and b.time >= p.time
								order by p.id, b.time)sub
								group by sub.id1, sub.org, sub.des) sub2 
								on b.origin = sub2.org and b.destination = sub2.des  and b.time = sub2.time
								group by b.id
								order by b.id
