/* =============================================================================
   05_master / master_event_registrations.sql
   Purpose : Trusted entity: surrogate key, confirmed business fixes with audit, DQ flags
   Source  : stg.stg_event_registrations
   Target  : master.master_event_registrations
   -------------------------------------------------------------------------
   1. DETECT - decisions
     ISS-035 BR-046 registration after event start -> registration_after_event_flag
     ISS-037 DQ-101 attendance NULL for past event  -> missing_attendance_for_past_event_flag
   2. RULES
     join stg_events.start_date
     past event = start_date < as-of date 2026-06-29
   ============================================================================= */

-- ============================================================
-- 3. TRANSFORM
-- ============================================================
DROP TABLE IF EXISTS master.master_event_registrations;


CREATE TABLE master.master_event_registrations (
	registration_key                          INT IDENTITY(1,1) PRIMARY KEY,
	registration_id                           VARCHAR(20)  NOT NULL UNIQUE,
	event_id                                  VARCHAR(20)  NOT NULL,
	hcp_id                                    VARCHAR(20)  NOT NULL,
	registration_date                         DATE         NOT NULL,
	attendance_status                         VARCHAR(20)  NULL,
	follow_up_required                        BIT          NULL,
	follow_up_status                          VARCHAR(20)  NULL,
	source                                    VARCHAR(20)  NULL,
	registration_after_event_flag             BIT          NOT NULL DEFAULT 0,   -- ISS-035
	missing_attendance_for_past_event_flag    BIT          NOT NULL DEFAULT 0,   -- ISS-037
	master_load_date                          DATETIME     NOT NULL DEFAULT GETDATE()
);


INSERT INTO master.master_event_registrations (
	registration_id, event_id, hcp_id, registration_date, attendance_status,
	follow_up_required, follow_up_status, source,
	registration_after_event_flag, missing_attendance_for_past_event_flag
)
SELECT
	r.registration_id, r.event_id, r.hcp_id, r.registration_date, r.attendance_status,
	r.follow_up_required, r.follow_up_status, r.source,
	CASE
		WHEN e.start_date IS NOT NULL AND r.registration_date > e.start_date
		THEN 1 ELSE 0
	END,
	CASE
		WHEN e.start_date IS NOT NULL AND e.start_date < '2026-06-29' AND r.attendance_status IS NULL
		THEN 1 ELSE 0
	END
FROM stg.stg_event_registrations AS r
LEFT JOIN stg.stg_events AS e ON r.event_id = e.event_id;

-- ============================================================
-- 4. TEST - case level
-- ============================================================
SELECT COUNT(*) 
FROM master.master_event_registrations 
WHERE registration_after_event_flag = 1;
-- Expected: about 334,011 (if different: check the 702 quarantined rows and remaining duplicates)


SELECT COUNT(*) 
FROM master.master_event_registrations 
WHERE missing_attendance_for_past_event_flag = 1;
-- Expected: about 11,651 (differs from the profiling figure because GETDATE() was replaced by the fixed as-of date - not a bug)

-- ============================================================
-- 5. VALIDATE - table level
-- ============================================================
SELECT
	(SELECT COUNT(*) FROM stg.stg_event_registrations) AS stg_count,
	(SELECT COUNT(*) FROM master.master_event_registrations) AS master_count;
-- Expected: 649,300 = 649,300
