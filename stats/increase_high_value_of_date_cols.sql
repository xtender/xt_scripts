accept tab_owner - 
		prompt 'Enter value for tab_owner[&_USER]: ' -
		default '&_USER';

accept tab_name - 
		prompt 'Enter value for tab_name: ';

accept col_name - 
		prompt 'Enter value for col_name: ';

accept months_count - 
		prompt 'Enter value for months_count: ';


DECLARE
   n_distcnt          NUMBER;
   n_density          NUMBER;
   n_nullcnt          NUMBER;
   rec_srec           DBMS_STATS.statrec;
   datevals           DBMS_STATS.DATEARRAY;
   n_avgclen          NUMBER;
   d_low              DATE;
   d_high             DATE;
   r_low              RAW(4000);
   r_high             RAW(4000);
   /* functions for cast raw */
   function raw_to_num(i_raw raw)
   return varchar2
   as
      m_n number;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   exception when others then return 'ERROR:'||sqlerrm;
   end;
     
   function raw_to_date(i_raw raw)
   return date
   as
      m_n date;
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
     
   function raw_to_varchar2(i_raw raw)
   return varchar2
   as
      m_n varchar2(4000);
   begin
      dbms_stats.convert_raw_value(i_raw,m_n);
      return m_n;
   end;
   /* end functions */
BEGIN
   DBMS_STATS.get_column_stats ('&tab_owner',
                                '&tab_name',
                                '&col_name',
                                distcnt      => n_distcnt,
                                density      => n_density,
                                nullcnt      => n_nullcnt,
                                srec         => rec_srec,
                                avgclen      => n_avgclen
                               );
    
   --handles just the case when HISTOGRAMS are not set -> rec_srec.epc = 2
   IF rec_srec.epc = 2 THEN
     SELECT low_value, high_value
        INTO r_low,r_high
        FROM dba_tab_col_statistics s
      WHERE 
            s.owner       = '&tab_owner'
        and s.table_name  = '&tab_name' 
        AND s.column_name = '&col_name';
     
     d_low := raw_to_date(r_low);
     d_high:= raw_to_date(r_high);
     
     d_high := ADD_MONTHS(d_high, &months_count);
     datevals := DBMS_STATS.DATEARRAY(d_low, d_high);
     rec_srec.minval:=NULL;
     rec_srec.maxval:=NULL;
     rec_srec.bkvals:=NULL;
     rec_srec.novals:=NULL;
      
     --this procedure will set epc.minval, epc.maxval etc in INTERNAL FORMAT
     DBMS_STATS.PREPARE_COLUMN_VALUES(rec_srec, datevals);
      
     --and then just set statistics
     DBMS_STATS.set_column_stats ('&tab_owner',
                                  '&tab_name',
                                  '&col_name',
                                  distcnt      => n_distcnt,
                                  density      => n_density,
                                  nullcnt      => n_nullcnt,
                                  srec         => rec_srec,
                                  avgclen      => n_avgclen,
                                  force        => true
                                  );
   ELSE
     raise_application_error(-20001,'!!!!! There are more than 1 bucket !!!!!!');
   END IF;   
END;
/
undef tab_owner;
undef tab_name;
undef col_name;
undef months_count;
