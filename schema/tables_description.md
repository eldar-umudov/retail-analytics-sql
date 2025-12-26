## Table: sales

### Physical schema (as-is)

This schema reflects the actual structure of the source table.

| Column name      | Data type | Description |
|------------------|----------|-------------|
| OrderID          | INT      | Order identifier |
| SaleDate         | DATE     | Sale date |
| Category         | TEXT     | Product category |
| Model            | TEXT     | Product model |
| Price            | INT      | Original price |
| DiscountPct      | TEXT     | Discount percentage (raw) |
| PriceAfterDiscount | INT    | Final price |
| Cost             | INT      | Cost |
| Margin           | INT      | Margin |
| Quantity         | INT      | Quantity |
| City             | TEXT     | City |
| DeliveryCost     | INT      | Delivery cost |
| LiftCharge       | INT      | Lift charge |
| PaymentMethod    | TEXT     | Payment method |
| Client           | TEXT     | Customer identifier (raw) |
| RepeatCustomer   | TEXT     | Repeat customer flag (Yes/No) |
| Returned         | TEXT     | Returned flag |
| Manager          | TEXT     | Sales manager |
| Comment          | TEXT     | Comment |

---

### Logical schema (used in analysis)

During analysis, raw fields are transformed to analytical-friendly formats.

| Logical field        | Type          | Source / Transformation |
|---------------------|---------------|--------------------------|
| discount_pct        | DECIMAL(5,2)  | CAST from DiscountPct |
| is_repeat_customer  | TINYINT(1)    | CASE from RepeatCustomer |
| is_returned         | TINYINT(1)    | CASE from Returned |
| client_id           | VARCHAR(64)   | Normalized from Client |

---

### Notes

- Source data contains non-normalized fields typical for operational systems.
- Data is transformed during analysis using SQL.
- Raw data is not modified at database level.
