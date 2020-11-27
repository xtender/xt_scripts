with
   function getxmltype(p_cursor sys_refcursor) return xmltype as
      h dbms_xmlgen.ctxHandle;
      x xmltype;
   begin
       h := dbms_xmlgen.newContext(p_cursor);
       dbms_xmlgen.setNullHandling(h, dbms_xmlgen.EMPTY_TAG);
       x := dbms_xmlgen.getXMLType(h);
       dbms_xmlgen.closecontext(h);
       return x;
   end;
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
            passing getxmltype(cursor(&1))
            columns 
                i for ordinality
            ,   p_rownum  int path 'i'
            ,   p_field_n int path 'j'
            ,   p_key     varchar2(30) path 'key'
            ,   p_val     varchar2(30) path 'val'
   )
/