store set settings.sql replace
-- saving previous query:
save tmp.sql replace
 
-- OS-dependent removing trailing slash from file, choose one:
-- 1. for *nix through head:
-- !head -1 tmp.sql >tmp2.sql
 
-- 2. for for *nix through grep:
-- host grep -v tmp.sql >tmp2.sql
 
-- 3. for windows without grep and head:
-- $cmd /C findstr /v /C:"/" tmp.sql > tmp2.sql

-- 4. for windows with "head"(eg from cygwin)
$cmd /C head -1 tmp.sql > tmp2.sql
 
-- 5. for windows with "grep":
--$cmd /C grep -v "/" tmp.sql > tmp2.sql
 
 
 
-- same setting as in print_table:
set termout on echo off embedded on pause on newpage 2
set pause "Press Enter to view next row..."
break on row_num skip page
 
-- main query:
select *
from
   xmltable( 'for $a at $i in /ROWSET/ROW
                 ,$r in $a/*
                   return element ROW{
                                     element ROW_NUM{$i}
                                    ,element COL_NAME{$r/name()}
                                    ,element COL_VALUE{$r/text()}
                                    }'
             passing dbms_xmlgen.getxmltype(
             q'[
               @tmp2.sql
             ]'
             )
             columns
                row_num   int
               ,col_name  varchar2(30)
               ,col_value varchar2(100)
      );
-- disabling pause and breaks:
set pause off
clear breaks
@settings.sql