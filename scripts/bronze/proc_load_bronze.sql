Bronze Layer Stored Procedure
Purpose:

The load_bronze_data stored procedure is created to prepare the Bronze layer tables for a fresh data load.

In our project, the procedure removes the existing data from the three CRM Bronze tables before loading the latest CSV data.

It performs:

TRUNCATE TABLE bronze.crm_cust_info;
TRUNCATE TABLE bronze.crm_prd_info;
TRUNCATE TABLE bronze.crm_sales_details;

This helps ensure that old data is removed before a new load and prevents duplicate records during repeated data-loading runs.

Parameters:

This procedure does not use any parameters.

CREATE PROCEDURE bronze.load_bronze_data()

The empty parentheses () mean that no input or output parameters are required.

The procedure operates directly on the Bronze tables defined in the project.

Usage Example:

After creating the procedure, execute it using:

CALL bronze.load_bronze_data();



-- =========================================================
-- BRONZE LAYER - LOAD DATA
-- MySQL Version
-- =========================================================


-- 1. DROP PROCEDURE IF IT ALREADY EXISTS
DROP PROCEDURE IF EXISTS bronze.load_bronze_data;


-- 2. CREATE STORED PROCEDURE
DROP PROCEDURE IF EXISTS bronze.load_bronze_data;

DELIMITER $$

CREATE PROCEDURE bronze.load_bronze_data()
BEGIN

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'ERROR: Bronze loading failed.' AS message;
    END;

    -- Start loading
    TRUNCATE TABLE bronze.crm_cust_info;
    TRUNCATE TABLE bronze.crm_prd_info;
    TRUNCATE TABLE bronze.crm_sales_details;

    SELECT 'Bronze tables truncated successfully.' AS message;

END $$

DELIMITER ;


-- =========================================================
-- 3. RUN STORED PROCEDURE
-- =========================================================

CALL bronze.load_bronze_data();


-- =========================================================
-- 4. LOAD CUSTOMER DATA
-- =========================================================

LOAD DATA LOCAL INFILE
'C:/Users/laksh/Downloads/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'

INTO TABLE bronze.crm_cust_info

FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'

IGNORE 1 ROWS;


-- Check customer data
SELECT COUNT(*) AS total_customer_rows
FROM bronze.crm_cust_info;

SELECT *
FROM bronze.crm_cust_info;


-- =========================================================
-- 5. LOAD PRODUCT DATA
-- =========================================================

LOAD DATA LOCAL INFILE
'C:/Users/laksh/Downloads/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'

INTO TABLE bronze.crm_prd_info

FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'

IGNORE 1 ROWS;


-- Check product data
SELECT COUNT(*) AS total_product_rows
FROM bronze.crm_prd_info;

SELECT *
FROM bronze.crm_prd_info;


-- =========================================================
-- 6. LOAD SALES DATA
-- =========================================================

LOAD DATA LOCAL INFILE
'C:/Users/laksh/Downloads/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'

INTO TABLE bronze.crm_sales_details

FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'

IGNORE 1 ROWS;


-- Check sales data
SELECT COUNT(*) AS total_sales_rows
FROM bronze.crm_sales_details;

SELECT *
FROM bronze.crm_sales_details;
