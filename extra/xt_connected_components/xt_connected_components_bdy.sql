create or replace package body XT_CONNECTED_COMPONENTS is

   type numbers_a_array is table of number index by pls_integer;
   type strings_a_array is table of varchar2(v_size) index by varchar2(v_size);

   type num_elems    is table of numbers index by varchar2(v_size);
   type str_elems    is table of strings index by varchar2(v_size);

   function get_strings(cur in sys_refcursor, delim varchar2:=',') return strings_array pipelined is
      root              strings_a_array;
      root_elems        str_elems;

      idx               varchar2(v_size);
      temp              strings;
       $IF $$DEBUG $THEN
          l integer:=dbms_utility.get_time();
       $END
          procedure print(v in varchar2) is
          begin
            $IF $$DEBUG $THEN
            dbms_output.put_line(to_char((dbms_utility.get_time-l)/100,'0999.99')||' '||v);
            l:=dbms_utility.get_time();
            $ELSE
            null;
            $END
          end;
      
      function get_root(n varchar2) return varchar2 is
      begin
         if root.exists(n) then 
            return root(n);
         else 
            return null;
         end if;
      end;
      
      procedure update_root(old_root varchar2,new_root varchar2) is
         i pls_integer;
      begin
         if old_root!=new_root then 
            root_elems(new_root):=root_elems(new_root) multiset union all root_elems(old_root);
            for i in 1..root_elems(old_root).count
            loop
               root(root_elems(old_root)(i)):=new_root;
            end loop;
            root_elems(old_root).delete;
          end if;
      end;
      
      procedure add_elem(p_root varchar2, p_elem varchar2) is
      begin
         if not root_elems.exists(p_root) then
            dbms_output.put_line(p_root||':'||p_elem);
            root_elems(p_root):=strings(p_elem);
         else
            root_elems(p_root).extend();
            root_elems(p_root)(root_elems(p_root).count):=p_elem;
         end if;
      end;
      
      procedure add_link(p varchar2,q varchar2) is
         r1       varchar2(v_size);
         r2       varchar2(v_size);
         new_root varchar2(v_size);
         old_root varchar2(v_size);
      begin
         if p is null or q is null then 
            add_elem(nvl(p,q),nvl(p,q)); 
            return;
         end if;
         r1:=get_root(p);
         r2:=get_root(q);
         
         if r1=r2 then 
            return;
         elsif r1 is null or r2 is null then
            new_root := coalesce(r1,r2,p);
            if r1 is null then add_elem(new_root,p); root(p):=new_root; end if;
            if r2 is null then add_elem(new_root,q); root(q):=new_root; end if;
         else
            case when root_elems(r1).count > root_elems(r2).count 
                    then new_root:=r1; old_root:=r2;
                    else new_root:=r2; old_root:=r1;
            end case;
            root(p) :=new_root;
            root(q) :=new_root;
            update_root(old_root,new_root);
         end if;
         
      end;

   begin
      print('start');
      loop
         fetch cur bulk collect into temp limit fetch_size;
         for i in 1..temp.count loop
            declare
               p_str varchar2(v_size):=temp(i)||delim;
               p varchar2(v_size);
               q varchar2(v_size);
               v_instr int:=0;
            begin
               v_instr:=instr(p_str,delim,v_instr+1);
               p:=substr(p_str,1,v_instr-length(delim));
               p_str:=substr(p_str,v_instr+length(delim));
               loop
                  v_instr:=instr(p_str,delim);
                  q:=substr(p_str,1,v_instr-1);
                  add_link(p, q);
                  p_str:=substr(p_str,v_instr+length(delim));
                  exit when p_str is null;
               end loop;
            end;
            dbms_session.free_unused_user_memory;
         end loop;
         
         exit when cur%notfound;
      end loop;
      print('processed');
      
      -- return results:
      idx:= root_elems.first();
      while idx is not null loop
         if root_elems(idx).count>0 then
            pipe row (root_elems(idx));
         end if;
         idx:=root_elems.next(idx);
      end loop;
      return;
   end get_strings;

   function get_numbers(cur in sys_refcursor) return numbers_array pipelined is
      root              numbers_a_array;
      root_elems        num_elems;
      idx               number;
      temp1             numbers;
      temp2             numbers;

       $IF $$DEBUG $THEN
          l integer:=dbms_utility.get_time();
       $END
          procedure print(v in varchar2) is
          begin
            $IF $$DEBUG $THEN
            dbms_output.put_line(to_char((dbms_utility.get_time-l)/100,'0999.99')||' '||v);
            l:=dbms_utility.get_time();
            $ELSE
            null;
            $END
          end;
      
      function get_root(n number) return varchar2 is
      begin
         if root.exists(n) then 
            return root(n);
         else 
            return null;
         end if;
      end;
      
      procedure update_root(old_root number,new_root number) is
         i pls_integer;
      begin
         if old_root!=new_root then 
            root_elems(new_root):=root_elems(new_root) multiset union all root_elems(old_root);
            for i in 1..root_elems(old_root).count
            loop
               root(root_elems(old_root)(i)):=new_root;
            end loop;
            root_elems(old_root).delete;
          end if;
      end;
      
      procedure add_elem(p_root number, p_elem number) is
      begin
         if not root_elems.exists(p_root) then
            dbms_output.put_line(p_root||':'||p_elem);
            root_elems(p_root):=numbers(p_elem);
         else
            root_elems(p_root).extend();
            root_elems(p_root)(root_elems(p_root).count):=p_elem;
         end if;
      end;
      
      procedure add_link(p number,q number) is
         r1       varchar2(v_size);
         r2       varchar2(v_size);
         new_root varchar2(v_size);
         old_root varchar2(v_size);
      begin
         if p is null or q is null then 
            add_elem(nvl(p,q),nvl(p,q)); 
            return;
         end if;
         r1:=get_root(p);
         r2:=get_root(q);
         
         if r1=r2 then 
            return;
         elsif r1 is null or r2 is null then
            new_root := coalesce(r1,r2,p);
            if r1 is null then add_elem(new_root,p); root(p):=new_root; end if;
            if r2 is null then add_elem(new_root,q); root(q):=new_root; end if;
         else
            case when root_elems(r1).count > root_elems(r2).count 
                    then new_root:=r1; old_root:=r2;
                    else new_root:=r2; old_root:=r1;
            end case;
            root(p) :=new_root;
            root(q) :=new_root;
            update_root(old_root,new_root);
         end if;
         
      end;

   begin
      print('start');
      loop
         fetch cur bulk collect into temp1, temp2 limit fetch_size;
         for i in 1..temp1.count loop
             add_link(temp1(i), temp2(i));
         end loop;
         dbms_session.free_unused_user_memory;
         exit when cur%notfound;
      end loop;
      print('processed');
      
      -- return results:
      idx:= root_elems.first();
      while idx is not null loop
         if root_elems(idx).count>0 then
            pipe row (root_elems(idx));
         end if;
         idx:=root_elems.next(idx);
      end loop;
      return;
   end get_numbers;
end XT_CONNECTED_COMPONENTS;
/