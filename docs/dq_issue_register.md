# Data-Quality Issue Register

Every issue found in profiling / DQ assessment gets an `ISS-xxx` id, is linked to the rule that
caught it (`DQ-xxx` = technical rule, `BR-xxx` = business rule) and is resolved in **exactly one
layer**. Method and patterns: [03 · Data Quality Approach](03_data_quality_approach.md).

**Treatment legend**
`Fix` value changed (cause confirmed) · `Flag` value kept, `*_flag = 1` added · `Quarantine` row moved out of the main table ·
`Accept` documented as valid, no change · `Merged` symptom of another issue, disappears when that one is fixed

| Issue | Table | Rule | Finding | Layer | Treatment |
|---|---|---|---|---|---|
| ISS-001 | hcp | DQ-002 | 20 exact-duplicate `hcp_id` rows | Staging | Fix - dedup (`ROW_NUMBER` over all columns) |
| ISS-002 | hcp | DQ-009 | `email` NULL / blank | Staging | Fix - blanks → NULL; field confirmed optional |
| ISS-003 | hcp | DQ-142 | `email` sentinel `'invalid-email'` | Staging | Fix - → NULL |
| ISS-004 | hcp | DQ-140 | duplicate e-mail values | - | Merged into ISS-001 |
| ISS-005 | hcp | DQ-010 | invalid e-mail format | - | Merged into ISS-003 |
| ISS-006 | hcp | DQ-012 | `phone` NULL / blank | Staging | Fix - blanks → NULL; field optional |
| ISS-007 | hcp | DQ-143 | `phone` sentinel `'12345'` | Staging | Fix - → NULL; stored as `VARCHAR(15)` not INT |
| ISS-008 | hcp | DQ-141 | duplicate phone values | - | Merged into ISS-001 |
| ISS-009 | hcp | DQ-013 | invalid phone format | - | Merged into ISS-007 |
| ISS-010 | hcp | BR-009 | "Active HCP with no interaction in 90 days" = 13 | Master | **Closed - false positive.** Original check used `GETDATE()`; re-run at as-of date 2026-06-29 → 0 violations |
| ISS-011 | customer_accounts | DQ-016 | 6 exact-duplicate `account_id` rows | Staging | Fix - dedup |
| ISS-012 | customer_accounts | DQ-023 | `tax_id` NULL | Master | Accept - business confirmed no backfill |
| ISS-013 | customer_accounts | DQ-024 | `phone` NULL | Master | Accept - no backfill |
| ISS-014 | affiliations | DQ-029 | 50 exact-duplicate `affiliation_id` rows | Staging | Fix - dedup |
| ISS-015 | affiliations | BR-014 | `start_date > end_date` (169 rows) | Master | Fix - swap dates, `date_swap_applied = 1` |
| ISS-016 | affiliations | BR-017 | overlapping primary affiliations | Master | Flag - `primary_overlap_flag` (pending Commercial Ops) |
| ISS-017 | affiliations | BR-018 | `end_date` sentinel `1900-xx-xx` (5,525) + real status/date mismatch (747) | Staging + Master | Sentinel → NULL (staging); mismatch → `status_date_mismatch_flag` |
| ISS-018 | affiliations | DQ-036 | `end_date` missing while status Inactive | Master | Accept as-is, no backfill |
| ISS-019 | products | BR-020 | `therapeutic_area` case (`cardiology`) | Staging | Fix - mapping table |
| ISS-020 | products | DQ-044 | `therapeutic_area` NULL (3) | Master | Flag - `missing_therapeutic_area_flag` |
| ISS-021 | products | DQ-048 | `launch_date` sentinel `2027-15-40` | Staging | Fix - `TRY_CAST` → NULL |
| ISS-022 | field_reps | DQ-051 | 1 duplicate `rep_id` | Staging | Fix - dedup |
| ISS-023 | field_reps | BR-026 | - | - | Merged into DQ-055 |
| ISS-024 | field_reps | BR-028 | `base_city` ↔ `territory` mismatch (153 reps, 69.23%) | Master | Fix - `base_city` is the truth; territory re-derived from confirmed 10-city mapping, `territory_source` audit column |
| ISS-025 | field_reps | DQ-055 | `territory` blank (6) | Master | Fix - filled from `base_city` mapping (same mechanism as ISS-024) |
| ISS-026 | field_reps | DQ-058 | `hire_date` sentinel `2026-99-99` | Staging | Fix - `TRY_CAST` → NULL |
| ISS-027 | interactions | DQ-063 | 640 exact-duplicate `interaction_id` rows | Staging | Fix - dedup |
| ISS-028 | interactions | BR-033 | interaction before rep `hire_date` (31,428 / 10.13%) | Master | Flag - `pre_hire_interaction_flag` |
| ISS-029 | interactions | BR-036 | negative `duration_minutes` (601 / 0.19%) | Master | Flag - `negative_duration_flag` |
| ISS-030 | interactions | DQ-074 | `outcome` NULL (7,341 / 2.29%) | Master | Flag - `missing_outcome_flag` |
| ISS-031 | events | DQ-079 | 2 duplicate `event_id` rows | Staging | Fix - dedup |
| ISS-032 | events | BR-039 | `end_date` sentinel `2020-01-01` → start > end | Staging | Fix - confirmed sentinel → NULL |
| ISS-033 | events | BR-045 | event before product launch (85 / 16.87%) | Master | Flag - `pre_launch_event_flag` (valid pre-launch activity, excluded from post-launch analysis) |
| ISS-034 | event_registrations | DQ-096 | 975 duplicate `registration_id` rows | Staging | Fix - dedup |
| ISS-035 | event_registrations | BR-046 | registration after event start (51.16%) | Master | Flag - `registration_after_event_flag` |
| ISS-036 | event_registrations | BR-047 | `attendance_status` case (12,815 / 1.97%) | Staging | Fix - mapping table |
| ISS-037 | event_registrations | DQ-101 | `attendance_status` NULL for past events (11,651 / 1.79%) | Master | Flag - `missing_attendance_for_past_event_flag` |
| ISS-038 | sales | DQ-107 | 1,050 duplicate `sales_id` rows | Staging | Fix - dedup |
| ISS-039 | sales | BR-050 | sale before product launch (159,341 / 16.40%) | Master | Flag |
| ISS-040 | sales | BR-052 | `sales_channel` case (15,586 / 1.48%) | Staging | Fix - mapping table |
| ISS-041 | sales | BR-054 | negative `quantity` (801 / 0.08%) | Master | Flag - excluded from `Total Sales` measure |
| ISS-042 | sales | BR-055 | `unit_price ≤ 0` (501 / 0.05%) | Master | Flag - excluded from `Total Sales` measure |
| ISS-043 | sales | DQ-113 | `sales_channel` NULL (12,549 / 1.19%) | Master | Flag |
| ISS-044 | sales | DQ-115 | `invoice_number` NULL (7,342 / 0.70%) | Master | Flag |
| ISS-045 | sales | BR-057 | `sales_amount ≠ quantity × unit_price` (1,301 / 0.12%) | Master | Flag - not recomputed (unknown which field is wrong) |
| ISS-046 | campaigns | DQ-125 | 2 duplicate `campaign_id` rows | Staging | Fix - dedup |
| ISS-047 | campaigns | DQ-126 | `campaign_name` NULL (1) | Master | Flag |
| ISS-048 | campaigns | BR-058 | `campaign_type` case (`hcp engagement`) | Staging | Fix - case map |
| ISS-049 | campaigns | DQ-129 | `campaign_type` NULL (1) | Master | Flag |
| ISS-050 | campaigns | BR-059 | `start_date > end_date` (CAM0062) | Master | Flag - cause not confirmed |
| ISS-051 | campaigns | BR-060 | negative `target_hcp_count` (1) | Master | Flag |
| ISS-052 | campaigns | BR-062 | `status` case (`active`) | Staging | Fix - case map |
| ISS-053 | campaigns | DQ-132 | `start_date` invalid (`2026-13-05`) | Staging | Fix - `TRY_CAST` → NULL |
| ISS-054 | campaigns | DQ-134 | `end_date` invalid (`2025-02-30`) | Staging | Fix - `TRY_CAST` → NULL |
| ISS-055 | campaigns | DQ-139 | `status` NULL (1) | Master | Flag |
| ISS-056 … 064 | affiliations, interactions, event_registrations, sales, campaigns | RI | Sentinel foreign keys (`HCP99999`, `ACC99999`, `EVT99999`, `PRD999`) | Staging | Quarantine - never silently remapped (Business Rule 7) |
| ISS-065 | sales, interactions, event_registrations | BR-049 | rows dated after the as-of date 2026-06-29 (48,065 sales · 20,801 interactions · 30,165 registrations). Missed at first because BR-049 compares with `GETDATE()` | Report | Excluded by the report-level filter `Date <= 29-Jun-2026`; source fix pending *(found in final review)* |
| ISS-066 | event_registrations | - | 4,687 registrations marked *Attended* for events that start after the as-of date | Report | Attendance Rate % only counts past events; WARN in `validation.sql` *(found in final review)* |
| ISS-067 | hcp, field_reps vs interactions | - | status does not match activity: 51 % of interactions (last 12 months) go to HCPs marked *Inactive*, 54 % are logged by reps marked *Inactive* | Master data | Review - statuses to be refreshed by CRM / master data; "active HCP" KPIs read with care *(found in final review)* |

## Summary by treatment

| Treatment | Where | Principle |
|---|---|---|
| Fix | Staging | Technical defects with an unambiguous correct form (type, whitespace, case, sentinel, exact duplicate) |
| Fix | Master | Business corrections **only after the cause is confirmed**, always with an audit column |
| Flag | Master | Cause unknown or decision pending - data kept, measures exclude or segment it |
| Quarantine | Staging | Orphan foreign keys - kept for investigation, excluded from analytics |
| Accept | Master | Confirmed valid business state |
