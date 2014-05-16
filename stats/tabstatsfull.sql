set echo off termout on tab off trimout on trimspool on lines 1500 pagesize 999 feed off timing off def on ver off serverout off;

define tab_owner="&1"
define tab_name="&2"

-------- TPT: verinfo
col _IF_ORA9              noprint new_value _IF_ORA9
col _IF_ORA10_OR_HIGHER   noprint new_value _IF_ORA10_OR_HIGHER
col _IF_ORA11_OR_HIGHER   noprint new_value _IF_ORA11_OR_HIGHER
col _IF_ORA112_OR_HIGHER  noprint new_value _IF_ORA112_OR_HIGHER
col _IF_ORA12_OR_HIGHER   noprint new_value _IF_ORA12_OR_HIGHER
col _IF_LOWER_THAN_ORA11  noprint new_value _IF_LOWER_THAN_ORA11

select
    case when ver like '09%' then '  ' else '--' end "_IF_ORA9",
    case when ver >= '1'     then '  ' else '--' end "_IF_ORA10_OR_HIGHER",
    case when ver >= '11'    then '  ' else '--' end "_IF_ORA11_OR_HIGHER",
    case when ver >= '11.2'  then '  ' else '--' end "_IF_ORA112_OR_HIGHER",
    case when ver >= '12'    then '  ' else '--' end "_IF_ORA12_OR_HIGHER",
    case when ver <  '11'    then '  ' else '--' end "_IF_LOWER_THAN_ORA11"
from(
     select substr(banner, instr(banner, 'Release ')+8,4) ver
     from (select replace(banner,'9','09') banner from v$version where rownum = 1)
    );

----------------------------
prompt Stats for "&tab_owner"."&tab_name";
prompt;
--------------- describe -----------------
set lines 150
desc "&tab_owner"."&tab_name";
set lines 1500;
col owner             for a15;
col table_name        for a30;
col partition_name    for a25;
col subpartition_name for a30;
col index_name        for a30;
col st_lock           for a7;
col part#             for 999;
col subpart#          for 999;
prompt ------------- tab stats -------------------;
select
    t.owner
   ,t.table_name
   ,t.partition_name
   ,t.partition_position    as part#
   ,t.subpartition_name
   ,t.subpartition_position as subpart#
   ,t.stattype_locked       as st_lock
   ,t.stale_stats
   ,t.global_stats
   ,t.user_stats
   ,t.NUM_ROWS
   ,t.BLOCKS
   ,t.EMPTY_BLOCKS
   ,t.AVG_ROW_LEN
   ,t.AVG_SPACE
   ,t.LAST_ANALYZED 
from all_tab_statistics t 
where  
      t.owner      = '&tab_owner'
  and t.table_name = '&tab_name'
order by t.owner,t.table_name,t.partition_position nulls first,t.subpartition_position nulls first;
prompt;
-------------- segs -------------------
col segment_name      for a30;
col partition_name    for a30;
col segment_type      for a20;
col segment_subtype   for a10;
select 
    segment_name
   ,partition_name
   ,segment_type
   ,segment_subtype
   ,round(bytes/1024/1024,1) mbytes
   ,blocks 
from dba_segments s
where s.owner='&tab_owner' and segment_name='&tab_name'
order by 1,2;
prompt;

prompt ------------ ind stats ------------------;
col owner           format a12
col table_owner     noprint
col table_name      noprint
col index_name      format a30
col partition_name  format a20
col column_name     format a30
col "#"             format 99
col BLEVEL          format 999
col VISIBLE         format a3
col UNIQ            format a4
col SEG_BLOCKS      heading "Sum blocks"
col SEG_SIZE        heading "Size(Mb)"
col PARTITIONED     format a4 heading "Part"
break  on owner skip 3 on table_name on index_name on VISIBLE on UNIQ on BLEVEL on NUM_ROWS on SEG_BLOCKS on SEG_SIZE -
       on LEAF_BLOCKS on DISTINCT_KEYS on CL_FACTOR on LAST_ANALYZED on PARTITIONED on created on last_ddl_time skip 1;

