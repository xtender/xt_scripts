clear scr;
set serverout on;
alter session set db_file_multiblock_read_count=256;
alter session set sort_area_size=100000000;
alter session set hash_area_size=100000000;

begin
   dbms_stats.set_global_prefs( 'CASCADE'           , 'TRUE');
   dbms_stats.set_global_prefs( 'DEGREE'            , '1');
   dbms_stats.set_global_prefs( 'ESTIMATE_PERCENT'  , '5'); --'DBMS_STATS.AUTO_SAMPLE_SIZE'
   dbms_stats.set_global_prefs( 'METHOD_OPT'        , 'FOR ALL INDEXED COLUMNS SIZE SKEWONLY');
   dbms_stats.set_global_prefs( 'NO_INVALIDATE'     , 'DBMS_STATS.AUTO_INVALIDATE');
   dbms_stats.set_global_prefs( 'GRANULARITY'       , 'AUTO');
   -- 11 only: 'PUBLISH','INCREMENTAL','STALE_PERCENT'
   dbms_stats.set_global_prefs( 'PUBLISH'           , 'FALSE');
   dbms_stats.set_global_prefs( 'INCREMENTAL'       , 'FALSE');
   dbms_stats.set_global_prefs( 'STALE_PERCENT'     , '10');
   dbms_output.put_line('Global prefs was setted.');
end;
/
declare
   m_object_list   dbms_stats.objecttab;
begin
   DBMS_STATS.GATHER_DATABASE_STATS(
      gather_sys   => false
     ,gather_temp  => false
     ,gather_fixed => false
     ,options      => 'gather stale'
     ,objlist      => m_object_list
   );
   
   for i in 1..m_object_list.count loop
        dbms_output.put_line(
            rpad(m_object_list(i).ownname,30)     ||' | '||
            rpad(m_object_list(i).objtype, 6)     ||' | '||
            rpad(m_object_list(i).objname,32)     ||' | '||
            rpad(m_object_list(i).partname,30)    ||' | '||
            rpad(m_object_list(i).subpartname,30) ||' | '
        );
   end loop;
end;
/
