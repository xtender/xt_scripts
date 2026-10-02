create or replace function split_interval_by_days(beg_date date, end_date date)
  return varchar2 sql_macro
is
begin
  return q'{
     select/*+ no_decorrelate */
        case 
          when n = 1 
             then beg_date 
          else trunc(beg_date)+n-1
        end as sub_beg_date
       ,case
          when n<=trunc(end_date)-trunc(beg_date)
            then trunc(beg_date)+n -1/24/60/60
          else end_date
        end as sub_end_date
     from (select/*+ no_merge */ level n
           from dual
           connect by level<=trunc(end_date)-trunc(beg_date)+1
          )
  }';
end;
/
