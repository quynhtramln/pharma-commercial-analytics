/* =============================================================================
   02_profiling / table_profiling.sql
   Purpose : Describe each raw table: row count, columns, duplicates, candidate keys
   Source  : raw.*
   -------------------------------------------------------------------------
   Note
     Profiling describes the data; it has no pass/fail. Column-level profiling
     (null %, distinct, min/max, patterns for all 89 columns) was run as well;
     its findings are summarised in docs/03 and the DQ issue register.
   ============================================================================= */

-- ============================================================
-- TABLE PROFILING
-- Purpose: Profile table-level characteristics across RAW tables
-- ============================================================

-- ============================================================
-- 01. ROW COUNT
-- Purpose: Count total records in each table
-- ============================================================
SELECT 'raw_hcp' AS table_name, COUNT(*) AS row_count
FROM raw.raw_hcp


UNION ALL


SELECT 'raw_customer_accounts', COUNT(*)
FROM raw.raw_customer_accounts


UNION ALL


SELECT 'raw_hcp_account_affiliations', COUNT(*)
FROM raw.raw_hcp_account_affiliations


UNION ALL


SELECT 'raw_products', COUNT(*)
FROM raw.raw_products


UNION ALL


SELECT 'raw_field_reps', COUNT(*)
FROM raw.raw_field_reps


UNION ALL


SELECT 'raw_interactions', COUNT(*)
FROM raw.raw_interactions


UNION ALL


SELECT 'raw_events', COUNT(*)
FROM raw.raw_events


UNION ALL


SELECT 'raw_event_registrations', COUNT(*)
FROM raw.raw_event_registrations


UNION ALL


SELECT 'raw_sales', COUNT(*)
FROM raw.raw_sales


UNION ALL


SELECT 'raw_campaigns', COUNT(*)
FROM raw.raw_campaigns


-- ============================================================
-- 02. COLUMN COUNT
-- Purpose: Count total columns in each table
-- ============================================================
SELECT
  	TABLE_NAME AS table_name,
   	COUNT(*) AS column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
	AND TABLE_NAME IN (
       'raw_hcp',
       'raw_customer_accounts',
       'raw_hcp_account_affiliations',
       'raw_products',
       'raw_field_reps',
       'raw_interactions',
       'raw_events',
       'raw_event_registrations',
       'raw_sales',
       'raw_campaigns'
	)
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME


