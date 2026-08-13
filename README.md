# Subscription Orders & Customer Complaints Analysis

## Project Overview

This project analyzes customer orders placed while customers had an active free-delivery subscription.

The analysis focuses on two key operational issues:

- Delivery delays
- Customer complaints

The objective is to understand how frequently subscription orders were affected by either a delivery delay or a customer complaint and to identify patterns by subscription type.


---

## Business Question

**How many subscription orders were delayed or had a complaint filed?**

The analysis also answers:

- How many subscription orders were placed?
- How many orders had customer complaints?
- How many orders were delayed?
- How many orders were affected by either a delay or a complaint?
- What percentage of subscription orders were affected?
- How do these metrics vary by subscription type?

---

## Project Objectives

The main objectives of the analysis are to:

1. Assess the quality of the raw data.
2. Clean and validate the source tables.
3. Identify orders placed during an active subscription period.
4. Identify orders with customer complaints.
5. Identify delayed orders.
6. Calculate the combined number and percentage of orders affected by delays or complaints.
7. Prepare clean, dashboard-ready datasets.
8. Present the results through an interactive Tableau dashboard.

---

## Dataset

The project uses several relational datasets containing information about:

- Orders
- Customers
- Subscriptions
- Subscription types
- Customer complaints
- Reported problems
- Problem groups

The original data was provided as CSV files and imported into a MySQL database.

### Main source tables

- `orders_order`
- `home_subscriptioninfo`
- `home_usersubscription`
- `orders_complaint`
- `orders_problem`
- `orders_problemgroup`
- `orders_problemproblemgroup`

---

## Data Preparation & Cleaning

Before performing the analysis, several data quality checks were carried out.

The cleaning process included:

- Checking row counts after CSV import
- Checking missing values
- Validating date formats
- Converting text-based dates into `DATE` / `DATETIME`
- Checking invalid payment values
- Identifying duplicate complaint records
- Removing invalid problem records
- Standardizing problem names
- Checking subscription date ranges
- Validating deactivation dates
- Comparing raw and cleaned row counts

Cleaned tables were created using a `clean_` naming convention while keeping the original raw tables unchanged.

This approach preserves the raw data and makes the cleaning process transparent and reproducible.

---

## Identifying Subscription Orders

An order is considered a **subscription order** when the order was created during an active subscription period.

The subscription period is defined using the subscription start and end dates:

```sql
o.created_at >= u.subscription_start
AND (
    u.subscription_end IS NULL
    OR o.created_at <= u.subscription_end
)
