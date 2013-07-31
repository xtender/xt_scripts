create or replace package xt_runstats
as
   /**
    Usage examples:
    -- 1. for own session:
      begin
        xt_runstats.init();
        [some_code_1]
        xt_runstats.snap(); -- by default it will have header 'Run 1'
        [some_code_2]
        xt_runstats.snap('Test 2'); -- header = Test 2
        ...
        [some_code_N]
        xt_runstats.snap();
        -- result output:
        xt_runstats.print();
      end;

    -- 2. for session with sid = N
      begin xt_runstats.init(N); end;
      ...[after a while]
      begin xt_runstats.snap; end;
      ...[one more if needed...]
      begin xt_runstats.snap; end;
        -- result output:
      begin xt_runstats.print(); end;

    -- 3. Only latches:
      xt_runstats.init(p_stats=>false);

    -- 4. Print stats with name like '%gets%':
      xt_runstats.print(p_stats_mask=>'%gets%');

    -- 5. Print latches which differ by 30% or more and stats differ by 15% or more:
      xt_runstats.print( p_lat_diff_pct=>30, p_sta_diff_pct => 15);
    */

   /**
    * Initialization with params setting
    * @param p_sid        Session sid for statistics gathering.      By default own session.
    * @param p_latches    Enable gathering latches gets from v$latch. Default = true.
    * @param p_stats      Enable statistics snapping. Default = true.
    */
   procedure init (
                    p_sid     in number :=userenv('SID')
                   ,p_latches in boolean:=true
                   ,p_stats   in boolean:=true
                  );
   /**
    * Snapping stats after next run test.
    */
   procedure snap (
                    p_header  in varchar2:=null
                  );

   /**
    * Print results.
    * @param p_latches_mask   Mask for filtering latches by name
    * @param p_stats_mask     Mask for filtering stats by name
    * @param p_lat_diff_pct   Print only latches with difference of gets between runs more or equal than specified percentage
    * @param p_sta_diff_pct   Print only stats with difference between runs more or equal than specified percentage
    */
   procedure print( p_latches_mask in varchar2 default '.'
                   ,p_stats_mask   in varchar2 default '.'
                   ,p_lat_diff_pct in number   default 5
                   ,p_sta_diff_pct in number   default 5
                  );
