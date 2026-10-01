-- ============================================================
-- E-Commerce Customer & Sales Analysis
-- SQLite SQL Portfolio Project
-- ============================================================
-- Source: UCI Online Retail dataset
-- The Python notebook loads Online Retail.xlsx into a SQLite
-- table named transactions before these analysis queries run.
-- ============================================================


-- 1. RAW DATA CHECKS
SELECT COUNT(*) AS total_transactions
FROM transactions;

SELECT COUNT(*) AS missing_customer_ids
FROM transactions
WHERE CustomerID IS NULL;

SELECT COUNT(*) AS cancelled_transactions
FROM transactions
WHERE InvoiceNo LIKE 'C%';

SELECT COUNT(*) AS non_positive_quantity
FROM transactions
WHERE Quantity <= 0;

SELECT COUNT(*) AS non_positive_price
FROM transactions
WHERE UnitPrice <= 0;


-- 2. CREATE ANALYSIS-READY TABLE
DROP TABLE IF EXISTS clean_transactions;

CREATE TABLE clean_transactions AS
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    Quantity * UnitPrice AS Revenue
FROM transactions
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0;


-- 3. CORE KPIs
SELECT
    ROUND(SUM(Revenue), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS total_customers,
    SUM(Quantity) AS total_units_sold,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM clean_transactions;


-- 4. COUNTRY PERFORMANCE
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS total_customers,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM clean_transactions
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;


-- 5. HIGHEST-VALUE CUSTOMERS
SELECT
    CustomerID,
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM clean_transactions
GROUP BY CustomerID, Country
ORDER BY total_revenue DESC
LIMIT 10;


-- 6. MOST FREQUENT CUSTOMERS
SELECT
    CustomerID,
    Country,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM clean_transactions
GROUP BY CustomerID, Country
ORDER BY total_orders DESC
LIMIT 10;


-- 7. DATASET DATE RANGE
SELECT
    MIN(InvoiceDate) AS first_transaction,
    MAX(InvoiceDate) AS last_transaction
FROM clean_transactions;


-- 8. MONTHLY REVENUE - COMPLETE MONTHS ONLY
SELECT
    strftime('%Y-%m', InvoiceDate) AS month,
    ROUND(SUM(Revenue), 2) AS monthly_revenue
FROM clean_transactions
WHERE InvoiceDate < '2011-12-01'
GROUP BY month
ORDER BY month;


-- 9. MONTH-ON-MONTH GROWTH WITH LAG()
WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS month,
        SUM(Revenue) AS monthly_revenue
    FROM clean_transactions
    WHERE InvoiceDate < '2011-12-01'
    GROUP BY month
),
monthly_comparison AS (
    SELECT
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        ((monthly_revenue - previous_month_revenue)
        / previous_month_revenue) * 100,
        2
    ) AS monthly_growth_percent
FROM monthly_comparison;


-- 10. TOP PRODUCTS BY REVENUE
SELECT
    Description,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    SUM(Quantity) AS total_units_sold
FROM clean_transactions
GROUP BY Description
ORDER BY total_revenue DESC
LIMIT 10;


-- 11. PRODUCT REVENUE AND VOLUME RANKS
WITH product_sales AS (
    SELECT
        Description,
        ROUND(SUM(Revenue), 2) AS total_revenue,
        SUM(Quantity) AS total_units_sold
    FROM clean_transactions
    GROUP BY Description
)
SELECT
    Description,
    total_revenue,
    total_units_sold,
    ROUND(
        total_revenue / total_units_sold,
        2
    ) AS revenue_per_unit,
    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank,
    RANK() OVER (
        ORDER BY total_units_sold DESC
    ) AS units_rank
FROM product_sales
ORDER BY revenue_rank
LIMIT 10;


-- 12. CUSTOMER VALUE SEGMENTATION WITH CASE WHEN
WITH customer_sales AS (
    SELECT
        CustomerID,
        SUM(Revenue) AS total_revenue
    FROM clean_transactions
    GROUP BY CustomerID
),
customer_segments AS (
    SELECT
        CustomerID,
        total_revenue,
        CASE
            WHEN total_revenue >= 50000 THEN 'High Value'
            WHEN total_revenue >= 10000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM customer_sales
)
SELECT
    customer_segment,
    COUNT(*) AS number_of_customers,
    ROUND(SUM(total_revenue), 2) AS segment_revenue,
    ROUND(AVG(total_revenue), 2) AS average_customer_revenue
