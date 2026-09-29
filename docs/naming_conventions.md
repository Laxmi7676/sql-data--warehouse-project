# Naming Conventions

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

## Table of Contents

- [General Principles](#general-principles)
- [Table Naming Conventions](#table-naming-conventions)
  - [Bronze Rules](#bronze-rules)
  - [Silver Rules](#silver-rules)
  - [Gold Rules](#gold-rules)
- [Column Naming Conventions](#column-naming-conventions)
  - [Surrogate Keys](#surrogate-keys)
  - [Technical Columns](#technical-columns)
- [Stored Procedure](#stored-procedure)

## General Principles

| Principle | Rule |
|---|---|
| Naming Convention | Use `snake_case`, with lowercase letters and underscores (`_`) to separate words. |
| Language | Use English for all names. |
| Avoid Reserved Words | Do not use SQL reserved words as object names. |

## Table Naming Conventions

### Bronze Rules

| Rule | Convention | Description | Example |
|---|---|---|---|
| Table Naming | `<sourcesystem>_<entity>` | All names must start with the source system name, and table names must match their original names without renaming. | `crm_customer_info` |
| Source System | `<sourcesystem>` | Name of the source system. | `crm`, `erp` |
| Entity | `<entity>` | Exact table name from the source system. | `customer_info` |

**Example:** `crm_customer_info` → Customer information from the CRM system.

### Silver Rules

| Rule | Convention | Description | Example |
|---|---|---|---|
| Table Naming | `<sourcesystem>_<entity>` | All names must start with the source system name, and table names must match their original names without renaming. | `crm_customer_info` |
| Source System | `<sourcesystem>` | Name of the source system. | `crm`, `erp` |
| Entity | `<entity>` | Exact table name from the source system. | `customer_info` |

**Example:** `crm_customer_info` → Customer information from the CRM system.

### Gold Rules

| Rule | Convention | Description | Example |
|---|---|---|---|
| Table Naming | `<category>_<entity>` | All names must use meaningful, business-aligned names for tables, starting with the category prefix. | `dim_customers` |
| Category | `<category>` | Describes the role of the table, such as dimension or fact table. | `dim`, `fact` |
| Entity | `<entity>` | Descriptive name aligned with the business domain. | `customers`, `products`, `sales` |

**Examples:**

| Table | Description |
|---|---|
| `dim_customers` | Dimension table for customer data. |
| `dim_products` | Dimension table for product data. |
| `fact_sales` | Fact table containing sales transactions. |

## Glossary of Category Patterns

| Pattern | Meaning | Example(s) |
|---|---|---|
| `dim_` | Dimension table | `dim_customer`, `dim_product` |
| `fact_` | Fact table | `fact_sales` |
| `report_` | Report table | `report_customers`, `report_sales_monthly` |

## Column Naming Conventions

### Surrogate Keys

| Rule | Convention | Description | Example |
|---|---|---|---|
| Surrogate Key | `<table_name>_key` | All primary keys in dimension tables must use the `_key` suffix. | `customer_key` |
| Table Name | `<table_name>` | Refers to the name of the table or entity the key belongs to. | `customer` |
| Key Suffix | `_key` | Indicates that the column is a surrogate key. | `customer_key` |

**Example:** `customer_key` → Surrogate key in the `dim_customers` table.

### Technical Columns

| Rule | Convention | Description | Example |
|---|---|---|---|
| Technical Column | `dwh_<column_name>` | All technical columns must start with the `dwh_` prefix. | `dwh_load_date` |
| Prefix | `dwh_` | Prefix exclusively used for system-generated metadata. | `dwh_` |
| Column Name | `<column_name>` | Descriptive name indicating the column's purpose. | `load_date` |

**Example:** `dwh_load_date` → System-generated column used to store the date when the record was loaded.

## Stored Procedure

All stored procedures used for loading data must follow the naming pattern:

`load_<layer>`

| Rule | Convention | Description | Example |
|---|---|---|---|
| Stored Procedure | `load_<layer>` | Naming pattern for stored procedures used for loading data. | `load_bronze` |
| Layer | `<layer>` | Represents the layer being loaded. | `bronze`, `silver`, `gold` |
| Bronze | `load_bronze` | Stored procedure for loading data into the Bronze layer. | `load_bronze` |
| Silver | `load_silver` | Stored procedure for loading data into the Silver layer. | `load_silver` |
| Gold | `load_gold` | Stored procedure for loading data into the Gold layer. | `load_gold` |
