SET ECHO OFF
SET FEEDBACK OFF
SET HEADING ON
SET SQLFORMAT CSV

SPOOL &1

WITH monthly_sales AS (
    SELECT
        TRUNC(t.time_id, 'MM') AS month_start,
        t.calendar_year,
        t.calendar_month_number,
        p.prod_category AS product_category,
        ch.channel_desc,
        SUM(s.quantity_sold) AS total_quantity,
        SUM(s.amount_sold) AS total_amount,
        ROUND(
            SUM(s.amount_sold) / NULLIF(SUM(s.quantity_sold), 0),
            2
        ) AS average_unit_price,
        COUNT(DISTINCT s.cust_id) AS customer_count,
        COUNT(*) AS transaction_count
    FROM sh.sales s
    JOIN sh.times t
        ON t.time_id = s.time_id
    JOIN sh.products p
        ON p.prod_id = s.prod_id
    JOIN sh.channels ch
        ON ch.channel_id = s.channel_id
    GROUP BY
        TRUNC(t.time_id, 'MM'),
        t.calendar_year,
        t.calendar_month_number,
        p.prod_category,
        ch.channel_desc
)
SELECT
    TO_CHAR(month_start, 'YYYY-MM-DD') AS month_start,
    calendar_year,
    calendar_month_number,
    product_category,
    channel_desc,
    total_quantity,
    ROUND(total_amount, 2) AS total_amount,
    average_unit_price,
    customer_count,
    transaction_count
FROM monthly_sales
ORDER BY
    month_start,
    product_category,
    channel_desc;

SPOOL OFF
SET SQLFORMAT ANSICONSOLE
SET FEEDBACK ON

PROMPT Dataset exported successfully.
