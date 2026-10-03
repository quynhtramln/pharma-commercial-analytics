/* =============================================================================
   08_analysis / q9_data_quality_trust.sql
   Purpose : Q9 - How does data quality affect reporting trust?
   Source  : warehouse.*, mart.*
   -------------------------------------------------------------------------
   Result (as of 2026-06-29)
     Overall DQ score 72.9 %; registrations 50.2 % (registered after event start); sales excluded by DQ = 0.04 % of value.
   Read with
     docs/06_insights_and_recommendations.md
   ============================================================================= */


WITH flags AS (
	-- fact_sales (6 flags)
	SELECT 'fact_sales' AS tbl, 'pre_launch_sales_flag' AS flag, COUNT(*) AS flagged_rows,
		(SELECT COUNT(*) FROM warehouse.fact_sales) AS total_rows
	FROM warehouse.fact_sales WHERE pre_launch_sales_flag = 1
	UNION ALL
	SELECT 'fact_sales', 'negative_quantity_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_sales)
	FROM warehouse.fact_sales WHERE negative_quantity_flag = 1
	UNION ALL
	SELECT 'fact_sales', 'non_positive_price_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_sales)
	FROM warehouse.fact_sales WHERE non_positive_price_flag = 1
	UNION ALL
	SELECT 'fact_sales', 'missing_sales_channel_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_sales)
	FROM warehouse.fact_sales WHERE missing_sales_channel_flag = 1
	UNION ALL
	SELECT 'fact_sales', 'missing_invoice_number_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_sales)
	FROM warehouse.fact_sales WHERE missing_invoice_number_flag = 1
	UNION ALL
	SELECT 'fact_sales', 'amount_mismatch_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_sales)
	FROM warehouse.fact_sales WHERE amount_mismatch_flag = 1
	UNION ALL
	-- fact_interactions (3 flags)
	SELECT 'fact_interactions', 'pre_hire_interaction_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_interactions)
	FROM warehouse.fact_interactions WHERE pre_hire_interaction_flag = 1
	UNION ALL
	SELECT 'fact_interactions', 'negative_duration_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_interactions)
	FROM warehouse.fact_interactions WHERE negative_duration_flag = 1
	UNION ALL
	SELECT 'fact_interactions', 'missing_outcome_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_interactions)
	FROM warehouse.fact_interactions WHERE missing_outcome_flag = 1
	UNION ALL
	-- fact_event_registrations (2 flags)
	SELECT 'fact_event_registrations', 'registration_after_event_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_event_registrations)
	FROM warehouse.fact_event_registrations WHERE registration_after_event_flag = 1
	UNION ALL
	SELECT 'fact_event_registrations', 'missing_attendance_for_past_event_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_event_registrations)
	FROM warehouse.fact_event_registrations WHERE missing_attendance_for_past_event_flag = 1
	UNION ALL
	-- fact_hcp_account_affiliation (3 flags)
	SELECT 'fact_hcp_account_affiliation', 'date_swap_applied', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_hcp_account_affiliation)
	FROM warehouse.fact_hcp_account_affiliation WHERE date_swap_applied = 1
	UNION ALL
	SELECT 'fact_hcp_account_affiliation', 'primary_overlap_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_hcp_account_affiliation)
	FROM warehouse.fact_hcp_account_affiliation WHERE primary_overlap_flag = 1
	UNION ALL
	SELECT 'fact_hcp_account_affiliation', 'status_date_mismatch_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_hcp_account_affiliation)
	FROM warehouse.fact_hcp_account_affiliation WHERE status_date_mismatch_flag = 1
	UNION ALL
	-- fact_campaign (5 flags)
	SELECT 'fact_campaign', 'missing_campaign_name_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_campaign)
	FROM warehouse.fact_campaign WHERE missing_campaign_name_flag = 1
	UNION ALL
	SELECT 'fact_campaign', 'missing_campaign_type_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_campaign)
	FROM warehouse.fact_campaign WHERE missing_campaign_type_flag = 1
	UNION ALL
	SELECT 'fact_campaign', 'start_after_end_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_campaign)
	FROM warehouse.fact_campaign WHERE start_after_end_flag = 1
	UNION ALL
	SELECT 'fact_campaign', 'negative_target_hcp_count_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_campaign)
	FROM warehouse.fact_campaign WHERE negative_target_hcp_count_flag = 1
	UNION ALL
	SELECT 'fact_campaign', 'missing_status_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.fact_campaign)
	FROM warehouse.fact_campaign WHERE missing_status_flag = 1
	UNION ALL
	-- dim_event (1 flag - lives in a dimension, not a fact, but is still a DQ flag worth tracking)
	SELECT 'dim_event', 'pre_launch_event_flag', COUNT(*), (SELECT COUNT(*) FROM warehouse.dim_event)
	FROM warehouse.dim_event WHERE pre_launch_event_flag = 1
)
SELECT
	tbl, flag, flagged_rows, total_rows,
	CAST(ROUND(flagged_rows * 100.0 / total_rows, 2) AS DECIMAL(5,2)) AS flag_pct
FROM flags
ORDER BY flag_pct DESC;
