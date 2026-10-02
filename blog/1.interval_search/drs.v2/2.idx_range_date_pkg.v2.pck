CREATE OR REPLACE PACKAGE idx_range_date_pkg AS
  
  function get_index_tab_name(ia sys.ODCIIndexInfo) return varchar2 deterministic;
  function get_beg_date(virt varchar2) return date deterministic;
  function get_end_date(virt varchar2) return date deterministic;
  procedure p_debug(str varchar2);
  
  procedure ODCIIndexCreate_pr(
        ia    sys.ODCIIndexInfo,
        parms VARCHAR2,
        env   sys.ODCIEnv
    );
    
  procedure ODCIIndexDrop_pr(
        ia  sys.ODCIIndexInfo,
        env sys.ODCIEnv
    );
  procedure ODCIIndexStart_Pr(
        sctx   IN OUT idx_range_date_type,
        ia     sys.ODCIIndexInfo,
        op     sys.ODCIPredInfo,
        qi     sys.ODCIQueryInfo,
        strt   NUMBER,
        stop   NUMBER,
        cmpval DATE,
        env    sys.ODCIEnv,
        res    out varchar2
    );
  procedure ODCIIndexFetch_pr(
        nrows NUMBER,
        rids  OUT sys.ODCIRidList,
        env   sys.ODCIEnv,
        cur   IN OUT sys_refcursor
    );
  procedure ODCIIndexInsert_pr(
        ia       sys.ODCIIndexInfo,
        rid      VARCHAR2,
        newval   VARCHAR2,
        env      sys.ODCIEnv
    );
  procedure ODCIIndexDelete_pr(
        ia      sys.ODCIIndexInfo,
        rid     VARCHAR2,
        oldval  VARCHAR2,
        env     sys.ODCIEnv
    );
