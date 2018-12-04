--------------------------------------------------------
--
-- simulate_control_c.sql
--
-- Purpose:
--
-- Sets event 10237 in a session to simulate
-- pressing CONTROL+C for that session
--
-- Allows to cancel a running SQL statement from
-- a remote session without killing the session
--
-- If the session is stuck on the server side
-- which means that it can't be killed this
-- probably won't help either
--
-- Requirements:
--
-- EXECUTE privilege on SYS.DBMS_SYSTEM
-- SELECT privilege on V$SESSION
--
-- Usage:
--
--            @simulate_control_c <SID>
--
-- Note:
--
-- The usage of that event is undocumented
-- Therefore use at your own risk!
-- Provided for free, without any warranties -
-- test this before using it on anything important
--
-- Other implementation ideas:
--
-- The following code is supposed to achieve the same on Enterprise Edition
-- and enabled Resource Manager in a documented way
-- In all versions tested (10.2.0.4, 11.1.0.7, 11.2.0.1, 11.2.0.2) I get however
-- ORA-29366 and it doesn't work as described
-- Note that the official documentation doesn't explicitly mention CANCEL_SQL as 
-- valid consumer group for this call

-- begin
--   sys.dbms_resource_manager.switch_consumer_group_for_sess(
--     <sid>,<serial#>,'CANCEL_SQL'
--   );
-- end;
--
-- When running on Unix KILL -URG sent to the server process
-- should also simulate a Control-C
-- This doesn't work with Windows SQL*Plus clients though
--
-- See Tanel Poder's blog post for more info
-- http://blog.tanelpoder.com/2010/02/17/how-to-cancel-a-query-running-in-another-session/
--
-- Author:
--
-- Randolf Geist
-- http://oracle-randolf.blogspot.com
--
-- Versions tested:
--
-- 11.2.0.1 Server+Client
-- 10.2.0.4 Server
-- 11.2.0.2 Server
--
--------------------------------------------------------

set echo off verify off feedback off

column sid new_value v_sid noprint
column serial# new_value v_serial noprint

-- Get details from V$SESSION
select
        sid
      , serial#
from
        v$session
where
        sid = to_number('&1')
and     status = 'ACTIVE'
;

declare
  -- Avoid compilation errors in case of SID not found
  v_sid     number  := to_number('&v_sid');
  v_serial  number  := to_number('&v_serial');
  v_status  varchar2(100);
  -- 60 seconds default timeout
  n_timeout number  := 5;
  dt_start  date    := sysdate;
begin
  -- SID not found
  if v_sid is null then
    raise_application_error(-20001, 'SID: &1 cannot be found or is not in STATUS=ACTIVE');
  else
    -- Set event 10237 to level 1 in session to simulate CONTROL+C
    sys.dbms_system.set_ev(v_sid, v_serial, 10237, 1, '');
    -- Check session state
    loop
      begin
        select
                status
        into
                v_status
        from
                v$session
        where
                sid = v_sid;
      exception
      -- SID no longer found
      when NO_DATA_FOUND then
        raise_application_error(-20001, 'SID: ' || v_sid || ' no longer found after cancelling');
      end;

      -- Status no longer active
      -- then set event level to 0 to avoid further cancels
      if v_status != 'ACTIVE' then
        sys.dbms_system.set_ev(v_sid, v_serial, 10237, 0, '');
        exit;
      end if;

      -- Session still active after timeout exceeded
      -- Give up
      if dt_start + (n_timeout / 86400) < sysdate then
        sys.dbms_system.set_ev(v_sid, v_serial, 10237, 0, '');
        raise_application_error(-20001, 'SID: ' || v_sid || ' still active after ' || n_timeout || ' seconds');
      end if;

      -- Back off after 5 seconds
      -- Check only every second from then on
      -- Avoids burning CPU and potential contention by this loop
      -- However this means that more than a single statement potentially
      -- gets cancelled during this second
      if dt_start + (5 / 86400) < sysdate then
        dbms_lock.sleep(1);
      end if;
    end loop;
  end if;
end;
/
