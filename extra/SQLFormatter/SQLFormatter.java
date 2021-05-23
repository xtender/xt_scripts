CREATE or replace AND COMPILE JAVA SOURCE NAMED SQLFormatter AS
/* Imports */
import oracle.dbtools.app.Format;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import oracle.sql.BLOB;
import oracle.sql.CLOB;
import java.io.StringWriter;
import java.io.PrintWriter;


public class SQLFormatter {

    private static String getStackTrace(Exception e) {
       StringWriter writer = new StringWriter();
       PrintWriter printWriter = new PrintWriter( writer );
       e.printStackTrace( printWriter );
       printWriter.flush();

       return writer.toString();
    }

    public static Format getFormat() {
        oracle.dbtools.app.Format format = new oracle.dbtools.app.Format();
        
        format.options.put("singleLineComments", Format.InlineComments.CommentsUnchanged);
        format.options.put("kwCase", Format.Case.UPPER);
        format.options.put("idCase", Format.Case.NoCaseChange);                             // default: Format.Case.lower
        format.options.put("adjustCaseOnly", false);                                        // default: false (set true to skip formatting)
        format.options.put("formatThreshold", 1);                                           // default: 1 (disables deprecated post-processing logic)
        // Alignment
        format.options.put("alignTabColAliases", false);                                    // default: true
        format.options.put("alignTypeDecl", true);
        format.options.put("alignNamedArgs", true);
        format.options.put("alignEquality", false);
        format.options.put("alignAssignments", true);                                       // default: false
        format.options.put("alignRight", false);                                            // default: false
        // Indentation
        format.options.put("identSpaces", 3);                                               // default: 4
        format.options.put("useTab", false);
        // Line Breaks
        format.options.put("breaksComma", Format.Breaks.Before);                            // default: Format.Breaks.After
        format.options.put("breaksProcArgs", false);
        format.options.put("breaksConcat", Format.Breaks.Before);
        format.options.put("breaksAroundLogicalConjunctions", Format.Breaks.Before);
        format.options.put("breaksAfterSelect", true);                                      // default: true
        format.options.put("commasPerLine", 1);                                             // default: 5
        format.options.put("breakOnSubqueries", true);
        format.options.put("breakAnsiiJoin", true);                                         // default: false
        format.options.put("breakParenCondition", true);                                    // default: false
        format.options.put("maxCharLineSize", 120);                                         // default: 128
        format.options.put("forceLinebreaksBeforeComment", false);                          // default: false
        format.options.put("extraLinesAfterSignificantStatements", Format.BreaksX2.Keep);   // default: Format.BreaksX2.X2
        format.options.put("flowControl", Format.FlowControl.IndentedActions);
        // White Space
        format.options.put("spaceAroundOperators", true);
        format.options.put("spaceAfterCommas", true);
        format.options.put("spaceAroundBrackets", Format.Space.Default);
        //format.options.put("formatProgramURL", "default");
        
        return format;
    }
    
  public static String format(String str) 
  {
    String res;
    try {
       //res = new Format().format(str);
       Format f = SQLFormatter.getFormat();
       res = f.format(str);
       }
    catch (Exception e){
       res = "Error: " + e.getMessage() + " [ " + SQLFormatter.getStackTrace(e) + " ]";
    }
    return res;
  }

  public static CLOB formatClob(oracle.sql.CLOB clob) 
  throws SQLException
  {
    String str = clob.getSubString(1, (int) clob.length());
    String res = SQLFormatter.format(str);
    Connection conn = DriverManager.getConnection("jdbc:default:connection:");
    CLOB resClob = CLOB.createTemporary(conn, false, BLOB.DURATION_SESSION);
    resClob.setString(1L, res);
    
    return resClob;
  }
}
/