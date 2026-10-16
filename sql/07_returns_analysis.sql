-- Active: 1792176784882@@localhost@5432

select * 
from returns
limit 5;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'returns'
ORDER BY ordinal_position;

/*
What does one row in returns represent? For example, is it a returned item, a return event, or an entire order return?
It represents a single returned item. There is an order_item_id foreign key, so it relates to a single item


Which columns identify the product and order, if those columns exist?
I can relate to orders directly with the order_id key, but to connect to the product,
I would have to go through the order_items table with the order_item_id
then connect from order_items' product_id key to the products table. 


Which columns contain the return quantity, refund amount, and reason, if available?
quantity returned tells us the return quantity and refund_amount tells us the amount refunded. 
We do not have a column telling us the reason for return. 
*/

-- =============================
-- Section 1: Return Overview
-- =============================

-- 1. How many returns were made in total?
select count(*) as total_returns
from returns;

-- 42480

-- 2. How much money has been refunded
select sum(refund_amount) as total_refunded
from returns;

-- $766,142.71

-- 3. What percentage of orders have at least one return?
select 
    round((count(distinct order_id) * 100.0 / (select count(distinct order_id) from orders)), 2) as return_percentage
from returns;

-- 34.03%

-- 4. How many units have been returned?
select sum(quantity_returned) as total_units_returned
from returns;

-- 85,228

-- =============================
-- Section 2: Return Overview
-- =============================

-- 1. Which product has the highest number of returns?
with product_returns as (
select 
    oi.product_id, 
    sum(r.quantity_returned) as total_returns
from returns r
join order_items oi
on r.order_item_id = oi.order_item_id
group by oi.product_id
)
select 
    p.name,
    COALESCE(pr.total_returns, 0) as returns
from products p 
left join product_returns pr
on p.product_id = pr.product_id
order by 2 desc;

-- Top 5 refunded products
/*
Tuna Steaks - 16 oz #2	    1357
Penne Pasta - 32 oz	        922
Quinoa - 6 pack #2	        709
Lemon Lime Soda - Original	639
Baby Food Pouches - Premium	595
*/

-- Tuna Steaks - 16oz #2 has the most returns of any product, being returned 1,357 times. 
-- According to the products sales analysis, this product was the most profitable,
-- so we may need to rectify that if the returns counter the profit. 

-- 2. Which products has the highest refunded amounts?

with product_return_amounts as (
select 
    oi.product_id, 
    sum(r.refund_amount) as total_amount_refunded
from returns r
join order_items oi
on r.order_item_id = oi.order_item_id
group by oi.product_id
)
select 
    p.name,
    COALESCE(pra.total_amount_refunded, 0) as total_return_amount
from products p 
left join product_return_amounts pra
on p.product_id = pra.product_id
order by 2 desc;

-- Top 5 refunded products and amounts
/*
Tuna Steaks - 16 oz #2	    22322.00
Baby Food Pouches - Premium	14669.00
Penne Pasta - 32 oz	        8976.03
Baby Lotion - 2 lb	        8645.21
Atlantic Salmon - 2 lb	    8290.59
*/

-- 3. Which products have the highest return rates relative to sales?

with product_sales as (
    select
        product_id,
        sum(quantity) as total_quantity_sold
    from order_items
    group by product_id
),
product_returns as (
    select
        oi.product_id,
        sum(r.quantity_returned) as total_quantity_returned
    from returns r
    join order_items oi
        on r.order_item_id = oi.order_item_id
    group by oi.product_id
)
select
    p.product_id,
    p.name,
    ps.total_quantity_sold,
    coalesce(pr.total_quantity_returned, 0) as total_quantity_returned,
    round(
        coalesce(pr.total_quantity_returned, 0) * 100.0
        / ps.total_quantity_sold,
        2
    ) as return_rate_percentage
from product_sales ps
join products p
    on p.product_id = ps.product_id
left join product_returns pr
    on pr.product_id = ps.product_id
where ps.total_quantity_sold >= 100
order by return_rate_percentage desc, total_quantity_returned desc;

/*
Top 5 products by return rate (descending) where quantity sold is >= 100
PROD_000190	Baby Diapers - 12 pack	210	33	15.71
PROD_000483	Toilet Paper - 6 pack #2	410	48	11.71
PROD_000224	Baby Wipes - Organic	884	99	11.20
PROD_000059	Floor Cleaner - Premium	181	20	11.05
PROD_000293	Soy Sauce - 8 oz	306	33	10.78
*/

/*
The tuna steaks, which have the highest number of quantity sold (25,217) and the most returns (1,357), has
a very low return rate of 5.38%. 
*/