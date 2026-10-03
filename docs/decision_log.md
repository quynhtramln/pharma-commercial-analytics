# Decision Log

Key design and data decisions, recorded in a lightweight ADR format (context → decision → consequence).
These are the judgement calls a reviewer should be able to challenge.

---

### D-01 · RAW is immutable
**Context** Source files contain duplicates, sentinels and broken dates.
**Decision** Load CSVs into `raw.*` as `NVARCHAR` exactly as received; every correction happens downstream.
**Consequence** Any number in the dashboard can be traced back to the untouched source row (auditability, Business Rule 10).

### D-02 · Staging fixes only what is technically unambiguous
**Context** Some defects have one correct form (whitespace, case, sentinel, exact duplicate); others need a business decision.
**Decision** Staging applies `TRIM`/`NULLIF`, `TRY_CAST`, mapping tables and exact-duplicate removal - nothing that requires knowing *why* a value is wrong.
**Consequence** Cross-table inconsistencies (e.g. interaction before rep hire date, ISS-028) pass through staging unchanged and are handled in Master.

### D-03 · Unknown cause ⇒ flag, never overwrite
**Context** e.g. `sales_amount ≠ quantity × unit_price` (ISS-045) - it is unknown which of the three fields is wrong.
**Decision** Keep the value, add a `*_flag` column; measures decide whether to exclude or segment.
**Consequence** No invented data. The Data quality page makes the flagged share visible, so users can judge reporting trust (Q9).

### D-04 · Confirmed business corrections are allowed - with an audit trail
**Context** Affiliation dates reversed (ISS-015, 169 rows); rep territory not matching base city (ISS-024, 153 reps).
**Decision** Swap the dates (`date_swap_applied = 1`); re-derive rep territory from `base_city` via the confirmed 10-city mapping (`territory_source` records old value and reason).
**Consequence** Corrected values are usable for coverage analysis and every change is reversible.

### D-05 · Orphan foreign keys are quarantined, not remapped
**Context** Sentinel FKs such as `HCP99999`, `ACC99999`, `EVT99999`, `PRD999`.
**Decision** Move to quarantine during staging; exclude from the main tables.
**Consequence** Referential integrity in the warehouse is guaranteed (Business Rule 7) without guessing the intended entity.

### D-06 · Sales belong to accounts; HCPs are engagement targets
**Context** Pharma HCPs influence prescribing but are not invoiced.
**Decision** `fact_sales` joins to `dim_account` only; HCP ↔ account is modelled through the factless bridge `fact_hcp_account_affiliation` (many-to-many).
**Consequence** Engagement ↔ sales analysis (Q4, Q8) is framed as *association at account level*, never causality (Business Rule 8).

### D-07 · Campaign is a fact, not a dimension
**Context** Campaign looks like a catalogue, but each row is something that happened with real budget and target counts.
**Decision** Model as `fact_campaign` with role-playing dates (`start_date_key` active, `end_date_key` inactive → `USERELATIONSHIP`).
**Consequence** No bridge links campaigns to sales/interactions yet, so campaign ROI is out of scope (see limitations).

### D-08 · Separate mart from warehouse
**Context** Tier labels (Growing/Declining, Rising/Stable, quadrant) are specific to today's nine questions.
**Decision** Keep the warehouse neutral and reusable; put question-specific logic in `mart.tbl_*`.
**Consequence** New questions change the mart only; the star schema stays stable.

### D-09 · Fixed as-of date `2026-06-29` instead of `GETDATE()`
**Context** BR-009 first reported 13 active HCPs with no interaction in 90 days - because it used today's date on a dataset that ends in June 2026.
**Decision** All recency logic uses the as-of date.
**Consequence** ISS-010 closed as a false positive (0 real violations); results are reproducible on any run date.

### D-10 · PII removed before the warehouse
**Context** `hcp_name`, `email`, `phone`, `tax_id` are not needed for any of the nine questions.
**Decision** Drop them in the warehouse; keep organisation names (not personal data). `rep_name` is kept but intended for row-level security.
**Consequence** The semantic model contains no personal contact data (data minimisation).

### D-11 · Measures over raw columns
**Context** Raw numeric columns still contain flagged rows (negative quantity, zero price).
**Decision** Hide all raw numeric columns, enable *Discourage implicit measures*, expose only DAX measures that apply the DQ exclusions.
**Consequence** A report author cannot accidentally `SUM` uncleaned values.

### D-12 · HCP opportunity inherits the account quadrant via the primary affiliation
**Context** HCPs have no sales of their own; some have overlapping primary affiliations (ISS-016, unresolved).
**Decision** Use the most recent primary affiliation as the representative account for overlapping HCPs.
**Consequence** Temporary rule - to be replaced once Commercial Ops confirms the correct affiliation.

### D-13 · Drill paths trimmed where they stop being meaningful
**Decision** The *Sales by [dimension]* field parameter drops *Therapeutic Area* (its drill level would be Account, not Product; therapeutic area gets its own chart); the Events page stops at event level (at registration level attendance is always 0% or 100%).
