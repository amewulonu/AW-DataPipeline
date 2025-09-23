-- Requirements for building AW-DataPipeline: Otlined in the README found in GitHub
-- Tasks AW-DataPipeline (PHASE 1): 
-- 1: Restore AdventureWorks2017 on the MySQL server as the DW (on-prem) based on the above architecture.
-- 2: Confirm all the tables and records were populated correctly with a SELECT statement on some of the tables.

USE AdventureWorksDW2017;

GO

SELECT s.name AS SchemaName,
       t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;

Go
SELECT * FROM AdventureWorksDWBuildVersion

GO
SELECT * FROM DatabaseLog

Go
SELECT * FROM DimAccount

GO
SELECT * FROM DimCurrency

GO
SELECT * FROM DimCustomer

GO
SELECT * FROM DimDate

GO
SELECT * FROM DimDepartmentGroup

GO
SELECT * FROM DimEmployee

GO
SELECT * FROM DimGeography

GO
SELECT * FROM DimOrganization

GO
SELECT * FROM DimProduct

GO
SELECT * FROM DimProductCategory

GO
SELECT * FROM DimPromotion

GO
SELECT * FROM DimReseller

GO
SELECT * FROM DimSalesReason

GO
SELECT * FROM DimSalesTerritory

GO
SELECT * FROM DimScenario

GO
SELECT * FROM FactAdditionalInternationalProductDescription

GO
SELECT * FROM FactCallCenter

GO
SELECT * FROM FactCurrencyRate

GO
SELECT * FROM FactFinance

GO
SELECT * FROM FactInternetSales

GO
SELECT * FROM FactInternetSalesReason

GO
SELECT * FROM FactProductInventory

GO
SELECT * FROM FactResellerSales

Go
SELECT * FROM FactSalesQuota

GO
SELECT * FROM FactSurveyResponse

GO
SELECT * FROM NewFactCurrencyRate

GO 
SELECT * FROM ProspectiveBuyer


GO
-- 3: Develop the data dictionary for five (5) of the tables with columns such as field Name, description, DB_Field Name, Foreign Key, Foreign key table, Data type, and comments. Store the dictionary in excel format. 

GO
