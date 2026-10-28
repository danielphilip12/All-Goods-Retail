BEGIN;

TRUNCATE TABLE
    returns,
    supplier_deliveries,
    order_items,
    payments,
    orders,
    promotion_items,
    supplier_products,
    products,
    customers,
    suppliers,
    promotions,
    product_categories,
    aisles
RESTART IDENTITY;

COMMIT;