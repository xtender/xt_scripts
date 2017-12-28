create or replace and compile java source named XT_UNWRAPPER_J
as
import java.sql.Connection;
import java.sql.DriverManager;
import java.io.*;
import java.util.zip.*;

public class XT_UNWRAPPER_J
{
  public static oracle.sql.CLOB Inflate( byte[] src ) throws java.sql.SQLException
  {
    Connection conn = DriverManager.getConnection("jdbc:default:connection:");
    oracle.sql.CLOB res = oracle.sql.CLOB.createTemporary(conn, true, oracle.sql.CLOB.DURATION_SESSION);
      
    try
    {
      ByteArrayInputStream bis = new ByteArrayInputStream( src );
      InflaterInputStream iis = new InflaterInputStream( bis );
      StringBuffer sb = new StringBuffer();
      for( int c = iis.read(); c != -1; c = iis.read() )
      {
        sb.append( (char) c );
      }
      System.out.println(sb.toString());
      int x = res.setString(1,sb.toString());
      return res;
    } catch ( Exception e )
    {
      System.out.println(e.getMessage());
    }
    int x = res.setString(1,"890"); /*sb.toString()*/
    return null;
  }
  public static byte[] Deflate( String src, int quality )
  {
    try
    {
      byte[] tmp = new byte[ src.length() + 100 ];
      Deflater defl = new Deflater( quality );
      defl.setInput( src.getBytes( "UTF-8" ) );
      defl.finish();
      int cnt = defl.deflate( tmp );
      byte[] res = new byte[ cnt ];
      for( int i = 0; i < cnt; i++ )
        res[i] = tmp[i];
      return res;
    } catch ( Exception e )
    {
    }
    return null;
  }
}
/
