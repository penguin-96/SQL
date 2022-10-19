--https://www.w3schools.com/sql/default.asp
--https://www.w3resource.com/sql-exercises/movie-database-exercise/joins-exercises-on-movie-database.php

/*Q1*/
SELECT p.Name Director_Name, m.title Movie , g.Name Genre , m.year
from Person p, Genre g, M_Director md, M_Genre mg, Movie m 
ON p.PID = md.PID AND m.MID = md.MID AND m.MID = mg.MID AND g.Name LIKE '%Comedy%' 
AND m.year %4= 0
GROUP BY p.Name, m.title

/*Q2*: All actos from movie Anand (1971)*/
SELECT p.Name Actor
from Person p, M_Cast mc, Movie m  
ON TRIM(mc.PID) = TRIM(p.PID) AND mc.MID = m.MID 
WHERE m.title = 'Anand'

/*Q3*: Actors acted in film before 1970 and in a film after 1990 */
SELECT p.Name Actor from Person p
WHERE TRIM(p.PID) IN 
(SELECT TRIM(PID) from M_Cast mc where mc.MID IN 
(SELECT m.MID from Movie m WHERE m."year"< 1970)
INTERSECT SELECT TRIM(PID) from M_Cast mc where mc.MID IN 
(SELECT m.MID from Movie m WHERE m."year"> 1990))

/*Q4*: Directors with 10 movies or more in descending order */
SELECT DISTINCT p.Name, count(*) Movie_Count
from Person p
join M_Director md on md.PID = p.PID
group BY md.PID
HAVING COUNT(*)>= 10 ORDER BY Movie_Count DESC 


/*Q5: For each year, count the number of movies in that year that had only female actors. */
-- getting all mids for pids where pid is male
-- get count of all the movies by year
-- combine the 2 where movies not in 1 list
			/*SELECT m."year" , COUNT(*) 
			from Movie m 
			WHERE m.MID IN (SELECT DISTINCT mc.mid
							from M_Cast mc
							join Person p  on TRIM(p.PID) = TRIM(mc.PID) 
							WHERE p.Gender LIKE '%Female%'
								)	
			GROUP BY m."year" */
SELECT m2."year" , COUNT(*) 
FROM Movie m2 
WHERE m2.MID NOT IN (SELECT mc.MID 
					FROM M_Cast mc,Person p
					join Movie m on mc.MID = m.MID
					WHERE p.gender='Male' and mc.MID = m.MID
					and Trim(mc.PID) = Trim(p.PID))
GROUP BY m2."year" 


/*Q6: report for each year the percentage of movies in that year with only female actors, and the total number of movies made that year. .*/

                     

/* Q7: film(s) with the largest cast. Return the movie title and the size of the cast. By "cast size" we mean the number of distinct actors that played in that movie: 
 * if an actor played multiple roles, or if it simply occurs multiple times in casts, we still count her/him only once*/
SELECT m.title 'Movie' , Count(DISTINCT Trim(mc.pid)) 'Cast Size'
from M_Cast mc 
join Movie m on m.MID = mc.MID 
group by mc.MID 
ORDER BY Count(DISTINCT Trim(mc.pid)) DESC 



/*Q8: A decade is a sequence of 10 consecutive years. For example, say in your database you have movie information starting from 1965. 
 * Then the first decade is 1965, 1966, ..., 1974; the second one is 1967, 1968, ..., 1976 and so on. 
 * Find the decade D with the largest number of films and the total number of films in D.*/
