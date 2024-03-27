/** Olympic event project **/

SELECT *
FROM athlete;

/** 1. Mention the total number of nations who participated in each olympics games? **/

SELECT games, COUNT(DISTINCT team) as numb_team
FROM athlete
GROUP BY games;


/** 2. WHich year saw the highest and lowest number of countries participating in olympics? **/
/** 2_a.year with highest number of participants **/

SELECT TOP 1 year, COUNT(DISTINCT team) as Participating_nation
FROM athlete
GROUP BY year
ORDER BY Participating_nation DESC;

/** 2_b. year with lowest number of participants **/

SELECT year, COUNT(DISTINCT team) as Participating_nation
FROM athlete
GROUP BY year
ORDER BY Participating_nation ASC
LIMIT 1;

/** 3. Which nation has participated in all of the olympic game? **/

SELECT team
FROM athlete
GROUP BY team
HAVING COUNT(DISTINCT year) = (SELECT COUNT(DISTINCT year) FROM athlete);

/** 4. identify the sport which was played in all summer olympics **/
SELECT sport
FROM athlete
WHERE season = 'Summer'
GROUP BY sport
having COUNT(DISTINCT year)=(SELECT COUNT(DISTINCT year) FROM athlete WHERE season = 'Summer');

/** 5. which sports were just played only once in the olympics? **/

SELECT sport, COUNT(DISTINCT year) as played_once
FROM athlete
GROUP BY sport
HAVING COUNT(DISTINCT year) = 1;

/** 6. Fetch the total number of sports played in each olympics games **/

SELECT games, year, COUNT(DISTINCT sport) as numb_sport
FROM athlete
GROUP BY games, year;

/** 7. Fetch details of the oldest athletes to win a gold medal **/
SELECT*
FROM athlete
WHERE medal = 'Gold' and age <> 'NA'
ORDER  BY AGE DESC;

/** 8. Find the ratio of male and female athletes participated in all olympic games **/

SELECT
    games,
    SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS MaleAthletes,
    SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) AS FemaleAthletes,
    SUM(CASE WHEN sex IN ('M', 'F') THEN 1 ELSE 0 END) AS TotalAthletes,
    SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) * 1.0 / SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS FemaleToMaleRatio
FROM athlete
GROUP BY games;

/** 9. Fetch the top 5 athletes who have won the most gold medals **/
SELECT name, SUM (CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) as gold_medals
FROM athlete
GROUP BY name
ORDER by gold_medals DESC
limit 5;

/** other way of doing it **/

WITH t1 as 
	(SELECT name, COUNT(1) as gold_medals
	FROM athlete
	WHERE medal = 'Gold'
	GROUP BY name
	ORDER by count(1) DESC),
t2 as 
	(SELECT*, dense_rank() over (order by gold_medals DESC) as rnk
	 FROM t1)
SELECT*
FROM t2
WHERE rnk <= 5;

/** 10. Fetch the top 5 athletes who have won the most medal(gold/silver/bronze) **/
SELECT name, 
       SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) as gold_medals,
       SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) as silver_medals,
       SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) as bronze_medals,
       SUM(CASE WHEN medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) as total_medals
FROM athlete
WHERE medal <> 'NA'
GROUP BY name
ORDER by total_medals DESC
limit 5;

/** 11. Fetch the 5 most successful countries in olympics. success is defined by number of medals won **/

SELECT team, 
	SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) as gold_medals,
    SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) as silver_medals,
    SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) as bronze_medals,
	SUM(CASE WHEN medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) as total_medals
FROM athlete
WHERE medal <> 'NA'
GROUP BY team
ORDER by total_medals DESC
limit 5;

/** Which country won the most gold, most silver, most bronze medals in each olympic games? **/

WITH MedalCounts AS (
    SELECT
        games,
        team AS country,
        SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS GoldCount,
        SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS SilverCount,
        SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeCount
    FROM athlete
    GROUP BY games, team
)
, RankedMedals AS (
    SELECT
        games,
        country,
        GoldCount,
        SilverCount,
        BronzeCount,
        RANK() OVER (PARTITION BY games ORDER BY GoldCount DESC) AS GoldRank,
        RANK() OVER (PARTITION BY games ORDER BY SilverCount DESC) AS SilverRank,
        RANK() OVER (PARTITION BY games ORDER BY BronzeCount DESC) AS BronzeRank
    FROM MedalCounts
)
SELECT
    games AS OlympicGames,
    MAX(CASE WHEN GoldRank = 1 THEN country END) AS GoldWinner,
    MAX(GoldCount) AS MostGoldMedals,
    MAX(CASE WHEN SilverRank = 1 THEN country END) AS SilverWinner,
    MAX(SilverCount) AS MostSilverMedals,
    MAX(CASE WHEN BronzeRank = 1 THEN country END) AS BronzeWinner,
    MAX(BronzeCount) AS MostBronzeMedals
FROM RankedMedals
GROUP BY games
ORDER BY games DESC;
