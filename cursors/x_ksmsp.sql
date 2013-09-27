with p as (
     select/*+ materialize */ 
        p.*
       ,decode(instr(p.ksmchcom,'^'),0,null, to_number(substr(p.ksmchcom,instr(p.ksmchcom,'^')+1),'XXXXXXXXXXXXXXXX')) hash_value
     from X$KSMSP p 
)
select--+ leading(s p) 
   s.sql_id,s.hash_value
--  ,child_address /*KGLHDADR*/
  , trim(to_char(s.hash_value,'XXXXXXXXXXXXXXXX')) chcom
  , p.KSMCHCOM heap
  , p.KSMCHPAR heap_adr/* can be joined with X$KSMHP.KSMCHDS = hextoraw(p.KSMCHPAR) */
  , p.KSMCHCLS
  , p.KSMCHTYP
  , p.addr
  , p.indx
--  , p.inst_id
  , p.KSMCHIDX
  , p.KSMCHDUR
  , p.KSMCHPTR
  , p.KSMCHSIZ
from 
   v$sqlarea s
  ,p 
where --rownum=1
     s.sql_id='&1'
 and p.hash_value=s.hash_value
--order by 
/
