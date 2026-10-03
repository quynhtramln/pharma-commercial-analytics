# 05 · Semantic Model & Dashboard

## Semantic model

| Component | Count | Detail |
|---|---:|---|
| Tables from SQL Server | 16 | 6 dimensions · 5 facts · 5 mart tables, Import mode, source set by Power Query parameters `pServer` / `pDatabase` |
| DAX measures | 101 | 10 display folders (Sales, Engagement, Coverage, Events, Engagement-Sales Gap, Opportunity, Data Quality, Drill-through …); 100 carry a business description |
| Field parameters | 5 | Account, HCP, Rep, Event and Segment views: one visual, the user picks the dimension |
| What-if parameters | 3 | Engagement threshold and Sales threshold (0.5× to 2× the median), DQ target (90 % to 100 %) |
| Calculated tables | 2 | `DQ Flag Catalog` (20 flags: table, column, type, severity) · `Segment` |
| Calculated columns | 7 | `Quarter`, `Year Month`, `Year Month Sort`, `Is Last 12M`, Yes/No labels |
| Relationships | 22 | 15 dimension → fact · 1 snowflake · 1 inactive role-playing date · 5 one-to-one dimension ↔ mart |

Full list of measures: [`powerbi/measures.dax`](../powerbi/measures.dax) · relationships: [`powerbi/README.md`](../powerbi/README.md#relationships)

### Governance built into the model

| Choice | Why it matters |
|---|---|
| Every number goes through a measure that applies the DQ exclusions | Nobody can drag `sales_amount` and get an uncleaned sum ([D-11](decision_log.md)) |
| Business definitions stored as **measure descriptions** | the definition travels with the measure and shows on hover |
| One fixed **`As Of Date`** measure (29 Jun 2026) used by all time logic instead of `TODAY()` | results are reproducible on any day ([D-09](decision_log.md)) |
| Columns renamed with entity prefixes (*HCP Territory*, *Account Territory*, *Rep Territory*, *Event Territory*) | several tables have a territory column; prefixes prevent wrong-field errors |
| Data-quality flags modelled as a **catalog** (`DQ Flag Catalog`) with severity | the DQ score and the Data quality page are driven by data, not hard-coded per table |
| `Year Month` axis for the 12-month trend | the window spans two years; month name alone would merge June 2025 and June 2026 |
| Rep names designed for row-level security | only Field Force Management sees individual names |

### Measure examples (from the model)

```dax
// Sum of sales_amount. Excludes rows with negative quantity or non-positive unit price
// (Business Rule 6). Sales are attributed to accounts, not HCPs.
Total Sales =
CALCULATE(
    SUM(fact_sales[sales_amount]),
    fact_sales[negative_quantity_flag] = FALSE(),
    fact_sales[non_positive_price_flag] = FALSE()
)

// Interactions of HCPs with an Active affiliation to the account, via the HCP-account
// affiliation bridge. Not additive across accounts: one HCP can be affiliated to several.
Engagement Index =
VAR AffHCP =
    CALCULATETABLE(
        VALUES(fact_hcp_account_affiliation[hcp_key]),
        fact_hcp_account_affiliation[Affiliation Status] = "Active"
    )
RETURN
    CALCULATE([Total Engagement], REMOVEFILTERS(dim_account), TREATAS(AffHCP, dim_hcp[hcp_key]))

// Accounts with Engagement Index at or above the engagement threshold and Total Sales below
// the sales threshold. Thresholds = median x what-if multiplier. Association only.
Engagement-Sales Gap Accounts =
VAR EngCut   = [Median Account Engagement] * [Engagement Threshold Value]
VAR SalesCut = [Median Account Sales] * [Sales Threshold Value]
RETURN
    COUNTROWS(
        FILTER(VALUES(dim_account[account_key]),
            [Engagement Index] >= EngCut && [Total Sales] < SalesCut)
    )

// 1 minus flagged rows divided by total rows; weighted by row count.
DQ Score % = 1 - DIVIDE([DQ Flagged Rows], [DQ Table Rows])
```

## Dashboard

10 pages, 3 drill-through pages and 2 report-page tooltips. A left navigation groups the pages into
**Overview · Commercial · Engagement · Opportunity · Admin**, and a global filter panel is available
on every page.

| # | Page | Group | Answers | Main visuals |
|---|---|---|---|---|
| 01 | **Overview** | Overview | summary | KPI cards · sales and HCP interactions over the last 12 months · auto-generated highlight text |
| 02 | **Sales trend** | Commercial | Q1 | KPI cards · monthly sales (with a *sales by product* tooltip) · sales by selectable dimension · sales by therapeutic area |
| 03 | **Account growth** | Commercial | Q2 | growth by dimension · accounts by growth tier · top accounts driving growth |
| 04 | **Product momentum** | Commercial | Q7 | sales growth vs engagement trend scatter · sales change and momentum by therapeutic area |
| 05 | **HCP engagement** | Engagement | Q3 | interactions by selectable dimension · by therapeutic area · HCP leaderboard with switchable views (bookmarks) |
| 06 | **Field coverage** | Engagement | Q5 | territory coverage by dimension · rep coverage table |
| 07 | **Events** | Engagement | Q6 | attendance by event type / territory · event detail matrix |
| 08 | **Engagement vs sales gap** | Opportunity | Q4 | engagement vs sales scatter with **what-if thresholds** · gap-account matrix · account-profile tooltip |
| 09 | **Opportunity segments** | Opportunity | Q8 | segment mix by dimension · account and HCP target lists |
| 10 | **Data quality** | Admin | Q9 | quality score by table · flagged rows by type and severity · flag detail · **what-if DQ target** |
| - | Account detail | drill-through | - | monthly sales · sales by product · affiliated HCPs (opened from pages 03, 08, 09) |
| - | HCP detail | drill-through | - | monthly interactions · recent interactions · affiliated accounts · event history (from 05, 09, Account detail) |
| - | Rep detail | drill-through | - | monthly interactions · HCPs and accounts reached (from 06) |
| - | TT Sales by product · TT Account profile | tooltip pages | - | hover detail on the sales trend and the gap scatter |

### Design decisions
- Engagement ↔ sales pages carry an on-page note: *association only*, high engagement does not prove sales will follow (Business Rule 8).
- Drill paths stop where a metric stops being meaningful - e.g. events stop at event level, because
  per registration attendance is always 0 % or 100 % ([D-13](decision_log.md)).
- Drill-through pages state where they can be opened from, so the user is never lost.
- An on-page "how to use" note reminds Desktop users to Ctrl + click buttons.
- An **HTML version** of the report is published so reviewers without Power BI can explore it.
