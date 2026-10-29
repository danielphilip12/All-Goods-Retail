-- Active: 1792176784882@@localhost@5432
select * 
from promotions
limit 5;

-- ==========================
-- Section 1: Promotion vs non-promotion
-- ==========================

-- 1. Number of orders
select used_promotion, count(order_id) 
from orders
group by used_promotion;

/*
false	94866
true	5134
*/

select round(avg(used_promotion::int), 4) * 100
from orders;

-- only about 5.13% of orders used a promotion.

-- 2. Total revenue 

select used_promotion, sum(total_price)
from orders
group by used_promotion;

/*
Orders without promotions generated a total revenue of $13,347,207.05 overall
Orders with promotions generated a total revenue of $875,220.39 overall.  
*/

-- 3. Average Order Value

select used_promotion, round(avg(total_price), 2)
from orders
group by used_promotion;

/*
The average order value for orders that used promotions is $170.48
The average order value for orders that did not use promotions is $140.70
*/

-- 4. Total Gross Profit
with profit_per_order as (
select 
    o.order_id,
    sum(oi.quantity * (oi.price_per_unit - p.cost)) as total_profit
from orders o
join order_items oi
on o.order_id = oi.order_id
left join products p
on oi.product_id = p.product_id
group by o.order_id
)
select o.used_promotion, sum(ppo.total_profit)
from profit_per_order ppo
join orders o
on ppo.order_id = o.order_id
group by o.used_promotion;

/*
The total profit for orders that used promotions was $259,245.04
The total profit for orders that did not use promotions was $4,315,265.93
*/

-- 5. Average gross profit per order
select 
    o.used_promotion,
    round(sum(oi.quantity * (oi.price_per_unit - p.cost)) / count(distinct o.order_id),2) as avg_profit_per_order
from orders o
join order_items oi
on o.order_id = oi.order_id
left join products p
on oi.product_id = p.product_id
group by o.used_promotion;
/*
The average gross profit per promoted order is $50.50
The average gross profit per non-promoted order is $45.49
*/

-- 6. Gross Profit Margin
WITH profit_by_order AS (
    SELECT
        oi.order_id,
        SUM(
            oi.quantity * (oi.price_per_unit - p.cost)
        ) AS gross_profit
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY oi.order_id
)
SELECT
    o.used_promotion,
    SUM(o.total_price) AS total_revenue,
    SUM(pbo.gross_profit) AS total_gross_profit,
    ROUND(
        100.0 * SUM(pbo.gross_profit)
        / NULLIF(SUM(o.total_price), 0),
        2
    ) AS gross_profit_margin_percent
FROM orders o
JOIN profit_by_order pbo
    ON o.order_id = pbo.order_id
GROUP BY o.used_promotion;

/*
The gross profit margin for promoted orders is 29.62%
The gross profit margin for non-promoted orders is 32.33%
*/

/*
Promotional orders have a higher average order value. 
Do they also have a higher gross profit margin, or are we trading profitability for larger baskets?

Promotional orders do not have a higher profit margin. The profit margin for promotional orders
is only 29.52%, while non-promotional orders have a profit margin of 32.34%. 
Although the promotional orders do generate higher profit per order ($50 vs ~$45), we do not 
retain as much of the profit. 
*/



-- ===================
-- Section 2: Individual Promotion Performance
-- ===================

-- 1. Which promotions are assoicated with the most orders
select 
    promotion_id, 
    count(*) as total_orders,
    row_number() over (order by count(*) desc) as "rank"
from orders
where promotion_id is not null
group by promotion_id
order by 2 desc
limit 10;

/*
promotion_id total_orders rank
PROMO_00042	104	1
PROMO_00054	104	2
PROMO_00009	103	3
PROMO_00070	97	4
PROMO_00178	94	5
PROMO_00067	83	6
PROMO_00133	81	7
PROMO_00124	80	8
PROMO_00098	76	9
PROMO_00172	76	10
*/

-- 2. Which promotions generate the most revenue

select 
    promotion_id, 
    sum(total_price) as total_revenue,
    row_number() over (order by sum(total_price) desc) as "rank"
from orders
where promotion_id is not null
group by promotion_id
order by 2 desc
limit 10;

/*
promotion_id total_revenue rank
PROMO_00054	17959.95	1
PROMO_00070	17901.22	2
PROMO_00009	17649.09	3
PROMO_00042	16537.37	4
PROMO_00178	14385.30	5
PROMO_00085	14278.28	6
PROMO_00133	14248.72	7
PROMO_00072	13694.06	8
PROMO_00124	13545.48	9
PROMO_00068	13021.88	10
*/

