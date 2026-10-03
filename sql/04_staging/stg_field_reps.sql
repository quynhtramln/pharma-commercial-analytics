/* =============================================================================
   04_staging / stg_field_reps.sql
   Purpose : Clean, type and de-duplicate raw_field_reps
   Source  : raw.raw_field_reps
   Target  : stg.stg_field_reps (+ stg.quarantine_field_reps / mapping table where relevant)
   Grain   : 1 row = 1 field rep (rep_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-022 DQ-051  1 exact-duplicate rep_id               -> dedup
     ISS-025 DQ-055  territory blank (6)                     -> NULLIF
     ISS-026 DQ-058  hire_date sentinel '2026-99-99'         -> TRY_CAST -> NULL
   NOT handled in staging, and why
     ISS-024 BR-028  base_city <> territory (153, 69.23 %) - DELIBERATELY not fixed here:
                     needs Field Force Management confirmation -> corrected in master
     ISS-023 BR-026  merged into DQ-055
   2. RULES
     rep_id, rep_name                    TRIM, mandatory
     territory, status, specialization   TRIM + NULLIF
     base_city                           TRIM + NULLIF (kept as is)
     hire_date                           TRY_CAST DATE
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS stg.stg_field_reps


CREATE TABLE stg.stg_field_reps (
	stg_rep_key      INT IDENTITY(1,1) PRIMARY KEY,
	rep_id           VARCHAR(20)   NOT NULL,
	rep_name         NVARCHAR(100) NOT NULL,
	territory        VARCHAR(50)   NULL,
	base_city        NVARCHAR(100) NULL,
	hire_date        DATE          NULL,
	status           VARCHAR(20)   NULL,
	specialization   NVARCHAR(100) NULL,
	stg_load_date    DATETIME      NOT NULL DEFAULT GETDATE()
)


WITH cleaned AS (
	SELECT
		TRIM(rep_id) AS rep_id,
		TRIM(rep_name) AS rep_name,
		NULLIF(TRIM(territory), '') AS territory,
		NULLIF(TRIM(base_city), '') AS base_city,
		TRY_CAST(hire_date AS DATE) AS hire_date,
		NULLIF(TRIM(status), '') AS status,
		NULLIF(TRIM(specialization), '') AS specialization
	FROM raw.raw_field_reps
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY rep_id, rep_name, territory, base_city, hire_date, status, specialization
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_field_reps (
	rep_id, rep_name, territory, base_city, hire_date, status, specialization, stg_load_date
)
SELECT
	rep_id, rep_name, territory, base_city, hire_date, status, specialization, GETDATE()
FROM deduped
WHERE rn = 1


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: hire_date sentinel must become NULL
SELECT r.rep_id, r.hire_date AS raw_hire_date, s.hire_date AS stg_hire_date
FROM raw.raw_field_reps r JOIN stg.stg_field_reps s ON r.rep_id = s.rep_id
WHERE r.hire_date = '2026-99-99'


-- Test 2: base_city / territory mismatch (BR-028) must still be present - staging does not fix it
SELECT COUNT(*) AS changed_rows
FROM raw.raw_field_reps r
JOIN stg.stg_field_reps s ON r.rep_id = s.rep_id
WHERE TRIM(r.base_city) <> s.base_city
	OR TRIM(r.territory) <> s.territory
-- Expected: 0 (confirms staging does NOT fix it, by design)

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
-- V1: Row count reconciliation
SELECT
	(SELECT COUNT(*) FROM raw.raw_field_reps) AS raw_count,
	(SELECT COUNT(*) FROM stg.stg_field_reps) AS stg_count;
-- Expected: raw = 221, stg = 220


-- V2: no duplicate rep_id left
SELECT rep_id, COUNT(*)
FROM stg.stg_field_reps
GROUP BY rep_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows
