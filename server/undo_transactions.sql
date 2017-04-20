select state,
undoblocksdone,
undoblockstotal,
undoblocksdone / undoblockstotal * 100
from v$fast_start_transactions
/
