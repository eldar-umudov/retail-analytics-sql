/*
Project: Retail Analytics (Furniture Store)
Analysis: RFM Segmentation
DB: MySQL
Description:
- Revenue calculated using discounted price
- RFM scores based on NTILE(3)
*/

WITH base AS (
    SELECT
        Client,
        MAX(SaleDate) AS last_purchase_date,
        DATEDIFF(CURDATE(), MAX(SaleDate)) AS recency,
        COUNT(*) AS frequency,
        SUM(PriceAfterDiscount * Quantity) AS monetary
    FROM sales
    GROUP BY Client
),

rfm_scores AS (
    SELECT
        Client,
        recency,
        frequency,
        monetary,
        NTILE(3) OVER (ORDER BY recency DESC)   AS r_score,
        NTILE(3) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(3) OVER (ORDER BY monetary ASC)  AS m_score
    FROM base
),

rfm_labeled AS (
    SELECT
        Client,
        recency,
        frequency,
        ROUND(monetary, 2) AS monetary,
        r_score,
        f_score,
        m_score,
        CONCAT(r_score, f_score, m_score) AS rfm_code,
        CASE
            WHEN r_score = 3 AND f_score = 3 AND m_score = 3 THEN 'Премиальный клиент'
            WHEN r_score = 3 AND f_score >= 2 AND m_score >= 2 THEN 'Перспективный клиент'
            WHEN r_score = 1 AND f_score = 1 AND m_score = 1 THEN 'Потерянный клиент'
            WHEN f_score = 1 THEN 'Клиент с низкой активностью'
            WHEN m_score = 1 THEN 'Клиент с низким доходом'
            ELSE 'Требует внимания'
        END AS segment
    FROM rfm_scores
)

SELECT
    Client          AS "Клиент",
    recency         AS "Давность покупки, дни",
    frequency       AS "Частота покупок",
    monetary        AS "Сумма покупок, ₽",
    r_score         AS "R",
    f_score         AS "F",
    m_score         AS "M",
    rfm_code        AS "RFM-код",
    segment         AS "Сегмент клиента"
FROM rfm_labeled
ORDER BY monetary DESC;