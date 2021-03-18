
(***)중요도
날짜관련 함수

MONTHS_BETWEEN(DATE, DATE) : 인자- start date, end date, 반환값: 두 일자 사이의 개월수(숫자반환)
(***)ADD_MONTHS : 인자 - date, number 더할 개월수: date로 부터 x개월 뒤의 날짜
(***)NEXT_DAY : 인자 - date, number(weekday, 주간일자) date이후의 가장 첫번째 주간일자에 해당하는 date를 반환
(***)LAST_DAY : 인자 - date : date가 속한 월의 마지막 일자를 date로 반환


MONTHS_BETWEEN
SELECT ename, TO_CHAR(hiredate, 'yyyy/mm/dd HH24:mi:ss') hiredate,
       MONTHS_BETWEEN(SYSDATE, hiredate) month_between,
       ADD_MONTHS(SYSDATE, 5) ADD_MONTHS,
       ADD_MONTHS(TO_DATE('2021-02-15', 'YYYY-MM-DD'), -5) ADD_MONTHS2,
       NEXT_DAY(SYSDATE, 1) NEXT_DAY,
       LAST_DAY(SYSDATE) LAST_DAY,
       TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM') || '01', 'YYYYMMDD') FIRST_DAY
 /*   SYSDATE를 이용하여 SYSDATE가 속한 월의 첫번째 날짜 구하기
    sysdate를 이용해서 년월까지 문자로 구하기 + || '01'
             '202103' || '01' ==> '20210301'
             TO_DATE('20210301', 'YYYYMMDD')*/
--여기는 해석이 안됩니다.             
FROM emp;


SELECT TO_DATE('2021' || '0101' , 'YYYYMMDD')
FROM dual;



[date 종합 실습 fn3]
-- 파라미터로 yyyymm 형식의 문자열을 사용 하여(ex:yyyymm = 201912) 해당 년월에 해당하는 일자 수를 구해보세요
yyyymm=201912 -> 31
yyyymm=201911 -> 30
yyyymm=201602-> 29(2016년은 윤년)

SELECT :YYYYMM,
       TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD') DT
FROM dual;


형변환
 . 명시적 형변환
    TO_DATE, TO_CHAR, TO_NUMBER
 . 묵시적 형변환

EXPLAIN PLAN FOR --실행계획(지금 알필요없음)
SELECT *
FROM emp
WHERE TO_CHAR(empno) = '7369';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 3956160932
 
 
1. 위에서 아래로
2. 단, 들여쓰기 되어있을 경우(자식 노드) 자식노드부터 읽는다

1-0
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     1 |    38 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| EMP  |     1 |    38 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(TO_CHAR("EMPNO")='7369')
   
   
-- 실행순서 : 3-2-5-4-1-0
  0 | SELECT STATEMENT
  1 |  NESTED LOOPS
  2 |   TABLE ACCESS BY INDEX ROWID
* 3 |    INDEX UNIQUE SCAN
  4 |   TABLE ACCESS BY INDEX ROWID
* 5 |    INDEX UNIQUE SCAN  

NUMBER
 형변환(CHARACTER->NUMBER)
 형변환(NUMBER->CHARACTER) 잘 안씀, 오라클에서 미리 포맷팅하지 않는다(보통 JAVA에서 변경 포맷팅해줌)
FORMAT
 9:숫자
 0:강제로0표시
 ,:1000자리 표시
 .:소수점
 L:화폐단위(사용자 지역)
 $:달러 화폐 표시
 
===========================================================
■ NULL 처리 함수 : 4가지

1.NVL(expr1, expr2) : expr1이 NULL 값이 아니면 expr1을 사용하고, expr1이 NULL값이면 expr2로 대체해서 사용한다
if( expr1 == null)
    System.out.println(expr2)
else
    System.out.println(expr1)
    
emp 테이블에서 comm 컬럼의 값이 NULL일 경우 0으로 대체 해서 조회하기
SELECT empno, sal, comm, 
       sal + NVL(comm, 0) nvl_sal_comm,
       NVL(sal+comm, 0) nvl_sal_comm2
FROM emp;

2. NVL2(expr1, expr2, expr3)
if(expr1 != null)
    System.out.println(expr2);
else
    System.out.println(expr3);

comm이 null이 아니면 sal+comm을 반환, 
comm이 null 이면 sal을 반환
SELECT empno, sal, comm,
       NVL2(comm, sal+comm, sal) nvl2,
       sal + NVL(comm, 0)
FROM emp;

3. NULLIF(expr1, expr2)
if(expr1 == expr2)
    System.out.println(null)
