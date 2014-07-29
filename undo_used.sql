@inc/input_vars_init;
prompt *** Show undo used by SID.
prompt Usage: @undo_used sid

col username         format a25;
col osuser           format a25;
col process          format a13;
col object           format a40;
col subobject_name   format a30;
col object_type      format a20;
   select
      s.sid
     ,s.serial#
     ,s.username
     ,s.osuser
     ,t.used_urec   as recs
     ,t.used_ublk   as blocks
     ,l.xidusn
     ,l.xidslot
     ,l.xidsqn
     ,l.process
     ,l.object_id
     ,o.owner||'.'||o.object_name object
     ,o.subobject_name
     ,Decode(l.locked_mode,
               0, 'None',
               1, 'Null (NULL)',
               2, 'Row-S (SS)',
               3, 'Row-X (SX)',
               4, 'Share (S)',
               5, 'S/Row-X (SSX)',
               6, 'Exclusive (X)',
               'Unknown:'||l.locked_mode)
              as l_mode
     ,o.data_object_id
     ,o.object_type
from v$transaction t
      , v$session s
      , v$locked_object l
      , dba_objects o
    where t.addr      = s.taddr
      and t.xidusn    = l.xidusn(+)
      and t.xidslot   = l.xidslot(+)
      and l.object_id = o.object_id(+)
      and sid = '&1'+0
/
col username         clear;
col osuser           clear;
col process          clear;
col object           clear;
col subobject_name   clear;
col object_type      clear;
@inc/input_vars_undef;