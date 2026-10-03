/* =============================================================================
   03_data_quality / br_single_table.sql
   Purpose : Business rules inside one table (BR-xxx), one section per source table
   Source  : raw.*
   -------------------------------------------------------------------------
   Output
     Each rule returns violation_count, violation_pct and Pass/Fail.
     Failed rules became issues in docs/dq_issue_register.md
   ============================================================================= */


-- ============================================================
-- BUSINESS RULE: RAW_HCP CHECKS
-- File: br_raw_hcp_checks.sql
-- Purpose: Validate HCP records against defined business rules and requirements
-- Rules covered: BR-001, BR-002, BR-003, BR-004, BR-005, BR-006, BR-007, BR-008
-- Scope: hcp_id, hcp_name, hcp_type, specialty, city, territory, status
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented
-- ============================================================

-- ------------------------------------------------------------
-- hcp_id
-- BR-001: HCP ID must follow the standard format: HCP + exactly 5 digits (total length 8 characters) 
-- ------------------------------------------------------------
SELECT
  	COUNT(*) AS violation_count,
  	CONCAT(
      		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
      		'%'
  	) AS violation_pct,
  	CASE
		WHEN COUNT(*) > 0 THEN 'Fail'
		ELSE 'Pass'
	END AS status
FROM raw.raw_hcp
WHERE hcp_id IS NOT NULL AND TRIM(hcp_id) != ''
	AND hcp_id NOT LIKE 'HCP[0-9][0-9][0-9][0-9][0-9]'


-- ------------------------------------------------------------
-- hcp_name
-- BR-002: HCP name must contain at least 4 characters and must not contain encoding errors [ÃÂÄÆáºá»] 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE hcp_name IS NOT NULL AND TRIM(hcp_name) != ''
	AND (
		hcp_name LIKE '%[!@#$%^&*()_+=<>{}~`";:,./\|]%'
		OR hcp_name LIKE '%Ã%'
		OR hcp_name LIKE '%Â%'
		OR hcp_name LIKE '%Ä%'
		OR hcp_name LIKE '%Æ%'
		OR hcp_name LIKE '%â€%'
	)


-- ------------------------------------------------------------
-- hcp_type
-- BR-003: HCP type must use an approved business value 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS invalid_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS invalid_pct
FROM raw.raw_hcp
WHERE hcp_type IS NOT NULL AND TRIM(hcp_type) != ''
	AND hcp_type COLLATE Latin1_General_BIN NOT IN ('Physician', 'Pharmacist', 'Nurse', 'Other HCP')

-- ------------------------------------------------------------
-- specialty
-- BR-004: HCP specialty must use an approved business value 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE specialty IS NOT NULL AND TRIM(specialty) != ''
	AND specialty COLLATE Latin1_General_BIN NOT IN ('Oncology', 'Internal Medicine', 'Cardiology', 'Hospital Pharmacy', 'Dermatology', 'General Practice', 'Pediatrics', 'Neurology', 'Endocrinology', 'Respiratory')

-- ------------------------------------------------------------
-- city
-- BR-005: HCP city must belong to the approved city list
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE city IS NOT NULL AND TRIM(city) != ''
	AND city COLLATE Latin1_General_BIN NOT IN ('Ho Chi Minh City', 'Dong Nai', 'Binh Duong', 'Da Nang', 'Khanh Hoa', 'Can Tho', 'Quang Ninh', 'Nghe An', 'Hai Phong', 'Hanoi')

-- ------------------------------------------------------------
-- city, territory
-- BR-007: HCP territory must be consistent with the assigned city
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE city IS NOT NULL AND TRIM(city) != ''
	AND territory IS NOT NULL AND TRIM(territory) != ''
	AND CONCAT(city, '|', territory) COLLATE Latin1_General_BIN NOT IN (
		'Binh Duong|South',
		'Can Tho|Mekong',
		'Da Nang|Central',
		'Dong Nai|South',
		'Hai Phong|North',
		'Hanoi|North',
		'Ho Chi Minh City|South',
		'Khanh Hoa|Central',
		'Nghe An|North',
		'Quang Ninh|North'
	)

-- ------------------------------------------------------------
-- territory
-- BR-006: HCP territory must belong to the approved territory list
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE territory IS NOT NULL AND TRIM(territory) != ''
	AND territory COLLATE Latin1_General_BIN NOT IN ('South', 'Central', 'Mekong', 'North')
