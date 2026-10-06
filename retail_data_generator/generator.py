"""
AllGoodsRetail synthetic data generator.

This script generates relational CSVs for the current AllGoodsRetail schema, including a normalized supplier many-to-many relationship.
It intentionally handles the repetitive synthetic-data work so the project
can focus on ETL/data engineering, SQL, validation, analysis, and Power BI.

Run from the retail_data_generator directory:

    python generator.py
"""

from __future__ import annotations

import random
from collections import defaultdict
from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

import numpy as np
import pandas as pd
from faker import Faker

from config import (
    MAX_DISCOUNT_PERCENT,
    MAX_ORDER_ITEMS,
    MAX_PRODUCTS_PER_SUPPLIER,
    MAX_QUANTITY_PER_ITEM,
    MIN_ORDER_ITEMS,
    MIN_QUANTITY_PER_ITEM,
    MEMBERSHIP_RATE,
    MIN_DISCOUNT_PERCENT,
    N_AISLES,
    N_PRODUCT_CATEGORIES,
    N_CUSTOMERS,
    N_ORDERS,
    N_PRODUCTS,
    N_PROMOTIONS,
    N_SUPPLIERS,
    OUTPUT_DIR,
    PAYMENT_TYPES,
    PROJECT_END_DATE,
    PROJECT_START_DATE,
    PROMOTION_USE_RATE,
    RETURN_RATE,
    SEED,
)

# ---------------------------------------------------------------------------
# Reproducibility
# ---------------------------------------------------------------------------

random.seed(SEED)
np.random.seed(SEED)

fake = Faker()
Faker.seed(SEED)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def money(value: float | Decimal) -> float:
    """Round a monetary value to two decimal places."""
    return float(
        Decimal(str(value)).quantize(
            Decimal("0.01"),
            rounding=ROUND_HALF_UP,
        )
    )


def random_datetime(
    start: datetime,
    end: datetime,
    start_hour: int | None = None,
    end_hour: int | None = None,
) -> datetime:
    """Return a random datetime between start and end."""
    if start > end:
        raise ValueError("Start datetime cannot be after end datetime.")

    start_seconds = int((start - PROJECT_START_DATE).total_seconds())
    end_seconds = int((end - PROJECT_START_DATE).total_seconds())

    offset = random.randint(start_seconds, end_seconds)
    result = PROJECT_START_DATE + timedelta(seconds=offset)

    if start_hour is not None and end_hour is not None:
        result = result.replace(
            hour=random.randint(start_hour, end_hour),
            minute=random.randint(0, 59),
            second=random.randint(0, 59),
            microsecond=0,
        )

    return result


def random_date_only(start: datetime, end: datetime) -> datetime:
    """Return a random date between two datetimes."""
    days = (end.date() - start.date()).days
    return datetime.combine(
        start.date() + timedelta(days=random.randint(0, days)),
        datetime.min.time(),
    )


def choose_weighted(values, weights):
    """Choose one value using a list of relative weights."""
    return random.choices(values, weights=weights, k=1)[0]


# ---------------------------------------------------------------------------
# Product categories
# ---------------------------------------------------------------------------

CATEGORY_SPECS = [
    ("CAT_001", "Fresh Produce", "Fresh fruits and vegetables.", "produce"),
    ("CAT_002", "Meat", "Fresh and packaged meat products.", "food"),
    ("CAT_003", "Seafood", "Fresh and frozen seafood.", "food"),
    ("CAT_004", "Dairy", "Milk, cheese, yogurt, and related products.", "food"),
    ("CAT_005", "Bakery", "Bread, pastries, and baked goods.", "food"),
    ("CAT_006", "Frozen Foods", "Frozen meals, vegetables, and desserts.", "freezer"),
    ("CAT_007", "Canned Goods", "Shelf-stable canned foods.", "food"),
    ("CAT_008", "Snacks", "Chips, crackers, bars, and snack foods.", "food"),
    ("CAT_009", "Breakfast Foods", "Cereal, oatmeal, and breakfast products.", "food"),
    ("CAT_010", "Condiments", "Sauces, dressings, and spreads.", "food"),
    ("CAT_011", "Pasta & Grains", "Pasta, rice, and grain products.", "food"),
    ("CAT_012", "Beverages", "Non-alcoholic drinks and beverages.", "drink"),
    ("CAT_013", "Coffee & Tea", "Coffee, tea, and related products.", "drink"),
    ("CAT_014", "Household Cleaning", "Cleaning and household maintenance products.", "nonfood"),
    ("CAT_015", "Paper Products", "Paper towels, tissues, and related products.", "nonfood"),
    ("CAT_016", "Personal Care", "Personal hygiene and care products.", "nonfood"),
    ("CAT_017", "Pet Supplies", "Food and supplies for household pets.", "nonfood"),
    ("CAT_018", "Baby Products", "Baby food, care, and household products.", "nonfood"),
    ("CAT_019", "Frozen Desserts", "Ice cream, frozen treats, and desserts.", "freezer"),
    ("CAT_020", "Prepared Foods", "Ready-to-eat and ready-to-heat foods.", "food"),
]


