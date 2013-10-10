accept tab  prompt 'Table name : ';
accept col  prompt 'Column name: ';
accept topn default 254 prompt 'Top count[254]: '
select  
   t.*
  ,sum(cnt)over(order by cnt desc)/overall pct
from (
     select &col
           ,count(*) cnt
           ,sum(count(*))over() overall
     from &tab
     group by &col
     order by cnt desc
     ) t
where rownum<=&topn
order by &col
/
undef tab col cnt