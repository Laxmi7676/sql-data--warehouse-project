/*
=======================================================================================
Stored Procedure: Load Silver Layer (BRONZE -> Silver)
=======================================================================================
Script Purpose:
THIS STORED PROCEDURE PERFORMS THE ETL (EXTRACT, TRANSFORM,LOAD) PROCESS TO POPULATE THE 'SILVER' SCHEMA TABLES FROM THE 'BRONZE' SCHEMA.
ACTION PERFORMED:
- TRUNCATED SILVER TABLES
- INSERTS TRANSFORMED AND CLEANED DATA FROM BRONZE INTO SILVER TABLES

PARAMETERS:
NONE.
THIS STORED PROCEDURE DOES NOT ACCEPT ANY PARAMETER OR RETURN ANY VALUES

USAGE EXAMPLE:
CALL SILVER.LOAD_SILVER();


DELIMITER $$

DROP PROCEDURE IF EXISTS load_silver_data $$

CREATE PROCEDURE load_silver_data()
BEGIN

    -- =========================================================
    -- DECLARE VARIABLES
    -- =========================================================

    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;

    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;

    DECLARE error_message TEXT;
    DECLARE error_state CHAR(5);


    -- =========================================================
    -- ERROR HANDLING
    -- =========================================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        GET DIAGNOSTICS CONDITION 1
            error_state = RETURNED_SQLSTATE,
            error_message = MESSAGE_TEXT;

        SELECT '============================================' AS message;
        SELECT 'ERROR OCCURRED WHILE LOADING SILVER LAYER' AS message;
        SELECT CONCAT('SQLSTATE: ', error_state) AS message;
        SELECT CONCAT('ERROR MESSAGE: ', error_message) AS message;
        SELECT '============================================' AS message;

    END;


    -- =========================================================
    -- START SILVER LOAD
    -- =========================================================

    SET batch_start_time = NOW();

    SELECT '============================================' AS message;
    SELECT 'STARTING SILVER LAYER LOAD' AS message;
    SELECT CONCAT('START TIME: ', batch_start_time) AS message;
    SELECT '============================================' AS message;


    -- =========================================================
    -- SILVER CRM CUSTOMER
    -- =========================================================

    SET start_time = NOW();

    SELECT '>> STARTING SILVER CRM CUSTOMER LOAD' AS message;
    SELECT '>> TRUNCATING TABLE silver.crm_cust_info' AS message;

    TRUNCATE TABLE silver.crm_cust_info;

    SELECT '>> INSERTING DATA INTO silver.crm_cust_info' AS message;

    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_first_name,
        TRIM(cst_lastname) AS cst_lastname,

        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,

        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,

        CASE
            WHEN cst_create_date IS NULL
                 OR TRIM(cst_create_date) = ''
            THEN NULL
            ELSE STR_TO_DATE(TRIM(cst_create_date), '%m/%d/%Y')
        END AS cst_create_date

    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER
               (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS flag_last
        FROM bronze.crm_cust_info
    ) t
    WHERE flag_last = 1
      AND cst_id != 0;

    SET end_time = NOW();

    SELECT '>> SILVER CRM CUSTOMER LOAD COMPLETED' AS message;
    SELECT CONCAT(
        '>> DURATION: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    -- =========================================================
    -- SILVER PRODUCT
    -- =========================================================

    SET start_time = NOW();

    SELECT '>> STARTING SILVER PRODUCT LOAD' AS message;

    SELECT '>> TRUNCATING TABLE silver.crm_prd_info' AS message;

    
    TRUNCATE TABLE silver.crm_prd_info;

    SELECT '>> INSERTING DATA INTO silver.crm_prd_info' AS message;

    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        REPLACE(
            SUBSTRING(prd_key, 1, 5),
            '-',
            '_'
        ) AS cat_id,

        SUBSTRING(prd_key, 7) AS prd_key,

        prd_nm,

        COALESCE(prd_cost, 0) AS prd_cost,

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        STR_TO_DATE(
            NULLIF(TRIM(prd_start_dt), ''),
            '%m/%d/%Y'
        ) AS prd_start_dt,

        DATE_SUB(
            LEAD(
                STR_TO_DATE(
                    NULLIF(TRIM(prd_start_dt), ''),
                    '%m/%d/%Y'
                )
            ) OVER (
                PARTITION BY prd_key
                ORDER BY
                    STR_TO_DATE(
                        NULLIF(TRIM(prd_start_dt), ''),
                        '%m/%d/%Y'
                    )
            ),
            INTERVAL 1 DAY
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;

    SET end_time = NOW();

    SELECT '>> SILVER PRODUCT LOAD COMPLETED' AS message;
    SELECT CONCAT(
        '>> DURATION: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    -- =========================================================
    -- SILVER SALES
    -- =========================================================

    SET start_time = NOW();

    SELECT '>> STARTING SILVER SALES LOAD' AS message;

    SELECT '>> DROPPING TABLE silver.crm_sales_details' AS message;

    DROP TABLE IF EXISTS silver.crm_sales_details;

    SELECT '>> CREATING TABLE silver.crm_sales_details' AS message;

    CREATE TABLE silver.crm_sales_details (
        sls_ord_num VARCHAR(50),
        sls_prd_key VARCHAR(50),
        sls_cust_id INT,
        sls_order_dt DATE,
        sls_ship_dt DATE,
        sls_due_dt DATE,
        sls_sales INT,
        sls_quantity INT,
        sls_price INT,
        dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    SELECT '>> TRUNCATING TABLE silver.crm_sales_details' AS message;

    TRUNCATE TABLE silver.crm_sales_details;

    SELECT '>> INSERTING DATA INTO silver.crm_sales_details' AS message;

    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt = 0
                 OR LENGTH(sls_order_dt) != 8
            THEN NULL
            ELSE STR_TO_DATE(
                CAST(sls_order_dt AS CHAR),
                '%Y%m%d'
            )
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt = 0
                 OR LENGTH(sls_ship_dt) != 8
            THEN NULL
            ELSE STR_TO_DATE(
                CAST(sls_ship_dt AS CHAR),
                '%Y%m%d'
            )
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt = 0
                 OR LENGTH(sls_due_dt) != 8
            THEN NULL
            ELSE STR_TO_DATE(
                CAST(sls_due_dt AS CHAR),
                '%Y%m%d'
            )
        END AS sls_due_dt,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
                 OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price

    FROM bronze.crm_sales_details;

    SET end_time = NOW();

    SELECT '>> SILVER SALES LOAD COMPLETED' AS message;
    SELECT CONCAT(
        '>> DURATION: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    -- =========================================================
    -- SILVER ERP CUSTOMER
    -- =========================================================

    SET start_time = NOW();

    SELECT '>> STARTING SILVER ERP CUSTOMER LOAD' AS message;

    SELECT '>> TRUNCATING TABLE silver.erp_cust_az12' AS message;

    TRUNCATE TABLE silver.erp_cust_az12;

    SELECT '>> INSERTING DATA INTO silver.erp_cust_az12' AS message;

    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT

        CASE
            WHEN cid LIKE 'NAS%'
            THEN SUBSTRING(cid, 4, LENGTH(cid))
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > CURRENT_DATE()
            THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(REPLACE(gen, '\r', '')))
                 IN ('F', 'FEMALE')
            THEN 'Female'

            WHEN UPPER(TRIM(REPLACE(gen, '\r', '')))
                 IN ('M', 'MALE')
            THEN 'Male'

            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;

    SET end_time = NOW();

    SELECT '>> SILVER ERP CUSTOMER LOAD COMPLETED' AS message;
    SELECT CONCAT(
        '>> DURATION: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    -- =========================================================
    -- SILVER ERP LOCATION
    -- =========================================================

    SET start_time = NOW();

    SELECT '>> STARTING SILVER ERP LOCATION LOAD' AS message;

    SELECT '>> TRUNCATING TABLE silver.erp_loc_a101' AS message;

    TRUNCATE TABLE silver.erp_loc_a101;

    SELECT '>> INSERTING DATA INTO silver.erp_loc_a101' AS message;

    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid,

        CASE
            WHEN TRIM(REPLACE(cntry, '\r', '')) = 'DE'
            THEN 'Germany'

            WHEN TRIM(REPLACE(cntry, '\r', ''))
                 IN ('US', 'USA')
            THEN 'United States'

            WHEN TRIM(REPLACE(cntry, '\r', '')) = ''
                 OR cntry IS NULL
            THEN 'n/a'

            ELSE TRIM(REPLACE(cntry, '\r', ''))
        END AS cntry

    FROM bronze.erp_loc_a101;

    SET end_time = NOW();

    SELECT '>> SILVER ERP LOCATION LOAD COMPLETED' AS message;
    SELECT CONCAT(
        '>> DURATION: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    -- =========================================================
    -- SILVER ERP PRODUCT CATEGORY
    -- =========================================================

    SET start_time = NOW();

    SELECT '>> STARTING SILVER ERP PRODUCT CATEGORY LOAD' AS message;

    SELECT '>> TRUNCATING TABLE silver.erp_px_cat_g1v2' AS message;

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    SELECT '>> INSERTING DATA INTO silver.erp_px_cat_g1v2' AS message;

    INSERT INTO silver.erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintance
    )
    SELECT
        id,
        cat,
        subcat,
        maintance
    FROM bronze.erp_px_cat_g1v2;

    SET end_time = NOW();

    SELECT '>> SILVER ERP PRODUCT CATEGORY LOAD COMPLETED' AS message;
    SELECT CONCAT(
        '>> DURATION: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS message;


    -- =========================================================
    -- TOTAL SILVER LOAD DURATION
    -- =========================================================

    SET batch_end_time = NOW();

    SELECT '============================================' AS message;
    SELECT 'SILVER LAYER LOAD COMPLETED SUCCESSFULLY' AS message;
    SELECT CONCAT(
        'TOTAL START TIME: ',
        batch_start_time
    ) AS message;

    SELECT CONCAT(
        'TOTAL END TIME: ',
        batch_end_time
    ) AS message;

    SELECT CONCAT(
        'TOTAL SILVER LOAD DURATION: ',
        TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time),
        ' seconds'
    ) AS message;

    SELECT '============================================' AS message;

END $$

DELIMITER ;
