/* =============================================================================
   05_master / master_customer_accounts.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_customer_accounts
   Target  : master.master_customer_accounts
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-012 tax_id NULL -> keep NULL (business: no backfill)
     ISS-013 phone NULL  -> keep NULL
   2. RULES
     copy stg_customer_accounts unchanged
     account_key IDENTITY PK, account_id UNIQUE
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_customer_accounts;


CREATE TABLE master.master_customer_accounts (
	account_key        INT IDENTITY(1,1) PRIMARY KEY,
	account_id         VARCHAR(20)    NOT NULL UNIQUE,
	account_name       NVARCHAR(150)  NOT NULL,
	account_type       VARCHAR(50)    NULL,
	city               NVARCHAR(100)  NULL,
	territory          VARCHAR(50)    NULL,
	tax_id             VARCHAR(20)    NULL,
	phone              VARCHAR(15)    NULL,
	status             VARCHAR(20)    NULL,
	parent_account_id  VARCHAR(20)    NULL,
	master_load_date   DATETIME       NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_customer_accounts (
	account_id, account_name, account_type, city, territory, tax_id, phone, status, parent_account_id
)
SELECT
	account_id, account_name, account_type, city, territory, tax_id, phone, status, parent_account_id
FROM stg.stg_customer_accounts;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
SELECT COUNT(*) AS mismatch
FROM master.master_customer_accounts m
JOIN stg.stg_customer_accounts s ON m.account_id = s.account_id
WHERE CHECKSUM(m.account_name, m.account_type, m.city, m.territory, m.tax_id, m.phone, m.status, m.parent_account_id)
	<> CHECKSUM(s.account_name, s.account_type, s.city, s.territory, s.tax_id, s.phone, s.status, s.parent_account_id);
-- Expected: 0

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_customer_accounts) AS stg_count,
	(SELECT COUNT(*) FROM master.master_customer_accounts) AS master_count;
-- Expected: 1,100 = 1,100
