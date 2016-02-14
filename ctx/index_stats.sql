var report clob;
declare
  tlob clob;
begin
  ctx_report.index_stats(
      index_name    => '&INDEX_NAME'
    , report        => tlob
    , list_size     => 20
    , report_format => 'TEXT'
  );
  :report := tlob;
end;
/
print report;
