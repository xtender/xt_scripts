col dt new_val dt
select to_char(sysdate,'yyyymmdd-hh24miss') dt from dual;

-- Buffer cache decision making:
alter session set events '10358 trace name context forever, level 2';
-- Direct I/O decision making:
alter session set events 'trace [NSMTIO] disk highest';

alter session set tracefile_identifier='nsmtio_&dt';
