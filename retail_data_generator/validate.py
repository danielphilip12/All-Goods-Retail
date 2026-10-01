import pandas as pd
from pathlib import Path

OUTPUT_DIR = Path("output")

from config import (
    MAX_DISCOUNT_PERCENT,
    MAX_ORDER_ITEMS,
    MAX_PRODUCTS_PER_SUPPLIER,
    MAX_QUANTITY_PER_ITEM,
    MEMBERSHIP_RATE,
    MIN_DISCOUNT_PERCENT,
    MIN_ORDER_ITEMS,
    MIN_QUANTITY_PER_ITEM,
    N_AISLES,
    N_PRODUCT_CATEGORIES,
    N_CUSTOMERS,
    N_ORDERS,
    N_PRODUCTS,
    N_PROMOTIONS,
    N_SUPPLIERS,
    PAYMENT_TYPES,
    PROJECT_END_DATE,
    PROJECT_START_DATE,
)


# ============================================================
# LOAD DATA
# ============================================================

def load_data():
    aisles = pd.read_csv(OUTPUT_DIR / "aisles.csv")
    customers = pd.read_csv(OUTPUT_DIR / "customers.csv")
    order_items = pd.read_csv(OUTPUT_DIR / "order_items.csv")
    orders = pd.read_csv(OUTPUT_DIR / "orders.csv")
    payments = pd.read_csv(OUTPUT_DIR / "payments.csv")
    product_categories = pd.read_csv(
        OUTPUT_DIR / "product_categories.csv"
    )
    products = pd.read_csv(OUTPUT_DIR / "products.csv")
    promotion_items = pd.read_csv(
        OUTPUT_DIR / "promotion_items.csv"
    )
    promotions = pd.read_csv(OUTPUT_DIR / "promotions.csv")
    returns = pd.read_csv(OUTPUT_DIR / "returns.csv")
    supplier_deliveries = pd.read_csv(
        OUTPUT_DIR / "supplier_delivery.csv"
    )
    suppliers = pd.read_csv(OUTPUT_DIR / "suppliers.csv")
    supplier_products = pd.read_csv(
        OUTPUT_DIR / "supplier_products.csv"
    )

    return {
        "aisles": aisles,
        "customers": customers,
        "order_items": order_items,
        "orders": orders,
        "payments": payments,
        "product_categories": product_categories,
        "products": products,
        "promotion_items": promotion_items,
        "promotions": promotions,
        "returns": returns,
        "supplier_deliveries": supplier_deliveries,
        "suppliers": suppliers,
        "supplier_products": supplier_products,
    }


data = load_data()

aisles = data["aisles"]
customers = data["customers"]
order_items = data["order_items"]
orders = data["orders"]
payments = data["payments"]
product_categories = data["product_categories"]
products = data["products"]
promotion_items = data["promotion_items"]
promotions = data["promotions"]
returns = data["returns"]
supplier_deliveries = data["supplier_deliveries"]
suppliers = data["suppliers"]
supplier_products = data["supplier_products"]


# ============================================================
# 1. ROW COUNTS
# ============================================================

def validate_row_counts(data):

    assert len(data["customers"]) == N_CUSTOMERS, (
        f"Expected {N_CUSTOMERS} customers, "
        f"but got {len(data['customers'])}"
    )

    assert len(data["aisles"]) == N_AISLES, (
        f"Expected {N_AISLES} aisles, "
        f"but got {len(data['aisles'])}"
    )

    assert len(data["orders"]) == N_ORDERS, (
        f"Expected {N_ORDERS} orders, "
        f"but got {len(data['orders'])}"
    )

    assert len(data["product_categories"]) == N_PRODUCT_CATEGORIES, (
        f"Expected {N_PRODUCT_CATEGORIES} product categories, "
        f"but got {len(data['product_categories'])}"
    )

    assert len(data["products"]) == N_PRODUCTS, (
        f"Expected {N_PRODUCTS} products, "
        f"but got {len(data['products'])}"
    )

    assert len(data["promotions"]) == N_PROMOTIONS, (
        f"Expected {N_PROMOTIONS} promotions, "
        f"but got {len(data['promotions'])}"
    )

    assert data["suppliers"]["supplier_id"].nunique() == N_SUPPLIERS, (
        f"Expected {N_SUPPLIERS} suppliers, "
        f"but got {data['suppliers']['supplier_id'].nunique()}"
    )


# ============================================================
# 2. PRIMARY KEYS
# ============================================================

def validate_primary_keys(data):

    primary_keys = {
        "customers": "customer_id",
        "aisles": "aisle_id",
        "orders": "order_id",
        "product_categories": "product_category_id",
        "products": "product_id",
        "promotions": "promotion_id",
        "suppliers": "supplier_id",
        "payments": "payment_id",
        "promotion_items": "promotion_item_id",
        "returns": "return_id",
        "supplier_deliveries": "delivery_id",
        "order_items": "order_item_id",
        "supplier_products": "supplier_product_id",
    }

    for table_name, primary_key in primary_keys.items():

        df = data[table_name]

        assert df[primary_key].notna().all(), (
            f"{table_name}.{primary_key} contains null values"
        )

        assert df[primary_key].is_unique, (
            f"{table_name}.{primary_key} contains duplicates"
        )


# ============================================================
# 3. REQUIRED FIELDS / NULL VALIDATION
# ============================================================

def validate_required_fields(data):

    required_fields = {
        "aisles": [
            "aisle_id",
            "aisle_number",
            "is_produce",
            "is_freezer",
            "is_food",
            "is_drink",
        ],
        "customers": [
            "customer_id",
            "is_member",
            "full_name",
        ],
        "products": [
            "product_id",
            "product_category_id",
            "aisle_id",
            "name",
            "price",
            "in_stock",
            "quantity_in_stock",
            "cost",
        ],
        "product_categories": [
            "product_category_id",
            "name",
        ],
        "promotions": [
            "promotion_id",
            "name",
            "discount_percent",
            "promotion_start_date",
            "promotion_end_date",
            "is_active",
        ],
        "promotion_items": [
            "promotion_item_id",
            "promotion_id",
            "product_id",
        ],
        "orders": [
            "order_id",
            "customer_id",
            "total_price",
            "order_date",
            "used_promotion",
            "is_member",
        ],
        "order_items": [
            "order_item_id",
            "order_id",
            "product_id",
            "quantity",
            "price_per_unit",
        ],
        "payments": [
            "payment_id",
            "customer_id",
            "order_id",
            "payment_type",
            "payment_date",
        ],
        "returns": [
            "return_id",
            "order_id",
            "customer_id",
            "order_item_id",
            "payment_id",
            "quantity_returned",
            "refund_amount",
        ],
        "suppliers": [
            "supplier_id",
            "name",
        ],
        "supplier_products": [
            "supplier_product_id",
            "supplier_id",
            "product_id",
            "price_per_unit",
            "delivery_occurrence",
        ],
        "supplier_deliveries": [
            "delivery_id",
            "supplier_product_id",
            "delivery_date",
            "quantity",
        ],
    }

    for table_name, columns in required_fields.items():

        df = data[table_name]

        for column in columns:

            assert df[column].notna().all(), (
                f"{table_name}.{column} contains null values"
            )


# ============================================================
# 4. FOREIGN KEY VALIDATION
# ============================================================

def validate_foreign_keys(data):

    def validate_fk(
        child_table,
        child_column,
        parent_table,
        parent_column,
    ):

        child = data[child_table]
        parent = data[parent_table]

        valid_values = set(parent[parent_column])

        invalid = child[
            child[child_column].notna()
            & ~child[child_column].isin(valid_values)
        ]

        assert invalid.empty, (
            f"{child_table}.{child_column} contains "
            f"{len(invalid)} invalid foreign keys"
        )

    # Products
    validate_fk(
        "products",
        "product_category_id",
        "product_categories",
        "product_category_id",
    )

    validate_fk(
        "products",
        "aisle_id",
        "aisles",
        "aisle_id",
    )

    # Promotion items
    validate_fk(
        "promotion_items",
        "promotion_id",
        "promotions",
        "promotion_id",
    )

    validate_fk(
        "promotion_items",
        "product_id",
        "products",
        "product_id",
    )

    # Orders
    validate_fk(
        "orders",
        "customer_id",
        "customers",
        "customer_id",
    )

    validate_fk(
        "orders",
        "promotion_id",
        "promotions",
        "promotion_id",
    )

    # Order items
    validate_fk(
        "order_items",
        "order_id",
        "orders",
        "order_id",
    )

    validate_fk(
        "order_items",
        "product_id",
        "products",
        "product_id",
    )

    # Payments
    validate_fk(
        "payments",
        "customer_id",
        "customers",
        "customer_id",
    )

    validate_fk(
        "payments",
        "order_id",
        "orders",
        "order_id",
    )

    # Returns
    validate_fk(
        "returns",
        "order_id",
        "orders",
        "order_id",
    )

    validate_fk(
        "returns",
        "customer_id",
        "customers",
        "customer_id",
    )

    validate_fk(
        "returns",
        "order_item_id",
        "order_items",
        "order_item_id",
    )

    validate_fk(
        "returns",
        "payment_id",
        "payments",
        "payment_id",
    )

    # Supplier products
    validate_fk(
        "supplier_products",
        "supplier_id",
        "suppliers",
        "supplier_id",
    )

    validate_fk(
        "supplier_products",
        "product_id",
        "products",
        "product_id",
    )

    # Supplier deliveries
    validate_fk(
        "supplier_deliveries",
        "supplier_product_id",
        "supplier_products",
        "supplier_product_id",
    )


