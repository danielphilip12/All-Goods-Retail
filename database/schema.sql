CREATE TABLE customers (
  "customer_id" varchar PRIMARY KEY,
  "is_member" bool NOT NULL,
  "membership_join_date" timestamptz,
  "membership_cancel_date" timestamptz,
  "full_name" varchar NOT NULL,
  "address" varchar,
  "phone_number" varchar
);

CREATE TABLE products (
  "product_id" varchar PRIMARY KEY,
  "product_category_id" varchar NOT NULL,
  "aisle_id" varchar NOT NULL,
  "name" varchar NOT NULL,
  "price" numeric(10, 2) NOT NULL,
  "in_stock" bool NOT NULL,
  "quantity_in_stock" int NOT NULL,
  "cost" numeric(10, 2) NOT NULL
);

CREATE TABLE product_categories (
  "product_category_id" varchar PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" varchar
);

CREATE TABLE aisles (
  "aisle_id" varchar PRIMARY KEY,
  "aisle_number" int NOT NULL,
  "is_produce" bool NOT NULL,
  "is_freezer" bool NOT NULL,
  "is_food" bool NOT NULL,
  "is_drink" bool NOT NULL
);

CREATE TABLE promotions (
  "promotion_id" varchar PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" varchar,
  "discount_percent" numeric(5, 2) NOT NULL,
  "promotion_start_date" timestamptz NOT NULL,
  "promotion_end_date" timestamptz NOT NULL,
  "is_active" bool NOT NULL
);

CREATE TABLE promotion_items (
  "promotion_item_id" varchar PRIMARY KEY,
  "promotion_id" varchar NOT NULL,
  "product_id" varchar NOT NULL
);

CREATE TABLE orders (
  "order_id" varchar PRIMARY KEY,
  "customer_id" varchar NOT NULL,
  "total_price" numeric(10, 2) NOT NULL,
  "order_date" timestamptz NOT NULL,
  "used_promotion" bool NOT NULL,
  "promotion_id" varchar,
  "is_member" bool NOT NULL
);

CREATE TABLE order_items (
  "order_item_id" varchar PRIMARY KEY,
  "order_id" varchar NOT NULL,
  "product_id" varchar NOT NULL,
  "quantity" int NOT NULL,
  "price_per_unit" numeric(10, 2) NOT NULL
);

CREATE TABLE payments (
  "payment_id" varchar PRIMARY KEY,
  "customer_id" varchar NOT NULL,
  "order_id" varchar NOT NULL,
  "payment_type" varchar NOT NULL,
  "payment_date" timestamptz NOT NULL
);

CREATE TABLE returns (
  "return_id" varchar PRIMARY KEY,
  "order_id" varchar NOT NULL,
  "customer_id" varchar NOT NULL,
  "order_item_id" varchar NOT NULL,
  "payment_id" varchar NOT NULL,
  "quantity_returned" int NOT NULL,
  "refund_amount" numeric(10, 2) NOT NULL
);

CREATE TABLE suppliers (
  "supplier_id" varchar PRIMARY KEY,
  "name" varchar NOT NULL
);

CREATE TABLE supplier_products (
  "supplier_product_id" varchar PRIMARY KEY,
  "supplier_id" varchar NOT NULL,
  "product_id" varchar NOT NULL,
  "price_per_unit" numeric(10, 2) NOT NULL,
  "delivery_occurrence" varchar NOT NULL
);

CREATE TABLE supplier_deliveries (
  "delivery_id" varchar PRIMARY KEY,
  "supplier_product_id" varchar NOT NULL,
  "delivery_date" timestamptz NOT NULL,
  "quantity" int NOT NULL
);

ALTER TABLE "products" ADD FOREIGN KEY ("product_category_id") REFERENCES "product_categories" ("product_category_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "products" ADD FOREIGN KEY ("aisle_id") REFERENCES "aisles" ("aisle_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "promotion_items" ADD FOREIGN KEY ("promotion_id") REFERENCES "promotions" ("promotion_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "promotion_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "orders" ADD FOREIGN KEY ("promotion_id") REFERENCES "promotions" ("promotion_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payments" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "payments" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "returns" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "returns" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "returns" ADD FOREIGN KEY ("order_item_id") REFERENCES "order_items" ("order_item_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "returns" ADD FOREIGN KEY ("payment_id") REFERENCES "payments" ("payment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "supplier_products" ADD FOREIGN KEY ("supplier_id") REFERENCES "suppliers" ("supplier_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "supplier_products" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "supplier_deliveries" ADD FOREIGN KEY ("supplier_product_id") REFERENCES "supplier_products" ("supplier_product_id") DEFERRABLE INITIALLY IMMEDIATE;
