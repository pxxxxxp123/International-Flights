--Creating a table for the year 2000
/*
CREATE TABLE combined(
	country_name nvarchar(100),
	country_code nvarchar(50),
	region nvarchar(50),
	val float,
	income nvarchar(50),
	notes nvarchar(1200),
);
*/

Insert INTO combined (country_name, country_code, region, val, income, notes)
SELECT A.column1 as "country_name", A.column2 as "country_code", c.Region , a.column61 as val, c.IncomeGroup, c.SpecialNotes
FROM Airport as A
JOIN country AS c ON A.column2 = c.Country_code

/*
SELECT *
FROM combined;

SELECT
    ISNULL(region, 'Unknown') AS region,
    AVG(ISNULL(val, 0)) AS average_val
FROM
    combined
GROUP BY
    ISNULL(region, 'Unknown');
*/
--No. of Visitor Per Capita
SELECT T.Country, T.total/P.Population_2020 as "No. of Visitor Per Capita"
FROM(
	SELECT DISTINCT(T.Country) AS Country, SUM(T.Passengers) AS total
	FROM top100 as T
	GROUP BY Country
) AS T
LEFT JOIN Population as P ON T.Country = P.Country_or_dependency
ORDER BY T.total/P.Population_2020 desc;

/*
For the year of 2020, the Qatar has the highest number of
Visitor per Capita, followed by UAE and Singapore.
*/

--Comparing to GDP
SELECT *
FROM GDP;

SELECT *
FROM(
	SELECT 'Average GDP' as "Row_Name", AVG(Y2020) as "Average GDP of Top 100 countries"
	FROM(
		SELECT DISTINCT(T.Country) AS Country, SUM(T.Passengers) AS total
		FROM top100 as T
		GROUP BY Country
	) AS T
	LEFT JOIN GDP as G ON T.Country = G.Country
	WHERE Y2020 IS NOT NULL
) as S, (
	SELECT AVG(Y2020) as "Average GDP of all countries"
	FROM GDP
) as G;

/*
The average GDP of the top100 countries has approximately 4 times more than the average GDP of the world
*/

SELECT *
FROM top100;


SELECT ISNULL(REGION, 'UNKNOWN') AS Region, SUM(DISTINCT(Passengers)) as Total_Passenger
FROM top100 AS T
LEFT JOIN combined as C on C.country_name = T.Country
GROUP BY region
ORDER BY Total_Passenger desc;

/*
Recal that the top 3 country with most visitors per capita is Qatar, UAE and Singapore. However it can be seen that the region that they are in, middle east and South Asia, are ranked 5th and 7th.
Question to be asked, why so?
2 plausible reasoning: 1) Small Population but popular tourist destination 2) Region not well developed
*/

--To tackle 1, we can normalise the data and check the visitor per capita
SELECT 
    T.Country, 
    T.total / (CAST(P.Population_2020 AS FLOAT) / M.most) AS "No. of Visitor Per Capita"
FROM (
    SELECT DISTINCT(T.Country) AS Country, SUM(T.Passengers) AS total
    FROM top100 as T
    GROUP BY Country
) AS T
INNER JOIN (
    SELECT MAX(Population_2020) AS most
    FROM Population
) AS M ON 1=1
LEFT JOIN Population as P ON T.Country = P.Country_or_dependency
ORDER BY "No. of Visitor Per Capita" DESC;

/*
After normalizing, the top 3 country remain the same. Therefore, it can be concluded that the region is underdeveloped. While the top 3 countries are famous tourist destination.
*/

SELECT *
FROM Airport;

SELECT *
FROM top100;

SELECT *
FROM combined

--Ratio of people travelling through Air compared to other routes
--Because ALLTravelers is based on the average over the years, if the ratio is computed to be 0, it is safe to say most of the travellers are by air
SELECT Country, 
		CASE
			WHEN(AllTravelers - FlyingTravellers)/FlyingTravellers < 0 THEN 0
			ELSE (AllTravelers - FlyingTravellers)/FlyingTravellers 
		END AS "Ratio of other mode of travelling to Air travelling"
FROM (
	SELECT T.Country, SUM(DISTINCT(T.Passengers)) AS AllTravelers, C.val AS FlyingTravellers
	FROM top100 AS T
	INNER JOIN combined AS C ON C.country_name = T.Country
	GROUP BY T.Country, C.val
) AS T1
ORDER BY "Ratio of other mode of travelling to Air travelling" DESC;

