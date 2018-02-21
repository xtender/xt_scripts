select * 
from (
    SELECT 
        row_number()over(order by SEQUENCE# desc) n
       ,SEQUENCE#, FIRST_TIME, NEXT_TIME, APPLIED
    FROM V$ARCHIVED_LOG 
    WHERE applied='YES'
)
where n=1;