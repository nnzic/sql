[실습 ana2]
window function을 이용하여 모든 사원에 대해 사원번호, 사원이름, 본인급여, 부서번호와 
해당 사원이 속한 부서의 급여 평균을 조회하는 쿼리를 작성하세요(급여 평균은 소수 둘째 자리까지 구한다)
SELECT empno, ename, sal, deptno, 
       ROUND(AVG(sal) OVER(PARTITION BY deptno), 2) avg_sal,
       --해당 부서의 가장 낮은 급여
       MIN(sal) OVER(PARTITION BY deptno) min_sal,
       --해당 부서의 가장 높은 급여
       MAX(sal) OVER(PARTITION BY deptno) max_sal,
       SUM(sal) OVER(PARTITION BY deptno) sum_sal,
       COUNT(*) OVER(PARTITION BY deptno) cnt
FROM emp;

■ window함수 (그룹내 행 순서)
LAG(col) 파티션별 윈도우에서 이전 행의 컬럼 값
LEAD(col) 파티션별 윈도우에서 이후 행의 컬럼 값


-- 자신보다 급여 순위가 한단계 낮은 사람의 급여를 5번째 컬럼으로 생성
SELECT empno, ename, hiredate, sal,
       LEAD(sal) OVER (ORDER BY sal DESC, hiredate)
FROM emp;

[실습 ana5]
window function을 이용하여 모든 사원에 대해 사원번호, 사원이름, 입사일자, 급여,
전체 사원중 급여 순위가 1단계 높은 사람의 급여를 조회하는 쿼리를 작성
(급여가 같을 경우 입사일이 빠른 사람이 높은순위)
SELECT empno, ename, hiredate, sal, LAG(sal) OVER (ORDER BY sal DESC, hiredate) lag_sal
FROM emp;

[실습 ana5_1]
window function을 이용하여 모든 사원에 대해 사원번호, 사원이름, 입사일자, 급여,
전체 사원중 급여 순위가 1단계 높은 사람의 급여를 조회하는 쿼리를 작성
(급여가 같을 경우 입사일이 빠른 사람이 높은순위)
SELECT
FROM (SELECT empno, ename, hiredate, sal, RANK() OVER (ORDER BY sal DESC) rnk FROM emp) a,
     (SELECT sal, count(*) cnt FROM emp GROUP BY sal ORDER BY sal DESC) b
WHERE a.rnk < b.rank

SELECT 
--a.empno, a.ename, a.hiredate, a.sal, b.sal
*
FROM
(SELECT a.*, ROWNUM rnm
 FROM 
  (SELECT empno, ename, hiredate, sal
   FROM emp
   ORDER BY sal DESC) a) a,
(SELECT a.*, ROWNUM rnm
 FROM 
  (SELECT empno, ename, hiredate, sal
   FROM emp
   ORDER BY sal DESC) a) b
WHERE a.rnm-1 = b.rnm(+)
ORDER BY a.sal DESC, a.hiredate;


[실습 ana6]
window function을 이용하여 모든 사원에 대해 사원번호, 사원이름, 입사일자, 직군(job), 급여정보와 담당업무(job)별
급여 순위가 급여 순위가 1단계 높은 사람의 급여를 조회하는 쿼리를 작성
(급여가 같을 경우 입사일이 빠른 사람이 높은순위)
SELECT empno, ename, hiredate, job, sal, 
       LAG(sal) OVER(PARTITION BY job ORDER BY sal DESC, hiredate) lag_sal
FROM emp

LAG, LEAD 함수의 두번째 인자 : 이저나 이후 몇번째 행을 가져올지 표기 -- 이러한 형태로 쓰는 경우는 많지 않다!
SELECT empno, ename, hiredate, job, sal, 
       LAG(sal, 2) OVER(ORDER BY sal DESC, hiredate)
FROM emp

분석함수 OVER([])

