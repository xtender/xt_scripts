create table kkpap_pruning
(
   operation_id number
  ,it_type varchar(5)
     --CONSTRAINT check_it_type 
     --   CHECK (it_type in ('RANGE', 'ARRAY'))
  ,it_level varchar(15)
     --CONSTRAINT check_it_level
     --   CHECK (it_level in ('PARTITION', 'SUBPARTITION', 'ABSOLUTE'))
  ,it_order varchar(10)
     --CONSTRAINT check_it_order 
     --   CHECK (it_order in ('ASCENDING', 'DESCENDING'))
  ,it_call_time varchar(10)
     --CONSTRAINT check_it_call_time
     --   CHECK (it_call_time in ('COMPILE', 'START', 'RUN'))
  ,pnum number
  ,spnum number
  ,apnum number
);