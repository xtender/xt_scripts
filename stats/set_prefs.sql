accept tab_owner - 
       prompt 'Owner: ' -
       default 'OD';

accept tab_name - 
       prompt 'Table: ';


accept _CASCADE            prompt 'CASCADE         : ';
accept _DEGREE             prompt 'DEGREE          : ';
accept _ESTIMATE_PERCENT   prompt 'ESTIMATE_PERCENT: ';
accept _METHOD_OPT         prompt 'METHOD_OPT      : ';
accept _NO_INVALIDATE      prompt 'NO_INVALIDATE   : ';
accept _GRANULARITY        prompt 'GRANULARITY     : ';
accept _PUBLISH            prompt 'PUBLISH         : ';
accept _INCREMENTAL        prompt 'INCREMENTAL     : ';
accept _STALE_PERCENT      prompt 'STALE_PERCENT   : ';

set serverout on;

declare
   p_owner varchar2(30):=upper('&tab_owner');
   p_table varchar2(30):=upper('&tab_name');
   
   procedure set_pref( p_name  varchar2
                      ,p_value varchar2)
   is
   begin
      if p_value is not null then 
         dbms_stats.set_table_prefs(
            ownname => p_owner
           ,tabname => p_table
           ,pname   => p_name
           ,pvalue  => p_value
         );
         dbms_output.put_line(rpad(p_name,10)||' = '||p_value);
      end if;
   end set_pref;
begin
   
      set_pref( 'CASCADE'           , '&_CASCADE');
      set_pref( 'DEGREE'            , '&_DEGREE');
      set_pref( 'ESTIMATE_PERCENT'  , '&_ESTIMATE_PERCENT');
      set_pref( 'METHOD_OPT'        , '&_METHOD_OPT');
      set_pref( 'NO_INVALIDATE'     , '&_NO_INVALIDATE');
      set_pref( 'GRANULARITY'       , '&_GRANULARITY');
   $IF DBMS_DB_VERSION.VERSION>=11 $THEN
      set_pref( 'PUBLISH'           , '&_PUBLISH');
      set_pref( 'INCREMENTAL'       , '&_INCREMENTAL');
      set_pref( 'STALE_PERCENT'     , '&_STALE_PERCENT');
   $END
end;
/
set serverout off
@stats/tab_prefs &tab_name &tab_owner
