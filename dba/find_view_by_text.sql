begin
  for v in ( select *
             from dba_views v
             where v.owner='&OWNER'
           )
  loop
    if v.text like '%&TEXT%' then
      --dbms_output.put_line(v.view_name||': '||v.text);
      dbms_output.put_line(v.view_name);
    end if;
  end loop;
end;
