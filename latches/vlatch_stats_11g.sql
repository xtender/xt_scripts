/*
     This file is part of demos for "Latch Mutex and beyond blog"
     Andrey S. Nikolaev (Andrey.Nikolaev@rdtex.ru)
 
http://AndreyNikolaev.wordpress.com
 
     Compute the latch statistics
     For Oracle versions 11g:
 
     @latch_stats_11g ADDRESS
*/
set verify off
select name from v$latch where addr='&1'
union all
select name from v$latch_children where addr='&1';
SET SERVEROUTPUT ON
set timing on
 
DECLARE
   i number;
   Samples  number:= 300;
   SampleFreq number:= 1 / 10;   -- Hz;
   Nw   NUMBER;
   laddr raw(8);
 cursor lstat(laddr_ raw) is   /* latch statistics */
    select kslltnum LATCH#,kslltwgt GETS, kslltwff MISSES,kslltwsl SLEEPS,ksllthst0  SPIN_GETS,kslltwtt  latch_wait_time, kslltcnm child#
    from vx$kslltr_children where kslltaddr=hextoraw(laddr_)
    union all
    select kslltnum LATCH#,kslltwgt GETS,kslltwff MISSES,kslltwsl SLEEPS,ksllthst0  SPIN_GETS,kslltwtt  latch_wait_time, 0 child#
    from vx$kslltr_parent where kslltaddr=hextoraw(laddr_);
   Lstat1 lstat%ROWTYPE;
   Lstat2 lstat%ROWTYPE;
   dgets number;
   dmisses number;
   rho number;
   eta number;
   lambda number;
   kappa number;
   W number;
   sigma number;
   error_ varchar2(100):='';
   lname varchar2(100);
   level_ number;
   dtime number;
   U number :=0;
   ssleeps number;
   S number;
   params varchar2(2000):='';
BEGIN
   laddr := HEXTORAW ('&1');
/*     CPU count */
   select value into Nw from v$parameter where name = 'cpu_count';
   if Nw != 1 then
      eta:= Nw/(Nw-1);
   else
      eta:=1;
      Error_ := Error_||' Single CPU configuration ';
   end if;
   Nw := 0;
/*     Beginning latch statistics */
   dtime := DBMS_UTILITY.GET_TIME();
   OPEN Lstat(laddr);
   FETCH Lstat into Lstat1;
   if Lstat%NOTFOUND then
       raise_application_error(-20001,'No latch at 0x'||laddr);
   end if;
   CLOSE Lstat;
/*     Sampling */
   FOR i IN 1 .. Samples
   LOOP
                /*   number of pocesses waiting for the latch */
       for Sample in (SELECT  count(decode(ksllawat,'00',null,1)) wat  FROM vx$ksupr
                   WHERE ksllawat=laddr)
        LOOP
          Nw := Nw + Sample.wat;
        END LOOP;
              /*    Is latch busy  */
       for Hold in (select 1 hold from vx$ksuprlat where ksuprlat=laddr)
       loop
          U:=U+1;
          exit;
       end loop;
         
     DBMS_LOCK.sleep (SampleFreq);
   END LOOP;
/*     End latch statistics */
   OPEN Lstat(laddr);
   FETCH Lstat into Lstat2;
   CLOSE Lstat;
   dtime:=(DBMS_UTILITY.GET_TIME()-dtime)*0.01; /* delta time in seconds */
