-- Active: 1792176784882@@localhost@5432@allgoods_db
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
        / NULLIF(oppb.order_count, 0), 2) AS confidence_b_to_a_percent,
    round((pp.total_orders * oto.order_count * 1.0) / (oppa.order_count * oppb.order_count), 2) as lift
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
where pp.total_orders >= 50
ORDER BY lift DESC
LIMIT 20;

-- before lift
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

-- With Lift
/*
product_a_id product_a_name orders_with_product_a product_b_id product_b_name orders_with_product_b orders_with_both support_percent confidence_a_to_b_percent confidence_b_to_a_percent lift
PROD_000605	Atlantic Salmon - 2 lb	2257	PROD_000916	Ground Turkey - 1 lb #2	1361	52	0.05	2.30	3.82	1.69
PROD_000185	Shrimp - 6 pack	1145	PROD_000637	Baby Food Pouches - Premium	3049	58	0.06	5.07	1.90	1.66
PROD_000226	Frozen Burritos - Family Size	1409	PROD_000309	2% Milk - 24 oz	2320	54	0.05	3.83	2.33	1.65
PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	PROD_000419	Paper Towels - 2 lb	806	52	0.05	1.32	6.45	1.63
PROD_000277	Frozen Mixed Vegetables - 12 oz	3393	PROD_000754	Sourdough Bread - 1 lb	1032	57	0.06	1.68	5.52	1.63
PROD_000148	Whole Wheat Pasta - 12 oz	963	PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	62	0.06	6.44	1.57	1.63
PROD_000057	Deodorant - 24 oz	1428	PROD_000219	Tilapia Fillets - 8 oz	2783	64	0.06	4.48	2.30	1.61
PROD_000083	2% Milk - 12 pack	3357	PROD_000349	Diced Tomatoes - Organic	1109	60	0.06	1.79	5.41	1.61
PROD_000339	Floor Cleaner - 24 oz	395	PROD_000401	Tuna Steaks - 16 oz #2	8441	53	0.05	13.42	0.63	1.59
PROD_000024	Quinoa - 32 oz	2094	PROD_000220	Disposable Cups - Family Size	1655	55	0.06	2.63	3.32	1.59
PROD_000460	Dishwasher Pods - Reduced Fat	562	PROD_000667	Lemon Lime Soda - Original	7636	68	0.07	12.10	0.89	1.58
PROD_000287	Yellow Onions - Organic	2611	PROD_000741	Granola - 12 oz #2	1481	61	0.06	2.34	4.12	1.58
PROD_000128	Frozen Fruit Bars - Organic	1646	PROD_000646	Paper Towels - Original	2285	59	0.06	3.58	2.58	1.57
PROD_000667	Lemon Lime Soda - Original	7636	PROD_000975	Peanut Butter - 16 oz #2	602	72	0.07	0.94	11.96	1.57
PROD_000024	Quinoa - 32 oz	2094	PROD_000814	Peanut Butter Crackers - Organic	1793	59	0.06	2.82	3.29	1.57
PROD_000101	Chicken Thighs - 24 oz	816	PROD_000238	Quinoa - 6 pack #2	4053	52	0.05	6.37	1.28	1.57
PROD_000402	Peanut Butter Crackers - 6 pack	3472	PROD_000621	Potato Chips - 2 lb	1241	67	0.07	1.93	5.40	1.55
PROD_000197	Bleach - 1 lb	1942	PROD_000814	Peanut Butter Crackers - Organic	1793	54	0.05	2.78	3.01	1.55
PROD_000197	Bleach - 1 lb	1942	PROD_000901	Frozen Fruit Bars - Family Size #2	2125	64	0.06	3.30	3.01	1.55
PROD_000309	2% Milk - 24 oz	2320	PROD_000662	Baby Lotion - 2 lb	1525	54	0.05	2.33	3.54	1.53
*/

