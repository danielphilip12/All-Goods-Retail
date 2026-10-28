-- Category sales performance

select
    pc.product_category_id,
    pc.name as category_name,
    sum(oi.quantity) as total_quantity_sold,
    sum(oi.quantity * oi.price_per_unit) as total_revenue,
    sum((oi.price_per_unit - p.cost) * oi.quantity) as total_profit,
    sum(oi.quantity * oi.price_per_unit)
        / nullif(sum(oi.quantity), 0) as average_selling_price,
    100.0 * sum((oi.price_per_unit - p.cost) * oi.quantity)
        / nullif(sum(oi.quantity * oi.price_per_unit), 0)
        as gross_profit_margin_percent,
    count(distinct oi.order_id) as total_orders
from product_categories pc
join products p
    on pc.product_category_id = p.product_category_id
join order_items oi
    on p.product_id = oi.product_id
group by pc.product_category_id, pc.name
order by total_revenue desc;

/*
CAT_003	Seafood	158409	2455747.18	824487.88	15.5025735911469677	33.5738094993964322	40448
CAT_018	Baby Products	78183	1477365.22	473778.97	18.8962462427893532	32.0691839489764081	22799
CAT_015	Paper Products	102602	1066482.92	331695.49	10.3943677511159627	31.1018098630215287	28656
CAT_002	Meat	86306	926890.07	278289.76	10.7395785924501193	30.0240307893254267	24818
CAT_011	Pasta & Grains	113462	691656.89	231394.35	6.0959342334878638	33.4550777047850994	31335
CAT_006	Frozen Foods	85251	673543.88	218054.00	7.9007152995272783	32.3741342583351808	24637
CAT_013	Coffee & Tea	63577	632876.90	194505.60	9.9544945499158501	30.7335597175374864	19071
CAT_016	Personal Care	74595	607010.29	177014.50	8.1374125611636169	29.1616967481720944	21824
CAT_019	Frozen Desserts	77588	602335.65	201766.78	7.7632578491519307	33.4973996641241474	22748
CAT_008	Snacks	106061	600252.98	204919.68	5.6595070761165744	34.1388859077384339	29630
CAT_009	Breakfast Foods	82782	546705.88	183054.80	6.6041637070860815	33.4832323369194419	23880
CAT_017	Pet Supplies	36329	543646.06	168556.99	14.9645203556387459	31.0049133805917769	11390
CAT_012	Beverages	87887	514592.17	186161.40	5.8551568491358221	36.1764929303141165	25391
CAT_020	Prepared Foods	56295	513270.08	168978.37	9.1175074162891909	32.9219209504672472	17038
CAT_005	Bakery	99117	499439.97	156630.17	5.0388931263052756	31.3611603812966752	27843
CAT_004	Dairy	84691	469457.43	148371.17	5.5431796767070881	31.6048187798412308	24476
CAT_010	Condiments	85281	444307.25	144170.70	5.2099207326368124	32.4484239228596877	24590
CAT_014	Household Cleaning	53057	429606.43	130513.99	8.0970735246998511	30.3798967813400744	16030
CAT_001	Fresh Produce	85606	384585.21	109872.72	4.4925029787631708	28.5691485639814386	24642
CAT_007	Canned Goods	33498	142654.98	42293.65	4.2586118574243238	29.6475103778360910	10537
*/

/*
FINDINGS: CATEGORY SALES PERFORMANCE

Seafood is the strongest overall category by sales performance. It leads all
20 categories in quantity sold (158,409 units), distinct orders (40,448),
total revenue ($2.46 million), and total gross profit ($824,488).

Baby Products ranks second in revenue at approximately $1.48 million, followed
by Paper Products at approximately $1.07 million.

Beverages has the highest gross profit margin at 36.18%, followed by Snacks
at 34.14% and Seafood at 33.57%. This indicates that the category generating
the most profit dollars is not necessarily the category with the highest
profitability relative to revenue.

Canned Goods is the weakest category by total revenue ($142,655) and total
gross profit ($42,294). It may warrant further investigation into product
demand, pricing, and assortment.

Overall, Seafood is the largest revenue and gross-profit contributor, while
Beverages leads in gross profit margin.
*/


-- Average product cost and prices by category

with product_averages as (
    select
        product_category_id,
        avg(cost) as average_unit_cost,
        avg(price) as average_list_price
    from products
    group by product_category_id
), actual_selling_prices as (
    select
        p.product_category_id,
        avg(oi.price_per_unit) as average_actual_price_per_unit
    from products p
    join order_items oi
        on p.product_id = oi.product_id
    group by p.product_category_id
)
select
    pc.product_category_id,
    pc.name as category_name,
    ROUND(pa.average_unit_cost, 2) as avg_unit_cost,
    ROUND(pa.average_list_price, 2) as avg_list_price,
    ROUND(asp.average_actual_price_per_unit, 2) as avg_actual_price_per_unit
from product_categories pc
join product_averages pa
    on pc.product_category_id = pa.product_category_id
left join actual_selling_prices asp
    on pc.product_category_id = asp.product_category_id
order by pc.name;

/*
CAT_018	Baby Products	11.98	17.73	18.87
CAT_005	Bakery	3.49	5.10	5.04
CAT_012	Beverages	3.43	5.11	5.88
CAT_009	Breakfast Foods	4.25	6.13	6.60
CAT_007	Canned Goods	3.02	4.27	4.25
CAT_013	Coffee & Tea	6.47	9.24	9.94
CAT_010	Condiments	3.54	5.25	5.22
CAT_004	Dairy	4.02	5.77	5.55
CAT_001	Fresh Produce	3.23	4.69	4.50
CAT_019	Frozen Desserts	5.01	7.56	7.77
CAT_006	Frozen Foods	5.02	7.23	7.89
CAT_014	Household Cleaning	5.65	8.17	8.09
CAT_002	Meat	7.52	10.87	10.73
CAT_015	Paper Products	7.57	11.03	10.40
CAT_011	Pasta & Grains	3.71	5.49	6.09
CAT_016	Personal Care	6.20	8.95	8.14
CAT_017	Pet Supplies	10.64	15.36	14.96
CAT_020	Prepared Foods	6.50	9.52	9.13
CAT_003	Seafood	10.76	16.16	15.51
CAT_008	Snacks	3.66	5.44	5.66
*/

/*
FINDINGS: AVERAGE PRODUCT COST AND SELLING PRICE

Seafood has an average unit cost of $10.76, an average list price of $16.16,
and an average actual selling price of $15.51. Its actual selling price is
approximately 2.64 times the Beverages category average of $5.88.

Beverages has a lower average unit cost of $3.43 and an average list price
of $5.11, while its average actual selling price is $5.88.

Seafood's higher average selling price and substantial sales volume help
explain why it generates the highest total gross profit ($824,488), even
though its gross profit margin (33.57%) is lower than Beverages (36.18%).

Beverages generates less total gross profit ($186,161), but earns a higher
percentage of revenue as gross profit.

These are category-level averages. Product-level pricing, sales mix, and
promotional activity should be examined before attributing the differences
to pricing strategy or discounts.
*/