-- 3. Which promotions generate the most gross profit

with profit_per_order as (
select 
    o.order_id,
    sum(oi.quantity * (oi.price_per_unit - p.cost)) as gross_profit
from orders o
join order_items oi
on o.order_id = oi.order_id
left join products p
on oi.product_id = p.product_id
group by o.order_id
)
select 
    o.promotion_id, 
    sum(ppo.gross_profit) as total_gross_profit,
    row_number() over (order by sum(ppo.gross_profit) desc) as "rank"
from orders o
join profit_per_order ppo
on o.order_id = ppo.order_id
where o.promotion_id is not null
group by promotion_id
order by 2 desc
limit 10;

/*
promotion_id total_gross_profit rank
PROMO_00054	5639.94	1
PROMO_00009	5277.39	2
PROMO_00070	5029.71	3
PROMO_00042	5029.58	4
PROMO_00085	4277.39	5
PROMO_00124	4205.43	6
PROMO_00133	4204.19	7
PROMO_00178	4167.97	8
PROMO_00067	3974.54	9
PROMO_00068	3971.34	10
*/

-- Average order value by promotion

/*
 * Explain what we need
 * 
 * to get the average order value for each promotion
 * we need the orders table total_price column and its 
 * promotion_id. We only need the one table
 */

select promotion_id, round(avg(totaL_price), 2) as avg_order_value
from orders
where promotion_id  is not null
group by promotion_id 
order by 2 desc
limit 10;

/*
PROMO_00195	283.55
PROMO_00090	266.05
PROMO_00154	244.34
PROMO_00025	242.15
PROMO_00159	229.25
PROMO_00021	225.42
PROMO_00007	225.27
PROMO_00174	223.03
PROMO_00018	222.26
PROMO_00187	220.55
 */

-- Gross profit margin by promotion

/*
 * Reusing the gross profit margin code 
 * from when we did the gross profit margin for each
 * group (promotion vs non-promotion)
 * we can modify it to group by promotion id rather than used_promotion 
 */

WITH profit_by_order AS (
    SELECT
        oi.order_id,
        SUM(
            oi.quantity * (oi.price_per_unit - p.cost)
        ) AS gross_profit
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY oi.order_id
)
SELECT
    o.promotion_id,
    SUM(o.total_price) AS total_revenue,
    SUM(pbo.gross_profit) AS total_gross_profit,
    ROUND(
        100.0 * SUM(pbo.gross_profit)
        / NULLIF(SUM(o.total_price), 0),
        2
    ) AS gross_profit_margin_percent
FROM orders o
JOIN profit_by_order pbo
    ON o.order_id = pbo.order_id
where o.promotion_id is not null
GROUP BY o.promotion_id
order by 4 desc
limit 10;

/*
PROMO_00082	1888.69	649.59	34.39
PROMO_00094	114.53	39.00	34.05
PROMO_00077	1064.19	361.08	33.93
PROMO_00055	378.14	126.87	33.55
PROMO_00136	1932.18	641.39	33.20
PROMO_00025	1695.02	560.83	33.09
PROMO_00170	5050.49	1647.49	32.62
PROMO_00145	4895.10	1577.25	32.22
PROMO_00021	901.67	290.35	32.20
PROMO_00130	1167.41	375.62	32.18
 */

select * from orders
where promotion_id = 'PROMO_00198';



WITH profit_by_order AS (
    SELECT
        oi.order_id,
        SUM(
            oi.quantity * (oi.price_per_unit - p.cost)
        ) AS gross_profit
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY oi.order_id
)
SELECT
    o.promotion_id,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_price) AS total_revenue,
    SUM(pbo.gross_profit) AS total_gross_profit,
    round(avg(o.totaL_price), 2) as avg_order_value,
    ROUND(
        100.0 * SUM(pbo.gross_profit)
        / NULLIF(SUM(o.total_price), 0),
        2
    ) AS gross_profit_margin_percent,
    rank() over (order by SUM(o.total_price) desc) as rank_revenue,
    rank() over (order by SUM(pbo.gross_profit) desc) as rank_gross_profit,
    rank() over (order by ROUND(
        100.0 * SUM(pbo.gross_profit)
        / NULLIF(SUM(o.total_price), 0),
        2
    ) desc) as rank_gross_profit_margin
