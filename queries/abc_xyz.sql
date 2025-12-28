/*
ABC + XYZ Analysis
Business goal:
- ABC: classify product categories by contribution to total margin
- XYZ: evaluate stability of demand (coefficient of variation of monthly margin)
Final output: ABC/XYZ matrix for prioritization of assortment and inventory
*/

-- =========================
-- 1. ABC Analysis
-- =========================

WITH category_margin AS (
    -- Aggregate total margin by product category
    SELECT
        Category AS category,
        SUM(Margin) AS total_margin
    FROM sales
    GROUP BY Category
),

total_margin AS (
    -- Calculate total margin across all categories
    SELECT
        SUM(total_margin) AS grand_total_margin
    FROM category_margin
),

category_share AS (
    -- Calculate share of each category in total margin
    SELECT
        cm.category,
        cm.total_margin,
        cm.total_margin / tm.grand_total_margin AS margin_share
    FROM category_margin cm
    CROSS JOIN total_margin tm
),

abc_classification AS (
    -- Assign ABC class based on cumulative margin share
    SELECT
        category,
        total_margin,
        margin_share,
        SUM(margin_share) OVER (ORDER BY margin_share DESC) AS cumulative_share,
        CASE
            WHEN SUM(margin_share) OVER (ORDER BY margin_share DESC) <= 0.80 THEN 'A'
            WHEN SUM(margin_share) OVER (ORDER BY margin_share DESC) <= 0.95 THEN 'B'
            ELSE 'C'
        END AS abc_class
    FROM category_share
),

-- =========================
-- 2. XYZ Analysis
-- =========================

monthly_data AS (
    -- Aggregate monthly margin by category
    SELECT
        Category AS category,
        DATE_FORMAT(SaleDate, '%Y-%m') AS sale_month,
        SUM(Margin) AS monthly_margin
    FROM sales
    GROUP BY Category, sale_month
),

stats AS (
    -- Calculate average, standard deviation, and coefficient of variation
    SELECT
        category,
        AVG(monthly_margin) AS avg_monthly_margin,
        STDDEV(monthly_margin) AS stddev_margin,
        STDDEV(monthly_margin) / AVG(monthly_margin) AS variation_coef
    FROM monthly_data
    GROUP BY category
),

xyz_classification AS (
    -- Assign XYZ class based on coefficient of variation
    SELECT
        category,
        avg_monthly_margin,
        stddev_margin,
        variation_coef,
        CASE
            WHEN variation_coef <= 0.10 THEN 'X'
            WHEN variation_coef <= 0.25 THEN 'Y'
            ELSE 'Z'
        END AS xyz_class
    FROM stats
)

-- =========================
-- 3. Final ABC/XYZ matrix
-- =========================

SELECT
    a.category,
    a.total_margin,
    a.margin_share,
    a.cumulative_share,
    a.abc_class,
    x.avg_monthly_margin,
    x.stddev_margin,
    x.variation_coef,
    x.xyz_class,
    CONCAT(a.abc_class, '/', x.xyz_class) AS abc_xyz_group
FROM abc_classification a
LEFT JOIN xyz_classification x
    ON a.category = x.category
ORDER BY a.cumulative_share DESC;