-- status
-- BR-008: HCP account status must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp
WHERE status IS NOT NULL AND TRIM(status) != ''
	AND status COLLATE Latin1_General_BIN NOT IN ('Active', 'Inactive')

-- ============================================================
-- BUSINESS RULE: RAW_CUSTOMER_ACCOUNTS
-- File: br_raw_customer_accounts.sql
-- Purpose: Validate customer account records against defined business rules and requirements
-- Rules covered: BR-010, BR-011, BR-012, BR-013
-- Scope: account_id, account_type, status, account_id, parent_account_id
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- account_id
-- BR-010: Customer account ID must follow the standard format: ACC + exactly 5 digits (total length 8 characters)
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_customer_accounts
WHERE account_id IS NOT NULL AND TRIM(account_id) != ''
	AND account_id NOT LIKE 'ACC[0-9][0-9][0-9][0-9][0-9]'


-- ------------------------------------------------------------
-- account_type
-- BR-011: Customer account type must use an approved business value 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_customer_accounts
WHERE account_type IS NOT NULL AND TRIM(account_type) != ''
	AND account_type COLLATE Latin1_General_BIN NOT IN ('Hospital', 'Clinic', 'Pharmacy', 'Pharmacy Chain', 'Distributor', 'Medical Center', 'Wholesaler')


-- ------------------------------------------------------------
-- status
-- BR-012: Customer account status must use an approved business value 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_customer_accounts
WHERE status IS NOT NULL AND TRIM(status) != ''
	AND status COLLATE Latin1_General_BIN NOT IN ('Active', 'Inactive')

-- ------------------------------------------------------------
-- account_id, parent_account_id
-- BR-013: parent_account_id must not equal account_id 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_customer_accounts
WHERE account_id IS NOT NULL AND TRIM(account_id) != ''
	AND parent_account_id IS NOT NULL AND TRIM(parent_account_id) != ''
	AND parent_account_id = account_id

-- ============================================================
-- BUSINESS RULE: RAW_HCP_ACCOUNT_AFFILIATIONS
-- File: br_raw_hcp_account_affiliations.sql
-- Purpose: Validate HCP-account affiliation records against defined business rules and requirements
-- Rules covered: BR-014, BR-015, BR-016, BR-017, BR-018
-- Scope: start_date, end_date, role, status, hcp_id, primary_affiliation, status
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- start_date, end_date
-- BR-014: HCP-account affiliation period must be chronologically valid
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp_account_affiliations), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp_account_affiliations
WHERE start_date IS NOT NULL AND TRIM(start_date) != ''
	AND end_date IS NOT NULL AND TRIM(end_date) != ''
	AND TRY_CAST(start_date AS DATE) > TRY_CAST(end_date AS DATE)


-- ------------------------------------------------------------
-- role
-- BR-015: Affiliation role must use an approved business value 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_hcp_account_affiliations), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_hcp_account_affiliations
WHERE role IS NOT NULL AND TRIM(role) != ''
	AND role COLLATE Latin1_General_BIN NOT IN ('Consultant', 'Department Head', 'Medical Director', 'Pharmacy Manager', 'Staff')

-- ------------------------------------------------------------
-- status
-- BR-016: Affiliation status must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_customer_accounts), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_customer_accounts
WHERE status IS NOT NULL AND TRIM(status) != ''
	AND status COLLATE Latin1_General_BIN NOT IN ('Active', 'Inactive')

-- ------------------------------------------------------------
-- hcp_id, primary_affiliation, status, start_date, end_date
-- BR-017: An HCP should have at most one active primary affiliation during an overlapping period
-- ------------------------------------------------------------
WITH primary_active AS (
	-- Restrict to affiliations that are Active AND marked as primary
	-- Exclude rows with invalid date range (start_date > end_date) to avoid false-trigger overlaps
	SELECT
		affiliation_id,
		hcp_id,
		account_id,
		start_date,
		COALESCE(end_date, '9999-12-31') AS end_date_eff
	FROM raw.raw_hcp_account_affiliations
	WHERE UPPER(TRIM(status)) = 'ACTIVE'
		AND UPPER(TRIM(primary_affiliation)) IN ('YES','Y','1','TRUE')
		AND start_date <= COALESCE(end_date, '9999-12-31')
),
overlaps AS (
	-- Self-join same hcp_id, different affiliation_id, overlapping date range
	SELECT DISTINCT a.hcp_id
	FROM primary_active AS a
	JOIN primary_active AS b
		ON a.hcp_id = b.hcp_id
		AND a.affiliation_id <> b.affiliation_id
		AND a.start_date <= b.end_date_eff
		AND b.start_date <= a.end_date_eff
),
applicable_rows AS (
	-- Denominator = distinct HCPs that have at least one active primary affiliation with a valid date range
	SELECT COUNT(DISTINCT hcp_id) AS total_applicable
	FROM primary_active
)
SELECT
	a.total_applicable AS hcp_with_active_primary,
	(SELECT COUNT(*) FROM overlaps) AS hcp_with_overlap_violation,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM overlaps) * 100.0 / NULLIF(a.total_applicable,0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM overlaps) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM applicable_rows a

