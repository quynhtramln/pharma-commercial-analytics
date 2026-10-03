/* =============================================================================
   run_all.sql - rebuild the whole pipeline in the right order
   SSMS: Query > SQLCMD Mode ON, set the two paths, F5   (or: sqlcmd -S . -E -i run_all.sql)
   Build path only. Profiling, DQ checks and analysis queries are run on demand.
   The source dataset is not published, so this file documents the execution order.
   ============================================================================= */
:setvar RepoPath "F:\GitHub\pharma-commercial-analytics"
:setvar DataPath "F:\Data\pharma_raw_csv"
:on error exit

:r $(RepoPath)\sql\00_setup\create_database_and_schemas.sql
:r $(RepoPath)\sql\01_raw\load_raw_tables.sql
:r $(RepoPath)\sql\04_staging\stg_products.sql
:r $(RepoPath)\sql\04_staging\stg_field_reps.sql
:r $(RepoPath)\sql\04_staging\stg_events.sql
:r $(RepoPath)\sql\04_staging\stg_hcp.sql
:r $(RepoPath)\sql\04_staging\stg_customer_accounts.sql
:r $(RepoPath)\sql\04_staging\stg_hcp_account_affiliations.sql
:r $(RepoPath)\sql\04_staging\stg_interactions.sql
:r $(RepoPath)\sql\04_staging\stg_event_registrations.sql
:r $(RepoPath)\sql\04_staging\stg_sales.sql
:r $(RepoPath)\sql\04_staging\stg_campaigns.sql
:r $(RepoPath)\sql\05_master\master_products.sql
:r $(RepoPath)\sql\05_master\master_field_reps.sql
:r $(RepoPath)\sql\05_master\master_events.sql
:r $(RepoPath)\sql\05_master\master_hcp.sql
:r $(RepoPath)\sql\05_master\master_customer_accounts.sql
:r $(RepoPath)\sql\05_master\master_hcp_account_affiliations.sql
:r $(RepoPath)\sql\05_master\master_interactions.sql
:r $(RepoPath)\sql\05_master\master_event_registrations.sql
:r $(RepoPath)\sql\05_master\master_sales.sql
:r $(RepoPath)\sql\05_master\master_campaigns.sql
:r $(RepoPath)\sql\06_warehouse\dim_date.sql
:r $(RepoPath)\sql\06_warehouse\dim_hcp.sql
:r $(RepoPath)\sql\06_warehouse\dim_account.sql
:r $(RepoPath)\sql\06_warehouse\dim_product.sql
:r $(RepoPath)\sql\06_warehouse\dim_field_rep.sql
:r $(RepoPath)\sql\06_warehouse\dim_event.sql
:r $(RepoPath)\sql\06_warehouse\fact_sales.sql
:r $(RepoPath)\sql\06_warehouse\fact_interactions.sql
:r $(RepoPath)\sql\06_warehouse\fact_event_registrations.sql
:r $(RepoPath)\sql\06_warehouse\fact_hcp_account_affiliation.sql
:r $(RepoPath)\sql\06_warehouse\fact_campaign.sql
:r $(RepoPath)\sql\07_mart\00_mart_views.sql
:r $(RepoPath)\sql\07_mart\tbl_account_growth.sql
:r $(RepoPath)\sql\07_mart\tbl_product_momentum.sql
:r $(RepoPath)\sql\07_mart\tbl_rep_coverage.sql
:r $(RepoPath)\sql\07_mart\tbl_account_opportunity.sql
:r $(RepoPath)\sql\07_mart\tbl_hcp_opportunity.sql
:r $(RepoPath)\sql\09_validation\validation.sql
