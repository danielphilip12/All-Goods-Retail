-- Active: 1792176784882@@localhost@5432@allgoods_db
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- =======================================
-- 1. Total number of customers
-- =======================================
select count(DISTINCT customer_id) 
from customers;

-- 10,000

-- =======================================
-- 2. Number of active members
-- =======================================
select count(*) as total_members
from customers
where is_member = true and membership_cancel_date is NULL;

-- 5,126

-- =======================================
-- 3. Number of current non-members
-- =======================================
select count(*) as total_non_members
from customers
where is_member = false or membership_cancel_date is not NULL;

-- 4,874

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
false	142.39
true	141.82
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
false	7.52
true	5.33
*/



-- =======================================
-- 8. Total Revenue: Member vs Non-Member
-- =======================================
select is_member, round(sum(total_price), 2)
from orders
group by is_member;

/*
false	10,116,998.08
true	4,105,429.36
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
false   1070.47
true	755.93
*/

/*
=======================================================
ANALYSIS FINDINGS: CUSTOMER MEMBERSHIP AND SPENDING
=======================================================

1. Do members appear to be more valuable customers than non-members?

Based on the current results, members do not appear to generate more revenue
per customer than non-members.

There are 5,126 active members (51.26% of the customer base) and 4,874
current non-members. The average order value is similar between the two
groups: $141.82 for member orders and $142.39 for non-member orders.

Non-members average 7.52 orders per customer, compared with 5.33 orders
per customer for members. Average revenue per customer is also higher for
non-members ($1,070.47) than for members ($755.93).

Total revenue from non-member orders is approximately $10.12 million,
compared with $4.11 million from member orders.

These results suggest that non-members generate more revenue per customer
and place more orders on average in this dataset. However, this does not
establish that membership reduces customer value. The results may be
influenced by membership join dates, customer tenure, and the way the
synthetic data was generated. A fair comparison would account for how long
customers have been members and how long they have been observed.

2. What pattern appears in monthly membership additions from 2021–2025?

Monthly membership additions appear relatively consistent, without a clear
seasonal pattern across most of the period. Monthly counts generally fall
within a similar range across years.

The available results are synthetic, so the apparent lack of seasonality
may reflect the random date-generation process rather than actual retail
customer behavior.

December 2025 has only four recorded membership additions, substantially
fewer than most other months. This may reflect the end of the generation
period or an issue in the date-generation logic and should be investigated
before drawing conclusions about December seasonality.

3. What follow-up question should management investigate?

Why do active members have fewer orders and lower average revenue per
customer than non-members, despite having nearly identical average order
values?

Management should investigate whether membership is associated with
increased purchase frequency, customer retention, or spending over time.
The analysis should account for membership tenure and compare customer
behavior before and after joining.

Management should also evaluate whether promotions influence member
purchasing behavior. The current results do not establish that members
receive no benefit from promotions, nor do they show that promotions cause
higher or lower spending. A separate analysis of promotional purchases,
discounts, and member versus non-member behavior would help answer this.
*/