def generate_product_categories() -> pd.DataFrame:
    """Generate Product_Categories."""
    rows = []

    for category_id, name, description, _ in CATEGORY_SPECS[:N_PRODUCT_CATEGORIES]:
        rows.append(
            {
                "product_category_id": category_id,
                "name": name,
                "description": description,
            }
        )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Aisles
# ---------------------------------------------------------------------------

AISLE_SPECS = [
    ("AIS_001", 1, True, False, True, False),
    ("AIS_002", 2, True, False, True, False),
    ("AIS_003", 3, True, False, True, False),
    ("AIS_004", 4, False, False, True, False),
    ("AIS_005", 5, False, False, True, False),
    ("AIS_006", 6, False, False, True, False),
    ("AIS_007", 7, False, False, True, False),
    ("AIS_008", 8, False, False, True, False),
    ("AIS_009", 9, False, False, True, False),
    ("AIS_010", 10, False, False, True, False),
    ("AIS_011", 11, False, False, True, False),
    ("AIS_012", 12, False, False, True, False),
    ("AIS_013", 13, False, False, True, False),
    ("AIS_014", 14, False, False, True, False),
    ("AIS_015", 15, False, False, True, False),
    ("AIS_016", 16, False, False, True, False),
    ("AIS_017", 17, False, True, True, False),
    ("AIS_018", 18, False, True, True, False),
    ("AIS_019", 19, False, True, True, False),
    ("AIS_020", 20, False, True, True, False),
    ("AIS_021", 21, False, True, True, False),
    ("AIS_022", 22, False, False, False, True),
    ("AIS_023", 23, False, False, False, True),
    ("AIS_024", 24, False, False, False, True),
    ("AIS_025", 25, False, False, False, True),
    ("AIS_026", 26, False, False, False, True),
    ("AIS_027", 27, False, False, False, False),
    ("AIS_028", 28, False, False, False, False),
    ("AIS_029", 29, False, False, False, False),
    ("AIS_030", 30, False, False, False, False),
]


def generate_aisles() -> pd.DataFrame:
    """Generate Aisles."""
    rows = []

    for aisle_id, aisle_number, is_produce, is_freezer, is_food, is_drink in AISLE_SPECS[:N_AISLES]:
        rows.append(
            {
                "aisle_id": aisle_id,
                "aisle_number": aisle_number,
                "is_produce": is_produce,
                "is_freezer": is_freezer,
                "is_food": is_food,
                "is_drink": is_drink,
            }
        )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Products
# ---------------------------------------------------------------------------

