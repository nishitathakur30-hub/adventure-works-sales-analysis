CREATE DATABASE AdventureWorks_Project;

USE AdventureWorks_Project;

-- Verify row counts after import:

SELECT COUNT(*) AS FactSalesRows    FROM FactInternetSales;
SELECT COUNT(*) AS CustomerRows     FROM DimCustomer;
SELECT COUNT(*) AS DateRows         FROM DimDate;
SELECT COUNT(*) AS ProductRows      FROM DimProduct;
SELECT COUNT(*) AS SubCategoryRows  FROM DimProductSubCategory;
SELECT COUNT(*) AS CategoryRows     FROM DimProductCategory;
SELECT COUNT(*) AS TerritoryRows    FROM DimSalesTerritory;

-- ============================================================
-- PAGE 1: OVERVIEW
-- ============================================================

-- Objective 1: Yearly Sales Trend — Business Growth Over Time
-- Total revenue, orders, units, cost and profit per year
SELECT
    d.CalendarYear,
    COUNT(DISTINCT f.SalesOrderNumber)   AS TotalOrders,
    SUM(f.OrderQuantity)                 AS TotalUnits,
    ROUND(SUM(f.ExtendedAmount), 2)      AS TotalSales,
    ROUND(SUM(f.ProductStandardCost), 2) AS TotalCost,
    ROUND(SUM(f.ExtendedAmount)
        - SUM(f.ProductStandardCost), 2) AS GrossProfit
FROM FactInternetSales f
JOIN DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;


-- Objective 2: Sales Contribution by Region Group
-- North America vs Europe vs Pacific with percentage share
SELECT
    t.SalesTerritoryGroup,
    ROUND(SUM(f.ExtendedAmount), 2)       AS TotalSales,
    ROUND(
      SUM(f.ExtendedAmount) * 100.0 /
      SUM(SUM(f.ExtendedAmount)) OVER ()
    , 2)                                  AS SalesPct
FROM FactInternetSales f
JOIN DimSalesTerritory t
    ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryGroup
ORDER BY TotalSales DESC;


-- Objective 3: Sales Contribution by Product Category
-- Bikes / Accessories / Clothing / Components breakdown
SELECT
    pc.EnglishProductCategoryName         AS Category,
    COUNT(DISTINCT f.SalesOrderNumber)    AS Orders,
    ROUND(SUM(f.ExtendedAmount), 2)       AS TotalSales,
    ROUND(
      SUM(f.ExtendedAmount) * 100.0 /
      SUM(SUM(f.ExtendedAmount)) OVER ()
    , 2)                                  AS SalesPct
FROM FactInternetSales f
JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
JOIN DimProductSubCategory psc
    ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
JOIN DimProductCategory pc
    ON psc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName
ORDER BY TotalSales DESC;


-- Objective 4: Customer Distribution Across Regions
-- Unique customers and sales per country and region
SELECT
    t.SalesTerritoryCountry,
    t.SalesTerritoryGroup,
    COUNT(DISTINCT f.CustomerKey)    AS UniqueCustomers,
    ROUND(SUM(f.ExtendedAmount), 2)  AS TotalSales
FROM FactInternetSales f
JOIN DimSalesTerritory t
    ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryCountry, t.SalesTerritoryGroup
ORDER BY UniqueCustomers DESC;


-- ============================================================
-- PAGE 2: TIME SERIES ANALYSIS
-- ============================================================

-- Objective 1: Yearly, Quarterly & Monthly Sales Trends
SELECT
    d.CalendarYear,
    d.CalendarQuarter,
    d.MonthNumberOfYear,
    d.EnglishMonthName,
    ROUND(SUM(f.ExtendedAmount), 2)      AS MonthlySales,
    COUNT(DISTINCT f.SalesOrderNumber)   AS Orders
FROM FactInternetSales f
JOIN DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY
    d.CalendarYear, d.CalendarQuarter,
    d.MonthNumberOfYear, d.EnglishMonthName
ORDER BY
    d.CalendarYear, d.MonthNumberOfYear;


-- Objective 2: Seasonal Patterns — Peak Sales Months
-- Average and peak sales for each month across all years
-- Objective 2: Seasonal Patterns — Peak Sales Months
SELECT
    monthly.MonthNumberOfYear,
    monthly.EnglishMonthName,
    ROUND(AVG(monthly.monthly_sales), 2)  AS AvgMonthlySales,
    ROUND(MAX(monthly.monthly_sales), 2)  AS PeakSales
FROM (
    SELECT
        d.CalendarYear,
        d.MonthNumberOfYear,
        d.EnglishMonthName,
        SUM(f.ExtendedAmount) AS monthly_sales
    FROM FactInternetSales f
    JOIN DimDate d ON f.OrderDateKey = d.DateKey
    GROUP BY
        d.CalendarYear,
        d.MonthNumberOfYear,
        d.EnglishMonthName
) monthly
GROUP BY
    monthly.MonthNumberOfYear,
    monthly.EnglishMonthName
