/* =============================================================================
   04_staging / stg_event_registrations.sql
   Purpose : Clean, type and de-duplicate raw_event_registrations
   Source  : raw.raw_event_registrations
   Target  : stg.stg_event_registrations (+ stg.quarantine_event_registrations / mapping table where relevant)
   Grain   : 1 row = 1 HCP registration to an event (registration_id)
   -------------------------------------------------------------------------
   1. DETECT - handled here
     ISS-034 DQ-096  975 exact-duplicate registration_id    -> dedup
     ISS-036 BR-047  attendance_status case (12,815)         -> mapping table
     ISS-037 DQ-101  attendance_status NULL (11,651)         -> NULLIF
     RI              hcp 'HCP99999' / event 'EVT99999'       -> quarantine
   NOT handled in staging, and why
     ISS-035 BR-046  registration after event start (51.16 %) - confirmed error, no known fix -> master flag
   2. RULES
     registration_id, event_id, hcp_id  TRIM, mandatory
     registration_date                  TRY_CAST DATE
     attendance_status                  TRIM -> map_attendance_status -> NULLIF
     follow_up_required                 'Y'/'N' -> BIT
     follow_up_status, source           TRIM + NULLIF
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS stg.stg_event_registrations;
DROP TABLE IF EXISTS stg.quarantine_event_registrations;
DROP TABLE IF EXISTS stg.map_attendance_status;


CREATE TABLE stg.map_attendance_status (
	raw_value        VARCHAR(50) NOT NULL PRIMARY KEY,
	canonical_value  VARCHAR(50) NOT NULL
);


INSERT INTO stg.map_attendance_status (raw_value, canonical_value) VALUES
	('registered', 'Registered'),
	('attended', 'Attended'),
	('no-show', 'No-show'),
	('cancelled', 'Cancelled');


CREATE TABLE stg.stg_event_registrations (
	stg_registration_key   INT IDENTITY(1,1) PRIMARY KEY,
	registration_id        VARCHAR(20)  NOT NULL,
	event_id               VARCHAR(20)  NOT NULL,
	hcp_id                 VARCHAR(20)  NOT NULL,
	registration_date      DATE         NOT NULL,
	attendance_status      VARCHAR(20)  NULL,
	follow_up_required     BIT          NULL,
	follow_up_status       VARCHAR(20)  NULL,
	source                 VARCHAR(20)  NULL,
	stg_load_date          DATETIME     NOT NULL DEFAULT GETDATE()
);


CREATE TABLE stg.quarantine_event_registrations (
	quarantine_key         INT IDENTITY(1,1) PRIMARY KEY,
	registration_id        VARCHAR(20)  NULL,
	event_id               VARCHAR(20)  NULL,
	hcp_id                 VARCHAR(20)  NULL,
	registration_date      VARCHAR(20)  NULL,
	attendance_status      VARCHAR(20)  NULL,
	follow_up_required     VARCHAR(5)   NULL,
	follow_up_status       VARCHAR(20)  NULL,
	source                 VARCHAR(20)  NULL,
	quarantine_reason      VARCHAR(200) NOT NULL,
	quarantine_load_date   DATETIME     NOT NULL DEFAULT GETDATE()
);


-- Step A: move sentinel foreign keys to quarantine
INSERT INTO stg.quarantine_event_registrations (
	registration_id, event_id, hcp_id, registration_date, attendance_status, follow_up_required, follow_up_status, source, quarantine_reason
)
SELECT
	TRIM(registration_id), TRIM(event_id), TRIM(hcp_id), TRIM(registration_date),
	TRIM(attendance_status), TRIM(follow_up_required), TRIM(follow_up_status), TRIM(source),
	CASE
		WHEN TRIM(hcp_id) = 'HCP99999' AND TRIM(event_id) = 'EVT99999' THEN 'Sentinel FK: both hcp_id=HCP99999 and event_id=EVT99999'
		WHEN TRIM(hcp_id) = 'HCP99999' THEN 'Sentinel FK: hcp_id=HCP99999'
		WHEN TRIM(event_id) = 'EVT99999' THEN 'Sentinel FK: event_id=EVT99999'
	END
FROM raw.raw_event_registrations
WHERE TRIM(hcp_id) = 'HCP99999' OR TRIM(event_id) = 'EVT99999';


-- Step B: clean and de-duplicate the valid rows
WITH cleaned AS (
	SELECT
		TRIM(r.registration_id) AS registration_id,
		TRIM(r.event_id) AS event_id,
		TRIM(r.hcp_id) AS hcp_id,
		TRY_CAST(r.registration_date AS DATE) AS registration_date,
		COALESCE(m.canonical_value, NULLIF(TRIM(r.attendance_status), '')) AS attendance_status,
		CASE
			WHEN TRIM(r.follow_up_required) = 'Y' THEN 1
			WHEN TRIM(r.follow_up_required) = 'N' THEN 0
			ELSE NULL
		END AS follow_up_required,
		NULLIF(TRIM(r.follow_up_status), '') AS follow_up_status,
		NULLIF(TRIM(r.source), '') AS source
	FROM raw.raw_event_registrations AS r
	LEFT JOIN stg.map_attendance_status AS m
		ON LOWER(TRIM(r.attendance_status)) = LOWER(m.raw_value)
	WHERE TRIM(r.hcp_id) <> 'HCP99999' AND TRIM(r.event_id) <> 'EVT99999'
),
deduped AS (
	SELECT
		*,
		ROW_NUMBER() OVER (
			PARTITION BY registration_id, event_id, hcp_id, registration_date, attendance_status, follow_up_required, follow_up_status, source
			ORDER BY (SELECT NULL)
		) AS rn
	FROM cleaned
)
INSERT INTO stg.stg_event_registrations (
	registration_id, event_id, hcp_id, registration_date, attendance_status, follow_up_required, follow_up_status, source, stg_load_date
)
SELECT
	registration_id, event_id, hcp_id, registration_date, attendance_status, follow_up_required, follow_up_status, source, GETDATE()
FROM deduped
WHERE rn = 1;


-- ============================================================
-- 4. TEST - case level
-- ============================================================
-- Test 1: attendance_status case standardised
SELECT DISTINCT attendance_status 
FROM stg.stg_event_registrations;
-- Expected: only {Registered, Attended, No-show, Cancelled, NULL}


-- Test 2: no sentinel FK left in the staging table
SELECT COUNT(*) 
FROM stg.stg_event_registrations 
WHERE hcp_id = 'HCP99999' OR event_id = 'EVT99999';
-- Expected: 0


-- Test 3: BR-046 still present (registration_date deliberately not changed)
SELECT COUNT(*) AS changed_rows
FROM raw.raw_event_registrations r
JOIN stg.stg_event_registrations s ON r.registration_id = s.registration_id
WHERE TRY_CAST(r.registration_date AS DATE) <> s.registration_date;
-- Expected: 0

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM raw.raw_event_registrations) AS raw_count,
	(SELECT COUNT(*) FROM stg.quarantine_event_registrations) AS quarantined_count,
	(SELECT COUNT(*) FROM stg.stg_event_registrations) AS staged_count;
-- raw_count must equal quarantined_count + staged_count + exact duplicates removed (about 975)


SELECT registration_id, COUNT(*)
FROM stg.stg_event_registrations
GROUP BY registration_id
HAVING COUNT(*) > 1;
-- Expected: 0 rows