# ============================================================
# 5. CUSTOMER / MEMBERSHIP VALIDATION
# ============================================================

def validate_customers(data):
    df = data["customers"].copy()

    df["membership_join_date"] = pd.to_datetime(
        df["membership_join_date"], errors="coerce"
    )
    df["membership_cancel_date"] = pd.to_datetime(
        df["membership_cancel_date"], errors="coerce"
    )

    # Current members:
    # Must have a join date and must not have a cancellation date.
    current_members = df[df["is_member"]]

    assert current_members["membership_join_date"].notna().all(), (
        "Current members are missing membership join dates"
    )

    assert current_members["membership_cancel_date"].isna().all(), (
        "Current members have membership cancellation dates"
    )

    # Former members:
    # Not currently a member, but has a membership history.
    former_members = df[
        (~df["is_member"])
        & df["membership_join_date"].notna()
    ]

    assert former_members["membership_cancel_date"].notna().all(), (
        "Former members have a join date but no cancellation date"
    )

    # Never-members:
    # No membership history at all.
    never_members = df[
        (~df["is_member"])
        & df["membership_join_date"].isna()
    ]

    assert never_members["membership_cancel_date"].isna().all(), (
        "Customers without membership join dates have cancellation dates"
    )

    # Cancellation cannot occur before joining.
    has_both_dates = (
        df["membership_join_date"].notna()
        & df["membership_cancel_date"].notna()
    )

    assert (
        df.loc[has_both_dates, "membership_cancel_date"]
        >= df.loc[has_both_dates, "membership_join_date"]
    ).all(), (
        "Some membership cancellation dates occur "
        "before the membership join date"
    )

    # Membership dates must fall within the project period.
    join_dates = df["membership_join_date"].dropna()
    cancel_dates = df["membership_cancel_date"].dropna()

    assert (join_dates >= PROJECT_START_DATE).all(), (
        "Membership join dates occur before project start"
    )

    assert (join_dates <= PROJECT_END_DATE).all(), (
        "Membership join dates occur after project end"
    )

    assert (cancel_dates >= PROJECT_START_DATE).all(), (
        "Membership cancellation dates occur before project start"
    )

    assert (cancel_dates <= PROJECT_END_DATE).all(), (
        "Membership cancellation dates occur after project end"
    )


# ============================================================
# 6. PRODUCT VALIDATION
# ============================================================

def validate_products(data):

    df = data["products"]

    assert (df["price"] > 0).all(), (
        "Products contain prices <= 0"
    )

    assert (df["cost"] > 0).all(), (
        "Products contain costs <= 0"
    )

    assert (df["cost"] < df["price"]).all(), (
        "Some products have cost >= retail price"
    )

    assert (df["quantity_in_stock"] >= 0).all(), (
        "Products contain negative inventory"
    )

    expected_in_stock = df["quantity_in_stock"] > 0

    assert (
        df["in_stock"] == expected_in_stock
    ).all(), (
        "Product in_stock flag does not match quantity_in_stock"
    )


# ============================================================
# 7. SUPPLIER / PRODUCT VALIDATION
# ============================================================

