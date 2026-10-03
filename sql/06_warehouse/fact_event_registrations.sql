/* =============================================================================
   06_warehouse / fact_event_registrations.sql
   Purpose : Fact
   Target  : warehouse.fact_event_registrations
   Grain   : 1 HCP registration to an event
   -------------------------------------------------------------------------
   Keys
     FK date_key, event_key, hcp_key
   ============================================================================= */


DROP TABLE IF EXISTS warehouse.fact_event_registrations;


CREATE TABLE warehouse.fact_event_registrations (
	registration_key                       INT PRIMARY KEY,
	date_key                               INT REFERENCES warehouse.dim_date(date_key),
	event_key                              INT REFERENCES warehouse.dim_event(event_key),
	hcp_key                                INT REFERENCES warehouse.dim_hcp(hcp_key),
	registration_id                        VARCHAR(20)  NOT NULL UNIQUE,
	attendance_status                      VARCHAR(20)  NULL,
	follow_up_required                     BIT          NULL,
	follow_up_status                       VARCHAR(20)  NULL,
	source                                 VARCHAR(20)  NULL,
	registration_after_event_flag          BIT NOT NULL DEFAULT 0,
	missing_attendance_for_past_event_flag BIT NOT NULL DEFAULT 0
);


INSERT INTO warehouse.fact_event_registrations
SELECT
	rg.registration_key,
	YEAR(rg.registration_date)*10000 + MONTH(rg.registration_date)*100 + DAY(rg.registration_date),
	e.event_key, h.hcp_key,
	rg.registration_id, rg.attendance_status, rg.follow_up_required, rg.follow_up_status, rg.source,
	rg.registration_after_event_flag, rg.missing_attendance_for_past_event_flag
FROM master.master_event_registrations AS rg
JOIN master.master_events AS e ON rg.event_id = e.event_id
JOIN master.master_hcp AS h ON rg.hcp_id = h.hcp_id;
