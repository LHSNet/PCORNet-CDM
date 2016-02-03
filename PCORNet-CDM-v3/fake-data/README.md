# Test Data : PCORNet Common Data Model v 3.0

This is a test dataset of fake data for the [PCORnet Common Data Model v3.0](http://www.pcornet.org/pcornet-common-data-model/). Fake data exist for the following tables:

* DEMOGRAPHIC
* ENCOUNTER
* LAB_RESULT_CM
* PRESCRIBING
* ENROLLMENT
* DIAGNOSIS
* PROCEDURES
* VITAL
* HARVEST - coded for University of Michigan

The procedures table currently needs additional work since many of the ESP codes are not actually procedures.

These data were initally generated as an [ESP fake data model](https://popmednet.atlassian.net/wiki/pages/viewpage.action?pageId=26345558) and were converted into a PCORI data model using [custom ETL code](https://github.com/jestill/medmimic/tree/master/map_esp_to_pcori_cdmv3).

To load the data.

1. run create_pcori_cdmv3_tables.sql to create the tables
2. copy csv tables to the /tmp directory
3. run load_pcori_cdmv3_tables.sql
4. run index_pcori_cdmv3_tables.sql

This process has be successfully tested on:

* PostgreSQL 9.3.5 on x86_64-apple-darwin
