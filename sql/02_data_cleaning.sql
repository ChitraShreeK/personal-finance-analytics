-- Raw Dataset loaded. Starting with Data Cleaning
SELECT * FROM spending_patterns_detailed_raw LIMIT 100;
    
-- creating the copy of raw dataset
CREATE TABLE spending_patterns_staging
LIKE spending_patterns_detailed_raw;
    
SELECT * FROM spending_patterns_staging;
    
INSERT spending_patterns_staging
SELECT * FROM spending_patterns_detailed_raw;
    
SELECT * FROM spending_patterns_staging LIMIT 100; -- Copied successfully

-- Standardizing the column

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Customer ID` TO customer_id;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Category` TO category;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Item` TO item;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Quantity` TO quantity;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Price Per Unit` TO price_per_unit;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Total Spent` TO total_spent;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Payment Method` TO payment_method;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Location` TO payment_mode;

ALTER TABLE spending_patterns_staging
RENAME COLUMN `Transaction Date` TO transaction_date;

SELECT * FROM spending_patterns_staging LIMIT 100; 
-- column name changed successfully

-- looking for distinct values in categorical columns
SELECT DISTINCT category
FROM spending_patterns_staging;

SELECT DISTINCT item
FROM spending_patterns_staging;

SELECT DISTINCT payment_method
FROM spending_patterns_staging;

SELECT DISTINCT payment_mode
FROM spending_patterns_staging;
-- all looks fine 

UPDATE spending_patterns_staging
SET payment_mode = TRIM(LOWER(payment_mode));

UPDATE spending_patterns_staging
SET payment_method = TRIM(LOWER(payment_method));

UPDATE spending_patterns_staging
SET item = TRIM(LOWER(item));

UPDATE spending_patterns_staging
SET category = TRIM(LOWER(category));

UPDATE spending_patterns_staging
SET payment_mode = REPLACE(payment_mode, ' ', '_');

UPDATE spending_patterns_staging
SET payment_mode = REPLACE(payment_mode, '-', '_');

UPDATE spending_patterns_staging
SET payment_method = REPLACE(payment_method, ' ', '_');

UPDATE spending_patterns_staging
SET category = REPLACE(category, ' ', '_');

UPDATE spending_patterns_staging
SET item = REPLACE(item, ' ', '_');

UPDATE spending_patterns_staging
SET category = REPLACE(category, '/', '_');

UPDATE spending_patterns_staging
SET item = REPLACE(item, '/', '_');

SELECT * FROM spending_patterns_staging LIMIT 100;
-- all the columns values updated

-- changing the 'transaction_date' type from 'text' to 'date'
UPDATE spending_patterns_staging
SET `transaction_date` = STR_TO_DATE(`transaction_date`, '%Y-%m-%d');

ALTER TABLE spending_patterns_staging
MODIFY COLUMN transaction_date DATE;

ALTER TABLE spending_patterns_staging
MODIFY COLUMN price_per_unit DECIMAL(10, 2);

ALTER TABLE spending_patterns_staging
MODIFY COLUMN total_spent DECIMAL(10, 2);

SELECT category, COUNT(*)
FROM spending_patterns_staging
GROUP BY category
ORDER BY COUNT(*) DESC; -- no duplicate category found with misspellings

SELECT *
FROM spending_patterns_staging;

-- checking for any NULL or Blank values
SELECT *
FROM spending_patterns_staging
WHERE price_per_unit IS NULL
AND total_spent IS NULL; -- no result found

SELECT *
FROM spending_patterns_staging
WHERE quantity = 0 AND price_per_unit = 0 AND total_spent = 0; -- no result found

SELECT * 
FROM spending_patterns_staging
WHERE customer_id IS NULL
AND category IS null; -- NO RESULT FOUND

SELECT *
FROM spending_patterns_staging
WHERE item IS NOT NULL
AND quantity = 0 AND transaction_date IS NULL; -- NO RESULT FOUND

SELECT *
FROM spending_patterns_staging
WHERE payment_method IS NULL
AND payment_mode IS NULL; -- NO RESULT FOUND

-- ensuring total_spent = quantity * price_per_unit

SELECT
	customer_id,
    category,
    item,
    quantity,
    price_per_unit,
    total_spent,
    (quantity * price_per_unit) AS calc_total_spent,
    ROUND(total_spent - (quantity * price_per_unit), 2) AS difference
FROM spending_patterns_staging
WHERE ABS(total_spent - (quantity * price_per_unit)) > 0.01;

-- ~100 rows had total_spent consistently off by -0.02. This appears to be a systematic rounding adjustment. So checking total % of rows affected

SELECT
	COUNT(*) AS mismatched_rows,
    COUNT(*) * 100.0/(SELECT COUNT(*) FROM spending_patterns_staging) AS mismatch_pct,
    MIN(ABS(total_spent - (quantity * price_per_unit))) AS min_diff,
    MAX(ABS(total_spent - (quantity * price_per_unit))) AS max_diff
FROM spending_patterns_staging
WHERE abs(total_spent - (quantity * price_per_unit)) > 0.01;
-- found 787 mismatched_rows which is 7.87% had a systematic -0.02 discrepancy in total_spent. It appears to be a systematic rounding adjustment
-- For further analysis using calc_total_spent = quantiy * price_per_unit to ensure consistency

ALTER TABLE spending_patterns_staging
ADD COLUMN calc_total_spent DECIMAL(10, 2);

UPDATE spending_patterns_staging
SET calc_total_spent = quantity * price_per_unit;

-- checking for any negative prices or quantity
SELECT *
FROM spending_patterns_staging
WHERE quantity < 0 OR price_per_unit < 0 OR total_spent < 0; -- no results 

-- checking transaction dates
SELECT MIN(transaction_date), MAX(transaction_date)
FROM spending_patterns_staging; -- min and max dates are within the valid range

-- Checking for duplicate values
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY customer_id, category, item, quantity, price_per_unit, total_spent, payment_method, payment_mode, transaction_date
) AS row_num
FROM spending_patterns_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- No duplicate row found

-- checking for the row counts match from the original data count to copied
SELECT COUNT(*) FROM spending_patterns_detailed_raw;
SELECT COUNT(*) FROM spending_patterns_staging; -- both have the same count of rows(10000)

SELECT * FROM spending_patterns_staging LIMIT 100;