PRODUCT_NAMES = {
    "Fresh Produce": [
        "Bananas", "Gala Apples", "Fuji Apples", "Navel Oranges",
        "Avocados", "Strawberries", "Blueberries", "Seedless Grapes",
        "Baby Spinach", "Romaine Lettuce", "Broccoli Crowns",
        "Carrots", "Bell Peppers", "Yellow Onions", "Russet Potatoes",
    ],
    "Meat": [
        "Chicken Breast", "Ground Beef", "Ground Turkey", "Pork Chops",
        "Beef Sirloin", "Chicken Thighs", "Italian Sausage",
        "Turkey Bacon", "Deli Ham", "Deli Turkey", "Beef Roast",
    ],
    "Seafood": [
        "Atlantic Salmon", "Tilapia Fillets", "Shrimp", "Cod Fillets",
        "Tuna Steaks", "Crab Cakes", "Breaded Fish Fillets",
    ],
    "Dairy": [
        "Whole Milk", "2% Milk", "Skim Milk", "Greek Yogurt",
        "Cheddar Cheese", "Mozzarella Cheese", "Butter", "Sour Cream",
        "Cottage Cheese", "Cream Cheese",
    ],
    "Bakery": [
        "White Bread", "Wheat Bread", "Sourdough Bread", "Hamburger Buns",
        "Hot Dog Buns", "Dinner Rolls", "Croissants", "Blueberry Muffins",
        "Bagels", "Tortillas",
    ],
    "Frozen Foods": [
        "Frozen Peas", "Frozen Corn", "Frozen Mixed Vegetables",
        "Frozen Pizza", "Frozen Burritos", "Frozen French Fries",
        "Frozen Chicken Nuggets", "Frozen Lasagna",
    ],
    "Canned Goods": [
        "Black Beans", "Kidney Beans", "Diced Tomatoes", "Tomato Sauce",
        "Chicken Noodle Soup", "Cream of Mushroom Soup", "Canned Corn",
        "Canned Green Beans", "Tuna", "Chickpeas",
    ],
    "Snacks": [
        "Potato Chips", "Tortilla Chips", "Pretzels", "Cheese Crackers",
        "Granola Bars", "Trail Mix", "Popcorn", "Peanut Butter Crackers",
        "Mixed Nuts", "Fruit Snacks",
    ],
    "Breakfast Foods": [
        "Corn Flakes", "Granola", "Oatmeal", "Cheerios",
        "Bran Cereal", "Pancake Mix", "Waffle Mix", "Maple Syrup",
    ],
    "Condiments": [
        "Ketchup", "Yellow Mustard", "Mayonnaise", "Ranch Dressing",
        "Italian Dressing", "Hot Sauce", "Barbecue Sauce", "Soy Sauce",
        "Peanut Butter", "Strawberry Jam",
    ],
    "Pasta & Grains": [
        "Spaghetti", "Penne Pasta", "Macaroni", "Brown Rice",
        "White Rice", "Jasmine Rice", "Quinoa", "Couscous",
        "Whole Wheat Pasta",
    ],
    "Beverages": [
        "Bottled Water", "Sparkling Water", "Cola", "Diet Cola",
        "Lemon Lime Soda", "Orange Soda", "Iced Tea", "Lemonade",
        "Sports Drink", "Energy Drink",
    ],
    "Coffee & Tea": [
        "Ground Coffee", "Coffee Beans", "Instant Coffee",
        "Black Tea", "Green Tea", "Herbal Tea", "Cold Brew Coffee",
        "Hot Cocoa Mix",
    ],
    "Household Cleaning": [
        "Dish Soap", "Laundry Detergent", "All Purpose Cleaner",
        "Glass Cleaner", "Disinfecting Wipes", "Bleach",
        "Dishwasher Pods", "Floor Cleaner",
    ],
    "Paper Products": [
        "Paper Towels", "Toilet Paper", "Facial Tissues",
        "Paper Napkins", "Disposable Plates", "Disposable Cups",
        "Trash Bags",
    ],
    "Personal Care": [
        "Shampoo", "Conditioner", "Body Wash", "Bar Soap",
        "Toothpaste", "Toothbrush", "Deodorant", "Hand Soap",
        "Razors", "Lotion",
    ],
    "Pet Supplies": [
        "Dry Dog Food", "Wet Dog Food", "Dry Cat Food", "Wet Cat Food",
        "Cat Litter", "Dog Treats", "Cat Treats", "Pet Shampoo",
    ],
    "Baby Products": [
        "Baby Diapers", "Baby Wipes", "Baby Formula", "Baby Shampoo",
        "Baby Lotion", "Baby Food Pouches",
    ],
    "Frozen Desserts": [
        "Vanilla Ice Cream", "Chocolate Ice Cream", "Strawberry Ice Cream",
        "Ice Cream Sandwiches", "Frozen Fruit Bars", "Cheesecake Bites",
    ],
    "Prepared Foods": [
        "Rotisserie Chicken", "Macaroni and Cheese", "Potato Salad",
        "Chicken Salad", "Garden Salad", "Deli Pasta Salad",
        "Prepared Sandwich", "Prepared Soup",
    ],
}

CATEGORY_PRICE_RANGES = {
    "Fresh Produce": (1.25, 8.99),
    "Meat": (4.99, 18.99),
    "Seafood": (6.99, 24.99),
    "Dairy": (2.49, 8.99),
    "Bakery": (2.49, 7.99),
    "Frozen Foods": (2.99, 11.99),
    "Canned Goods": (1.25, 5.99),
    "Snacks": (2.49, 8.99),
    "Breakfast Foods": (2.99, 9.99),
    "Condiments": (1.99, 7.99),
    "Pasta & Grains": (1.49, 9.99),
    "Beverages": (1.49, 8.99),
    "Coffee & Tea": (3.99, 14.99),
    "Household Cleaning": (2.99, 12.99),
    "Paper Products": (3.99, 18.99),
    "Personal Care": (2.99, 16.99),
    "Pet Supplies": (4.99, 24.99),
    "Baby Products": (4.99, 29.99),
    "Frozen Desserts": (3.99, 10.99),
    "Prepared Foods": (4.99, 14.99),
}