def validate_supplier_products(data):

    df = data["supplier_products"]

    # A supplier/product pair should only occur once.
    duplicate_pairs = df[
        df.duplicated(
            subset=["supplier_id", "product_id"],
            keep=False,
        )
    ]

    assert duplicate_pairs.empty, (
        "Duplicate supplier/product relationships found"
    )

    # No supplier can supply more than the configured maximum.
    supplier_counts = (
        df.groupby("supplier_id")["product_id"]
        .nunique()
    )

    assert (
        supplier_counts <= MAX_PRODUCTS_PER_SUPPLIER
    ).all(), (
        "One or more suppliers exceed "
        f"MAX_PRODUCTS_PER_SUPPLIER ({MAX_PRODUCTS_PER_SUPPLIER})"
    )

    # Every product must have at least one supplier.
    supplied_products = set(df["product_id"])

    products_without_supplier = products[
        ~products["product_id"].isin(supplied_products)
    ]

    assert products_without_supplier.empty, (
        "One or more products do not have a supplier"
    )

    # Supplier cost must be positive.
    assert (df["price_per_unit"] > 0).all(), (
        "Supplier prices contain values <= 0"
    )

    # Supplier cost should be lower than retail price.
    product_prices = data["products"][
        ["product_id", "price"]
    ]

    merged = df.merge(
        product_prices,
        on="product_id",
        how="left",
    )

    assert (
        merged["price_per_unit"] < merged["price"]
    ).all(), (
        "Some supplier prices are >= the corresponding "
        "retail price"
    )

    # Delivery occurrence must be one of the allowed values.
    valid_occurrences = {
        "Weekly",
        "Biweekly",
        "Monthly",
        "As Needed",
    }

    assert (
        df["delivery_occurrence"]
        .isin(valid_occurrences)
        .all()
    ), "Invalid supplier delivery occurrence found"


# ============================================================
# 8. PROMOTION VALIDATION
# ============================================================

def validate_promotions(data):

    promotions = data["promotions"].copy()

    promotions["promotion_start_date"] = pd.to_datetime(
        promotions["promotion_start_date"]
    )

    promotions["promotion_end_date"] = pd.to_datetime(
        promotions["promotion_end_date"]
    )

    # Discount range.
    assert (
        promotions["discount_percent"]
        > 0
    ).all(), "Promotions contain discounts <= 0"

    assert (
        promotions["discount_percent"]
        <= MAX_DISCOUNT_PERCENT
    ).all(), (
        "Promotions contain discounts above "
        f"{MAX_DISCOUNT_PERCENT}%"
    )

    assert (
        promotions["discount_percent"]
        >= MIN_DISCOUNT_PERCENT
    ).all(), (
        "Promotions contain discounts below "
        f"{MIN_DISCOUNT_PERCENT}%"
    )

    # Start date must precede end date.
    assert (
        promotions["promotion_start_date"]
        < promotions["promotion_end_date"]
    ).all(), (
        "Some promotions end before they start"
    )

    # Promotion dates must be inside project period.
    assert (
        promotions["promotion_start_date"]
        >= PROJECT_START_DATE
    ).all(), (
        "Promotion starts before project start"
    )

    assert (
        promotions["promotion_end_date"]
        <= PROJECT_END_DATE
    ).all(), (
        "Promotion ends after project end"
    )

    # Promotion item relationships must be unique.
    promotion_items = data["promotion_items"]

    duplicate_pairs = promotion_items[
        promotion_items.duplicated(
            subset=["promotion_id", "product_id"],
            keep=False,
        )
    ]

    assert duplicate_pairs.empty, (
        "Duplicate promotion/product relationships found"
    )

    # Every promotion should have at least one product.
    promotions_with_products = set(
        promotion_items["promotion_id"]
    )

    promotions_without_products = promotions[
        ~promotions["promotion_id"].isin(
            promotions_with_products
        )
    ]

    assert promotions_without_products.empty, (
        "One or more promotions have no products"
    )


# ============================================================
# 9. ORDER VALIDATION
# ============================================================

def validate_orders(data):

    orders = data["orders"].copy()
    customers = data["customers"].copy()

    orders["order_date"] = pd.to_datetime(
        orders["order_date"]
    )

    # Order dates must be within project period.
    assert (
        orders["order_date"] >= PROJECT_START_DATE
    ).all(), (
        "Orders occur before project start"
    )

    assert (
        orders["order_date"] <= PROJECT_END_DATE
    ).all(), (
        "Orders occur after project end"
    )

    # Orders should contain at least one item.
    item_counts = (
        data["order_items"]
        .groupby("order_id")
        .size()
    )

    missing_item_orders = orders[
        ~orders["order_id"].isin(item_counts.index)
    ]

    assert missing_item_orders.empty, (
        "One or more orders have no order items"
    )

    # Number of items per order.
    assert (
        item_counts >= MIN_ORDER_ITEMS
    ).all(), (
        "An order contains fewer than the minimum "
        "number of items"
    )

    assert (
        item_counts <= MAX_ORDER_ITEMS
    ).all(), (
        "An order exceeds MAX_ORDER_ITEMS"
    )

    # Membership status at order time.
    customer_membership = customers[
        [
            "customer_id",
            "membership_join_date",
            "membership_cancel_date",
        ]
    ].copy()

    customer_membership[
        "membership_join_date"
    ] = pd.to_datetime(
        customer_membership["membership_join_date"]
    )

    customer_membership[
        "membership_cancel_date"
    ] = pd.to_datetime(
        customer_membership["membership_cancel_date"]
    )

    merged = orders.merge(
        customer_membership,
        on="customer_id",
        how="left",
    )

    expected_member_status = (
        merged["membership_join_date"].notna()
        & (
            merged["order_date"]
            >= merged["membership_join_date"]
        )
        & (
            merged["membership_cancel_date"].isna()
            | (
                merged["order_date"]
                < merged["membership_cancel_date"]
            )
        )
    )

    assert (
        merged["is_member"]
        == expected_member_status
    ).all(), (
        "Order membership status does not match "
        "customer membership dates"
    )


