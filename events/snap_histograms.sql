prompt &_C_RED *** Snapper for event histograms &_C_RESET;
prompt * Usage: @events/snap_histograms event_mask [period]

var cur refcursor;

declare
   l_event_mask varchar2(128):=q'[&1]';
   l_period     int:=case &2+0 when 0 then 1 else &2+0 end;
   x_start      xmltype;
   x_end        xmltype;
   
   cursor c_ev_histgrm(v_input varchar2) is
      select 
         XMLELEMENT("ROWSET",
            xmlagg(
                xmlelement( 
                    "ROW"
                   ,xmlelement(EVENT_ID        , e.event#          )
                   ,xmlelement(EVENT           , e.event           )
                   ,xmlelement(WAIT_TIME_MILLI , e.wait_time_milli )
                   ,xmlelement(WAIT_COUNT      , e.wait_count      )
                   ,xmlelement(LAST_UPDATE_TIME, e.last_update_time)
                  )
                )
            ) x
      from v$event_histogram e
      where e.EVENT like v_input||'%'
      ;

   function f_get_histgrm( p_param in varchar2 )
      return xmltype
   is
      res   xmltype;
   begin
      open c_ev_histgrm(p_param);
      fetch c_ev_histgrm into res;
      close c_ev_histgrm;
      return res;
   end;   
   
begin
   x_start:=f_get_histgrm(l_event_mask);
   dbms_lock.sleep(l_period);
   x_end  :=f_get_histgrm(l_event_mask);   
   open :cur for 
         with 
          v1 as (select/*+ no_xml_query_rewrite */ *
                 from xmltable(
                                '/ROWSET/ROW'
                                passing x_start
                                columns
                                   EVENT_ID          number        path 'EVENT_ID'
                                  ,EVENT             varchar2(64) path 'EVENT'
                                  ,WAIT_TIME_MILLI   number        path 'WAIT_TIME_MILLI'
                                  ,WAIT_COUNT        number        path 'WAIT_COUNT'
                                  ,LAST_UPDATE_TIME  varchar2(30)  path 'LAST_UPDATE_TIME'
                               )
          )
         ,v2 as (select/*+ no_xml_query_rewrite */ *
                 from xmltable(
                                '/ROWSET/ROW'
                                passing x_end
                                columns
                                   EVENT_ID          number        path 'EVENT_ID'
                                  ,EVENT             varchar2(64) path 'EVENT'
                                  ,WAIT_TIME_MILLI   number        path 'WAIT_TIME_MILLI'
                                  ,WAIT_COUNT        number        path 'WAIT_COUNT'
                                  ,LAST_UPDATE_TIME  varchar2(30)  path 'LAST_UPDATE_TIME'
                               )
          )
      select 
          nvl(v2.EVENT_ID        , v1.EVENT_ID       )  EVENT_ID       
         ,nvl(v2.EVENT           , v1.EVENT          )  EVENT          
         ,nvl(v2.WAIT_TIME_MILLI , v1.WAIT_TIME_MILLI)  WAIT_TIME_MILLI
         ,nvl(v2.WAIT_COUNT,0)-nvl(v1.WAIT_COUNT,0)     WAIT_COUNT
         ,nvl(v2.LAST_UPDATE_TIME, v1.LAST_UPDATE_TIME) LAST_UPDATE_TIME
      from v1
           full join v2 on (v1.event_id=v2.event_id and v1.event=v2.event and v1.wait_time_milli=v2.wait_time_milli)
      order by 1,2,3;
end;
/
col event            for a64;
col last_update_time for a35;
print cur;
col event            clear;
col last_update_time clear;
