declare
   pref     varchar2(64);
   new_pref varchar2(10) :='10';
   
   a_processed    ku$_vcnt := ku$_vcnt();
   a_notprocessed ku$_vcnt := ku$_vcnt();
   
begin
   for r in (
      select  owner,table_name
             ,max(length(owner||'.'||table_name))over() max_len
             ,num_rows,sample_size
      from dba_tables st
      where st.owner         = '&owner'
        --and st.last_analyzed < trunc(sysdate)
        and st.num_rows      > 50e6
        and st.num_rows      = sample_size
        --and st.PARTITIONED   = 'NO'
   ) 
   loop
      pref := upper(dbms_stats.get_prefs( 
                                          ownname => r.owner
                                        , tabname => r.table_name
                                        , pname => 'ESTIMATE_PERCENT'
                   ));
      if pref  = 'DBMS_STATS.AUTO_SAMPLE_SIZE' then
         dbms_stats.set_table_prefs(r.owner,r.table_name,'ESTIMATE_PERCENT',new_pref);
         a_processed.extend();
         a_processed(a_processed.last)       := rpad(r.owner||'.'||r.table_name,r.max_len);
      else
         a_notprocessed.extend();
         a_notprocessed(a_notprocessed.last) := rpad(r.owner||'.'||r.table_name,r.max_len)||': pref = '||pref;
      end if;
   end loop;
   
   dbms_output.put_line('++++++++++++++++++++++++++++++++++++++++++++++');

   dbms_output.put_line('Processed:');
   for i in 1..a_processed.count loop
      dbms_output.put_line(a_processed(i));
   end loop;
   
   dbms_output.put_line('++++++++++++++++++++++++++++++++++++++++++++++');
   
   dbms_output.put_line('Not processed:');
   for i in 1..a_notprocessed.count loop
      dbms_output.put_line(a_notprocessed(i));
   end loop;
end;
/
