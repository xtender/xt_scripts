select * from (
SELECT SEQUENCE#, FIRST_TIME, NEXT_TIME, APPLIED 
FROM V$ARCHIVED_LOG 
order by SEQUENCE# desc
)
where rownum<=5;

select * from (
SELECT SEQUENCE#, FIRST_TIME, NEXT_TIME, APPLIED 
FROM V$ARCHIVED_LOG 
where APPLIED !='NO'
order by SEQUENCE# desc
)
where rownum<=5;