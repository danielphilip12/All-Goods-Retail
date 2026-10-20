-- Active: 1791309856637@@localhost@5432@allgoods_db

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
Seafood has the most returned units at 8407. Top 5 categories by returned units are listed below.

product_category_id	category_name	total_quantity_returned
CAT_003	Seafood	8407
CAT_015	Paper Products	7178
CAT_011	Pasta & Grains	6121
CAT_008	Snacks	5751
CAT_005	Bakery	5362
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
Seafood has the highest return amount, with a total return value of $130,093.30.

Top 5 categories by return amount are listed below.
product_category_id	category_name	total_amount_returned
CAT_003	Seafood	130093.30
CAT_018	Baby Products	101978.20
CAT_015	Paper Products	74439.52
CAT_002	Meat	50326.66
CAT_016	Personal Care	41084.42
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
The category with the highest return rate is Paper Products, with a return rate of 6.96%

Top 5 categories by return rate are listed below.
product_category_id	category_name	total_quantity_sold	total_quantity_returned	return_rate_percentage
CAT_015	Paper Products	103068	7178	6.96
CAT_018	Baby Products	78046	5355	6.86
CAT_017	Pet Supplies	36112	2465	6.83
CAT_016	Personal Care	74411	5069	6.81
CAT_014	Household Cleaning	53053	3556	6.70
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
CAT_018	Baby Products	1	PROD_000190	Baby Diapers - 12 pack	210	33	15.71
CAT_018	Baby Products	2	PROD_000224	Baby Wipes - Organic	884	99	11.20
CAT_018	Baby Products	3	PROD_000156	Baby Food Pouches - Reduced Fat	889	88	9.90
CAT_018	Baby Products	4	PROD_000096	Baby Food Pouches - 2 lb	624	60	9.62
CAT_018	Baby Products	5	PROD_000006	Baby Wipes - Reduced Fat	408	39	9.56

CAT_015	Paper Products	1	PROD_000879	Trash Bags - 16 oz	61	9	14.75
CAT_015	Paper Products	2	PROD_000483	Toilet Paper - 6 pack #2	410	48	11.71
CAT_015	Paper Products	3	PROD_000013	Disposable Plates - 12 oz	351	35	9.97
CAT_015	Paper Products	4	PROD_000317	Paper Towels - Organic	955	90	9.42
CAT_015	Paper Products	5	PROD_000398	Trash Bags - Family Size	135	12	8.89

In baby products, baby diapers has the highest return rate among the top 5 products, with a return rate of 15.71%.
In paper products, trash bags - 16 oz has the highest return rate among the top 5 products, with a return rate of 14.75%.
*/


-- =======================
-- Section 4: Business Insights
-- =======================

-- 1. Seafood
/*
The Seafood category has the highest number of returned units and the
highest total refund amount. However, Seafood also has the highest
sales volume and revenue, which may help explain its high absolute
return totals.

Despite its high return volume, Seafood's unit return rate is
approximately 5%, lower than that of several other categories.
This suggests that its high return totals may be partly attributable
to the scale of its sales rather than an unusually high return rate.

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
Paper Products has the highest category-level unit return rate at
6.96%. The five products with the highest return rates in this
category are Trash Bags - 16 oz, Toilet Paper - 6 pack #2,
Disposable Plates - 12 oz, Paper Towels - Organic, and Trash Bags -
Family Size.

Several of these products sold fewer than 500 units in the dataset.
Trash Bags - 16 oz had 61 units sold and 9 units returned, resulting
in a 14.75% return rate. Because of its low sales volume, this rate
should be interpreted cautiously.

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
Baby Products has the second-highest category-level unit return rate
at 6.86%. The five products with the highest return rates in this
category are Baby Diapers - 12 pack, Baby Wipes - Organic,
Baby Food Pouches - Reduced Fat, Baby Food Pouches - 2 lb,
and Baby Wipes - Reduced Fat.

Baby Diapers - 12 pack had 210 units sold and 33 units returned,
resulting in a 15.71% return rate. Because of its relatively low
sales volume, this rate should be interpreted cautiously.

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