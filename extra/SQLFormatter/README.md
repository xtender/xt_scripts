

### 1. load appropriate java library into Oracle
```
loadjava -u login/pass@pdb1 $ORACLE_HOME/sqlcl/lib/dbtools-common.jar
```

### 2. set java permissions

```
@permissions.sql
```

### 3. create java functions
```
@SQLFormatter.java
@SQLFormatter.pl.sql
```

### Example:

```
select SQLFormatter.format('select 1 a,2 /*123 */ b,3 c, d from dual, dual d2') qtext from dual;
```
Output:
```
SQL> select SQLFormatter.format('select 1 a,2 /*123 */ b,3 c, d from dual, dual d2') qtext from dual;
 
QTEXT
----------------------------------------------------------------------------------------------------
SELECT
   1 a
 , 2 /*123 */ b
 , 3 c
 , d
FROM
   dual
 , dual d2
 ```
