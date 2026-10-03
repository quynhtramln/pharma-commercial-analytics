# Data Dictionary

Column-level description of the 10 source tables. The dataset itself is not published; this page
describes its structure only.

- **Type** is the type after staging. In raw, every column is stored as text, exactly as received.
- **Known issues** link to the [DQ Issue Register](dq_issue_register.md).
- **Model** shows where the column ends up: `dim` / `fact` = kept in the warehouse, `removed` = dropped before the model (personal data or not needed), `flag` = drives a DQ flag.

---

## raw_hcp · HCP master · 1 row = 1 healthcare professional

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| hcp_id | VARCHAR | HCP identifier (PK) | ISS-001 duplicates | dim_hcp |
| hcp_name | NVARCHAR | Full name | - | removed (PII) |
| hcp_type | VARCHAR | Physician, Pharmacist, Nurse, Other HCP | - | dim_hcp |
| specialty | VARCHAR | 10 specialties: Cardiology, Oncology, Internal Medicine, General Practice, Neurology… | - | dim_hcp |
| city | NVARCHAR | City of practice | - | dim_hcp |
| territory | VARCHAR | North, Central, South, Mekong | - | dim_hcp |
| email | VARCHAR | Contact e-mail (candidate business key) | ISS-002/003 null, `'invalid-email'` | removed (PII) |
| phone | VARCHAR(15) | Contact phone; text to keep leading zero | ISS-006/007 null, `'12345'` | removed (PII) |
| status | VARCHAR | Active / Inactive | ISS-010 (closed) | dim_hcp |

## raw_customer_accounts · Account master · 1 row = 1 customer account

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| account_id | VARCHAR | Account identifier (PK) | ISS-011 duplicates | dim_account |
| account_name | NVARCHAR | Organisation name (not personal data) | - | dim_account |
| account_type | VARCHAR | Hospital, Clinic, Pharmacy, Pharmacy Chain, Distributor, Wholesaler, Medical Center | - | dim_account |
| city | NVARCHAR | City | - | dim_account |
| territory | VARCHAR | Sales territory | - | dim_account |
| tax_id | VARCHAR | Tax number (candidate business key) | ISS-012 null | removed |
| phone | VARCHAR | Contact phone | ISS-013 null | removed |
| status | VARCHAR | Active / Inactive | - | dim_account |
| parent_account_id | VARCHAR | Parent account, self-reference for the account hierarchy | must reference a valid account (BR-11) | dim_account |

## raw_hcp_account_affiliations · Bridge · 1 row = 1 HCP-account relationship over time

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| affiliation_id | VARCHAR | Relationship identifier (PK) | ISS-014 duplicates | fact_hcp_account_affiliation |
| hcp_id | VARCHAR | FK → HCP | orphan `HCP99999` (quarantined) | hcp_key |
| account_id | VARCHAR | FK → account | orphan `ACC99999` (quarantined) | account_key |
| role | VARCHAR | Consultant, Department Head, Medical Director, Pharmacy Manager, Staff | - | fact |
| primary_affiliation | BIT | Y/N → 1/0: HCP's main workplace | ISS-016 overlapping primaries | flag |
| start_date | DATE | Relationship start | ISS-015 start > end (swapped) | fact |
| end_date | DATE | Relationship end; NULL = ongoing | ISS-017 sentinel 1900, ISS-018 missing | fact |
| status | VARCHAR | Active / Inactive | ISS-017 status vs dates | flag |

## raw_products · Product master · 1 row = 1 product

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| product_id | VARCHAR | Product identifier (PK) | orphan `PRD999` in other tables | dim_product |
| product_name | NVARCHAR | Product name | - | dim_product |
| therapeutic_area | VARCHAR | Oncology, Cardiology, CNS, Diabetes, Dermatology, Respiratory | ISS-019 case (`cardiology`), ISS-020 null | dim_product |
| product_type | VARCHAR | Prescription, OTC | - | dim_product |
| priority_flag | BIT | Y/N → 1/0: strategic priority product | - | dim_product |
| launch_date | DATE | Market launch date | ISS-021 `2027-15-40` | dim_product |
| status | VARCHAR | Active / Discontinued | - | dim_product |

## raw_field_reps · Field-force master · 1 row = 1 sales representative

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| rep_id | VARCHAR | Rep identifier (PK) | ISS-022 duplicate | dim_field_rep |
| rep_name | NVARCHAR | Rep name | - | dim_field_rep (RLS) |
| territory | VARCHAR | Assigned territory | ISS-024 mismatch, ISS-025 blank, lower-case variants - all resolved by re-deriving from base_city | dim_field_rep |
| base_city | NVARCHAR | Home-base city (source of truth for territory) | - | dim_field_rep |
| hire_date | DATE | Hire date | ISS-026 `2026-99-99` | used for flag |
| status | VARCHAR | Active / Inactive | - | dim_field_rep |
| specialization | VARCHAR | Primary Care, Specialty Care, Hospital, Key Account | - | dim_field_rep |

