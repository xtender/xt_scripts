set termout off;
alter session set nls_territory=RUSSIA;
alter session set nls_language=RUSSIAN;
set termout on;
col s format a200
with t as (select trunc(sysdate,'yyyy') d from dual)
   ,t0 as (select d ,rpad(max(sys_connect_by_path(to_char(level,'fm00'),'--')),42*4) s
                    ,substr(max(sys_connect_by_path(lpad(
                       to_char(trunc(d,'d')+level-1,'Dy'),3),'-')),1,28) b
             from t connect by level <= 31)
   ,t1 as (select level-1 n
                 ,add_months(d,3*floor((level-1)/9)+0) d1
                 ,add_months(d,3*floor((level-1)/9)+1) d2
                 ,add_months(d,3*floor((level-1)/9)+2) d3
                 ,s ,b
            from t0 connect by level <= 4*9+1
            )
   ,t2 as (select n ,b ,d1 ,d2 ,d3
                 ,rpad(rpad('-',(to_char(d1,'d')-1)*4,'--')
                     ||substr(s,1,2+instr(s,extract(day from last_day(d1)))),42*4) s1
                 ,rpad(rpad('-',(to_char(d2,'d')-1)*4,'--')
                     ||substr(s,1,2+instr(s,extract(day from last_day(d2)))),42*4) s2
                 ,rpad(rpad('-',(to_char(d3,'d')-1)*4,'--')
                     ||substr(s,1,2+instr(s,extract(day from last_day(d3)))),42*4) s3
             from t1)
   ,t3 as (select case
        when n=0
          then lpad(extract(year from d1),48)
        when mod(n,9) = 1
          then '*'||lpad(to_char(d1,'fm[Month]')||'--*',30,'-')
             ||'*'||lpad(to_char(d2,'fm[Month]')||'--*',30,'-')
             ||'*'||lpad(to_char(d3,'fm[Month]')||'--*',30,'-')
        when mod(n,9) = 2
          then replace(replace('|- ||- ||- |','-',b),'-',' ')
        when mod(n,9) = 0
          then replace('*-**-**-*','-',rpad('-',29,'-'))
        else replace(replace('|'
           ||substr(s1,1+28*(mod(n,9)-3),28)||' ||'
           ||substr(s2,1+28*(mod(n,9)-3),28)||' ||'
           ||substr(s3,1+28*(mod(n,9)-3),28)||' |'
           ,'-0','--'),'-',' ')
        end s,n
     from t2
   )
   ,t4 as (select level nn from dual connect by level<=45)
   ,t31 as (select n+1+2*floor((n-1)/9) n, substr(s, 1,31) s1 from t3)
   ,t32 as (select n+2+2*floor((n-1)/9) n, substr(s,32,31) s2 from t3)
   ,t33 as (select n+3+2*floor((n-1)/9) n, substr(s,63)    s3 from t3)
   select case nn when 1 then (select s from t3 where n=0)
                 else nvl(s1,lpad(' ',31))||nvl(s2,lpad(' ',31))||s3 end s
     from t4 ,t31 ,t32 ,t33
    where t31.n (+) = nn
      and t32.n (+) = nn
      and t33.n (+) = nn
order by nn;
set termout off;
alter session set nls_language=AMERICAN;
alter session set nls_numeric_characters  =q'[.`]';
alter session set nls_date_format         ='yyyy-mm-dd hh24:mi:ss';
alter session set nls_time_format         ='hh24:mi:ssxff';
alter session set nls_time_tz_format      ='hh24:mi:ssxff TZR';
alter session set nls_timestamp_format    ='yyyy-mm-dd hh24:mi:ssxff';
alter session set nls_timestamp_tz_format ='yyyy-mm-dd hh24:mi:ssxff TZR';
set termout on;