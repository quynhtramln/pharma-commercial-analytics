/* =============================================================================
   04_staging / stg_hcp.sql
   Purpose : Clean, type and de-duplicate raw_hcp
   Source  : raw.raw_hcp
   Target  : stg.stg_hcp (+ stg.quarantine_hcp / mapping table where relevant)
   Grain   : 1 row = 1 HCP (hcp_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-001 DQ-002  20 exact-duplicate hcp_id rows          -> dedup
     ISS-002 DQ-009  email NULL/blank                        -> NULLIF(TRIM())
     ISS-003 DQ-142  email sentinel 'invalid-email'          -> NULL
     ISS-006 DQ-012  phone NULL/blank                        -> NULLIF(TRIM())
     ISS-007 DQ-143  phone sentinel '12345'                  -> NULL
   NOT handled in staging, and why
     ISS-004/005/008/009  merged - disappear after dedup / sentinel fix
     ISS-010 BR-009       cross-table (closed as false positive)
   2. RULES
     hcp_id, hcp_name                              TRIM, mandatory
     hcp_type, specialty, city, territory, status  TRIM + NULLIF
     email                                         'invalid-email' -> NULL
     phone                                         VARCHAR(15), not INT (keeps leading 0); '12345' -> NULL
     table                                         exact-duplicate removal, ROW_NUMBER over all columns
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================

-- ------------------------------------------------------------
-- Step 1: Create table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS stg.stg_hcp;
CREATE TABLE stg.stg_hcp (
	stg_hcp_key    INT IDENTITY(1,1) PRIMARY KEY,
	hcp_id         VARCHAR(20)   NOT NULL,
	hcp_name       VARCHAR(150)  NOT NULL,
	hcp_type       VARCHAR(50)   NULL,
	specialty      VARCHAR(100)  NULL,
	city           VARCHAR(100)  NULL,
	territory      VARCHAR(50)   NULL,
	email          VARCHAR(255)  NULL,
	phone          VARCHAR(15)   NULL,
	status         VARCHAR(20)   NULL,
	stg_load_date  DATETIME      NOT NULL DEFAULT GETDATE()
)


-- ------------------------------------------------------------
-- Step 2: Insert cleaned data into the table
-- ------------------------------------------------------------
WITH cleaned AS (
	SELECT
		TRIM(hcp_id) AS hcp_id,
		TRIM(hcp_name) AS hcp_name,
		NULLIF(TRIM(hcp_type), '') AS hcp_type,
		NULLIF(TRIM(specialty), '') AS specialty,
		NULLIF(TRIM(city), '') AS city,
		NULLIF(TRIM(territory), '') AS territory,
		CASE
			WHEN TRIM(email) = 'invalid-email' THEN NULL
			ELSE NULLIF(TRIM(email), '')
		END AS email,
		CASE
			WHEN TRIM(phone) = '12345' THEN NULL
			ELSE NULLIF(TRIM(phone), '')
		END AS phone,
		NULLIF(TRIM(status), '') AS status
	FROM raw.raw_hcp
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY hcp_id, hcp_name, hcp_type, specialty, city, territory, email, phone, status
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_hcp (
	hcp_id, hcp_name, hcp_type, specialty, city, territory, email, phone, status, stg_load_date
)
SELECT
	hcp_id, hcp_name, hcp_type, specialty, city, territory, email, phone, status, GETDATE()
FROM deduped
WHERE rn = 1


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: email 'invalid-email' must become NULL
SELECT r.hcp_id, r.email AS raw_email, s.email AS stg_email
FROM raw.raw_hcp r JOIN stg.stg_hcp s ON r.hcp_id = s.hcp_id
WHERE r.email = 'invalid-email'

-- Test 2: phone '12345' must become NULL
SELECT r.hcp_id, r.phone AS raw_phone, s.phone AS stg_phone
FROM raw.raw_hcp r JOIN stg.stg_hcp s ON r.hcp_id = s.hcp_id
WHERE r.phone = '12345'

-- Test 3: valid phone keeps all 10 digits including the leading 0
SELECT TOP 5 r.phone AS raw_phone, s.phone AS stg_phone
FROM raw.raw_hcp r JOIN stg.stg_hcp s ON r.hcp_id = s.hcp_id
WHERE r.phone <> '12345' AND LEN(TRIM(r.phone)) = 10

-- Test 4: a previously duplicated hcp_id now has exactly 1 row
SELECT hcp_id, COUNT(*) AS cnt
FROM stg.stg_hcp
WHERE hcp_id IN (SELECT hcp_id FROM raw.raw_hcp GROUP BY hcp_id HAVING COUNT(*) > 1)
GROUP BY hcp_id

-- Expected: Test 1 & 2 -> all NULL; Test 3 -> both columns identical; Test 4 -> every cnt = 1.
-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================

-- V1: Row count reconciliation
SELECT
	(SELECT COUNT(*) FROM raw.raw_hcp) AS raw_count,
	(SELECT COUNT(*) FROM stg.stg_hcp) AS stg_count,
	(SELECT COUNT(*) FROM raw.raw_hcp) - (SELECT COUNT(*) FROM stg.stg_hcp) AS removed

-- V2: no duplicate hcp_id left
SELECT hcp_id, COUNT(*) AS cnt
FROM stg.stg_hcp
GROUP BY hcp_id
HAVING COUNT(*) > 1

-- V3: no sentinel value left
SELECT COUNT(*) AS remaining_sentinel
FROM stg.stg_hcp
WHERE email = 'invalid-email' OR phone = '12345'

-- V4: no phone lost its leading 0
SELECT COUNT(*) AS bad_length_phone
FROM stg.stg_hcp
WHERE phone IS NOT NULL AND LEN(phone) <> 10

-- Expected: V1 -> raw = 5,220, stg = 5,200, removed = 20; V2 -> 0 rows; V3 -> 0; V4 -> 0.
