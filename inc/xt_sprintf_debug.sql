create or replace function xt_sprintf(sformat varchar2, params sys.ku$_vcnt, align varchar2 default 'LEFT')
       return varchar2
as
   str   varchar2(4000);
   sparams sys.ku$_vcnt;
   smask varchar2(10);
   slen  int;
   val   varchar2(4000);
   cnt   int;
   i     int;
   spos  int:=1;
   procedure debug(msg varchar2) is
   begin
      $IF $$DEBUG $THEN
         dbms_output.put_line(msg);
      $ELSE
         null;
      $END
   end debug;
   
   function f_align(plen int, pval varchar2) return varchar2 is
   begin
      if slen is null or length(sparams(i)) > slen then
         return nvl(pval,' ');
      else
         case upper(align)
            when 'LEFT'   then return rpad(nvl(pval,' '),plen);
            when 'RIGHT'  then return lpad(nvl(pval,' '),plen);
            when 'CENTER' then return rpad(nvl(pval,' '),plen);
         end case;
      end if;
   end f_align;
      
begin
   str := sformat;
   if upper(align) not in ('LEFT','RIGHT','CENTER') then
      raise_application_error(-20001,'Valid values for align: "LEFT","RIGHT","CENTER"');
   end if;
   sparams := case 
                when params is not null 
                   then params 
                else sys.ku$_vcnt()
              end;
   cnt := least( nvl(regexp_count(str,'%\d*s'),0), sparams.count);
   spos := 1;
   i := 1;
   debug('--------'||sformat);
   debug('--------'||cnt);
   loop
      debug(' ------ i = '|| i || ' ------ ');
      debug(' str before = "'||str||'"');
      spos  := regexp_instr (str,'%\d*s', spos);
      exit when i> cnt or spos = 0 ;
      smask := regexp_substr(str,'%\d*s', spos);
      debug('smask = '||smask);

      slen  := regexp_substr(smask,'%(\d*)s',1,1,null,1);
      debug('slen = '||slen);
      val := f_align(slen,sparams(i));
      debug('val = '||val);
      str   := regexp_replace( str, smask, val, spos, 1);
      spos  := spos+length(val);
      debug('pos = '||spos);
      debug(' str after = "'||str||'"');
      i     := i+1;
   end loop;
   return str;
end xt_sprintf;
/
