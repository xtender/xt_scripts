@inc/input_vars_init.sql
prompt Simple gather stats by table.
prompt Syntax: @gts table owner
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
                   t.owner      like nvl(upper('&2'),user)
               and t.table_name like upper('&1')
   )
   loop
      print('Starting gather on '||r.owner||'.'||r.table_name);
      dbms_stats.gather_table_stats(r.owner,r.table_name);
      print('Stats gathered on '||r.owner||'.'||r.table_name);
   end loop;
end;
/
set serverout off
@inc/input_vars_undef.sql