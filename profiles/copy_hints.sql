prompt &_C_REVERSE *** Copy sql profile to another query ***  &_C_RESET
prompt &_C_RED * Enter % into desc sql_id if you want find by mask" &_C_RESET

accept _src_profile prompt "Enter source profile: ";
accept _dst_sql_id  prompt "Enter dest sql_id   : ";
accept _dst_mask    prompt "Enter sql_text mask : ";
accept _description prompt "Enter description   : ";

set serverout on;
declare
    --------------------
    -- PARAMS:
    l_profile    varchar2(30)    := trim('&_src_profile');
    l_mask       clob            := '&_dst_mask';
    l_manual     int             := 0; -- 1 - true, 0 - false
    l_dest_sqlid varchar2(13)    := trim('&_dst_sql_id');
    l_dest_text  varchar2(32767) := null;
    l_description varchar2(64)   := '&_description';
    --------------------
    ar_profile_hints       sys.sqlprof_attr;
    l_dbid                 number;
    l_instance             number;
    --------------------
    cursor c_new_queries 
       is
          with t as (
               select 
                  a.sql_id
                 ,(select p.name from dba_sql_profiles p
                   where  p.name = 'PROF_'||a.sql_id
                  ) as prof_name
                 ,sql_text
                 ,sql_fulltext
               from gv$sqlarea a
                   ,(select s.sql_id,min(s.INST_ID) min_inst
                     from gv$sql s
                     where (s.sql_id = l_dest_sqlid or (l_dest_sqlid = '%' and s.sql_fulltext like l_mask escape '\'))
                       and s.SQL_PROFILE is null
                     group by s.sql_id
                    ) x
               where a.sql_id      = x.sql_id
                 and a.INST_ID     = x.min_inst
                 and a.sql_profile is null
               union all
               select sql_id
                     ,'' as prof_name
                     ,to_char(substr(sql_text,1,2000)) as sql_text
                     ,sql_text as sql_fulltext
               from dba_hist_sqltext t
               where t.sql_id = l_dest_sqlid
               union all
               select 
                  l_dest_sqlid
                 ,null
                 ,l_dest_text
                 ,to_clob(l_dest_text)
               from dual
               where 1=l_manual
         )
         select sql_id, sql_fulltext
         from t
         where t.prof_name is null
         order by sql_id
         ;
    -- end cursor
    --------------------------
    function get_hints( p_profile varchar2) return sys.sqlprof_attr
    is
       ret_hints sys.sqlprof_attr;
       cursor c_get_hints is
          $IF DBMS_DB_VERSION.ver_le_10 $THEN
                  select attr_val as outline_hint
                  from dba_sql_profiles p
                      ,sys.sqlprof$attr h 
                  where 
                       p.name      = p_profile
                   and p.category  = h.category  
                   and p.signature = h.signature
                  order by    p.name,h.attr#;
          $ELSE
                  select--+ NO_XML_QUERY_REWRITE
                     x.hints as outline_hints 
                  from sys.sqlobj$ p
                      ,sys.sqlobj$data sd
                      ,xmltable('/outline_data/hint' 
                                passing xmltype(sd.comp_data)
                                columns 
                                   n     for ordinality,
                                   hints varchar2(200) path '.'
                               ) x
                  where
                       p.name      = p_profile
                   and p.signature = sd.signature 
                   and p.category  = sd.category
                   and p.obj_type  = sd.obj_type
                  order by    p.name,x.n;
          $END
        -- end cursor
    begin
       open c_get_hints;
       fetch c_get_hints bulk collect into ret_hints;
       close c_get_hints;
       return ret_hints;
    end get_hints;
    --------------------------
    procedure show_hints( p_hints in sys.sqlprof_attr) is
    begin
       dbms_output.put_line('Hints:');
       for i in p_hints.first..p_hints.last loop
         dbms_output.put_line(p_hints(i));
       end loop;
       dbms_output.put_line('----------');
       dbms_output.put_line('----------');
    end show_hints;
begin
    -- vars:
    select instance_number 
          into l_instance
    from v$instance;
    dbms_output.put_line('Instance: #'||l_instance);
    
   -- Get hints from source profile:
    ar_profile_hints:=get_hints(l_profile);
    --    End hints
    if true then show_hints(ar_profile_hints); end if;
    
    ---------------------------------------------
    ---         Main Cycle:
    for r in c_new_queries 
    loop
       dbms_sqltune.import_sql_profile(
            name        => 'PROF_'||R.SQL_ID -- Profile name
           ,sql_text    => R.SQL_FULLTEXT    -- SQL text
           ,profile     => ar_profile_hints  -- our hints
           ,description => l_description
           ,category    => 'DEFAULT'
           ,replace     => true
           ,force_match => true
       );
       dbms_output.put_line('SQL Profile "PROF_'||R.SQL_ID||'" created.');
    end loop;
end;
/
set serverout off;
