-- ============================================================
-- VALIDITY CHECK
-- File name: validity_checks.sql
-- Purpose: Validate values against expected formats, patterns, characters, lengths, domains, and date constraints
-- Rules covered: Validity-related DQ rules in the Data Quality Rule Catalog
-- Scope: raw_hcp, raw_customer_accounts, hcp_account_affiliations, raw_products, raw_field_reps, raw_interactions, raw_events, raw_event_registrations, raw_sales, raw_campaigns
-- Source: Data Quality Rule Catalog
-- Expected Result: Each rule should return 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ============================================================
-- 01. raw_hcp
-- ============================================================

-- ------------------------------------------------------------
-- email
-- DQ-010: email must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE email IS NOT NULL AND TRIM(email) <> ''
	AND (email NOT LIKE '%@%'
		OR email NOT LIKE '%@%.%'
		OR email LIKE '% %')


-- ------------------------------------------------------------
-- phone
-- DQ-013: phone must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE phone IS NOT NULL AND TRIM(phone) <> ''
	AND (
		(phone NOT LIKE '0_________' AND phone NOT LIKE '+84__________')
		OR phone LIKE '% %')


-- ============================================================
-- 02. raw_customer_accounts
-- ============================================================

-- ------------------------------------------------------------
-- account_name
-- DQ-018: account_name must not contain invalid or unexpected encoding characters
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_customer_accounts
WHERE account_name IS NOT NULL AND TRIM(account_name) != ''
	AND (
		account_name LIKE '%[!@#$%^&*()_+=<>{}~`";:,./\|]%'
		OR account_name LIKE '%Ã%'
		OR account_name LIKE '%Â%'
		OR account_name LIKE '%Ä%'
		OR account_name LIKE '%Æ%'
		OR account_name LIKE '%â€%'
	)


-- ------------------------------------------------------------
-- phone
-- DQ-025: phone must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_customer_accounts
WHERE phone IS NOT NULL AND TRIM(phone) <> ''
	AND ((phone NOT LIKE '0_________' AND phone NOT LIKE '+84__________')
		OR phone LIKE '% %')


-- ============================================================
-- 03. hcp_account_affiliations
-- ============================================================

-- ------------------------------------------------------------
-- affiliation_id
-- DQ-028: affiliation_id must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp_account_affiliations), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp_account_affiliations
WHERE affiliation_id IS NOT NULL AND TRIM(affiliation_id) <> ''
	AND (
		affiliation_id NOT LIKE 'AFF%'
		OR affiliation_id LIKE '% %'
		OR PATINDEX('%[^0-9]%', SUBSTRING(affiliation_id, 4, LEN(affiliation_id))) > 0
	)


-- ------------------------------------------------------------
-- start_date
-- DQ-035: start_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT affiliation_id, start_date
FROM raw.raw_hcp_account_affiliations
WHERE start_date IS NOT NULL AND TRIM(start_date) <> ''
	AND TRY_CAST(start_date AS DATE) IS NULL


-- ------------------------------------------------------------
-- end_date
-- DQ-037: end_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT affiliation_id, end_date
FROM raw.raw_hcp_account_affiliations
WHERE end_date IS NOT NULL AND TRIM(end_date) <> ''
	AND TRY_CAST(end_date AS DATE) IS NULL


-- ============================================================
-- 04. raw_products
-- ============================================================

-- ------------------------------------------------------------
-- product_name
-- DQ-042: product_name must not contain invalid or unexpected encoding characters
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_products), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_products
WHERE product_name IS NOT NULL AND TRIM(product_name) != ''
	AND (
		product_name LIKE '%[!@#$%^&*()_+=<>{}~`";:,./\|]%'
		OR product_name LIKE '%Ã%'
		OR product_name LIKE '%Â%'
		OR product_name LIKE '%Ä%'
		OR product_name LIKE '%Æ%'
		OR product_name LIKE '%â€%'
	)


-- ------------------------------------------------------------
-- launch_date
-- DQ-048: launch_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT product_id, launch_date
FROM raw.raw_products
WHERE launch_date IS NOT NULL AND TRIM(launch_date) <> ''
	AND TRY_CAST(launch_date AS DATE) IS NULL


-- ============================================================
-- 05. raw_field_reps
-- ============================================================

