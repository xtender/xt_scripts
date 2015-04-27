declare 
   $IF dbms_db_version.ver_le_11_1 $THEN
      v_text       clob;
   $ELSE
      v_text       varchar2(32767);
   $END
   v_sql_id     varchar2(13):='&1';
   v_old_schema varchar2(30):=sys_context('userenv','current_schema');
   v_schema     varchar2(30);
begin
   begin
      select a.SQL_FULLTEXT 
            ,a.PARSING_SCHEMA_NAME
         into v_text, v_schema
      from v$sqlarea a 
      where a.sql_id = v_sql_id 
        and rownum=1;
   exception
      when no_data_found then
         begin
            select t.SQL_TEXT
                  ,(select--+ leading(st.sn st.sql) index_desc(st.sn wrm$_snapshot_pk) index_desc(st.sql wrh$_sqlstat_pk)
                        st.parsing_schema_name 
                    from dba_hist_sqlstat st 
                    where st.instance_number = 1 
                      and st.sql_id  = t.sql_id 
                      and st.dbid    = db.dbid
                      and st.snap_id < 1e38
                      and rownum = 1
                   ) p_schema
               into v_text, v_schema
            from (select dbid from gv$database where rownum=1) db
                ,dba_hist_sqltext t 
            where t.sql_id = v_sql_id 
              and t.dbid   = db.dbid
              and rownum   = 1;
         exception
            when no_data_found then
               select
                  p.sql_text,null
               into v_text, v_schema
               from dba_sql_profiles p
               where upper(p.name) like '%'||upper(v_sql_id)||'%';
         end;
   end;
   
   if v_schema is not null
      then execute immediate 'alter session set current_schema='||v_schema;
   end if;
   v_text:=to_clob('') || 'explain plan for '||v_text;
   begin
      execute immediate v_text;
      if v_schema is not null
         then execute immediate 'alter session set current_schema='||v_old_schema;
      end if;
   exception when others then  
      if v_schema is not null
         then execute immediate 'alter session set current_schema='||v_old_schema;
      end if;
      raise;
   end;
end;
/
@xplan "+note"
