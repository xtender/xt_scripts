CREATE OR REPLACE TYPE idx_range_date_type AS OBJECT (
    curnum number, -- Cursor

    -- Define new ODCIIndex interface methods
    STATIC FUNCTION ODCIGetInterfaces(
        ifclist OUT sys.ODCIObjectList
    ) RETURN NUMBER,

    STATIC FUNCTION ODCIIndexCreate(
        ia    sys.ODCIIndexInfo,
        parms VARCHAR2,
        env   sys.ODCIEnv
    ) RETURN NUMBER,

    STATIC FUNCTION ODCIIndexDrop(
        ia    sys.ODCIIndexInfo,
        env   sys.ODCIEnv
    ) RETURN NUMBER,

    STATIC FUNCTION ODCIIndexStart(
        sctx   IN OUT idx_range_date_type,
        ia     sys.ODCIIndexInfo,
        op     sys.ODCIPredInfo,
        qi     sys.ODCIQueryInfo,
        strt   NUMBER,
        stop   NUMBER,
        cmpval DATE,
        env    sys.ODCIEnv
    ) RETURN NUMBER,

    MEMBER FUNCTION ODCIIndexFetch(
        self in out idx_range_date_type,
        nrows NUMBER,
        rids  OUT sys.ODCIRidList,
        env   sys.ODCIEnv
    ) RETURN NUMBER,

    MEMBER FUNCTION ODCIIndexClose(
        env sys.ODCIEnv
    ) RETURN NUMBER,

    STATIC FUNCTION ODCIIndexInsert(
        ia      sys.ODCIIndexInfo,
        rid     VARCHAR2,
        newval  VARCHAR2,
        env     sys.ODCIEnv
    ) RETURN NUMBER,

    STATIC FUNCTION ODCIIndexDelete(
        ia      sys.ODCIIndexInfo,
        rid     VARCHAR2,
        oldval  VARCHAR2,
        env     sys.ODCIEnv
    ) RETURN NUMBER,

    STATIC FUNCTION ODCIIndexUpdate(
        ia      sys.ODCIIndexInfo,
        rid     VARCHAR2,
        oldval  VARCHAR2,
        newval  VARCHAR2,
        env     sys.ODCIEnv
    ) RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY idx_range_date_type AS


    STATIC FUNCTION ODCIGetInterfaces(
        ifclist OUT sys.ODCIObjectList
    ) RETURN NUMBER IS
    BEGIN
        -- Populate the list of supported interfaces
        ifclist := sys.ODCIObjectList(sys.ODCIObject('SYS','ODCIINDEX2'));
        RETURN ODCIConst.Success;
    END;

    STATIC FUNCTION ODCIIndexCreate(
        ia    sys.ODCIIndexInfo,
        parms VARCHAR2,
        env   sys.ODCIEnv
    ) RETURN NUMBER 
    IS
    BEGIN
      idx_range_date_pkg.ODCIIndexCreate_pr(ia,parms,env);
      RETURN ODCIConst.Success;
    END;

    STATIC FUNCTION ODCIIndexDrop(
        ia  sys.ODCIIndexInfo,
        env sys.ODCIEnv
    ) RETURN NUMBER IS
    BEGIN
        idx_range_date_pkg.ODCIIndexDrop_pr(ia,env);
        RETURN ODCIConst.Success;
    END;

    STATIC FUNCTION ODCIIndexStart(
        sctx   IN OUT idx_range_date_type,
        ia     sys.ODCIIndexInfo,
        op     sys.ODCIPredInfo,
        qi     sys.ODCIQueryInfo,
        strt   NUMBER,
        stop   NUMBER,
        cmpval DATE,
        env    sys.ODCIEnv
    ) RETURN NUMBER 
    IS
      stmt varchar2(32000);
      cnum number;
      rid ROWID;
      nrows INTEGER;
    BEGIN
      idx_range_date_pkg.ODCIIndexStart_pr(sctx,ia,op,qi,strt,stop,cmpval,env,stmt);
      
      cnum := dbms_sql.open_cursor;
      idx_range_date_pkg.p_debug('cursor opened');
      
      dbms_sql.parse(cnum, stmt, dbms_sql.native);
      dbms_sql.bind_variable(cnum, ':cmpval', cmpval);
      dbms_sql.define_column_rowid(cnum, 1, rid);   
      nrows := dbms_sql.execute(cnum);
      idx_range_date_pkg.p_debug('cursor executed. nrows: '||nrows);
      
      -- Set context as the cursor number.
      sctx := idx_range_date_type(cnum);
     
      -- Return success.
      RETURN ODCICONST.SUCCESS;
    END;

    MEMBER FUNCTION ODCIIndexFetch(
        self in out idx_range_date_type,
        nrows NUMBER,
        rids  OUT sys.ODCIRidList,
        env   sys.ODCIEnv
    ) RETURN NUMBER 
    IS
      cnum number;
      cur sys_refcursor;
    BEGIN
      idx_range_date_pkg.p_debug('Fetch: nrows='||nrows);
      cnum:=self.curnum;
      cur:=dbms_sql.to_refcursor(cnum);
      idx_range_date_pkg.p_debug('Fetch: converted to refcursor');

      idx_range_date_pkg.ODCIIndexFetch_pr(nrows,rids,env,cur);
      
      self.curnum:=dbms_sql.to_cursor_number(cur);
      RETURN ODCICONST.SUCCESS;
    END;

    MEMBER FUNCTION ODCIIndexClose(
        env sys.ODCIEnv
    ) RETURN NUMBER 
    IS
      cnum INTEGER;
    BEGIN
      idx_range_date_pkg.p_debug('ODCIIndexClose>>>>>'||env.DebugLevel);
     
      cnum := self.curnum;
      dbms_sql.close_cursor(cnum);
      RETURN ODCICONST.SUCCESS;
    END;

    STATIC FUNCTION ODCIIndexInsert(
        ia       sys.ODCIIndexInfo,
        rid      VARCHAR2,
        newval   VARCHAR2,
        env      sys.ODCIEnv
    ) RETURN NUMBER IS
    BEGIN
      idx_range_date_pkg.ODCIIndexInsert_pr(ia,rid,newval,env);
      RETURN ODCIConst.Success;
    END;

    STATIC FUNCTION ODCIIndexDelete(
        ia      sys.ODCIIndexInfo,
        rid     VARCHAR2,
        oldval  VARCHAR2,
        env     sys.ODCIEnv
    ) RETURN NUMBER IS
    BEGIN
      idx_range_date_pkg.ODCIIndexDelete_pr(ia,rid,oldval,env);
      RETURN ODCIConst.Success;
    END;

    STATIC FUNCTION ODCIIndexUpdate(
        ia      sys.ODCIIndexInfo,
        rid     VARCHAR2,
        oldval  VARCHAR2,
        newval  VARCHAR2,
        env     sys.ODCIEnv
    ) RETURN NUMBER IS
    BEGIN
      -- Example: delete old and insert new
      idx_range_date_pkg.ODCIIndexDelete_pr(ia,rid,oldval,env);
      idx_range_date_pkg.ODCIIndexInsert_pr(ia,rid,newval,env);
      RETURN ODCIConst.Success;
    END;

END;
/
