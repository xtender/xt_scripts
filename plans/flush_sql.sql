DECLARE
  name varchar2(50);
  version varchar2(3);
BEGIN
  select regexp_replace(version,'\..*') into version from v$instance;

  if version = '10' then
    execute immediate 
      q'[alter session set events '5614566 trace name context forever']'; -- bug fix for 10.2.0.4 backport
  end if;

  select address||','||hash_value into name
  from v$sqlarea 
  where sql_id like '&sql_id';

  sys.dbms_shared_pool.purge(name,'C',1);

END;
/