def _aisles_for_category(category_type: str, aisles: pd.DataFrame) -> list[str]:
    """Return aisle IDs appropriate for a category type."""
    if category_type == "produce":
        mask = aisles["is_produce"]
    elif category_type == "freezer":
        mask = aisles["is_freezer"]
    elif category_type == "drink":
        mask = aisles["is_drink"]
    elif category_type == "food":
        mask = aisles["is_food"] & ~aisles["is_freezer"]
    else:
        mask = ~(
            aisles["is_food"]
            | aisles["is_drink"]
            | aisles["is_produce"]
            | aisles["is_freezer"]
        )

    matches = aisles.loc[mask, "aisle_id"].tolist()
    return matches or aisles["aisle_id"].tolist()


def generate_products(
    product_categories: pd.DataFrame,
    aisles: pd.DataFrame,
) -> pd.DataFrame:
    """Generate Products with category-appropriate aisles, prices, and stock."""
    rows = []
    used_names: set[str] = set()

    category_lookup = {
        row["product_category_id"]: row["name"]
        for _, row in product_categories.iterrows()
    }

    category_type_lookup = {
        category_id: category_type
        for category_id, _, _, category_type in CATEGORY_SPECS
    }

    for i in range(1, N_PRODUCTS + 1):
        category_id = random.choice(list(category_lookup))
        category_name = category_lookup[category_id]
        category_type = category_type_lookup[category_id]

        base_name = random.choice(PRODUCT_NAMES[category_name])
        variants = [
            "8 oz", "12 oz", "16 oz", "24 oz", "32 oz",
            "1 lb", "2 lb", "6 pack", "12 pack", "Family Size",
            "Organic", "Reduced Fat", "Original", "Premium",
        ]

        candidate = f"{base_name} - {random.choice(variants)}"
        counter = 2

        while candidate in used_names:
            candidate = f"{base_name} - {random.choice(variants)} #{counter}"
            counter += 1

        used_names.add(candidate)

        min_price, max_price = CATEGORY_PRICE_RANGES[category_name]
        price = np.random.uniform(min_price, max_price)

        cost_ratio = np.random.uniform(0.55, 0.82)
        cost = price * cost_ratio

        quantity_in_stock = max(
            0,
            int(np.random.lognormal(mean=3.0, sigma=1.0)),
        )

        aisle_id = random.choice(
            _aisles_for_category(category_type, aisles)
        )

        rows.append(
            {
                "product_id": f"PROD_{i:06d}",
                "product_category_id": category_id,
                "aisle_id": aisle_id,
                "name": candidate,
                "price": money(price),
                "in_stock": quantity_in_stock > 0,
                "quantity_in_stock": quantity_in_stock,
                "cost": money(cost),
            }
        )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Customers
# ---------------------------------------------------------------------------

def generate_customers() -> pd.DataFrame:
    """Generate Customers with logically consistent membership dates."""
    rows = []

    project_days = (
        PROJECT_END_DATE.date() - PROJECT_START_DATE.date()
    ).days

    for i in range(1, N_CUSTOMERS + 1):
        member_candidate = random.random() < MEMBERSHIP_RATE

        membership_join_date = None
        membership_cancel_date = None

        if member_candidate:
            join_day = random.randint(0, max(0, project_days - 30))
            membership_join_date = PROJECT_START_DATE + timedelta(days=join_day)

            # Most members remain active; some cancel.
            if random.random() < 0.15:
                remaining_days = (
                    PROJECT_END_DATE.date()
                    - membership_join_date.date()
                ).days

                if remaining_days >= 30:
                    cancel_day = random.randint(30, remaining_days)
                    membership_cancel_date = (
                        membership_join_date + timedelta(days=cancel_day)
                    )

        rows.append(
            {
                "customer_id": f"CUST_{i:06d}",
                "is_member": membership_cancel_date is None and member_candidate,
                "membership_join_date": membership_join_date,
                "membership_cancel_date": membership_cancel_date,
                "full_name": fake.name(),
                "address": fake.address().replace("\n", ", "),
                "phone_number": fake.phone_number(),
            }
        )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Suppliers
