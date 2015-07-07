select * from table(dbms_xplan.display('','','TYPICAL'));
col outlines for a120;
select--+ CURSOR_SHARING_EXACT NO_XMLINDEX_REWRITE NO_XMLINDEX_REWRITE_IN_SELECT 
        q'{,q'[}'
        ||regexp_replace(d.hint,'\s{2,}',' ')||
        q'{]'}' outlines
    from
        xmltable('/other_xml/outline_data/*'
            passing (
                select
                 xmlval
                from(
                    select
                        xmltype(other_xml) as xmlval
                    from
                        plan_table
                    where other_xml is not null
                    order by plan_id desc
                )
                where rownum<2
            )
            columns
            "HINT" varchar2(4000) PATH '/hint'
    ) d
/

col outlines clear;