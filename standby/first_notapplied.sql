select * 
from (
    SELECT SEQUENCE#, FIRST_TIME, NEXT_TIME, APPLIED
    FROM V$ARCHIVED_LOG
    WHERE applied!='YES'
    order by 1,2
    )
where rownum<30
/