FROM orders o
JOIN profit_by_order pbo
    ON o.order_id = pbo.order_id
where o.promotion_id is not null
GROUP BY o.promotion_id
having COUNT(o.order_id) > 20
ORDER BY 9;


-- =====================
-- Section 3: Promotion Effectiveness and Business Insights
-- =====================

-- part 1: Compare promotion usage and profitability

select * from orders limit 5;

WITH profit_by_order AS (
    SELECT
        oi.order_id,
        SUM(
            oi.quantity * (oi.price_per_unit - p.cost)
        ) AS gross_profit
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY oi.order_id
)
select 
    o.used_promotion,
    count(o.order_id) as total_orders,
    sum(o.total_price) as total_revenue,
    round(avg(o.total_price), 2) as average_order_value,
    SUM(pbo.gross_profit) AS total_gross_profit,
    round(avg(pbo.gross_profit), 2) AS avg_gross_profit,
    ROUND(
        100.0 * SUM(pbo.gross_profit)
        / NULLIF(SUM(o.total_price), 0),
        2
    ) AS gross_profit_margin_percent
from orders o
join profit_by_order pbo
on o.order_id = pbo.order_id
group by o.used_promotion;

/*
used_promotion  total_orders    total_revenue   average_order_value total_gross_profit  avg_gross_profit    gross_profit_margin
false	94866	13347207.05	140.70	4315265.93	45.49	32.33
true	5134	875220.39	170.48	259245.04	50.50	29.62
*/

-- Part 2: Identify promising individual promotions

-- Which promotions generated the most total gross profit
-- Top 5: 00054, 00009, 00070, 00042, 00085

-- Which have the highest gross profit margins among promotions with sufficient order volume?
-- Top 5: 00170, 00145, 00065, 00017, 00002

-- Do the same promotions rank highly on both?
-- No, although the rankings are similar based on revenue and gross profit, the ranking
-- based on the gross profit margin differs significantly. 
-- none of the top 5 revenue/gross profit even rank in the top 10 of gross profit margin. 

-- 3. Business Insights
-- Revenue
/*
The top revenue/profit generating promotion was PROMO_00054. This promotion generated $17,959.95 of revenue, and $5,639.94 of gross profit. 
Although not the highest, it does have a substantial profit margin of 31.40%, which is excellent, considering
the total number of orders that used this promotion was 104, the highest number of orders for any single promotion. 
*/

-- Gross profit margin
/*
The promotions that generated the highest profit margins ultimately were not used as 
often. The total number of orders for the highest profit margin promotions are under 100 for the 
top 5. 
*/

select 
    *,
    age(promotion_end_date, promotion_start_date),
    'revenue' as section
from promotions 
where promotion_id IN ('PROMO_00054', 'PROMO_00178', 'PROMO_00042', 'PROMO_00070', 'PROMO_00171')
union
select 
    *,
    age(promotion_end_date, promotion_start_date),
    'margin'
from promotions as section
where promotion_id IN ('PROMO_00080', 'PROMO_00015', 'PROMO_00008', 'PROMO_00151', 'PROMO_00175')
order by section; 

select promotion_id, count(*)
from promotion_items
where promotion_id in ('PROMO_00054', 'PROMO_00178', 'PROMO_00042', 'PROMO_00070', 'PROMO_00171', 'PROMO_00080', 'PROMO_00015', 'PROMO_00008', 'PROMO_00151', 'PROMO_00175')
group by promotion_id
order by 2 desc;

/*
The above queries tell us how long each promotion lasted (top 5 of each for revenue and profit margin) 
as well as how many promotional items were in each promotion. 

There was not too much difference between the duration of the promotion in 
either list, but the revenue toppers tended to have higher amounts of
items in their promotion. 

This may indicate that if we want to see better revenue from our promotions, 
we should expand the number of items in a promotion. Note, this is only 
a hypothesis, and further testing would be needed to confirm it. 
*/