-- ------------------------------------------------------------
-- rep_name
-- DQ-053: rep_name must not contain invalid or unexpected encoding characters
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE rep_name IS NOT NULL AND TRIM(rep_name) != ''
	AND (
		rep_name LIKE '%[!@#$%^&*()_+=<>{}~`";:,./\|]%'
		OR rep_name LIKE '%Ã%'
		OR rep_name LIKE '%Â%'
		OR rep_name LIKE '%Ä%'
		OR rep_name LIKE '%Æ%'
		OR rep_name LIKE '%â€%'
	)


-- ------------------------------------------------------------
-- hire_date
-- DQ-058: hire_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE hire_date IS NOT NULL AND TRIM(hire_date) <> ''
	AND TRY_CAST(hire_date AS DATE) IS NULL


-- ============================================================
-- 06. raw_interactions
-- ============================================================

-- ------------------------------------------------------------
-- interaction_id
-- DQ-062: interaction_id must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_interactions), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_interactions
WHERE interaction_id IS NOT NULL AND TRIM(interaction_id) != ''
	AND (
		interaction_id NOT LIKE 'INT%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(interaction_id, 4, LEN(interaction_id))) > 0
		OR interaction_id LIKE '% %'
	)


-- ------------------------------------------------------------
-- interaction_datetime
-- DQ-065: interaction_datetime must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT interaction_id, interaction_datetime
FROM raw.raw_interactions
WHERE interaction_datetime IS NOT NULL AND TRIM(interaction_datetime) <> ''
	AND TRY_CAST(interaction_datetime AS DATE) IS NULL


-- ------------------------------------------------------------
-- duration_minutes
-- DQ-073: duration_minutes must contain numeric values
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_interactions), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_interactions
WHERE duration_minutes IS NOT NULL AND TRIM(duration_minutes) <> ''
	AND TRY_CAST(duration_minutes AS DECIMAL(18,2)) IS NULL


-- ------------------------------------------------------------
-- engagement_score
-- DQ-076: engagement_score must contain numeric values
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_interactions), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_interactions
WHERE engagement_score IS NOT NULL AND TRIM(engagement_score) != ''
	AND TRY_CAST(engagement_score AS FLOAT) IS NOT NULL
	AND TRY_CAST(engagement_score AS FLOAT) < 0


-- ============================================================
-- 07. raw_events
-- ============================================================

-- ------------------------------------------------------------
-- event_id
-- DQ-078: event_id must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_events
WHERE event_id IS NOT NULL AND TRIM(event_id) != ''
	AND (
		event_id NOT LIKE 'EVT%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(event_id, 4, LEN(event_id))) > 0
		OR event_id LIKE '% %'
	)


-- ------------------------------------------------------------
-- event_name
-- DQ-081: event_name must not contain invalid or unexpected encoding characters
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_events
WHERE event_name IS NOT NULL AND TRIM(event_name) != ''
	AND (
		event_name LIKE '%[!@#$%^&*()_+=<>{}~`";:,./\|]%'
		OR event_name LIKE '%Ã%'
		OR event_name LIKE '%Â%'
		OR event_name LIKE '%Ä%'
		OR event_name LIKE '%Æ%'
		OR event_name LIKE '%â€%'
	)


-- ------------------------------------------------------------
-- start_date
-- DQ-085: start_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT event_id, start_date
FROM raw.raw_events
WHERE start_date IS NOT NULL AND TRIM(start_date) <> ''
	AND TRY_CAST(start_date AS DATE) IS NULL


-- ------------------------------------------------------------
-- end_date
-- DQ-087: end_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT event_id, end_date
FROM raw.raw_events
WHERE end_date IS NOT NULL AND TRIM(end_date) <> ''
	AND TRY_CAST(end_date AS DATE) IS NULL


-- ------------------------------------------------------------
-- budget
-- DQ-092: budget must contain numeric values
-- ------------------------------------------------------------
[SQL query]


-- ============================================================
-- 08. raw_event_registrations
-- ============================================================

-- ------------------------------------------------------------
-- registration_id
-- DQ-095: registration_id must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_event_registrations), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_event_registrations
WHERE registration_id IS NOT NULL AND TRIM(registration_id) != ''
	AND (
		registration_id NOT LIKE 'REG%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(registration_id, 4, LEN(registration_id))) > 0
		OR registration_id LIKE '% %'
	)