with i as (
        SELECT
                ix.*
              ,(select sum(bytes) from dba_segments s where s.owner=ix.owner and s.segment_name=ix.index_name) seg_size 
              ,o.last_ddl_time
              ,o.created
        FROM    
                all_indexes ix
               ,all_objects o
        WHERE  1=1
        --
        and ix.table_owner = '&tab_owner'
        and ix.table_name  = '&tab_name'
        and o.owner        = ix.owner 
        and o.object_name  = ix.index_name
        and o.SUBOBJECT_NAME is null
)
select--+ leading(i ic o) use_nl(i ic o)
         i.owner
        ,i.table_name
        ,i.index_name
&_IF_ORA11_OR_HIGHER        ,decode(i.VISIBILITY,'INVISIBLE'  ,'N','Y') as VISIBLE
        ,decode(i.UNIQUENESS,'NONUNIQUE','N','Y')  as UNIQ
        ,i.BLEVEL
        ,i.NUM_ROWS
        ,round(i.seg_size/1024/1024,1) seg_size
        ,i.LEAF_BLOCKS
        ,i.DISTINCT_KEYS
        ,i.CLUSTERING_FACTOR as CL_FACTOR
        ,i.LAST_ANALYZED
        ,i.PARTITIONED
        ,i.created
        ,i.last_ddl_time
        ,ic.column_position "#"
        ,decode(ic.column_position,1,'','  ,')||ic.column_name column_name
from i
    ,all_ind_columns ic 
where
     ic.index_owner = i.owner
 and ic.index_name  = i.index_name
order by
         owner,table_name,seg_size desc, DISTINCT_KEYS, index_name,"#"
/
clear break;
clear col;
prompt;


prompt ------------- col statistics -----------------;
set serverout on;

declare
   
   l_column_name    constant number := 30;
   l_data_type      constant number := 15;
   l_num_distinct   constant number := 12;
   l_low_value      constant number := 30;
   l_high_value     constant number := 30;
   --l_density        constant number := 10;
   l_num_nulls      constant number := 10;
   l_num_buckets    constant number := 10;
   l_last_analyzed  constant number := 20;
   l_sample_size    constant number := 11;
   l_global_stats   constant number := 5 ;
   l_user_stats     constant number := 5 ;
   l_avg_col_len    constant number := 5 ;
   l_histogram      constant number := 20;
   
   full_len         constant number := 27
                                       + l_column_name + l_data_type
                                       + l_num_distinct + l_low_value + l_high_value 
                                       -- + l_density
                                       + l_num_nulls + l_num_buckets + l_last_analyzed + l_sample_size 
                                       + l_global_stats + l_user_stats + l_avg_col_len + l_histogram
                                       ;
   function raw_to_num(i_raw raw)
   return varchar2
   as
      m_n number;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   exception when others then return 'ERROR:'||sqlerrm;
   end;
     
   function raw_to_date(i_raw raw)
   return date
   as
      m_n date;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
     
   function raw_to_varchar2(i_raw raw)
   return varchar2
   as
      m_n varchar2(4000);
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
   
   function val_to_output(p_datatype varchar2,p_value raw) 
   return varchar2
   is
     res varchar2(4000);
   begin
      res := case 
           when p_datatype in ('CHAR','VARCHAR2')                       then raw_to_varchar2(p_value)
           when p_datatype = 'DATE' or p_datatype like 'TIMESTAMP%'     then to_char(raw_to_date(p_value),'yyyy-mm-dd hh24:mi:ss')
           when p_datatype = 'NUMBER'                                   then raw_to_num(p_value)
           when p_datatype = 'FLOAT'                                    then raw_to_num(p_value)
           else 'tp='||p_datatype
        end;
      return nvl(res,'NULL');
   end;

   function xrpad(str1 in varchar2,len int,pad varchar2)
   return varchar2
   is
      str2 varchar2(32676):=nvl(replace(str1,chr(10),' '),' ');
   begin
      --str2:=regexp_replace(str2,'[[:cntrl:]]','~');
      if regexp_like(str2,'[[:cntrl:]]') then 
         select 'DUMP:'||dump(str2,17) into str2 from dual;
      end if;
      return rpad(str2,len,pad);
   end;
