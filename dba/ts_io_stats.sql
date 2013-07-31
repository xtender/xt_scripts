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
		prompt 'Enter file_name(default [ts_io_stats_&_SYSDATE._&cnt_days..html]): ' -
		default 'ts_io_stats_&_SYSDATE._&cnt_days..html';


set term off feed off timing off

var c_result refcursor;

declare
   v_dates_list varchar2(4000);
   v_sql_text   varchar2(32767):= q'[
      with 
       ts_normalized as (
                     select trunc(sn.begin_interval_time) dt
                           ,st.snap_id
                           ,st.ts#
                           ,st.tsname
                           ,sum(st.phyrds)                phyrds
                           ,sum(st.phywrts)               phywrts
                           ,sum(st.singleblkrds)          singleblkrds
                           ,sum(st.readtim)               readtim
                           ,sum(st.writetim)              writetim
                           ,sum(st.singleblkrdtim)        singleblkrdtim
                           ,sum(st.phyblkrd)              phyblkrd
                           ,sum(st.phyblkwrt)             phyblkwrt
                           ,sum(st.wait_count)            wait_count
                           ,sum(st.time)                  time_total
                     from 
                        v$database          db
                       ,dba_hist_snapshot   sn
                       ,dba_hist_filestatxs st
                     where 
                           sn.begin_interval_time >= date'&dt'-&cnt_days-1/24
                       and sn.begin_interval_time <  date'&dt'
                       and sn.snap_id=st.snap_id
                       and st.dbid=db.dbid
                       and sn.dbid=db.dbid
                     group by 
                              trunc(sn.begin_interval_time)
                              ,st.snap_id
                              ,st.ts#
                              ,st.tsname
       )
      ,ts_delta as (
                     select d.dt
                           ,d.ts#
                           ,d.tsname
                           ,d.phyrds              - lag(d.phyrds)         over(partition by d.ts#,d.tsname order by d.snap_id) phyrds
                           ,d.phywrts             - lag(d.phywrts)        over(partition by d.ts#,d.tsname order by d.snap_id) phywrts
                           ,d.singleblkrds        - lag(d.singleblkrds)   over(partition by d.ts#,d.tsname order by d.snap_id) singleblkrds
                           ,d.readtim             - lag(d.readtim)        over(partition by d.ts#,d.tsname order by d.snap_id) readtim
                           ,d.writetim            - lag(d.writetim)       over(partition by d.ts#,d.tsname order by d.snap_id) writetim
                           ,d.singleblkrdtim      - lag(d.singleblkrdtim) over(partition by d.ts#,d.tsname order by d.snap_id) singleblkrdtim
                           ,d.phyblkrd            - lag(d.phyblkrd)       over(partition by d.ts#,d.tsname order by d.snap_id) phyblkrd
                           ,d.phyblkwrt           - lag(d.phyblkwrt)      over(partition by d.ts#,d.tsname order by d.snap_id) phyblkwrt
                           ,d.wait_count          - lag(d.wait_count)     over(partition by d.ts#,d.tsname order by d.snap_id) wait_count
                           ,d.time_total          - lag(d.time_total)     over(partition by d.ts#,d.tsname order by d.snap_id) time_total
                     from 
                        ts_normalized d
                     where 
                           d.dt >= date'&dt'-&cnt_days
      )
      ,ts_stat as (
                     select 
                            dt
                           ,ts#
                           ,tsname
                           ,sum(phyrds)                phyrds
                           ,sum(phywrts)               phywrts
                           ,sum(singleblkrds)          singleblkrds
                           ,sum(readtim)               readtim
                           ,sum(writetim)              writetim
                           ,sum(singleblkrdtim)        singleblkrdtim

                           ,sum(readtim)/sum(phyrds)   readtim_p_read
                           ,sum(writetim)/sum(phywrts) writetim_p_write

                           ,sum(singleblkrdtim)
                               /sum(singleblkrds)      singleblkrdtim_per_block
                           
                           ,sum(phyblkrd)              phyblkrd
                           ,sum(phyblkwrt)             phyblkwrt
                           ,sum(wait_count)            wait_count
                           ,sum(time_total)            time_total
                    from ts_delta
                    group by 
                           dt
                          ,ts#
                          ,tsname
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
                 ,readtim
                 ,writetim
                 ,singleblkrdtim

                 ,readtim_p_read
                 ,writetim_p_write
                 ,singleblkrdtim_per_block
                 
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
             max( round(stat_value,3)  ) val        
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
   for i in reverse 1..&cnt_days loop
      v_dates_list :=  v_dates_list || f_format_date(i);
   end loop;
   v_dates_list := ltrim(v_dates_list,',');
   v_sql_text:=replace(v_sql_text,'{__DATES_LIST__}',v_dates_list);
   dbms_output.put_line(v_sql_text);
   open :c_result for v_sql_text;
end;
/
alter session set NLS_NUMERIC_CHARACTERS='. ';
set numformat FM999g999g999g999d999

set markup HTML ON HEAD "                                                       -
<style type='text/css'>                                                         -
   body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;}  -
   p {   font:10pt Arial,Helvetica,sans-serif; color:black; background:White;}  -
                                                                                -
   table,tr,td {                                                                -
         font:10pt Arial,Helvetica,sans-serif; color:Black; background:white;   -
         border-color: #a9c6c9;                                                 -
         padding:0px 0px 0px 0px; margin:0px 0px 0px 0px; white-space:nowrap;   -
   }                                                                            -
   th {  font:bold 10pt Arial,Helvetica,sans-serif;                             -
         color:#336699; background:#d4e3e5;                                     -
         padding:0px 0px 0px 0px;                                               -
   }                                                                            -
   h1 {  font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699;            -
         background-color:White;                                                -
         border-bottom:1px solid #cccc99;                                       -
         margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;            -
   }                                                                            -
   h2 {  font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699;       -
         background-color:White;                                                -
         margin-top:4pt; margin-bottom:0pt;                                     -
   }                                                                            -
   a  {  font:9pt Arial,Helvetica,sans-serif; color:#663300;                    -
         background:#ffffff;                                                    -
         margin-top:0pt; margin-bottom:0pt; vertical-align:top;                 -
   }                                                                            -
</style>                                                                        -
<title>IO stats by tablespaces report for &cnt_days day till &dt</title>      " -
BODY "" -
TABLE "border='1' align='center' summary='Script output'" -
SPOOL ON ENTMAP ON PREFORMAT OFF;

spool &_SPOOLS./&file_name;
print c_result;

spool off
set markup html off spool off

host &_START &_SPOOLS./&file_name;
undef file_name;
undef cnt_days;
undef dt;
@sqlplus_restore;