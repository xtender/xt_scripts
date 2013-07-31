col filetype_name 	format a40 heading "File Type"
col reads 			format 999,999,999 heading "Reads"
col writes 			format 999,999,999 heading "Writes"
col read_time_sec 	format 999,999 heading "Read Time|sec"
col write_time_sec 	format 999,999 heading "Write Time|sec"
col avg_sync_read_ms format 999.99 heading "Avg Sync|Read ms"
col total_io_seconds format 999,999,999 heading "Total IO|sec"

WITH iostat_file AS 
  (SELECT filetype_name,SUM(large_read_reqs) large_read_reqs,
          SUM(large_read_servicetime) large_read_servicetime,
          SUM(large_write_reqs) large_write_reqs,
          SUM(large_write_servicetime) large_write_servicetime,
          SUM(small_read_reqs) small_read_reqs,
          SUM(small_read_servicetime) small_read_servicetime,
          SUM(small_sync_read_latency) small_sync_read_latency,
          SUM(small_sync_read_reqs) small_sync_read_reqs,
          SUM(small_write_reqs) small_write_reqs,
          SUM(small_write_servicetime) small_write_servicetime
     FROM sys.v_$iostat_file
    GROUP BY filetype_name)
SELECT filetype_name, small_read_reqs + large_read_reqs reads,
       large_write_reqs + small_write_reqs writes,
       ROUND((small_read_servicetime + large_read_servicetime)/1000) 
          read_time_sec,
       ROUND((small_write_servicetime + large_write_servicetime)/1000) 
          write_time_sec,
       CASE WHEN small_sync_read_reqs > 0 THEN 
          ROUND(small_sync_read_latency / small_sync_read_reqs, 2) 
       END avg_sync_read_ms,
       ROUND((  small_read_servicetime+large_read_servicetime
              + small_write_servicetime + large_write_servicetime)
             / 1000, 2)  total_io_seconds
  FROM iostat_file
 ORDER BY 7 DESC; 