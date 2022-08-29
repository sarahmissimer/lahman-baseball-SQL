--random table for how many games each player has played;
SELECT p.namegiven, a.g_all
FROM people AS p
JOIN appearances AS a
USING (playerid);

--- What range of years for baseball games played does the provided database cover?
SELECT namegiven, debut
FROM people
WHERE debut IS NOT NULL
ORDER BY debut ASC;
---ANSWER: 1871-2017 (2016 season)

---Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT p.namegiven, MIN(p.height) AS height, a.g_all, p.namelast, t.name
FROM people AS p
JOIN appearances AS a
USING (playerid)
JOIN teams AS t
USING (teamid)
WHERE p.height IS NOT null
GROUP BY p.namegiven, a.g_all, p.namelast, t.name
ORDER BY height ASC
LIMIT 1;
--- Edward Gaedel, 43", 1, St. Louis Browns

---Find all players in the database who played at Vanderbilt University. (A)Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned.(B) Which Vanderbilt player earned the most money in the majors?

SELECT p.namefirst AS first, p.namelast AS last, c.schoolid, CAST(CAST(SUM(DISTINCT s.salary) AS numeric)  as money) AS salary
FROM collegeplaying AS c
JOIN people AS p
USING (playerid)
JOIN salaries AS s
USING (playerid)
WHERE schoolid = 'vandy'
AND p.namefirst = 'David'
GROUP BY p.namefirst, p.namelast, c.schoolid
ORDER BY salary;
---ANSWER: DAVID PRICE, $81,851,296

--- Tried this but decided that it was repeating 3 times, which was giving us that HUGE number.
SELECT p.namefirst AS first, p.namelast AS last, c.schoolid, CAST(CAST(SUM(s.salary) AS NUMERIC) AS MONEY)
FROM collegeplaying AS c
JOIN people AS p
USING (playerid)
JOIN salaries AS s
USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast, c.schoolid
ORDER BY SUM(s.salary) DESC;


--OPT2 for Question3
SELECT p.namefirst AS first, p.namelast AS last, c.schoolid, CAST(CAST(SUM(s.salary) AS NUMERIC) AS MONEY) AS salary
FROM collegeplaying AS c
JOIN people AS p
USING (playerid)
JOIN salaries AS s
USING (playerid)
WHERE schoolid = 'vandy'
AND p.namefirst ='David'
GROUP BY p.namefirst, p.namelast, c.schoolid
ORDER BY salary;


---trying to see the salaries
SELECT p.namefirst AS first, p.namelast AS last, p.playerid, c.schoolid, CAST(CAST(s.salary AS numeric)  as money) AS salary
FROM collegeplaying AS c
JOIN people AS p
USING (playerid)
JOIN salaries AS s
USING (playerid)
WHERE schoolid = 'vandy'
AND p.namefirst = 'David'
GROUP BY p.namefirst, p.namelast, c.schoolid, s.salary, p.playerid
ORDER BY salary;

----salaries 
SELECT p.namefirst AS first, p.namelast AS last, c.schoolid, CAST(CAST(SUM(DISTINCT s.salary) AS numeric)  as money) AS salary
FROM collegeplaying AS c
JOIN people AS p
USING (playerid)
JOIN salaries AS s
USING (playerid)
WHERE schoolid = 'vandy'
AND p.namefirst = 'David'
GROUP BY p.namefirst, p.namelast, c.schoolid
ORDER BY salary;


-- used to find the schoolid for vanderbilt 
SELECT *
FROM schools
WHERE schoolcity = 'Nashville';


---THIS IS TYLER'S QUERY
WITH vandy AS(
  SELECT 
            p.namefirst,
            p.namelast,
            cp.schoolid,
            cp.playerid
          FROM collegeplaying AS cp
          JOIN people AS p ---giving me all the names in colleges amd their schoolid
          USING (playerid)
          JOIN schools AS s
          USING (schoolid)
          WHERE s.schoolname LIKE '%Vanderbilt%' ---this is giving me all the players at vandy
)
SELECT vandy.namefirst, vandy.namelast, CAST(CAST(SUM(s.salary) AS numeric) AS money) AS player_pay --have to select on the vandy CTE
    FROM vandy --this is my CTE to give us the players from vandy
    JOIN salaries AS s
    ON vandy.playerid = s.playerid --have to join on the vandy CTE 
    WHERE s.salary IS NOT null
    GROUP BY vandy.namefirst,
      vandy.namelast
    ORDER BY player_pay DESC;
    
    
    
