@inc/input_vars_init;
prompt *** Show top session by undo used:
prompt;
col "Username/Osuser"         format a45;
col process          format a13;
col object           format a40;
col subobject_name   format a30;
col l_mode           format a12;
col object_type      format a20;

break on sid on serial# on "Username/Osuser" on recs on blocks on xidusn on xidslot on xidsqn on process skip 1;

with t as (
   select *
   from (select *
         from v$transaction
         where used_ublk>0
         order by used_ublk desc)
   where rownum<=10
)
   select
      s.sid
     ,s.serial#
     ,s.username ||' / '|| s.osuser as "Username/Osuser"
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
   from t
      , v$session s
      , v$locked_object l
      , dba_objects o
    where t.addr      = s.taddr
      and t.xidusn    = l.xidusn(+)
      and t.xidslot   = l.xidslot(+)
      and l.object_id = o.object_id(+)
   order by blocks desc,sid
/
col "Username/Osuser"         clear;
col process          clear;
col object           clear;
col subobject_name   clear;
col l_mode           clear;
col object_type      clear;
clear break;
@inc/input_vars_undef;