FROM customer_segments
GROUP BY customer_segment
ORDER BY segment_revenue DESC;


-- 13. REPEAT CUSTOMERS WITH HAVING
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM clean_transactions
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) > 1
ORDER BY total_orders DESC;


-- 14. REPEAT CUSTOMER RATE
WITH customer_orders AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS total_orders
    FROM clean_transactions
    GROUP BY CustomerID
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS repeat_customer_percent
FROM customer_orders;


-- 15. CUSTOMER RECENCY
WITH customer_recency AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date
    FROM clean_transactions
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    last_purchase_date,
    CAST(
        julianday('2011-12-09') - julianday(last_purchase_date)
        AS INTEGER
    ) AS days_since_last_purchase
FROM customer_recency
ORDER BY days_since_last_purchase DESC
LIMIT 20;


-- 16. RECENCY SEGMENTATION
WITH customer_recency AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date
    FROM clean_transactions
    GROUP BY CustomerID
),
recency_segments AS (
    SELECT
        CustomerID,
        last_purchase_date,
        CAST(
            julianday('2011-12-09') - julianday(last_purchase_date)
            AS INTEGER
        ) AS days_since_last_purchase,
        CASE
            WHEN julianday('2011-12-09') - julianday(last_purchase_date) <= 30
                THEN 'Active'
            WHEN julianday('2011-12-09') - julianday(last_purchase_date) <= 90
                THEN 'At Risk'
            ELSE 'Inactive'
        END AS recency_segment
    FROM customer_recency
)
SELECT
    recency_segment,
    COUNT(*) AS number_of_customers
FROM recency_segments
GROUP BY recency_segment
ORDER BY number_of_customers DESC;


-- 17. VALUABLE CUSTOMERS AT RISK OR INACTIVE
WITH customer_summary AS (
    SELECT
        CustomerID,
        Country,
        ROUND(SUM(Revenue), 2) AS total_revenue,
        COUNT(DISTINCT InvoiceNo) AS total_orders,
        MAX(InvoiceDate) AS last_purchase_date
    FROM clean_transactions
    GROUP BY CustomerID, Country
),
customer_status AS (
    SELECT
        CustomerID,
        Country,
        total_revenue,
        total_orders,
        last_purchase_date,
        CAST(
            julianday('2011-12-09') - julianday(last_purchase_date)
            AS INTEGER
        ) AS days_since_last_purchase,
        CASE
            WHEN total_revenue >= 50000 THEN 'High Value'
            WHEN total_revenue >= 10000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS value_segment,
        CASE
            WHEN julianday('2011-12-09') - julianday(last_purchase_date) <= 30
                THEN 'Active'
            WHEN julianday('2011-12-09') - julianday(last_purchase_date) <= 90
                THEN 'At Risk'
            ELSE 'Inactive'
        END AS recency_segment
    FROM customer_summary
)
SELECT
    CustomerID,
    Country,
    total_revenue,
    total_orders,
    days_since_last_purchase,
    value_segment,
    recency_segment
FROM customer_status
WHERE value_segment IN ('High Value', 'Medium Value')
  AND recency_segment IN ('At Risk', 'Inactive')
ORDER BY total_revenue DESC
LIMIT 20;


-- 18. INNER JOIN EXAMPLE
WITH customer_value AS (
    SELECT
        CustomerID,
        ROUND(SUM(Revenue), 2) AS total_revenue,
        COUNT(DISTINCT InvoiceNo) AS total_orders
    FROM clean_transactions
    GROUP BY CustomerID
),
customer_recency AS (
    SELECT
        CustomerID,
        MAX(InvoiceDate) AS last_purchase_date
    FROM clean_transactions
    GROUP BY CustomerID
)
SELECT
    v.CustomerID,
    v.total_revenue,
    v.total_orders,
    r.last_purchase_date
FROM customer_value v
INNER JOIN customer_recency r
    ON v.CustomerID = r.CustomerID
ORDER BY v.total_revenue DESC
LIMIT 10;