/*
AI Assisted analysis/insights

=======================================================
SECTION 3: UPDATED PROMOTION EFFECTIVENESS FINDINGS
=======================================================

=======================================================
SECTION 3: UPDATED PROMOTION EFFECTIVENESS FINDINGS
=======================================================

**1. PROMOTIONAL ORDERS HAVE HIGHER ORDER VALUES AND GROSS
PROFIT PER ORDER, BUT LOWER GROSS PROFIT MARGINS.**

Of the 100,000 orders, 5,134 (5.13%) used promotions.
These orders generated $875,220.39 in revenue and
$259,245.04 in gross profit.

Promotional orders averaged $170.48 in order value,
compared with $140.70 for non-promotional orders.
Average gross profit per order was also higher for
promotional orders ($50.50 versus $45.49).

However, promotional orders had a lower gross profit
margin (29.62%) than non-promotional orders (32.33%).

Business implication:
Promotional orders are associated with larger baskets
and more gross profit per order, but a smaller share
of revenue is retained as gross profit. Management
should evaluate whether the additional order value and
gross profit justify the lower margin.

Limitation:
These are observational comparisons. They do not prove
that promotions caused larger orders or lower margins.
Differences in product mix, customer behavior, and
promotion selection may contribute to the results.


**2. PROMO_00054 IS THE LEADING PROMOTION BY TOTAL
REVENUE AND TOTAL GROSS PROFIT.**

PROMO_00054 was associated with 104 orders, tied with
PROMO_00042 for the highest order count among the
promotions in the current results.

It generated $17,959.95 in revenue and $5,639.94 in
gross profit, ranking first in both total revenue and
total gross profit among promotions with more than
20 orders.

Its gross profit margin was 31.40%, ranking eighth
among the promotions in that filtered comparison.
This illustrates that the promotion generating the
most total gross profit does not necessarily have the
highest gross profit margin.

Business implication:
Investigate the products, promotion characteristics,
and customer purchasing behavior associated with
PROMO_00054 to understand which factors may contribute
to its strong overall contribution. Evaluate its
performance alongside its margin rather than relying
on revenue or total gross profit alone.

Limitation:
Historical performance does not guarantee that
repeating the promotion will produce similar results.
The results also do not establish that the promotion
caused the observed revenue or profit.


**3. THE BEST-PERFORMING PROMOTIONS DIFFER BY METRIC.**

PROMO_00054 ranked first in both revenue ($17,959.95)
and total gross profit ($5,639.94). PROMO_00070 and
PROMO_00009 also ranked among the leading promotions
by total revenue and gross profit.

When considering gross profit margin among promotions
with more than 20 orders, PROMO_00170 ranked first at
32.62%, followed by PROMO_00145 at 32.22%,
PROMO_00065 at 31.81%, and PROMO_00017 at 31.75%.

PROMO_00054 ranked eighth by margin at 31.40%.
PROMO_00170, the highest-margin promotion in this
filtered comparison, generated $1,647.49 in gross
profit across 37 orders—substantially less total gross
profit than PROMO_00054.

Business implication:
Evaluate promotions using multiple measures, including
order volume, revenue, total gross profit, average
order value, and gross profit margin. High-margin
promotions may be attractive for profitability, while
high-volume promotions may contribute more total
gross profit. The preferred campaign depends on the
business objective.

Limitation:
The margin rankings depend on the filter requiring
more than 20 orders. This reduces the influence of
very low-volume campaigns but does not eliminate
uncertainty from differences in sample size, product
mix, and customer behavior.


**4. PROMOTION SIZE MAY BE ASSOCIATED WITH REVENUE
PERFORMANCE, BUT FURTHER ANALYSIS IS NEEDED.**

The exploratory comparison of promotion duration and
the number of associated promotional items suggested
that leading promotions by revenue tended to include
more items than the selected high-margin promotions.

Business implication:
Investigate whether the number of promoted items,
campaign duration, product popularity, and promotion
selection are associated with revenue and profitability.
Compare promotions with similar durations and exposure
where possible to better understand these relationships.

Limitation:
This comparison does not establish that increasing
the number of promoted items will increase revenue.
Product demand, pricing, campaign exposure, and other
factors may also explain differences in performance.


**5. PROMOTION USAGE IS LIMITED IN THE CURRENT DATASET.**

Only 5.13% of orders used a promotion, accounting for
$875,220.39 of the approximately $14.22 million in
total order revenue.

Business implication:
Management could investigate whether the relatively
low promotion usage reflects a deliberate strategy,
limited promotion availability, or customer behavior.
It may be useful to test targeted promotions on
selected products or customer groups and evaluate
their effects on total gross profit and margin.

Limitation:
The synthetic dataset does not establish an optimal
promotion usage rate or demonstrate how real customers
would respond to a change in promotion frequency.
Any proposed changes should be evaluated through
additional analysis or controlled experiments.
*/