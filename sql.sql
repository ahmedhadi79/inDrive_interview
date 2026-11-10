-- For each customer, what are their transactions from newest to oldest, and what is each transaction’s sequence number?

SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY customer_id
           ORDER BY transaction_date DESC
       ) rn
FROM transactions;

-- What is each customer’s most recent transaction?

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY customer_id
               ORDER BY transaction_date DESC
           ) rn
    FROM transactions
)
SELECT *
FROM cte
WHERE rn = 1;

-- For each customer, what is their running balance after each transaction?

SELECT
    customer_id,
    transaction_date,
    amount,
    SUM(amount) OVER(
        PARTITION BY customer_id
        ORDER BY transaction_date
    ) running_balance
FROM transactions;

-- For each transaction, what is the previous transaction’s amount?

SELECT
    transaction_id,
    amount,
    LAG(amount) OVER(
        ORDER BY transaction_date
    ) previous_amount
FROM transactions;

--Common SQL Challenges
--Top N per group
-- For each team, what are the top 3 highest paid employees?
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY team
               ORDER BY salary DESC
           ) rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn <= 3;

--Duplicate Detection
-- Find all transactions that have duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*)
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


--Gap Analysis
-- For each transaction, what is the previous transaction’s date?
SELECT
    transaction_date,
    LAG(transaction_date)
       OVER(ORDER BY transaction_date)
FROM transactions;