# ============================================================
# 10. ORDER ITEM VALIDATION
# ============================================================

def validate_order_items(data):

    items = data["order_items"]

    # Quantity limits.
    assert (
        items["quantity"] >= MIN_QUANTITY_PER_ITEM
    ).all(), (
        "Order items contain quantities below the minimum"
    )

    assert (
        items["quantity"] <= MAX_QUANTITY_PER_ITEM
    ).all(), (
        "Order items exceed MAX_QUANTITY_PER_ITEM"
    )

    # Price must be positive.
    assert (
        items["price_per_unit"] > 0
    ).all(), (
        "Order items contain prices <= 0"
    )

    # Same product should not appear twice in an order.
    duplicate_products = items[
        items.duplicated(
            subset=["order_id", "product_id"],
            keep=False,
        )
    ]

    assert duplicate_products.empty, (
        "The same product appears multiple times "
        "in one order"
    )


# ============================================================
# 11. ORDER TOTAL VALIDATION
# ============================================================

# def validate_order_totals(data):

#     orders = data["orders"]
#     items = data["order_items"]

#     calculated_totals = (
#         items.assign(
#             line_total=lambda df:
#                 df["quantity"] * df["price_per_unit"]
#         )
#         .groupby("order_id")["line_total"]
#         .sum()
#     )

#     comparison = orders.set_index(
#         "order_id"
#     )["total_price"].compare(
#         calculated_totals
#     )

#     assert comparison.empty, (
#         "Order totals do not match the sum of order item totals"
#     )

def validate_order_totals(data):
    orders = data["orders"].copy()
    order_items = data["order_items"].copy()

    # Calculate the total from order items
    order_items["line_total"] = (
        order_items["quantity"] *
        order_items["price_per_unit"]
    )

    calculated_totals = (
        order_items
        .groupby("order_id")["line_total"]
        .sum()
        .round(2)
        .rename("calculated_total")
    )

    comparison = (
        orders[["order_id", "total_price"]]
        .merge(
            calculated_totals,
            on="order_id",
            how="left"
        )
    )

    comparison["difference"] = (
        comparison["total_price"] -
        comparison["calculated_total"]
    ).round(2)

    mismatches = comparison[
        comparison["difference"].abs() > 0.01
    ]

    if not mismatches.empty:
        print("\nOrder total mismatches:")
        print(mismatches.head(10).to_string(index=False))

        print(
            f"\nTotal mismatched orders: {len(mismatches)}"
        )

        print(
            "\nLargest differences:"
        )
        print(
            mismatches
            .sort_values("difference", key=lambda x: x.abs(), ascending=False)
            .head(10)
            .to_string(index=False)
        )

    print(mismatches)

    assert mismatches.empty, (
        "Order totals do not match the sum of order item totals"
    )

# ============================================================
# 12. PAYMENT VALIDATION
# ============================================================

