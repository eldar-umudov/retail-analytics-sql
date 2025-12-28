/*
Project: Retail Analytics (Furniture Store)
Analysis: Cohort Retention Analysis
DB: MySQL
Description:
- Cohorts are defined by the month of first purchase
- Retention is calculated as % of returning customers by month
*/

WITH first_purchase AS (
    SELECT
        Client,
        MIN(DATE_FORMAT(SaleDate, '%Y-%m')) AS first_month
    FROM sales
    GROUP BY Client
),

purchases_with_cohort AS (
    SELECT
        s.Client,
        fp.first_month,
        DATE_FORMAT(s.SaleDate, '%Y-%m') AS purchase_month
    FROM sales s
    JOIN first_purchase fp
        ON s.Client = fp.Client
),

cohort_activity AS (
    SELECT
        first_month,
        purchase_month,
        COUNT(DISTINCT Client) AS clients_count
    FROM purchases_with_cohort
    GROUP BY first_month, purchase_month
),

cohort_base AS (
    SELECT
        first_month,
        COUNT(DISTINCT Client) AS base_clients
    FROM first_purchase
    GROUP BY first_month
)

SELECT
    ca.first_month        AS cohort_month,
    ca.purchase_month     AS activity_month,
    ROUND(ca.clients_count / cb.base_clients * 100, 2) AS retention_pct
FROM cohort_activity ca
JOIN cohort_base cb
    ON ca.first_month = cb.first_month
ORDER BY
    cohort_month,
    activity_month;