-- Active: 1792176784882@@localhost@5432
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
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000667	Lemon Lime Soda - Original	670
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000732	Penne Pasta - 32 oz	523
PROD_000667	Lemon Lime Soda - Original	PROD_000732	Penne Pasta - 32 oz	437
PROD_000371	Frozen Mixed Vegetables - 2 lb	PROD_000401	Tuna Steaks - 16 oz #2	369
PROD_000238	Quinoa - 6 pack #2	PROD_000401	Tuna Steaks - 16 oz #2	367
PROD_000004	Chicken Breast - 12 oz	PROD_000401	Tuna Steaks - 16 oz #2	342
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000871	Iced Tea - 12 pack	335
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000402	Peanut Butter Crackers - 6 pack	333
PROD_000238	Quinoa - 6 pack #2	PROD_000667	Lemon Lime Soda - Original	330
PROD_000083	2% Milk - 12 pack	PROD_000401	Tuna Steaks - 16 oz #2	324
PROD_000371	Frozen Mixed Vegetables - 2 lb	PROD_000667	Lemon Lime Soda - Original	324
PROD_000277	Frozen Mixed Vegetables - 12 oz	PROD_000401	Tuna Steaks - 16 oz #2	317
PROD_000119	Baby Spinach - Original	PROD_000401	Tuna Steaks - 16 oz #2	313
PROD_000667	Lemon Lime Soda - Original	PROD_000871	Iced Tea - 12 pack	307
PROD_000065	Beef Roast - 12 pack	PROD_000401	Tuna Steaks - 16 oz #2	307
PROD_000004	Chicken Breast - 12 oz	PROD_000667	Lemon Lime Soda - Original	295
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000932	Prepared Sandwich - 8 oz #2	293
PROD_000277	Frozen Mixed Vegetables - 12 oz	PROD_000667	Lemon Lime Soda - Original	292
PROD_000401	Tuna Steaks - 16 oz #2	PROD_000637	Baby Food Pouches - Premium	288
PROD_000402	Peanut Butter Crackers - 6 pack	PROD_000667	Lemon Lime Soda - Original	282
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

-- A count-ranked list is shown above. The next table ranks pairs by lift instead.