def validate_payments(data):

    payments = data["payments"]
    orders = data["orders"]

    payments["payment_date"] = pd.to_datetime(
        payments["payment_date"]
    )

    orders_for_payment = orders[
        [
            "order_id",
            "customer_id",
            "order_date",
        ]
    ].copy()

    orders_for_payment["order_date"] = pd.to_datetime(
        orders_for_payment["order_date"]
    )

    merged = payments.merge(
        orders_for_payment,
        on="order_id",
        how="left",
        suffixes=("_payment", "_order"),
    )

    # Payment customer must match order customer.
    assert (
        merged["customer_id_payment"]
        == merged["customer_id_order"]
    ).all(), (
        "Payment customer does not match order customer"
    )

    # Every order needs at least one payment.
    payment_counts = (
        payments.groupby("order_id")
        .size()
    )

    unpaid_orders = orders[
        ~orders["order_id"].isin(
            payment_counts.index
        )
    ]

    assert unpaid_orders.empty, (
        "One or more orders have no payment"
    )

    # Payment date cannot precede order date.
    assert (
        merged["payment_date"]
        >= merged["order_date"]
    ).all(), (
        "A payment occurs before its order"
    )

    # Payment types.
    assert (
        payments["payment_type"]
        .isin(PAYMENT_TYPES)
        .all()
    ), (
        "Invalid payment type found"
    )


# ============================================================
# 13. RETURN VALIDATION
# ============================================================

def validate_returns(data):

    returns = data["returns"]
    order_items = data["order_items"]
    orders = data["orders"]
    payments = data["payments"]

    # Positive quantity and refund.
    assert (
        returns["quantity_returned"] > 0
    ).all(), (
        "Returns contain quantities <= 0"
    )

    assert (
        returns["refund_amount"] > 0
    ).all(), (
        "Returns contain refund amounts <= 0"
    )

    # Return customer must match original order.
    return_orders = returns.merge(
        orders[
            ["order_id", "customer_id"]
        ],
        on="order_id",
        how="left",
        suffixes=("_return", "_order"),
    )

    assert (
        return_orders["customer_id_return"]
        == return_orders["customer_id_order"]
    ).all(), (
        "Return customer does not match order customer"
    )

    # Return order item must belong to the return's order.
    return_items = returns.merge(
        order_items[
            [
                "order_item_id",
                "order_id",
                "quantity",
                "price_per_unit",
            ]
        ],
        on="order_item_id",
        how="left",
        suffixes=("_return", "_item"),
    )

    assert (
        return_items["order_id_return"]
        == return_items["order_id_item"]
    ).all(), (
        "Return order item does not belong to return order"
    )

    # Returned quantity cannot exceed purchased quantity,
    # accounting for multiple return records.
    returned_by_item = (
        returns.groupby("order_item_id")[
            "quantity_returned"
        ]
        .sum()
    )

    purchased_by_item = (
        order_items.set_index("order_item_id")[
            "quantity"
        ]
    )

    comparison = (
        returned_by_item
        <= purchased_by_item.loc[
            returned_by_item.index
        ]
    )

    assert comparison.all(), (
        "Total returned quantity exceeds purchased quantity"
    )

    # Return payment must belong to same order.
    return_payments = returns.merge(
        payments[
            ["payment_id", "order_id"]
        ],
        on="payment_id",
        how="left",
        suffixes=("_return", "_payment"),
    )

    assert (
        return_payments["order_id_return"]
        == return_payments["order_id_payment"]
    ).all(), (
        "Return payment does not belong to return order"
    )

    # Refund cannot exceed the original purchased value
    # of the returned item.
    return_items["maximum_refund"] = (
        return_items["quantity_returned"]
        * return_items["price_per_unit"]
    )

    assert (
        return_items["refund_amount"]
        <= return_items["maximum_refund"] + 0.01
    ).all(), (
        "A refund exceeds the value of the returned items"
    )


# ============================================================
# 14. SUPPLIER DELIVERY VALIDATION
# ============================================================

def validate_supplier_deliveries(data):

    deliveries = data["supplier_deliveries"].copy()

    deliveries["delivery_date"] = pd.to_datetime(
        deliveries["delivery_date"]
    )

    # Quantity must be positive.
    assert (
        deliveries["quantity"] > 0
    ).all(), (
        "Supplier deliveries contain quantities <= 0"
    )

    # Delivery date must be within project period.
    assert (
        deliveries["delivery_date"]
        >= PROJECT_START_DATE
    ).all(), (
        "Supplier delivery occurs before project start"
    )

    assert (
        deliveries["delivery_date"]
        <= PROJECT_END_DATE
    ).all(), (
        "Supplier delivery occurs after project end"
    )

    # Every supplier-product relationship should have
    # at least one delivery.
    relationship_ids = set(
        data["supplier_products"]["supplier_product_id"]
    )

    delivery_relationship_ids = set(
        deliveries["supplier_product_id"]
    )

    missing_deliveries = (
        relationship_ids
        - delivery_relationship_ids
    )

    assert not missing_deliveries, (
        "One or more supplier-product relationships "
        "have no deliveries"
    )


