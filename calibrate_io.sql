set serverout on
DECLARE
   lat INTEGER;
   iops INTEGER;
   mbps INTEGER;
BEGIN
   --DBMS_RESOURCE_MANAGER.CALIBRATE_IO(, ,iops, mbps, lat);
   DBMS_RESOURCE_MANAGER.CALIBRATE_IO (28, 10, iops, mbps, lat);
   DBMS_OUTPUT.PUT_LINE ('max_iops = ' || iops);
   DBMS_OUTPUT.PUT_LINE ('latency = ' || lat);
   DBMS_OUTPUT.PUT_LINE ('max_mbps = ' || mbps);
end;
/
set sererout off;
select * from V$IO_CALIBRATION_STATUS;
