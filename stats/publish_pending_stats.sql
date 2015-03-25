accept _owner   prompt "Owner mask[%]: " default '%';
accept _tabname prompt "Table mask[%]: " default '%';
set serverout on;
begin
   for r in (
             select tps.owner,tps.TABLE_NAME
             from   dba_tab_pending_stats tps
             where owner like '&_owner'
               and table_name like '&_tabname'
             union 
             select cps.owner,cps.TABLE_NAME
             from   dba_col_pending_stats cps
             where owner like '&_owner'
               and table_name like '&_tabname'
            )
   loop
      dbms_stats.publish_pending_stats(
         ownname       => r.owner
        ,tabname       => r.table_name
        ,no_invalidate => false
        ,force         => true
      );
      dbms_output.put_line('Published: '||r.owner||'.'||r.table_name);
   end loop;
end;
/
set serverout off;
undef _owner   ;
undef _tabname ;
