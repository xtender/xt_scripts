doc
--------------------------------------------------------------------------------
--
--  Script for calling Tanel Poder's ashtop/dashtop:
--------------------------------------------------------------------------------
--
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--
-- Usage:       
--     @ashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Examples:
--     @ashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--     @ash/dashtop session_state,event 1=1 "TIMESTAMP'2013-09-09 21:00:00'" "TIMESTAMP'2013-09-09 22:00:00'"
-- 
-- -----------------------------------------------------------------------------
#
accept grouping_cols    prompt "Grouping cols: ";
accept filters          prompt "Filters      : ";
accept fromtime         prompt "From time    : ";
accept totime           prompt "To time      : ";
accept call_prefix      prompt "Enter 'd' for dashtop: ";

@tpt/ash/&call_prefix.ashtop "&grouping_cols" "&filters" "&fromtime" "&totime"
