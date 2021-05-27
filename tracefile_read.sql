col payload		for a300;
select
-- component_name,operation_name,file_name,function_name,line_number,
payload
from V$DIAG_TRACE_FILE_CONTENTS
where 
     trace_filename like '&1'
 and function_name!='dbktWriteTimestampWCdbInfo'
;
col payload clear;