-- Active: 1791309856637@@localhost@5432
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
false	89719
true	10281
*/

select round(avg(used_promotion::int), 4) * 100
from orders;

-- only about 10.28% of orders used a promotion.

-- 2. Total revenue 

select used_promotion, sum(total_price)
from orders
group by used_promotion;

/*
Orders with promotions generated a total revenue of $1,741,503.94 overall
Orders without promotions generated a total revenue of $12,466,258.19 overall.  
*/

-- 3. Average Order Value

select used_promotion, round(avg(total_price), 2)
from orders
group by used_promotion;

/*
The average order value for orders that used promotions is $169.39
The average order value for orders that did not use promotions is $138.95
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
The total profit for orders that used promotions was $514,038.17
The total profit for orders that did not use promotions was $4,031,086.08
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
The average gross profit per promoted order is $50.00
The average gross profit per non-promoted order is $44.93
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
The gross profit margin for promoted orders is 29.52%
The gross profit margin for non-promoted orders is 32.34%
*/

/*
Promotional orders have a higher average order value. 
Do they also have a higher gross profit margin, or are we trading profitability for larger baskets?

Promotional orders do not have a higher profit margin. The profit margin for promotional orders
is only 29.52%, while non-promotional orders have a profit margin of 32.34%. 
Although the promotional orders do generate higher profit per order ($50 vs ~$45), we do not 
retain as much of the profit. 
*/

SELECT
    o.used_promotion,
    SUM(o.total_price) AS total_revenue,
    SUM(oi.quantity * (oi.price_per_unit - p.cost)) AS total_gross_profit,
    ROUND(
        100.0 * SUM(oi.quantity * (oi.price_per_unit - p.cost))
        / NULLIF(SUM(o.total_price), 0),
        2
    ) AS gross_profit_margin_percent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY o.used_promotion;


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
PROMO_00054	439	1
PROMO_00178	266	2
PROMO_00042	258	3
PROMO_00070	251	4
PROMO_00171	231	5
PROMO_00176	187	6
PROMO_00002	183	7
PROMO_00067	180	8
PROMO_00104	177	9
PROMO_00099	163	10
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
PROMO_00054	73582.40	1
PROMO_00178	46450.07	2
PROMO_00171	41919.58	3
PROMO_00042	41617.94	4
PROMO_00070	40864.92	5
PROMO_00176	31970.76	6
PROMO_00002	30507.98	7
PROMO_00067	29565.16	8
PROMO_00104	29395.72	9
PROMO_00099	29238.10	10
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
PROMO_00054	23149.63	1
PROMO_00178	13164.85	2
PROMO_00171	12854.90	3
PROMO_00042	12799.45	4
PROMO_00070	11096.04	5
PROMO_00002	9627.75	6
PROMO_00176	9245.48	7
PROMO_00170	9051.63	8
PROMO_00067	9009.51	9
PROMO_00099	8944.74	10
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
PROMO_00046	404.98
PROMO_00182	237.28
PROMO_00161	234.79
PROMO_00077	227.27
PROMO_00174	225.62
PROMO_00100	217.45
PROMO_00025	214.20
PROMO_00164	209.85
PROMO_00150	209.42
PROMO_00118	200.21
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
PROMO_00198	173.55	61.39	35.37
PROMO_00108	609.01	210.32	34.53
PROMO_00025	642.59	213.61	33.24
PROMO_00003	2190.04	726.15	33.16
PROMO_00136	1811.82	600.66	33.15
PROMO_00046	404.98	133.38	32.93
PROMO_00080	7970.99	2621.33	32.89
PROMO_00015	4625.51	1516.11	32.78
PROMO_00008	4175.65	1358.17	32.53
PROMO_00007	3204.16	1039.72	32.45
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
    ) AS gross_profit_margin_percent
FROM orders o
JOIN profit_by_order pbo
    ON o.order_id = pbo.order_id
where o.promotion_id is not null
GROUP BY o.promotion_id
having COUNT(o.order_id) > 20
ORDER BY total_gross_profit desc ;
