SET LINESIZE 200
SET PAGESIZE 100

PROMPT === SH SOURCE ROW COUNTS ===

SELECT 'SALES' AS table_name, COUNT(*) AS row_count FROM sh.sales
UNION ALL
SELECT 'PRODUCTS', COUNT(*) FROM sh.products
UNION ALL
SELECT 'TIMES', COUNT(*) FROM sh.times
UNION ALL
SELECT 'CUSTOMERS', COUNT(*) FROM sh.customers
UNION ALL
SELECT 'CHANNELS', COUNT(*) FROM sh.channels
UNION ALL
SELECT 'PROMOTIONS', COUNT(*) FROM sh.promotions;

PROMPT === SALES DATE RANGE ===

SELECT
    MIN(t.time_id) AS first_sale_date,
    MAX(t.time_id) AS last_sale_date,
    COUNT(DISTINCT TRUNC(t.time_id, 'MM')) AS covered_months
FROM sh.sales s
JOIN sh.times t
    ON t.time_id = s.time_id;

PROMPT === NULL AND INVALID VALUE CHECKS ===

SELECT
    SUM(CASE WHEN s.amount_sold IS NULL THEN 1 ELSE 0 END)
        AS null_amount_rows,
    SUM(CASE WHEN s.quantity_sold IS NULL THEN 1 ELSE 0 END)
        AS null_quantity_rows,
    SUM(CASE WHEN s.amount_sold < 0 THEN 1 ELSE 0 END)
        AS negative_amount_rows,
    SUM(CASE WHEN s.quantity_sold <= 0 THEN 1 ELSE 0 END)
        AS non_positive_quantity_rows
FROM sh.sales s;

PROMPT === ORPHAN RELATIONSHIP CHECKS ===

SELECT
    SUM(CASE WHEN p.prod_id IS NULL THEN 1 ELSE 0 END)
        AS missing_product_rows,
    SUM(CASE WHEN t.time_id IS NULL THEN 1 ELSE 0 END)
        AS missing_time_rows,
    SUM(CASE WHEN c.cust_id IS NULL THEN 1 ELSE 0 END)
        AS missing_customer_rows,
    SUM(CASE WHEN ch.channel_id IS NULL THEN 1 ELSE 0 END)
        AS missing_channel_rows
FROM sh.sales s
LEFT JOIN sh.products p
    ON p.prod_id = s.prod_id
LEFT JOIN sh.times t
    ON t.time_id = s.time_id
LEFT JOIN sh.customers c
    ON c.cust_id = s.cust_id
LEFT JOIN sh.channels ch
    ON ch.channel_id = s.channel_id;
