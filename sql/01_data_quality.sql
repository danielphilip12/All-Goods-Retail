-- Active: 1791309856637@@localhost@5432@allgoods_db

-- ==============================
-- 1. Row Counts
-- ==============================
SELECT COUNT(*) FROM aisles;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM product_categories;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM promotion_items;    
SELECT COUNT(*) FROM promotions;    
SELECT COUNT(*) FROM returns;
SELECT COUNT(*) FROM suppliers; 
SELECT COUNT(*) FROM supplier_products;
SELECT COUNT(*) FROM supplier_deliveries;

-- ============================================
-- 2. Primary Key Checks
-- ============================================

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_item_id, COUNT(*)
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

SELECT payment_id, COUNT(*)
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

-- ============================================
-- 3. Required Field Checks
-- ============================================

SELECT COUNT(*) AS missing_customer_ids
FROM customers
WHERE customer_id IS NULL;

SELECT COUNT(*) AS missing_product_names
FROM products
WHERE name IS NULL;

SELECT COUNT(*) AS missing_product_prices
FROM products
WHERE price IS NULL;

SELECT COUNT(*) AS missing_order_customers
FROM orders
WHERE customer_id IS NULL;

SELECT COUNT(*) AS missing_order_dates
FROM orders
WHERE order_date IS NULL;

-- ============================================
-- 4. Business Rule Checks
-- ============================================

SELECT *
FROM products
WHERE price < 0;

SELECT *
FROM products
WHERE cost < 0;

SELECT *
FROM products
WHERE quantity_in_stock < 0;

SELECT *
FROM orders
WHERE total_price < 0;

SELECT *
FROM orders
WHERE order_date < '2021-01-01'
   OR order_date > '2025-12-31';

SELECT *
FROM order_items
WHERE quantity <= 0;

SELECT *
FROM order_items
WHERE price_per_unit < 0;

SELECT supplier_id, product_id, COUNT(*)
FROM supplier_products
GROUP BY supplier_id, product_id
HAVING COUNT(*) > 1;

SELECT supplier_id, COUNT(*) AS product_count
FROM supplier_products
GROUP BY supplier_id
HAVING COUNT(*) > 10;

-- ============================================
-- 5. Referential Integrity Checks
-- ============================================

SELECT O.ORDER_ID, O.CUSTOMER_ID
FROM ORDERS O
LEFT JOIN CUSTOMERS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
WHERE C.CUSTOMER_ID IS NULL;

SELECT OI.ORDER_ITEM_ID, OI.ORDER_ID
FROM ORDER_ITEMS OI
LEFT JOIN ORDERS O ON OI.ORDER_ID = O.ORDER_ID
WHERE O.ORDER_ID IS NULL;

SELECT oi.order_item_id, oi.product_id
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ============================================
-- 6. Order total validation
-- ============================================

select 
    o.order_id, 
    o.total_price as recorded_total, 
    sum(oi.quantity * oi.price_per_unit) as calculated_total
from orders o
join order_items oi on o.order_id = oi.order_id
group by o.order_id, o.total_price
having abs(o.total_price - sum(oi.quantity * oi.price_per_unit)) > 0.01;

-- ============================================
-- 7. Return Validation
-- ============================================

SELECT
    r.return_id,
    r.order_item_id,
    r.quantity_returned,
    oi.quantity AS purchased_quantity
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE r.quantity_returned > oi.quantity;

SELECT *
FROM returns
WHERE quantity_returned <= 0
   OR refund_amount < 0;

-- ============================================
-- 8. Promotion Validation
-- ============================================

SELECT pi.promotion_item_id
FROM promotion_items pi
LEFT JOIN products p
    ON pi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT *
FROM promotions
WHERE promotion_end_date < promotion_start_date;

SELECT *
FROM promotions
WHERE discount_percent <= 0
   OR discount_percent > 100;