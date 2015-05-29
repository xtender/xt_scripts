REM *******************************************************************************************
REM **  VERSION_CHECK: sets variables about ORACLE version in addition to _O_REALEASE, etc
REM ** Based on Tanel Poder's TPT scripts.
REM *******************************************************************************************

define _IF_ORA10_OR_HIGHER="--"
define _IF_ORA11_OR_HIGHER="--"
define _IF_LOWER_THAN_ORA11="--"
define _IF_DBMS_SYSTEM_ACCESSIBLE="/* dbms_system is not accessible" /*dummy*/
define _IF_X_ACCESSIBLE="--"

define _YES_PLSQL_OBJ_ID="--"  -- plsql_object_id columns available in v$session (from 10.2.0.3)
define _NO_PLSQL_OBJ_ID=""
define _YES_BLK_INST="--"      -- blocking_instance available in v$session (from 10.2)
define _NO_BLK_INST=""

col snapper_ora09lower      noprint new_value _IF_LOWER_THAN_ORA09
col snapper_ora10lower      noprint new_value _IF_LOWER_THAN_ORA10
col snapper_ora11lower      noprint new_value _IF_LOWER_THAN_ORA11
col snapper_ora12lower      noprint new_value _IF_LOWER_THAN_ORA12

col snapper_ora09higher     noprint new_value _IF_ORA09_OR_HIGHER
col snapper_ora10higher     noprint new_value _IF_ORA10_OR_HIGHER
col snapper_ora11higher     noprint new_value _IF_ORA11_OR_HIGHER
col snapper_ora12higher     noprint new_value _IF_ORA12_OR_HIGHER

col dbms_system_accessible  noprint new_value _IF_DBMS_SYSTEM_ACCESSIBLE
col x_accessible            noprint new_value _IF_X_ACCESSIBLE
col no_plsql_obj_id         noprint new_value _NO_PLSQL_OBJ_ID
col yes_plsql_obj_id        noprint new_value _YES_PLSQL_OBJ_ID
col no_blk_inst             noprint new_value _NO_BLK_INST
col yes_blk_inst            noprint new_value _YES_BLK_INST

col snapper_ora9            noprint new_value _IF_ORA9
col snapper_ora9206lower    noprint new_value _IF_ORA9206_OR_LOWER
col snapper_ora9207higher   noprint new_value _IF_ORA9207_OR_HIGHER
col snapper_ora112higher    noprint new_value _IF_ORA112_OR_HIGHER

-- this block determines whether dbms_system.ksdwrt is accessible to us
-- dbms_describe is required as all_procedures/all_objects may show this object
-- even if its not executable by us (thanks to o7_dictionary_accessibility=false)

var v    varchar2(100)
var x    varchar2(10)

declare

    o       sys.dbms_describe.number_table;
    p       sys.dbms_describe.number_table;
    l       sys.dbms_describe.number_table;
    a       sys.dbms_describe.varchar2_table;
    dty     sys.dbms_describe.number_table;
    def     sys.dbms_describe.number_table;
    inout   sys.dbms_describe.number_table;
    len     sys.dbms_describe.number_table;
    prec    sys.dbms_describe.number_table;
    scal    sys.dbms_describe.number_table;
    rad     sys.dbms_describe.number_table;
    spa     sys.dbms_describe.number_table;

    tmp     number;

begin

    begin
        execute immediate 'select count(*) from x$kcbwh where rownum = 1' into tmp;
        :x:= ' '; -- x$ tables are accessible, so dont comment any lines out
    exception
        when others then null;
    end;

    sys.dbms_describe.describe_procedure(
        'DBMS_SYSTEM.KSDWRT', null, null,
        o, p, l, a, dty, def, inout, len, prec, scal, rad, spa
    );

    -- we never get to following statement if dbms_system is not accessible
    -- as sys.dbms_describe will raise an exception
    :v:= '-- dbms_system is accessible';

exception
    when others then null;
end;
/
with 
version as (
    select 
      ver
     ,substr(ver,1,2) v1
     ,substr(ver,1,4) v2
    from (
      select lpad('&_O_RELEASE',10,' ') ver from dual
    )
)
select
    case when v1  <  '09'        then ''   else '--'  end   snapper_ora09lower,
    case when v1  <  '10'        then ''   else '--'  end   snapper_ora10lower,
    case when v1  <  '11'        then ''   else '--'  end   snapper_ora11lower,
    case when v1  <  '12'        then ''   else '--'  end   snapper_ora12lower,

    case when v1  >= '09'        then ''   else '--'  end   snapper_ora09higher,
    case when v1  >= '10'        then ''   else '--'  end   snapper_ora10higher,
    case when v1  >= '11'        then ''   else '--'  end   snapper_ora11higher,
    case when v1  >= '12'        then ''   else '--'  end   snapper_ora12higher,

    case when ver >= '1002'      then ''   else '--'  end   yes_blk_inst,
    case when ver >= '1002'      then '--' else ''    end   no_blk_inst,
    case when ver >= '10020003'  then ''   else '--'  end   yes_plsql_obj_id,
    case when ver >= '10020003'  then '--' else ''    end   no_plsql_obj_id,
    case when v1  <  '10'        then ''   else '--'  end   snapper_ora9,
    case when ver <  '09020007'  then ''   else '--'  end   snapper_ora9206lower,
    case when ver >= '09020007'  then ''   else '--'  end   snapper_ora9207higher,
    case when v2  >= '1102'      then ''   else '--'  end   snapper_ora112higher,
    nvl(:v, '/* dbms_system is not accessible') dbms_system_accessible,
    nvl(:x, '--') x_accessible,
    null
from
    version
/
