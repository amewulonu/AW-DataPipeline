USE AdventureWorksDW2017;
GO
-- 4: Using stored procedure, develop the following on the DW 
-- Stored procedure: Total Sales by Year:

CREATE PROCEDURE usp_GetTotalSalesYearly
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.CalendarYear AS SalesYear,
        SUM(f.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales f
    INNER JOIN dbo.DimDate d
        ON f.OrderDateKey = d.DateKey
    GROUP BY d.CalendarYear
    ORDER BY d.CalendarYear;
END;

-- to run EXEC usp_GetTotalSalesYearly;

GO
-- Stored procedure: Top N customers by Sales 
CREATE PROCEDURE usp_GetTopNCustomersBySales
	@TopN INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP (@TOPN)
	c.CustomerKey,
	c.FirstName + ' ' + c.LastName AS CustomerName,
	SUM(f.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales f
    INNER JOIN dbo.DimCustomer c
        ON f.CustomerKey = c.CustomerKey
    GROUP BY c.CustomerKey, c.FirstName, c.LastName
    ORDER BY TotalSales DESC;
END;
-- EXEC usp_GetTopNCustomersBySales @TopN = 10;

GO
-- Stored procedure: Sales by Product Category for a given year

CREATE PROCEDURE usp_GetSalesByProductCategory
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ISNULL(pc.EnglishProductCategoryName, 'Unknown') AS ProductCategory,
        SUM(f.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales f
    INNER JOIN dbo.DimDate d
        ON f.OrderDateKey = d.DateKey
    LEFT JOIN dbo.DimProduct p
        ON f.ProductKey = p.ProductKey
    LEFT JOIN dbo.DimProductSubcategory ps
        ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    LEFT JOIN dbo.DimProductCategory pc
        ON ps.ProductCategoryKey = pc.ProductCategoryKey
    WHERE d.CalendarYear = @Year
    GROUP BY pc.EnglishProductCategoryName
    ORDER BY TotalSales DESC;
END;
GO

-- EXEC usp_GetSalesByProductCategory @Year = 2010;

GO
-- Stored procedure: Monthly  Sales
CREATE OR ALTER PROCEDURE usp_GetMonthlySales
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.CalendarYear,
        d.MonthNumberOfYear,
        d.EnglishMonthName,
        SUM(f.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales f
    INNER JOIN dbo.DimDate d
        ON f.OrderDateKey = d.DateKey
    WHERE d.CalendarYear = @Year
    GROUP BY d.CalendarYear, d.MonthNumberOfYear, d.EnglishMonthName
    ORDER BY d.MonthNumberOfYear;
END;
-- EXEC usp_GetMonthlySales @Year = 2012;

 GO
-- Stored procedure: Sales trend for a specific Product
CREATE OR ALTER PROCEDURE usp_GetProductSalesTrend
    @ProductKey INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.CalendarYear,
        d.MonthNumberOfYear,
        d.EnglishMonthName,
        ISNULL(SUM(f.SalesAmount), 0) AS TotalSales
    FROM dbo.DimDate d
    LEFT JOIN dbo.FactInternetSales f
        ON f.OrderDateKey = d.DateKey
        AND f.ProductKey = @ProductKey
    GROUP BY d.CalendarYear, d.MonthNumberOfYear, d.EnglishMonthName
    ORDER BY d.CalendarYear, d.MonthNumberOfYear;
END;
-- Show sales trend for product with ProductKey = 776
EXEC usp_GetProductSalesTrend @ProductKey = 776;

GO
-- Stored procedure: That returns customers who have purchased more than once
CREATE OR ALTER PROCEDURE usp_CustomersWithMultiplePurchases
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CustomerKey,
        c.FirstName + ' ' + c.LastName AS CustomerName,
        COUNT(f.SalesOrderNumber) AS PurchaseCount,
        SUM(f.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales f
    INNER JOIN dbo.DimCustomer c
        ON f.CustomerKey = c.CustomerKey
    GROUP BY c.CustomerKey, c.FirstName, c.LastName
    HAVING COUNT(f.SalesOrderNumber) > 1
    ORDER BY PurchaseCount DESC, TotalSales DESC;
END;
--To execute
EXEC usp_CustomersWithMultiplePurchases;

GO
-- Stored procedure: Sales by Territory with Date Range.
CREATE OR ALTER PROCEDURE usp_SalesByTerritory
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.SalesTerritoryKey,
        t.SalesTerritoryRegion,
        t.SalesTerritoryCountry,
        SUM(f.SalesAmount) AS TotalSales,
        COUNT(f.SalesOrderNumber) AS TotalOrders
    FROM dbo.FactInternetSales f
    INNER JOIN dbo.DimSalesTerritory t
        ON f.SalesTerritoryKey = t.SalesTerritoryKey
    INNER JOIN dbo.DimDate d
        ON f.OrderDateKey = d.DateKey
    WHERE d.FullDateAlternateKey BETWEEN @StartDate AND @EndDate
    GROUP BY t.SalesTerritoryKey, t.SalesTerritoryRegion, t.SalesTerritoryCountry
    ORDER BY TotalSales DESC;
END;
-- To execute
EXEC usp_SalesByTerritory 
    @StartDate = '2007-01-01', 
    @EndDate = '2007-12-31';

GO
-- 5:Implement agent job for the stored procedure sales trend and Top N customers by Sales to run every morning by 7am using Agent jobs in SSMS. 

USE msdb;
GO
EXEC sp_add_job
    @job_name = N'Daily_SalesTrend_TopCustomers';

-- Step 1: Product Sales Trend
EXEC sp_add_jobstep
    @job_name = N'Daily_SalesTrend_TopCustomers',
    @step_name = N'Run_ProductSalesTrend',
    @subsystem = N'TSQL',
    @database_name = N'AdventureWorksDW2017',
    @command = N'EXEC usp_GetProductSalesTrend @ProductKey = 776;';

-- Step 2: Top N Customers
EXEC sp_add_jobstep
    @job_name = N'Daily_SalesTrend_TopCustomers',
    @step_name = N'Run_TopNCustomers',
    @subsystem = N'TSQL',
    @database_name = N'AdventureWorksDW2017',
    @command = N'EXEC usp_GetTopNCustomersBySales @TopN = 10;',
    @on_success_action = 1; -- go to next step

-- Daily 7 AM schedule
EXEC sp_add_schedule
    @schedule_name = N'Daily_7AM',
    @freq_type = 4,               -- daily
    @freq_interval = 1,
    @active_start_time = 070000;  -- 7:00 AM

EXEC sp_attach_schedule
    @job_name = N'Daily_SalesTrend_TopCustomers',
    @schedule_name = N'Daily_7AM';

EXEC sp_add_jobserver
    @job_name = N'Daily_SalesTrend_TopCustomers';

GO
-- 6: Load the Data (Stored Procedures) into power BI and provide the visuals. 