else
    System.out.println(expr1)

SELECT empno, sal, NULLIF(sal, 1250)
FROM emp;


4. COALESCE(expr1, expr2, expr3....)
인자들 중에 가장먼저 등장하는 null이 아닌 인자를 반환
if(expr1 != null)
    System.out.println(expr1);
else
    COALESCE(expr2, expr3....);
    
if(expr2 != null)
    System.out.println(expr2);
else
    COALESCE(expr3....);   

SELECT empno, sal, comm, COALESCE(
FROM emp;

[null 실습 fn4]
-- emp 테이블의 정보를 다음과 같이 조회되도록 쿼리를 작성하세요(nvl, nvl2, coalesce)
SELECT empno, ename, mgr, NVL(mgr, 9999) mgr_n, NVL2(mgr, mgr, 9999) mgr_n_1, COALESCE(mgr, null, 9999) mgr_n_2
FROM emp;

[null 실습 fn5]
-- user 테이블의 정보를 다음과 같이 조회되도록 쿼리를 작성하세요(reg_dt가 null일 경우 sysdate를 적용)
SELECT userid, usernm, reg_dt, NVL(reg_dt, SYSDATE) n_reg_dt
FROM users
WHERE userid IN ('cony', 'sally', 'james', 'moon');


조건분기
1. CASE 절
    CASE expr1 비교식(참거짓을 판단 할수 있는 수식) THEN 사용할 값       => if
    CASE expr2 비교식(참거짓을 판단 할수 있는 수식) THEN 사용할 값2      => else if
    CASE expr3 비교식(참거짓을 판단 할수 있는 수식) THEN 사용할 값3      => else if
    ELSE 사용할 값4                                                  => else
   END
    
2. DECODE 함수 => COALESCE 함수 처럼 가변인자 사용
DECODE( expr1, search1, return1, search2, return2, search3, return3, ....[, default])

DECODE( expr1, 
            search1, return1, 
            search2, return2, 
            search3, return3, 
            ....[, default])

if(expr1 == search1)
    System.out.println(retur1)
else if(expr1 == search2)
    System.out.println(retur2)
else if(expr1 == search3)
    System.out.println(retur3)
else
    System.out.println(default)

직원들의 급여를 인상하려고 한다
job이 SALESMAN 이면 현재 급여에서 5%를 인상
job이 MANAGER 이면 현재 급여에서 10%를 인상
job이 PRESIDENT 이면 현재 급여에서 20%를 인상
그 이외의 직군은 현재 급여를 유지

SELECT ename, job, sal, 
        CASE
            WHEN job = 'SALESMAN' THEN sal * 1.05
            WHEN job = 'MANAGER' THEN sal * 1.10
            WHEN job = 'PRESIDENT' THEN sal * 1.20
            ELSE sal * 1.0
        END sal_bonus,
        DECODE(job, 'SALESMAN', sal * 1.05, 'MANAGER', sal * 1.10, 'PRESIDENT', sal * 1.20, sal * 1.0) sal_bonus_decode
FROM emp;

[실습 cond1]
--emp 테이블이 이용하여 deptno에 따라 부서명으로 변경해서 다음과 같이 조회되는 쿼리를 작성하세요
SELECT empno, ename, deptno, 
       CASE
        WHEN deptno = 10 THEN 'ACCOUNTING'
        WHEN deptno = 20 THEN 'RESEARCH'
        WHEN deptno = 30 THEN 'SALES'
        WHEN deptno = 40 THEN 'OPERATIONS'
        ELSE 'DDIT'
       END dname,
       DECODE(deptno, 
                10, 'ACCOUNTING', 
                20, 'RESEARCH', 
                30, 'SALES', 
                40, 'OPERATIONS', 
                'DDIT') dname_decode
FROM emp;


[실습 cond2]
-emp 테이블을 이용하여 hiredate에 따라 올해 건강보험 검진 대상자인지 조회하는 쿼리를 작성하세요.
(생년을 기준으로 하나 여기서는 입사년도를 기준으로 한다)
SELECT MOD(, 2)
FROM dual;

SELECT empno, ename, hiredate, 
        CASE
            WHEN
                MOD(TO_CHAR(hiredate, 'yyyy'), 2) =
                MOD(TO_CHAR(SYSDATE, 'yyyy'), 2) THEN '건강검진 대상자'
            ELSE '건강검진 비대상자'
        END CONTACT_TO_DOCTOR,
        DECODE( MOD(TO_CHAR(hiredate, 'yyyy'), 2), 
                            MOD(TO_CHAR(SYSDATE, 'yyyy'), 2), '건강검진 대상자',
                                                                    '건강검진 비대상자') CONTACT_TO_DOCTOR_DECODE
                
FROM emp;


실습 cond3]
--users 테이블을 이용하여 reg_dt에 따라 올해 건강보험 검진 대상자인지 조회하는 쿼리를 작성하세요.
(생년을 기준으로 하나 여기서는 reg_dt를 기준으로 한다)
SELECT userid, usernm, reg_dt, 
        CASE
            WHEN
                MOD(TO_CHAR(reg_dt, 'yyyy'), 2) =
                MOD(TO_CHAR(SYSDATE, 'yyyy'), 2) THEN '건강검진 대상자'
            ELSE '건강검진 비대상자'
        END CONTACT_TO_DOCTOR
