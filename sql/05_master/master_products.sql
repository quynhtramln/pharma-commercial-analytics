/* =============================================================================
   05_master / master_products.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_products
   Target  : master.master_products
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-020 DQ-044 therapeutic_area NULL (3) -> missing_therapeutic_area_flag, no backfill
   2. RULES
     copy stg_products unchanged
     product_key IDENTITY PK
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_products;


CREATE TABLE master.master_products (
	product_key                   INT IDENTITY(1,1) PRIMARY KEY,
	product_id                    VARCHAR(20)    NOT NULL UNIQUE,
	product_name                  NVARCHAR(150)  NOT NULL,
	therapeutic_area              NVARCHAR(100)  NULL,
	product_type                  VARCHAR(50)    NULL,
	priority_flag                 BIT            NULL,
	launch_date                   DATE           NULL,
	status                        VARCHAR(20)    NULL,
	missing_therapeutic_area_flag BIT            NOT NULL DEFAULT 0,   -- ISS-020
	master_load_date              DATETIME       NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_products (
	product_id, product_name, therapeutic_area, product_type, priority_flag, launch_date, status,
	missing_therapeutic_area_flag
)
SELECT
	product_id, product_name, therapeutic_area, product_type, priority_flag, launch_date, status,
	CASE WHEN therapeutic_area IS NULL THEN 1 ELSE 0 END
FROM stg.stg_products;

-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: exactly 3 rows flagged
SELECT product_id, therapeutic_area, missing_therapeutic_area_flag
FROM master.master_products
WHERE missing_therapeutic_area_flag = 1;
-- Expected: 3 rows, all with therapeutic_area NULL

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_products) AS stg_count,
	(SELECT COUNT(*) FROM master.master_products) AS master_count,
	(SELECT COUNT(*) FROM master.master_products WHERE missing_therapeutic_area_flag = 1) AS flagged_count;
-- Expected: stg_count = master_count = 40, flagged_count = 3