ORDER BY
    monthly.MonthNumberOfYear;


-- Objective 3: Sales vs Cost vs Profit — Yearly Comparison
-- Year-over-year with profit margin percentage
SELECT
    d.CalendarYear                               AS Year,
    ROUND(SUM(f.ExtendedAmount), 2)             AS TotalSales,
    ROUND(SUM(f.ProductStandardCost), 2)        AS ProductionCost,
    ROUND(SUM(f.ExtendedAmount)
        - SUM(f.ProductStandardCost), 2)        AS GrossProfit,
    ROUND(
        (SUM(f.ExtendedAmount)
            - SUM(f.ProductStandardCost))
        / SUM(f.ExtendedAmount) * 100
    , 2)                                        AS ProfitMarginPct
FROM FactInternetSales f
JOIN DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;


-- Objective 4: Year-over-Year Sales Growth Rate
-- Percentage change using LAG window function
WITH yearly AS (
    SELECT
        d.CalendarYear,
        ROUND(SUM(f.ExtendedAmount), 2) AS TotalSales
    FROM FactInternetSales f
    JOIN DimDate d ON f.OrderDateKey = d.DateKey
    GROUP BY d.CalendarYear
)
SELECT
    CalendarYear,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY CalendarYear)  AS PrevYearSales,
    ROUND(
        (TotalSales - LAG(TotalSales) OVER (ORDER BY CalendarYear))
        / LAG(TotalSales) OVER (ORDER BY CalendarYear) * 100
    , 2)                                           AS GrowthPct
FROM yearly
ORDER BY CalendarYear;


-- ============================================================
-- PAGE 3: CUSTOMER ANALYSIS
-- ============================================================

-- Objective 5: Customer Distribution by Region & Country
-- Unique buyers, total sales and avg spend per customer
SELECT
    t.SalesTerritoryGroup                       AS RegionGroup,
    t.SalesTerritoryCountry                     AS Country,
    t.SalesTerritoryRegion                      AS Region,
    COUNT(DISTINCT f.CustomerKey)               AS UniqueCustomers,
    ROUND(SUM(f.ExtendedAmount), 2)             AS TotalSales,
    ROUND(SUM(f.ExtendedAmount)
        / COUNT(DISTINCT f.CustomerKey), 2)     AS AvgSalesPerCustomer
FROM FactInternetSales f
JOIN DimSalesTerritory t
    ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY
    t.SalesTerritoryGroup,
    t.SalesTerritoryCountry,
    t.SalesTerritoryRegion
ORDER BY TotalSales DESC;


-- Objective 6: Repeat Customers & Retention Trends
-- Segment customers by number of orders placed
WITH customer_orders AS (
    SELECT
        f.CustomerKey,
        COUNT(DISTINCT f.SalesOrderNumber)  AS TotalOrders,
        MIN(d.CalendarYear)                 AS FirstOrderYear,
        MAX(d.CalendarYear)                 AS LastOrderYear,
        ROUND(SUM(f.ExtendedAmount), 2)     AS TotalSpend
    FROM FactInternetSales f
    JOIN DimDate d ON f.OrderDateKey = d.DateKey
    GROUP BY f.CustomerKey
)
SELECT
    CASE WHEN TotalOrders = 1 THEN 'One-time'
         WHEN TotalOrders = 2 THEN 'Returning'
         ELSE 'Loyal (3+)' END             AS CustomerType,
    COUNT(*)                               AS CustomerCount,
    ROUND(AVG(TotalSpend), 2)             AS AvgLifetimeSpend
FROM customer_orders
GROUP BY CustomerType
ORDER BY CustomerCount DESC;


-- Objective 7: Top 10 Customers by Total Sales
-- Full name, total orders, units bought, lifetime spend
-- Objective 7: Top 10 Customers by Total Sales
SELECT
    RANK() OVER (ORDER BY SUM(f.ExtendedAmount) DESC)  AS CustomerRank,
    CONCAT(c.FirstName, ' ', c.LastName)               AS CustomerName,
    COUNT(DISTINCT f.SalesOrderNumber)                 AS TotalOrders,
    SUM(f.OrderQuantity)                               AS UnitsBought,
    ROUND(SUM(f.ExtendedAmount), 2)                    AS TotalSales
FROM FactInternetSales f
JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
GROUP BY f.CustomerKey, c.FirstName, c.LastName
ORDER BY TotalSales DESC
LIMIT 10;


-- Objective 8: Customer Purchasing Behavior by Market
-- Gender, occupation and spend patterns per country
SELECT
    t.SalesTerritoryCountry          AS Country,
    c.Gender,
    c.EnglishOccupation              AS Occupation,
    COUNT(DISTINCT f.CustomerKey)    AS Customers,
    ROUND(AVG(f.ExtendedAmount), 2)  AS AvgOrderValue,
    ROUND(SUM(f.ExtendedAmount), 2)  AS TotalSales
FROM FactInternetSales f
JOIN DimCustomer c
    ON f.CustomerKey = c.CustomerKey
