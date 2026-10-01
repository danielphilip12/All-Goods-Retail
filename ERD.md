# Tables

## Customers

- Customer ID - varchar
- Is Member - bool
- Membership Join Date - datetime
- Membership Cancel Date - datetime
- Full Name - varchar
- Address
- Phone Number

## Products

- Product ID - varchar
- Product Category ID - varchar
- Aisle ID - varchar
- Name
- Price
- In Stock
- Quantity in Stock
- Supplier
- Cost

## Product Categories

- Product Category ID - varchar
- Name
- Description

## Aisles

- Aisle ID
- Aisle Number
- Is Produce
- Is Freezer
- Is Food
- Is Drink

## Promotions

- Promotion ID - varchar
- Name
- Description
- Discount %
- Promotion Start Date
- Promotion End Date
- Is Active

## Promotion Items

- Promotion Item ID
- Promotion ID
- Product ID

## Orders

- Order ID
- Customer ID
- Total Price
- Order Date
- Used Promotion
- Is Member

## Order Items

- Order Item ID
- Order ID
- Product ID
- Quantity
- Price per Unit

## Payments

- Payment ID
- Customer ID
- Order ID
- Payment Type
- Payment Date

## Returns

- Return ID
- Order ID
- Customer ID
- Order Item ID
- Payment ID
- Quantity Returned
- Refund Amount

## Suppliers

- Supplier ID
- Product ID
- Price per unit
- Delivery Occurrence

## Supplier Delivery

- Delivery ID
- Supplier ID
- Delivery Date
- Product ID
- Quantity


# DB Diagram Code
Table Customers {
  customer_id varchar [pk]
  is_member bool
  membership_join_date datetime
  membership_cancel_date datetime
  full_name varchar
  address varchar
  phone_number varchar
}

Table Products {
  product_id varchar [pk]
  product_category_id varchar [not null, ref: > Product_Categories.product_category_id]
  aisle_id varchar [not null, ref: > Aisles.aisle_id]
  name varchar
  price decimal
  in_stock bool
  quantity_in_stock int
  supplier varchar
  cost decimal
}

Table Product_Categories {
  product_category_id varchar [pk]
  name varchar
  description varchar
}

Table Aisles {
  aisle_id varchar [pk]
  aisle_number int
  is_produce bool
  is_freezer bool
  is_food bool
  is_drink bool
}

Table Promotions {
  promotion_id varchar [pk]
  name varchar
  description varchar
  discount_percent decimal
  promotion_start_date datetime
  promotion_end_date datetime
  is_active bool
}

Table Promotion_Items {
  promotion_item_id varchar [pk]
  promotion_id varchar [not null, ref: > Promotions.promotion_id]
  product_id varchar [not null, ref: > Products.product_id]
}

Table Orders {
  order_id varchar [pk]
  customer_id varchar [not null, ref: > Customers.customer_id]
  total_price decimal
  order_date datetime
  used_promotion bool
  promotion_id varchar [ref: >? Promotions.promotion_id]
  is_member bool
}

Table Order_Items {
  order_item_id varchar [pk]
  order_id varchar [not null, ref: > Orders.order_id]
  product_id varchar [not null, ref: > Products.product_id]
  quantity int
  price_per_unit decimal
}

Table Payments {
  payment_id varchar [pk]
  customer_id varchar [not null, ref: > Customers.customer_id]
  order_id varchar [not null, ref: > Orders.order_id]
  payment_type varchar
  payment_date datetime
}

Table Returns {
  return_id varchar [pk]
  order_id varchar [not null, ref: > Orders.order_id]
  customer_id varchar [not null, ref: > Customers.customer_id]
  order_item_id varchar [not null, ref: > Order_Items.order_item_id]
  payment_id varchar [not null, ref: > Payments.payment_id]
  quantity_returned int
  refund_amount decimal
}

Table Suppliers {
  supplier_id varchar [pk]
  product_id varchar [not null, ref: > Products.product_id]
  price_per_unit decimal
  delivery_occurrence varchar
}

Table Supplier_Delivery {
  delivery_id varchar [pk]
  supplier_id varchar [not null, ref: > Suppliers.supplier_id]
  delivery_date datetime
  product_id varchar [not null, ref: > Products.product_id]
  quantity int
}