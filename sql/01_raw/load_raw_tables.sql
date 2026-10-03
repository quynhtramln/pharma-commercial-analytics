/* =============================================================================
   01_raw / load_raw_tables.sql
   Purpose : Load the 10 CSV extracts into raw.* exactly as received
   Source  : CSV files in $(DataPath) - dataset not published
   Target  : raw.raw_<entity>
   -------------------------------------------------------------------------
   Design
     Every column is NVARCHAR: nothing is typed or cleaned at this layer, so the raw
     table is a faithful copy of the file and the audit baseline (Business Rule 10).
     Typing (TRY_CAST) and cleaning happen in 04_staging.
   Row counts after load
     hcp 5,220 · customer_accounts 1,106 · hcp_account_affiliations 12,550 · products 40
     field_reps 221 · interactions 320,640 · events 552 · event_registrations 650,975
     sales 1,051,050 · campaigns 72
   ============================================================================= */
USE New_Project_Healthcare_Pharma_Commercial;
GO

-- ----------------------------------------------------------------------------
-- raw.raw_hcp  (9 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_hcp;
CREATE TABLE raw.raw_hcp (
    hcp_id                 NVARCHAR(400) NULL,
    hcp_name               NVARCHAR(400) NULL,
    hcp_type               NVARCHAR(400) NULL,
    specialty              NVARCHAR(400) NULL,
    city                   NVARCHAR(400) NULL,
    territory              NVARCHAR(400) NULL,
    email                  NVARCHAR(400) NULL,
    phone                  NVARCHAR(400) NULL,
    status                 NVARCHAR(400) NULL
);
BULK INSERT raw.raw_hcp
FROM '$(DataPath)\raw_hcp.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_customer_accounts  (9 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_customer_accounts;
CREATE TABLE raw.raw_customer_accounts (
    account_id             NVARCHAR(400) NULL,
    account_name           NVARCHAR(400) NULL,
    account_type           NVARCHAR(400) NULL,
    city                   NVARCHAR(400) NULL,
    territory              NVARCHAR(400) NULL,
    tax_id                 NVARCHAR(400) NULL,
    phone                  NVARCHAR(400) NULL,
    status                 NVARCHAR(400) NULL,
    parent_account_id      NVARCHAR(400) NULL
);
BULK INSERT raw.raw_customer_accounts
FROM '$(DataPath)\raw_customer_accounts.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_hcp_account_affiliations  (8 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_hcp_account_affiliations;
CREATE TABLE raw.raw_hcp_account_affiliations (
    affiliation_id         NVARCHAR(400) NULL,
    hcp_id                 NVARCHAR(400) NULL,
    account_id             NVARCHAR(400) NULL,
    role                   NVARCHAR(400) NULL,
    primary_affiliation    NVARCHAR(400) NULL,
    start_date             NVARCHAR(400) NULL,
    end_date               NVARCHAR(400) NULL,
    status                 NVARCHAR(400) NULL
);
BULK INSERT raw.raw_hcp_account_affiliations
FROM '$(DataPath)\raw_hcp_account_affiliations.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_products  (7 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_products;
CREATE TABLE raw.raw_products (
    product_id             NVARCHAR(400) NULL,
    product_name           NVARCHAR(400) NULL,
    therapeutic_area       NVARCHAR(400) NULL,
    product_type           NVARCHAR(400) NULL,
    priority_flag          NVARCHAR(400) NULL,
    launch_date            NVARCHAR(400) NULL,
    status                 NVARCHAR(400) NULL
);
BULK INSERT raw.raw_products
FROM '$(DataPath)\raw_products.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_field_reps  (7 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_field_reps;
CREATE TABLE raw.raw_field_reps (
    rep_id                 NVARCHAR(400) NULL,
    rep_name               NVARCHAR(400) NULL,
    territory              NVARCHAR(400) NULL,
    base_city              NVARCHAR(400) NULL,
    hire_date              NVARCHAR(400) NULL,
    status                 NVARCHAR(400) NULL,
    specialization         NVARCHAR(400) NULL
);
BULK INSERT raw.raw_field_reps
FROM '$(DataPath)\raw_field_reps.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_interactions  (11 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_interactions;
CREATE TABLE raw.raw_interactions (
    interaction_id         NVARCHAR(400) NULL,
    interaction_datetime   NVARCHAR(400) NULL,
    hcp_id                 NVARCHAR(400) NULL,
    account_id             NVARCHAR(400) NULL,
    rep_id                 NVARCHAR(400) NULL,
    product_id             NVARCHAR(400) NULL,
    interaction_type       NVARCHAR(400) NULL,
    channel                NVARCHAR(400) NULL,
    duration_minutes       NVARCHAR(400) NULL,
    outcome                NVARCHAR(400) NULL,
    engagement_score       NVARCHAR(400) NULL
);
BULK INSERT raw.raw_interactions
FROM '$(DataPath)\raw_interactions.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_events  (10 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_events;
CREATE TABLE raw.raw_events (
    event_id               NVARCHAR(400) NULL,
    event_name             NVARCHAR(400) NULL,
    event_type             NVARCHAR(400) NULL,
    start_date             NVARCHAR(400) NULL,
    end_date               NVARCHAR(400) NULL,
    city                   NVARCHAR(400) NULL,
    territory              NVARCHAR(400) NULL,
    product_id             NVARCHAR(400) NULL,
    budget                 NVARCHAR(400) NULL,
    status                 NVARCHAR(400) NULL
);
BULK INSERT raw.raw_events
FROM '$(DataPath)\raw_events.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_event_registrations  (8 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_event_registrations;
CREATE TABLE raw.raw_event_registrations (
    registration_id        NVARCHAR(400) NULL,
    event_id               NVARCHAR(400) NULL,
    hcp_id                 NVARCHAR(400) NULL,
    registration_date      NVARCHAR(400) NULL,
    attendance_status      NVARCHAR(400) NULL,
    follow_up_required     NVARCHAR(400) NULL,
    follow_up_status       NVARCHAR(400) NULL,
    source                 NVARCHAR(400) NULL
);
BULK INSERT raw.raw_event_registrations
FROM '$(DataPath)\raw_event_registrations.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_sales  (11 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_sales;
CREATE TABLE raw.raw_sales (
    sales_id               NVARCHAR(400) NULL,
    sales_date             NVARCHAR(400) NULL,
    account_id             NVARCHAR(400) NULL,
    product_id             NVARCHAR(400) NULL,
    territory              NVARCHAR(400) NULL,
    sales_channel          NVARCHAR(400) NULL,
    order_type             NVARCHAR(400) NULL,
    invoice_number         NVARCHAR(400) NULL,
    quantity               NVARCHAR(400) NULL,
    unit_price             NVARCHAR(400) NULL,
    sales_amount           NVARCHAR(400) NULL
);
BULK INSERT raw.raw_sales
FROM '$(DataPath)\raw_sales.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ----------------------------------------------------------------------------
-- raw.raw_campaigns  (9 columns)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS raw.raw_campaigns;
CREATE TABLE raw.raw_campaigns (
    campaign_id            NVARCHAR(400) NULL,
    campaign_name          NVARCHAR(400) NULL,
    campaign_type          NVARCHAR(400) NULL,
    product_id             NVARCHAR(400) NULL,
    start_date             NVARCHAR(400) NULL,
    end_date               NVARCHAR(400) NULL,
    target_hcp_count       NVARCHAR(400) NULL,
    budget                 NVARCHAR(400) NULL,
    status                 NVARCHAR(400) NULL
);
BULK INSERT raw.raw_campaigns
FROM '$(DataPath)\raw_campaigns.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, CODEPAGE = '65001', FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
