-------------------------------------------------------------------------------------------
-- SCRIPT:  DF.SQL
-- PURPOSE: Show Oracle tablespace free space in Unix df style
-- AUTHOR:  Tanel Poder [ http://www.tanelpoder.com ]
-- DATE:    2003-05-01
-------------------------------------------------------------------------------------------
@inc/input_vars_init;
col "Tablespace"for a30
col "Used(%)"   for a8
col "Free(%)"   for a8
col "Used"      for a52

select
    rpad(t.tablespace_name,30,'..')                                         as "Tablespace"
   ,t.type
   ,t.mb                                                                    as "TotalMB"
   ,t.mb - nvl(f.mb, 0)                                                     as "UsedMB"
   ,nvl(f.mb, 0)                                                            as "FreeMB"
   ,to_char((1 - nvl(f.mb, 0) / decode(t.mb, 0, 1, t.mb))*100,'990.0')||'%' as "Used(%)"
   ,to_char(nvl(f.mb, 0)*100 / decode(t.mb, 0, 1, t.mb),'990.0')||'%'       as "Free(%)"
   ,t.ext                                                                   as "Ext"
   ,'|' || rpad(lpad('#'
                     ,ceil((1 - nvl(f.mb, 0) / decode(t.mb, 0, 1, t.mb)) * 50)
                     ,'#')
                ,50
                ,' ') || '|'                                             as "Used"
from   (select tablespace_name, trunc(sum(bytes) / 1048576) MB
        from   dba_free_space
        group  by tablespace_name
        union all
        select tablespace_name, trunc(sum(bytes_free) / 1048576) MB
        from   v$temp_space_header
        group  by tablespace_name) f
      ,(select tablespace_name
              ,'normal' type  
              ,trunc(sum(bytes) / 1048576) MB
              ,max(autoextensible) ext
        from   dba_data_files
        group  by tablespace_name
        union all
        select tablespace_name
              ,'temp' type  
              ,trunc(sum(bytes) / 1048576) MB
              ,max(autoextensible) ext
        from   dba_temp_files
        group  by tablespace_name) t
where  t.tablespace_name = f.tablespace_name(+)
  and t.tablespace_name like nvl(upper('&1'),'%')
order  by t.tablespace_name;

@inc/input_vars_undef;