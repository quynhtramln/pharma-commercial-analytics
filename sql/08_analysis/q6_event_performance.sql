/* =============================================================================
   08_analysis / q6_event_performance.sql
   Purpose : Q6 - Which events generate strong attendance and follow-up?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     Attendance 25.0 %, no-show 25.0 %, follow-up completion 33.5 %, near-identical across event types.
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


SELECT
	e.event_type,
	COUNT(*) AS total_registrations,
	SUM(CASE WHEN r.attendance_status = 'Attended' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS attendance_rate_pct,
	SUM(CASE WHEN r.attendance_status = 'No-show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS no_show_rate_pct,
	SUM(CASE WHEN r.follow_up_required = 1 AND r.follow_up_status = 'Completed' THEN 1 ELSE 0 END) * 100.0
		/ NULLIF(SUM(CASE WHEN r.follow_up_required = 1 THEN 1 ELSE 0 END),0) AS followup_completion_pct
FROM warehouse.fact_event_registrations AS r
JOIN warehouse.dim_event AS e ON r.event_key = e.event_key
GROUP BY e.event_type
ORDER BY attendance_rate_pct DESC;