[실습 ana7] rownum, 범위 조인 --누적 합 구하자
모든 사원에 대해 사원번호, 사원이름, 입사일자
1. ROWNUM
2. INLINE VIEW
3. NON-EQUI-JOIN
4. GROUP BY
SELECT a.empno, a.ename, a.sal
--, SUM(a.sal)
FROM
    (SELECT a.*, ROWNUM rn
     FROM (SELECT * FROM emp ORDER BY sal, empno) a) a,
    (SELECT b.*, ROWNUM rn
     FROM (SELECT * FROM emp ORDER BY sal, empno) b) b
WHERE a.rn >= b.rn
GROUP BY  a.empno, a.ename, a.sal
ORDER BY a.sal, a.empno;

■ 분석함수() OVER ([PARTITION] [ORDER] [WINDOWING])
WINDOWING : 윈도우함수의 대상이 되는 행을 지정
UNBOUNDED PRECEDING : 특정 행을 기준으로 모든 이전행(LAG)
  n PRECEDING : 특정 행을 기준으로 N행 이전행(LAG)
CURRENT ROW : 현재행
UNBOUNDED FOLLOWING : 특정 행을 기준으로 모든 이후행(LEAD)
  n FOLLOWING : 특정 행을 기준으로 N행 이후행(LEAD)
  ROWS : 행
  
■ 분석함수() OVER ([] [ORDER] [WINDOWING])
SELECT empno, ename, sal, 
       SUM(sal) OVER (ORDER BY sal, empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum, -- 길더라도 이것을 추천
       SUM(sal) OVER (ORDER BY sal, empno ROWS UNBOUNDED PRECEDING) c_sum -- 이건 참고만 하자
FROM emp
ORDER BY sal, empno;
    
SELECT empno, ename, sal, 
       SUM(sal) OVER (ORDER BY sal, empno ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) c_sum
FROM emp
ORDER BY sal, empno;

[실습 ANA 7]
사원번호, 사원이름, 부서번호, 급여정보를 부서별로 급여, 사원번호 오름차순으로 정렬 했을때, 
자신의 급여와 선행하는 사원들의 급여 합을 조회하는 쿼리 작성(WINDOW함수 사용)
SELECT empno, ename, deptno, sal,
       SUM(sal) OVER (PARTITION BY deptno ORDER BY sal, empno ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) c_sum
FROM emp
ORDER BY sal, empno;

■ 범위 설정 - row와 range 
○ row
-물리적인 row
○ range : 같은 값을 하나의 행으로 본다
-논리적인 값의 범위
-같은 값을 하나로 본다

■ ROW와 RANGE의 차이
SELECT empno, ename, sal,
       SUM(sal) OVER (ORDER BY sal ROWS UNBOUNDED PRECEDING) rows_c_sum,
       SUM(sal) OVER (ORDER BY sal RANGE UNBOUNDED PRECEDING) range_c_sum,
       SUM(sal) OVER (ORDER BY sal) no_win_c_sum, --ORDER BY 이후 윈도윙이 없을 경우 기본설정 : RANGE UNBOUNDED PRECEDING
       SUM(sal) OVER () no_ord_c_sum
FROM emp
ORDER BY sal, empno;

나머지 분석함수
RATIO_TO_REPORT
PERCENT_RANK
CUME_DIST
NTILE

수업시간 내용을 잘 이해한 경우 책추천
(오라클)
SQL 전문가 가이드 - 자격증
★전문가로 가는 지름길(오라클 실습) - 실습시 테이블생성 스크립트에서 한글 사이즈를 늘려준다 (오라클8버전으로 작성)
불친절한 SQL 프로그래밍 - 잘 정리 되어있음

관계형 데이터 모델링 (김기창 지음)

DBMS내부원리 -> SQLP/DAP
97년-어둠의 경로 강의영상 : 대용량 데이터베이스 솔루션(조광원, 인터파크)
책 - 새로쓴 대용량 데이터베이스 솔루션, 오라클 성능 고도화 원리와 해법1,2

교양
나는 프로그래머다

================================================================

SQL : DBMS와 통신수단

T아카데미, 프로그래머스