# ---------------------------------------------------------------------------

def generate_suppliers() -> pd.DataFrame:
    """Generate supplier entities."""
    supplier_names = [
        "Northstar Foods",
        "Pacific Wholesale",
        "Evergreen Distribution",
        "Summit Supply Co.",
        "Cascadia Merchants",
        "Blue River Supply",
        "Golden Valley Distributors",
        "Horizon Wholesale",
        "Pioneer Supply Group",
        "West Coast Distribution",
    ]

    rows = []

    for i in range(1, N_SUPPLIERS + 1):
        if i <= len(supplier_names):
            name = supplier_names[i - 1]
        else:
            name = f"{fake.company()} Supply"

        rows.append(
            {
                "supplier_id": f"SUP_{i:05d}",
                "name": name,
            }
        )

    return pd.DataFrame(rows)


def generate_supplier_products(
    products: pd.DataFrame,
    suppliers: pd.DataFrame,
) -> pd.DataFrame:
    """
    Generate the many-to-many relationship between suppliers and products.

    Every product receives at least one supplier, while no supplier supplies
    more than MAX_PRODUCTS_PER_SUPPLIER products.
    """
    product_ids = products["product_id"].tolist()
    supplier_ids = suppliers["supplier_id"].tolist()

    required_capacity = len(product_ids)
    available_capacity = len(supplier_ids) * MAX_PRODUCTS_PER_SUPPLIER

    if available_capacity < required_capacity:
        raise ValueError(
            "Not enough supplier capacity to give every product at least "
            f"one supplier. Products={len(product_ids)}, "
            f"suppliers={len(supplier_ids)}, "
            f"max_products_per_supplier={MAX_PRODUCTS_PER_SUPPLIER}."
        )

    product_lookup = products.set_index("product_id")

    # Assign products across suppliers in a shuffled round-robin. This
    # guarantees every product gets at least one supplier before any
    # additional relationships are considered.
    shuffled_products = product_ids.copy()
    random.shuffle(shuffled_products)

    supplier_load = {supplier_id: 0 for supplier_id in supplier_ids}
    assignments = []

    for index, product_id in enumerate(shuffled_products):
        supplier_id = supplier_ids[index % len(supplier_ids)]
        supplier_load[supplier_id] += 1
        assignments.append((supplier_id, product_id))

    # Add additional supplier relationships where capacity remains.
    # This creates a true many-to-many relationship rather than making every
    # product have exactly one supplier.
    remaining_products = [
        product_id
        for product_id in product_ids
        if sum(1 for _, p_id in assignments if p_id == product_id) == 1
    ]

    random.shuffle(remaining_products)

    for product_id in remaining_products:
        eligible_suppliers = [
            supplier_id
            for supplier_id in supplier_ids
            if supplier_load[supplier_id] < MAX_PRODUCTS_PER_SUPPLIER
            and (supplier_id, product_id) not in assignments
        ]

        if not eligible_suppliers:
            break

        # Only add an additional relationship some of the time.
        if random.random() > 0.30:
            continue

        supplier_id = random.choice(eligible_suppliers)
        supplier_load[supplier_id] += 1
        assignments.append((supplier_id, product_id))

    rows = []

    for supplier_id, product_id in assignments:
        product = product_lookup.loc[product_id]

        rows.append(
            {
                "supplier_product_id": f"SUPPROD_{len(rows) + 1:08d}",
                "supplier_id": supplier_id,
                "product_id": product_id,
                "price_per_unit": money(product["cost"]),
                "delivery_occurrence": choose_weighted(
                    ["Weekly", "Biweekly", "Monthly", "As Needed"],
                    [0.30, 0.30, 0.25, 0.15],
                ),
            }
        )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Promotions
# ---------------------------------------------------------------------------

def generate_promotions() -> pd.DataFrame:
    """Generate promotions with weighted discounts and valid date ranges."""
    rows = []

    project_days = (
        PROJECT_END_DATE.date() - PROJECT_START_DATE.date()
    ).days

    for i in range(1, N_PROMOTIONS + 1):
        start_day = random.randint(0, max(0, project_days - 14))
        start_date = PROJECT_START_DATE + timedelta(days=start_day)

        duration_days = random.randint(7, 60)
        end_date = min(
            start_date + timedelta(days=duration_days),
            PROJECT_END_DATE,
        )

        # Beta distribution favors smaller discounts.
        discount = (
            MIN_DISCOUNT_PERCENT
            + np.random.beta(2, 5)
            * (MAX_DISCOUNT_PERCENT - MIN_DISCOUNT_PERCENT)
        )

        rows.append(
            {
                "promotion_id": f"PROMO_{i:05d}",
                "name": f"Member Promotion {i:03d}",
                "description": "Member-only promotional discount.",
                "discount_percent": round(float(discount), 2),
                "promotion_start_date": start_date,
                "promotion_end_date": end_date,
                # Reference date = end of the project period.
                "is_active": start_date <= PROJECT_END_DATE <= end_date,
            }
        )

    return pd.DataFrame(rows)


