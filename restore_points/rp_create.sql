accept rp prompt "Enter restore point name: "

create restore point &rp guarantee flashback database;

select FLASHBACK_ON from v$database;
prompt * Should not be "NO"
@@rp_list;
