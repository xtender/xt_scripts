@sqlplus_store;

column v_sysdate new_val _SYSDATE noprint; 
select to_char(sysdate,'yyyy-mm-dd') v_sysdate from dual;

accept DT - 
		prompt 'Enter EndDate(format "YYYY-MM-DD", default [&_SYSDATE]): ' -
		default '&_SYSDATE';
accept cnt_days - 
		prompt 'Enter count of days(default [10]): ' -
		default '10';
accept file_name - 
		prompt 'Enter file_name(default [ts_io_stats_&_SYSDATE._&cnt_days..csv]): ' -
		default 'ts_io_stats_&_SYSDATE._&cnt_days..csv';


set term off feed off timing off

var c_result refcursor;

declare
   v_dates_list varchar2(4000);
   v_sql_text   varchar2(32767):= q'[
      with ts_stat as (
                     select trunc(sn.begin_interval_time) dt
                           ,st.ts#
                           ,st.tsname
                           ,sum(st.phyrds)                phyrds
                           ,sum(st.phywrts)               phywrts
                           ,sum(st.singleblkrds)          singleblkrds
                           ,avg(st.readtim)               readtim_avg
                           ,min(st.readtim)               readtim_min
                           ,max(st.readtim)               readtim_max
                           ,avg(st.writetim)              writetim_avg
                           ,min(st.writetim)              writetim_min
                           ,max(st.writetim)              writetim_max
                           ,avg(st.singleblkrdtim)        singleblkrdtim_avg
                           ,min(st.singleblkrdtim)        singleblkrdtim_min
                           ,max(st.singleblkrdtim)        singleblkrdtim_max
                           ,sum(st.phyblkrd)              phyblkrd
                           ,sum(st.phyblkwrt)             phyblkwrt
                           ,sum(st.wait_count)            wait_count
                           ,sum(st.time)                  time_total
                     from 
                        v$database          db
                       ,dba_hist_snapshot   sn
                       ,dba_hist_filestatxs st
                     where 
                           sn.begin_interval_time >= date'&dt'-&cnt_days
                       and sn.begin_interval_time <  date'&dt'
                       and sn.snap_id=st.snap_id
                       and st.dbid=db.dbid
                       and sn.dbid=db.dbid
                     group by 
                              trunc(sn.begin_interval_time)
                              ,st.ts#
                              ,st.tsname
                    )
      ,ts_stat_unpivot as (
         select *
         from ts_stat
         unpivot (
            stat_value
            FOR stat_name 
               IN (
                  phyrds
                 ,phywrts
                 ,singleblkrds
                 ,readtim_avg
                 ,readtim_min
                 ,readtim_max
                 ,writetim_avg
                 ,writetim_min
                 ,writetim_max
                 ,singleblkrdtim_avg
                 ,singleblkrdtim_min
                 ,singleblkrdtim_max
                 ,phyblkrd
                 ,phyblkwrt
                 ,wait_count
                 ,time_total
                 )
         )
      )
      select *
      from ts_stat_unpivot
      pivot (
             max( round(stat_value)  ) val        
         for dt in ( {__DATES_LIST__} )
      )
      order by 1,2,3]';
   -- end of sql_text
   function f_format_date(n int) return varchar2 as
      l_date   date    := date'&dt'-n;
   begin
      return to_char( l_date
                     ,q'[",date'"yyyy-mm-dd"'" "dt_"yyyy_mm_dd]'
                    );
   end;
begin
   for i in 1..&cnt_days loop
      v_dates_list :=  v_dates_list || f_format_date(i);
   end loop;
   v_dates_list := ltrim(v_dates_list,',');
   v_sql_text:=replace(v_sql_text,'{__DATES_LIST__}',v_dates_list);
   dbms_output.put_line(v_sql_text);
   open :c_result for v_sql_text;
end;
/
set numformat 999999999999.9999
set termout off feedback off colsep ";" trimspool on trimout on tab off underline off

spool &_SPOOLS./&file_name;
print c_result;

spool off

host &_START &_SPOOLS./&file_name;
undef file_name;
undef cnt_days;
undef dt;
@sqlplus_restore;