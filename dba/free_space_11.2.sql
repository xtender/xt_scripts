with
 ts as (select/*+ materialize */ name,ts#,bitmapped,online$,contents$,blocksize,flags from sys.ts$)
,fi as (select/*+ materialize */ * from sys.file$)
,ktfbfe as (select/*+ materialize */ * from sys.x$ktfbfe)
,free_space(tablespace_name, bytes) as (
      select ts.name, 
             sum(f.length) * ts.blocksize
      from ts, sys.fet$ f
      where ts.ts# = f.ts#
        and ts.bitmapped = 0
      group by ts.name,ts.blocksize
      union all
      select
             ts.name,
             sum(f.ktfbfeblks) * ts.blocksize
      from ts, ktfbfe f
      where ts.ts# = f.ktfbfetsn
        and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
      group by ts.name,ts.blocksize
      union all
      select
             ts.name, 
             sum(u.ktfbueblks) * ts.blocksize
      from sys.recyclebin$ rb, ts, sys.x$ktfbue u, fi
      where ts.ts# = rb.ts#
        and rb.ts# = fi.ts#
        and u.ktfbuefno = fi.relfile#
        and u.ktfbuesegtsn = rb.ts#
        and u.ktfbuesegfno = rb.file#
        and u.ktfbuesegbno = rb.block#
        and ts.bitmapped <> 0 and ts.online$ in (1,4) and ts.contents$ = 0
      group by ts.name,ts.blocksize
      union all
      select ts.name, 
             sum(u.length) * ts.blocksize
      from ts, sys.uet$ u, fi, sys.recyclebin$ rb
      where ts.ts# = u.ts#
        and u.ts# = fi.ts#
        and u.segfile# = fi.relfile#
        and u.ts# = rb.ts#
        and u.segfile# = rb.file#
        and u.segblock# = rb.block#
        and ts.bitmapped = 0
      group by ts.name,ts.blocksize
)
select * from free_space