FROM users
WHERE userid IN ('brown', 'cony', 'james', 'moon', 'sally');


■ GROUP FUNCTION : 여러행을 그룹으로 하여 하나의 행으로 결과값을 변환하는 함수
- AVG : 평균
- COUNT : 건수
- MAX : 최대값
- MIN : 최소값
- SUM : 합

- 그룹함수에서 NULL컬럼은 계산에서 제외된다
- GRUOP BY절에 작성된 컬럼 이외의 컬럼이 SELECT 절에 올 수 없다
- WHERE절에 그룹 함수를 조건으로 사용할 수 없다
 · having절 사용
   where sum(sal) > 3000 (X)
   having sum(sal) > 3000(O)
   
SELECT
FROM
[WHERE]
[GROUP BY]
[HAVING]
[ORDER BY]

SELECT *
FROM emp;

10, 5000
20, 3000
30, 2850
SELECT deptno, 
        MAX(sal), MIN(sal), ROUND(AVG(sal), 2),
        SUM(sal), 
        COUNT(sal),-- 그룹핑된 행중에 sal 컬럼의 값이 NULL이 아닌 행의 건수
        COUNT(mgr),-- 그룹핑된 행중에 mgr 컬럼의 값이 NULL이 아닌 행의 건수
        COUNT(*) -- 그룹핑된 행 건수
FROM emp
GROUP BY deptno;

--GROUP BY를 사용하지 않을 경우 테이블의 모든 행을 하나의 행으로 그룹핑한다
SELECT COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal)
FROM emp;




--GROUP BY 절에 나온 컬럼이 SELECT절에 그룹함수가 적용되지 않은채로 기술되면 에러
SELECT deptno, empno, 
        MAX(sal), MIN(sal), ROUND(AVG(sal), 2),
        SUM(sal), 
        COUNT(sal),-- 그룹핑된 행중에 sal 컬럼의 값이 NULL이 아닌 행의 건수
        COUNT(mgr),-- 그룹핑된 행중에 mgr 컬럼의 값이 NULL이 아닌 행의 건수
        COUNT(*) -- 그룹핑된 행 건수
FROM emp
GROUP BY deptno;

SELECT *
FROM emp
ORDER BY deptno;


SELECT  COUNT(*), MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal)
FROM emp;


SELECT deptno, 'TEST', 100,
        MAX(sal), MIN(sal), ROUND(AVG(sal), 2),
        SUM(sal), 
        COUNT(sal),-- 그룹핑된 행중에 sal 컬럼의 값이 NULL이 아닌 행의 건수
        COUNT(mgr),-- 그룹핑된 행중에 mgr 컬럼의 값이 NULL이 아닌 행의 건수
        COUNT(*), -- 그룹핑된 행 건수
        SUM(comm), -- 그룹함수에서는 NULL은 제외시키고 연산실행 => 값 출력
        SUM(NVL(comm, 0)), -- NVL이 14회 수행
        NVL(SUM(comm), 0) -- 성능상 위보다 좋음 NVL이 1회만 수행
FROM emp
GROUP BY deptno
HAVING COUNT(*) >= 4 ;


[실습 grp1]
--emp테이블을 이용하여 다음을 구하시오
직원중 가장 높은 급여
직원중 가장 낮은 급여
직원의 급여 평균(소수점 두자리까지 나오도록 반올림)
직원의 급여 합
직원중 급여가 있는 직원의 수(null 제외)
직원중 상급자가 있는 직원의 수(null 제외)
전체 직원의 수
SELECT  MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(*)
FROM emp;

grp2]
SELECT  deptno, MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(*)
FROM emp
GROUP BY deptno;




SELECT :YYYYMM,
       TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')) || 'DD' ) DT
FROM dual;