-- ------------------------------------------------------------
-- start_date, end_date, status
-- BR-018: Active affiliation must fall within a valid active period
-- ------------------------------------------------------------
WITH active_affiliations AS (
	-- Restrict to affiliations currently marked as Active
	SELECT
		affiliation_id,
		hcp_id,
		account_id,
		start_date,
		end_date
	FROM raw.raw_hcp_account_affiliations
	WHERE UPPER(TRIM(status)) = 'ACTIVE'
),
violations AS (
	-- Violates when start_date is after the dataset's as-of date ('2026-06-29'), OR end_date is already before it
	SELECT affiliation_id
	FROM active_affiliations
	WHERE start_date > '2026-06-29'
		OR (end_date IS NOT NULL AND end_date < '2026-06-29')
),
applicable_rows AS (
	SELECT COUNT(*) AS total_applicable
	FROM active_affiliations
)
SELECT
	a.total_applicable AS active_affiliation_rows,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF(a.total_applicable,0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM applicable_rows a

-- ============================================================
-- BUSINESS RULE: RAW_PRODUCTS
-- File: br_raw_products.sql
-- Purpose: Validate product records against defined business rules and requirements
-- Rules covered: BR-019, BR-020, BR-021, BR-022, BR-023, BR-024
-- Scope: product_id, therapeutic_area, product_type, priority_flag, status, launch_date
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- product_id
-- BR-019: Product ID must follow the format: PRD + digits only (total length at least 6 characters)
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_products), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_products
WHERE product_id IS NOT NULL AND TRIM(product_id) != ''
	AND (
		product_id NOT LIKE 'PRD%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(product_id, 4, LEN(product_id))) > 0
		OR LEN(product_id) < 6
		OR product_id LIKE '% %'
	)


-- ------------------------------------------------------------
-- therapeutic_area
-- BR-020: Product therapeutic area must use an approved business value 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_products), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_products
WHERE therapeutic_area IS NOT NULL AND TRIM(therapeutic_area) != ''
	AND therapeutic_area COLLATE Latin1_General_BIN NOT IN ('Cardiology', 'CNS', 'Dermatology', 'Diabetes', 'Oncology', 'Respiratory')

-- ------------------------------------------------------------
-- product_type
-- BR-021: Product type must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_products), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_products
WHERE product_type IS NOT NULL AND TRIM(product_type) != ''
	AND product_type COLLATE Latin1_General_BIN NOT IN ('Prescription', 'OTC')

-- ------------------------------------------------------------
-- priority_flag
-- BR-022: Priority flag must use the approved flag representation
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS invalid_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_products), 2) AS DECIMAL(5,2)),
		'%'
	) AS invalid_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_products
WHERE priority_flag IS NOT NULL AND TRIM(priority_flag) != ''
	AND priority_flag COLLATE Latin1_General_BIN NOT IN ('Y', 'N')

-- ------------------------------------------------------------
-- status
-- BR-023: Product status must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_products), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_products
WHERE status IS NOT NULL AND TRIM(status) != ''
	AND status COLLATE Latin1_General_BIN NOT IN ('Active', 'Discontinued')


