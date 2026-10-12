CREATE EXTENSION IF NOT EXISTS tablefunc;

-- =======================================
-- 1. Total number of customers
-- =======================================
select count(DISTINCT customer_id) 
from customers;

-- 10000

-- =======================================
-- 2. Number of active members
-- =======================================
select count(*) as total_members
from customers
where is_member = true and membership_cancel_date is NULL;

-- 5126

-- =======================================
-- 3. Number of current non-members
-- =======================================
select count(*) as total_non_members
from customers
where is_member = false or membership_cancel_date is not NULL;

-- 4874

-- =======================================
-- 4. Membership percentage
-- =======================================
select 
    AVG(case when is_member = true and membership_cancel_date is NULL then 1 else 0 end)
from customers;

-- Membership percentage is 51.26%

-- =======================================
-- 5. New Memberships by month
-- =======================================

select * from customers
limit 10;

SELECT *
FROM crosstab(
    $$
    SELECT 
        EXTRACT(MONTH FROM membership_join_date) AS month,
        EXTRACT(YEAR FROM membership_join_date) AS year,
        COUNT(customer_id) AS new_members
    FROM customers
    WHERE EXTRACT(MONTH FROM membership_join_date) IS NOT NULL
    GROUP BY 1, 2
    ORDER BY 1, 2
    $$,
    $$
    SELECT DISTINCT EXTRACT(YEAR FROM membership_join_date) AS year
    FROM customers
    WHERE membership_join_date IS NOT NULL
    ORDER BY year
    $$
) AS ct (
    month INT,
    "2021" INT,
    "2022" INT,
    "2023" INT,
    "2024" INT,
    "2025" INT
);

/*
month 2021 2022 2023 2024 2025
1	118	86	96	117	105
2	98	91	92	93	78
3	117	102	109	112	103
4	109	107	104	93	104
5	103	96	107	100	92
6	108	90	88	115	126
7	124	121	92	111	94
8	99	102	123	119	107
9	87	98	102	98	94
10	128	105	104	86	93
11	98	91	100	111	90
12	98	106	97	104	4
*/

-- =======================================
-- 6. Average Order Value: Member vs Non-Member
-- =======================================
select * from orders limit 10;

select is_member, round(avg(total_price), 2)
from orders
group by is_member;

/*
false	143.01
true	141.36
*/

-- =======================================
-- 7. Average Orders Per Customer: Member vs Non-Member
-- =======================================
with orders_by_customer as (
    select customer_id, is_member, count(order_id) as order_count
from orders
group by customer_id, is_member
)
select obc.is_member, avg(obc.order_count)
from orders_by_customer obc
group by obc.is_member;

/*
false	9.1245812395309883
true	9.4365278474661315
*/



-- =======================================
-- 8. Total Revenue: Member vs Non-Member
-- =======================================
select is_member, round(sum(total_price), 2)
from orders
group by is_member;

/*
false	6232113.11
true	7975649.02
*/


-- ===== 
-- Side Task: december 2025 member joins
-- =====
select
    customer_id,
    membership_join_date
from customers
where membership_join_date between '2025-12-01' and '2025-12-31';

/*
CUST_003266	2025-12-01 00:00:00+00
CUST_006957	2025-12-01 00:00:00+00
CUST_007419	2025-12-01 00:00:00+00
CUST_009219	2025-12-01 00:00:00+00
*/

-- =======================================
-- 9. Average Revenue per customer
-- =======================================
with revenue_by_customer as (
    select customer_id, is_member, sum(total_price) as revenue
from orders
group by customer_id, is_member
)
select rbc.is_member, avg(rbc.revenue)
from revenue_by_customer rbc
group by rbc.is_member;

/*
false   1304.8813044388609715
true	1333.9436394045827061
*/

/*
Do members appear to be more valuable customers than non-members, based on your results?
Members appear to be slightly more valuble than non-members. Although there is a sizable difference in 
generated revenue between membership status, the average order value and average order values
only slightly differ from each other. 


What pattern do you see in monthly membership additions across 2021–2025?
There do not seem to be any distinct patterns in terms of membership join date. 
However, this is likely due to the synthetic nature of the data generation,
as the date were randomly generated, making it likely that 
no patterns emerges due to randomness. 


What is one follow-up question you'd recommend management investigate?
Why are members still spending the same amount of money as non-members, as members
should be getting discounts on select items each promotion period?
*/