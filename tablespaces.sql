SELECT /* + RULE */  
       df.tablespace_name                                       "Tablespace",
       df.bytes / (1024 * 1024)                                 "Size (MB)",
       SUM(fs.bytes) / (1024 * 1024)                            "Free (MB)",
       Nvl(Round(SUM(fs.bytes) * 100 / df.bytes),1)             "% Free",
       Round((df.bytes - SUM(fs.bytes)) * 100 / df.bytes)       "% Used"
  FROM dba_free_space fs,
       (SELECT tablespace_name,SUM(bytes) bytes
          FROM dba_data_files
         GROUP BY tablespace_name) df
 WHERE fs.tablespace_name (+)  = df.tablespace_name
 GROUP BY df.tablespace_name,df.bytes
UNION ALL
SELECT /* + RULE */ 
       df.tablespace_name                                       tspace,
       fs.bytes / (1024 * 1024),
       SUM(df.bytes_free) / (1024 * 1024),
       Nvl(Round((SUM(fs.bytes) - df.bytes_used) * 100 / fs.bytes), 1),
       Round((SUM(fs.bytes) - df.bytes_free) * 100 / fs.bytes)
  FROM dba_temp_files fs,
       (SELECT tablespace_name,bytes_free,bytes_used
          FROM v$temp_space_header
         GROUP BY tablespace_name,bytes_free,bytes_used) df
 WHERE fs.tablespace_name (+)  = df.tablespace_name
 GROUP BY df.tablespace_name,fs.bytes,df.bytes_free,df.bytes_used
 ORDER BY 1;