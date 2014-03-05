def _SQL_ID="&1";

@awr/binds "&_SQL_ID";

@if "'&_O_RELEASE'>'11.2'" then
   
   @rtsm/binds "&_SQL_ID" "" "";
   
/* end if */

PROMPT *            &_C_RED *** Binds values from v$sql_bind_capture *** &_C_RESET;
col name            format a30;
col value_string    format a80;
col datatype_string format a20;
break on child_number on last_captured skip 1;

select distinct
       bc.child_number
      ,bc.last_captured
      ,bc.position
      ,bc.name
      ,bc.datatype_string
&_IF_LOWER_THAN_ORA11       ,decode(bc.datatype_string
&_IF_LOWER_THAN_ORA11              ,'TIMESTAMP',to_char(anydata.accesstimestamp(value_anydata))
&_IF_LOWER_THAN_ORA11              ,bc.value_string /*  Bug 6156624 */
&_IF_LOWER_THAN_ORA11       ) 
&_IF_ORA112_OR_HIGHER       ,bc.value_string
                            as value_string
from v$sql_bind_capture bc
where bc.sql_id       = '&_SQL_ID'
  and bc.dup_position is null
order by last_captured,child_number,position
/
col name            clear;
col value_string    clear;
col datatype_string clear;
clear break;