-- ------------------------------------------------------------
-- launch_date, status
-- BR-024: An active product must have been launched on or before the current date
-- ------------------------------------------------------------
WITH active_product AS (
	SELECT
		product_id,
		TRY_CAST(launch_date AS DATE) AS launch_date_parsed
	FROM raw.raw_products
	WHERE UPPER(TRIM(status)) = 'ACTIVE'
),
violations AS (
	SELECT product_id
	FROM active_product
	WHERE launch_date_parsed IS NOT NULL AND launch_date_parsed > '2026-06-29'
),
applicable_rows AS (
	SELECT COUNT(*) AS total_applicable
	FROM active_product
)
SELECT
	a.total_applicable AS active_product_rows,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF(a.total_applicable,0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM applicable_rows a

-- ============================================================
-- BUSINESS RULE: RAW_FIELD_REPS
-- File: br_raw_field_reps.sql
-- Purpose: Validate field representative records against defined business rules and requirements
-- Rules covered: BR-025, BR-026, BR-027, BR-028, BR-029, BR-030, BR-031
-- Scope: rep_id, territory, base_city, hire_date, status, specialization
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- rep_id
-- BR-025: Field representative ID must follow the format: REP + digits only (total length at least 7 characters)
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE rep_id IS NOT NULL AND TRIM(rep_id) != ''
	AND (
		rep_id NOT LIKE 'REP%'
		OR PATINDEX('%[^0-9]%', SUBSTRING(rep_id, 4, LEN(rep_id))) > 0
		OR LEN(rep_id) < 7
		OR rep_id LIKE '% %'
	)


-- ------------------------------------------------------------
-- territory
-- BR-026: Field rep territory must belong to the approved territory list 
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE territory IS NOT NULL AND TRIM(territory) != ''
	AND territory COLLATE Latin1_General_BIN NOT IN ('South', 'Central', 'Mekong', 'North')

-- ------------------------------------------------------------
-- base_city
-- BR-027: Field rep base city must belong to the approved city list
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE base_city IS NOT NULL AND TRIM(base_city) != ''
	AND base_city COLLATE Latin1_General_BIN NOT IN ('Ho Chi Minh City', 'Dong Nai', 'Binh Duong', 'Da Nang', 'Khanh Hoa', 'Can Tho', 'Quang Ninh', 'Nghe An', 'Hai Phong', 'Hanoi')

-- ------------------------------------------------------------
-- base_city, territory
-- BR-028: Field rep territory must be consistent with the assigned base city
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE base_city IS NOT NULL AND TRIM(base_city) != ''
	AND territory IS NOT NULL AND TRIM(territory) != ''
	AND CONCAT(base_city, '|', territory) COLLATE Latin1_General_BIN NOT IN (
		'Binh Duong|South',
		'Can Tho|Mekong',
		'Da Nang|Central',
		'Dong Nai|South',
		'Hai Phong|North',
		'Hanoi|North',
		'Ho Chi Minh City|South',
		'Khanh Hoa|Central',
		'Nghe An|North',
		'Quang Ninh|North'
	)

-- ------------------------------------------------------------
-- hire_date
-- BR-029: Field representative hire date cannot be in the future
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE hire_date IS NOT NULL AND TRIM(hire_date) != ''
	AND TRY_CAST(hire_date AS DATE) > GETDATE()


-- ------------------------------------------------------------
-- status
-- BR-030: Field representative status must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE status IS NOT NULL AND TRIM(status) != ''
	AND status COLLATE Latin1_General_BIN NOT IN ('Active', 'Inactive')


-- ------------------------------------------------------------
-- specialization
-- BR-031: Field representative specialization must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE specialization IS NOT NULL AND TRIM(specialization) != ''
	AND specialization COLLATE Latin1_General_BIN NOT IN ('Primary Care', 'Specialty Care', 'Key Account', 'Hospital')

-- ============================================================
-- BUSINESS RULE: RAW_INTERACTIONS
-- File: br_raw_interactions.sql
-- Purpose: Validate interaction records against defined business rules and requirements
-- Rules covered: BR-032, BR-034, BR-035, BR-036, BR-037
-- Scope: interaction_datetime, interaction_type, channel, duration_minutes, engagement_score
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- interaction_datetime
-- BR-032: An interaction cannot occur in the future
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_interactions), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_interactions
WHERE interaction_datetime IS NOT NULL AND TRIM(interaction_datetime) != ''
	AND TRY_CAST(interaction_datetime AS DATE) > GETDATE()


-- ------------------------------------------------------------
-- interaction_type
-- BR-034: Interaction type must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_interactions), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_interactions
WHERE interaction_type IS NOT NULL AND TRIM(interaction_type) != ''
	AND interaction_type COLLATE Latin1_General_BIN NOT IN ('Phone', 'Email', 'Face-to-face', 'Pharmacy Visit', 'Video', 'Hospital Visit')

