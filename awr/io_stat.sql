col metric_name for a40;
col min for a14;
col max for a14;
col avg for a14;
SELECT metric_name,
  (CASE WHEN metric_name LIKE '%Bytes%' THEN TO_CHAR(ROUND(MIN(minval / 1024),1)) || ' KB' ELSE TO_CHAR(ROUND(MIN(minval),1)) END) min,
  (CASE WHEN metric_name LIKE '%Bytes%' THEN TO_CHAR(ROUND(MAX(maxval / 1024),1)) || ' KB' ELSE TO_CHAR(ROUND(MAX(maxval),1)) END) max,
  (CASE WHEN metric_name LIKE '%Bytes%' THEN TO_CHAR(ROUND(AVG(average / 1024),1)) || ' KB' ELSE TO_CHAR(ROUND(AVG(average),1)) END) avg
FROM dba_hist_sysmetric_summary
WHERE metric_name
  IN (
  'Physical Read Total IO Requests Per Sec',
  'Physical Write Total IO Requests Per Sec',
  'Physical Read Total Bytes Per Sec',
  'Physical Write Total Bytes Per Sec')
GROUP BY metric_name
ORDER BY metric_name;
col metric_name clear;
col min clear;
col max clear;
col avg clear;
