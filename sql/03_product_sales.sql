-- 1. Top 10 products by quantity sold
select p.product_id, p.name, sum(oi.quantity) as total_quantity_sold
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_id, p.name
order by total_quantity_sold desc
limit 10;

-- 2. Top 10 products by revenue
select p.product_id, p.name, sum(oi.quantity * oi.price_per_unit) as total_revenue
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_id, p.NAME
order by total_revenue DESC
limit 10;

-- The best performing product was Tuna Steaks - 16 oz #2. It ranks top in terms of both quantity sold and revenue. 
-- Overall, 25,217 units of this product were sold, and they generated $415,075.91 in revenue. This is over the course of 4 years. 

-- 3. Bottom 10 products by quantity sold
select p.product_id, p.name, sum(oi.quantity) as total_quantity_sold
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_id, p.name
order by total_quantity_sold asc
limit 10;

-- 4. Bottom 10 products by revenue
select p.product_id, p.name, sum(oi.quantity * oi.price_per_unit) as total_revenue
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_id, p.NAME
order by total_revenue asc
limit 10;

-- Conversely, the worst performing product was Glass Cleaner - 16 oz. Only 25 units have been sold, generating $88.75 in revenue over the 4 years.

-- 5. Top 10 products by profit

select 
    p.product_id,
    p.name,
    sum((oi.price_per_unit - p.cost) * oi.quantity) as total_profit
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_id, p.name
order by total_profit desc
limit 10;

-- Tuna Steaks - 16 oz #2 also has the highest profit at $104,654.64
