-- Create database scoped credential
CREATE DATABASE SCOPED CREDENTIAL credent
WITH IDENTITY = 'MANAGED IDENTITY'
GO

-- Create external data source
CREATE EXTERNAL DATA SOURCE mydatasrc WITH (
    LOCATION = 'abfss://live@livinlearn.dfs.core.windows.net',
    CREDENTIAL = credent
)
GO

-- Create external file format
CREATE EXTERNAL FILE FORMAT CSVFileFormat1
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (
        FIELD_TERMINATOR = ',',       
        STRING_DELIMITER = '"',       
        FIRST_ROW = 2,                
        USE_TYPE_DEFAULT = TRUE,      
        ENCODING = 'UTF8'
    )
);

CREATE EXTERNAL TABLE dbo.ext_tourism (
    Location NVARCHAR(4000) NULL,
    Country NVARCHAR(4000) NULL,
    Category NVARCHAR(4000) NULL,
    Visitors INT NULL,
    Rating FLOAT NULL,
    Revenue FLOAT NULL,
    Accomodation_Available NVARCHAR(4000) NULL
)
WITH (
    LOCATION = '/Data/tourism.csv',
    DATA_SOURCE = mydatasrc,
    FILE_FORMAT = CSVFileFormat1
);

--Creates seperate tables for every average aggregation of the data
SELECT
    Country AS Country,
    AVG(Revenue) AS Avg_revenue
INTO dbo.avg_revenue_country
FROM dbo.ext_tourism
GROUP BY Country;

SELECT
    Category AS Category,
    AVG(Revenue) AS Avg_revenue
INTO dbo.avg_revenue_category
FROM dbo.ext_tourism
GROUP BY Category;

SELECT
    Country AS Country,
    AVG(Rating) AS Avg_rating
INTO dbo.avg_rating_country
FROM dbo.ext_tourism
GROUP BY Country;

SELECT
    Category AS Category,
    AVG(Rating) AS Avg_rating
INTO dbo.avg_rating_category
FROM dbo.ext_tourism
GROUP BY Category;

SELECT
    Country AS Country,
    AVG(Visitors) AS Avg_visitors
INTO dbo.avg_visitors_country
FROM dbo.ext_tourism
GROUP BY Country;

SELECT
    Category AS Category,
    AVG(Visitors) AS Avg_visitors
INTO dbo.avg_visitors_category
FROM dbo.ext_tourism
GROUP BY Category;

--Querying the data from the new tables
SELECT * FROM dbo.avg_revenue_country

SELECT * FROM dbo.avg_revenue_category

SELECT * FROM dbo.avg_rating_country

SELECT * FROM dbo.avg_rating_category

SELECT * FROM dbo.avg_visitors_country

SELECT * FROM dbo.avg_visitors_category

--Questions to answer based off the data
--1. Which category or country has the highest average rating across all reviews? 

    --The highest rated category across all reviews was Beach tourism with  an average rating of 3.07

SELECT * FROM dbo.avg_rating_country ORDER BY Avg_rating DESC
    --The highest rated country across all reviews was Brazil for tourism with an average rating of 3.07


--2. What are the top 5 highest-rated tourist areas or categories based on customer reviews? 
SELECT TOP 5 * FROM dbo.avg_rating_category ORDER BY Avg_rating DESC 
    --The top 5 highest rated tourist categories are Beach, Adventure, Historical, Cultural, Urban.

SELECT TOP 5 * FROM dbo.avg_rating_country ORDER BY Avg_rating DESC
    --The top 5 highest rated tourist countries are Brazil, France, Egypt, Australia, USA.


--3. Which country or category recieves the highest revenue amount and is it correlated with high ratings? 
SELECT * FROM dbo.avg_revenue_category ORDER BY Avg_revenue DESC
    --The category with the highest average revenue is Cultural Tourism. 
    --It seems that the highest rated tourism categories were among the lowesst average revenue and vise versa.

SELECT * FROM dbo.avg_revenue_country ORDER BY Avg_revenue DESC
    --The country with the highest average revenue is Brazil.
    --There doesnt seem to be any correlation between high average revenue and high average ratings. 
    --Brazil is the highest rated country and highest average revenue country.

--4. How does the average revenue vary based on the country? 
SELECT VAR(Avg_revenue) As Variance FROM dbo.avg_revenue_country 
    --The variance of the average revenue is 107,028,121.09 so the average revenue varies by 100 million.

--5. Which combination of country and category provides the best tourist trip, considering both ratings and revenue?
SELECT TOP 5 * FROM dbo.avg_rating_category ORDER BY Avg_rating DESC 
SELECT TOP 5 * FROM dbo.avg_rating_country ORDER BY Avg_rating DESC
SELECT * FROM dbo.avg_revenue_category ORDER BY Avg_revenue DESC
SELECT * FROM dbo.avg_revenue_country ORDER BY Avg_revenue DESC
    --The best combination of country and category for the best tourist trip would be a Beach Trip in Brazil.
    --Brazil is the highest rated and highest average revenue out of all the countries.
    --Beach is the highest rated category out of all the categories and is still has the fourth highest average revenue.
    --All of these insights combined brings you to the conclusion that Beach category and the country Brazil are the best choice for the tourist trip.





