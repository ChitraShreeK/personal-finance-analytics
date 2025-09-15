SELECT * FROM spending_patterns_staging LIMIT 100;

-- checking for the repeated customer ids
SELECT customer_id,
COUNT(*) AS transaction_count
FROM spending_patterns_staging
GROUP BY customer_id
HAVING COUNT(*) > 1; -- 200 rows returned

-- randomly checking customer id to see the transaction details
SELECT *
FROM spending_patterns_staging
WHERE customer_id = 'CUST_0199'; -- same customer id made 44 transactions

-- Starting by summarizing the dataset
-- looking for how many customers and transactions are there
SELECT COUNT(DISTINCT customer_id) AS total_customers,
	COUNT(*) AS total_transactions
FROM spending_patterns_staging; -- Total Customers: 200, total transactions: 10000

-- checking for the transactions date range
SELECT MIN(transaction_date) AS start_date,
	   MAX(transaction_date) AS end_date
FROM spending_patterns_staging;  -- start date: 2023-01-01, end date: 2025-01-13

-- 	total spent summary
SELECT
	SUM(total_spent) AS sum_total, -- sum total: 25347508.90
	AVG(total_spent) AS avg_total_spent, -- avg total: 2534.750890
	MAX(total_spent) AS max_total_spent,  -- max total: 352230.76
	MIN(total_spent) AS min_total_spent   -- min total: 1.11
FROM spending_patterns_staging;

-- total spent on each category
SELECT category,
	COUNT(*) AS num_transactions,
    SUM(total_spent) AS total_spent,
    ROUND(AVG(total_spent), 2) AS avg_transaction
FROM spending_patterns_staging
GROUP BY category
ORDER BY total_spent DESC; -- got the group by list of all the unique category and there total transactions sum amount and avg amount spent
-- highest amount spent on shopping category with 775(num_transactions), total_spent:22654524.44 and avg_transaction: 29231.64
-- lowest spent on groceries with 799(num_transactions), total_spent:17416.69, avg_transaction: 21.80

-- now checking for top 10 items purchased
SELECT item,
	SUM(total_spent) AS total_spent,
    COUNT(*) AS num_transactions
FROM spending_patterns_staging
GROUP BY item
ORDER BY total_spent DESC
LIMIT 10;
-- 1st item: car, total_spent: 22051024.82, num_transactions: 194
-- 10th item: medicine, total_spent: 100748.42, num_transactions: 252

-- checking for the monthly spending trends
SELECT DATE_FORMAT(transaction_date, '%Y-%m') AS month_of_year,
	SUM(total_spent) AS total_spent
FROM spending_patterns_staging
GROUP BY month_of_year
ORDER BY month_of_year; -- got the sum of total amout spent every month year wise for 2025 only till Jan month details are available 

-- looking for top spending customers
SELECT customer_id,
	SUM(total_spent) AS total_spent,
    COUNT(*) AS transactions
FROM spending_patterns_staging
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;
-- 1st customer_id: CUST_0033, total_spent: 676346.70, transactions: 45
-- 10th customer_id: CUST_0200, total_spent: 382732.97, transactions: 44

-- looking for average spent based on payment method
SELECT payment_method,
	COUNT(*) AS num_transactions,
    SUM(total_spent) AS total_spent,
    ROUND(AVG(total_spent), 2) AS avg_total_spent
FROM spending_patterns_staging
GROUP BY payment_method
ORDER BY total_spent DESC;
-- Most transactions were done via digital_wallet with 2560 transactions with the total spending of 7754538.81 and avg spent is 3029.12

-- looking for each customer high spending
SELECT customer_id,
	SUM(total_spent) AS total_spent
FROM spending_patterns_staging
GROUP BY customer_id
ORDER BY total_spent DESC;
-- customer id CUST_0033 has the highest spending of 676346.70

-- checking for monthly expenses based on category
SELECT DATE_FORMAT(transaction_date, '%Y-%m') AS month_of_year,
	category,
    SUM(total_spent) AS total_spent
FROM spending_patterns_staging
GROUP BY month_of_year, category
ORDER BY total_spent DESC;

-- On an average how much customer spend
SELECT customer_id,
	SUM(total_spent) AS total_spent,
	COUNT(*) AS transactions,
    ROUND(SUM(total_spent)/COUNT(*), 2) AS avg_transaction
FROM spending_patterns_staging
GROUP BY customer_id
ORDER BY avg_transaction DESC;

-- looking for high and low transactions
SELECT CASE
		WHEN total_spent < 100 THEN 'Low'
		WHEN total_spent BETWEEN 100 AND 1000 THEN 'Medium'
		WHEN total_spent BETWEEN 1000 AND 10000 THEN 'High'
		ELSE 'Very High'
	END AS spend_pattern,
    COUNT(*) AS num_transactions,
    SUM(total_spent) AS total_spent
FROM spending_patterns_staging
GROUP BY spend_pattern
ORDER BY total_spent DESC;