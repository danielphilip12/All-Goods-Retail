-- Active: 1792176784882@@localhost@5432@allgoods_db

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

-- 42,236

-- 2. How much money has been refunded
select sum(refund_amount) as total_refunded
from returns;

-- $759,940.74

-- 3. What percentage of orders have at least one return?
select 
    round((count(distinct order_id) * 100.0 / (select count(distinct order_id) from orders)), 2) as return_percentage
from returns;

-- 33.83%

-- 4. How many units have been returned?
select sum(quantity_returned) as total_units_returned
from returns;

-- 84,504

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

-- Top 5 products by returned units
/*
Tuna Steaks - 16 oz #2	1296
Penne Pasta - 32 oz	887
Lemon Lime Soda - Original	711
Quinoa - 6 pack #2	640
Baby Food Pouches - Premium	639
*/

-- Tuna Steaks - 16 oz #2 has the most returned units at 1,296. Its return rate is
-- 5.15%; assess its $21,340.22 in refunds against its sales and profit before
-- deciding whether the return volume warrants intervention.

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
Tuna Steaks - 16 oz #2	21340.22
Baby Food Pouches - Premium	15780.86
Penne Pasta - 32 oz	8725.83
Baby Lotion - 2 lb	8566.40
Atlantic Salmon - 2 lb	8328.24
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
PROD_000042	Shampoo - 12 oz	139	19	13.67
PROD_000214	Paper Napkins - Premium #2	350	43	12.29
PROD_000677	Chocolate Ice Cream - Original	152	18	11.84
PROD_000592	Disposable Cups - 1 lb #2	258	29	11.24
PROD_000706	Facial Tissues - Premium #2	211	23	10.90
*/

/*
The tuna steaks, which have the highest number of quantity sold (25,181) and the most returns (1,296), has
a very low return rate of 5.15%. 
*/


-- ====================
-- Section 3: Category Return Analysis
-- ====================

-- 1. Which categories have the most returned units?
select 
    c.product_category_id,
    c.name as category_name,
    sum(r.quantity_returned) as total_quantity_returned
from returns r
join order_items oi
    on r.order_item_id = oi.order_item_id
join products p
    on oi.product_id = p.product_id
join product_categories c
    on p.product_category_id = c.product_category_id
group by c.product_category_id, c.name
order by total_quantity_returned desc, c.product_category_id;

/*
Seafood has the most returned units at 8334. Top 5 categories by returned units are listed below.

product_category_id	category_name	total_quantity_returned
CAT_003	Seafood	8334
CAT_015	Paper Products	6993
CAT_011	Pasta & Grains	6089
CAT_008	Snacks	5795
CAT_018	Baby Products	5204
*/


-- 2. Which categories have the highest refund amounts?
select
    c.product_category_id,
    c.name as category_name,
    sum(r.refund_amount) as total_amount_returned
from returns r
join order_items oi
    on r.order_item_id = oi.order_item_id
join products p
    on oi.product_id = p.product_id
join product_categories c
    on p.product_category_id = c.product_category_id
group by c.product_category_id, c.name
order by total_amount_returned desc, c.product_category_id;

/*
Seafood has the highest return amount, with a total return value of $128,362.58

Top 5 categories by return amount are listed below.
product_category_id	category_name	total_amount_returned
CAT_003	Seafood	128362.58
CAT_018	Baby Products	98389.12
CAT_015	Paper Products	71839.77
CAT_002	Meat	51528.33
CAT_016	Personal Care	41218.36
*/

-- 3. Which categories have the highest return rates?
with category_sales as (
    select
        c.product_category_id,
        c.name as category_name,
        sum(oi.quantity) as total_quantity_sold
    from order_items oi
    join products p
        on oi.product_id = p.product_id
    join product_categories c
        on p.product_category_id = c.product_category_id
    group by c.product_category_id, c.name
),
category_returns as (
    select
        c.product_category_id,
        sum(r.quantity_returned) as total_quantity_returned
    from returns r
    join order_items oi
        on r.order_item_id = oi.order_item_id
    join products p
        on oi.product_id = p.product_id
    join product_categories c
        on p.product_category_id = c.product_category_id
    group by c.product_category_id
)
select
    cs.product_category_id,
    cs.category_name,
    cs.total_quantity_sold,
    coalesce(cr.total_quantity_returned, 0) as total_quantity_returned,
    round(
        coalesce(cr.total_quantity_returned, 0) * 100.0
        / nullif(cs.total_quantity_sold, 0),
        2
    ) as return_rate_percentage
from category_sales cs
left join category_returns cr
    on cs.product_category_id = cr.product_category_id
order by return_rate_percentage desc, total_quantity_returned desc,
    cs.product_category_id;

/*
Pet Supplies has the highest category unit return rate at 6.99%.

Top 5 categories by return rate are listed below.
product_category_id	category_name	total_quantity_sold	total_quantity_returned	return_rate_percentage
CAT_017	Pet Supplies	36329	2539	6.99
CAT_015	Paper Products	102602	6993	6.82
CAT_016	Personal Care	74595	5038	6.75
CAT_018	Baby Products	78183	5204	6.66
CAT_014	Household Cleaning	53057	3445	6.49
*/

