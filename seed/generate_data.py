#!/usr/bin/env python3
"""
Generate realistic retail CSV seed data for SQL Practice Lab.
Uses fixed random seed (42) for reproducibility.
"""

from __future__ import annotations

import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

from dateutil.relativedelta import relativedelta
from faker import Faker

SEED = 42
DATA_DIR = Path(__file__).parent / "data"

COUNTS = {
    "customers": 1200,
    "products": 550,
    "orders": 5200,
}

REGIONS = ["NA", "EU", "LATAM", "APAC"]
REGION_WEIGHTS = [0.40, 0.25, 0.20, 0.15]

CHANNELS = ["online", "retail", "phone", "wholesale", "marketplace"]
CHANNEL_WEIGHTS = [0.45, 0.25, 0.15, 0.10, 0.05]

ORDER_STATUSES = ["pending", "processing", "shipped", "delivered", "cancelled", "returned"]
STATUS_WEIGHTS = [0.05, 0.10, 0.15, 0.55, 0.10, 0.05]

PAYMENT_METHODS = ["credit_card", "debit_card", "bank_transfer", "paypal", "cash", "check"]
PAYMENT_STATUSES = ["completed", "completed", "completed", "partial", "failed", "refunded"]

REGION_COUNTRIES = {
    "NA": ["USA", "Canada", "Mexico"],
    "EU": ["UK", "Germany", "France", "Spain", "Italy", "Netherlands"],
    "LATAM": ["Brazil", "Argentina", "Colombia", "Chile", "Peru"],
    "APAC": ["Japan", "Australia", "South Korea", "Singapore", "India"],
}

WAREHOUSES = ["WH-EAST", "WH-WEST", "WH-CENTRAL", "WH-EU", "WH-APAC"]

fake = Faker()
random.seed(SEED)
Faker.seed(SEED)


def weighted_date(start: datetime, end: datetime) -> datetime:
    """More orders in Q4 and gradual YoY growth."""
    years = list(range(start.year, end.year + 1))
    year_weights = [1.0 + (i * 0.15) for i in range(len(years))]
    year = random.choices(years, weights=year_weights)[0]

    month_weights = [1.0] * 12
    for m in [10, 11, 12]:
        month_weights[m - 1] = 1.8
    for m in [6, 7, 8]:
        month_weights[m - 1] = 1.2

    month = random.choices(range(1, 13), weights=month_weights)[0]
    day = random.randint(1, 28)
    hour = random.randint(8, 20)
    minute = random.randint(0, 59)
    return datetime(year, month, day, hour, minute)


def maybe_null(value, null_rate: float = 0.08):
    return "" if random.random() < null_rate else value


def write_csv(filename: str, fieldnames: list[str], rows: list[dict]) -> None:
    path = DATA_DIR / filename
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
    print(f"  Wrote {len(rows):>6} rows -> {path.name}")


def generate_customers() -> list[dict]:
    rows = []
    sales_employee_ids = list(range(2, 21)) + list(range(72, 76))

    for i in range(1, COUNTS["customers"] + 1):
        region = random.choices(REGIONS, weights=REGION_WEIGHTS)[0]
        country = random.choice(REGION_COUNTRIES[region])
        created = weighted_date(datetime(2019, 1, 1), datetime(2025, 6, 30))

        rows.append({
            "customer_code": f"CUST-{i:05d}",
            "full_name": fake.name(),
            "email": maybe_null(fake.email()),
            "phone": maybe_null(fake.phone_number()[:20]),
            "country": country,
            "region": region,
            "city": fake.city(),
            "sales_channel": random.choices(CHANNELS, weights=CHANNEL_WEIGHTS)[0],
            "credit_limit": maybe_null(round(random.uniform(500, 50000), 2)),
            "created_at": created.isoformat(),
        })

    # High-volume customer for analytics skew (50+ orders target)
    rows[0]["full_name"] = "Mega Buyer International"
    rows[0]["region"] = "NA"
    rows[0]["sales_channel"] = "wholesale"
    rows[0]["credit_limit"] = "100000.00"

    return rows


