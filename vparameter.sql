col NAME                    format a30
col VALUE                   format a15
col DISPLAY_VALUE           format a15
col ISDEFAULT               format a9
col ISSES_MODIFIABLE        format a16
col ISSYS_MODIFIABLE        format a16
col ISINSTANCE_MODIFIABLE   format a21
col ISMODIFIED              format a10
col ISADJUSTED              format a10
col ISDEPRECATED            format a12
col ISBASIC                 format a7
col DESCRIPTION             format a150
col UPDATE_COMMENT          format a150 noprint
col hash                                noprint

select * 
from v$parameter 
where upper(name) like upper('%&1%')
  or upper(DESCRIPTION) like upper('%&1%');
  
col NAME                    clear
col VALUE                   clear
col DISPLAY_VALUE           clear
col ISDEFAULT               clear
col ISSES_MODIFIABLE        clear
col ISSYS_MODIFIABLE        clear
col ISINSTANCE_MODIFIABLE   clear
col ISMODIFIED              clear
col ISADJUSTED              clear
col ISDEPRECATED            clear
col ISBASIC                 clear
col DESCRIPTION             clear
col UPDATE_COMMENT          clear
