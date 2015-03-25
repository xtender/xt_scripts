accept trace_identifier prompt "Trace identifier: ";
accept ownname          prompt "Segment owner: ";
accept segname          prompt "Segment name: ";

alter session set tracefile_identifier='&trace_identifier';

prompt Tracing was enabled:
select par.value ||'/'||(select instance_name from v$instance) ||'_ora_'||s.suffix|| '.trc' as tracefile_name
from 
    v$parameter par
  , (select spid||case when traceid is not null then '_'||traceid else null end suffix
     from v$process where addr = (select paddr from v$session
                                  where sid = userenv('sid')
                                ) 
    ) s
where name = 'user_dump_dest';

begin
 for rec in (select file_id, block_id start_block, block_id + blocks - 1 end_block from dba_extents where segment_name = '&segname' and owner = '&ownname') loop
 execute immediate 'alter system dump datafile ' || rec.file_id || ' block min ' || rec.start_block || ' block max ' || rec.end_block;
 end loop;
end;
/
undef trace_identifier ownname segname;
alter session set tracefile_identifier=CLEANUP;
alter session set tracefile_identifier=new;
