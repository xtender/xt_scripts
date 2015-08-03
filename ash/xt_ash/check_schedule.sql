var c refcursor;
declare 
   vc_sql varchar2(1000):='select * from all_scheduler_jobs j where j.job_name='''||xt_ash.C_JOB_NAME||'''';
begin
   open :C for
    select p_key, p_val
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
                passing dbms_xmlgen.getxmltype(vc_sql)
                columns 
                    i for ordinality
                ,   p_rownum  int path 'i'
                ,   p_field_n int path 'j'
                ,   p_key     varchar2(30) path 'key'
                ,   p_val     varchar2(120) path 'val'
       );
end;
/
col p_key for a40;
col p_val for a120;
print :c;
col p_key clear;
col p_val clear;