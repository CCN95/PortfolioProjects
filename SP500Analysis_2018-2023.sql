SELECT *
FROM sp500_prices
ORDER BY 1




-- SHOWS THE MONTHLY RETURN PERCENTAGE FOR EACH STOCK
/* Formula used: MRP = (closing price of latest month / closing price of previous month) - 1 x 100) 

Used a self join, combined them through the ID column but table b starts on the second row to get the closing price
of the latest month*/

SELECT 
	a.Company, 
	a.[GICS Sector], 
	a.[GICS Sub-Industry], 
	a.Close_ AS [Closing Price],
	ROUND((a.close_ / b.close_) - 1, 6) *100 AS [Monthly Return Percentage],
	a.Month_, 
	a.Year_
FROM sp500_prices a
JOIN sp500_prices b
ON a.ID = b.ID+1 
ORDER BY a.ID






-- SHOWS THE PROFITABLE SECTORS EACH YEAR
/* Created a CTE using the previous select statement to get the total MRP of each sectors per year*/

WITH 
	CTE_Sectors (
		Company, 
		[GICS Sector], 
		[GICS Sub-Industry],
		[Closing Price],
		[Monthly Return Percentage],
		Month_, 
		Year_)
AS
(
SELECT 
	a.Company, 
	a.[GICS Sector], 
	a.[GICS Sub-Industry], 
	a.Close_ AS [Closing Price],
	ROUND((a.close_ / b.close_) - 1, 6) *100 AS [Monthly Return Percentage],
	a.Month_, 
	a.Year_
FROM sp500_prices a
JOIN sp500_prices b
ON a.ID = b.ID+1 
--ORDER BY a.ID
)
SELECT 
	[GICS Sector], 
	Year_,
	SUM([Monthly Return Percentage]) AS [Total MRP]
FROM CTE_Sectors
GROUP BY [GICS Sector], Year_
HAVING SUM([Monthly Return Percentage]) > 0
ORDER BY 2 ASC, 3 DESC





-- SHOWS THE PROFITABLE INDUSTRIES EACH YEAR
/* Created a CTE using the select statement that shows the MRP to get the total MRP of each industries per year*/

WITH 
	CTE_Industries (
		Company, 
		[GICS Sector], 
		[GICS Sub-Industry],
		[Closing Price],
		[Monthly Return Percentage],
		Month_, 
		Year_)
AS
(
SELECT 
	a.Company, 
	a.[GICS Sector], 
	a.[GICS Sub-Industry], 
	a.Close_ AS [Closing Price],
	ROUND((a.close_ / b.close_) - 1, 6) *100 AS [Monthly Return Percentage],
	a.Month_, 
	a.Year_
FROM sp500_prices a
JOIN sp500_prices b
ON a.ID = b.ID+1 
-- ORDER BY a.ID
)
SELECT 
	[GICS Sub-Industry], 
	Year_,
	SUM([Monthly Return Percentage]) AS [Total MRP]
FROM CTE_Industries
GROUP BY [GICS Sub-Industry], Year_
HAVING SUM([Monthly Return Percentage]) > 0
ORDER BY 2 ASC, 3 DESC





-- CALCULATING FOR THE DIVIDEND YIELD
/* To get the Dividend Yield, the stocks' annual dividend will be divided by their last price.

Formula:
	Dividend Yield = (Annual Dividend per Share / Last Price) x 100 
	
Used Window Functions to get the stocks' annual dividends and last price columns. 
Created a CTE to perform the calculation */


WITH
	SP500_DivYield (
		Company,
		Security,
		Dividends,
		[Annual Dividends],
		Close_,
		[Last Price],
		Month_,
		Year_)
AS
(
SELECT
	Company,
	Security,
	Dividends,
	SUM(Dividends) OVER (PARTITION BY Company, Year_) AS [Annual Dividends],
	Close_,
	FIRST_VALUE(Close_) OVER (PARTITION BY Company ORDER BY Year_ DESC, Month_ DESC) AS [Last Price],
	Month_,
	Year_
FROM sp500_prices
)
SELECT 
	DISTINCT Company,
	Security,
	(ROUND([Annual Dividends]/[Last Price], 6)*100) AS [Dividend Yield],
	Year_
FROM SP500_DivYield
ORDER BY 
	Company, 
	Security, 
	Year_ DESC, 
	[Dividend Yield]



-- SHOWS THE MONTHLY RETURN PERCENTAGE OF SP500 INDEX 
/* Created this table to later compare the monthly return percentage of each stocks to sp500's and see which ones
outperformed the index and which did not*/

SELECT 
	a.Company, 
	ROUND((CAST(a.[Close] AS float) / CAST(b.[Close] as float)) - 1, 6) *100 AS [Monthly Return Percentage],
	a.Month,
	a.Year
FROM sp500_index a
JOIN sp500_index b
ON a.ID = b.ID+1 
ORDER BY a.ID, a.Year DESC
