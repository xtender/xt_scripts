declare
    C_SQL_ID          constant varchar2(13)  :='&sqlid';
    C_PROFILE_NAME    constant varchar2(30)  :='PROF_'||C_SQL_ID;
    C_DESCRIPTION     constant varchar2(30)  :='test profile';
    C_FORCE_MATCH     boolean                :=true;
    ar_profile_hints  sys.sqlprof_attr;
    cl_sql_text       clob;
    l_other_xml       xmltype;
    /*
    -- explain plan:
    function get_outlines_from_plan_table(p_statement_id in varchar2)
       return xmltype 
    is res xmltype;
    begin
       select xmltype(other_xml) into res
       from  plan_table pt
       where pt.statement_id = p_statement_id
         and other_xml is not null
         ;
         
       return res;
    exception when no_data_found then raise_application_error(-20000,'NO_DATA_FOUND: PLAN_TABLE');
    end;
    */
    -- AWR:
    function get_outlines_from_plan_table(
                   p_src_sql_id  in varchar2, 
                   p_src_plan_hv in number
       )
       return xmltype
    is res xmltype;
    begin
       select xmltype(other_xml) into res
       from dba_hist_sql_plan p
       where   p.sql_id = p_src_sql_id
           and p.dbid in (select i.dbid from dba_hist_database_instance i)
           and p.plan_hash_value = p_src_plan_hv
           and p.other_xml is not null;
       return res;
    exception when no_data_found then raise_application_error(-20000,'NO_DATA_FOUND: AWR');
    end;
    -- V$SQL_PLAN
    function get_outlines_from_V$SQL_PLAN(
                   p_src_sql_id  in varchar2, 
                   p_src_child   in number
       )
       return xmltype
    is res xmltype;
    begin
       select xmltype(other_xml) into res
       from V$SQL_PLAN p
       where   p.sql_id       = p_src_sql_id
           and p.CHILD_NUMBER = p_src_child
           and p.other_xml is not null;
       return res;
    exception when no_data_found then raise_application_error(-20000,'NO_DATA_FOUND: AWR');
    end;
    
    function split_outline(c clob)  return sys.sqlprof_attr as
       res sys.sqlprof_attr:=sys.sqlprof_attr();
    begin
       for i in 1..regexp_count(c,'[^'||chr(10)||']+') loop
          res.extend;
          res(i):=trim(regexp_substr(c,'[^'||chr(10)||']+',1,i));
       end loop;
       return res;
    end;