# ============================================================
# 15. PROMOTION / ORDER CROSS-TABLE VALIDATION
# ============================================================

def validate_order_promotions(data):

    orders = data["orders"].copy()
    order_items = data["order_items"]
    promotion_items = data["promotion_items"]
    promotions = data["promotions"]
    customers = data["customers"]

    orders["order_date"] = pd.to_datetime(
        orders["order_date"]
    )

    promotions = promotions.copy()

    promotions["promotion_start_date"] = pd.to_datetime(
        promotions["promotion_start_date"]
    )

    promotions["promotion_end_date"] = pd.to_datetime(
        promotions["promotion_end_date"]
    )

    # Orders that use promotions.
    promo_orders = orders[
        orders["used_promotion"]
    ].copy()

    # Promotion ID must be populated when used.
    assert (
        promo_orders["promotion_id"].notna().all()
    ), (
        "Orders marked as using a promotion "
        "are missing promotion_id"
    )

    # Orders not using a promotion must have NULL promotion_id.
    non_promo_orders = orders[
        ~orders["used_promotion"]
    ]

    assert (
        non_promo_orders["promotion_id"].isna().all()
    ), (
        "Orders not using promotions have a promotion_id"
    )

    if promo_orders.empty:
        return

    # Promotion users must be members.
    assert (
        promo_orders["is_member"]
    ).all(), (
        "A non-member used a promotion"
    )

    # Promotion must exist and order date must be inside
    # promotion period.
    merged = promo_orders.merge(
        promotions[
            [
                "promotion_id",
                "promotion_start_date",
                "promotion_end_date",
            ]
        ],
        on="promotion_id",
        how="left",
    )

    assert (
        merged["order_date"]
        >= merged["promotion_start_date"]
    ).all(), (
        "Promotion used before promotion start date"
    )

    assert (
        merged["order_date"]
        <= merged["promotion_end_date"]
    ).all(), (
        "Promotion used after promotion end date"
    )

    # Each promotional order must contain at least one
    # product included in that promotion.
    promo_order_items = promo_orders[
        [
            "order_id",
            "promotion_id",
        ]
    ].merge(
        order_items[
            [
                "order_id",
                "product_id",
            ]
        ],
        on="order_id",
    )

    promo_order_items = promo_order_items.merge(
        promotion_items[
            [
                "promotion_id",
                "product_id",
            ]
        ],
        on=[
            "promotion_id",
            "product_id",
        ],
        how="left",
        indicator=True,
    )

    matching_orders = set(
        promo_order_items.loc[
            promo_order_items["_merge"] == "both",
            "order_id",
        ]
    )

    assert set(promo_orders["order_id"]).issubset(
        matching_orders
    ), (
        "A promotion was used on an order that contains "
        "no product included in that promotion"
    )


# ============================================================
# 16. PROMOTIONAL PRICE VALIDATION
# ============================================================

# def validate_promotional_prices(data):

#     orders = data["orders"]
#     order_items = data["order_items"]
#     products = data["products"]
#     promotions = data["promotions"]
#     promotion_items = data["promotion_items"]

#     promo_orders = orders[
#         orders["used_promotion"]
#     ][
#         [
#             "order_id",
#             "promotion_id",
#         ]
#     ]

#     if promo_orders.empty:
#         return

#     promo_lines = promo_orders.merge(
#         order_items,
#         on="order_id",
#     )

#     promo_lines = promo_lines.merge(
#         promotion_items,
#         on=[
#             "promotion_id",
#             "product_id",
#         ],
#         how="left",
#         indicator=True,
#     )

#     promo_lines = promo_lines.merge(
#         promotions[
#             [
#                 "promotion_id",
#                 "discount_percent",
#             ]
#         ],
#         on="promotion_id",
#         how="left",
#     )

#     promo_lines = promo_lines.merge(
#         products[
#             [
#                 "product_id",
#                 "price",
#             ]
#         ],
#         on="product_id",
#         how="left",
#     )

#     # Only products actually included in the promotion
#     # should receive the discounted price.
#     promoted_lines = promo_lines[
#         promo_lines["_merge"] == "both"
#     ].copy()

#     expected_price = (
#         promoted_lines["price"]
#         * (
#             1
#             - promoted_lines["discount_percent"]
#             / 100
#         )
#     ).round(2)

#     actual_price = (
#         promoted_lines["price_per_unit"]
#         .round(2)
#     )

#     assert (
#         actual_price == expected_price
#     ).all(), (
#         "Promotional order line prices do not match "
#         "the promotion discount"
#     )

