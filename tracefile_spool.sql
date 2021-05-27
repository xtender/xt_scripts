@inc/input_vars_init;
set termout off;
col payload		for a300;
spool "&2" replace
select
-- component_name,operation_name,file_name,function_name,line_number,
payload
from V$DIAG_TRACE_FILE_CONTENTS
where 
     trace_filename like '&1'
;
spool off;
col payload clear;
set termout on;

-- you can open file automatically using the following line:
-- host &_START &2

-- _START depends on OS: it is set automatically in inc/on_login_win or inc/on_login_nix
-- windows: 
-- DEFINE _START   ="start"
-- *nix:
-- DEFINE _START   ="open"
