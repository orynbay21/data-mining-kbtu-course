--DESCRIPTIVE STATISTICS
--Price Analysis

--Find the Median price of car for each city
--See the difference between the PERCENTILE_DISC and PERCENTILE_CONT values
SELECT
    City,
    MAX(disc_percentile) as median_disc,
    MAX(cont_percentile) as median_cont
FROM
(
    SELECT
        City,
        price,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY price DESC) OVER (PARTITION BY City) AS disc_percentile,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price DESC) OVER (PARTITION BY City) AS cont_percentile
    FROM [carmarket2023].[dbo].[carmarket2023]
) AS MedianCity
GROUP BY
   City;

--Median price irrespective of the city
SELECT
    MAX(disc_percentile) as median_disc,
    MAX(cont_percentile) as median_cont
FROM
(
    SELECT
        price,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY price DESC) OVER () AS disc_percentile,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price DESC) OVER () AS cont_percentile
    FROM [carmarket2023].[dbo].[carmarket2023]
) AS MedianOverall;


--Find the Mean Price irrespective of the city
SELECT AVG(price) AS MeanPrice
FROM [carmarket2023].[dbo].[carmarket2023]

--Find Extreme Outliers by Price using IQR

WITH prices AS (
    SELECT price,
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) OVER() AS Q1,
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) OVER() AS Q3
    FROM [carmarket2023].[dbo].[carmarket2023]
)

SELECT price
FROM prices
WHERE price < Q1 - 1.5 * (Q3 - Q1)
   OR price > Q3 + 1.5 * (Q3 - Q1);

--Find Extreme Price Outliers using Zscore

SELECT
    Brand,Model,Price,zscore
FROM (
    SELECT
        Brand,
        Model,
		Price,
        (Price - AVG(Price) OVER ()) / STDEV(Price) OVER () as zscore
   FROM [carmarket2023].[dbo].[carmarket2023]
) AS DerivedTable
WHERE zscore > 2.576 OR zscore < -2.576;

--Calculate a 95% confidence interval for the price of cars.
SELECT
    AVG(Price) AS AvgPrice,
	SQRT(VAR(Price)) as StdDev,
     SQRT(VAR(Price)) / SQRT(COUNT(*)) * 1.96 AS MarginOfError,
    AVG(Price) -  SQRT(VAR(Price)) / SQRT(COUNT(*)) * 1.96 AS LowerBound,
    AVG(Price) +  SQRT(VAR(Price))/ SQRT(COUNT(*)) * 1.96 AS UpperBound
FROM [carmarket2023].[dbo].[carmarket2023];

--What is the most expensive car on sale in 2020?
SELECT  TOP 1 *
FROM [carmarket2023].[dbo].[carmarket2023]
ORDER BY price DESC;
--What is the cheapest?
SELECT  TOP 1 *
FROM [carmarket2023].[dbo].[carmarket2023]
ORDER BY price ASC;


--BRAND AND MODEL ANALYSIS
--What are the TOP 10 car brands most frequently listed for sale in 2023?
SELECT TOP 10 Brand, COUNT(Brand) as BrandCount
FROM [carmarket2023].[dbo].[carmarket2023]
where Brand is not null
GROUP BY Brand
ORDER BY BrandCount DESC;

SELECT TOP 10 Model, COUNT(Model) as ModelCount
FROM [carmarket2023].[dbo].[carmarket2023]
where Model is not null 
GROUP BY Model
ORDER BY ModelCount DESC;


--What the percentage of the market is overtaken by Toyota Hilux?
SELECT
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [carmarket2023].[dbo].[carmarket2023])) AS ToyotaMarketPer
FROM
    [carmarket].[dbo].[carmarket]
WHERE
    Brand = 'Toyota' AND Model = 'Hilux';

--Since Toyota is the most popular brand
--What is the Distribution of its Models on the Market?
--What is the Mean Price for each such Model?
WITH ToyotaDistribution AS (
    SELECT Model, COUNT(*) AS ToyotaFrequency,ROUND(AVG(price),0) as ToyotaModelAvg
	FROM [carmarket2023].[dbo].[carmarket2023]
	WHERE Brand='Toyota'
    GROUP BY Model
)
SELECT
    Model,ToyotaFrequency,ToyotaModelAvg
FROM ToyotaDistribution
ORDER BY ToyotaFrequency desc;

--What percentage of cars on sale where NEW/USED?
SELECT
     UsedOrNew,
    COUNT(*) AS count,
	(COUNT(*) * 100 / (SELECT COUNT(*) FROM [carmarket2023].[dbo].[carmarket2023])) AS presencePercentage
FROM [carmarket2023].[dbo].[carmarket2023]
WHERE UsedOrNew is not null
GROUP BY UsedOrNew
ORDER BY UsedOrNew;

--Percentage of each fuel type?
SELECT
      FuelType,
    COUNT(*) AS count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [carmarket2023].[dbo].[carmarket2023])) AS percentage_presence
FROM [carmarket2023].[dbo].[carmarket2023]
WHERE FuelType is not null
GROUP BY FuelType
ORDER BY FuelType;
--What percentage of cars on the market have extremely high mileage?
SELECT
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM [carmarket2023].[dbo].[carmarket2023])) AS HighMileage
FROM
    [carmarket2023].[dbo].[carmarket2023]
WHERE
    kilometres>=200000;

