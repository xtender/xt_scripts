col metric for a45;
col value for a15;
SELECT inst_id,
  intsize_csec / 100 "Interval (Secs)",
  metric_name "Metric",
  (
  CASE
    WHEN metric_name LIKE '%Bytes%'
    THEN TO_CHAR(ROUND(AVG(value / 1024 ),1))
      || 'KB'
    ELSE TO_CHAR(ROUND(AVG(value),1))
  END) "Value"
FROM gv$sysmetric
WHERE metric_name IN ('Physical Read Total IO Requests Per Sec', 'Physical Write Total IO Requests Per Sec', 'Physical Read Total Bytes Per Sec', 'Physical Write Total Bytes Per Sec')
GROUP BY inst_id,
  intsize_csec,
  metric_name
ORDER BY inst_id,
  intsize_csec,
  metric_name;
col metric clear;
