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

-- Seafood appears to be the strongest overall category based on its leading performance in sales volume, 
-- order count, revenue, and gross profit, while also ranking within the top three categories 
-- for average selling price and gross profit margin.

-- Beverages has the highest gross profit margin, while Seafood has the highest gross profit. 


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
    pa.average_unit_cost,
    pa.average_list_price,
    asp.average_actual_price_per_unit
from product_categories pc
join product_averages pa
    on pc.product_category_id = pa.product_category_id
left join actual_selling_prices asp
    on pc.product_category_id = asp.product_category_id
order by pc.name;

-- The average cost of beverages is around $3.43, and the average price is $5.85
-- For seafood, the average unit cost is $10.76, and the average price is $15.48. 
-- The average profit margin for Seafood products is 30.49%
-- The average profit margin for Beverages is 41.47%
-- Seafood may have a lower profit margin, but it makes up for it by having more orders (nearly 15,000 more) 
-- and a higher average selling price (nearly triple that of beverages)