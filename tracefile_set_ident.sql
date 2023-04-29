alter session set tracefile_identifier='&1';
select value as tracefile_name from v$diag_info where name = 'Default Trace File';