-- ============================================================
-- 03. EXACT DUPLICATE ROWS
-- Purpose: Identify fully duplicated records across all columns
-- ============================================================
WITH dup_hcp AS (
	SELECT
		hcp_id, hcp_name, hcp_type, specialty, city, territory, email, phone, status,
		COUNT(*) AS dup_rows
	FROM raw.raw_hcp
	GROUP BY
		hcp_id, hcp_name, hcp_type, specialty, city, territory, email, phone, status
	HAVING COUNT(*) > 1
),
dup_customer_accounts AS (
	SELECT
		account_id, account_name, account_type, city, territory, tax_id, phone, status, parent_account_id,
		COUNT(*) AS dup_rows
	FROM raw.raw_customer_accounts
	GROUP BY
		account_id, account_name, account_type, city, territory, tax_id, phone, status, parent_account_id
	HAVING COUNT(*) > 1
),
dup_hcp_account_affiliations AS (
	SELECT
		affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status,
		COUNT(*) AS dup_rows
	FROM raw.raw_hcp_account_affiliations
	GROUP BY
		affiliation_id, hcp_id, account_id, role, primary_affiliation, start_date, end_date, status
	HAVING COUNT(*) > 1
),
dup_products AS (
	SELECT
		product_id, product_name, therapeutic_area, product_type, priority_flag, launch_date, status,
		COUNT(*) AS dup_rows
	FROM raw.raw_products
	GROUP BY
		product_id, product_name, therapeutic_area, product_type, priority_flag, launch_date, status
	HAVING COUNT(*) > 1
),
dup_field_reps AS (
	SELECT
		rep_id, rep_name, territory, base_city, hire_date, status, specialization,
		COUNT(*) AS dup_rows
	FROM raw.raw_field_reps
	GROUP BY
		rep_id, rep_name, territory, base_city, hire_date, status, specialization
	HAVING COUNT(*) > 1
),
dup_interactions AS (
	SELECT
		interaction_id, interaction_datetime, hcp_id, account_id, rep_id, product_id, interaction_type, channel, duration_minutes, outcome, engagement_score,
		COUNT(*) AS dup_rows
	FROM raw.raw_interactions
	GROUP BY
		interaction_id, interaction_datetime, hcp_id, account_id, rep_id, product_id, interaction_type, channel, duration_minutes, outcome, engagement_score
	HAVING COUNT(*) > 1
),
dup_events AS (
	SELECT
		event_id, event_name, event_type, start_date, end_date, city, territory, product_id, budget, status,
		COUNT(*) AS dup_rows
	FROM raw.raw_events
	GROUP BY
		event_id, event_name, event_type, start_date, end_date, city, territory, product_id, budget, status
	HAVING COUNT(*) > 1
),
dup_event_registrations AS (
	SELECT
		registration_id, event_id, hcp_id, registration_date, attendance_status, follow_up_required, follow_up_status, source,
		COUNT(*) AS dup_rows
	FROM raw.raw_event_registrations
	GROUP BY
		registration_id, event_id, hcp_id, registration_date, attendance_status, follow_up_required, follow_up_status, source
	HAVING COUNT(*) > 1
),
dup_sales AS (
	SELECT
		sales_id, sales_date, account_id, product_id, territory, sales_channel, order_type, invoice_number, quantity, unit_price, sales_amount,
		COUNT(*) AS dup_rows
	FROM raw.raw_sales
	GROUP BY
		sales_id, sales_date, account_id, product_id, territory, sales_channel, order_type, invoice_number, quantity, unit_price, sales_amount
	HAVING COUNT(*) > 1
),
dup_campaigns AS (
	SELECT
		campaign_id, campaign_name, campaign_type, product_id, start_date, end_date, target_hcp_count, budget, status,
		COUNT(*) AS dup_rows
	FROM raw.raw_campaigns
	GROUP BY
		campaign_id, campaign_name, campaign_type, product_id, start_date, end_date, target_hcp_count, budget, status
	HAVING COUNT(*) > 1
)
SELECT 'raw_hcp' AS table_name, COUNT(*) AS total_exact_dup_rows FROM dup_hcp
UNION ALL
SELECT 'raw_customer_accounts', COUNT(*) FROM dup_customer_accounts
UNION ALL
SELECT 'raw_hcp_account_affiliations', COUNT(*) FROM dup_hcp_account_affiliations
UNION ALL
SELECT 'raw_products', COUNT(*) FROM dup_products
UNION ALL
SELECT 'raw_field_reps', COUNT(*) FROM dup_field_reps
UNION ALL
SELECT 'raw_interactions', COUNT(*) FROM dup_interactions
UNION ALL
SELECT 'raw_events', COUNT(*) FROM dup_events
UNION ALL
SELECT 'raw_event_registrations', COUNT(*) FROM dup_event_registrations
UNION ALL
SELECT 'raw_sales', COUNT(*) FROM dup_sales
UNION ALL
SELECT 'raw_campaigns', COUNT(*) FROM dup_campaigns;


-- ============================================================
-- 04. EMPTY ROWS
-- Purpose: Detect rows where all key columns are NULL or empty
-- ============================================================
SELECT 'raw_hcp' AS table_name, COUNT(*) AS empty_rows
FROM raw.raw_hcp
WHERE COALESCE(
   	NULLIF(TRIM(hcp_id), ''),
   	NULLIF(TRIM(hcp_name), ''),
   	NULLIF(TRIM(hcp_type), ''),
   	NULLIF(TRIM(specialty), ''),
   	NULLIF(TRIM(city), ''),
   	NULLIF(TRIM(territory), ''),
   	NULLIF(TRIM(email), ''),
   	NULLIF(TRIM(phone), ''),
   	NULLIF(TRIM(status), '')
) IS NULL


