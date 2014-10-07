set feed on serverout on;
accept tab_owner prompt "Table owner: ";
accept tab_name  prompt "Table name : ";
accept col_name  prompt "Column name: ";
declare
   tab_owner varchar2(30);
   tab_name  varchar2(30);
   col_name  varchar2(30);
BEGIN
   select 
       c.OWNER      
      ,c.TABLE_NAME 
      ,c.COLUMN_NAME
   into tab_owner
       ,tab_name
       ,col_name 
   from dba_tab_columns c
   where c.OWNER       like upper('&tab_owner')
     and c.TABLE_NAME  like upper('&tab_name')
     and c.COLUMN_NAME like upper('&col_name');
  
   dbms_output.put_line('Deleting histograms from: '||tab_owner||'.'||tab_name||'('||col_name||')...');
   dbms_stats.delete_column_stats(
      ownname => tab_owner
    , tabname => tab_name
    , colname => col_name
    , col_stat_type=>'HISTOGRAM'
   );
   dbms_output.put_line('Deleted!');
exception 
   when no_data_found then dbms_output.put_line('Error: column not found: '||tab_owner||'.'||tab_name||'('||col_name||')');
   when others then
     dbms_output.put_line('Error: '||sqlerrm);
END;
/
undef tab_owner tab_owner col_name
set feed off serverout off;