-- ------------------------------------------------------------
-- channel
-- BR-035: Interaction channel must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_interactions), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_interactions
WHERE channel IS NOT NULL AND TRIM(channel) != ''
	AND channel COLLATE Latin1_General_BIN NOT IN ('In-person', 'Digital', 'Remote')

-- ------------------------------------------------------------
-- duration_minutes
-- BR-036: Interaction duration must be non-negative
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_interactions), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_interactions
WHERE duration_minutes IS NOT NULL AND TRIM(duration_minutes) != ''
	AND TRY_CAST(duration_minutes AS FLOAT) IS NOT NULL
	AND TRY_CAST(duration_minutes AS FLOAT) < 0


-- ------------------------------------------------------------
-- engagement_score
-- BR-037: Engagement score must be between 0 and 10, inclusive.
-- ------------------------------------------------------------
WITH applicable_rows AS (
	SELECT
		TRY_CAST(engagement_score AS FLOAT) AS score_parsed
	FROM raw.raw_interactions
	WHERE engagement_score IS NOT NULL AND TRIM(engagement_score) != ''
		AND TRY_CAST(engagement_score AS FLOAT) IS NOT NULL
),
violations AS (
	SELECT score_parsed
	FROM applicable_rows
	WHERE score_parsed < 0.0 OR score_parsed > 10.0
)
SELECT
	(SELECT COUNT(*) FROM applicable_rows) AS applicable_row_count,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF((SELECT COUNT(*) FROM applicable_rows),0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status

-- ============================================================
-- BUSINESS RULE: RAW_EVENTS
-- File: br_raw_events.sql
-- Purpose: Validate event records against defined business rules and requirements
-- Rules covered: BR-038, BR-039, BR-040, BR-041, BR-042, BR-043, BR-044
-- Scope: event_type, start_date, end_date, city, territory, budget, status
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- event_type
-- BR-038: Event type must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_events
WHERE event_type IS NOT NULL AND TRIM(event_type) != ''
	AND event_type COLLATE Latin1_General_BIN NOT IN ('Product Symposium', 'Roundtable', 'Congress', 'CME', 'Workshop')


-- ------------------------------------------------------------
-- start_date, end_date
-- BR-039: Event start date must be on or before event end date
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS invalid_affiliation_period_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS invalid_affiliation_period_pct
FROM raw.raw_events
WHERE start_date IS NOT NULL AND TRIM(start_date) != ''
	AND end_date IS NOT NULL AND TRIM(end_date) != ''
	AND TRY_CAST(start_date AS DATE) > TRY_CAST(end_date AS DATE)

-- ------------------------------------------------------------
-- city
-- BR-040: Event city must belong to the approved city list
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_field_reps), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_field_reps
WHERE base_city IS NOT NULL AND TRIM(base_city) != ''
	AND base_city COLLATE Latin1_General_BIN NOT IN ('Ho Chi Minh City', 'Dong Nai', 'Binh Duong', 'Da Nang', 'Khanh Hoa', 'Can Tho', 'Quang Ninh', 'Nghe An', 'Hai Phong', 'Hanoi')

-- ------------------------------------------------------------
-- territory
-- BR-041: Event territory must belong to the approved territory list
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_events
WHERE territory IS NOT NULL AND TRIM(territory) != ''
	AND territory COLLATE Latin1_General_BIN NOT IN ('South', 'Central', 'Mekong', 'North')

-- ------------------------------------------------------------
-- city, territory
-- BR-042: Event territory must be consistent with the assigned city
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_events
WHERE city IS NOT NULL AND TRIM(city) != ''
	AND territory IS NOT NULL AND TRIM(territory) != ''
	AND CONCAT(city, '|', territory) COLLATE Latin1_General_BIN NOT IN (
		'Binh Duong|South',
		'Can Tho|Mekong',
		'Da Nang|Central',
		'Dong Nai|South',
		'Hai Phong|North',
		'Hanoi|North',
		'Ho Chi Minh City|South',
		'Khanh Hoa|Central',
		'Nghe An|North',
		'Quang Ninh|North'
	)


-- ------------------------------------------------------------
-- budget
-- BR-043: Event budget must not be negative
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_events
WHERE budget IS NOT NULL AND TRIM(budget) != ''
	AND TRY_CAST(budget AS FLOAT) IS NOT NULL
	AND TRY_CAST(budget AS FLOAT) < 0