-- ------------------------------------------------------------
-- registration_date
-- DQ-100: registration_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT registration_id, registration_date
FROM raw.raw_event_registrations
WHERE registration_date IS NOT NULL AND TRIM(registration_date) <> ''
	AND TRY_CAST(registration_date AS DATE) IS NULL


-- ============================================================
-- 09. raw_sales
-- ============================================================

-- ------------------------------------------------------------
-- sales_id
-- DQ-106: sales_id must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_event_registrations), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_event_registrations
WHERE registration_id IS NOT NULL AND TRIM(registration_id) != ''
	AND (
		registration_id NOT LIKE 'REG%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(registration_id, 4, LEN(registration_id))) > 0
		OR registration_id LIKE '% %'
	)


-- ------------------------------------------------------------
-- sales_date
-- DQ-109: sales_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT sales_id, sales_date
FROM raw.raw_sales
WHERE sales_date IS NOT NULL AND TRIM(sales_date) <> ''
	AND TRY_CAST(sales_date AS DATE) IS NULL


-- ------------------------------------------------------------
-- invoice_number
-- DQ-116: invoice_number must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE invoice_number IS NOT NULL AND TRIM(invoice_number) != ''
	AND (
		invoice_number NOT LIKE 'INV%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(invoice_number, 4, LEN(invoice_number))) > 0
		OR invoice_number LIKE '% %'
	)


-- ------------------------------------------------------------
-- quantity
-- DQ-118: quantity must contain numeric values
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE quantity IS NOT NULL AND TRIM(quantity) != ''
	AND TRY_CAST(quantity AS DECIMAL(18,2)) IS NULL


-- ------------------------------------------------------------
-- unit_price
-- DQ-120: unit_price must contain numeric values
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE unit_price IS NOT NULL AND TRIM(unit_price) != ''
	AND TRY_CAST(unit_price AS DECIMAL(18,2)) IS NULL


-- ------------------------------------------------------------
-- sales_amount
-- DQ-122: sales_amount must contain numeric values
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE sales_amount IS NOT NULL AND TRIM(sales_amount) != ''
	AND TRY_CAST(sales_amount AS DECIMAL(18,2)) IS NULL


-- ============================================================
-- 10. raw_campaigns
-- ============================================================

-- ------------------------------------------------------------
-- campaign_id
-- DQ-124: campaign_id must follow the defined source format/pattern
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE campaign_id IS NOT NULL AND TRIM(campaign_id) != ''
	AND (
		campaign_id NOT LIKE 'CAM%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(campaign_id, 4, LEN(campaign_id))) > 0
		OR campaign_id LIKE '% %'
	)


-- ------------------------------------------------------------
-- campaign_name
-- DQ-127: campaign_name must not contain invalid or unexpected encoding characters
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE campaign_name IS NOT NULL AND TRIM(campaign_name) != ''
	AND (
		campaign_name LIKE '%[!@#$%^&*()_+=<>{}~`";:,./\|]%'
		OR campaign_name LIKE '%Ã%'
		OR campaign_name LIKE '%Â%'
		OR campaign_name LIKE '%Ä%'
		OR campaign_name LIKE '%Æ%'
		OR campaign_name LIKE '%â€%'
	)


-- ------------------------------------------------------------
-- start_date
-- DQ-132: start_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT campaign_id, start_date
FROM raw.raw_campaigns
WHERE start_date IS NOT NULL AND TRIM(start_date) <> ''
	AND TRY_CAST(start_date AS DATE) IS NULL


-- ------------------------------------------------------------
-- end_date
-- DQ-134: end_date must contain a valid date/datetime value
-- ------------------------------------------------------------
SELECT campaign_id, end_date
FROM raw.raw_campaigns
WHERE end_date IS NOT NULL AND TRIM(end_date) <> ''
	AND TRY_CAST(end_date AS DATE) IS NULL


-- ------------------------------------------------------------
-- target_hcp_count
-- DQ-136: target_hcp_count must contain numeric values
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE target_hcp_count IS NOT NULL AND TRIM(target_hcp_count) != ''
	AND TRY_CAST(target_hcp_count AS DECIMAL(18,2)) IS NULL


-- ------------------------------------------------------------
-- budget
-- DQ-138: budget must contain numeric values
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE budget IS NOT NULL AND TRIM(budget) != ''
	AND TRY_CAST(budget AS DECIMAL(18,2)) IS NULL