def validate_promotional_prices(data):
    order_items = data["order_items"].copy()
    orders = data["orders"].copy()
    promotions = data["promotions"].copy()
    promotion_items = data["promotion_items"].copy()
    products = data["products"].copy()

    # Only orders that actually used a promotion
    promo_orders = orders[
        orders["used_promotion"] == True
    ][["order_id", "promotion_id"]]

    # Connect order items to their order's promotion
    promo_lines = order_items.merge(
        promo_orders,
        on="order_id",
        how="inner"
    )

    # Connect promotion to the products included in it
    promo_lines = promo_lines.merge(
        promotion_items[
            ["promotion_id", "product_id"]
        ],
        on=["promotion_id", "product_id"],
        how="inner"
    )

    # Get product retail prices
    promo_lines = promo_lines.merge(
        products[
            ["product_id", "price"]
        ],
        on="product_id",
        how="left"
    )

    # Get promotion discount
    promo_lines = promo_lines.merge(
        promotions[
            ["promotion_id", "discount_percent"]
        ],
        on="promotion_id",
        how="left"
    )

    # Calculate expected promotional price
    promo_lines["expected_price"] = (
        promo_lines["price"] *
        (
            1 -
            promo_lines["discount_percent"] / 100
        )
    ).round(2)

    promo_lines["actual_price"] = (
        promo_lines["price_per_unit"]
        .round(2)
    )

    promo_lines["difference"] = (
        promo_lines["actual_price"] -
        promo_lines["expected_price"]
    ).round(2)

    mismatches = promo_lines[
        promo_lines["difference"].abs() > 0.01
    ]

    if not mismatches.empty:
        print("\nPromotional price mismatches:")
        print(
            mismatches[
                [
                    "order_id",
                    "promotion_id",
                    "product_id",
                    "price",
                    "discount_percent",
                    "expected_price",
                    "actual_price",
                    "difference",
                ]
            ]
            .head(20)
            .to_string(index=False)
        )

        print(
            f"\nTotal promotional price mismatches: "
            f"{len(mismatches)}"
        )

    assert mismatches.empty, (
        "Promotional order line prices do not match "
        "the promotion discount"
    )


# ============================================================
# 17. GENERAL MONEY VALIDATION
# ============================================================

def validate_money(data):

    money_columns = {
        "products": [
            "price",
            "cost",
        ],
        "orders": [
            "total_price",
        ],
        "order_items": [
            "price_per_unit",
        ],
        "supplier_products": [
            "price_per_unit",
        ],
        "returns": [
            "refund_amount",
        ],
    }

    for table_name, columns in money_columns.items():

        df = data[table_name]

        for column in columns:

            # Check that values have no more than two decimal places.
            rounded = df[column].round(2)

            assert (
                (df[column] - rounded).abs() < 0.000001
            ).all(), (
                f"{table_name}.{column} contains "
                "values with more than two decimal places"
            )


# ============================================================
# RUN ALL VALIDATIONS
# ============================================================

def run_all_validations():

    print("Starting validation...\n")

    validations = [
        ("Row counts", lambda: validate_row_counts(data)),
        ("Primary keys", lambda: validate_primary_keys(data)),
        ("Required fields", lambda: validate_required_fields(data)),
        ("Foreign keys", lambda: validate_foreign_keys(data)),
        ("Customers", lambda: validate_customers(data)),
        ("Products", lambda: validate_products(data)),
        (
            "Supplier products",
            lambda: validate_supplier_products(data),
        ),
        (
            "Promotions",
            lambda: validate_promotions(data),
        ),
        (
            "Orders",
            lambda: validate_orders(data),
        ),
        (
            "Order items",
            lambda: validate_order_items(data),
        ),
        (
            "Order totals",
            lambda: validate_order_totals(data),
        ),
        (
            "Payments",
            lambda: validate_payments(data),
        ),
        (
            "Returns",
            lambda: validate_returns(data),
        ),
        (
            "Supplier deliveries",
            lambda: validate_supplier_deliveries(data),
        ),
        (
            "Order promotions",
            lambda: validate_order_promotions(data),
        ),
        (
            "Promotional prices",
            lambda: validate_promotional_prices(data),
        ),
        (
            "Money values",
            lambda: validate_money(data),
        ),
    ]

    for name, validation in validations:

        validation()

        print(f"✓ {name}")

    print("\nAll validations passed!")


if __name__ == "__main__":
    run_all_validations()