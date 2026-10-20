select *
from order_items
limit 5;

select * 
from orders
limit 5;

select * 
from products
limit 5;

-- =====================
-- Section 1
-- =====================

-- 1. Find the 20 most frequently co-purchased product pairs
with order_products as (
    select distinct order_id, product_id
    from order_items
)
select 
    pa.product_id, 
    pa.name,
    pb.product_id, 
    pb.name,
    count(*) as total_orders
from order_products as opa
join order_products as opb
on opa.order_id = opb.order_id AND opa.product_id != opb.product_id AND opa.product_id < opb.product_id
join products pa
on pa.product_id = opa.product_id
join products pb
on pb.product_id = opb.product_id
group by pa.product_id, pb.product_id, pa.name, pb.name
order by total_orders desc
limit 20;

/*
product_id name product_id name total_orders
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000667	Lemon Lime Soda - Original	678
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000732	Penne Pasta - 32 oz	500
PROD_000667	Lemon Lime Soda - Original	PROD_000732	Penne Pasta - 32 oz	444
PROD_000238	Quinoa - 6 pack #2	PROD_000401	Tuna Steaks - 16 oz #2	379
PROD_000371	Frozen Mixed Vegetables - 2 lb	PROD_000401	Tuna Steaks - 16 oz #2	361
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000402	Peanut Butter Crackers - 6 pack	336
PROD_000371	Frozen Mixed Vegetables - 2 lb	PROD_000667	Lemon Lime Soda - Original	334
PROD_000277	Frozen Mixed Vegetables - 12 oz	PROD_000401	Tuna Steaks - 16 oz #2	319
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000871	Iced Tea - 12 pack	319
PROD_000083	2% Milk - 12 pack	PROD_000401	Tuna Steaks - 16 oz #2	319
PROD_000667	Lemon Lime Soda - Original	PROD_000871	Iced Tea - 12 pack	314
PROD_000119	Baby Spinach - Original	PROD_000401	Tuna Steaks - 16 oz #2	313
PROD_000004	Chicken Breast - 12 oz	PROD_000401	Tuna Steaks - 16 oz #2	311
PROD_000065	Beef Roast - 12 pack	PROD_000401	Tuna Steaks - 16 oz #2	304
PROD_000004	Chicken Breast - 12 oz	PROD_000667	Lemon Lime Soda - Original	303
PROD_000238	Quinoa - 6 pack #2	PROD_000667	Lemon Lime Soda - Original	299
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000637	Baby Food Pouches - Premium	299
PROD_000402	Peanut Butter Crackers - 6 pack	PROD_000667	Lemon Lime Soda - Original	284
PROD_000277	Frozen Mixed Vegetables - 12 oz	PROD_000667	Lemon Lime Soda - Original	283
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000932	Prepared Sandwich - 8 oz #2	283
*/

-- 2. Product Pair Strengths

WITH order_products AS (
    SELECT DISTINCT order_id, product_id
    FROM order_items
),
overall_total_orders AS (
    SELECT COUNT(*) AS order_count
    FROM orders
),
orders_per_product AS (
    SELECT
        product_id,
        COUNT(*) AS order_count
    FROM order_products
    GROUP BY product_id
),
product_pairs AS (
    SELECT
        opa.product_id AS product_a_id,
        opb.product_id AS product_b_id,
        COUNT(*) AS total_orders
    FROM order_products AS opa
    JOIN order_products AS opb
        ON opa.order_id = opb.order_id
        AND opa.product_id < opb.product_id
    GROUP BY opa.product_id, opb.product_id
)
SELECT
    pp.product_a_id,
    pa.name AS product_a_name,
    oppa.order_count AS orders_with_product_a,
    pp.product_b_id,
    pb.name AS product_b_name,
    oppb.order_count AS orders_with_product_b,
    pp.total_orders AS orders_with_both,
    round(pp.total_orders * 100.0
        / NULLIF(oto.order_count, 0), 2) AS support_percent,
    round(pp.total_orders * 100.0
        / NULLIF(oppa.order_count, 0), 2) AS confidence_a_to_b_percent,
    round(pp.total_orders * 100.0
        / NULLIF(oppb.order_count, 0), 2) AS confidence_b_to_a_percent
FROM product_pairs AS pp
JOIN products AS pa
    ON pa.product_id = pp.product_a_id
JOIN products AS pb
    ON pb.product_id = pp.product_b_id
JOIN orders_per_product AS oppa
    ON oppa.product_id = pp.product_a_id
JOIN orders_per_product AS oppb
    ON oppb.product_id = pp.product_b_id
CROSS JOIN overall_total_orders AS oto
ORDER BY pp.total_orders DESC
LIMIT 20;

/*
product_a_id product_a_name orders_with_product_a product_b_id product_b_name orders_with_product_b orders_with_both support_percent confidence_a_to_b_percent confidence_b_to_a_percent
PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000667	Lemon Lime Soda - Original	7636	678	0.68	8.03	8.88
PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000732	Penne Pasta - 32 oz	5383	500	0.50	5.92	9.29
PROD_000667	Lemon Lime Soda - Original	7636	PROD_000732	Penne Pasta - 32 oz	5383	444	0.44	5.81	8.25
PROD_000238	Quinoa - 6 pack #2	4053	PROD_000401	Tuna Steaks - 16 oz #2	8441	379	0.38	9.35	4.49
PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	PROD_000401	Tuna Steaks - 16 oz #2	8441	361	0.36	9.14	4.28
PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000402	Peanut Butter Crackers - 6 pack	3472	336	0.34	3.98	9.68
PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	PROD_000667	Lemon Lime Soda - Original	7636	334	0.33	8.46	4.37
PROD_000277	Frozen Mixed Vegetables - 12 oz	3393	PROD_000401	Tuna Steaks - 16 oz #2	8441	319	0.32	9.40	3.78
PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000871	Iced Tea - 12 pack	3587	319	0.32	3.78	8.89
PROD_000083	2% Milk - 12 pack	3357	PROD_000401	Tuna Steaks - 16 oz #2	8441	319	0.32	9.50	3.78
PROD_000667	Lemon Lime Soda - Original	7636	PROD_000871	Iced Tea - 12 pack	3587	314	0.31	4.11	8.75
PROD_000119	Baby Spinach - Original	3238	PROD_000401	Tuna Steaks - 16 oz #2	8441	313	0.31	9.67	3.71
PROD_000004	Chicken Breast - 12 oz	3400	PROD_000401	Tuna Steaks - 16 oz #2	8441	311	0.31	9.15	3.68
PROD_000065	Beef Roast - 12 pack	2959	PROD_000401	Tuna Steaks - 16 oz #2	8441	304	0.30	10.27	3.60
PROD_000004	Chicken Breast - 12 oz	3400	PROD_000667	Lemon Lime Soda - Original	7636	303	0.30	8.91	3.97
PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000637	Baby Food Pouches - Premium	3049	299	0.30	3.54	9.81
PROD_000238	Quinoa - 6 pack #2	4053	PROD_000667	Lemon Lime Soda - Original	7636	299	0.30	7.38	3.92
PROD_000402	Peanut Butter Crackers - 6 pack	3472	PROD_000667	Lemon Lime Soda - Original	7636	284	0.28	8.18	3.72
PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000932	Prepared Sandwich - 8 oz #2	3083	283	0.28	3.35	9.18
PROD_000277	Frozen Mixed Vegetables - 12 oz	3393	PROD_000667	Lemon Lime Soda - Original	7636	283	0.28	8.34	3.71
*/