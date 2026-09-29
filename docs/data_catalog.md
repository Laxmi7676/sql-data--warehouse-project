# Gold Layer Data Catalog

The Gold Layer is the business-level data representation, structured to
support analytical and reporting use cases. It consists of dimension
tables and fact tables for specific business metrics.

## 1. gold.dim_customers

- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| customer_key | INT | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id | INT | Unique numerical identifier assigned to each customer. |
| customer_number | NVARCHAR(50) | Alphanumeric identifier representing the customer. |
| first_name | NVARCHAR(50) | The customer's first name. |
| last_name | NVARCHAR(50) | The customer's last name. |
| country | NVARCHAR(50) | The country of residence for the customer. |
| marital_status | NVARCHAR(50) | The marital status of the customer. |
| gender | NVARCHAR(50) | The gender of the customer. |
| birthdate | DATE | The customer's date of birth. |
| create_date | DATE | The date when the customer record was created. |

## 2. gold.dim_products

- **Purpose:** Provides information about products and their attributes.
- **Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| product_key | INT | Surrogate key uniquely identifying each product. |
| product_id | INT | Unique identifier assigned to the product. |
| product_number | NVARCHAR(50) | Structured alphanumeric product code. |
| product_name | NVARCHAR(50) | Descriptive name of the product. |
| category_id | NVARCHAR(50) | Unique identifier for the product category. |
| category | NVARCHAR(50) | Broader classification of the product. |
| subcategory | NVARCHAR(50) | Detailed classification within the category. |
| maintenance_required | NVARCHAR(50) | Indicates whether maintenance is required. |
| cost | INT | Cost or base price of the product. |
| product_line | NVARCHAR(50) | Product line or series. |
| start_date | DATE | Date when the product became available. |

## 3. gold.fact_sales

- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**

| Column Name | Data Type | Description |
|---|---|---|
| order_number | NVARCHAR(50) | Unique identifier for each sales order. |
| product_key | INT | Surrogate key linking to the product dimension. |
| customer_key | INT | Surrogate key linking to the customer dimension. |
| order_date | DATE | Date when the order was placed. |
| shipping_date | DATE | Date when the order was shipped. |
| due_date | DATE | Date when payment was due. |
| sales_amount | INT | Total monetary value of the sale line item. |
| quantity | INT | Number of units ordered. |
| price | INT | Price per unit of the product. |