-- 4. Paper Products and Baby Products return rates by product.
with product_sales as (
    select
        p.product_id,
        p.name as product_name,
        c.product_category_id,
        c.name as category_name,
        sum(oi.quantity) as total_quantity_sold
    from order_items oi
    join products p
        on oi.product_id = p.product_id
    join product_categories c
        on p.product_category_id = c.product_category_id
    where c.name in ('Paper Products', 'Baby Products')
    group by p.product_id, p.name, c.product_category_id, c.name
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
    ps.product_category_id,
    ps.category_name,
    rank() over (
        partition by ps.product_category_id
        order by coalesce(pr.total_quantity_returned, 0) * 100.0
            / nullif(ps.total_quantity_sold, 0) desc
    ) as return_rate_rank,
    ps.product_id,
    ps.product_name,
    ps.total_quantity_sold,
    coalesce(pr.total_quantity_returned, 0) as total_quantity_returned,
    round(
        coalesce(pr.total_quantity_returned, 0) * 100.0
        / nullif(ps.total_quantity_sold, 0),
        2
    ) as return_rate_percentage
from product_sales ps
left join product_returns pr
    on ps.product_id = pr.product_id
order by ps.category_name, return_rate_rank, ps.product_id;

/*
Top 5 products by return rate within Paper Products and Baby Products categories.
product_category_id	category_name	return_rate_rank	product_id	product_name	total_quantity_sold	total_quantity_returned	return_rate_percentage
CAT_018	Baby Products	1	PROD_000489	Baby Lotion - 1 lb	508	49	9.65
CAT_018	Baby Products	2	PROD_000204	Baby Wipes - 8 oz #2	131	12	9.16
CAT_018	Baby Products	3	PROD_000612	Baby Shampoo - 12 pack	1852	166	8.96
CAT_018	Baby Products	4	PROD_000062	Baby Shampoo - 16 oz	380	34	8.95
CAT_018	Baby Products	5	PROD_000034	Baby Diapers - Organic	883	76	8.61

CAT_015	Paper Products	1	PROD_000214	Paper Napkins - Premium #2	350	43	12.29
CAT_015	Paper Products	2	PROD_000592	Disposable Cups - 1 lb #2	258	29	11.24
CAT_015	Paper Products	3	PROD_000706	Facial Tissues - Premium #2	211	23	10.90
CAT_015	Paper Products	4	PROD_000991	Facial Tissues - 24 oz	540	53	9.81
CAT_015	Paper Products	5	PROD_000920	Paper Towels - 24 oz #2	350	32	9.14

Baby Lotion - 1 lb has the highest return rate among the listed Baby Products at 9.65%.
Paper Napkins - Premium #2 has the highest return rate among the listed Paper Products at 12.29%.
*/


-- =======================
-- Section 4: Business Insights
-- =======================

-- 1. Seafood
/*
Seafood has the highest number of returned units (8,334) and the
highest total refund amount ($128,362.58). Its unit return rate is
5.26%, below the rates for 11 other categories, so its high absolute
return totals do not correspond to the highest category return rate.

Business implication:
We should evaluate Seafood's returns alongside its gross profit and
sales performance before deciding whether intervention is necessary.

Limitation:
The current analysis does not establish whether Seafood's return
level is financially acceptable. That would require a clearer
assessment of the profit impact and appropriate business targets.
*/

-- 2. Paper Products
/*
Paper Products has the second-highest category-level unit return rate
at 6.82%. The five products with the highest return rates in this
category are Paper Napkins - Premium #2, Disposable Cups - 1 lb #2,
Facial Tissues - Premium #2, Facial Tissues - 24 oz, and Paper Towels -
24 oz #2.

The top three products sold fewer than 500 units. Paper Napkins -
Premium #2 had 350 units sold and 43 units returned, resulting in a
12.29% return rate. Interpret product-level rates in light of sales
volume.

Business implication:
Investigate whether the elevated return rates are concentrated in
specific products, and examine product details and promotion history
for possible contributing factors. Adding a return-reason field to
the database could help distinguish issues such as defects from
other reasons for returns.

Limitation:
The current dataset does not contain return reasons, so we cannot
determine why these products were returned. We also have not
established that promotions contribute to higher return rates.
*/

-- 3. Baby Products
/*
Baby Products has the fourth-highest category-level unit return rate
at 6.66%. The five products with the highest return rates in this
category are Baby Lotion - 1 lb, Baby Wipes - 8 oz #2,
Baby Shampoo - 12 pack, Baby Shampoo - 16 oz, and Baby Diapers -
Organic.

Baby Lotion - 1 lb had 508 units sold and 49 units returned,
resulting in a 9.65% return rate.

Business implication:
Investigate whether elevated return rates are concentrated in
specific products, and examine product details and promotion history
for possible contributing factors. Adding a return-reason field to
the database could help distinguish issues such as defects from
other reasons for returns.

Limitation:
The current dataset does not contain return reasons, so we cannot
determine why these products were returned. We also have not
established that promotions contribute to higher return rates.
*/