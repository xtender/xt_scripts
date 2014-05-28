col username   for a30;
col osuser     for a30;
col module     for a30;
col program    for a30;
col status     for a12;
col name       for a5;
col start_time for a18;
with v as (
      select s.sid,s.username
            ,s.osuser
            ,s.module,s.program
            --,addr,ses_addr
            ,tr.xid
            ,tr.xidusn
            ,tr.xidslot
            ,tr.xidsqn
            --,ubafil,ubablk,ubasqn,ubarec
            ,tr.status
            ,tr.start_time
            --,tr.start_date
            ,tr.used_ublk
            ,tr.used_urec
            ,tr.log_io
            ,tr.phy_io
            ,tr.cr_get
            ,tr.cr_change
            ,tr.flag
            ,tr.space
            ,tr.recursive
            ,tr.noundo
            ,tr.ptx        parallel_tx
            ,tr.name
            ,tr.start_scn 
            --,dependent_scn
            --,start_scnb,start_scnw,start_uext,start_ubafil,start_ubablk,start_ubasqn,start_ubarec
            --,prv_xidusn,prv_xidslt,prv_xidsqn
            --,ptx_xidusn,ptx_xidslt,ptx_xidsqn
            --,dscn-b,dscn-w
            --,dscn_base,dscn_wrap
            --,prv_xid,ptx_xid
            ,row_number()over(order by used_ublk desc) blks_rn
            ,row_number()over(order by used_urec desc) recs_rn
            ,row_number()over(order by start_time desc) time_rn
      from v$transaction tr
          ,v$session s
      where tr.SES_ADDR = s.saddr(+)
)
select 
  sid
 ,username
 ,osuser
 ,substr(module,1,30) as module
 ,program
 --,xid
 --,xidusn,xidslot,xidsqn
 ,status
 ,start_time
 ,used_ublk
 ,used_urec
 ,log_io
 ,phy_io
 ,cr_get
 ,cr_change
 --,flag
 ,space,recursive,noundo,parallel_tx
 ,name
 ,start_scn
from v
where blks_rn<=10
   or recs_rn<=10
   or time_rn<=10
order by blks_rn
/
col username   clear;
col osuser     clear;
col module     clear;
col program    clear;
col status     clear;
col name       clear;
col start_time clear;
