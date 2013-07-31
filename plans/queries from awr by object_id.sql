select object_id from dba_objects o where object_name='IX_CURREXCHANGE_109' and owner='OD'
/
select distinct ','''||p.sql_id||''''
from
     dba_hist_sql_plan p
    ,dba_hist_sqltext  s
    ,sys.wrm$_snapshot sn
    ,sys.wrh$_sqlstat  st
    ,v$database db
where 
      p.OBJECT#               = 573334

  and s.sql_id                = p.sql_id
  and s.dbid                  = db.dbid

  and sn.dbid                 = db.dbid
  and sn.begin_interval_time >= trunc(sysdate)-14

  and st.SQL_ID               = p.sql_id
  and st.DBID                 = db.dbid
  and st.SNAP_ID              = sn.snap_id
  and st.INSTANCE_NUMBER      = 1
/
select * 
from dba_hist_sqltext t
where t.sql_id in (
                   'dkb38c20zac4q'
                  ,'gj0rv12zfrkzb'
                  ,'0taxj9k7nw1hv'
                  ,'bx8xv55cgksgh'
                  ,'43rnyt3jr1s06'
                  ,'a7br98fa3c8p8'
                  ,'093h7bww8dyt3'
                  ,'4zf9vx2gqvbrv'
                  ,'ads2vthcxcq50'
                  ,'0z150u9059czs'
                  ,'bv91sbjt56knq'
                  ,'5dna6z8g9z120'
                  )
and dbid=(select dbid from v$database)
