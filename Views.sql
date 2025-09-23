
USE AdventureWorksDW2017;
GO

-- Create views to be used in Power BI for analysis
-- Total Sales by Year
CREATE OR ALTER VIEW dbo.vw_TotalSalesYearly AS
SELECT
    d.CalendarYear   AS SalesYear,
    SUM(f.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales f
JOIN dbo.DimDate d
  ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear;


GO
-- Top-N Customers by Sales
-- (Parameterised “Top N” can’t live inside a view, so this returns all customers ranked. Filter Top N in Power BI with a Top-N filter).
CREATE OR ALTER VIEW dbo.vw_CustomersBySales AS
SELECT
    c.CustomerKey,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    SUM(f.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales f
JOIN dbo.DimCustomer c
  ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, c.FirstName, c.LastName


GO
-- Sales by Product Category (with Year column so you can slice/filter in Power BI)
CREATE OR ALTER VIEW dbo.vw_SalesByProductCategory AS
SELECT
    d.CalendarYear AS SalesYear,
    ISNULL(pc.EnglishProductCategoryName, 'Unknown') AS ProductCategory,
    SUM(f.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales f
JOIN dbo.DimDate d
  ON f.OrderDateKey = d.DateKey
LEFT JOIN dbo.DimProduct p
  ON f.ProductKey = p.ProductKey
LEFT JOIN dbo.DimProductSubcategory ps
  ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN dbo.DimProductCategory pc
  ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY d.CalendarYear, pc.EnglishProductCategoryName;


GO
--Monthly Sales
CREATE OR ALTER VIEW dbo.vw_MonthlySales AS
SELECT
    d.CalendarYear,
    d.MonthNumberOfYear,
    d.EnglishMonthName,
    SUM(f.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales f
JOIN dbo.DimDate d
  ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear, d.MonthNumberOfYear, d.EnglishMonthName;


GO
-- Product Sales Trend
-- (Returns trend for all products; filter by ProductKey in Power BI slicer.)
CREATE OR ALTER VIEW dbo.vw_ProductSalesTrend AS
SELECT
    f.ProductKey,
    d.CalendarYear,
    d.MonthNumberOfYear,
    d.EnglishMonthName,
    SUM(f.SalesAmount) AS TotalSales
FROM dbo.DimDate d
LEFT JOIN dbo.FactInternetSales f
  ON f.OrderDateKey = d.DateKey
GROUP BY f.ProductKey, d.CalendarYear, d.MonthNumberOfYear, d.EnglishMonthName;


GO
-- Customers with Multiple Purchases
CREATE OR ALTER VIEW dbo.vw_CustomersWithMultiplePurchases AS
SELECT
    c.CustomerKey,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(f.SalesOrderNumber) AS PurchaseCount,
    SUM(f.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales f
JOIN dbo.DimCustomer c
  ON f.CustomerKey = c.CustomerKey
GROUP BY c.CustomerKey, c.FirstName, c.LastName
HAVING COUNT(f.SalesOrderNumber) > 1;


GO
-- Sales by Territory with Date
CREATE OR ALTER VIEW dbo.vw_SalesByTerritory AS
SELECT
    t.SalesTerritoryKey,
    t.SalesTerritoryRegion,
    t.SalesTerritoryCountry,
    d.FullDateAlternateKey AS OrderDate,
    SUM(f.SalesAmount) AS TotalSales,
    COUNT(f.SalesOrderNumber) AS TotalOrders
FROM dbo.FactInternetSales f
JOIN dbo.DimSalesTerritory t
  ON f.SalesTerritoryKey = t.SalesTerritoryKey
JOIN dbo.DimDate d
  ON f.OrderDateKey = d.DateKey
GROUP BY t.SalesTerritoryKey, t.SalesTerritoryRegion,
         t.SalesTerritoryCountry, d.FullDateAlternateKey;


GO


-- To view all my Views
USE AdventureWorksDW2017;
GO

-- List all views in the current database
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
ORDER BY TABLE_SCHEMA, TABLE_NAME;

GO

-- To ensure all view are working fine
USE AdventureWorksDW2017;
GO

-- 1. Total Sales by Year
SELECT *
FROM dbo.vw_TotalSalesYearly;
GO

-- 2. Customers by Sales
SELECT *
FROM dbo.vw_CustomersBySales
ORDER BY TotalSales DESC;  -- optional: order by highest sales
GO

-- 3. Sales by Product Category
SELECT *
FROM dbo.vw_SalesByProductCategory
ORDER BY SalesYear, ProductCategory;
GO

-- 4. Monthly Sales
SELECT *
FROM dbo.vw_MonthlySales
ORDER BY CalendarYear, MonthNumberOfYear;
GO

-- 5. Product Sales Trend
SELECT *
FROM dbo.vw_ProductSalesTrend
ORDER BY ProductKey, CalendarYear, MonthNumberOfYear;
GO

-- 6. Customers with Multiple Purchases
SELECT *
FROM dbo.vw_CustomersWithMultiplePurchases
ORDER BY TotalSales DESC;
GO

-- 7. Sales by Territory
SELECT *
FROM dbo.vw_SalesByTerritory
ORDER BY SalesTerritoryRegion, OrderDate;
GO