UNION ALL


SELECT 'raw_customer_accounts', COUNT(*)
FROM raw.raw_customer_accounts
WHERE COALESCE(
   	NULLIF(TRIM(account_id), ''),
   	NULLIF(TRIM(account_name), ''),
   	NULLIF(TRIM(account_type), ''),
   	NULLIF(TRIM(city), ''),
   	NULLIF(TRIM(territory), ''),
   	NULLIF(TRIM(tax_id), ''),
   	NULLIF(TRIM(phone), ''),
   	NULLIF(TRIM(status), ''),
   	NULLIF(TRIM(parent_account_id), '')
) IS NULL


UNION ALL


SELECT 'raw_hcp_account_affiliations', COUNT(*)
FROM raw.raw_hcp_account_affiliations
WHERE COALESCE(
   	NULLIF(TRIM(affiliation_id), ''),
   	NULLIF(TRIM(hcp_id), ''),
   	NULLIF(TRIM(account_id), ''),
   	NULLIF(TRIM(role), ''),
   	NULLIF(TRIM(primary_affiliation), ''),
   	NULLIF(TRIM(start_date), ''),
   	NULLIF(TRIM(end_date), ''),
   	NULLIF(TRIM(status), '')
) IS NULL


UNION ALL


SELECT 'raw_products', COUNT(*)
FROM raw.raw_products
WHERE COALESCE(
   	NULLIF(TRIM(product_id), ''),
   	NULLIF(TRIM(product_name), ''),
   	NULLIF(TRIM(therapeutic_area), ''),
   	NULLIF(TRIM(product_type), ''),
   	NULLIF(TRIM(priority_flag), ''),
   	NULLIF(TRIM(launch_date), ''),
   	NULLIF(TRIM(status), '')
) IS NULL


UNION ALL


SELECT 'raw_field_reps', COUNT(*)
FROM raw.raw_field_reps
WHERE COALESCE(
   	NULLIF(TRIM(rep_id), ''),
   	NULLIF(TRIM(rep_name), ''),
   	NULLIF(TRIM(territory), ''),
   	NULLIF(TRIM(base_city), ''),
   	NULLIF(TRIM(hire_date), ''),
   	NULLIF(TRIM(status), ''),
   	NULLIF(TRIM(specialization), '')
) IS NULL


UNION ALL


SELECT 'raw_interactions', COUNT(*)
FROM raw.raw_interactions
WHERE COALESCE(
   	NULLIF(TRIM(interaction_id), ''),
   	NULLIF(TRIM(interaction_datetime), ''),
   	NULLIF(TRIM(hcp_id), ''),
   	NULLIF(TRIM(account_id), ''),
   	NULLIF(TRIM(rep_id), ''),
   	NULLIF(TRIM(product_id), ''),
   	NULLIF(TRIM(interaction_type), ''),
   	NULLIF(TRIM(channel), ''),
   	NULLIF(TRIM(duration_minutes), ''),
   	NULLIF(TRIM(outcome), ''),
   	NULLIF(TRIM(engagement_score), '')
) IS NULL


UNION ALL


SELECT 'raw_events', COUNT(*)
FROM raw.raw_events
WHERE COALESCE(
   	NULLIF(TRIM(event_id), ''),
   	NULLIF(TRIM(event_name), ''),
   	NULLIF(TRIM(event_type), ''),
   	NULLIF(TRIM(start_date), ''),
   	NULLIF(TRIM(end_date), ''),
   	NULLIF(TRIM(city), ''),
   	NULLIF(TRIM(territory), ''),
   	NULLIF(TRIM(product_id), ''),
   	NULLIF(TRIM(budget), ''),
   	NULLIF(TRIM(status), '')
) IS NULL


