accept uname prompt "Schema name:"

exec dbms_java.grant_permission( '&uname', 'SYS:java.lang.RuntimePermission', 'oracle.DbmsJavaScriptUser', '' );
exec dbms_java.grant_permission( '&uname', 'SYS:java.lang.RuntimePermission', 'accessClassInPackage.jdk.nashorn.internal.runtime', '' );
exec dbms_java.grant_permission( '&uname', 'SYS:java.lang.reflect.ReflectPermission', 'suppressAccessChecks', '' );