--- TYLER'S #3 - GO BACK TO REVIEW... WORKS BECAUSE OF LEFT JOIN
SELECT CONCAT(vandy.namefirst, ' ', vandy.namelast) AS name,
      CAST(CAST(SUM(s.salary) AS numeric) AS money) AS player_pay
    FROM (SELECT p.playerid,
            p.namefirst,
            p.namelast
          FROM people AS p
          LEFT JOIN collegeplaying AS cp
          USING (playerid)
          JOIN schools AS s
          USING (schoolid)
          WHERE s.schoolname LIKE '%Vanderbilt%'
          GROUP BY p.playerid) AS vandy
    JOIN salaries AS s
    ON vandy.playerid = s.playerid
    WHERE s.salary IS NOT null
    GROUP BY vandy.namefirst,
      vandy.namelast
    ORDER BY player_pay DESC;


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
--fielding table, people table
--position 
--looking to make a table w/ 3 groups

SELECT SUM(po) AS putouts,
CASE WHEN pos = 'OF' THEN 'Outfield' ---you can use an 'IN'to get it prettier
    WHEN pos = 'SS' OR pos = '1B' OR pos= '2B' OR pos='3B' THEN 'Infield'
    WHEN pos = 'P' OR pos='C' THEN 'Battery'
    END AS position
FROM fielding
WHERE yearid = 2016
GROUP by position;
---ANSWER: Battery, 41424; Infield, 58934; Outfield, 29560


-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- look at teams, batting, pitching, people tables
-- be sure to ROUND to 2 decimals
-- find the average
-- i need the year to be a decade, 

SELECT CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
            WHEN yearid BETWEEN 1930 AND 1939 THEN '1930S'
            WHEN yearid BETWEEN 1940 AND 1949 THEN '1940S'
            WHEN yearid BETWEEN 1950 AND 1959 THEN '1950S'
            WHEN yearid BETWEEN 1960 AND 1969 THEN '1960S'
            WHEN yearid BETWEEN 1970 AND 1979 THEN '1970S'
            WHEN yearid BETWEEN 1980 AND 1989 THEN '1980S'
            WHEN yearid BETWEEN 1990 AND 1999 THEN '1990S'
            WHEN yearid BETWEEN 2000 AND 2009 THEN '2000S'
            WHEN yearid BETWEEN 2010 AND 2019 THEN '2010S'
                END AS decade,
           ROUND(CAST(SUM(so) AS DECIMAL)/CAST(SUM(g/2) AS DECIMAL), 2) AS avg_strikeouts,
           ROUND(CAST(SUM(hr) AS DECIMAL)/CAST(SUM(g/2) AS DECIMAL), 2) AS avg_homeruns
FROM teams
WHERE yearid >=1920
GROUP BY 1
ORDER BY 1;
---ANSWER: 
"1920s"	5.65	0.81
"1930S"	6.65	1.09
"1940S"	7.12	1.05
"1950S"	8.82	1.69
"1960S"	11.45	1.64
"1970S"	10.31	1.49
"1980S"	10.75	1.62
"1990S"	12.31	1.92
"2000S"	13.13	2.15
"2010S"	15.05	1.97

-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
--SB stolen base--- how many times they have successfully stolen
--CS caught stealing + stolen base (total attempts)
--stolen bases/stolen bases + caught stealing 
--can use the batting table and the player id


SELECT p.namefirst, p.namelast, b.sb/b.cs AS total_attempts
FROM batting AS b
JOIN people AS p
USING (playerid)
WHERE yearid = '2016' and sb>=20
GROUP BY p.namefirst, p.namelast, b.sb, b.cs
ORDER BY total_attempts DESC;
---ANSWER: CHRIS OWINGS

--7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
---there are 47 teams

---pt1 largest number of wins for a team that did not win the world series
SELECT wswin,
name,
MAX(w), 
yearid
FROM teams
WHERE wswin LIKE 'N'
AND yearid BETWEEN 1970 AND 2016
GROUP BY name, wswin, yearid, w
ORDER BY MAX(w) DESC;
---pt1: Seattle Mariners, 116wins

--pt2 smallest number of wins for a team that did win the world series
SELECT wswin,
name,
MIN(w),
yearid
FROM teams
WHERE wswin LIKE 'Y'
AND yearid BETWEEN 1970 AND 2016
GROUP BY name, wswin, yearid, w
ORDER BY MIN(w) ASC;
--pt2: Los Angeles Dodgers, 63wins

--query redo: 
SELECT wswin,
name,
MIN(w),
yearid
FROM teams
WHERE wswin LIKE 'Y'
AND yearid BETWEEN 1970 AND 2016
AND yearid <> 1981
GROUP BY name, wswin, yearid, w
ORDER BY MIN(w) ASC;
-- St. Louis Cardinals, 83wins

--pt3: How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? Basically, I need to know 




WITH CTE AS
(
    SELECT wswin, --this tells me which teams won the world series, year and the most games
name,
MAX(w), 
yearid
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016
AND yearid <> 1981
GROUP BY name, wswin, yearid, w
ORDER BY MAX(w) DESC)

