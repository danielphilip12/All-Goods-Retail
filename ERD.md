# Synthetic Retail Dataset — Data Dictionary

## Customers

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| customer_id | VARCHAR | No | Unique identifier for the customer. |
| is_member | BOOLEAN | No | Indicates whether the customer currently has an active membership. |
| membership_join_date | DATETIME | Yes | Date and time the customer joined the membership program. |
| membership_cancel_date | DATETIME | Yes | Date and time the customer cancelled their membership. NULL when the membership is active or the customer was never a member. |
| full_name | VARCHAR | No | Customer's full name. |
| address | VARCHAR | Yes | Customer's address. |
| phone_number | VARCHAR | Yes | Customer's phone number. |

---

## Products

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| product_id | VARCHAR | No | Unique identifier for the product. |
| product_category_id | VARCHAR | No | Identifier of the product category. Foreign key to `Product_Categories`. |
| aisle_id | VARCHAR | No | Identifier of the aisle where the product is located. Foreign key to `Aisles`. |
| name | VARCHAR | No | Product name. |
| price | DECIMAL | No | Current retail price of the product. |
| in_stock | BOOLEAN | No | Indicates whether the product currently has inventory available. |
| quantity_in_stock | INTEGER | No | Current quantity of the product in inventory. |
| cost | DECIMAL | No | Retailer's cost for the product. |

---

## Product Categories

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| product_category_id | VARCHAR | No | Unique identifier for the product category. |
| name | VARCHAR | No | Name of the product category. |
| description | VARCHAR | Yes | Description of the product category. |

---

## Aisles

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| aisle_id | VARCHAR | No | Unique identifier for the aisle. |
| aisle_number | INTEGER | No | Physical aisle number. |
| is_produce | BOOLEAN | No | Indicates whether the aisle contains produce. |
| is_freezer | BOOLEAN | No | Indicates whether the aisle is a freezer aisle. |
| is_food | BOOLEAN | No | Indicates whether the aisle contains food products. |
| is_drink | BOOLEAN | No | Indicates whether the aisle contains beverages. |

---

## Promotions

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| promotion_id | VARCHAR | No | Unique identifier for the promotion. |
| name | VARCHAR | No | Promotion name. |
| description | VARCHAR | Yes | Description of the promotion. |
| discount_percent | DECIMAL | No | Percentage discount offered by the promotion. Maximum 75%. |
| promotion_start_date | DATETIME | No | Date and time the promotion begins. |
| promotion_end_date | DATETIME | No | Date and time the promotion ends. |
| is_active | BOOLEAN | No | Indicates whether the promotion is currently active relative to the reference date. |

---

## Promotion Items

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| promotion_item_id | VARCHAR | No | Unique identifier for the promotion-product relationship. |
| promotion_id | VARCHAR | No | Promotion associated with the product. Foreign key to `Promotions`. |
| product_id | VARCHAR | No | Product receiving the promotion. Foreign key to `Products`. |

---

## Orders

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| order_id | VARCHAR | No | Unique identifier for the order. |
| customer_id | VARCHAR | No | Customer who placed the order. Foreign key to `Customers`. |
| total_price | DECIMAL | No | Total amount paid for the order after applicable discounts. |
| order_date | DATETIME | No | Date and time the order was placed. |
| used_promotion | BOOLEAN | No | Indicates whether the order used a promotion. |
| promotion_id | VARCHAR | Yes | Promotion used on the order. NULL when no promotion was used. |
| is_member | BOOLEAN | No | Customer's membership status at the time of the order. |

---

## Order Items

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| order_item_id | VARCHAR | No | Unique identifier for the order line item. |
| order_id | VARCHAR | No | Order containing the item. Foreign key to `Orders`. |
| product_id | VARCHAR | No | Product purchased. Foreign key to `Products`. |
| quantity | INTEGER | No | Number of units purchased. |
| price_per_unit | DECIMAL | No | Actual price paid per unit after applicable discounts. |

---

## Payments

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| payment_id | VARCHAR | No | Unique identifier for the payment. |
| customer_id | VARCHAR | No | Customer who made the payment. Foreign key to `Customers`. |
| order_id | VARCHAR | No | Order associated with the payment. Foreign key to `Orders`. |
| payment_type | VARCHAR | No | Method used to pay for the order. |
| payment_date | DATETIME | No | Date and time the payment was made. |

---

## Returns

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| return_id | VARCHAR | No | Unique identifier for the return. |
| order_id | VARCHAR | No | Original order associated with the return. Foreign key to `Orders`. |
| customer_id | VARCHAR | No | Customer who returned the item. Foreign key to `Customers`. |
| order_item_id | VARCHAR | No | Original order item being returned. Foreign key to `Order_Items`. |
| payment_id | VARCHAR | No | Payment associated with the original purchase. Foreign key to `Payments`. |
| quantity_returned | INTEGER | No | Number of units returned. |
| refund_amount | DECIMAL | No | Amount refunded to the customer. |

---

## Suppliers

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| supplier_id | VARCHAR | No | Identifier for the supplier. |
| product_id | VARCHAR | No | Product supplied by the supplier. Foreign key to `Products`. |
| price_per_unit | DECIMAL | No | Price paid by the retailer to the supplier per unit. |
| delivery_occurrence | VARCHAR | No | Typical delivery frequency for the supplier-product relationship. |

---

## Supplier Delivery

| Column | Data Type | Nullable | Description |
|---|---|---:|---|
| delivery_id | VARCHAR | No | Unique identifier for the delivery. |
| supplier_id | VARCHAR | No | Supplier responsible for the delivery. Foreign key to `Suppliers`. |
| delivery_date | DATETIME | No | Date and time the delivery occurred. |
| product_id | VARCHAR | No | Product included in the delivery. Foreign key to `Products`. |
| quantity | INTEGER | No | Number of units delivered. |

---

# Relationships

| Parent Table | Child Table | Relationship |
|---|---|---|
| Customers | Orders | One customer can have many orders. |
| Customers | Payments | One customer can make many payments. |
| Customers | Returns | One customer can have many returns. |
| Product_Categories | Products | One category can contain many products. |
| Aisles | Products | One aisle can contain many products. |
| Products | Order_Items | One product can appear in many order items. |
| Orders | Order_Items | One order contains many order items. |
| Promotions | Promotion_Items | One promotion can apply to many products. |
| Products | Promotion_Items | One product can participate in many promotions. |
| Promotions | Orders | One promotion can be used by many orders. |
| Orders | Payments | One order can have one or more payments. |
| Orders | Returns | One order can have zero or more returns. |
| Order_Items | Returns | One order item can have zero or more returns. |
| Payments | Returns | One payment can be associated with zero or more returns. |
| Products | Suppliers | One product can have multiple supplier relationships. |
| Suppliers | Supplier_Delivery | One supplier can have many deliveries. |
| Products | Supplier_Delivery | One product can appear in many deliveries. |