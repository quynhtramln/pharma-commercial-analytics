/* =============================================================================
   00_setup / create_database_and_schemas.sql
   Purpose : Create the database and one schema per layer (idempotent)
   ============================================================================= */

IF DB_ID(N'New_Project_Healthcare_Pharma_Commercial') IS NULL
    CREATE DATABASE New_Project_Healthcare_Pharma_Commercial;
GO
USE New_Project_Healthcare_Pharma_Commercial;
GO
IF SCHEMA_ID(N'raw')       IS NULL EXEC (N'CREATE SCHEMA raw');        -- source as received, never modified
IF SCHEMA_ID(N'stg')       IS NULL EXEC (N'CREATE SCHEMA stg');        -- typed, trimmed, de-duplicated; quarantine + mapping tables
IF SCHEMA_ID(N'master')    IS NULL EXEC (N'CREATE SCHEMA master');     -- trusted entities: surrogate keys, audited fixes, DQ flags
IF SCHEMA_ID(N'warehouse') IS NULL EXEC (N'CREATE SCHEMA warehouse');  -- star schema, PII removed (Power BI source)
IF SCHEMA_ID(N'mart')      IS NULL EXEC (N'CREATE SCHEMA mart');       -- analytical tier tables + views
GO