begin
   dbms_output.put_line( rpad('-',full_len,'-'));
   dbms_output.put_line( '| '
      ||rpad('column_name'                                 ,l_column_name   ,' ') ||'| '
      ||rpad('datatype'                                    ,l_data_type     ,' ') ||'| '
      ||rpad('num_distinct'                                ,l_num_distinct  ,' ') ||'| '
      ||rpad('low_value'                                   ,l_low_value     ,' ') ||'| '
      ||rpad('high_value'                                  ,l_high_value    ,' ') ||'| '
      --||rpad('density'                                     ,l_density       ,' ') ||'| '
      ||rpad('num_nulls'                                   ,l_num_nulls     ,' ') ||'| '
      ||rpad('num_buckets'                                 ,l_num_buckets   ,' ') ||'| '
      ||rpad('last_analyzed'                               ,l_last_analyzed ,' ') ||'| '
      ||rpad('sample_size'                                 ,l_sample_size   ,' ') ||'| '
      ||rpad('global_stats'                                ,l_global_stats  ,' ') ||'| '
      ||rpad('user_stats'                                  ,l_user_stats    ,' ') ||'| '
      ||rpad('avg_col_len'                                 ,l_avg_col_len   ,' ') ||'| '
      ||rpad('histogram'                                   ,l_histogram     ,' ') ||'| '
      );
   dbms_output.put_line( rpad('-',full_len,'-'));
   
   for r in (
         select 
             tc.column_name
            ,tc.data_type
            ,cs.num_distinct
            ,cs.low_value
            ,cs.high_value
            ,cs.density
            ,cs.num_nulls
            ,cs.num_buckets
            ,cs.last_analyzed
            ,cs.sample_size
            ,cs.global_stats
            ,cs.user_stats
            ,cs.avg_col_len
            ,cs.HISTOGRAM
         from dba_tab_col_statistics cs 
             ,dba_tab_columns tc
         where 
                tc.owner       = '&tab_owner'
            and tc.table_name  = '&tab_name'
            and tc.OWNER       = cs.owner(+)
            and tc.TABLE_NAME  = cs.table_name(+)
            and tc.COLUMN_NAME = cs.column_name(+)
         order by tc.COLUMN_ID
   )
   loop
      dbms_output.put_line( '| '
         ||xrpad(r.column_name                                 ,l_column_name   ,' ') ||'| '
         ||xrpad(r.data_type                                   ,l_data_type     ,' ') ||'| '
         ||xrpad(r.num_distinct                                ,l_num_distinct  ,' ') ||'| '
         ||xrpad(val_to_output(r.data_type,r.low_value)        ,l_low_value     ,' ') ||'| '
         ||xrpad(val_to_output(r.data_type,r.high_value)       ,l_high_value    ,' ') ||'| '
         --||xrpad(r.density                                     ,l_density       ,' ') ||'| '
         ||xrpad(r.num_nulls                                   ,l_num_nulls     ,' ') ||'| '
         ||xrpad(r.num_buckets                                 ,l_num_buckets   ,' ') ||'| '
         ||xrpad(to_char(r.last_analyzed,'yyyy-mm-dd hh24:mi') ,l_last_analyzed ,' ') ||'| '
         ||xrpad(r.sample_size                                 ,l_sample_size   ,' ') ||'| '
         ||xrpad(r.global_stats                                ,l_global_stats  ,' ') ||'| '
         ||xrpad(r.user_stats                                  ,l_user_stats    ,' ') ||'| '
         ||xrpad(r.avg_col_len                                 ,l_avg_col_len   ,' ') ||'| '
         ||xrpad(r.histogram                                   ,l_histogram     ,' ') ||'| '
         );
    end loop;
   dbms_output.put_line( rpad('-',full_len,'-'));
end;
/
exit;