end xt_runstats;
/
create or replace package body xt_runstats
as

   cursor c_stats(p_sid in number) is
      select a.statistic#,a.name name, b.value
      from v$statname a
         , v$sesstat b
      where a.statistic# = b.statistic#
        and b.sid        = p_sid
      order by a.statistic#;

   cursor c_latches is
      select l.latch#,l.name, l.gets value
      from v$latch l
      order by l.latch#;

   type t_stats   is table of c_stats%rowtype   index by binary_integer;
   type t_latches is table of c_latches%rowtype index by binary_integer;

   type t_run_data is record(
                   stats   t_stats
                  ,latches t_latches
   );
   type t_runs is table of t_run_data
                   index by binary_integer;

   g_sid        number;
   g_start      number;
   g_runs_count int:=0;
   g_runs       t_runs;
   g_starts     sys.ku$_objnumset;
   g_headers    sys.ku$_vcnt;

   g_latches    boolean;
   g_stats      boolean;
   /* end declarations */

   /* procedures: */
   procedure init (
                    p_sid     in number :=userenv('SID')
                   ,p_latches in boolean:=true
                   ,p_stats   in boolean:=true
                  )
   is
   begin
      g_sid     := p_sid;
      g_latches := p_latches;
      g_stats   := p_stats;
      g_headers := sys.ku$_vcnt();
      if g_runs is not null then
         g_runs.delete;
      end if;
      if g_starts is not null then
         g_starts.delete;
      else
         g_starts:=sys.ku$_objnumset();
      end if;
      -- save:
      g_runs_count:=0;
      if g_stats then
         open c_stats(g_sid);
         fetch c_stats bulk collect into g_runs(g_runs_count).stats;
         close c_stats;
      end if;

      if g_latches then
         open c_latches;
         fetch c_latches bulk collect into g_runs(g_runs_count).latches;
         close c_latches;
      end if;
      g_start := dbms_utility.get_time;
   end;

   procedure snap( p_header  in varchar2:=null )
   is
   begin
      g_runs_count := g_runs_count + 1;
      g_headers.extend;
      g_headers(g_runs_count) := nvl(p_header,'Run #'||g_runs_count);
      g_starts.extend;
      g_starts(g_runs_count):=dbms_utility.get_time-g_start;

      if g_stats then
         open c_stats(g_sid);
         fetch c_stats bulk collect into g_runs(g_runs_count).stats;
         close c_stats;
      end if;

      if g_latches then
         open c_latches;
         fetch c_latches bulk collect into g_runs(g_runs_count).latches;
         close c_latches;
      end if;

      g_start :=dbms_utility.get_time;
   end;

   procedure print( p_latches_mask in varchar2 default '.'
                   ,p_stats_mask   in varchar2 default '.'
                   ,p_lat_diff_pct in number   default 5
                   ,p_sta_diff_pct in number   default 5
                  )
   is
      v_str        varchar2(32767);
      v_changed    boolean;
      v_delta_old  number;
      v_delta_cur  number;
      c_name_len   constant number       :=40;
      c_val_mask   constant varchar2(30) :='9,999,999,999';
      c_delim      constant varchar2(3)  :=' | ';
      c_tab_len    number:=80;

      /* table border */
      procedure hr is
      begin
        dbms_output.put_line(lpad('#',c_tab_len,'#'));
      end;

      /* print_header */
      procedure print_header(p_str in varchar2) is
         v_head varchar2(32767);
      begin
         v_head := rpad( p_str,c_name_len+1 ,' ');

         for i in 1..g_runs_count
         loop
            v_head:= v_head || c_delim
                            || rpad(g_headers(i),length(c_val_mask)+1,' ');
         end loop;
         c_tab_len := length(v_head);
         hr();
         dbms_output.put_line( v_head );
         hr();
      end;
     
      /* format_name */
      function format_name(p_str in varchar2) return varchar2
      is
      begin
         return rpad( p_str, c_name_len, '.');
      end;
      
      /* abs delta percents */
      function delta_pct(p1 number, p2 number) return number
      is
      begin
        return abs( 
                   (p2-p1)
                   /case p2 when 0 then 1 else p2 end
                  );
      end;
      
      /* print_latches */
      procedure print_latches is
      begin
         print_header(' Latches ');
         for i in 1..g_runs(0).latches.count
         loop
            v_changed:=false;
            v_str := format_name( g_runs(0).latches(i).name );
            if regexp_like(v_str,p_latches_mask)
            then-- start by mask:
               for j in 1..g_runs_count
               loop
                  v_delta_cur := g_runs( j ).latches(i).value
                               - g_runs(j-1).latches(i).value;
                  if g_runs_count=1
                     or (j>1 and p_lat_diff_pct/100 <= delta_pct(v_delta_old,v_delta_cur))
                  then
                     v_changed := true;
                  end if;
                  v_str :=   v_str
                          || c_delim
                          || to_char(
                                      v_delta_cur
                                     ,c_val_mask
                                    );
                  v_delta_old := v_delta_cur;
               end loop;
               if v_changed then
                  dbms_output.put_line(v_str);
               end if;
             end if;--end masking
         end loop;
         hr();
         dbms_output.put_line('- ');
      end;

      /* print_stats */
      procedure print_stats is
      begin
         print_header(' Statistics ');
         for i in 1..g_runs(0).stats.count
         loop
            v_changed:=false;
            v_str := format_name( g_runs(0).stats(i).name);
            if regexp_like(v_str,p_stats_mask,'i')
            then-- start by mask:
               for j in 1..g_runs_count
               loop
                  v_delta_cur := g_runs( j ).stats(i).value
                               - g_runs(j-1).stats(i).value;
                  if g_runs_count=1
                     or (j>1 and p_sta_diff_pct/100 <= delta_pct(v_delta_old,v_delta_cur))
                  then
                     v_changed := true;
                  end if;
                  v_str :=   v_str
                          || c_delim
                          || to_char(
                                      v_delta_cur
                                     ,c_val_mask
                                    );
                  v_delta_old := v_delta_cur;
               end loop;
               if v_changed then
                  dbms_output.put_line(v_str);
               end if;
             end if;--end masking
         end loop;
         hr();
         dbms_output.put_line('- ');
      end print_stats;
   /* print: main body */
   begin
      dbms_output.put_line('################     Results:      ##################');
      --dbms_output.enable(1000000);
      for i in 1..g_runs_count
      loop
         dbms_output.put_line
            ( 'Run #'||to_char(i,'909')||' ran in ' || g_starts(i) || ' hsecs ');
      end loop;

      if g_stats then
         print_stats;
      end if;

      if g_latches then
         print_latches;
      end if;
   end print;

end xt_runstats;
/