-- Section 3: Top co-purchased pairs and top pairs by lift
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
        COUNT(*) AS orders_with_both
    FROM order_products AS opa
    JOIN order_products AS opb
        ON opa.order_id = opb.order_id
        AND opa.product_id < opb.product_id
    GROUP BY opa.product_id, opb.product_id
),
pair_metrics AS (
    SELECT
        pp.product_a_id,
        pa.name AS product_a_name,
        oppa.order_count AS orders_with_product_a,
        pp.product_b_id,
        pb.name AS product_b_name,
        oppb.order_count AS orders_with_product_b,
        pp.orders_with_both,
        ROUND(pp.orders_with_both * 100.0
            / NULLIF(oto.order_count, 0), 2) AS support_percent,
        ROUND(pp.orders_with_both * 100.0
            / NULLIF(oppa.order_count, 0), 2) AS confidence_a_to_b_percent,
        ROUND(pp.orders_with_both * 100.0
            / NULLIF(oppb.order_count, 0), 2) AS confidence_b_to_a_percent,
        ROUND((pp.orders_with_both * oto.order_count * 1.0)
            / NULLIF(oppa.order_count * oppb.order_count, 0), 4) AS lift
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
),
ranked_by_count AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY orders_with_both DESC, product_a_id, product_b_id
        ) AS count_rank,
        *
    FROM pair_metrics
),
ranked_by_lift AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY lift DESC, orders_with_both DESC, product_a_id, product_b_id
        ) AS lift_rank,
        *
    FROM pair_metrics
    WHERE orders_with_both >= 50
)
SELECT *
FROM (
    SELECT
        'top_10_by_co_purchase_count' AS ranking,
        count_rank as pair_rank,
        product_a_id,
        product_a_name,
        orders_with_product_a,
        product_b_id,
        product_b_name,
        orders_with_product_b,
        orders_with_both,
        support_percent,
        confidence_a_to_b_percent,
        confidence_b_to_a_percent,
        lift
    FROM ranked_by_count
    WHERE count_rank <= 10

    UNION ALL

    SELECT
        'top_10_by_lift' AS ranking,
        lift_rank as pair_rank,
        product_a_id,
        product_a_name,
        orders_with_product_a,
        product_b_id,
        product_b_name,
        orders_with_product_b,
        orders_with_both,
        support_percent,
        confidence_a_to_b_percent,
        confidence_b_to_a_percent,
        lift
    FROM ranked_by_lift
    WHERE lift_rank <= 10
) AS ranked_pairs
ORDER BY ranking, pair_rank;

/*
top_10_by_co_purchase_count	1	PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000667	Lemon Lime Soda - Original	7636	678	0.68	8.03	8.88	1.05
top_10_by_co_purchase_count	2	PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000732	Penne Pasta - 32 oz	5383	500	0.50	5.92	9.29	1.10
top_10_by_co_purchase_count	3	PROD_000667	Lemon Lime Soda - Original	7636	PROD_000732	Penne Pasta - 32 oz	5383	444	0.44	5.81	8.25	1.08
top_10_by_co_purchase_count	4	PROD_000238	Quinoa - 6 pack #2	4053	PROD_000401	Tuna Steaks - 16 oz #2	8441	379	0.38	9.35	4.49	1.11
top_10_by_co_purchase_count	5	PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	PROD_000401	Tuna Steaks - 16 oz #2	8441	361	0.36	9.14	4.28	1.08
top_10_by_co_purchase_count	6	PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000402	Peanut Butter Crackers - 6 pack	3472	336	0.34	3.98	9.68	1.15
top_10_by_co_purchase_count	7	PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	PROD_000667	Lemon Lime Soda - Original	7636	334	0.33	8.46	4.37	1.11
top_10_by_co_purchase_count	8	PROD_000083	2% Milk - 12 pack	3357	PROD_000401	Tuna Steaks - 16 oz #2	8441	319	0.32	9.50	3.78	1.13
top_10_by_co_purchase_count	9	PROD_000277	Frozen Mixed Vegetables - 12 oz	3393	PROD_000401	Tuna Steaks - 16 oz #2	8441	319	0.32	9.40	3.78	1.11
top_10_by_co_purchase_count	10	PROD_000401	Tuna Steaks - 16 oz #2	8441	PROD_000871	Iced Tea - 12 pack	3587	319	0.32	3.78	8.89	1.05
top_10_by_lift	1	PROD_000605	Atlantic Salmon - 2 lb	2257	PROD_000916	Ground Turkey - 1 lb #2	1361	52	0.05	2.30	3.82	1.69
top_10_by_lift	2	PROD_000185	Shrimp - 6 pack	1145	PROD_000637	Baby Food Pouches - Premium	3049	58	0.06	5.07	1.90	1.66
top_10_by_lift	3	PROD_000226	Frozen Burritos - Family Size	1409	PROD_000309	2% Milk - 24 oz	2320	54	0.05	3.83	2.33	1.65
top_10_by_lift	4	PROD_000148	Whole Wheat Pasta - 12 oz	963	PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	62	0.06	6.44	1.57	1.63
top_10_by_lift	5	PROD_000277	Frozen Mixed Vegetables - 12 oz	3393	PROD_000754	Sourdough Bread - 1 lb	1032	57	0.06	1.68	5.52	1.63
top_10_by_lift	6	PROD_000371	Frozen Mixed Vegetables - 2 lb	3949	PROD_000419	Paper Towels - 2 lb	806	52	0.05	1.32	6.45	1.63
top_10_by_lift	7	PROD_000057	Deodorant - 24 oz	1428	PROD_000219	Tilapia Fillets - 8 oz	2783	64	0.06	4.48	2.30	1.61
top_10_by_lift	8	PROD_000083	2% Milk - 12 pack	3357	PROD_000349	Diced Tomatoes - Organic	1109	60	0.06	1.79	5.41	1.61
top_10_by_lift	9	PROD_000024	Quinoa - 32 oz	2094	PROD_000220	Disposable Cups - Family Size	1655	55	0.06	2.63	3.32	1.59
top_10_by_lift	10	PROD_000339	Floor Cleaner - 24 oz	395	PROD_000401	Tuna Steaks - 16 oz #2	8441	53	0.05	13.42	0.63	1.59
*/