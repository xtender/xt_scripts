with 
 fi as (select/*+ materialize */ * from sys.file$)
,used as (select/*+ materialize */ fi.ts#,sum(blocks) blocks from fi group by fi.ts#)
,free as (
   select ts#,sum(blocks) blocks
   from (
      select f.ts#,
             sum(f.length) blocks
      from sys.fet$ f
      group by f.ts#
      union all
      select
             f.ktfbfetsn,
             sum(f.ktfbfeblks)
      from sys.x$ktfbfe f
      group by f.ktfbfetsn
      union all
      select
             rb.ts#, 
             sum(u.ktfbueblks)
      from sys.recyclebin$ rb, sys.x$ktfbue u, fi
      where rb.ts# = fi.ts#
        and u.ktfbuefno = fi.relfile#
        and u.ktfbuesegtsn = rb.ts#
        and u.ktfbuesegfno = rb.file#
        and u.ktfbuesegbno = rb.block#
      group by rb.ts#
      union all
      select u.ts#, 
             sum(u.length)
      from sys.uet$ u, fi, sys.recyclebin$ rb
      where u.ts# = fi.ts#
        and u.segfile# = fi.relfile#
        and u.ts# = rb.ts#
        and u.segfile# = rb.file#
        and u.segblock# = rb.block#
      group by u.ts#
  )
  group by ts#
)
select t.name
      ,free.blocks*blocksize as free_space
      ,used.blocks*blocksize 
from sys.ts$ t,free,used
where t.ts#=free.ts#
  and t.ts#=used.ts#
/