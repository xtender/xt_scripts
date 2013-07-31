select sql_text
from dba_hist_sqltext t
where t.sql_id='&1'
  and dbid=(select db.dbid from v$database db);