begin
   -- 1. Можем заполнить хинты вручную:
   --   ar_profile_hints:=sys.sqlprof_attr('LEADING(P)','USE_CONCAT(@SEL$2)');
      ar_profile_hints:=split_outline(q'[
      IGNORE_OPTIM_EMBEDDED_HINTS
      OPTIMIZER_FEATURES_ENABLE('12.1.0.1')
      DB_VERSION('12.1.0.1')
      ALL_ROWS
      OUTLINE_LEAF(@"SEL$8")
      OUTLINE_LEAF(@"SEL$10")
      OUTLINE_LEAF(@"SET$BEF9A72B")
      OUTLINE_LEAF(@"SEL$3C5B95CF")
      UNNEST(@"SET$2" UNNEST_NOSEMIJ_NODISTINCTVIEW)
      OUTLINE_LEAF(@"SEL$3")
      OUTLINE_LEAF(@"SEL$4")
      OUTLINE_LEAF(@"SEL$9")
      OUTLINE_LEAF(@"SEL$11")
      OUTLINE_LEAF(@"SET$203E6E04")
      OUTLINE_LEAF(@"SEL$77851879")
      OUTLINE_LEAF(@"SEL$370931A2")
      UNNEST(@"SEL$4B0EFDD8" UNNEST_SEMIJ_VIEW)
      OUTLINE_LEAF(@"SET$1")
      OUTLINE_LEAF(@"SEL$F91C5D3E")
      CONNECT_BY_ELIM_DUPS(@"SEL$683B0107")
      OUTLINE_LEAF(@"SEL$5DA710D3")
      UNNEST(@"SEL$2" UNNEST_INNERJ_DISTINCT_VIEW)
      OUTLINE(@"SET$2")
      OUTLINE(@"SEL$6")
      OUTLINE(@"SET$3")
      OUTLINE(@"SEL$4B0EFDD8")
      UNNEST(@"SET$3" UNNEST_NOSEMIJ_NODISTINCTVIEW)
      OUTLINE(@"SEL$5")
      OUTLINE(@"SEL$683B0107")
      OUTLINE(@"SEL$1")
      OUTLINE(@"SEL$2")
      OUTLINE(@"SEL$7")
      NO_ACCESS(@"SEL$5DA710D3" "VW_NSO_4"@"SEL$5DA710D3")
      INDEX(@"SEL$5DA710D3" "A"@"SEL$1" ("TM_PG_ABS"."ID"))
      LEADING(@"SEL$5DA710D3" "VW_NSO_4"@"SEL$5DA710D3" "A"@"SEL$1")
      USE_NL(@"SEL$5DA710D3" "A"@"SEL$1")
      NLJ_BATCHING(@"SEL$5DA710D3" "A"@"SEL$1")
      NO_ACCESS(@"SEL$F91C5D3E" "connect$_by$_work$_set$_019"@"SEL$2")
      USE_HASH_AGGREGATION(@"SEL$F91C5D3E")
      CONNECT_BY_FILTERING(@"SEL$F91C5D3E")
      NO_ACCESS(@"SEL$370931A2" "VW_NSO_3"@"SEL$370931A2")
      INDEX(@"SEL$370931A2" "TM_PG_ABS"@"SEL$5" ("TM_PG_ABS"."ID"))
      LEADING(@"SEL$370931A2" "VW_NSO_3"@"SEL$370931A2" "TM_PG_ABS"@"SEL$5")
      USE_NL(@"SEL$370931A2" "TM_PG_ABS"@"SEL$5")
      NLJ_BATCHING(@"SEL$370931A2" "TM_PG_ABS"@"SEL$5")
      SEMI_TO_INNER(@"SEL$370931A2" "VW_NSO_3"@"SEL$370931A2")
      FULL(@"SEL$4" "connect$_by$_pump$_015"@"SEL$4")
      BITMAP_TREE(@"SEL$4" "TM_PG_ABS"@"SEL$4" OR(1 1 ("TM_PG_ABS"."ID") 2 ("TM_PG_ABS"."ID")))
      BATCH_TABLE_ACCESS_BY_ROWID(@"SEL$4" "TM_PG_ABS"@"SEL$4")
      LEADING(@"SEL$4" "connect$_by$_pump$_015"@"SEL$4" "TM_PG_ABS"@"SEL$4")
      USE_NL(@"SEL$4" "TM_PG_ABS"@"SEL$4")
      FULL(@"SEL$3" "TM_PG_ABS"@"SEL$3")
      INDEX_RS_ASC(@"SEL$3C5B95CF" "A"@"SEL$6" ("TM_PG_ABS"."ID"))
      NO_ACCESS(@"SEL$3C5B95CF" "VW_NSO_1"@"SEL$3C5B95CF")
      LEADING(@"SEL$3C5B95CF" "A"@"SEL$6" "VW_NSO_1"@"SEL$3C5B95CF")
      USE_NL(@"SEL$3C5B95CF" "VW_NSO_1"@"SEL$3C5B95CF")
      INDEX(@"SEL$10" "P"@"SEL$10" "TM_PG_ABS_IDS_COLS_CTX")
      INDEX_RS_ASC(@"SEL$8" "P"@"SEL$8" ("TM_PG_ABS"."ID"))
      NO_ACCESS(@"SEL$77851879" "VW_NSO_2"@"SEL$4B0EFDD8")
      INDEX(@"SEL$77851879" "A"@"SEL$7" ("TM_PG_ABS"."ID"))
      LEADING(@"SEL$77851879" "VW_NSO_2"@"SEL$4B0EFDD8" "A"@"SEL$7")
      USE_NL(@"SEL$77851879" "A"@"SEL$7")
      NLJ_BATCHING(@"SEL$77851879" "A"@"SEL$7")
      USE_HASH_AGGREGATION(@"SEL$77851879")
      INDEX(@"SEL$11" "P"@"SEL$11" "TM_PG_ABS_IDS_COLS_CTX")
      INDEX(@"SEL$9" "P"@"SEL$9" "TM_PG_ABS_TEXT_COLS_CTX")
]');
   -- 2. или берем аутлайны из plan_table
   -- l_other_xml := get_outlines_from_plan_table('&statement_id');
   -- 3. или из v$sql_plan
   -- l_other_xml := get_outlines_from_plan_table('&AWR_SRC_SQL_ID',&AWR_SRC_PLAN_HV);
   -- 4. или из dba_hist_sql_plan:
   -- l_other_xml := get_outlines_from_V$SQL_PLAN('&src_sql_id', &src_child)
/*
   -- получаем хинты запроса:
    select
        d.hint
        bulk collect into ar_profile_hints
    from
        xmltable('/other_xml/outline_data/*'
            passing (l_other_xml)
            columns
            "HINT" varchar2(4000) PATH '/hint'
    ) d;
    */
    -- Получаем текст запроса:
    select 
      coalesce(
          (select a.sql_fulltext from v$sqlarea a        where a.sql_id = C_SQL_ID and rownum = 1 )
         ,(select t.sql_text     from dba_hist_sqltext t where t.sql_id = C_SQL_ID and rownum = 1 and dbid = (select db.DBID from v$database db))
      ) into cl_sql_text
    from dual;
    
    if cl_sql_text is null then
       raise_application_error(-20000,'SQL_TEXT was not found for sql_id='||C_SQL_ID);
    end if;
    
    dbms_sqltune.import_sql_profile(
         sql_text    => cl_sql_text
        ,profile     => ar_profile_hints
        ,name        => C_PROFILE_NAME
        ,description => C_DESCRIPTION
        ,category    => 'DEFAULT'
        ,replace     => true
        ,force_match => C_FORCE_MATCH
    );

    dbms_output.put_line('=========================================');
    dbms_output.put_line('SQL Profile '||C_PROFILE_NAME||' created.');
    dbms_output.put_line('HINTS:');
    for i in ar_profile_hints.first..ar_profile_hints.last loop
       dbms_output.put_line(ar_profile_hints(i));
    end loop;

end;
/
