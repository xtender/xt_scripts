create or replace package PKG_RTSM is
  
  function base64_to_blob(p_clob in clob) return blob;
  
  function base64_rtsm_to_xml(p_base64_clob in clob) return clob;
  
  function blob_to_clob(p_blob blob) return clob;
  
  function find_substring_clob(p_clob in clob, p_beg in varchar2, p_end in varchar2, p_including in varchar2 default 'Y') return clob;
  
  function rtsm_html_to_xml(p_blob in blob) return clob;
  
  PROCEDURE zlib_inflate_blob(
      p_src IN BLOB, 
      p_dst IN OUT BLOB
  ) AS LANGUAGE JAVA 
  NAME 'ZlibHelper.inflate(oracle.sql.BLOB, oracle.sql.BLOB[])';
    
end PKG_RTSM;
/
create or replace package body PKG_RTSM is

  function base64_to_blob(p_clob in clob) return blob
  is
      l_blob        BLOB;
      l_raw         RAW(32767);
      l_buffer      VARCHAR2(32767);
      l_chunk_size  INTEGER := 2400; 
      l_offset      INTEGER := 1;
      l_len         INTEGER;
      v_clob        clob;
  BEGIN
      DBMS_LOB.CREATETEMPORARY(l_blob, TRUE);
        
      v_clob:=REPLACE(REPLACE(REPLACE(p_clob, CHR(10)), CHR(13)), ' ', '');
      l_len := DBMS_LOB.GETLENGTH(v_clob);
        
      WHILE l_offset < l_len LOOP
          l_buffer := DBMS_LOB.SUBSTR(v_clob, l_chunk_size, l_offset);
          IF LENGTH(l_buffer) > 0 THEN
              l_raw := UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(l_buffer));
              DBMS_LOB.WRITEAPPEND(l_blob, UTL_RAW.LENGTH(l_raw), l_raw);
          END IF;
          l_offset := l_offset + l_chunk_size;
      END LOOP;
      RETURN l_blob;
  END;

  function base64_rtsm_to_xml(p_base64_clob in clob) return clob 
  is
      l_compressed_blob BLOB;
      l_decompressed_blob BLOB;
      l_xml_result      CLOB;
      -- temp vars:
      l_dest_offset INTEGER := 1;
      l_src_offset  INTEGER := 1;
      l_lang_ctx    INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
      l_warning     INTEGER;  
  BEGIN
      -- 1. Base64 >> BLOB (still ZLIB)
      l_compressed_blob := pkg_rtsm.base64_to_blob(p_base64_clob);
      
      -- 2. BLOB for results
      DBMS_LOB.CREATETEMPORARY(l_decompressed_blob, TRUE);
      
      -- 3. Calling Java inflater, which is working with wbits=15 - standard for Java Inflater.
      PKG_RTSM.zlib_inflate_blob(l_compressed_blob, l_decompressed_blob);
      
      -- 4. BLOB to CLOB (XML)
      DBMS_LOB.CREATETEMPORARY(l_xml_result, TRUE);
      DBMS_LOB.CONVERTTOCLOB(
          dest_lob     => l_xml_result,
          src_blob     => l_decompressed_blob,
          amount       => DBMS_LOB.LOBMAXSIZE,
          dest_offset  => l_dest_offset,
          src_offset   => l_src_offset,
          blob_csid    => DBMS_LOB.DEFAULT_CSID,
          lang_context => l_lang_ctx,
          warning      => l_warning
      );
      
      DBMS_LOB.FREETEMPORARY(l_compressed_blob);
      DBMS_LOB.FREETEMPORARY(l_decompressed_blob);
      
      return l_xml_result;
  END;
  
  function blob_to_clob(p_blob blob) return clob
  is
    l_clob   CLOB;
    dest_offset    INTEGER := 1;
    src_offset     INTEGER := 1;
    lang_context   INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
    warning        INTEGER;
  BEGIN
    DBMS_LOB.CREATETEMPORARY(l_clob, TRUE);
    DBMS_LOB.CONVERTTOCLOB (
      dest_lob     => l_clob,
      src_blob     => p_blob,
      amount       => DBMS_LOB.LOBMAXSIZE,
      dest_offset  => dest_offset,
      src_offset   => src_offset,
      blob_csid    => 871,                       -- 871 = AL32UTF8
      lang_context => lang_context,
      warning      => warning
    );
    return l_clob;
  END blob_to_clob;

  function find_substring_clob(p_clob in clob, p_beg in varchar2, p_end in varchar2, p_including in varchar2 default 'Y') return clob
  is
  begin
    if p_including='Y' then
      return DBMS_LOB.SUBSTR(
             p_clob
            ,INSTR(p_clob, p_end) + LENGTH(p_end) - INSTR(p_clob, p_beg)
            ,INSTR(p_clob, p_beg)
           );
    else
      return DBMS_LOB.SUBSTR(
             p_clob
            ,INSTR(p_clob, p_end) - INSTR(p_clob, p_beg) - LENGTH(p_beg)
            ,INSTR(p_clob, p_beg) + LENGTH(p_beg)
           );
    end if;
  end find_substring_clob;
  
  function rtsm_html_to_xml(p_blob in blob) return clob
  is
    v_clob       clob;
    v_prefix     clob;
    v_xml_base64 clob;
    v_xml        clob;
    v_result clob;
  begin
    v_clob       := pkg_rtsm.blob_to_clob(p_blob);
    v_prefix     := pkg_rtsm.find_substring_clob(v_clob,'<report'     ,'</report_id>','Y');
    v_prefix     := replace(v_prefix, 'encode="base64" compress="zlib"', '');
    v_xml_base64 := pkg_rtsm.find_substring_clob(v_clob,'</report_id>','</report>'   ,'N');
    v_xml        := pkg_rtsm.base64_rtsm_to_xml(v_xml_base64);
    v_result := v_prefix || v_xml || '</report>';
    return v_result;
  end rtsm_html_to_xml;
  
end PKG_RTSM;
/