UNION ALL


SELECT 'raw_event_registrations', COUNT(*)
FROM raw.raw_event_registrations
WHERE COALESCE(
   	NULLIF(TRIM(registration_id), ''),
   	NULLIF(TRIM(event_id), ''),
   	NULLIF(TRIM(hcp_id), ''),
   	NULLIF(TRIM(registration_date), ''),
   	NULLIF(TRIM(attendance_status), ''),
   	NULLIF(TRIM(follow_up_required), ''),
   	NULLIF(TRIM(follow_up_status), ''),
   	NULLIF(TRIM(source), '')
) IS NULL


UNION ALL


SELECT 'raw_sales', COUNT(*)
FROM raw.raw_sales
WHERE COALESCE(
   	NULLIF(TRIM(sales_id), ''),
   	NULLIF(TRIM(sales_date), ''),
   	NULLIF(TRIM(account_id), ''),
   	NULLIF(TRIM(product_id), ''),
   	NULLIF(TRIM(territory), ''),
   	NULLIF(TRIM(sales_channel), ''),
   	NULLIF(TRIM(order_type), ''),
   	NULLIF(TRIM(invoice_number), ''),
   	NULLIF(TRIM(quantity), ''),
   	NULLIF(TRIM(unit_price), ''),
   	NULLIF(TRIM(sales_amount), '')
) IS NULL


UNION ALL


SELECT 'raw_campaigns', COUNT(*)
FROM raw.raw_campaigns
WHERE COALESCE(
   	NULLIF(TRIM(campaign_id), ''),
   	NULLIF(TRIM(campaign_name), ''),
   	NULLIF(TRIM(campaign_type), ''),
   	NULLIF(TRIM(product_id), ''),
   	NULLIF(TRIM(start_date), ''),
   	NULLIF(TRIM(end_date), ''),
   	NULLIF(TRIM(target_hcp_count), ''),
   	NULLIF(TRIM(budget), ''),
   	NULLIF(TRIM(status), '')
) IS NULL


-- ============================================================
-- 05. DUPLICATE PRIMARY KEY
-- Purpose: Identify records with repeated primary key values
-- ============================================================
WITH
dup_PK_hcp AS (
   SELECT hcp_id
   FROM raw.raw_hcp
   GROUP BY hcp_id
   HAVING COUNT(*) > 1
),
dup_PK_customer_accounts AS (
   SELECT account_id
   FROM raw.raw_customer_accounts
   GROUP BY account_id
   HAVING COUNT(*) > 1
),
dup_PK_hcp_account_affiliations AS (
   SELECT affiliation_id
   FROM raw.raw_hcp_account_affiliations
   GROUP BY affiliation_id
   HAVING COUNT(*) > 1
),
dup_PK_products AS (
   SELECT product_id
   FROM raw.raw_products
   GROUP BY product_id
   HAVING COUNT(*) > 1
),
dup_PK_field_reps AS (
   SELECT rep_id
   FROM raw.raw_field_reps
   GROUP BY rep_id
   HAVING COUNT(*) > 1
),
dup_PK_interactions AS (
   SELECT interaction_id
   FROM raw.raw_interactions
   GROUP BY interaction_id
   HAVING COUNT(*) > 1
),
dup_PK_events AS (
   SELECT event_id
   FROM raw.raw_events
   GROUP BY event_id
   HAVING COUNT(*) > 1
),
dup_PK_event_registrations AS (
   SELECT registration_id
   FROM raw.raw_event_registrations
   GROUP BY registration_id
   HAVING COUNT(*) > 1
),
dup_PK_sales AS (
   SELECT sales_id
   FROM raw.raw_sales
   GROUP BY sales_id
   HAVING COUNT(*) > 1
),
dup_PK_campaigns AS (
   SELECT campaign_id
   FROM raw.raw_campaigns
   GROUP BY campaign_id
   HAVING COUNT(*) > 1
)
SELECT 'raw_hcp' AS table_name, COUNT(*) AS dup_PK_count FROM dup_PK_hcp
UNION ALL
SELECT 'raw_customer_accounts', COUNT(*) FROM dup_PK_customer_accounts
UNION ALL
SELECT 'raw_hcp_account_affiliations', COUNT(*) FROM dup_PK_hcp_account_affiliations
UNION ALL
SELECT 'raw_products', COUNT(*) FROM dup_PK_products
UNION ALL
SELECT 'raw_field_reps', COUNT(*) FROM dup_PK_field_reps
UNION ALL
SELECT 'raw_interactions', COUNT(*) FROM dup_PK_interactions
UNION ALL
SELECT 'raw_events', COUNT(*) FROM dup_PK_events
UNION ALL
SELECT 'raw_event_registrations', COUNT(*) FROM dup_PK_event_registrations
UNION ALL
SELECT 'raw_sales', COUNT(*) FROM dup_PK_sales
UNION ALL
SELECT 'raw_campaigns', COUNT(*) FROM dup_PK_campaigns

