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

