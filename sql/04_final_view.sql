-- This view is the final, clean, and analytical source for the dashboard.
CREATE VIEW vw_financial_dashboard AS
SELECT
    customer_id,
    category,
    item,
    quantity,
    price_per_unit,
    total_spent,
    payment_method,
    payment_mode,
    transaction_date,
    calc_total_spent,

    -- calculated columns for analysis
    YEAR(transaction_date) AS transaction_year,
    MONTH(transaction_date) AS transaction_month,
    DAYNAME(transaction_date) AS transaction_day_of_week,
    CASE
        WHEN total_spent < 100 THEN 'Low'
        WHEN total_spent BETWEEN 100 AND 1000 THEN 'Medium'
        WHEN total_spent BETWEEN 1000 AND 10000 THEN 'High'
        ELSE 'Very High'
    END AS spend_pattern,
    CASE
        WHEN category = 'salary' THEN 'income'
        ELSE 'expense'
    END AS transaction_type

FROM
    spending_patterns_staging;
    
SELECT * FROM vw_financial_dashboard LIMIT 100;