/*     Compute derived statistics */
   dgets  := (lstat2.gets-lstat1.gets);
   dmisses:= (lstat2.misses-lstat1.misses);
     if(dgets>0)then rho := dmisses/dgets;
     else
       raise_application_error(-20002,'No gets activity for this latch');
     end if;
   Nw:=Nw/Samples;
   U:=U/Samples;
   lambda:=dgets/dtime;
   W:= (lstat2.latch_wait_time-lstat1.latch_wait_time)/dtime*1.E-6;    /* wait time in seconds */
   select kslldnam,kslldlvl into lname,level_ from vx$kslld where indx=lstat2.latch#;
   /* S:=eta*rho/lambda; */
   S:=U/lambda;
   if(dmisses>0) then
          kappa:=(lstat2.sleeps-lstat1.sleeps)/dmisses;
          sigma:=(lstat2.spin_gets-lstat1.spin_gets)/dmisses;
   else
          error_ := Error_||' Delta MISSES='||dmisses;
          kappa:=null;
          sigma:=null;
   end if;
   if(kappa>0) then  
          ssleeps:=(kappa+sigma-1)/kappa;
   else
          error_ := Error_||'  Sigma='||sigma;
          ssleeps:=null;
   end if;
 
   if(length(Error_)>0 ) then
      DBMS_OUTPUT.put_LINE (' Error: '||error_);
   end if;
   DBMS_OUTPUT.put_LINE (chr(10)||'Latch statistics  for  0x'||laddr||'   "'||lname||'"  level#='||level_||'   child#='||lstat2.child#);
   DBMS_OUTPUT.put_LINE ('Requests rate:       lambda=' || to_char(lambda,'999999.9')||' Hz');
   DBMS_OUTPUT.put_LINE ('Miss /get:              rho=' || to_char(rho,'9.999999'));
   DBMS_OUTPUT.put_LINE ('Est. Utilization:   eta*rho=' || to_char(eta*rho,'9.999999'));
   DBMS_OUTPUT.put_LINE ('Sampled   Utilization:    U='||to_char(U,'9.999999'));
   DBMS_OUTPUT.put_LINE ('Slps /Miss:      kappa=' || to_char(kappa,'9.999999'));
   DBMS_OUTPUT.put_LINE ('Wait_time/sec:       W=' || to_char(W,'999.999999'));
   DBMS_OUTPUT.put_LINE ('Sampled queue length L=' || to_char(Nw,'999.999999'));
   DBMS_OUTPUT.put_LINE ('Spin_gets/miss:  sigma=' || to_char(sigma,'9.999999'));
   DBMS_OUTPUT.put_LINE (chr(10)||'Derived statistics:');
   DBMS_OUTPUT.put_LINE ('Secondary sleeps ratio =' || to_char(ssleeps,'9.99EEEE'));
   DBMS_OUTPUT.put_LINE ('Avg latch holding time =' || to_char(S*1000000,'999999.9')||' us');
   DBMS_OUTPUT.put_LINE ('.        sleeping time =' || to_char(W/lambda*1000000,'999999.9')||' us');
   DBMS_OUTPUT.put_LINE ('.  avg latch free wait =' || to_char(W/(kappa*rho*lambda)*1000000,'999999.9')||' us');
   DBMS_OUTPUT.put_LINE ('.             miss rate=' || to_char(rho*lambda,'999999.9')||' Hz');
   DBMS_OUTPUT.put_LINE ('.           waits rate =' || to_char(kappa*rho*lambda,'999999.9')||' Hz');
   DBMS_OUTPUT.put_LINE ('.   spin inefficiency k=' || to_char(kappa/(1+kappa*rho),'9.999999'));
         /* latch parameters */
   for Param in (select  ksppinm,ksppstvl from vx$ksppi x  join vx$ksppcv using (indx )
               where ksppinm like  '\_latch\_class%' ESCAPE '\' or ksppinm in
                   ('_spin_count','_enable_reliable_latch_waits','_latch_miss_stat_sid','_ultrafast_latch_statistics')
                order by ksppinm)
   loop
        params:=params||Param.ksppinm||'='||Param.ksppstvl||' ';
   end loop;
   DBMS_OUTPUT.put_LINE (chr(10) ||'Latch related parameters:'||chr(10) || params);
EXCEPTION
 when others then
      DBMS_OUTPUT.put_LINE (chr(10)||'Error raised:'||SQLERRM);
      DBMS_OUTPUT.put_LINE (DBMS_UTILITY.FORMAT_CALL_STACK);
      DBMS_OUTPUT.put_LINE ('----- '||chr(10)||'LADDR= 0x'||rawtohex(laddr)||' dtime='||dtime||' Nw= '||Nw||' U='||U);
      DBMS_OUTPUT.put_LINE ('gets='||lstat2.gets||'-'||lstat1.gets||'='||dgets||' misses='||lstat2.misses||'-'||lstat1.misses||'='||dmisses);
      DBMS_OUTPUT.put_LINE ('sleeps='||lstat2.sleeps||'-'||lstat1.sleeps||'='||(lstat2.sleeps-lstat1.sleeps)||
        ' spin_gets='||lstat2.spin_gets||'-'||lstat1.spin_gets||'='||(lstat2.spin_gets-lstat1.spin_gets));
      DBMS_OUTPUT.put_LINE ('rho='||rho||' lambda='||lambda||' kappa= '||kappa||' sigma='||sigma);
END;
/