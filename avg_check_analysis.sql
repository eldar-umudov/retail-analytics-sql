/*
Project: Retail Analytics (Furniture Store)
Analysis: Average Check
DB: MySQL
Description:
- Calculating average check by category, month, city, and discount
*/

WITH revenue_per_order AS (
    SELECT
        Category,
        City,
        DATE_FORMAT(SaleDate, '%Y-%m') AS SaleMonth,
        DiscountPct,
        PriceAfterDiscount * Quantity AS OrderRevenue
    FROM sales
)

-- 1. Средний чек по категориям
, avg_by_category AS (
    SELECT
        Category AS Категория,
        ROUND(AVG(OrderRevenue), 2) AS СреднийЧек
    FROM revenue_per_order
    GROUP BY Category
    ORDER BY СреднийЧек DESC
)

-- 2. Средний чек по месяцам
, avg_by_month AS (
    SELECT
        SaleMonth AS Месяц,
        ROUND(AVG(OrderRevenue), 2) AS СреднийЧек
    FROM revenue_per_order
    GROUP BY SaleMonth
    ORDER BY SaleMonth
)

-- 3. Средний чек по городам
, avg_by_city AS (
    SELECT
        City AS Город,
        ROUND(AVG(OrderRevenue), 2) AS СреднийЧек
    FROM revenue_per_order
    GROUP BY City
    ORDER BY СреднийЧек DESC
)

-- 4. Средний чек по уровням скидки
, avg_by_discount AS (
    SELECT
        DiscountPct AS СкидкаПроцентов,
        ROUND(AVG(OrderRevenue), 2) AS СреднийЧек
    FROM revenue_per_order
    GROUP BY DiscountPct
    ORDER BY СкидкаПроцентов
)

SELECT * FROM avg_by_category;
SELECT * FROM avg_by_month;
SELECT * FROM avg_by_city;
SELECT * FROM avg_by_discount;