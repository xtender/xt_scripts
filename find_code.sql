accept _OWNER_MASK default '%'  prompt "Owner mask[default %]: "
accept _CODE       default ''   prompt "Code: "
accept _CASESENS   default 'NO' prompt "Casesensitive[yes/no, default=no]: "

def _IF_CASESENS="--"
def _IF_INCASESENS=""
col _IF_CASESENS   new_value _IF_CASESENS      noprint
col _IF_INCASESENS new_value _IF_INCASESENS    noprint
col text format a400
col owner for a25
select decode(upper('&_CASESENS'),'YES','','--') "_IF_CASESENS"
      ,decode(upper('&_CASESENS'),'YES','--','') "_IF_INCASESENS"
from dual;

select 
  *
from dba_source s
where
    s.owner like upper('&_OWNER_MASK')
&_IF_CASESENS   and s.text like '%&_CODE%'
&_IF_INCASESENS and upper(s.text) like upper('%&_CODE%')
/