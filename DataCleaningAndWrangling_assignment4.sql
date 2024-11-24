--DATA CLEANING

--Observe the first 1000 rows of data and look for inconsistancies
SELECT TOP 1000 * FROM [carmarket2023].[dbo].[carmarket2023];

-- 1.STANDARDIZE THE CONVENTION 
--Handle the missing values
--An empty cell, '-' and 'nan' both represent the same NULL value

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET FuelConsumption = NULL
WHERE FuelConsumption = '-';

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET Transmission = NULL
WHERE Transmission = '-';

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET FuelType= NULL
WHERE FuelType = '-';

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET Engine= NULL
WHERE Engine = '-';

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET CylindersinEngine= NULL
WHERE CylindersinEngine = '-';

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET UsedOrNew= NULL
WHERE UsedOrNew = 'nan';

--2.STRUCTURAL ERRORS
--Fix Structural Errors and do Type Conversion

--Split 'Location' Column into 'City' and 'State' columns

--Create 'City' and 'State' Columns
ALTER TABLE [carmarket2023].[dbo].[carmarket2023]
ADD City nvarchar(255);

ALTER TABLE [carmarket2023].[dbo].[carmarket2023]
ADD State nvarchar(255);
--Scrape the values from 'Location' and update the values in 'City' and 'State'
UPDATE [carmarket2023].[dbo].[carmarket2023]
SET City=SUBSTRING(Location,1,CHARINDEX(',',Location)-1)

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET State=SUBSTRING(Location,CHARINDEX(',',Location)+1,LEN(Location)-1)

--Remove the number of cylinders from the Engine column
--Only leave the Engine Capacity in a numerical form

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET Engine= SUBSTRING(Engine, CHARINDEX('l',Engine)+2,CHARINDEX('L',Engine)+1) 

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET Engine=TRIM(Engine)

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET Engine= SUBSTRING(Engine, 1, CHARINDEX(' ', Engine))
WHERE Engine is not null;

--Remove the 'cyl' letters from CylindersinEngine Column
--Only leave the numerical value
UPDATE [carmarket2023].[dbo].[carmarket2023]
SET CylindersinEngine= SUBSTRING(Engine, 0,2)
WHERE CylindersinEngine is not null;

--Remove 'L/100km' prefixes from FuelConsumption
--Only leave the numerical value
UPDATE [carmarket2023].[dbo].[carmarket2023]
SET FuelConsumption=SUBSTRING(FuelConsumption,1, CHARINDEX(' ', FuelConsumption)-1)

--Remove 'Doors' and 'Seats' words from the data entries in the columns
--Only leave the numerical value
UPDATE [carmarket2023].[dbo].[carmarket2023]
SET Doors=SUBSTRING(Doors,1,CHARINDEX(' ',Doors)+1) 

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET Seats=SUBSTRING(Seats,1,CHARINDEX(' ',Seats)+1) 

--3.TYPE CONVERSIONS

--Type Conversions from NVARCHAR to FLOAT
--So we can perform calculations on this values
ALTER TABLE [carmarket2023].[dbo].[carmarket2023]
ALTER COLUMN Engine FLOAT;

ALTER TABLE [carmarket2023].[dbo].[carmarket2023]
ALTER COLUMN CylindersinEngine FLOAT;

ALTER TABLE [carmarket2023].[dbo].[carmarket2023]
ALTER COLUMN FuelConsumption FLOAT;

ALTER TABLE [carmarket2023].[dbo].[carmarket2023]
ALTER COLUMN Doors FLOAT;

ALTER TABLE [carmarket2023].[dbo].[carmarket2023]
ALTER COLUMN Seats FLOAT;

--4.RENAME COLUMNS
--Rename Column Names for better readability

EXEC sp_rename '[carmarket2023].[dbo].[carmarket2023].Engine', 'EngineCapacity', 'COLUMN';
EXEC sp_rename '[carmarket2023].[dbo].[carmarket2023].CylindersinEngine', 'Cylinders', 'COLUMN';

--5.HANDLE MISSING VALUES
SELECT TOP 1000 * FROM [carmarket2023].[dbo].[carmarket2023]
--I noticed a lot of records have FuelConsumption=0
--Even Though they are not electric
--Therefore their FuelConsumption should be equal to NULL and not 0

SELECT FuelConsumption,Brand,Model,FuelType
FROM [carmarket2023].[dbo].[carmarket2023]
WHERE FuelConsumption=0.
AND FuelType!='Electric'

UPDATE [carmarket2023].[dbo].[carmarket2023]
SET FuelConsumption=NULL
WHERE FuelConsumption=0
AND FuelType!='Electric'

SELECT FuelConsumption,Brand,Model,FuelType
FROM [carmarket2023].[dbo].[carmarket2023]
WHERE FuelConsumption=0.
AND FuelType!='Electric'

--6.DROP USELESS COLUMNS
--Title Column is just duplicating values from Brand,Model and Year Columns
--Drop it
ALTER TABLE  [carmarket2023].[dbo].[carmarket2023]
DROP COLUMN Title
--Columns Car/Suv and BodyType seem to duplicates in a lot of rows
--Let's explore

--What kind of values does BodyType have?How many missing values does it have?
SELECT BodyType,Count(BodyType) AS Frequency, COUNT(CASE WHEN BodyType IS NULL THEN 1 END) AS MissingValues
FROM [carmarket2023].[dbo].[carmarket2023]
GROUP BY BodyType

--Now Let's Look at Car/Suv
SELECT CarSuv,Count(CarSuv) AS Frequency, COUNT(CASE WHEN CarSuv IS NULL THEN 1 END) AS MissingValues
FROM [carmarket2023].[dbo].[carmarket2023]
GROUP BY CarSuv

--Now that we see that CarSuv is a 'garbage' column , we can drop it overall
ALTER TABLE  [carmarket2023].[dbo].[carmarket2023]
DROP COLUMN CarSuv

--Now let's save the clean data
SELECT * FROM [carmarket2023].[dbo].[carmarket2023];

