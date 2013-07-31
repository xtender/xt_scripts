accept _N - 
    prompt 'Enter Number for PDB:[1] ' -
    default '1'
define _P_NAME    = "pdb&_N";
define _P_ADMUSER = "&_P_NAME._sys";

prompt New PDB name = "&_P_NAME"
prompt New PDB user = "&_P_ADMUSER"

CREATE PLUGGABLE DATABASE &_P_NAME
admin user &_P_ADMUSER identified by syspass 
ROLES=(DBA)
-- default tablespace
file_name_convert = ('/pdbseed/', '/&_P_NAME/')
STORAGE (MAXSIZE 10G MAX_SHARED_TEMP_SIZE 100M)
-- path_prefix
-- tempfile_reuse_clause
/
