COL res FORMAT A500

WITH p AS ( /*Входные параметры календаря*/
  SELECT trunc(SYSDATE,'YEAR') y,
         12 mrows, 
         4 cpd, -- ширина колонки с месцем
         4 padd -- расстояние между колонками
    FROM dual),
ds AS ( /*Все дни года*/
SELECT to_number(to_char(y+LEVEL-1,'MM')) m,
       y+LEVEL-1 yd,
       to_char(y+LEVEL-1,'d') wd
  FROM p
 CONNECT BY LEVEL <=add_months(y,12)-y),
ms AS ( /*Месяцы и их позиция в прямоугольнике 3х4*/
 SELECT --+materialize
        LEVEL m, -- номер месяца
        to_number(to_char(add_months(y,LEVEL-1),'d'))-2 offs, -- мсещение первого дня от начала недели
        --/* это по временам года:
        MOD(LEVEL,3)*(7*cpd+padd)+2 mcol, 
        trunc((LEVEL)/3)*mrows      mrow
        --*/
        /* разбросать по столу:
        2+trunc(dbms_random.value(1,80)) mcol, 
        2+trunc(dbms_random.value(1,90)) mrow 
        --*/
       -- по диагонали:
       -- 4*level mcol,4*level mrow 
   FROM p
  CONNECT BY LEVEL<=12),
bcal AS ( /*Базовая информация для дней года*/
SELECT m,
       yd,
       wd, -- день недели (колонка)
       trunc((to_number(to_char(yd,'dd'))+offs)/7) lno, --номер строки в месяце
       mcol,
       mrow
  FROM ds JOIN ms USING(m)
 ORDER BY yd),
wds AS ( /*Дни недели - для шапки*/
  SELECT to_char(SYSDATE+LEVEL,'D') dn,
         lpad(to_char(SYSDATE+LEVEL,'fmDy'),cpd,' ') ds
    FROM p
   CONNECT BY LEVEL<=7),
q AS ( /*Выводимые надписи*/
SELECT r,c,txt 
  FROM (SELECT m,1 l, /*"Подложки" под месяцы*/
               mrow+p1.i AS r,
               mcol AS c,
               lpad(' ',7*cpd+3,' ') txt
          FROM ms,p,(SELECT LEVEL-1 i FROM p CONNECT BY LEVEL<=9) p1
         UNION ALL
        SELECT /*Дни*/
               to_number(to_char(yd,'MM')) m, 2 l,
               mrow+2+lno AS r,
               mcol+wd*cpd+1-length(to_number(to_char(yd,'DD'))) c,
               case when yd=trunc(sysdate) then '**' 
                    else to_char(to_number(to_char(yd,'DD')))
               end txt
          FROM bcal,p
         UNION ALL
        SELECT /*Строчки, подчеркивающие месяцы*/
               m, 2 l,
               mrow+case when m>to_number(to_char(sysdate,'MM')) then 0 else 8 end AS r, 
               mcol c,
               '*'||lpad('-',7*cpd+1,'-')||'*' txt
          FROM ms,p
         UNION ALL
        SELECT /*Заголовки месяцев*/
               m, 2 l,
               mrow+case when m>to_number(to_char(sysdate,'MM')) then 8 else 0 end AS r,
                    --(см. выше) вот переключалка названия месяца верх/низ
               mcol c,
               '*'||lpad('['||to_char(add_months(y,m-1),'fmMonth')||']',7*cpd-1,'-')||'--*' txt
          FROM ms,p
         UNION ALL
        SELECT /*Боковые вертикальные границы*/
               m, 2 l,
               mrow+radd AS r,
               mcol+cadd c,
               '|' txt
          FROM ms,p,
               (SELECT LEVEL radd FROM dual CONNECT BY LEVEL<=7) p1,
               (SELECT sign(level-1)*(7*cpd+2) cadd FROM p CONNECT BY LEVEL<=2) p2
         UNION ALL
        SELECT /*Дни недели в каждом месяце*/
               m, 2 l,
               mrow+1 AS r,
               mcol+1+(dn-1)*cpd c,
               ds txt
          FROM ms, wds,p
         UNION ALL
        SELECT /*Год в шапке отчета*/
               0 m, 2 l,
               1 AS r,
               trunc((3*(7*cpd+2)+2*padd)/2-2) c,
               to_char(y,'YYYY') txt
          FROM p)
 ORDER BY abs(-m+to_number(to_char(sysdate,'MM'))) desc, l asc ),
qr as ( /*Упорядочим все выводимые надписи*/
  select rownum-1 i, r,c,txt from q),
pvt as ( /*Здесь у нас пивотик - в упор не помню, зачем я его пририсовал, но пусть будет*/
  select level-1 i from (select max(r) r from q) connect by LEVEL<r),
mdl as ( /*А вот это, собственно, наш GUI :) */
select *
  from qr
 model dimension by(i)
       measures(r,c,txt,cast(null as varchar2(1000)) res)
       rules iterate(1e6) until (r[iteration_number] is null) (
         res[r[iteration_number]] = rpad(nvl(substr(res[r[iteration_number]],1,c[iteration_number]-1),' '),c[iteration_number]-1,' ')||
                                    txt[iteration_number]||
                                    substr(res[r[iteration_number]],c[iteration_number]+length(txt[iteration_number]))
       )
)
select res
  from pvt right join mdl using(i)
 WHERE res IS NOT NULL -- пустые строчки не выводим - грубо, конечно, но сойдет для сельской местности
 order by i -- Не забудем упорядочить, а то мало ли что
/