def generate_promotion_items(
    promotions: pd.DataFrame,
    products: pd.DataFrame,
) -> pd.DataFrame:
    """
    Assign products to promotions.

    A product can participate in multiple promotions, but overlapping
    promotion periods for the same product are avoided.
    """
    rows = []
    product_intervals: dict[str, list[tuple[datetime, datetime]]] = defaultdict(list)
    product_ids = products["product_id"].tolist()

    for _, promotion in promotions.iterrows():
        desired_count = random.randint(
            5,
            min(25, len(product_ids)),
        )

        candidates = random.sample(product_ids, desired_count)

        for product_id in candidates:
            start = promotion["promotion_start_date"]
            end = promotion["promotion_end_date"]

            overlaps = any(
                start <= existing_end and end >= existing_start
                for existing_start, existing_end in product_intervals[product_id]
            )

            if overlaps:
                continue

            rows.append(
                {
                    "promotion_item_id": f"PROMO_ITEM_{len(rows) + 1:07d}",
                    "promotion_id": promotion["promotion_id"],
                    "product_id": product_id,
                }
            )

            product_intervals[product_id].append((start, end))

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Orders and order items
# ---------------------------------------------------------------------------

def _membership_status_at_order(
    customer: pd.Series,
    order_datetime: datetime,
) -> bool:
    """Return membership status at the time an order is placed."""
    join_date = customer["membership_join_date"]
    cancel_date = customer["membership_cancel_date"]

    if pd.isna(join_date):
        return False

    if order_datetime < join_date:
        return False

    if pd.notna(cancel_date) and order_datetime > cancel_date:
        return False

    return True


def _customer_order_window(customer: pd.Series) -> tuple[datetime, datetime]:
    """
    Return the valid order window for a customer.

    Customers who become members do not receive generated orders before their
    membership join date. This keeps the current membership business rule
    straightforward for the first version of the project.
    """
    join_date = customer["membership_join_date"]

    if pd.notna(join_date):
        return join_date, PROJECT_END_DATE

    return PROJECT_START_DATE, PROJECT_END_DATE


def _build_promotion_lookup(
    promotions: pd.DataFrame,
    promotion_items: pd.DataFrame,
):
    """Build product -> promotions and promotion -> products lookups."""
    promotion_dates = {
        row["promotion_id"]: (
            row["promotion_start_date"],
            row["promotion_end_date"],
            row["discount_percent"],
        )
        for _, row in promotions.iterrows()
    }

    promotion_products: dict[str, set[str]] = defaultdict(set)
    product_promotions: dict[str, set[str]] = defaultdict(set)

    for _, row in promotion_items.iterrows():
        promotion_products[row["promotion_id"]].add(row["product_id"])
        product_promotions[row["product_id"]].add(row["promotion_id"])

    return promotion_dates, promotion_products, product_promotions


