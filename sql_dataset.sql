-- Sample data for the window-function and SQL challenge queries in sql.sql.
-- Safe to run more than once: existing sample rows are left unchanged.

CREATE TABLE IF NOT EXISTS public.transactions (
    row_id BIGINT PRIMARY KEY,
    transaction_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    amount NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.employees (
    employee_id BIGINT PRIMARY KEY,
    employee_name TEXT NOT NULL,
    team TEXT NOT NULL,
    salary NUMERIC(10, 2) NOT NULL
);

INSERT INTO public.transactions
    (row_id, transaction_id, customer_id, transaction_date, amount)
VALUES
    (1, 7001, 101, DATE '2025-01-02', 120.00),
    (2, 7002, 102, DATE '2025-01-03', 75.00),
    (3, 7003, 101, DATE '2025-01-05', 45.00),
    (4, 7004, 103, DATE '2025-01-07', 210.00),
    (5, 7005, 102, DATE '2025-01-10', 100.00),
    (6, 7006, 104, DATE '2025-01-12', 80.00),
    (7, 7007, 101, DATE '2025-01-15', 60.00),
    (8, 7008, 103, DATE '2025-01-18', 95.00),
    (9, 7009, 104, DATE '2025-01-21', 130.00),
    (10, 7010, 102, DATE '2025-01-24', 25.00),
    (11, 7003, 101, DATE '2025-01-27', 45.00),
    (12, 7011, 103, DATE '2025-01-30', 160.00),
    (13, 7012, 104, DATE '2025-02-02', 70.00)
ON CONFLICT (row_id) DO NOTHING;

INSERT INTO public.employees
    (employee_id, employee_name, team, salary)
VALUES
    (1, 'Ava Patel', 'Engineering', 132000.00),
    (2, 'Noah Kim', 'Engineering', 125000.00),
    (3, 'Mia Chen', 'Engineering', 118000.00),
    (4, 'Ethan Reed', 'Engineering', 110000.00),
    (5, 'Isla Morgan', 'Data', 128000.00),
    (6, 'Leo Garcia', 'Data', 121000.00),
    (7, 'Zoe Brooks', 'Data', 115000.00),
    (8, 'Owen James', 'Data', 108000.00),
    (9, 'Amir Khan', 'Operations', 99000.00),
    (10, 'Lily Wright', 'Operations', 94000.00),
    (11, 'Kai Nguyen', 'Operations', 89000.00),
    (12, 'Emma Davis', 'Operations', 85000.00),
    (13, 'Lucas Silva', 'Support', 82000.00),
    (14, 'Grace Wilson', 'Support', 78000.00),
    (15, 'Theo Martin', 'Support', 74000.00),
    (16, 'Ruby Clark', 'Support', 70000.00)
ON CONFLICT (employee_id) DO NOTHING;
