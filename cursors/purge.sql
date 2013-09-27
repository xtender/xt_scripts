prompt &_C_REVERSE *** Purge cursor from shared pool &_C_RESET
prompt &_C_REVERSE * Usage: @cursors/purge sqlid  &_C_RESET

col to_purge new_val _purge noprint;

select address||','||hash_value to_purge
from v$sqlarea 
where sql_id like '&1';

begin
&_IF_LOWER_THAN_ORA11 execute immediate q'[alter session set events '5614566 trace name context forever']';
&_IF_ORA10_OR_HIGHER  sys.dbms_shared_pool.purge('&_purge','C',1);
  null;
end;
/
