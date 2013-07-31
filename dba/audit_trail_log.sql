with t as (
      select spare1            OS_USERNAME ,
             userid            USERNAME ,
             userhost          USERHOST ,
             terminal          TERMINAL ,
             cast (             
                 (from_tz(ntimestamp#,'00:00') at local) as date)
                               timestamp,
             obj$creator       OWNER ,
             obj$name          OBJECT_NAME ,
             aud.action#       ACTION ,
             act.name          ACTION_NAME ,
             new$owner         NEW_OWNER ,
             new$name          NEW_NAME ,
             decode(aud.action#,
                    108 /* grant  sys_priv */, null,
                    109 /* revoke sys_priv */, null,
                    114 /* grant  role */, null,
                    115 /* revoke role */, null,
                    auth$privileges)
                               OBJ_PRIVILEGE ,
             decode(aud.action#,
                    108 /* grant  sys_priv */, spm.name,
                    109 /* revoke sys_priv */, spm.name,
                    null)
                               SYS_PRIVILEGE ,
             decode(aud.action#,
                    108 /* grant  sys_priv */, substr(auth$privileges,1,1),
                    109 /* revoke sys_priv */, substr(auth$privileges,1,1),
                    114 /* grant  role */, substr(auth$privileges,1,1),
                    115 /* revoke role */, substr(auth$privileges,1,1),
                    null)
                               ADMIN_OPTION ,
             auth$grantee      GRANTEE ,
             decode(aud.action#,
                    104 /* audit   */, aom.name,
                    105 /* noaudit */, aom.name,
                    null)
                               AUDIT_OPTION  ,
             ses$actions       SES_ACTIONS   ,
             logoff$time       LOGOFF_TIME   ,
             logoff$lread      LOGOFF_LREAD  ,
             logoff$pread      LOGOFF_PREAD  ,
             logoff$lwrite     LOGOFF_LWRITE ,
             decode(aud.action#,
                    104 /* audit   */, null,
                    105 /* noaudit */, null,
                    108 /* grant  sys_priv */, null,
                    109 /* revoke sys_priv */, null,
                    114 /* grant  role */, null,
                    115 /* revoke role */, null,
                    aud.logoff$dead)
                                LOGOFF_DLOCK ,
             comment$text       COMMENT_TEXT ,
             sessionid          SESSIONID ,
             entryid            ENTRYID ,
             statement          STATEMENTID ,
             returncode         RETURNCODE ,
             spx.name           PRIVILEGE ,
             clientid           CLIENT_ID ,
             auditid            ECONTEXT_ID ,
             sessioncpu         SESSION_CPU ,
             ntimestamp#                  ntimestamp#,
             proxy$sid                       PROXY_SESSIONID,
             user$guid                            GLOBAL_UID,
             instance#                       INSTANCE_NUMBER,
             process#                             OS_PROCESS,
             xid                               TRANSACTIONID,
             scn                                         SCN,
             to_nchar(substr(sqlbind,1,2000))       SQL_BIND,
             to_nchar(substr(sqltext,1,2000))       SQL_TEXT,
             action#
      from 
          sys.aud$ aud
         , system_privilege_map spm, system_privilege_map spx,
           STMT_AUDIT_OPTION_MAP aom, audit_actions act
      where   aud.action#     = act.action    (+)
        and - aud.logoff$dead = spm.privilege (+)
        and   aud.logoff$dead = aom.option#   (+)
        and - aud.priv$used   = spx.privilege (+)
)-------------------------------------------------------
select * 
from t
where ntimestamp#+0 between sysdate-5/24 and sysdate
  and action# not in (100,101)
order by ntimestamp#+0 desc