--table with all the decades
--table with all the movies in 1 year
-- table summing all the movies and grouped by decades between start and end year
WITH 
	DECADE_COUNT AS
	(SELECT DISTINCT 
		CAST(SUBSTRING(M."YEAR", -4) AS UNSIGNED)  'YEAR',      -- USING SUBSTRING BECAUSE OF ROMAN YEARS AND SPACES. EXTRACTING ONLY THE NO PART AND CASTING IT TO NON-NEG
		CAST(SUBSTRING(M."YEAR", -4) AS UNSIGNED)  'DECADE_START',
		CAST(SUBSTRING(M."YEAR", -4) AS UNSIGNED)+9  'DECADE_END',
		'DECADE OF '|| CAST(SUBSTRING(M."YEAR", -4) AS UNSIGNED) 'DECADE' 
	FROM MOVIE M),
	MOVIE_COUNT AS
	(SELECT 
		CAST(SUBSTRING(M."YEAR", -4) AS UNSIGNED)  'YEAR', COUNT(*) 'NO_OF_MOVIES'
	FROM MOVIE M 
	GROUP BY CAST(SUBSTRING(M."YEAR", -4) AS UNSIGNED)),
	MOVIE_IN_DECADE AS 
	(SELECT 
		DC.DECADE 'DECADE', SUM(NO_OF_MOVIES) 'TOTAL_MOVIES'
	FROM MOVIE_COUNT MC, DECADE_COUNT DC
	WHERE MC."YEAR" BETWEEN DC.DECADE_START AND DC.DECADE_END
	GROUP BY DC.DECADE)
SELECT DECADE, TOTAL_MOVIES
FROM MOVIE_IN_DECADE


/*Find the actors that were never unemployed for more than 3 years at a stretch. (Assume that the actors remain unemployed between two consecutive movies*/
SELECT Actor, Gap_Year
FROM (SELECT p.name 'Actor', Cast(SUBSTRING(m."year", -4) as unsigned) 'Year',

lag(Cast(SUBSTRING(m."year", -4) as unsigned),1) over (partition by trim(mc.pid) order by Cast(SUBSTRING(m."year", -4) as unsigned)) AS 'Prev_Working_year',

(Cast(SUBSTRING(m."year", -4) as unsigned) - lag(Cast(SUBSTRING(m."year", -4) as unsigned),1) over (partition by trim(mc.pid) order by Cast(SUBSTRING(m."year", -4) as unsigned))) Gap_Year

from M_Cast mc 

join Movie m on m.MID = mc.MID 

JOIN Person p on Trim(p.PID) = trim(mc.pid) 

ORDER BY trim(mc.pid), Cast(SUBSTRING(m."year", -4) as unsigned))
WHERE Gap_Year < 4
Group by Actor
ORDER by 2 DESC 


/*Q9: all the actors that made more movies with Yash Chopra than any other director*/
-- find no. of movies with yash (1)
-- find no of movies with all the directors (2)
-- find max of no. of movies with other directorrs and not yash (3)
-- comparre 1 and 3
WITH 
Movie_with_Yash AS 
(SELECT COUNT(DISTINCT md.MID) Movie_Count, p.pid Actor, md.PID Director
FROM M_Director md 
join M_Cast mc on md.MID = mc.MID
JOIN Person p on Trim(mc.PID) = Trim(p.PID) 
WHERE md.PID LIKE '%nm0007181%'
GROUP BY md.PID, mc.PID
ORDER by 1 DESC ),
Movie_with_Directors AS 
(SELECT TRIM(MC.PID) ACTORS, TRIM(MD.PID) DIRECTORS,
COUNT(Distinct TRIM(MD.MID)) 'No_of_Movies_Togethere', DENSE_RANK() over (PARTITION by TRIM(MC.PID) order by COUNT(Distinct TRIM(MD.MID)))
FROM M_CAST MC, M_DIRECTOR MD
WHERE TRIM(MC.MID) = TRIM(MD.MID)
GROUP BY ACTORS, DIRECTORS),
Other_directors_Movies AS 
(SELECT Actors, max(No_of_Movies_Togethere) Movie_Count
from Movie_with_Directors mdd , Movie_with_Yash my
WHERE mdd.DIRECTORS <> my.Director
Group by Actors),
select_count AS 
(SELECT my.Actor,
case when my.Movie_Count > ifnull(od.Movie_Count, 0) then '1' else 'NA' end Max_with_Yash
from Movie_with_Yash my
LEFT OUTER JOIN Other_directors_Movies OD ON my.Actor = OD.Actors)
SELECT Distinct p.name Actor
from Person p 
join select_count sc on Trim(sc.Actor) = Trim(p.PID) 
WHERE sc.Max_with_Yash LIKE '%Yes%'
