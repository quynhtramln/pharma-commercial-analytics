/* =============================================================================
   04_staging / stg_sales.sql
   Purpose : Clean, type and de-duplicate raw_sales
   Source  : raw.raw_sales
   Target  : stg.stg_sales (+ stg.quarantine_sales / mapping table where relevant)
   Grain   : 1 row = 1 sales transaction (sales_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-038 DQ-107  1,050 exact-duplicate sales_id         -> dedup
     ISS-040 BR-052  sales_channel case (15,586)             -> mapping table
     ISS-043 DQ-113  sales_channel NULL                      -> NULLIF
     ISS-044 DQ-115  invoice_number NULL                     -> NULLIF
     RI              account 'ACC99999' / product 'PRD999'   -> quarantine
   NOT handled in staging, and why
     ISS-039 BR-050  sale before product launch (16.40 %)  cross-table -> master flag
     ISS-041 BR-054  negative quantity (801)               value kept  -> master flag
     ISS-042 BR-055  unit_price <= 0 (501)                 value kept  -> master flag
     ISS-045 BR-057  amount <> qty x price (1,301)         NOT recomputed: unknown which field is wrong
   2. RULES
     sales_id, account_id, product_id  TRIM, mandatory
     sales_date                        TRY_CAST DATE
     territory, order_type             TRIM + NULLIF
     sales_channel                     TRIM -> map_sales_channel -> NULLIF
     quantity                          TRY_CAST INT, negatives kept
     unit_price, sales_amount          TRY_CAST DECIMAL, values kept
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS stg.stg_sales;
DROP TABLE IF EXISTS stg.quarantine_sales;
DROP TABLE IF EXISTS stg.map_sales_channel;


CREATE TABLE stg.map_sales_channel (
	raw_value        VARCHAR(50) NOT NULL PRIMARY KEY,
	canonical_value  VARCHAR(50) NOT NULL
);
INSERT INTO stg.map_sales_channel (raw_value, canonical_value) VALUES
	('hospital tender', 'Hospital Tender'),
	('distributor', 'Distributor'),
	('pharmacy chain', 'Pharmacy Chain'),
	('direct', 'Direct'),
	('wholesaler', 'Wholesaler');


CREATE TABLE stg.stg_sales (
	stg_sales_key     INT IDENTITY(1,1) PRIMARY KEY,
	sales_id          VARCHAR(20)    NOT NULL,
	sales_date        DATE           NOT NULL,
	account_id        VARCHAR(20)    NOT NULL,
	product_id        VARCHAR(20)    NOT NULL,
	territory         VARCHAR(50)    NULL,
	sales_channel     VARCHAR(50)    NULL,
	order_type        VARCHAR(50)    NULL,
	invoice_number    VARCHAR(20)    NULL,
	quantity          INT            NULL,
	unit_price        DECIMAL(10,2)  NULL,
	sales_amount      DECIMAL(12,2)  NULL,
	stg_load_date     DATETIME       NOT NULL DEFAULT GETDATE()
);


CREATE TABLE stg.quarantine_sales (
	quarantine_key       INT IDENTITY(1,1) PRIMARY KEY,
	sales_id             VARCHAR(20)   NULL,
	sales_date           VARCHAR(20)   NULL,
	account_id           VARCHAR(20)   NULL,
	product_id           VARCHAR(20)   NULL,
	territory            VARCHAR(50)   NULL,
	sales_channel        VARCHAR(50)   NULL,
	order_type           VARCHAR(50)   NULL,
	invoice_number       VARCHAR(20)   NULL,
	quantity             VARCHAR(20)   NULL,
	unit_price           VARCHAR(20)   NULL,
	sales_amount         VARCHAR(20)   NULL,
	quarantine_reason    VARCHAR(200)  NOT NULL,
	quarantine_load_date DATETIME      NOT NULL DEFAULT GETDATE()
);


-- Step A: move sentinel foreign keys to quarantine
INSERT INTO stg.quarantine_sales (
	sales_id, sales_date, account_id, product_id, territory, sales_channel, order_type, invoice_number, quantity, unit_price, sales_amount, quarantine_reason
)
SELECT
	TRIM(sales_id), TRIM(sales_date), TRIM(account_id), TRIM(product_id), TRIM(territory),
	TRIM(sales_channel), TRIM(order_type), TRIM(invoice_number), TRIM(quantity), TRIM(unit_price), TRIM(sales_amount),
	CASE
		WHEN TRIM(account_id) = 'ACC99999' AND TRIM(product_id) = 'PRD999' THEN 'Sentinel FK: both account_id=ACC99999 and product_id=PRD999'
		WHEN TRIM(account_id) = 'ACC99999' THEN 'Sentinel FK: account_id=ACC99999'
		WHEN TRIM(product_id) = 'PRD999' THEN 'Sentinel FK: product_id=PRD999'
	END
FROM raw.raw_sales
WHERE TRIM(account_id) = 'ACC99999' OR TRIM(product_id) = 'PRD999';


-- Step B: clean and de-duplicate the valid rows
WITH cleaned AS (
	SELECT
		TRIM(s.sales_id) AS sales_id,
		TRY_CAST(s.sales_date AS DATE) AS sales_date,
		TRIM(s.account_id) AS account_id,
		TRIM(s.product_id) AS product_id,
		NULLIF(TRIM(s.territory), '') AS territory,
		COALESCE(m.canonical_value, NULLIF(TRIM(s.sales_channel), '')) AS sales_channel,
		NULLIF(TRIM(s.order_type), '') AS order_type,
		NULLIF(TRIM(s.invoice_number), '') AS invoice_number,
		TRY_CAST(s.quantity AS INT) AS quantity,
		TRY_CAST(s.unit_price AS DECIMAL(10,2)) AS unit_price,
		TRY_CAST(s.sales_amount AS DECIMAL(12,2)) AS sales_amount
	FROM raw.raw_sales AS s
	LEFT JOIN stg.map_sales_channel AS m
		ON LOWER(TRIM(s.sales_channel)) = LOWER(m.raw_value)
	WHERE TRIM(s.account_id) <> 'ACC99999' AND TRIM(s.product_id) <> 'PRD999'
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY sales_id, sales_date, account_id, product_id, territory, sales_channel, order_type, invoice_number, quantity, unit_price, sales_amount
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_sales (
	sales_id, sales_date, account_id, product_id, territory, sales_channel, order_type, invoice_number, quantity, unit_price, sales_amount, stg_load_date
)
SELECT
	sales_id, sales_date, account_id, product_id, territory, sales_channel, order_type, invoice_number, quantity, unit_price, sales_amount, GETDATE()
FROM deduped
WHERE rn = 1;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: sales_channel case standardised
SELECT DISTINCT sales_channel
FROM stg.stg_sales;


-- Test 2: no sentinel FK left in the staging table
SELECT COUNT(*)
FROM stg.stg_sales
WHERE account_id = 'ACC99999' OR product_id = 'PRD999';
-- Expected: 0


-- Test 3: negative quantity and zero unit_price still present (not changed)
SELECT COUNT(*) AS still_negative_qty FROM stg.stg_sales WHERE quantity < 0;
SELECT COUNT(*) AS still_zero_price FROM stg.stg_sales WHERE unit_price = 0;

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM raw.raw_sales) AS raw_count,
	(SELECT COUNT(*) FROM stg.quarantine_sales) AS quarantined_count,
	(SELECT COUNT(*) FROM stg.stg_sales) AS staged_count;
-- Expected (approx.): raw 1,051,050 = quarantine (~1,702) + staged + duplicates removed (~1,050)


SELECT sales_id, COUNT(*) FROM stg.stg_sales GROUP BY sales_id HAVING COUNT(*) > 1;
-- Expected: 0 rows