-- ------------------------------------------------------------
-- status
-- BR-044: Event status must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_events), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_events
WHERE status IS NOT NULL AND TRIM(status) != ''
	AND status COLLATE Latin1_General_BIN NOT IN ('Cancelled', 'Planned','Completed')

-- ============================================================
-- BUSINESS RULE: RAW_EVENTS
-- File: br_raw_event_registrations.sql
-- Purpose: Validate event registration records against defined business rules and requirements
-- Rules covered: BR-047, BR-048
-- Scope: attendance_status, follow_up_required, follow_up_status
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- attendance_status
-- BR-047: Attendance status must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_event_registrations), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_event_registrations
WHERE attendance_status IS NOT NULL AND TRIM(attendance_status) != ''
	AND attendance_status COLLATE Latin1_General_BIN NOT IN ('Attended', 'No-show', 'Registered', 'Cancelled')


-- ------------------------------------------------------------
-- follow_up_required, follow_up_status
-- BR-048: When follow_up_required = 'No', follow_up_status must be Not Required. When follow_up_required = 'Yes', follow_up_status must be a valid follow-up status other than Not Required
-- ------------------------------------------------------------
WITH applicable_rows AS (
	SELECT
		registration_id,
		follow_up_required,
		follow_up_status
	FROM raw.raw_event_registrations
	WHERE follow_up_required IS NOT NULL AND TRIM(follow_up_required) != ''
		AND follow_up_status IS NOT NULL AND TRIM(follow_up_status) != ''
),
violations AS (
	SELECT registration_id
	FROM applicable_rows
	WHERE (UPPER(TRIM(follow_up_required)) = 'NO' AND UPPER(TRIM(follow_up_status)) <> 'NOT REQUIRED')
		OR (UPPER(TRIM(follow_up_required)) = 'YES' AND UPPER(TRIM(follow_up_status)) = 'NOT REQUIRED')
)
SELECT
	(SELECT COUNT(*) FROM applicable_rows) AS applicable_row_count,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF((SELECT COUNT(*) FROM applicable_rows),0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status

-- ============================================================
-- BUSINESS RULE: RAW_SALES
-- File: br_raw_sales.sql
-- Purpose: Validate sales transaction records against defined business rules and requirements
-- Rules covered: BR-049, BR-051, BR-052, BR-053, BR-054, BR-055, BR-056, BR-057
-- Scope: sales_date, territory, sales_channel, order_type, quantity, unit_price, sales_amount, quantity
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- sales_date
-- BR-049: Sales transaction date cannot be in the future
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE sales_date IS NOT NULL AND TRIM(sales_date) != ''
	AND TRY_CAST(sales_date AS DATE) > GETDATE()


-- ------------------------------------------------------------
-- territory
-- BR-051: Sales territory must belong to the approved territory list
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE territory IS NOT NULL AND TRIM(territory) != ''
	AND territory COLLATE Latin1_General_BIN NOT IN ('South', 'Central', 'Mekong', 'North')


-- ------------------------------------------------------------
-- sales_channel
-- BR-052: Sales channel must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE sales_channel IS NOT NULL AND TRIM(sales_channel) != ''
	AND sales_channel COLLATE Latin1_General_BIN NOT IN ('Direct', 'Pharmacy Chain', 'Hospital Tender', 'Distributor', 'Wholesaler')

-- ------------------------------------------------------------
-- order_type
-- BR-053: Order type must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE order_type IS NOT NULL AND TRIM(order_type) != ''
	AND order_type COLLATE Latin1_General_BIN NOT IN ('Regular', 'Emergency', 'Contract', 'Tender')


-- ------------------------------------------------------------
-- quantity
-- BR-054: Sales quantity must be positive
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE quantity IS NOT NULL AND TRIM(quantity) != ''
	AND TRY_CAST(quantity AS FLOAT) IS NOT NULL
	AND TRY_CAST(quantity AS FLOAT) < 0

-- ------------------------------------------------------------
-- unit_price
-- BR-055: Unit price must be positive
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE unit_price IS NOT NULL AND TRIM(unit_price) != ''
	AND TRY_CAST(unit_price AS FLOAT) IS NOT NULL
	AND TRY_CAST(unit_price AS FLOAT) <= 0


-- ------------------------------------------------------------
-- sales_amount
-- BR-056: Sales amount must not be negative
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_sales), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_sales
WHERE sales_amount IS NOT NULL AND TRIM(sales_amount) != ''
	AND TRY_CAST(sales_amount AS FLOAT) IS NOT NULL
	AND TRY_CAST(sales_amount AS FLOAT) <= 0