END;
/
CREATE OR REPLACE PACKAGE BODY idx_range_date_pkg AS
  
  function get_index_tab_name(ia sys.ODCIIndexInfo) return varchar2 deterministic is
  begin
    return '"'||ia.IndexSchema || '"."' || ia.IndexName ||'_DRS1_TAB"';
  end;
  
  function get_index_tab_name_only(ia sys.ODCIIndexInfo) return varchar2 deterministic is
  begin
    return ia.IndexName ||'_DRS1_TAB';
  end;
  
  function get_index_tab_index(ia sys.ODCIIndexInfo) return varchar2 deterministic is
  begin
    return '"'||ia.IndexSchema || '"."' || ia.IndexName ||'_DRS1_IND"';
  end;
  
  function get_index_tab_index2(ia sys.ODCIIndexInfo) return varchar2 deterministic is
  begin
    return '"'||ia.IndexSchema || '"."' || ia.IndexName ||'_DRS1_RID"';
  end;
  
  procedure p_debug(str varchar2) is
  begin
    --to enable debug:
    --ALTER SESSION SET PLSQL_CCFLAGS = 'DRS_DEBUG:FALSE' 
    $IF $$DRS_DEBUG $THEN 
      dbms_output.put_line(str);
    $ELSE
      null;
    $END
  end;

  procedure p_exec(stmt varchar2) is
  begin
    if true then
      p_debug('Exec: '||stmt);
      execute immediate stmt;
    else
      p_debug('Exec: '||stmt);
    end if;
  end;
  
  function get_beg_date(virt varchar2) return date deterministic 
    is
  begin
    return to_date(substr(virt, 1,19),'YYYY-MM-DD HH24:MI:SS');
  end;
  
  function get_end_date(virt varchar2) return date deterministic 
    is
  begin
    return to_date(substr(virt,21,19),'YYYY-MM-DD HH24:MI:SS');
  end;
  
  procedure ODCIIndexCreate_pr(
        ia    sys.ODCIIndexInfo,
        parms VARCHAR2,
        env   sys.ODCIEnv
    )
  is
      stmt1 VARCHAR2(1000);
      stmt2 VARCHAR2(1000);
      stmt3 VARCHAR2(1000);
  BEGIN
    p_debug('indexschema   :'||ia.indexschema   );
    p_debug('indexname     :'||ia.indexname     );
    p_debug('indexpartition:'||ia.indexpartition);

    p_debug('indexcols     :');
    for i in 1..ia.indexcols.count loop
      p_debug(i||': '||ia.indexcols(i).ColName ||' '|| ia.indexcols(i).ColTypeName);
    end loop;

  
    p_debug('Parms: '||parms);
    p_debug('env.DEBUGLEVEL: '||env.DEBUGLEVEL);
    p_debug('env.CURSORNUM: '||env.CURSORNUM);
    
        -- Create auxiliary table for the index
        -- Construct the SQL statement.
        stmt1 := 'CREATE TABLE ' || get_index_tab_name(ia)
        ||q'[
        (
           beg_date date
          ,end_date date
          ,rid rowid
          ,DURATION_MINUTES number as ((end_date-beg_date)*24*60)
        )
        partition by range(DURATION_MINUTES)
        (
            partition part_15_min   values less than (15)
           ,partition part_1_hour   values less than (60)
           ,partition part_1_day    values less than (1440)  --40*24*60
        )
        ]';

        -- Dump the SQL statement.
        $IF $$DRS_DEBUG $THEN
          p_debug('ODCIIndexCreate>>>>>');
          sys.ODCIIndexInfoDump(ia);
          p_debug('ODCIIndexCreate>>>>>'||stmt1);
        $END
        p_exec(stmt1);
        
        -- Now populate the table.
        stmt2 := q'[INSERT INTO {index_tab_name} ( beg_date, end_date, rid )
            SELECT SUB_BEG_DATE as beg_date 
                  ,SUB_END_DATE as end_date 
                  ,P.rowid
            FROM "{owner}"."{tab_name}" P
            outer apply(
              select /*+ no_merge */ *
              from split_interval_by_days(
                to_date(substr(P.{col_name}, 1,19),'YYYY-MM-DD HH24:MI:SS')
               ,to_date(substr(P.{col_name},21,19),'YYYY-MM-DD HH24:MI:SS')
               )
              )
            ]';
        stmt2 := replace(stmt2, '{index_tab_name}', get_index_tab_name(ia));
        stmt2 := replace(stmt2, '{col_name}'      , ia.IndexCols(1).ColName);
        stmt2 := replace(stmt2, '{owner}'         , ia.IndexCols(1).TableSchema);
        stmt2 := replace(stmt2, '{tab_name}'      , ia.IndexCols(1).TableName);
        p_debug('ODCIIndexCreate>>>>>'||stmt2);
       
        p_exec(stmt2);
        
        stmt3:='create index '||get_index_tab_index(ia)||' on '||get_index_tab_name(ia)||'(end_date,beg_date,rid) local';
        p_exec(stmt3);
        
        stmt3:='create index '||get_index_tab_index2(ia)||' on '||get_index_tab_name(ia)||'(rid) local';
        p_exec(stmt3);
        
        dbms_stats.gather_table_stats(ia.IndexSchema,get_index_tab_name_only(ia));
  end ODCIIndexCreate_pr;
  
  procedure ODCIIndexDrop_pr(
        ia  sys.ODCIIndexInfo,
        env sys.ODCIEnv
    ) is
  begin
    p_debug('env.DEBUGLEVEL: '||env.DEBUGLEVEL);
    p_debug('env.CURSORNUM: '||env.CURSORNUM);
    -- drop the auxiliary table
    p_exec('DROP TABLE '||get_index_tab_name(ia));
  end;
  
  procedure ODCIIndexStart_Pr(
        sctx   IN OUT idx_range_date_type,
        ia     sys.ODCIIndexInfo,
        op     sys.ODCIPredInfo,
        qi     sys.ODCIQueryInfo,
        strt   NUMBER,
        stop   NUMBER,
        cmpval DATE,
        env    sys.ODCIEnv,
        res    out varchar2
    )
  IS
      relop VARCHAR2(20);
      stmt VARCHAR2(1000);
    BEGIN
      $IF $$DRS_DEBUG $THEN
        idx_range_date_pkg.p_debug('ODCIIndexStart>>>>>');
        sys.ODCIIndexInfoDump(ia);
        sys.ODCIPredInfoDump(op);
        sys.Odciqueryinfodump(qi);
        idx_range_date_pkg.p_debug('start key : '||strt);
        idx_range_date_pkg.p_debug('stop key : '||stop);
        idx_range_date_pkg.p_debug('compare value : '||cmpval);
      $END
      
      -- Take care of some error cases.
      -- The only predicates in which btree operators can appear are
      --    op() = 1     OR    op() = 0
      if (strt != 1) /*and (strt != 0)*/ then
        raise_application_error(-20101, 'Incorrect predicate for operator');
      END if;
     
      if (stop != 1) /*and (stop != 0)*/ then
        raise_application_error(-20101, 'Incorrect predicate for operator');
      END if;
      
      -- Generate the SQL statement to be executed.
      -- First, figure out the relational operator needed for the statement.
      -- Take into account the operator name and the start and stop keys. For now, 
      -- the start and stop keys can both be 1 (= TRUE) or both be 0 (= FALSE).
      if op.ObjectName = 'DATE_IN_RANGE' then
        relop := 'between';
      else
        raise_application_error(-20101, 'Unsupported operator');
      end if;
      p_debug('relop: '||relop);
      -- This statement returns the qualifying rows for the TRUE case.
      stmt := q'{
        select rid from {tab_name} partition (part_15_min) p1
        where :cmpval between beg_date and end_date
          and end_date < :cmpval+interval'15'minute
        union all
        select rid from {tab_name} partition (part_1_hour) p2
        where :cmpval between beg_date and end_date
          and end_date < :cmpval+1/24
        union all
        select rid from {tab_name} partition (part_1_day ) p3
        where :cmpval between beg_date and end_date
          and end_date < :cmpval+1
        }';
      stmt:= replace(stmt,'{tab_name}',idx_range_date_pkg.get_index_tab_name(ia));
      -- In the FALSE case, we must find the  complement of the rows.
      if (strt = 0) then
        raise_application_error(-20101, 'Unsupported operator (must be =1)');
        --stmt := 'select distinct r from '||idx_range_date_pkg.get_index_tab_name(ia)
        --      ||' minus '||stmt;
      end if;
     
      idx_range_date_pkg.p_debug('ODCIIndexStart>>>>>' || stmt);

      -- out:
      res:=stmt;
  END ODCIIndexStart_Pr;
  
  procedure ODCIIndexFetch_pr(
        nrows NUMBER,
        rids  OUT sys.ODCIRidList,
        env   sys.ODCIEnv,
        cur   IN OUT sys_refcursor
    )
  IS
    rlist sys.ODCIRidList := sys.ODCIRidList();
    type t_rowid is table of rowid;
    rowids t_rowid;
  BEGIN
    idx_range_date_pkg.p_debug('ODCIIndexFetch>>>>>');
    idx_range_date_pkg.p_debug('Nrows : '||round(nrows));
     
    
    FETCH cur BULK COLLECT INTO rowids limit nrows;
    idx_range_date_pkg.p_debug('Fetch: fetched '||rowids.count()||' rows');
    for i in 1..rowids.count loop
      rlist.extend;
      rlist(i):=rowids(i);
    end loop;
    if rowids.count<nrows then
      rlist.extend;
    end if;

    rids:=rlist;
  end ODCIIndexFetch_pr;
  
  procedure ODCIIndexInsert_pr(
        ia       sys.ODCIIndexInfo,
        rid      VARCHAR2,
        newval   VARCHAR2,
        env      sys.ODCIEnv
    )
  IS
  BEGIN
        -- Insert into auxiliary table
        execute immediate 
           'INSERT INTO '|| get_index_tab_name(ia)||' (rid, beg_date, end_date)'
         ||'select 
             :rid, sub_beg_date, sub_end_date
            from split_interval_by_days(:beg_date, :end_date)'
           using rid,get_beg_date(newval),get_end_date(newval);
  END;
  
  procedure ODCIIndexDelete_pr(
        ia      sys.ODCIIndexInfo,
        rid     VARCHAR2,
        oldval  VARCHAR2,
        env     sys.ODCIEnv
    ) is
  begin
    -- Remove from auxiliary table
    execute immediate
       'DELETE FROM '|| get_index_tab_name(ia)||' WHERE rid = :rid'
       using rid;
  end;
END;
/
