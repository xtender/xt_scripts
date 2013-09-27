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
begin
   DBMS_STATS.get_column_stats ('&tab_owner',
                                '&tab_name',
                                '&col_name',
                                distcnt      => n_distcnt,
                                density      => n_density,
                                nullcnt      => n_nullcnt,
                                srec         => rec_srec,
                                avgclen      => n_avgclen
                               );
   n_distcnt:=2670507;
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
end;
/
