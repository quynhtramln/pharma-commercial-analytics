/* =============================================================================
   04_staging / stg_customer_accounts.sql
   Purpose : Clean, type and de-duplicate raw_customer_accounts
   Source  : raw.raw_customer_accounts
   Target  : stg.stg_customer_accounts (+ stg.quarantine_customer_accounts / mapping table where relevant)
   Grain   : 1 row = 1 customer account (account_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-011 DQ-016  6 exact-duplicate account_id rows      -> dedup
     ISS-012 DQ-023  tax_id NULL/blank                       -> NULLIF(TRIM())
     ISS-013 DQ-024  phone NULL/blank                        -> NULLIF(TRIM())
   2. RULES
     account_id, account_name   TRIM, mandatory
     all other columns          TRIM + NULLIF
     table                      exact-duplicate removal
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================

-- ------------------------------------------------------------
-- Step 1: Create table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS stg.stg_customer_accounts
CREATE TABLE stg.stg_customer_accounts (
	stg_account_key    INT IDENTITY(1,1) PRIMARY KEY,
	account_id         VARCHAR(20)    NOT NULL,
	account_name       NVARCHAR(150)  NOT NULL,
	account_type       VARCHAR(50)    NULL,
	city               NVARCHAR(100)  NULL,
	territory          VARCHAR(50)    NULL,
	tax_id             VARCHAR(20)    NULL,
	phone              VARCHAR(15)    NULL,
	status             VARCHAR(20)    NULL,
	parent_account_id  VARCHAR(20)    NULL,
	stg_load_date      DATETIME       NOT NULL DEFAULT GETDATE()
)


-- ------------------------------------------------------------
-- Step 2: Insert cleaned data into the table
-- ------------------------------------------------------------
WITH cleaned AS (
	SELECT
		TRIM(account_id) AS account_id,
		TRIM(account_name) AS account_name,
		NULLIF(TRIM(account_type), '') AS account_type,
		NULLIF(TRIM(city), '') AS city,
		NULLIF(TRIM(territory), '') AS territory,
		NULLIF(TRIM(tax_id), '') AS tax_id,
		NULLIF(TRIM(phone), '') AS phone,
		NULLIF(TRIM(status), '') AS status,
		NULLIF(TRIM(parent_account_id), '') AS parent_account_id
	FROM raw.raw_customer_accounts
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY account_id, account_name, account_type, city, territory, tax_id, phone, status, parent_account_id
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_customer_accounts (
	account_id, account_name, account_type, city, territory, tax_id, phone, status, parent_account_id, stg_load_date
)
SELECT
	account_id, account_name, account_type, city, territory, tax_id, phone, status, parent_account_id, GETDATE()
FROM deduped
WHERE rn = 1


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: a previously duplicated account_id now has exactly 1 row
SELECT account_id, COUNT(*) AS cnt
FROM stg.stg_customer_accounts
WHERE account_id IN (SELECT account_id FROM raw.raw_customer_accounts GROUP BY account_id HAVING COUNT(*) > 1)
GROUP BY account_id


-- Test 2: blank tax_id / phone in raw must be NULL in staging
SELECT TOP 5 r.tax_id AS raw_tax_id, s.tax_id AS stg_tax_id
FROM raw.raw_customer_accounts r JOIN stg.stg_customer_accounts s ON r.account_id = s.account_id
WHERE TRIM(r.tax_id) = ''


-- Test 3: valid phone keeps all 10 digits (no data-type truncation)
SELECT TOP 5 r.phone AS raw_phone, s.phone AS stg_phone
FROM raw.raw_customer_accounts r JOIN stg.stg_customer_accounts s ON r.account_id = s.account_id
WHERE r.phone IS NOT NULL AND LEN(TRIM(r.phone)) = 10


-- Expected: Test 1 -> every cnt = 1; Test 2 -> stg_tax_id all NULL; Test 3 -> both columns identical.
-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
-- V1: Row count reconciliation
SELECT
	(SELECT COUNT(*) FROM raw.raw_customer_accounts) AS raw_count,
	(SELECT COUNT(*) FROM stg.stg_customer_accounts) AS stg_count,
	(SELECT COUNT(*) FROM raw.raw_customer_accounts) - (SELECT COUNT(*) FROM stg.stg_customer_accounts) AS removed


-- V2: no duplicate account_id left
SELECT account_id, COUNT(*) AS cnt
FROM stg.stg_customer_accounts
ROUP BY account_id
HAVING COUNT(*) > 1


-- V3: no phone with a wrong length (guards against type errors)
SELECT COUNT(*) AS bad_length_phone
FROM stg.stg_customer_accounts
WHERE phone IS NOT NULL AND LEN(phone) <> 10


-- Expected: V1 -> raw = 1,106, stg = 1,100, removed = 6; V2 -> 0 rows; V3 -> 0.
