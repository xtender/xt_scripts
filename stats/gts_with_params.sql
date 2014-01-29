accept tab_owner - 
       prompt 'Enter value for owner mask[&_USER]: ' -
       default '&_USER';

accept tab_name - 
       prompt 'Enter value for table mask: ';

accept _CASCADE            prompt 'CASCADE [TRUE]  : ' default 'true';
accept _DEGREE             prompt 'DEGREE          : ';
accept _ESTIMATE_PERCENT   prompt 'ESTIMATE_PERCENT: ';
accept _METHOD_OPT         prompt 'METHOD_OPT      : ';
--accept _NO_INVALIDATE      prompt 'NO_INVALIDATE   : ';
accept _GRANULARITY        prompt 'GRANULARITY[ALL]: ' default 'ALL';

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
                   t.owner      like upper('&tab_owner')
               and t.table_name like upper('&tab_name')
               and t.table_name not like 'BIN$%'
               and t.dropped   = 'NO'
               and t.TEMPORARY = 'N'
   )
   loop
      print('Starting gather on '||r.owner||'.'||r.table_name);
      dbms_stats.gather_table_stats( 
                  force => true 
                , ownname => r.owner
                , tabname => r.table_name
                , cascade          => &&_CASCADE
                , degree           => '&&_DEGREE'
                , estimate_percent => '&&_ESTIMATE_PERCENT'
                , method_opt       => '&&_METHOD_OPT'  --'FOR ALL COLUMNS SIZE SKEWONLY'
                , granularity      => nvl('&&_GRANULARITY','ALL')
               );
      print('Stats gathered on '||r.owner||'.'||r.table_name);
   end loop;
end;
/
set serverout off;
@stats/tab  &tab_name &tab_owner
