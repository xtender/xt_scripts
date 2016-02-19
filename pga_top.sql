col NAME for a23;
select sn.name
      ,sum(st.value) Total
from 
     v$sesstat st
    ,v$statname sn
where st.STATISTIC# = sn.STATISTIC#
  and lower(sn.name) like 'sess%mem%'
group by sn.name
order by sn.name
/
col RNK        for 999;
col NAME       for a18;
col SIZE       for 99999999.9 justify right;
col wait_class for a12;
col event      for a25 trunc;
col program    for a12 trunc;
col module     for a12 trunc;
col stext      for a100 trunc;

break on name skip 1;

select 
  stt.name
 ,stt.value as bytes
 ,case 
    when stt.value>1024*1024*1024 then round(stt.value/(1024*1024*1024),1)
    when stt.value>     1024*1024 then round(stt.value/(     1024*1024),1)
    when stt.value>          1024 then round(stt.value/(          1024),1)
    else stt.value
  end as "SIZE"
 ,case 
    when stt.value>1024*1024*1024 then 'GB'
    when stt.value>     1024*1024 then 'MB'
    when stt.value>          1024 then 'KB'
    else                               'B'
  end units
 ,stt.rnk
 ,s.sid
 ,s.serial#
 ,s.username
 ,decode(s.state,'WAITING', s.wait_class ,'ON CPU')                       as wait_class
 ,decode(s.state,'WAITING', s.event      ,'ON CPU')                       as event
 ,s.sql_id
 ,s.program
 ,s.module
 ,substr((select substr(sql_text,1,100) from v$sqlarea a where a.sql_id = s.sql_id),1,100) as stext
from (
      select st.SID
            ,sn.name
            ,st.value
            ,row_number()over(partition by sn.name order by st.value desc) rnk
      from 
           v$sesstat st
          ,v$statname sn
      where st.STATISTIC# = sn.STATISTIC#
        and lower(sn.name) like 'sess%memory'
     ) stt
    ,v$session s
where stt.rnk<=10
and stt.sid = s.sid
/
col NAME clear;
col SIZE clear;
col wait_class clear;
col event      clear;
col program    clear;
col module     clear;
col stext      clear;
clear break;