SELECT yearid, t.name,t.wswin, MAX(w) ---all the teams that have won the world series (45teams) 
FROM teams AS t
JOIN CTE 
USING (yearid)
WHERE yearid BETWEEN 1970 AND 2016
AND yearid <>1981
GROUP BY yearid, t.name, t.wswin
-- ORDER BY MAX(w) DESC;



-- 9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
--managers that have won TSN Manager of the year in both leagues
--need their full anme and team they were managing
-- teams, awardsmanager
SELECT *
FROM teams

SELECT DISTINCT /*playerid AS managers*/ people.namefirst, people.namelast, teams.name ---managers that won the award in each league
FROM awardsmanagers
JOIN people
USING (playerid)
JOIN teams
USING (lgid)
WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL' , 'NL')

----working query 
SELECT DISTINCT name AS team_name, managers.namefirst, managers.namelast  --this is the teams the managers were managing when they won
FROM (
    SELECT playerid AS managers, lgid, p.namefirst, p.namelast ---managers that won the award in each league
    FROM awardsmanagers
    JOIN people AS p
    USING (playerid)
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL' , 'NL')) AS managers
JOIN teams 
USING (lgid)

---trying to make playerid work
-- SELECT DISTINCT name AS namefirst, namelast  --this is the teams the managers were managing when they won
-- FROM (
--     SELECT playerid AS managers, lgid ---managers that won the award in each league
--     FROM awardsmanagers
--     WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL' , 'NL')) AS managers
-- JOIN people 
-- USING (playerid)


SELECT DISTINCT namefirst, namelast, a.awardid, a.lgid, t.name ---this is the managers namea.
FROM people
JOIN awardsmanagers AS a
USING (playerid)
JOIN teams AS t
USING (yearid)
WHERE a.awardid = 'TSN Manager of the Year' AND a.lgid IN ('AL', 'NL')
GROUP BY namefirst, namelast, a.awardid, a.yearid, a.lgid, t.name
-- ORDER BY a.yearid



----cte time
WITH CTE_managerteam AS
(SELECT namefirst, namelast, awardid ---this is the managers name
FROM people
JOIN awardsmanagers
USING (playerid)
WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL', 'NL'))
SELECT CTE_managerteam, name AS team_name  --this is the teams the managers were managing when they won
FROM ---managers ---
    (SELECT playerid AS managers, lgid ---managers that won the award in each league
    FROM awardsmanagers
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL' , 'NL')) AS managers
JOIN teams 
USING (lgid);




SELECT DISTINCT name AS team_name,
    (SELECT namefirst, namelast, awardid ---this is the managers name
    FROM people
    JOIN awardsmanagers
    USING (playerid)
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL', 'NL')) AS manager_name--this is the     teams the managers were managing when they won
FROM 
    (SELECT playerid AS managers, lgid ---managers that won the award in each league
    FROM awardsmanagers
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL' , 'NL')) AS managers
JOIN teams 
USING (lgid);


---- 60 managers who won award and coach in league
SELECT namefirst, namelast
FROM people
JOIN awardsmanagers
USING (playerid)
WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL' , 'NL')

SELECT t.name, t.lgid, t.yearid, awardid
FROM teams AS t
LEFT JOIN awardsmanagers 
USING (lgid)
WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL' , 'NL')


--managers name, award, year, league ---using people and awardstable 
SELECT namefirst, namelast, awardid, yearid, lgid 
    FROM people
    JOIN awardsmanagers
    USING (playerid)
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL', 'NL')
    
    
SELECT p.namefirst, p.namelast, m.teamid
 FROM people AS p
 JOIN managers AS m
 USING (teamid)
--  JOIN awardsmanagers AS a
--  USING(playerid) 
 WHERE p.namefirst LIKE '%Hal%' AND p.namelast LIKE '%Lanier%'
--  GROUP BY t.name, p.namefirst, p.namelast, a.awardid

SELECT p.namefirst, p.namelast, m.teamid
FROM people AS p
JOIN salaries AS s
USING  (playerid)
JOIN managers AS m
USING (teamid)
WHERE p.namefirst LIKE '%Hal%' AND p.namelast LIKE '%Lanier%'
-- GROUP BY m.teamid, p.namefirst, p.namelast

--this is every manager name and team they managed 
SELECT
playerid, 
name
FROM managers
JOIN teams
USING (teamid)
-- WHERE name = 'Houston Astros'
GROUP BY playerid, name;

--managers name, award, year, league ---using people and awardstable 
SELECT namefirst, namelast, awardid, yearid, lgid 
    FROM people
    JOIN awardsmanagers
    USING (playerid)
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL', 'NL')
 
 
 
 
 WITH deargod AS (
 SELECT
playerid, 
name
FROM managers
JOIN teams
USING (teamid)
GROUP BY playerid, name)
SELECT namefirst, namelast, awardid, yearid, lgid, deargod.name 
    FROM people
    JOIN awardsmanagers
    USING (playerid)
    JOIN deargod
    USING (playerid)
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL', 'NL') 
    GROUP BY namefirst, namelast, awardid, yearid, lgid, deargod.name
    ORDER BY yearid ASC;
--     JOIN deargod
--     USING (playerid)

--3436 rows
SELECT *
FROM managers

--2835 rows
SELECT *
FROM teams

--30 active franchises 
SELECT *
FROM teamsfranchises
WHERE active = 'Y'

---90 unactive or n/a
SELECT *
from teamsfranchises
WHERE active IN ('N', 'NA')

----Team IDs and their names (183)
SELECT t.teamid, t.name
FROM managers AS m
JOIN teams AS t
USING (teamid)
GROUP BY t.teamid, t.name

--teams, their name linked to franchise (183)
SELECT t.teamid, t.name
FROM managers AS m
JOIN teams AS t
USING (teamid)
JOIN teamsfranchises
USING(franchid)
GROUP BY t.teamid, t.name

---filter to only active teams (81 teams that are 'active') ISSUE: it's giving me 81 teams... and not the 30 active franchises... 
SELECT t.teamid, t.name, tf.active
FROM managers AS m
JOIN teams AS t
USING (teamid)
JOIN teamsfranchises AS tf
USING(franchid)
WHERE active = 'Y'
GROUP BY t.teamid, t.name, tf.active
    
---making a table that has the active franchises to join to
WITH active_franchises AS (
SELECT *
FROM teamsfranchises
WHERE active = 'Y')
SELECT t.teamid, t.name, franchname, active
FROM managers AS m
JOIN teams AS t
USING (teamid)
JOIN active_franchises 
USING(franchid)
WHERE active = 'Y'
GROUP BY t.teamid, t.name, franchname, active


---active 'teams/franchises' (30) --- and i have to join on teams b/c the franchise table is floating 
WITH active_franchises AS (
SELECT *
FROM teamsfranchises
WHERE active = 'Y')---end of the CTE
SELECT franchname
FROM teams 
JOIN active_franchises
USING (franchid)
GROUP BY franchname


---should be able to use the cte with franchises to filter is the team is active 
WITH deargod AS (
 SELECT
playerid, 
franchname
FROM managers
LEFT JOIN teams
USING (teamid) ---the playerid, the franchise name
JOIN teamsfranchises
USING (franchid) --this is joining the franchise table to teams
WHERE active = 'Y' --actie means franchise active
GROUP BY playerid, franchname)
SELECT namefirst, namelast, yearid, lgid, franchname, playerid, awardid
    FROM people
    JOIN awardsmanagers
    USING (playerid)
    JOIN deargod
    USING (playerid)
    WHERE awardid = 'TSN Manager of the Year' AND lgid IN ('AL', 'NL') 
    GROUP BY namefirst, namelast, yearid, lgid, franchname, playerid, awardid
    ORDER BY yearid ASC;
    
 --this is giving me the 60 coaches (filtered to see just one) who won the award, the year and the league
 
 SELECT namefirst, namelast, awardid, yearid, lgid
    FROM people
    JOIN awardsmanagers
    USING (playerid)
    WHERE awardid = 'TSN Manager of the Year' AND  lgid IN ('AL', 'NL')
 
 SELECT playerid, franchname
 FROM managers
 JOIN teams
 USING (teamid)
 JOIN teamsfranchises
 USING (franchid)
 WHERE playerid = 'mcnamjo99'
 GROUP BY playerid, franchname
 
 
 --cte 1
 WITH CTE1 AS 
 (SELECT playerid, franchname
 FROM teams
 JOIN managers
 USING (teamid)
 JOIN teamsfranchises
 USING (franchid)
 WHERE playerid = 'mcnamjo99' AND active = 'Y'
 GROUP BY playerid, franchname),
 --cte2
 PEOPLE1 AS (
SELECT namefirst, namelast, awardid, yearid, lgid, playerid
 FROM people
 JOIN awardsmanagers
 USING (playerid)
 WHERE awardid = 'TSN Manager of the Year' AND  lgid IN ('AL', 'NL'))
 SELECT namefirst, namelast, awardid, yearid, lgid, playerid, franchname
    FROM PEOPLE1
    JOIN CTE1
    USING (playerid);
    
    
    
    
-- SELECT t.name, a.playerid
-- FROM teams AS t
-- JOIN awardsmanagers AS a
-- USING (yearid)
-- WHERE awardid = 'TSN Manager of the Year' AND t.lgid IN ('AL' , 'NL')