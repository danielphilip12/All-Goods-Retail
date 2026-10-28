import random
import unittest
from datetime import datetime, timedelta
from unittest.mock import patch

import numpy as np
import pandas as pd

import generator
from config import PROJECT_END_DATE, PROJECT_START_DATE, SEED


class RandomDatetimeTests(unittest.TestCase):
    def test_datetime_stays_inside_bounds_and_allowed_hours(self):
        start = datetime(2021, 1, 1, 22, 30)
        end = datetime(2021, 1, 3, 1, 0)

        random.seed(SEED)
        result = generator.random_datetime(
            start,
            end,
            start_hour=6,
            end_hour=23,
        )

        self.assertGreaterEqual(result, start)
        self.assertLessEqual(result, end)
        self.assertIn(result.hour, range(6, 24))

    def test_falls_back_to_bounded_time_when_no_allowed_hour_is_possible(self):
        start = datetime(2021, 1, 1, 1, 0)
        end = datetime(2021, 1, 1, 5, 59, 59)

        result = generator.random_datetime(
            start,
            end,
            start_hour=6,
            end_hour=23,
        )

        self.assertGreaterEqual(result, start)
        self.assertLessEqual(result, end)
        self.assertLess(result.hour, 6)

    def test_datetime_is_clamped_to_project_period(self):
        random.seed(SEED)
        result = generator.random_datetime(
            PROJECT_START_DATE - timedelta(days=2),
            PROJECT_END_DATE + timedelta(days=2),
            start_hour=6,
            end_hour=23,
        )

        self.assertGreaterEqual(result, PROJECT_START_DATE)
        self.assertLessEqual(result, PROJECT_END_DATE)


class OrderGenerationTests(unittest.TestCase):
    def setUp(self):
        self.customers = pd.DataFrame(
            [
                {
                    "customer_id": "CUST_1",
                    "membership_join_date": datetime(2024, 1, 1),
                    "membership_cancel_date": pd.NaT,
                },
                {
                    "customer_id": "CUST_2",
                    "membership_join_date": pd.NaT,
                    "membership_cancel_date": pd.NaT,
                },
                {
                    "customer_id": "CUST_3",
                    "membership_join_date": datetime(2021, 1, 1),
                    "membership_cancel_date": datetime(2022, 1, 1),
                },
            ]
        )
        self.products = pd.DataFrame(
            [
                {"product_id": f"PROD_{i}", "price": 2.50 + i}
                for i in range(1, 6)
            ]
        )
        self.promotions = pd.DataFrame(
            columns=[
                "promotion_id",
                "promotion_start_date",
                "promotion_end_date",
                "discount_percent",
            ]
        )
        self.promotion_items = pd.DataFrame(
            columns=["promotion_id", "product_id"]
        )

    def generate_orders(self):
        random.seed(SEED)
        np.random.seed(SEED)
        with patch.object(generator, "N_ORDERS", 300):
            return generator.generate_orders_and_items(
                self.customers,
                self.products,
                self.promotions,
                self.promotion_items,
            )

    def test_orders_use_full_period_and_membership_at_order_time(self):
        for customer in self.customers.to_dict("records"):
            self.assertEqual(
                generator._customer_order_window(pd.Series(customer)),
                (PROJECT_START_DATE, PROJECT_END_DATE),
            )

        orders, _ = self.generate_orders()

        self.assertEqual(len(orders), 300)
        self.assertGreaterEqual(orders["order_date"].min(), PROJECT_START_DATE)
        self.assertLessEqual(orders["order_date"].max(), PROJECT_END_DATE)

        customer_dates = self.customers.set_index("customer_id")
        for order in orders.to_dict("records"):
            customer = customer_dates.loc[order["customer_id"]]
            expected_status = generator._membership_status_at_order(
                customer,
                order["order_date"],
            )
            self.assertEqual(order["is_member"], expected_status)

        joined_customer_orders = orders[
            orders["customer_id"] == "CUST_1"
        ]
        pre_join_orders = joined_customer_orders[
            joined_customer_orders["order_date"]
            < datetime(2024, 1, 1)
        ]
        self.assertFalse(pre_join_orders.empty)
        self.assertFalse(pre_join_orders["is_member"].any())

        post_join_orders = joined_customer_orders[
            joined_customer_orders["order_date"]
            >= datetime(2024, 1, 1)
        ]
        self.assertFalse(post_join_orders.empty)
        self.assertTrue(post_join_orders["is_member"].all())

    def test_order_generation_is_reproducible_with_configured_seed(self):
        first_run = self.generate_orders()
        second_run = self.generate_orders()

        for first, second in zip(first_run, second_run):
            pd.testing.assert_frame_equal(first, second)


if __name__ == "__main__":
    unittest.main()
