@inc/input_vars_init.sql
prompt Gather stats by table.
prompt Syntax: @gts table owner [ESTIMATE_PERCENT]
prompt Estimate_percent by default = DBMS_STATS.AUTO_SAMPLE_SIZE
set serverout on
col p_estimate_percent new_val p_estimate_percent noprint;
select 
   case 
     when '&3' is not null 
      and translate('&3','x0123465789','x') is null 
       then '&3'
     when '&_O_RELEASE' > '11'
       then 'DBMS_STATS.AUTO_SAMPLE_SIZE'
     else '5'
   end p_estimate_percent
from dual;

set serverout on
declare
    l integer:=dbms_utility.get_time();

    procedure print(v in varchar2) is
    begin
      dbms_output.put_line(to_char((dbms_utility.get_time-l)/100,'0999.99')||' '||v);
      l:=dbms_utility.get_time();
    end;
begin
   for r in (
             select owner,table_name 
             from dba_tables t 
             where 
                   t.owner like nvl(upper('&2'),'%')
               and t.table_name like upper('&1')
               and table_name not like 'BIN$%'
               and t.TEMPORARY = 'N'
   )
   loop
      print('Starting gather on '||r.owner||'.'||r.table_name);
      dbms_stats.gather_table_stats(
                  ownname => r.owner
                , tabname => r.table_name
                , estimate_percent => &p_estimate_percent
                , cascade => true
                , method_opt => 'FOR ALL COLUMNS SIZE SKEWONLY'
               );
      print('Stats gathered on '||r.owner||'.'||r.table_name);
   end loop;
end;
/
set serverout off
@inc/input_vars_undef.sql