-- ============================================================
-- 06. NULL PRIMARY KEY
-- Purpose: Detect records with missing primary key values
-- ============================================================
SELECT 'raw_hcp' AS table_name, COUNT(*) AS null_PK_count
FROM raw.raw_hcp
WHERE hcp_id IS NULL
UNION ALL
SELECT 'raw_customer_accounts', COUNT(*)
FROM raw.raw_customer_accounts
WHERE account_id IS NULL
UNION ALL
SELECT 'raw_hcp_account_affiliations', COUNT(*)
FROM raw.raw_hcp_account_affiliations
WHERE affiliation_id IS NULL
UNION ALL
SELECT 'raw_products', COUNT(*)
FROM raw.raw_products
WHERE product_id IS NULL
UNION ALL
SELECT 'raw_field_reps', COUNT(*)
FROM raw.raw_field_reps
WHERE rep_id IS NULL
UNION ALL
SELECT 'raw_interactions', COUNT(*)
FROM raw.raw_interactions
WHERE interaction_id IS NULL
UNION ALL
SELECT 'raw_events', COUNT(*)
FROM raw.raw_events
WHERE event_id IS NULL
UNION ALL
SELECT 'raw_event_registrations', COUNT(*)
FROM raw.raw_event_registrations
WHERE registration_id IS NULL
UNION ALL
SELECT 'raw_sales', COUNT(*)
FROM raw.raw_sales
WHERE sales_id IS NULL
UNION ALL
SELECT 'raw_campaigns', COUNT(*)
FROM raw.raw_campaigns
WHERE campaign_id IS NULL


-- ============================================================
-- 07. ORPHAN FOREIGN KEY
-- Purpose: Count foreign key values without matching primary key
-- ============================================================
-- Orphan check for FK parent_account_id, table raw_customer_accounts
SELECT
   	'account_id_hcp' AS FK_name,
   	COUNT(*) AS orphan_FK_count
FROM raw.raw_customer_accounts AS child
LEFT JOIN raw.raw_customer_accounts AS parent
   	ON child.parent_account_id = parent.account_id
WHERE child.parent_account_id IS NOT NULL
 	AND child.parent_account_id <> ''
 	AND parent.account_id IS NULL


UNION ALL


-- Orphan check for FK hcp_id, table raw_hcp_account_affiliations
SELECT
   	'hcp_id_hcp_account_affiliations',
   	COUNT(*)
FROM raw.raw_hcp_account_affiliations AS child
LEFT JOIN raw.raw_hcp AS parent
   	ON child.hcp_id = parent.hcp_id
WHERE child.hcp_id IS NOT NULL
 	AND child.hcp_id <> ''
 	AND parent.hcp_id IS NULL


UNION ALL


