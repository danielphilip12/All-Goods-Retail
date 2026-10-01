# Synthetic Retail Dataset — Business & Generation Rules

## Project Scope

This dataset represents a fictional brick-and-mortar retail business.
Orders occur between January 1, 2021 and December 31, 2025.

The dataset is designed to simulate realistic retail transactions,
customers, products, promotions, suppliers, deliveries, payments, and returns.

---

# Customers

1. Each customer has a unique `customer_id`.

2. Customers can exist without being members.

3. If `is_member = false`:
   - `membership_join_date` must be NULL.
   - `membership_cancel_date` must be NULL.

4. If `is_member = true`:
   - `membership_join_date` must exist.
   - `membership_cancel_date` must be NULL while the membership is active.

5. A membership cancellation date cannot occur before the membership join date.

6. Membership join dates must occur before or on the customer's first order date.

7. Some customers should join the membership program after their initial
   customer creation date.

8. Customer IDs must be unique.

---

# Product Categories

9. Each product belongs to exactly one product category.

10. Product category names must be unique.

11. Each product category should contain multiple products.

---

# Aisles

12. Each product belongs to exactly one aisle.

13. Aisles should have realistic classifications.

14. Product categories should generally correspond to appropriate aisles.

15. Example relationships:
    - Produce products → produce aisles.
    - Frozen products → freezer aisles.
    - Beverages → drink aisles.
    - Food products → food aisles.

16. Aisle IDs and aisle numbers must be unique.

---

# Products

17. Each product has a unique `product_id`.

18. Every product belongs to exactly one product category.

19. Every product belongs to exactly one aisle.

20. Product prices must be greater than zero.

21. Product costs must be greater than zero.

22. Product cost should normally be lower than the retail price.

23. `quantity_in_stock` cannot be negative.

24. `in_stock = true` when `quantity_in_stock > 0`.

25. `in_stock = false` when `quantity_in_stock = 0`.

26. Products can have multiple suppliers.

27. Product names should be realistic for their product category.

---

# Suppliers

28. Each supplier has a unique `supplier_id`.

29. A supplier can supply multiple products.

30. A product can be supplied by multiple suppliers.

31. A supplier may supply no more than five products.

32. A supplier's `price_per_unit` represents the supplier's cost to the retailer.

33. Supplier price should normally be lower than the product's retail price.

34. A supplier-product relationship must exist before that supplier can deliver
    that product.

35. `delivery_occurrence` should represent a realistic delivery pattern,
    such as:
    - Weekly
    - Biweekly
    - Monthly
    - As Needed

---

# Supplier Deliveries

36. Every delivery has a unique `delivery_id`.

37. Every delivery must reference an existing supplier.

38. Every delivery must reference a product supplied by that supplier.

39. Delivery quantity must be greater than zero.

40. Delivery dates must fall within the project period.

41. Multiple deliveries can occur for the same supplier/product combination.

42. Delivery frequency should vary between suppliers.

---

# Promotions

43. Each promotion has a unique `promotion_id`.

44. Promotion start dates must occur before promotion end dates.

45. Promotion discounts must be greater than 0%.

46. Promotion discounts cannot exceed 75%.

47. Discount percentages should be weighted toward smaller discounts rather
    than uniformly distributed.

48. A promotion can apply to multiple products.

49. A product can participate in multiple promotions.

50. The same product should not have overlapping promotions unless the
    generation rules explicitly allow them.

51. Promotions are available only to members.

52. A promotion can only be used during its active date range.

53. A promotion can only be applied to products included in
    `Promotion_Items`.

54. `is_active` should correspond to whether the promotion is active relative
    to the dataset's reference date.

---

# Promotion Items

55. Every promotion item has a unique `promotion_item_id`.

56. Every promotion item must reference an existing promotion.

57. Every promotion item must reference an existing product.

58. A product should not be assigned to the same promotion more than once.

---

# Orders

59. Each order has a unique `order_id`.

60. Every order belongs to exactly one customer.

61. Orders must occur between:

    January 1, 2021 00:00:00
    and
    December 31, 2025 23:59:59

62. Orders must occur between 6:00 AM and 11:00 PM.

63. Orders represent in-person purchases. No online orders are included.

64. Every order must contain at least one order item.

65. `is_member` represents the customer's membership status at the time
    the order was placed, rather than their current membership status.

66. A non-member cannot use a promotion.

67. A member may use a promotion when an eligible promotion is available.

68. Promotion usage should be probabilistic rather than guaranteed.

69. If an order uses a promotion:
    - `used_promotion = true`
    - `promotion_id` must contain the promotion used.

70. If an order does not use a promotion:
    - `used_promotion = false`
    - `promotion_id = NULL`.

71. A promotion can only be used if:
    - The customer was a member at the time of purchase.
    - The order date falls within the promotion's active period.
    - The promoted product is included in the promotion.

72. `total_price` must equal the sum of all order-item quantities multiplied
    by their actual price per unit.

---

# Order Items

73. Each order item has a unique `order_item_id`.

74. Every order item must reference an existing order.

75. Every order item must reference an existing product.

76. Quantity must be greater than zero.

77. `price_per_unit` represents the actual price paid by the customer.

78. If no promotion applies, the order-item price should equal the product's
    applicable retail price at the time of purchase.

79. If a promotion applies, the order-item price should reflect the
    applicable promotion discount.

80. Historical order-item prices should not change when a product's current
    price changes.

81. An order can contain multiple products.

82. The same product may appear only once within an individual order unless
    there is a specific business reason to allow multiple line items.

---

# Payments

83. Each payment has a unique `payment_id`.

84. Every payment must reference an existing order.

85. Every payment must reference the same customer associated with the order.

86. Every order must have at least one payment.

87. Payment dates cannot occur before the order date.

88. Payment dates should normally occur on the same day as the order.

89. Payment types should be limited to realistic methods such as:
    - Credit Card
    - Debit Card
    - Cash
    - Gift Card

---

# Returns

90. Each return has a unique `return_id`.

91. Every return must reference an existing order.

92. Every return must reference an existing order item from that order.

93. Every return must reference the payment associated with that order.

94. The customer associated with the return must match the customer who
    placed the original order.

95. Quantity returned must be greater than zero.

96. Quantity returned cannot exceed the quantity originally purchased,
    accounting for previous returns.

97. Refund amount must be greater than zero.

98. Refund amount cannot exceed the amount originally paid for the
    returned quantity.

99. Not every order should have a return.

100. Return frequency should vary by product category.

---

# General Data Integrity

101. All primary keys must be unique.

102. All non-nullable foreign keys must reference existing records.

103. Foreign-key relationships must not create circular dependencies during
     initial data loading.

104. Dates should maintain logical chronological relationships.

105. Monetary values should use two decimal places.

106. Quantities should be positive integers unless specifically representing
     inventory, where zero is permitted.

107. Generated data should contain realistic variation rather than uniform
     random values.

108. Related fields should be generated together so that relationships
     between variables remain believable.

109. Random generation should use a fixed seed when reproducibility is
     required.

110. The generated dataset should contain enough variation to support
     meaningful SQL, Power BI, and statistical analysis.