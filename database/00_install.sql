WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET DEFINE OFF
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT Creating the university schema...
@@01_create_tables.sql

PROMPT Loading sample data...
@@04_sample_data.sql

PROMPT Creating views and indexes...
@@05_views.sql
@@06_indexes.sql

PROMPT Creating PL/SQL examples...
@@06_sequences.sql
@@07_triggers.sql
@@08_procedures.sql
@@10_packages.sql

PROMPT Installation completed successfully.
EXIT SUCCESS
