doc
----------------------------------------------------------
TYPE SYS.ku$_ErrorLines AS TABLE OF sys.ku$_ErrorLine
            AS OBJECT(
                errorNumber     NUMBER,
                errorText       VARCHAR2(2000) 
            )
----------------------------------------------------------
TYPE ku$_ObjNumNamSet  IS TABLE OF  ku$_ObjNumNam 
            as object (
                obj_num         NUMBER,
                name            VARCHAR2(30)
                );
----------------------------------------------------------
TYPE ku$_procobj_locs AS TABLE OF sys.ku$_procobj_loc
            AS OBJECT(
                newblock        NUMBER,
                line_of_code    VARCHAR2(32767) 
            )
----------------------------------------------------------
TYPE ku$_ObjNumPairList  IS TABLE OF ku$_ObjNumPair
            AS OBJECT (
                num1            NUMBER,
                num2            NUMBER
            )
----------------------------------------------------------
----------------------------------------------------------
TYPE ku$_parsed_items IS TABLE OF sys.ku$_parsed_item
            AS OBJECT(
                item            VARCHAR2(30),
                value           VARCHAR2(4000),
                object_row      NUMBER
            )
----------------------------------------------------------
TYPE ku$_ddl AS OBJECT
            (       ddltext         CLOB,
                    parsedItems     sys.ku$_parsed_items    -- ^^ previous type ^^
            )
----------------------------------------------------------
----------------------------------------------------------
type ku$_oparg_list_t as TABLE of ku$_oparg_t
            as object
            (
                obj_num       number,                            /* operator object number */
                bind_num      number,                      /* binding this arg. belongs to */
                position      number,                   /* position of the arg in the bind */
                type          varchar2(61)                          /* datatype of the arg */
            )
----------------------------------------------------------
TYPE ku$_ParamValues1010 AS TABLE OF sys.ku$_ParamValue1010
            AS OBJECT(
                param_name      VARCHAR2(30),           -- Parameter name
                param_op        VARCHAR2(30),           -- Param operation
                param_type      VARCHAR2(30),           -- Its type
                param_length    NUMBER,                 -- Its length in bytes
                param_value_n   NUMBER,                 -- Numeric value
                param_value_t   VARCHAR2(4000)          -- And its text value
            )
----------------------------------------------------------
#