## raw_interactions · Fact · 1 row = 1 rep-HCP interaction at an account

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| interaction_id | VARCHAR | Interaction identifier (PK) | ISS-027 duplicates | fact_interactions |
| interaction_datetime | DATETIME2 | Date and time of the interaction | ISS-028 before rep hire | date_key + flag |
| hcp_id | VARCHAR | FK → HCP | orphan quarantined | hcp_key |
| account_id | VARCHAR | FK → account where it took place | orphan quarantined | account_key |
| rep_id | VARCHAR | FK → field rep | - | rep_key |
| product_id | VARCHAR | FK → product discussed | - | product_key |
| interaction_type | VARCHAR | Type of interaction | - | fact |
| channel | VARCHAR | Interaction channel | - | fact |
| duration_minutes | INT | Duration | ISS-029 negative | fact + flag |
| outcome | VARCHAR | Result of the interaction | ISS-030 null | fact + flag |
| engagement_score | DECIMAL(4,1) | Engagement rating | - | fact |

## raw_events · Event master · 1 row = 1 medical event

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| event_id | VARCHAR | Event identifier (PK) | ISS-031 duplicates | dim_event |
| event_name | NVARCHAR | Event name | - | dim_event |
| event_type | VARCHAR | CME, Congress, Product Symposium, Roundtable, Workshop | - | dim_event |
| start_date / end_date | DATE | Event dates | ISS-032 sentinel `2020-01-01` | dim_event |
| city / territory | VARCHAR | Location | - | dim_event |
| product_id | VARCHAR | FK → product promoted | ISS-033 before launch | product_key + flag |
| budget | DECIMAL(12,2) | Event budget | - | dim_event |
| status | VARCHAR | Planned, Completed, Cancelled | - | dim_event |

## raw_event_registrations · Fact · 1 row = 1 HCP registration to an event

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| registration_id | VARCHAR | Registration identifier (PK) | ISS-034 duplicates | fact_event_registrations |
| event_id | VARCHAR | FK → event | orphan `EVT99999` quarantined | event_key |
| hcp_id | VARCHAR | FK → HCP | orphan quarantined | hcp_key |
| registration_date | DATE | Date of registration | ISS-035 after event start | date_key + flag |
| attendance_status | VARCHAR | Attendance outcome | ISS-036 case, ISS-037 null | fact + flag |
| follow_up_required | BIT | Y/N → 1/0 | - | fact |
| follow_up_status | VARCHAR | Follow-up progress | - | fact |
| source | VARCHAR | Registration channel | - | fact |

## raw_sales · Fact · 1 row = 1 sales transaction (account level, no HCP)

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| sales_id | VARCHAR | Transaction identifier (PK) | ISS-038 duplicates | fact_sales |
| sales_date | DATE | Transaction date | ISS-039 before launch | date_key + flag |
| account_id | VARCHAR | FK → customer account | orphan quarantined | account_key |
| product_id | VARCHAR | FK → product | orphan quarantined | product_key |
| territory | VARCHAR | Territory on the invoice | - | hidden (account territory used) |
| sales_channel | VARCHAR | Sales channel | ISS-040 case, ISS-043 null | fact + flag |
| order_type | VARCHAR | Order type | - | fact |
| invoice_number | VARCHAR | Invoice reference (candidate business key) | ISS-044 null | fact + flag |
| quantity | INT | Units | ISS-041 negative | fact + flag |
| unit_price | DECIMAL | Price per unit | ISS-042 ≤ 0 | fact + flag |
| sales_amount | DECIMAL | Transaction value | ISS-045 ≠ qty × price | fact + flag |

## raw_campaigns · Campaign · 1 row = 1 campaign

| Column | Type | Description | Known issues | Model |
|---|---|---|---|---|
| campaign_id | VARCHAR | Campaign identifier (PK) | ISS-046 duplicates | fact_campaign |
| campaign_name | NVARCHAR | Campaign name | ISS-047 null | fact + flag |
| campaign_type | VARCHAR | HCP Engagement, Product Education, Awareness, Launch, Advisory | ISS-048 case, ISS-049 null | fact + flag |
| product_id | VARCHAR | FK → product | orphan `PRD999` quarantined | product_key |
| start_date / end_date | DATE | Campaign period | ISS-050 start > end, ISS-053/054 invalid dates | start_date_key / end_date_key |
| target_hcp_count | INT | Planned number of HCPs to reach | ISS-051 negative | fact + flag |
| budget | DECIMAL | Campaign budget | - | fact |
| status | VARCHAR | Planned, Active, Completed, Cancelled | ISS-052 case, ISS-055 null | fact + flag |
