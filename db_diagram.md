Table Customers {
  customer_id varchar [pk]
  is_member bool [not null]
  membership_join_date datetime
  membership_cancel_date datetime
  full_name varchar [not null]
  address varchar
  phone_number varchar
}

Table Products {
  product_id varchar [pk]
  product_category_id varchar [not null, ref: > Product_Categories.product_category_id]
  aisle_id varchar [not null, ref: > Aisles.aisle_id]
  name varchar [not null]
  price decimal [not null]
  in_stock bool [not null]
  quantity_in_stock int [not null]
  cost decimal [not null]
}

Table Product_Categories {
  product_category_id varchar [pk]
  name varchar [not null]
  description varchar
}

Table Aisles {
  aisle_id varchar [pk]
  aisle_number int [not null]
  is_produce bool [not null]
  is_freezer bool [not null]
  is_food bool [not null]
  is_drink bool [not null]
}

Table Promotions {
  promotion_id varchar [pk]
  name varchar [not null]
  description varchar
  discount_percent decimal [not null]
  promotion_start_date datetime [not null]
  promotion_end_date datetime [not null]
  is_active bool [not null]
}

Table Promotion_Items {
  promotion_item_id varchar [pk]
  promotion_id varchar [not null, ref: > Promotions.promotion_id]
  product_id varchar [not null, ref: > Products.product_id]
}

Table Orders {
  order_id varchar [pk]
  customer_id varchar [not null, ref: > Customers.customer_id]
  total_price decimal [not null]
  order_date datetime [not null]
  used_promotion bool [not null]
  promotion_id varchar [ref: >? Promotions.promotion_id]
  is_member bool [not null]
}

Table Order_Items {
  order_item_id varchar [pk]
  order_id varchar [not null, ref: > Orders.order_id]
  product_id varchar [not null, ref: > Products.product_id]
  quantity int [not null]
  price_per_unit decimal [not null]
}

Table Payments {
  payment_id varchar [pk]
  customer_id varchar [not null, ref: > Customers.customer_id]
  order_id varchar [not null, ref: > Orders.order_id]
  payment_type varchar [not null]
  payment_date datetime [not null]
}

Table Returns {
  return_id varchar [pk]
  order_id varchar [not null, ref: > Orders.order_id]
  customer_id varchar [not null, ref: > Customers.customer_id]
  order_item_id varchar [not null, ref: > Order_Items.order_item_id]
  payment_id varchar [not null, ref: > Payments.payment_id]
  quantity_returned int [not null]
  refund_amount decimal [not null]
}

Table Suppliers {
  supplier_id varchar [pk]
  product_id varchar [not null, ref: > Products.product_id]
  price_per_unit decimal [not null]
  delivery_occurrence varchar [not null]
}

Table Supplier_Delivery {
  delivery_id varchar [pk]
  supplier_id varchar [not null, ref: > Suppliers.supplier_id]
  delivery_date datetime [not null]
  product_id varchar [not null, ref: > Products.product_id]
  quantity int [not null]
}