-- ------------------------------------------------------------
-- quantity, unit_price, sales_amount
-- BR-057: Sales amount must equal quantity × unit price within a tolerance of 0.01
-- ------------------------------------------------------------
WITH applicable_rows AS (
	SELECT
		sales_id,
		TRY_CAST(quantity AS FLOAT) AS quantity_parsed,
		TRY_CAST(unit_price AS FLOAT) AS unit_price_parsed,
		TRY_CAST(sales_amount AS FLOAT) AS sales_amount_parsed
	FROM raw.raw_sales
	WHERE TRY_CAST(quantity AS FLOAT) IS NOT NULL
		AND TRY_CAST(unit_price AS FLOAT) IS NOT NULL
		AND TRY_CAST(sales_amount AS FLOAT) IS NOT NULL
),
violations AS (
	SELECT sales_id
	FROM applicable_rows
	WHERE ABS(sales_amount_parsed - (quantity_parsed * unit_price_parsed)) > 0.01
)
SELECT
	(SELECT COUNT(*) FROM applicable_rows) AS applicable_row_count,
	(SELECT COUNT(*) FROM violations) AS violation_count,
	CONCAT(CAST(ROUND((SELECT COUNT(*) FROM violations) * 100.0 / NULLIF((SELECT COUNT(*) FROM applicable_rows),0), 2) AS DECIMAL(5,2)), '%') AS violation_pct,
	CASE WHEN (SELECT COUNT(*) FROM violations) > 0 THEN 'Fail' ELSE 'Pass' END AS status

-- ============================================================
-- BUSINESS RULE: RAW_CAMPAIGNS
-- File: br_raw_campaigns.sql
-- Purpose: Validate campaign records against defined business rules and requirements
-- Rules covered: BR-058, BR-059, BR-060, BR-061, BR-062
-- Scope: campaign_type, start_date, end_date, target_hcp_count, budget, status
-- Source: Business Rule Catalog, Domain Reference
-- Expected Result: Each business rule should return 0 violations unless exceptions are explicitly documented. 
-- ============================================================

-- ------------------------------------------------------------
-- campaign_type
-- BR-058: Campaign type must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE campaign_type IS NOT NULL AND TRIM(campaign_type) != ''
	AND campaign_type COLLATE Latin1_General_BIN NOT IN ('Advisory', 'Awareness', 'HCP Engagement', 'Launch', 'Product Education')


-- ------------------------------------------------------------
-- start_date, end_date
-- BR-059: Campaign start date must be on or before campaign end date
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE start_date IS NOT NULL AND TRIM(start_date) != ''
	AND end_date IS NOT NULL AND TRIM(end_date) != ''
	AND TRY_CAST(start_date AS DATE) > TRY_CAST(end_date AS DATE)


-- ------------------------------------------------------------
-- target_hcp_count
-- BR-060: Campaign target HCP count must not be negative
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE target_hcp_count IS NOT NULL AND TRIM(target_hcp_count) != ''
	AND TRY_CAST(target_hcp_count AS FLOAT) IS NOT NULL
	AND TRY_CAST(target_hcp_count AS FLOAT) <= 0

-- ------------------------------------------------------------
-- budget
-- BR-061: Campaign budget must not be negative
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS negative_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS negative_pct
FROM raw.raw_campaigns
WHERE budget IS NOT NULL AND TRIM(budget) != ''
	AND TRY_CAST(budget AS FLOAT) IS NOT NULL
	AND TRY_CAST(budget AS FLOAT) < 0

-- ------------------------------------------------------------
-- status
-- BR-062: Campaign status must use an approved business value
-- ------------------------------------------------------------
SELECT
	COUNT(*) AS violation_count,
	CONCAT(
		CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.raw_campaigns), 2) AS DECIMAL(5,2)),
		'%'
	) AS violation_pct,
	CASE WHEN COUNT(*) > 0 THEN 'Fail' ELSE 'Pass' END AS status
FROM raw.raw_campaigns
WHERE status IS NOT NULL AND TRIM(status) != ''
	AND status COLLATE Latin1_General_BIN NOT IN ('Active','Cancelled', 'Planned','Completed')
