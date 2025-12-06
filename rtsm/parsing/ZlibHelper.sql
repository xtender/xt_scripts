create or replace and compile java source named "ZlibHelper" as
import java.io.*;
import java.util.zip.*;
import java.sql.*;
import oracle.sql.*;

public class ZlibHelper {
    public static void inflate(Blob src, Blob[] dst) throws Exception {
        if (src == null || src.length() == 0) return;

        try (InputStream in = src.getBinaryStream();
             // Java InflaterInputStream by default is expecting ZLIB header.
             // This is a full analogue of Python wbits=15 (or zlib.MAX_WBITS)
             InflaterInputStream inflaterIn = new InflaterInputStream(in);
             OutputStream out = dst[0].setBinaryStream(1L)) {

            byte[] buffer = new byte[8192];
            int len;
            while ((len = inflaterIn.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
        }
    }
};
