from pathlib import Path
from datetime import datetime


# --------------------------------------------------
# Project
# --------------------------------------------------

SEED = 42

PROJECT_START_DATE = datetime(2021, 1, 1)
PROJECT_END_DATE = datetime(2025, 12, 31)


# --------------------------------------------------
# Output
# --------------------------------------------------

OUTPUT_DIR = Path(__file__).parent / "output"


# --------------------------------------------------
# Number of records
# --------------------------------------------------

N_CUSTOMERS = 10_000
N_PRODUCTS = 1_000
N_PRODUCT_CATEGORIES = 20
N_AISLES = 30
N_PROMOTIONS = 200
N_SUPPLIERS = 120
N_ORDERS = 100_000


# --------------------------------------------------
# Generation probabilities
# --------------------------------------------------

MEMBERSHIP_RATE = 0.60

PROMOTION_USE_RATE = 0.70

RETURN_RATE = 0.08


# --------------------------------------------------
# Business constraints
# --------------------------------------------------

MIN_ORDER_ITEMS = 1
MAX_ORDER_ITEMS = 10

MIN_QUANTITY_PER_ITEM = 1
MAX_QUANTITY_PER_ITEM = 5

MAX_PRODUCTS_PER_SUPPLIER = 10


# --------------------------------------------------
# Promotion constraints
# --------------------------------------------------

MIN_DISCOUNT_PERCENT = 5
MAX_DISCOUNT_PERCENT = 75


# --------------------------------------------------
# Payment types
# --------------------------------------------------

PAYMENT_TYPES = [
    "Credit Card",
    "Debit Card",
    "Cash",
    "Gift Card",
]