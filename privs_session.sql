select 
   row_number()over(order by privilege) n
 , s.* 
from session_privs s
order by privilege;