col tracedir new_value tracedir for a120;
select value tracedir from v$diag_info where name = 'Diag Trace';
create directory TRACE_DIR as '&tracedir';
