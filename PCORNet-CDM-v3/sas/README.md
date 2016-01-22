# SAS Queries

These directories contain SAS queries against the PCORNet CDM v.3 data model.


1. **create-sas-tables** - From ADVANCE CDRN
  * Script to create SAS data files from SQL Server tables for PCORNet CDM v 3.0
2. **diagnostic** - From PCORNet DRN OC
  * Contains diagnostic queries to verify metadata-level model conformance
  * Will generate counts for all 15 CDM tables
  * This diagnostic query is a prerequisite for data characterization queries
2. **data-characterization** - From PCORNet DRN OC
  * Will contain queries to verify record-level model  conformance
  * Will characterize the 7 expected tables (Demographic, Enrollment, Encounter, Diagnosis, Procedures, Vital and Harvest)
4. **research-queries** - From multiple sources
  * Exemplar SAS research queries against the PCORNet CDM
