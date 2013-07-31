col object_name for a30
select o.owner
      ,o.object_name
      ,o.object_id
      ,o.data_object_id
      ,v$bh.FILE#
      ,v$bh.BLOCK#
      ,v$bh.CLASS#
      ,v$bh.STATUS
      ,v$bh.DIRTY
      ,v$bh.TEMP
      ,v$bh.STALE
      ,v$bh.DIRECT
      ,v$bh.lobid
      ,decode( class#
              ,1,'data block'
              ,2,'sort block'
              ,3,'save undo block'
              ,4,'segment header'
              ,5,'save undo header'
              ,6,'free list'
              ,7,'extent map'
              ,8,'1st level bmb'
              ,9,'2nd level bmb'
              ,10,'3rd level bmb'
              ,11,'bitmap block'
              ,12,'bitmap index block'
              ,13,'file header block'
              ,14,'unused'
              ,15,'system undo header'
              ,16,'system undo block'
              ,17,'undo header'
              ,18,'undo block'
            ) bl
from 
    dba_objects o
  , v$bh 
where 
     o.owner       like upper('%&owner%')
 and o.object_name like upper('&name')
 and v$bh.objd=DATA_OBJECT_ID
order by 1,2,3,4,5,6;