-- With Lift
/*
product_a_id product_a_name orders_with_product_a product_b_id product_b_name orders_with_product_b orders_with_both support_percent confidence_a_to_b_percent confidence_b_to_a_percent lift
PROD_000043	Ranch Dressing - 8 oz	596	PROD_000732	Penne Pasta - 32 oz	5391	55	0.06	9.23	1.02	1.71
PROD_000195	Granola Bars - Organic	1192	PROD_000442	Lotion - 12 pack	2596	52	0.05	4.36	2.00	1.68
PROD_000004	Chicken Breast - 12 oz	3381	PROD_000527	Deli Turkey - 12 pack	920	52	0.05	1.54	5.65	1.67
PROD_000383	Tuna Steaks - Organic	890	PROD_000402	Peanut Butter Crackers - 6 pack	3455	51	0.05	5.73	1.48	1.66
PROD_000552	Disposable Plates - 1 lb	1763	PROD_000863	Couscous - 32 oz	2092	60	0.06	3.40	2.87	1.63
PROD_000401	Tuna Steaks - 16 oz #2	8426	PROD_000644	Barbecue Sauce - 6 pack	426	58	0.06	0.69	13.62	1.62
PROD_000212	Tilapia Fillets - 12 oz	2592	PROD_000220	Disposable Cups - Family Size	1655	69	0.07	2.66	4.17	1.61
PROD_000097	2% Milk - Reduced Fat	2355	PROD_000392	Disposable Cups - 32 oz	1320	50	0.05	2.12	3.79	1.61
PROD_000673	Vanilla Ice Cream - 12 pack	2401	PROD_000792	Italian Sausage - Organic	1326	51	0.05	2.12	3.85	1.60
PROD_000776	Body Wash - Family Size	1399	PROD_000965	Waffle Mix - 16 oz	2818	63	0.06	4.50	2.24	1.60
PROD_000017	Breaded Fish Fillets - 24 oz	1668	PROD_000309	2% Milk - 24 oz	2305	61	0.06	3.66	2.65	1.59
PROD_000349	Diced Tomatoes - Organic	1113	PROD_000965	Waffle Mix - 16 oz	2818	50	0.05	4.49	1.77	1.59
PROD_000145	Granola Bars - Original	1832	PROD_000587	Pancake Mix - Reduced Fat	1848	53	0.05	2.89	2.87	1.57
PROD_000043	Ranch Dressing - 8 oz	596	PROD_000667	Lemon Lime Soda - Original	7604	71	0.07	11.91	0.93	1.57
PROD_000402	Peanut Butter Crackers - 6 pack	3455	PROD_000792	Italian Sausage - Organic	1326	72	0.07	2.08	5.43	1.57
PROD_000560	Lemonade - Organic	1115	PROD_000637	Baby Food Pouches - Premium	3042	53	0.05	4.75	1.74	1.56
PROD_000219	Tilapia Fillets - 8 oz	2774	PROD_000474	Potato Salad - Organic	1255	54	0.05	1.95	4.30	1.55
PROD_000406	Baby Food Pouches - 32 oz #2	1970	PROD_000587	Pancake Mix - Reduced Fat	1848	56	0.06	2.84	3.03	1.54
PROD_000215	Strawberry Jam - Family Size	1591	PROD_000901	Frozen Fruit Bars - Family Size #2	2122	52	0.05	3.27	2.45	1.54
PROD_000273	Bananas - 1 lb	1184	PROD_000965	Waffle Mix - 16 oz	2818	51	0.05	4.31	1.81	1.53
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
        (pp.orders_with_both * oto.order_count * 1.0)
            / NULLIF(oppa.order_count * oppb.order_count, 0) AS lift
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
    where orders_with_both >= 50
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
        round(lift, 4) as lift
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
        round(lift, 4) as lift
    FROM ranked_by_lift
    WHERE lift_rank <= 10
) AS ranked_pairs
ORDER BY ranking, pair_rank;

/*
top_10_by_co_purchase_count	1	PROD_000401	Tuna Steaks - 16 oz #2	8426	PROD_000667	Lemon Lime Soda - Original	7604	670	0.67	7.95	8.81	1.0457
top_10_by_co_purchase_count	2	PROD_000401	Tuna Steaks - 16 oz #2	8426	PROD_000732	Penne Pasta - 32 oz	5391	523	0.52	6.21	9.70	1.1514
top_10_by_co_purchase_count	3	PROD_000667	Lemon Lime Soda - Original	7604	PROD_000732	Penne Pasta - 32 oz	5391	437	0.44	5.75	8.11	1.0660
top_10_by_co_purchase_count	4	PROD_000371	Frozen Mixed Vegetables - 2 lb	3940	PROD_000401	Tuna Steaks - 16 oz #2	8426	369	0.37	9.37	4.38	1.1115
top_10_by_co_purchase_count	5	PROD_000238	Quinoa - 6 pack #2	4053	PROD_000401	Tuna Steaks - 16 oz #2	8426	367	0.37	9.06	4.36	1.0747
top_10_by_co_purchase_count	6	PROD_000004	Chicken Breast - 12 oz	3381	PROD_000401	Tuna Steaks - 16 oz #2	8426	342	0.34	10.12	4.06	1.2005
top_10_by_co_purchase_count	7	PROD_000401	Tuna Steaks - 16 oz #2	8426	PROD_000871	Iced Tea - 12 pack	3566	335	0.34	3.98	9.39	1.1149
top_10_by_co_purchase_count	8	PROD_000401	Tuna Steaks - 16 oz #2	8426	PROD_000402	Peanut Butter Crackers - 6 pack	3455	333	0.33	3.95	9.64	1.1439
top_10_by_co_purchase_count	9	PROD_000238	Quinoa - 6 pack #2	4053	PROD_000667	Lemon Lime Soda - Original	7604	330	0.33	8.14	4.34	1.0708
top_10_by_co_purchase_count	10	PROD_000083	2% Milk - 12 pack	3352	PROD_000401	Tuna Steaks - 16 oz #2	8426	324	0.32	9.67	3.85	1.1471
top_10_by_lift	1	PROD_000043	Ranch Dressing - 8 oz	596	PROD_000732	Penne Pasta - 32 oz	5391	55	0.06	9.23	1.02	1.7118
top_10_by_lift	2	PROD_000195	Granola Bars - Organic	1192	PROD_000442	Lotion - 12 pack	2596	52	0.05	4.36	2.00	1.6804
top_10_by_lift	3	PROD_000004	Chicken Breast - 12 oz	3381	PROD_000527	Deli Turkey - 12 pack	920	52	0.05	1.54	5.65	1.6717
top_10_by_lift	4	PROD_000383	Tuna Steaks - Organic	890	PROD_000402	Peanut Butter Crackers - 6 pack	3455	51	0.05	5.73	1.48	1.6586
top_10_by_lift	5	PROD_000552	Disposable Plates - 1 lb	1763	PROD_000863	Couscous - 32 oz	2092	60	0.06	3.40	2.87	1.6268
top_10_by_lift	6	PROD_000401	Tuna Steaks - 16 oz #2	8426	PROD_000644	Barbecue Sauce - 6 pack	426	58	0.06	0.69	13.62	1.6158
top_10_by_lift	7	PROD_000212	Tilapia Fillets - 12 oz	2592	PROD_000220	Disposable Cups - Family Size	1655	69	0.07	2.66	4.17	1.6085
top_10_by_lift	8	PROD_000097	2% Milk - Reduced Fat	2355	PROD_000392	Disposable Cups - 32 oz	1320	50	0.05	2.12	3.79	1.6084
top_10_by_lift	9	PROD_000673	Vanilla Ice Cream - 12 pack	2401	PROD_000792	Italian Sausage - Organic	1326	51	0.05	2.12	3.85	1.6019
top_10_by_lift	10	PROD_000776	Body Wash - Family Size	1399	PROD_000965	Waffle Mix - 16 oz	2818	63	0.06	4.50	2.24	1.5980
*/

