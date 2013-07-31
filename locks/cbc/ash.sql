define event_mask=latch: cache buffers chains
define minutes=15
accept event_mask default &event_mask  prompt "Event like: "
accept minutes    default &minutes prompt "Minutes ago: "

SELECT * FROM (
    SELECT
        event
      , TRIM(TO_CHAR(p1, 'XXXXXXXXXXXXXXXX')) latch_addr
      , TRIM(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1))||'%' PCT
      , COUNT(*)
    FROM
        v$active_session_history
    WHERE
        --event = 'latch: cache buffers chains'
        event like '&event_mask'
    AND sample_time>sysdate-&minutes/24/60
    AND session_state = 'WAITING'
    GROUP BY
        event
      , p1
    ORDER BY
        COUNT(*) DESC
)
WHERE ROWNUM <= 10
/
undef event_mask
undef minutes
