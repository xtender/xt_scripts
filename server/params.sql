@param cpu_count
@param multiblock
col sname format a30;
col pname format a12;
col pval  format a30 justify center;
select sname
      ,pname
      ,lpad(
        trim(
          coalesce(
             case when pval1=round(pval1) 
                    then to_char(round(pval1,3),'9999999')
                    else to_char(round(pval1,3),'9999999.999')
             end
            ,pval2)
        )
       ,30,' '
       ) pval
from sys.aux_stats$;
col sname clear;
col pname clear;
col pval  clear;
