select * from orders
limit 10;

select 
    extract(year from order_date) as order_year,
    sum(total_price) as total_revenue
from orders
group by 1
order by 1;

select 
    extract(year from order_date) as order_year,
    extract(month from order_date) as order_month,
    sum(total_price) as total_revenue
from orders
group by 1, 2
order by 1;

SELECT
    EXTRACT(YEAR FROM o.order_date) AS order_year,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE o.is_member) AS member_orders,
    COUNT(*) FILTER (WHERE NOT o.is_member) AS non_member_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE o.is_member) / COUNT(*),
        2
    ) AS member_order_pct
FROM orders o
GROUP BY EXTRACT(YEAR FROM o.order_date)
ORDER BY order_year;

SELECT
    EXTRACT(YEAR FROM membership_join_date) AS join_year,
    COUNT(*) AS customers_joined
FROM customers
WHERE membership_join_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM membership_join_date)
ORDER BY join_year;