/*
Business Insights — Product Affinity

1. High co-purchase count does not necessarily indicate a strong association

Tuna Steaks - 16 oz #2 and Lemon Lime Soda - Original had the highest co-purchase count,
appearing together in 670 orders. Their lift was 1.0457, meaning they occurred together
about 4.6% more often than expected based
on their individual order frequencies. Although this is the most frequently purchased pair, 
the relatively low lift suggests that their high co-purchase count may largely 
reflect their individual popularity rather than a particularly strong association.

Business implication: The business should not assume that bundling these products 
would substantially increase sales simply because 
they frequently appear in the same orders. 
A controlled promotion or further profitability analysis could help 
determine whether a bundle would be worthwhile.

2. A high lift does not necessarily indicate a commercially valuable opportunity

Frozen Fruit Bars - Organic and Paper Towels had the highest lift, at 1.3888.
These products appeared together in 52 orders, meaning they were purchased together about
38.88% more often than expected under an independence assumption.
However, this combination appeared in relatively few orders overall, 
so its potential reach may be limited.

Business implication: This pair could be investigated as a potential targeted 
cross-selling opportunity, but the limited co-purchase volume does not yet 
justify investing in a promotion or bundle. 
Further analysis and testing would be needed to determine whether 
the association could translate into meaningful sales or profit.

Limitations: These metrics describe observed purchasing patterns; 
they do not establish causation or prove that a bundle would increase sales. 
The dataset is synthetic, so the observed associations may not reflect real-world customer behavior.
*/

select *
from promotions
limit 5;

SELECT 
    column_name, 
    data_type,
    character_maximum_length AS max_length
FROM 
    information_schema.columns
WHERE 
    table_name = 'promotions'
    AND table_schema = 'public';

select * from customers
limit 15;