with 
 bugs as (
    select--+ materialize
        id,description
    from xmltable(
            '/bugInfo/bugs/bug'
            passing dbms_qopatch.get_opatch_bugs
            columns
                id         number path '@id'
               ,description varchar2(100) path 'description'
        )
 )
select *
from bugs
where id = &1
/