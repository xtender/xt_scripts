create or replace package SQLFormatter as

  FUNCTION Format(str in varchar2) RETURN VARCHAR2
  AS LANGUAGE JAVA NAME 'SQLFormatter.format(java.lang.String) return java.lang.String';

  FUNCTION FormatClob(str in clob) RETURN CLOB
  AS LANGUAGE JAVA NAME 'SQLFormatter.formatClob(oracle.sql.CLOB) return oracle.sql.CLOB';
  
end;
/