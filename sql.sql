SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY customer_id
           ORDER BY transaction_date DESC
       ) rn
FROM transactions;

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

SELECT
    customer_id,
    transaction_date,
    amount,
    SUM(amount) OVER(
        PARTITION BY customer_id
        ORDER BY transaction_date
    ) running_balance
FROM transactions;

SELECT
    transaction_id,
    amount,
    LAG(amount) OVER(
        ORDER BY transaction_date
    ) previous_amount
FROM transactions;

--Common SQL Challenges
--Top N per group

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

SELECT
    transaction_id,
    COUNT(*)
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


--Gap Analysis
SELECT
    transaction_date,
    LAG(transaction_date)
       OVER(ORDER BY transaction_date)
FROM transactions;


