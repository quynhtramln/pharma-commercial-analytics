# 01 · Business Context

> [!IMPORTANT]
> **All data in this project is synthetic.** It was generated for this portfolio case and designed
> from hands-on experience in HCP data operations. No real company, healthcare professional,
> customer, product or transaction is represented, and all names (e.g. *HCP Professional 00001*,
> *Pharma Product 001*) are fictitious. Defects such as duplicates and invalid dates were injected
> on purpose to exercise the data-quality pipeline.

> **Storyline:** HCP Engagement → HCP/Account Relationship → Account Coverage → Commercial Performance

## The situation

A pharmaceutical company works with two very different groups:

- **Healthcare Professionals (HCPs)** - doctors, pharmacists, nurses. The company *engages* them
  through field-rep visits, medical events and campaigns. HCPs influence clinical adoption, but
  **they are not invoiced**.
- **Customer accounts** - hospitals, clinics, pharmacies, pharmacy chains, distributors,
  wholesalers, medical centres. This is **where sales are recorded**.

An HCP can work at several accounts, and an account has many HCPs. So the question leadership really
cares about - *"is our engagement effort landing where the commercial opportunity is?"* - can only be
answered by bridging the two worlds carefully, without pretending that a visit *caused* a sale.

## The problem

Commercial leadership had data from CRM, events and sales systems, but:

1. **No single view** linking HCP engagement to account-level sales.
2. **Low trust in the numbers** - duplicates, placeholder values, broken dates and orphan records
   meant different reports disagreed.
3. **No clear prioritisation** - which accounts, HCPs, products and territories deserve attention next.

## Objective

Build an end-to-end analytics solution - from raw extracts to a governed data model and a Power BI
report - that answers nine business questions **and states how far each answer can be trusted**.

## Business questions

| # | Domain | Question | Decision it supports |
|---|---|---|---|
| Q1 | Commercial | How are sales trending by month, territory, account type, product and therapeutic area? | Where performance is moving |
| Q2 | Accounts | Which customer accounts drive growth? | Key-account focus |
| Q3 | HCP engagement | Which HCPs engage strongly with priority products? | Medical / marketing targeting |
| Q4 | Engagement → sales | Which accounts have strong HCP engagement but low commercial penetration? | Where access or distribution may be blocking sales |
| Q5 | Field force | How effectively does the field force cover active HCPs / accounts? | Call-plan re-balancing |
| Q6 | Events | Which events generate strong attendance and follow-up? | Event budget allocation |
| Q7 | Products | Which products / therapeutic areas gain or lose momentum? | Brand investment |
| Q8 | Opportunity | Which HCP / account segments represent opportunity? | Target lists for the next cycle |
| Q9 | Data trust | How does data quality affect reporting trust? | Which numbers to act on, what to fix at source |

## Stakeholders

| Stakeholder | Needs | Report pages |
|---|---|---|
| Commercial leadership | Performance and growth at a glance | 01 Overview, 02 Sales trend, 03 Account growth |
| Marketing / Medical | HCP engagement, events, product momentum | 04 Product momentum, 05 HCP engagement, 07 Events |
| Field Force Management | Coverage, rep productivity | 06 Field coverage, Rep detail |
| Key Account Management | Gap and opportunity accounts | 08 Engagement vs sales gap, 09 Opportunity segments, Account detail |
| Data / BI owner | Reporting trust | 10 Data quality |

## Guiding principles

- Sales are attributed to **accounts**, engagement to **HCPs** - never mixed.
- Engagement ↔ sales findings are **associations, not causation**.
- **The source is never edited**; every correction is traceable.
- **A value is changed only when the cause is confirmed** - otherwise it is flagged and the report shows its impact.

*Synthetic case built from hands-on experience in HCP data operations; not a representation of any real company.*