def generate_products() -> list[dict]:
    rows = []
    adjectives = ["Pro", "Elite", "Basic", "Ultra", "Max", "Mini", "Smart", "Classic"]
    nouns = ["Widget", "Gadget", "Device", "Kit", "Bundle", "Pack", "Set", "Unit"]

    for i in range(1, COUNTS["products"] + 1):
        category_id = "" if random.random() < 0.05 else random.randint(1, 24)
        supplier_id = random.randint(1, 34)
        cost = round(random.uniform(5, 500), 2)
        margin = random.uniform(1.2, 2.5)
        list_price = round(cost * margin, 2)
        is_active = random.random() > 0.08
        discontinued_at = ""
        if not is_active and random.random() < 0.7:
            discontinued_at = weighted_date(
                datetime(2021, 1, 1), datetime(2025, 12, 31)
            ).date().isoformat()

        rows.append({
            "sku": f"SKU-{i:05d}",
            "product_name": f"{random.choice(adjectives)} {random.choice(nouns)} {i:03d}",
            "category_id": category_id,
            "supplier_id": supplier_id,
            "list_price": list_price,
            "cost_price": cost,
            "is_active": str(is_active).lower(),
            "discontinued_at": discontinued_at,
            "created_at": weighted_date(datetime(2019, 6, 1), datetime(2025, 1, 1)).isoformat(),
        })

    return rows


def generate_orders_and_items(
    customer_count: int,
) -> tuple[list[dict], list[dict], list[int]]:
    """Returns orders, items, and customer_ids used (for payment generation)."""
    orders = []
    items = []
    sales_reps = list(range(10, 21)) + list(range(72, 76))

    # Distribute orders: customer 1 gets ~55 orders, some get 0
    customer_order_counts: dict[int, int] = {i: 0 for i in range(1, customer_count + 1)}
    remaining = COUNTS["orders"]

    customer_order_counts[1] = 55
    remaining -= 55

    zero_order_customers = random.sample(range(2, customer_count + 1), 80)
    for cid in zero_order_customers:
        customer_order_counts[cid] = 0

    active_customers = [c for c in range(1, customer_count + 1) if c not in zero_order_customers and c != 1]
    while remaining > 0 and active_customers:
        cid = random.choice(active_customers)
        customer_order_counts[cid] += 1
        remaining -= 1

    order_num = 1
    for customer_id, count in customer_order_counts.items():
        for _ in range(count):
            region = random.choices(REGIONS, weights=REGION_WEIGHTS)[0]
            order_date = weighted_date(datetime(2020, 1, 1), datetime(2025, 12, 31))
            status = random.choices(ORDER_STATUSES, weights=STATUS_WEIGHTS)[0]

            shipped_at = ""
            cancelled_at = ""
            if status in ("shipped", "delivered"):
                shipped_at = (order_date + timedelta(days=random.randint(1, 7))).isoformat()
            elif status == "cancelled":
                cancelled_at = (order_date + timedelta(days=random.randint(0, 2))).isoformat()

            order = {
                "order_number": f"ORD-{order_num:06d}",
                "customer_code": f"CUST-{customer_id:05d}",
                "employee_id": random.choice(sales_reps) if random.random() > 0.05 else "",
                "order_date": order_date.isoformat(),
                "status": status,
                "sales_channel": random.choices(CHANNELS, weights=CHANNEL_WEIGHTS)[0],
                "ship_region": region,
                "shipped_at": shipped_at,
                "cancelled_at": cancelled_at,
                "notes": maybe_null(fake.sentence(nb_words=6), 0.85),
            }
            orders.append(order)

            num_items = random.choices([1, 2, 3, 4, 5, 6], weights=[5, 15, 35, 25, 12, 8])[0]
            for _ in range(num_items):
                product_id = random.randint(1, COUNTS["products"])
                qty = random.randint(1, 5)
                unit_price = round(random.uniform(10, 999), 2)
                discount = "" if random.random() > 0.25 else round(random.uniform(0, 30), 2)
                items.append({
                    "order_number": order["order_number"],
                    "sku": f"SKU-{product_id:05d}",
                    "quantity": qty,
                    "unit_price": unit_price,
                    "discount_pct": discount,
                })

            order_num += 1

    return orders, items, list(customer_order_counts.keys())


def generate_inventory() -> list[dict]:
    rows = []
    for product_id in range(1, COUNTS["products"] + 1):
        qty = random.randint(-10, 500)
        rows.append({
            "product_id": product_id,
            "warehouse_location": random.choice(WAREHOUSES),
            "quantity_on_hand": qty,
            "reorder_level": random.randint(5, 50),
            "last_restocked_at": maybe_null(
                weighted_date(datetime(2023, 1, 1), datetime(2025, 12, 31)).isoformat(),
                0.12,
            ),
        })
    return rows


