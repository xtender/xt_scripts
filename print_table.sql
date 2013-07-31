select *
from 
   xmltable( 'let $i:=0
              for $r at $i in /ROWSET/ROW
                for $e at $j in $r/*
                   return element r {
                              element i {data($i)}
                            , element j {data($j)}
                            , element key   { data($e/name()) }
                            , element val   { data($e/text()) }
                          }
             '
            passing dbms_xmlgen.getxmltype(q'[&1 ]')
                    --xmltype(cursor(select * from doctype where rownum=1))
            columns 
                i for ordinality
            ,   p_rownum  int path 'i'
            ,   p_field_n int path 'j'
            ,   p_key     varchar2(30) path 'key'
            ,   p_val     varchar2(30) path 'val'
   )
/
/* variant 2:
alter session set events '19027 trace name context forever, level 0x1';
select *
from 
   table(xmlsequence(cursor(&1))) t
  ,xmltable( 'let $i:=0
              for $r at $i in /ROW
                for $e at $j in $r/*
                   return element r {
                              element i {data($i)}
                            , element j {data($j)}
                            , element key   { data($e/name()) }
                            , element val   { data($e/text()) }
                          }
             '
            passing 
                    t.column_value
            columns 
                i for ordinality
            ,   p_rownum  int path 'i'
            ,   p_field_n int path 'j'
            ,   p_key     varchar2(30) path 'key'
            ,   p_val     varchar2(30) path 'val'
   );
*/