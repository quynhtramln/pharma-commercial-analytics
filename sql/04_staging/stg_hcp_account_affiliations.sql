/* =============================================================================
   04_staging / stg_hcp_account_affiliations.sql
   Purpose : Clean, type and de-duplicate raw_hcp_account_affiliations
   Source  : raw.raw_hcp_account_affiliations
   Target  : stg.stg_hcp_account_affiliations (+ stg.quarantine_hcp_account_affiliations / mapping table where relevant)
   Grain   : 1 row = 1 HCP-account relationship (affiliation_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-014 DQ-029  50 exact-duplicate affiliation_id rows -> dedup
     ISS-017 BR-018  end_date sentinel year 1900 (5,525)     -> NULL (sentinel part only)
     RI              hcp_id 'HCP99999' / account_id 'ACC99999' -> quarantine
   NOT handled in staging, and why
     ISS-015 BR-014  start_date > end_date   cause not confirmed -> master
     ISS-016 BR-017  primary overlap         business decision   -> master
     ISS-017 BR-018  747 real status/date mismatches            -> master
     ISS-018 DQ-036  end_date completeness   root cause open     -> master
   2. RULES
     affiliation_id, hcp_id, account_id  TRIM, mandatory
     role, status                        TRIM + NULLIF
     primary_affiliation                 'Y'/'N' -> BIT
     start_date                          TRY_CAST DATE, order NOT corrected here
     end_date                            TRY_CAST DATE; year 1900 -> NULL
     table                               quarantine first, then exact-duplicate removal
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================

-- ------------------------------------------------------------
-- Step 1: Create table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS stg.stg_hcp_account_affiliations
DROP TABLE IF EXISTS stg.quarantine_hcp_account_affiliations


CREATE TABLE stg.stg_hcp_account_affiliations (
	stg_affiliation_key   INT IDENTITY(1,1) PRIMARY KEY,
	affiliation_id        VARCHAR(20)  NOT NULL,
	hcp_id                VARCHAR(20)  NOT NULL,
	account_id            VARCHAR(20)  NOT NULL,
	role                  NVARCHAR(50) NULL,
	primary_affiliation   BIT          NULL,
	start_date            DATE         NOT NULL,
	end_date              DATE         NULL,
	status                VARCHAR(20)  NULL,
	stg_load_date         DATETIME     NOT NULL DEFAULT GETDATE()
)


CREATE TABLE stg.quarantine_hcp_account_affiliations (
	quarantine_key        INT IDENTITY(1,1) PRIMARY KEY,
	affiliation_id        VARCHAR(20)  NULL,
	hcp_id                VARCHAR(20)  NULL,
	account_id            VARCHAR(20)  NULL,
	role                  VARCHAR(50)  NULL,
	primary_affiliation   VARCHAR(5)   NULL,
	start_date            VARCHAR(20)  NULL,
	end_date              VARCHAR(20)  NULL,
	status                VARCHAR(20)  NULL,
	quarantine_reason     VARCHAR(200) NOT NULL,
	quarantine_load_date  DATETIME     NOT NULL DEFAULT GETDATE()
)


-- ------------------------------------------------------------
-- Step 2: Insert sentinel FK data into the quarantine table
-- ------------------------------------------------------------
INSERT INTO stg.quarantine_hcp_account_affiliations (
	affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status, quarantine_reason
)
SELECT
	TRIM(affiliation_id), TRIM(hcp_id), TRIM(account_id), TRIM(role), TRIM(primary_affiliation),
	TRIM(start_date), TRIM(end_date), TRIM(status),
	CASE
		WHEN TRIM(hcp_id) = 'HCP99999' AND TRIM(account_id) = 'ACC99999'
			THEN 'Sentinel FK: both hcp_id=HCP99999 and account_id=ACC99999'
		WHEN TRIM(hcp_id) = 'HCP99999' THEN 'Sentinel FK: hcp_id=HCP99999'
		WHEN TRIM(account_id) = 'ACC99999' THEN 'Sentinel FK: account_id=ACC99999'
	END
FROM raw.raw_hcp_account_affiliations
WHERE TRIM(hcp_id) = 'HCP99999' OR TRIM(account_id) = 'ACC99999'


-- ------------------------------------------------------------
-- Step 3: Insert cleaned data into the staging table
-- ------------------------------------------------------------
WITH cleaned AS (
	SELECT
		TRIM(affiliation_id) AS affiliation_id,
		TRIM(hcp_id) AS hcp_id,
		TRIM(account_id) AS account_id,
		NULLIF(TRIM(role), '') AS role,
		CASE
			WHEN TRIM(primary_affiliation) = 'Y' THEN 1
			WHEN TRIM(primary_affiliation) = 'N' THEN 0
			ELSE NULL
		END AS primary_affiliation,
		TRY_CAST(start_date AS DATE) AS start_date,
		CASE
			WHEN YEAR(TRY_CAST(end_date AS DATE)) = 1900 THEN NULL
			ELSE TRY_CAST(end_date AS DATE)
		END AS end_date,
		NULLIF(TRIM(status), '') AS status
	FROM raw.raw_hcp_account_affiliations
	WHERE TRIM(hcp_id) <> 'HCP99999' AND TRIM(account_id) <> 'ACC99999'
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_hcp_account_affiliations (
	affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status, stg_load_date
)
SELECT
	affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status, GETDATE()
FROM deduped
WHERE rn = 1


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: end_date in 1900 must become NULL
SELECT r.affiliation_id, r.end_date AS raw_end_date, s.end_date AS stg_end_date
FROM raw.raw_hcp_account_affiliations r
JOIN stg.stg_hcp_account_affiliations s ON r.affiliation_id = s.affiliation_id
WHERE YEAR(TRY_CAST(r.end_date AS DATE)) = 1900

-- Test 2: primary_affiliation Y/N converted to BIT
SELECT DISTINCT primary_affiliation
FROM stg.stg_hcp_account_affiliations
-- Expected: only {0, 1, NULL}

-- Test 3: sentinel FKs are in quarantine, NOT in the staging table
SELECT COUNT(*)
FROM stg.stg_hcp_account_affiliations
WHERE hcp_id = 'HCP99999' OR account_id = 'ACC99999'
-- Expected: 0
SELECT COUNT(*)
FROM stg.quarantine_hcp_account_affiliations
-- Expected: > 0, about 80 + 60 (minus rows matching both conditions)

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
-- V1: row conservation - raw = quarantine + staged + exact duplicates removed
SELECT
	(SELECT COUNT(*) FROM raw.raw_hcp_account_affiliations) AS raw_count,
	(SELECT COUNT(*) FROM stg.quarantine_hcp_account_affiliations) AS quarantined_count,
	(SELECT COUNT(*) FROM stg.stg_hcp_account_affiliations) AS staged_count
-- raw_count must equal quarantined_count + staged_count + exact duplicates removed (checked in V2)

-- V2: count exact duplicates removed (among non-quarantined rows)
WITH non_quarantine AS (
	SELECT affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status
	FROM raw.raw_hcp_account_affiliations
	WHERE TRIM(hcp_id) <> 'HCP99999' AND TRIM(account_id) <> 'ACC99999'
)
SELECT COUNT(*) - (SELECT COUNT(DISTINCT CONCAT(affiliation_id,'|',hcp_id,'|',account_id)) FROM non_quarantine) AS approx_check
FROM non_quarantine

-- V3: no duplicate affiliation_id left in staging
SELECT affiliation_id, COUNT(*)
FROM stg.stg_hcp_account_affiliations
GROUP BY affiliation_id
HAVING COUNT(*) > 1
-- Expected: 0 rows
