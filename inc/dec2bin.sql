create or replace function dec2bin (n number, split_count int default 4,min_bits int default 8) 
   return varchar2 deterministic 
is
   type bin_tab is table of number(1,0);
   binval bin_tab:=bin_tab();
   i      int;
   res    varchar(4000);
BEGIN
  i:= n;
  
  if i< 0 then
     dbms_standard.raise_application_error(-6502,q'[DEC2BIN doesn't supports negative integers]');
  end if;
  
  while ( i > 0 ) loop
     binval.extend;
     binval(binval.count) := mod(i, 2);
     i := floor( i / 2 );
  end loop;
  
  for j in binval.count+1..greatest(min_bits, split_count, 4*ceil(binval.count/4)) loop
     binval.extend;
     binval(binval.count):=0;
  end loop;
  
  for j in 1.. binval.count loop
     res:=to_char(binval(j),'fm0')||res;
     if mod(j,split_count)=0 then 
        res:=' '||res;
     end if;
  end loop;
     
  return ltrim(res,' ');
end dec2bin;
/
