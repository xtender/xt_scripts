declare
   isclean        boolean :=false;
   max_iterations int:=10;
   sleep_interval int:=3;
begin
   while max_iterations>0 and not isclean
   loop
      isclean := sys.DBMS_REPAIR.ONLINE_INDEX_CLEAN(sys.dbms_repair.all_index_id,sys.dbms_repair.lock_wait);
      if isclean then
         dbms_output.put_line( max_iterations||': '|| 'Cleanup successfully completed');
      else
         dbms_output.put_line( max_iterations||': '|| 'Cleanup was not completed...');
         max_iterations := max_iterations - 1;
         sys.dbms_lock.sleep(sleep_interval);
      end if;
   end loop;
end;
/
