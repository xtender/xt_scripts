col opt_name format a35
col sql_id   format a13
col child_0    format a20
col child_1    format a20 
col child_2    format a20
col child_3    format a20
col child_4    format a20
col child_5    format a20 
col child_6    format a20
col child_7    format a20 
col child_8    format a20
col child_9    format a20 
col child_10   format a20
col child_11   format a20 
col child_12   format a20
col child_13   format a20
col child_14   format a20
col child_15   format a20 
col child_16   format a20
col child_17   format a20 
col child_18   format a20
col child_19   format a20 
col child_20   format a20

var c refcursor;
def p_sql_id=&1
declare
   v_sql    clob;
   v_childs varchar2(1000);
   v_sqlid  varchar2(13):='&p_sql_id';
begin
   select 
       listagg(s.child_number||' as child_'||child_number,',') within group(order by s.child_number)
     into v_childs
   from v$sql s
   where s.sql_id=v_sqlid;

   v_sql := '
      with x as (
            select 
                sql_id
              , child_number
              , id
              , name  as opt_name
              , value
              , count(distinct value) over(partition by id) cnt
              --, child_address, isdefault, address, hash_value
            from v$sql_optimizer_env
            where sql_id=:sqlid
      )
      select *
      from 
        (select sql_id,child_number,id,opt_name,value from x where cnt>1) e
      pivot (
            max(value)
            for child_number in ('||v_childs||')
      )
      order by id';
   open :c for v_sql using v_sqlid;
end;
/
print c;
col child_0  clear
col child_1  clear
col child_2  clear
col child_3  clear
col child_4  clear
col child_5  clear 
col child_6  clear
col child_7  clear 
col child_8  clear
col child_9  clear 
col child_10 clear
col child_11 clear 
col child_12 clear
col child_13 clear
col child_14 clear
col child_15 clear 
col child_16 clear
col child_17 clear 
col child_18 clear
col child_19 clear 
col child_20 clear
