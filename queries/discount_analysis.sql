/*
Project: Retail Analytics (Furniture Store)
Analysis: Discount Impact Simulation
DB: MySQL
Description:
- Simulate maximum discount of 10% for each sale
- Compare current revenue vs simulated revenue
- Calculate absolute and percentage change per category
*/
WITH simulated AS (
    SELECT
        Category,
        Price,
        Quantity,
        Margin,
        DiscountPct,
        PriceAfterDiscount,
        -- New price with discount capped at 10%
        Price * (1 - LEAST(DiscountPct, 10) / 100) AS NewPriceAfterDiscount
    FROM sales
)
SELECT
    Category AS Категория,
    COUNT(*) AS Продаж,
    ROUND(SUM(PriceAfterDiscount * Quantity), 0) AS ТекущаяВыручка,
    ROUND(SUM(NewPriceAfterDiscount * Quantity), 0) AS ВыручкаПри10проц,
    ROUND(SUM(NewPriceAfterDiscount * Quantity) - SUM(PriceAfterDiscount * Quantity), 0) AS ИзменениеВыручки,
    ROUND(
        (SUM(NewPriceAfterDiscount * Quantity) - SUM(PriceAfterDiscount * Quantity))
        / SUM(PriceAfterDiscount * Quantity) * 100, 2
    ) AS ПроцентИзменения
FROM simulated
GROUP BY Category
ORDER BY ПроцентИзменения DESC;
