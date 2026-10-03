/* =============================================================================
   04_staging / stg_products.sql
   Purpose : Clean, type and de-duplicate raw_products
   Source  : raw.raw_products
   Target  : stg.stg_products (+ stg.quarantine_products / mapping table where relevant)
   Grain   : 1 row = 1 product (product_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-019 BR-020  therapeutic_area case ('cardiology')   -> mapping table
     ISS-020 DQ-044  therapeutic_area NULL (3)               -> NULLIF
     ISS-021 DQ-048  launch_date sentinel '2027-15-40'       -> TRY_CAST -> NULL
   2. RULES
     product_id, product_name  TRIM, mandatory
     therapeutic_area          TRIM -> map_therapeutic_area -> NULLIF
     product_type, status      TRIM + NULLIF
     priority_flag             'Y'/'N' -> BIT
     launch_date               TRY_CAST DATE
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================

DROP TABLE IF EXISTS stg.stg_products;
DROP TABLE IF EXISTS stg.map_therapeutic_area;


CREATE TABLE stg.map_therapeutic_area (
	raw_value        NVARCHAR(100) NOT NULL PRIMARY KEY,
	canonical_value  NVARCHAR(100) NOT NULL
);


INSERT INTO stg.map_therapeutic_area (raw_value, canonical_value)
VALUES ('cardiology', 'Cardiology');


CREATE TABLE stg.stg_products (
	stg_product_key    INT IDENTITY(1,1) PRIMARY KEY,
	product_id         VARCHAR(20)    NOT NULL,
	product_name       NVARCHAR(150)  NOT NULL,
	therapeutic_area   NVARCHAR(100)  NULL,
	product_type       VARCHAR(50)    NULL,
	priority_flag      BIT            NULL,
	launch_date        DATE           NULL,
	status             VARCHAR(20)    NULL,
	stg_load_date      DATETIME       NOT NULL DEFAULT GETDATE()
);


INSERT INTO stg.stg_products (
	product_id, product_name, therapeutic_area, product_type, priority_flag, launch_date, status, stg_load_date
)
SELECT
	TRIM(p.product_id),
	TRIM(p.product_name),
	COALESCE(m.canonical_value, NULLIF(TRIM(p.therapeutic_area), '')) AS therapeutic_area,
	NULLIF(TRIM(p.product_type), '') AS product_type,
	CASE
		WHEN TRIM(p.priority_flag) = 'Y' THEN 1
		WHEN TRIM(p.priority_flag) = 'N' THEN 0
		ELSE NULL
	END AS priority_flag,
	TRY_CAST(p.launch_date AS DATE) AS launch_date,
	NULLIF(TRIM(p.status), '') AS status,
	GETDATE()
FROM raw.raw_products AS p
LEFT JOIN stg.map_therapeutic_area AS m
	ON LOWER(TRIM(p.therapeutic_area)) = LOWER(m.raw_value)


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: "cardiology" must become "Cardiology"
SELECT DISTINCT therapeutic_area
FROM stg.stg_products
-- Expected: no lower-case value left


-- Test 2: launch_date sentinel must become NULL
SELECT r.product_id, r.launch_date AS raw_launch_date, s.launch_date AS stg_launch_date
FROM raw.raw_products r
JOIN stg.stg_products s ON r.product_id = s.product_id
WHERE r.launch_date = '2027-15-40'
-- Expected: stg_launch_date = NULL


-- Test 3: priority_flag converted to BIT
SELECT DISTINCT priority_flag
FROM stg.stg_products
-- Expected: only {0, 1}

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
-- V1: row count - no dedup in this table, so counts must match exactly
SELECT
	(SELECT COUNT(*) FROM raw.raw_products) AS raw_count,
	(SELECT COUNT(*) FROM stg.stg_products) AS stg_count
-- Expected: raw_count = stg_count = 40

-- V2: no case inconsistency left
SELECT therapeutic_area, COUNT(*)
FROM stg.stg_products 
GROUP BY therapeutic_area
-- Visual check: no two values that differ only by case (e.g. "Cardiology" and "cardiology")

-- V3: no malformed launch_date left
SELECT COUNT(*) AS remaining_invalid
FROM raw.raw_products r
JOIN stg.stg_products s ON r.product_id = s.product_id
WHERE TRY_CAST(r.launch_date AS DATE) IS NULL AND s.launch_date IS NOT NULL
-- Expected: 0 (every raw value that cannot be parsed is NULL in staging)