def generate_payments(orders: list[dict], items: list[dict]) -> list[dict]:
    order_totals: dict[str, float] = {}
    for item in items:
        discount = float(item["discount_pct"]) if item["discount_pct"] else 0
        total = item["quantity"] * float(item["unit_price"]) * (1 - discount / 100)
        order_totals[item["order_number"]] = order_totals.get(item["order_number"], 0) + total

    payments = []
    dup_refs = ["REF-2024-001", "REF-2024-002", "REF-2025-100", "PAY-DUP-99"]

    for order in orders:
        if order["status"] in ("cancelled", "returned"):
            if random.random() < 0.3:
                payments.append({
                    "order_number": order["order_number"],
                    "payment_date": order["order_date"],
                    "amount": round(order_totals.get(order["order_number"], 0), 2),
                    "payment_method": random.choice(PAYMENT_METHODS),
                    "status": "refunded",
                    "reference_no": maybe_null(f"REF-{random.randint(1000, 9999)}", 0.15),
                })
            continue

        total = order_totals.get(order["order_number"], 0)
        if total <= 0:
            continue

        if random.random() < 0.15:
            first_amount = round(total * random.uniform(0.3, 0.7), 2)
            second_amount = round(total - first_amount, 2)
            ref = random.choice(dup_refs) if random.random() < 0.03 else f"REF-{random.randint(10000, 99999)}"
            payments.append({
                "order_number": order["order_number"],
                "payment_date": order["order_date"],
                "amount": first_amount,
                "payment_method": random.choice(PAYMENT_METHODS),
                "status": "partial",
                "reference_no": ref,
            })
            pay_date = datetime.fromisoformat(order["order_date"]) + timedelta(days=random.randint(1, 14))
            payments.append({
                "order_number": order["order_number"],
                "payment_date": pay_date.isoformat(),
                "amount": second_amount,
                "payment_method": random.choice(PAYMENT_METHODS),
                "status": "completed",
                "reference_no": ref if random.random() < 0.03 else f"REF-{random.randint(10000, 99999)}",
            })
        else:
            payments.append({
                "order_number": order["order_number"],
                "payment_date": order["order_date"],
                "amount": round(total, 2),
                "payment_method": random.choice(PAYMENT_METHODS),
                "status": random.choice(PAYMENT_STATUSES),
                "reference_no": maybe_null(
                    random.choice(dup_refs) if random.random() < 0.02 else f"REF-{random.randint(10000, 99999)}",
                    0.10,
                ),
            })

    return payments


def main() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    print("Generating seed data (seed=42)...")

    customers = generate_customers()
    write_csv("customers.csv", [
        "customer_code", "full_name", "email", "phone", "country",
        "region", "city", "sales_channel", "credit_limit", "created_at",
    ], customers)

    products = generate_products()
    write_csv("products.csv", [
        "sku", "product_name", "category_id", "supplier_id",
        "list_price", "cost_price", "is_active", "discontinued_at", "created_at",
    ], products)

    orders, items, _ = generate_orders_and_items(len(customers))
    write_csv("sales_orders.csv", [
        "order_number", "customer_code", "employee_id", "order_date", "status",
        "sales_channel", "ship_region", "shipped_at", "cancelled_at", "notes",
    ], orders)

    write_csv("sales_order_items.csv", [
        "order_number", "sku", "quantity", "unit_price", "discount_pct",
    ], items)

    inventory = generate_inventory()
    write_csv("inventory.csv", [
        "product_id", "warehouse_location", "quantity_on_hand",
        "reorder_level", "last_restocked_at",
    ], inventory)

    payments = generate_payments(orders, items)
    write_csv("payments.csv", [
        "order_number", "payment_date", "amount", "payment_method",
        "status", "reference_no",
    ], payments)

    print("\nSummary:")
    print(f"  Customers:     {len(customers)}")
    print(f"  Products:      {len(products)}")
    print(f"  Orders:        {len(orders)}")
    print(f"  Order items:   {len(items)}")
    print(f"  Inventory:     {len(inventory)}")
    print(f"  Payments:      {len(payments)}")
    print("\nDone. Run setup.ps1 to load into PostgreSQL.")


if __name__ == "__main__":
    main()
