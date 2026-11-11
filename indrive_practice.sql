-- =========================================================
--  inDrive SQL practice  (PostgreSQL / pgAdmin 4)
--  Run PART 1 once to create the tables, then run each query
--  in PART 2 one at a time (highlight it, then press F5).
-- =========================================================

-- ---------------------------------------------------------
-- PART 1: Create tables + sample data
-- ---------------------------------------------------------
DROP TABLE IF EXISTS bids;
DROP TABLE IF EXISTS rides;

CREATE TABLE rides (
    ride_id       INT PRIMARY KEY,
    passenger_id  INT,
    city_id       INT,
    created_at    TIMESTAMP,
    status        VARCHAR(20)      -- 'completed', 'cancelled', 'no_driver'
);

CREATE TABLE bids (
    bid_id      INT PRIMARY KEY,
    ride_id     INT REFERENCES rides(ride_id),
    driver_id   VARCHAR(10),
    bid_price   NUMERIC(10,2),
    created_at  TIMESTAMP
);

INSERT INTO rides (ride_id, passenger_id, city_id, created_at, status) VALUES
(1, 101, 1, '2026-11-07 09:55', 'completed'),
(2, 102, 1, '2026-11-07 10:55', 'completed'),
(3, 103, 2, '2026-11-07 12:00', 'no_driver'),   -- nobody bid on this ride
(4, 104, 2, '2026-11-07 13:00', 'cancelled');

INSERT INTO bids (bid_id, ride_id, driver_id, bid_price, created_at) VALUES
(1, 1, 'A', 50, '2026-11-07 10:00'),
(2, 1, 'B', 40, '2026-11-07 10:05'),
(3, 1, 'C', 40, '2026-11-07 10:02'),   -- same price as B, but earlier
(4, 2, 'D', 70, '2026-11-07 11:00'),
(5, 2, 'E', 60, '2026-11-07 11:01'),
(6, 4, 'F', 55, '2026-11-07 13:01'),
(7, 4, 'A', 55, '2026-11-07 13:01');   -- full tie: same price AND same time

-- Check the data
SELECT * FROM rides;
SELECT * FROM bids;


-- ---------------------------------------------------------
-- PART 2: Practice queries (run them one by one)
-- ---------------------------------------------------------

-- Q1) See ROW_NUMBER in action (look at the rn column)
SELECT
    ride_id, driver_id, bid_price, created_at,
    ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY bid_price, created_at, bid_id) AS rn
FROM bids
ORDER BY ride_id, rn;


-- Q2) Compare ROW_NUMBER vs RANK vs DENSE_RANK side by side
SELECT
    ride_id, driver_id, bid_price,
    ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY bid_price) AS row_num,
    RANK()       OVER (PARTITION BY ride_id ORDER BY bid_price) AS rnk,
    DENSE_RANK() OVER (PARTITION BY ride_id ORDER BY bid_price) AS dense_rnk
FROM bids
ORDER BY ride_id, bid_price;


-- Q3) FINAL ANSWER: lowest bid per ride (rides with no bids show NULL)
WITH ranked_bids AS (
    SELECT
        ride_id, driver_id, bid_price, created_at,
        ROW_NUMBER() OVER (
            PARTITION BY ride_id
            ORDER BY bid_price ASC, created_at ASC, bid_id ASC
        ) AS rn
    FROM bids
)
SELECT
    r.ride_id, r.city_id, r.status,
    b.driver_id AS best_driver_id,
    b.bid_price AS lowest_bid
FROM rides r
LEFT JOIN ranked_bids b
       ON b.ride_id = r.ride_id
      AND b.rn = 1
ORDER BY r.ride_id;


-- Q4) THE TRAP: same query but filter in WHERE -> ride 3 disappears!
WITH ranked_bids AS (
    SELECT
        ride_id, driver_id, bid_price,
        ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY bid_price, created_at, bid_id) AS rn
    FROM bids
)
SELECT r.ride_id, b.driver_id, b.bid_price
FROM rides r
LEFT JOIN ranked_bids b ON b.ride_id = r.ride_id
WHERE b.rn = 1          -- <-- wrong place
ORDER BY r.ride_id;


-- Q5) COUNT(*) vs COUNT(b.bid_id) -> look at ride 3
SELECT
    r.ride_id,
    COUNT(*)        AS count_star,     -- wrong: gives 1 for ride 3
    COUNT(b.bid_id) AS count_bids      -- right: gives 0 for ride 3
FROM rides r
LEFT JOIN bids b ON b.ride_id = r.ride_id
GROUP BY r.ride_id
ORDER BY r.ride_id;


-- Q6) Per city: average bids per ride + % of rides with no bids
WITH bids_per_ride AS (
    SELECT r.ride_id, r.city_id, COUNT(b.bid_id) AS n_bids
    FROM rides r
    LEFT JOIN bids b ON b.ride_id = r.ride_id
    GROUP BY r.ride_id, r.city_id
)
SELECT
    city_id,
    ROUND(AVG(n_bids), 2)                                              AS avg_bids_per_ride,
    ROUND(100.0 * COUNT(*) FILTER (WHERE n_bids = 0) / COUNT(*), 2)    AS pct_no_bids
FROM bids_per_ride
GROUP BY city_id
ORDER BY city_id;


-- Q7) YOUR CHECK QUESTION: order by time only. Who gets rn = 1 in ride 1 and ride 2?
--     Guess first, then run it to check yourself.
SELECT
    ride_id, driver_id, bid_price, created_at,
    ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY created_at) AS rn
FROM bids
WHERE ride_id IN (1, 2)
ORDER BY ride_id, rn;
