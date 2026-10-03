/* =============================================================================
   05_master / master_hcp.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_hcp
   Target  : master.master_hcp
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-002/006 email, phone NULL   -> field optional, no action
     ISS-010 BR-009 13 active HCPs w/o interaction in 90 days -> FALSE POSITIVE (GETDATE() used);
             re-run at as-of date 2026-06-29 -> 0 violations
   2. RULES
     copy stg_hcp unchanged
     hcp_key  IDENTITY surrogate PRIMARY KEY
     hcp_id   UNIQUE (validated in staging: 5,200 rows, 100 % unique)
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_hcp;


CREATE TABLE master.master_hcp (
	hcp_key           INT IDENTITY(1,1) PRIMARY KEY,
	hcp_id            VARCHAR(20)   NOT NULL UNIQUE,
	hcp_name          VARCHAR(150)  NOT NULL,
	hcp_type          VARCHAR(50)   NULL,
	specialty         VARCHAR(100)  NULL,
	city              VARCHAR(100)  NULL,
	territory         VARCHAR(50)   NULL,
	email             VARCHAR(255)  NULL,
	phone             VARCHAR(15)   NULL,
	status            VARCHAR(20)   NULL,
	master_load_date  DATETIME      NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_hcp (
	hcp_id, hcp_name, hcp_type, specialty, city, territory, email, phone, status
)
SELECT
	hcp_id, hcp_name, hcp_type, specialty, city, territory, email, phone, status
FROM stg.stg_hcp;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: data identical to stg_hcp, nothing changed
SELECT COUNT(*) AS mismatch
FROM master.master_hcp m
JOIN stg.stg_hcp s ON m.hcp_id = s.hcp_id
WHERE CHECKSUM(m.hcp_name, m.hcp_type, m.specialty, m.city, m.territory, m.email, m.phone, m.status)
	<> CHECKSUM(s.hcp_name, s.hcp_type, s.specialty, s.city, s.territory, s.email, s.phone, s.status);
-- Expected: 0


-- Test 2: hcp_id is unique (UNIQUE constraint works)
SELECT hcp_id, COUNT(*)
FROM master.master_hcp
GROUP BY hcp_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_hcp) AS stg_count,
	(SELECT COUNT(*) FROM master.master_hcp) AS master_count;
-- Expected: both counts = 5,200
