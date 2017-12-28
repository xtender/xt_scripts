create or replace package xt_unwrapper
is
  function deflate( src in varchar2 )
  return raw;
--
  function deflate( src in varchar2, quality in number )
  return raw;
--
  function inflate( src in raw )
  return varchar2;
--
end;
/

create or replace package body xt_unwrapper
is
  function deflate( src in varchar2 )
  return raw
  is
  begin
    return deflate( src, 6 );
  end;
--
  function deflate( src in varchar2, quality in number )
  return raw
  as language java
  name 'XT_UNWRAPPER_J.Deflate( java.lang.String, int ) return byte[]';
--
  function inflate( src in raw )
  return varchar2
  as language java
  name 'XT_UNWRAPPER_J.Inflate( byte[] ) return java.lang.String';
--
  
end;
/