def generate_orders_and_items(
    customers: pd.DataFrame,
    products: pd.DataFrame,
    promotions: pd.DataFrame,
    promotion_items: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """
    Generate Orders and Order_Items together.

    Orders.total_price depends on the actual line-level prices, so these two
    tables are intentionally generated in the same function.
    """
    promotion_dates, promotion_products, product_promotions = _build_promotion_lookup(
        promotions,
        promotion_items,
    )

    customer_records = list(customers.to_dict("records"))
    product_records = list(products.to_dict("records"))

    product_lookup = {
        p["product_id"]: p
        for p in product_records
    }

    product_ids = [p["product_id"] for p in product_records]

    # Non-uniform product popularity.
    product_weights = np.random.lognormal(
        mean=0.0,
        sigma=1.0,
        size=len(product_ids),
    )
    product_weights = product_weights / product_weights.sum()

    orders = []
    order_items = []

    for order_number in range(1, N_ORDERS + 1):
        customer = random.choice(customer_records)

        order_start, order_end = _customer_order_window(
            pd.Series(customer)
        )

        order_datetime = random_datetime(
            order_start,
            order_end,
            start_hour=6,
            end_hour=23,
        )

        customer_member = _membership_status_at_order(
            pd.Series(customer),
            order_datetime,
        )

        item_count = random.randint(
            MIN_ORDER_ITEMS,
            min(MAX_ORDER_ITEMS, len(product_ids)),
        )

        selected_product_ids = list(
            np.random.choice(
                product_ids,
                size=item_count,
                replace=False,
                p=product_weights,
            )
        )

        # Find promotions that are active and apply to at least one product
        # already in the customer's cart.
        eligible_promotions = set()

        for product_id in selected_product_ids:
            for promotion_id in product_promotions.get(product_id, set()):
                start, end, _ = promotion_dates[promotion_id]

                if start <= order_datetime <= end:
                    eligible_promotions.add(promotion_id)

        used_promotion = (
            customer_member
            and bool(eligible_promotions)
            and random.random() < PROMOTION_USE_RATE
        )

        selected_promotion = (
            random.choice(list(eligible_promotions))
            if used_promotion
            else None
        )

        order_id = f"ORDER_{order_number:08d}"
        order_total = Decimal("0.00")

        for product_id in selected_product_ids:
            product = product_lookup[product_id]

            quantity = random.randint(
                MIN_QUANTITY_PER_ITEM,
                MAX_QUANTITY_PER_ITEM,
            )

            price = Decimal(str(product["price"]))

            if (
                selected_promotion
                and product_id in promotion_products[selected_promotion]
            ):
                discount_percent = Decimal(
                    str(promotion_dates[selected_promotion][2])
                )

                price = price * (
                    Decimal("1.00")
                    - discount_percent / Decimal("100")
                )

            price = price.quantize(
                Decimal("0.01"),
                rounding=ROUND_HALF_UP,
            )

            order_total += price * quantity

            order_items.append(
                {
                    "order_item_id": f"ORDER_ITEM_{len(order_items) + 1:09d}",
                    "order_id": order_id,
                    "product_id": product_id,
                    "quantity": quantity,
                    "price_per_unit": float(price),
                }
            )

        orders.append(
            {
                "order_id": order_id,
                "customer_id": customer["customer_id"],
                "total_price": money(order_total),
                "order_date": order_datetime,
                "used_promotion": used_promotion,
                "promotion_id": selected_promotion,
                "is_member": customer_member,
            }
        )


    return pd.DataFrame(orders), pd.DataFrame(order_items)


# ---------------------------------------------------------------------------
# Payments
# ---------------------------------------------------------------------------

def generate_payments(orders: pd.DataFrame) -> pd.DataFrame:
    """Generate exactly one payment for each order."""
    rows = []

    for i, order in enumerate(orders.to_dict("records"), start=1):
        payment_date = order["order_date"] + timedelta(
            minutes=random.randint(0, 15)
        )

        rows.append(
            {
                "payment_id": f"PAY_{i:08d}",
                "customer_id": order["customer_id"],
                "order_id": order["order_id"],
                "payment_type": random.choice(PAYMENT_TYPES),
                "payment_date": payment_date,
            }
        )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Returns
# ---------------------------------------------------------------------------

RETURN_RATES_BY_CATEGORY_TYPE = {
    "produce": 0.03,
    "freezer": 0.05,
    "food": 0.07,
    "drink": 0.04,
    "nonfood": 0.09,
}


def generate_returns(
    orders: pd.DataFrame,
    order_items: pd.DataFrame,
    payments: pd.DataFrame,
    products: pd.DataFrame,
) -> pd.DataFrame:
    """
    Generate returns at the order-item level.

    At most one return is generated for an order item. Therefore the returned
    quantity cannot exceed the purchased quantity or require multiple return
    transactions for the same item.
    """
    columns = [
        "return_id",
        "order_id",
        "customer_id",
        "order_item_id",
        "payment_id",
        "quantity_returned",
        "refund_amount",
    ]

    if order_items.empty:
        return pd.DataFrame(columns=columns)

    category_type_lookup = {
        category_id: category_type
        for category_id, _, _, category_type in CATEGORY_SPECS
    }

    product_lookup = products.set_index("product_id")
    order_lookup = orders.set_index("order_id")
    payment_lookup = payments.set_index("order_id")

    rows = []

    for item in order_items.to_dict("records"):
        product = product_lookup.loc[item["product_id"]]

        category_type = category_type_lookup[
            product["product_category_id"]
        ]

        probability = min(
            RETURN_RATE * (
                RETURN_RATES_BY_CATEGORY_TYPE[category_type] / 0.07
            ),
            0.50,
        )

        if random.random() >= probability:
            continue

        quantity_returned = random.randint(
            1,
            item["quantity"],
        )

        refund_amount = money(
            quantity_returned * item["price_per_unit"]
        )

        order_id = item["order_id"]
        order = order_lookup.loc[order_id]
        payment = payment_lookup.loc[order_id]

        rows.append(
            {
                "return_id": f"RETURN_{len(rows) + 1:08d}",
                "order_id": order_id,
                "customer_id": order["customer_id"],
                "order_item_id": item["order_item_id"],
                "payment_id": payment["payment_id"],
                "quantity_returned": quantity_returned,
                "refund_amount": refund_amount,
            }
        )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Supplier deliveries
# ---------------------------------------------------------------------------

def generate_supplier_deliveries(
    supplier_products: pd.DataFrame,
) -> pd.DataFrame:
    """Generate supplier deliveries based on each supplier-product frequency."""
    rows = []

    frequency_days = {
        "Weekly": 7,
        "Biweekly": 14,
        "Monthly": 30,
    }

    for supplier_product in supplier_products.to_dict("records"):
        occurrence = supplier_product["delivery_occurrence"]

        if occurrence == "As Needed":
            delivery_count = random.randint(5, 20)

            delivery_dates = sorted(
                random_date_only(
                    PROJECT_START_DATE,
                    PROJECT_END_DATE,
                )
                for _ in range(delivery_count)
            )
        else:
            interval = frequency_days[occurrence]

            start_offset = random.randint(0, interval - 1)
            current = PROJECT_START_DATE + timedelta(days=start_offset)

            delivery_dates = []

            while current <= PROJECT_END_DATE:
                delivery_dates.append(current)
                current += timedelta(days=interval)

        for delivery_date in delivery_dates:
            rows.append(
                {
                    "delivery_id": f"DELIVERY_{len(rows) + 1:08d}",
                    "supplier_product_id": supplier_product["supplier_product_id"],
                    "delivery_date": delivery_date,
                    "quantity": random.randint(20, 250),
                }
            )

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# Save
# ---------------------------------------------------------------------------

def save_data(dataframes: dict[str, pd.DataFrame]) -> None:
    """Write each generated table to a CSV file."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for table_name, dataframe in dataframes.items():
        output_path = OUTPUT_DIR / f"{table_name}.csv"

        dataframe.to_csv(
            output_path,
            index=False,
        )

        print(
            f"Saved {table_name:<22} "
            f"{len(dataframe):>10,} rows -> {output_path}"
        )


# ---------------------------------------------------------------------------
# Main pipeline
# ---------------------------------------------------------------------------

def main() -> None:
    """Generate all tables in dependency order."""
    print("Starting AllGoodsRetail data generation...")
    print(
        f"Project period: "
        f"{PROJECT_START_DATE.date()} to {PROJECT_END_DATE.date()}"
    )
    print(f"Random seed: {SEED}")
    print()

    # Reference tables
    product_categories = generate_product_categories()
    aisles = generate_aisles()

    # Products and suppliers
    products = generate_products(
        product_categories,
        aisles,
    )

    suppliers = generate_suppliers()

    supplier_products = generate_supplier_products(
        products,
        suppliers,
    )

    # Promotions
    promotions = generate_promotions()

    promotion_items = generate_promotion_items(
        promotions,
        products,
    )

    # Customers
    customers = generate_customers()

    # Transactions
    orders, order_items = generate_orders_and_items(
        customers,
        products,
        promotions,
        promotion_items,
    )

    payments = generate_payments(
        orders,
    )

    returns = generate_returns(
        orders,
        order_items,
        payments,
        products,
    )

    supplier_deliveries = generate_supplier_deliveries(
        supplier_products,
    )

    dataframes = {
        "customers": customers,
        "products": products,
        "product_categories": product_categories,
        "aisles": aisles,
        "promotions": promotions,
        "promotion_items": promotion_items,
        "orders": orders,
        "order_items": order_items,
        "payments": payments,
        "returns": returns,
        "suppliers": suppliers,
        "supplier_products": supplier_products,
        "supplier_deliveries": supplier_deliveries,
    }

    save_data(dataframes)

    print()
    print("Generation complete.")


if __name__ == "__main__":
    main()
