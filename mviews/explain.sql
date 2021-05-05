truncate table mv_capabilities_table;
call dbms_mview.explain_mview('&1');

col STATEMENT_ID for a12;
col MVOWNER for a20;
col MVNAME for a30;
col CAPABILITY_NAME for a30;
col MSGTXT for a90;
col RELATED_TEXT for a34;

select * from mv_capabilities_table;
