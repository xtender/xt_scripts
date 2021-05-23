col component_name	for a12;
col operation_name	for a20;
col file_name		for a12;
col function_name	for a20;
col payload		for a120;
select component_name,operation_name,file_name,function_name,line_number,payload
from V$DIAG_TRACE_FILE_CONTENTS
where 
     trace_filename like '&1'
 and function_name!='dbktWriteTimestampWCdbInfo'
;
col component_name	clear;
col operation_name	clear;
col file_name		clear;
