/* =============================================================================
   05_master / master_hcp_account_affiliations.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_hcp_account_affiliations
   Target  : master.master_hcp_account_affiliations
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-015 BR-014 start > end (169)      -> SWAP dates, date_swap_applied = 1
     ISS-016 BR-017 primary overlap         -> primary_overlap_flag (pending Commercial Ops)
     ISS-017 BR-018 status/date mismatch (747) -> status_date_mismatch_flag
     ISS-018 DQ-036 end_date missing, Inactive -> accept as-is
   2. RULES
     swap only where start_date > end_date AND end_date IS NOT NULL
     overlap: re-run the BR-017 self-join AFTER the swap
     mismatch: status 'Active' but dates do not cover as-of date 2026-06-29
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_hcp_account_affiliations;


CREATE TABLE master.master_hcp_account_affiliations (
	affiliation_key             INT IDENTITY(1,1) PRIMARY KEY,
	affiliation_id              VARCHAR(20)  NOT NULL UNIQUE,
	hcp_id                      VARCHAR(20)  NOT NULL,
	account_id                  VARCHAR(20)  NOT NULL,
	role                        NVARCHAR(50) NULL,
	primary_affiliation         BIT          NULL,
	start_date                  DATE         NOT NULL,
	end_date                    DATE         NULL,
	status                      VARCHAR(20)  NULL,
	date_swap_applied           BIT          NOT NULL DEFAULT 0,   -- ISS-015
	primary_overlap_flag        BIT          NOT NULL DEFAULT 0,   -- ISS-016
	status_date_mismatch_flag   BIT          NOT NULL DEFAULT 0,   -- ISS-017
	master_load_date            DATETIME     NOT NULL DEFAULT GETDATE()
);


WITH swapped AS (
	-- ISS-015: swap start/end on reversed rows (only when end_date has a real value)
	SELECT
		affiliation_id, hcp_id, account_id, role, primary_affiliation, status,
		CASE WHEN end_date IS NOT NULL AND start_date > end_date THEN end_date ELSE start_date END AS start_date,
		CASE WHEN end_date IS NOT NULL AND start_date > end_date THEN start_date ELSE end_date END AS end_date,
		CASE WHEN end_date IS NOT NULL AND start_date > end_date THEN 1 ELSE 0 END AS date_swap_applied
	FROM stg.stg_hcp_account_affiliations
),
overlap_pairs AS (
	-- ISS-016: self-join on the SWAPPED data, excluding pairs where both end_dates are NULL
	-- (two open-ended affiliations are not enough evidence of a violation)
	SELECT DISTINCT a.affiliation_id
	FROM swapped AS a
	JOIN swapped AS b
		ON a.hcp_id = b.hcp_id
		AND a.affiliation_id <> b.affiliation_id
		AND a.primary_affiliation = 1 AND b.primary_affiliation = 1
		AND a.status = 'Active' AND b.status = 'Active'
		AND NOT (a.end_date IS NULL AND b.end_date IS NULL)
		AND a.start_date <= COALESCE(b.end_date, '9999-12-31')
		AND b.start_date <= COALESCE(a.end_date, '9999-12-31')
)
INSERT INTO master.master_hcp_account_affiliations (
	affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status,
	date_swap_applied, primary_overlap_flag, status_date_mismatch_flag
)
SELECT
	s.affiliation_id, s.hcp_id, s.account_id, s.role, s.primary_affiliation, s.start_date, s.end_date, s.status,
	s.date_swap_applied,
	CASE WHEN op.affiliation_id IS NOT NULL THEN 1 ELSE 0 END,
	CASE
		WHEN s.status = 'Active'
			AND (s.start_date > '2026-06-29' OR (s.end_date IS NOT NULL AND s.end_date < '2026-06-29'))
		THEN 1 ELSE 0
	END
FROM swapped AS s
LEFT JOIN overlap_pairs AS op ON s.affiliation_id = op.affiliation_id;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: exactly 169 rows swapped
SELECT COUNT(*) 
FROM master.master_hcp_account_affiliations 
WHERE date_swap_applied = 1;
-- Expected: 169


-- Test 2: after the swap, no row has start_date > end_date
SELECT COUNT(*) 
FROM master.master_hcp_account_affiliations 
WHERE end_date IS NOT NULL AND start_date > end_date;
-- Expected: 0


-- Test 3: overlap flag - check whether it is still 9 HCPs or changed because of the swap
SELECT COUNT(DISTINCT hcp_id) 
FROM master.master_hcp_account_affiliations 
WHERE primary_overlap_flag = 1;
-- Compare with 9 (pre-swap figure) - may differ if a swapped row now overlaps


-- Test 4: status_date_mismatch_flag - expected about 747 (may shift slightly after the swap)
SELECT COUNT(*) 
FROM master.master_hcp_account_affiliations 
WHERE status_date_mismatch_flag = 1;

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_hcp_account_affiliations) AS stg_count,
	(SELECT COUNT(*) FROM master.master_hcp_account_affiliations) AS master_count;
-- Expected: both counts = 12,360 (master adds no rows, it only corrects and flags)