-- Orphan check for FK account_id, table raw_hcp_account_affiliations
SELECT
   	'account_id_hcp_account_affiliations',
   	COUNT(*)
FROM raw.raw_hcp_account_affiliations AS child
LEFT JOIN raw.raw_customer_accounts AS parent
   	ON child.account_id = parent.account_id
WHERE child.account_id IS NOT NULL
 	AND child.account_id <> ''
 	AND parent.account_id IS NULL


UNION ALL


-- Orphan check for FK hcp_id, table raw_interactions
SELECT 'hcp_id_interactions', COUNT(*)
FROM raw.raw_interactions AS child
LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
WHERE child.hcp_id IS NOT NULL
 	AND child.hcp_id <> ''
 	AND parent.hcp_id IS NULL


UNION ALL


-- Orphan check for FK account_id, table raw_interactions
SELECT 'account_id_interactions', COUNT(*)
FROM raw.raw_interactions AS child
LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
WHERE child.account_id IS NOT NULL
 	AND child.account_id <> ''
 	AND parent.account_id IS NULL


UNION ALL


-- Orphan check for FK rep_id, table raw_interactions
SELECT 'rep_id_interactions', COUNT(*)
FROM raw.raw_interactions AS child
LEFT JOIN raw.raw_field_reps AS parent ON child.rep_id = parent.rep_id
WHERE child.rep_id IS NOT NULL
 	AND child.rep_id <> ''
 	AND parent.rep_id IS NULL


UNION ALL


-- Orphan check for FK product_id, table raw_interactions
SELECT 'product_id_interactions', COUNT(*)
FROM raw.raw_interactions AS child
LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
WHERE child.product_id IS NOT NULL
 	AND child.product_id <> ''
 	AND parent.product_id IS NULL


UNION ALL


-- Orphan check for FK product_id, table raw_events
SELECT 'product_id_events', COUNT(*)
FROM raw.raw_events AS child
LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
WHERE child.product_id IS NOT NULL
 	AND child.product_id <> ''
 	AND parent.product_id IS NULL


UNION ALL


-- Orphan check for FK event_id, table raw_event_registrations
SELECT 'event_id_event_registrations', COUNT(*)
FROM raw.raw_event_registrations AS child
LEFT JOIN raw.raw_events AS parent ON child.event_id = parent.event_id
WHERE child.event_id IS NOT NULL
 	AND child.event_id <> ''
 	AND parent.event_id IS NULL


UNION ALL


-- Orphan check for FK hcp_id, table raw_event_registrations
SELECT 'hcp_id_event_registrations', COUNT(*)
FROM raw.raw_event_registrations AS child
LEFT JOIN raw.raw_hcp AS parent ON child.hcp_id = parent.hcp_id
WHERE child.hcp_id IS NOT NULL
 	AND child.hcp_id <> ''
 	AND parent.hcp_id IS NULL


UNION ALL


-- Orphan check for FK account_id, table raw_sales
SELECT 'account_id_sales', COUNT(*)
FROM raw.raw_sales AS child
LEFT JOIN raw.raw_customer_accounts AS parent ON child.account_id = parent.account_id
WHERE child.account_id IS NOT NULL
 	AND child.account_id <> ''
 	AND parent.account_id IS NULL


UNION ALL


-- Orphan check for FK product_id, table raw_sales
SELECT 'product_id_sales', COUNT(*)
FROM raw.raw_sales AS child
LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
WHERE child.product_id IS NOT NULL
 	AND child.product_id <> ''
 	AND parent.product_id IS NULL


UNION ALL


-- Orphan check for FK product_id, table raw_campaigns
SELECT 'product_id_campaigns', COUNT(*)
FROM raw.raw_campaigns AS child
LEFT JOIN raw.raw_products AS parent ON child.product_id = parent.product_id
WHERE child.product_id IS NOT NULL
 	AND child.product_id <> ''
 	AND parent.product_id IS NULL
