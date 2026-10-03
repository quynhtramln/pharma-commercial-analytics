# 07 · Validation, Limitations & Next Steps

All checks live in [`sql/09_validation/validation.sql`](../sql/09_validation/validation.sql). Each one
returns a status of PASS, FAIL, or WARN for a known, documented item.

## 1 · Row-count lineage

Master and warehouse keep exactly the staging row count. Staging = raw − quarantined − exact duplicates.

| Entity | Raw | Staging = Master = Warehouse |
|---|---:|---:|
| hcp | 5,220 | 5,200 |
| customer_accounts | 1,106 | 1,100 |
| hcp_account_affiliations | 12,550 | 12,360 |
| products | 40 | 40 |
| field_reps | 221 | 220 |
| interactions | 320,640 | 319,570 |
| events | 552 | 550 |
| event_registrations | 650,975 | 649,300 |
| sales | 1,051,050 | 1,048,300 |
| campaigns | 72 | 69 |

The warehouse counts match the tables loaded in the Power BI model.

## 2 · Model integrity

- Surrogate keys are unique in every dimension.
- Every fact foreign key finds its dimension row; orphans were quarantined in staging.
- Each mart table has exactly one row per dimension row, which the one-to-one relationships in Power BI require.

## 3 · KPI reconciliation (SQL = Power BI)

Period: 1 Jan 2023 to 29 Jun 2026, the same as the report-level filter.

| KPI | Power BI | SQL (`validation.sql` §3) | Match |
|---|---:|---:|:---:|
| Total Sales | $482,177,312.05 | 482,177,312.05 | ✅ |
| YoY Growth % (H1 2026 vs H1 2025) | 0.59 % | 0.59 | ✅ |
| Total Engagement | 298,769 | 298,769 | ✅ |
| Coverage Rate % | 100.00 % | 100.00 | ✅ |
| Attendance Rate % | 24.61 % | 24.61 | ✅ after fix |
| Follow-up Completion % | 33.44 % | 33.44 | ✅ |

**What the reconciliation caught.** Attendance Rate % first did not match. SQL returned 24.61 %, but
the DAX measure gave 25.35 %. The numerator `[Attended Count]` counted attendances for **all**
events, while the denominator only counted events already held. As a result, 4,457 "Attended"
records on future events (ISS-066) inflated the rate. The measure was fixed by adding the same
`Event Start Date <= As Of Date` filter to the numerator. This is exactly why every KPI is
reconciled against SQL before release.

## 4 · Business sanity

| Check | Expected |
|---|---|
| Rows with negative quantity or zero price without a flag | 0 · PASS |
| Affiliations with start > end after the swap | 0 · PASS |
| Engagement score outside 1-10 | 0 · PASS |
| Attended registrations for events not yet started | 4,687 · WARN (ISS-066) |
| Sales dated after the as-of date | 48,065 · WARN (ISS-065, excluded by the report filter) |

## 5 · UAT

| Scenario | Expected |
|---|---|
| Drill Year → Quarter → Month | quarters, then months in calendar order |
| 12-month trend on Overview | exactly 12 points, Jul 2025 → Jun 2026 |
| Therapeutic area → product drill | only the products of that area |
| Account-by-territory matrix | account totals add up to the territory total |
| Drill-through to account / HCP / rep | the detail page is filtered to that entity only |
| What-if thresholds on Engagement vs sales gap / Data quality | counts and lists update together |
| Drag a raw numeric column into a visual | not possible (values go through measures) |

## Open checks found during review

| Item | Detail | Next step |
|---|---|---|
| ISS-045 amount ≠ qty × price | flagged on 1,301 rows in raw profiling, but `amount_mismatch_flag` = 0 in the warehouse | confirm whether casting to `DECIMAL(10,2)` / `DECIMAL(12,2)` removed rounding-only differences, then close or re-open the issue |
| Mart scripts | the first versions had no upper date bound and used a different engagement count than the tables in the .pbix | the 4 mart build queries were updated to the logic that reproduces the Power BI tables exactly (checked row by row): as-of bound, Business Rule 6 exclusions, engagement through active affiliations |

## Known limitations

| Area | Limitation | Effect |
|---|---|---|
| Causality | Engagement and sales meet only through account affiliation | Q4 / Q8 show association, not impact |
| Campaigns | No link from campaigns to interactions or sales | Campaign ROI is out of scope |
| Open issues | Overlapping primary affiliations wait for Commercial Ops; 55 % of HCPs have no active primary affiliation | HCP opportunity uses a temporary rule ([D-12](decision_log.md)) |
| Status fields | 51 % of interactions go to HCPs marked inactive and 54 % are logged by inactive reps | "Active HCP" figures (coverage, recency) depend on statuses that are out of date |
| Flagged data | e.g. 49 % of registrations after event start | visible on the Data quality page; timing metrics need care |
| Synthetic data | many measures are uniform (attendance 25 %, channels ⅓ each) | insights are framed as "the metric does not discriminate", see [docs/06](06_insights_and_recommendations.md#note-on-the-data) |
| Deployment | Power BI Desktop only | no scheduled refresh; row-level security designed but not enforced |

## If this went to production

1. Close out event outcomes and correct launch and hire dates at source (the top DQ items).
2. Add a campaign ↔ HCP bridge to measure campaign effectiveness.
3. Add incremental loads and SCD Type 2 for HCP territory and specialty.
4. Publish to Power BI Service with scheduled refresh and enforced row-level security.
5. Run `validation.sql` after every load and trend the DQ score over time.
