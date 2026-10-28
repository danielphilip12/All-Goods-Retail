select TABLE_NAME
from information_schema.tables
where table_schema = 'public';

-- 1. Total Revenue
select sum(total_price) as revenue
from orders;

-- $14,222,427.44

-- 2. total number of orders
select count(*) as total_orders
from orders;

-- 100,000

-- 3. Average order value
SELECT ROUND(AVG(total_price), 2) AS average_order_value
FROM orders;

-- 142.22

-- 4. Total Quantity of products sold
select sum(oi.quantity) as total_quantity
from order_items oi;
-- 1,650,577

-- select p.name, sum(oi.quantity) as total_quantity
-- from products p
-- join order_items oi on p.product_id = oi.product_id
-- group by p.name;

-- 5. Number of unique customers who placed orders
select count(distinct customer_id) as unique_customers
from orders;

-- 9999

-- 6. Number of active members
select count(*) as total_members
from customers
where is_member = true and membership_cancel_date is NULL;

-- 5126

-- 7. Number of non-active members
select count(*) as total_non_members
from customers
where is_member = false or membership_cancel_date is not NULL;

-- 4874

-- 8. Total Returns
select count(*) as total_returns
from returns;

-- 42,236

select sum(quantity_returned) as total_quantity_returned
from returns;

-- $84,504

-- 9. Total refunded amount
select sum(refund_amount) as total_refunded_amount
from returns;

-- $759,940.74

-- 10. Percentage of orders with at least one return
SELECT
    COUNT(DISTINCT r.order_id) * 100.0
        / COUNT(DISTINCT o.order_id) AS return_rate
FROM orders o
LEFT JOIN returns r
    ON o.order_id = r.order_id;

-- 33.83%