JOIN DimSalesTerritory t
    ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY
    t.SalesTerritoryCountry,
    c.Gender, c.EnglishOccupation
ORDER BY TotalSales DESC;


-- ============================================================
-- PAGE 4: PRODUCT & REGIONAL ANALYSIS
-- ============================================================

-- Objective 9: Sales by Product Category & Subcategory
-- Full product hierarchy drill-down with profit
SELECT
    pc.EnglishProductCategoryName        AS Category,
    psc.EnglishProductSubcategoryName    AS SubCategory,
    COUNT(DISTINCT f.SalesOrderNumber)   AS Orders,
    SUM(f.OrderQuantity)                 AS UnitsSold,
    ROUND(SUM(f.ExtendedAmount), 2)      AS TotalSales,
    ROUND(SUM(f.ExtendedAmount)
        - SUM(f.ProductStandardCost), 2) AS GrossProfit
FROM FactInternetSales f
JOIN DimProduct p
    ON f.ProductKey = p.ProductKey
JOIN DimProductSubCategory psc
    ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
JOIN DimProductCategory pc
    ON psc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY
    pc.EnglishProductCategoryName,
    psc.EnglishProductSubcategoryName
ORDER BY TotalSales DESC;


-- Objective 10: Top 10 Selling & High-Profit Products
-- Ranked by gross profit with margin percentage
SELECT
    p.EnglishProductName                         AS Product,
    psc.EnglishProductSubcategoryName            AS SubCategory,
    SUM(f.OrderQuantity)                         AS UnitsSold,
    ROUND(SUM(f.ExtendedAmount), 2)              AS TotalSales,
    ROUND(SUM(f.ProductStandardCost), 2)         AS TotalCost,
    ROUND(SUM(f.ExtendedAmount)
        - SUM(f.ProductStandardCost), 2)         AS GrossProfit,
    ROUND(
      (SUM(f.ExtendedAmount)
          - SUM(f.ProductStandardCost))
      / SUM(f.ExtendedAmount) * 100
    , 2)                                         AS ProfitMarginPct
FROM FactInternetSales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
JOIN DimProductSubCategory psc
    ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
GROUP BY p.ProductKey, p.EnglishProductName,
         psc.EnglishProductSubcategoryName
ORDER BY GrossProfit DESC
LIMIT 10; -- use TOP 10 for SQL Server


-- Objective 11: Low-Profit & Loss-Making Products
-- Flag products with margin under 20% for cost review
SELECT
    p.EnglishProductName                      AS Product,
    psc.EnglishProductSubcategoryName         AS SubCategory,
    ROUND(SUM(f.ExtendedAmount), 2)           AS TotalSales,
    ROUND(SUM(f.ProductStandardCost), 2)      AS TotalCost,
    ROUND(SUM(f.ExtendedAmount)
        - SUM(f.ProductStandardCost), 2)      AS GrossProfit,
    ROUND(
      (SUM(f.ExtendedAmount)
          - SUM(f.ProductStandardCost))
      / SUM(f.ExtendedAmount) * 100
    , 2)                                      AS MarginPct,
    CASE
        WHEN (SUM(f.ExtendedAmount)
              - SUM(f.ProductStandardCost)) < 0
             THEN 'Loss-making'
        WHEN (SUM(f.ExtendedAmount)
              - SUM(f.ProductStandardCost))
              / SUM(f.ExtendedAmount) < 0.10
             THEN 'Low margin'
        ELSE 'Healthy'
    END                                       AS ProfitStatus
FROM FactInternetSales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
JOIN DimProductSubCategory psc
    ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
GROUP BY p.ProductKey, p.EnglishProductName,
         psc.EnglishProductSubcategoryName
HAVING MarginPct < 20
ORDER BY MarginPct ASC;


-- Objective 12: Regional Sales & Profit Comparison
-- All regions ranked by gross profit to find top markets
SELECT
    RANK() OVER (ORDER BY
        SUM(f.ExtendedAmount)
        - SUM(f.ProductStandardCost) DESC)    AS ProfitRank,
    t.SalesTerritoryGroup                     AS RegionGroup,
    t.SalesTerritoryCountry                   AS Country,
    t.SalesTerritoryRegion                    AS Region,
    ROUND(SUM(f.ExtendedAmount), 2)           AS TotalSales,
    ROUND(SUM(f.ProductStandardCost), 2)      AS TotalCost,
    ROUND(SUM(f.ExtendedAmount)
        - SUM(f.ProductStandardCost), 2)      AS GrossProfit,
    ROUND(
        (SUM(f.ExtendedAmount)
         - SUM(f.ProductStandardCost))
        / SUM(f.ExtendedAmount) * 100
    , 2)                                      AS ProfitMarginPct
FROM FactInternetSales f
JOIN DimSalesTerritory t
    ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY
    t.SalesTerritoryGroup,
    t.SalesTerritoryCountry,
    t.SalesTerritoryRegion
ORDER BY GrossProfit DESC;


-- ============================================================






