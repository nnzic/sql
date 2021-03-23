시험문제 
1. 트랜잭션
2. NOT IN 연산자 사용시 주의점!! : 비교값 중에 NULL이 포함되면 데이터가 조회되지 않는다
3. 페이징처리
4. NONEQUI-JOIN : 조인 조건이 =(equals)가 아닌 조인

SELECT *
FROM emp, dept
WHERE emp.deptno != dept.deptno
ORDER BY emp.ename;
===============================================

[실습 grp3]
--emp테이블을 이용하여 다음을 구하시오
--grp2에서 작성한 쿼리를 활용하여 deptno 대신 부서명이 나올수 있도록 수정하시오
SELECT  CASE
        WHEN deptno = 10 THEN 'ACCOUNTING'
        WHEN deptno = 20 THEN 'RESEARCH'
        WHEN deptno = 30 THEN 'SALES'
        WHEN deptno = 40 THEN 'OPERATIONS'
        ELSE 'DDIT'
       END dname, MAX(sal), MIN(sal), ROUND(AVG(sal), 2), SUM(sal), COUNT(sal), COUNT(mgr), COUNT(*)
FROM emp
GROUP BY detpno;

[실습 grp4]
--emp테이블을 이용하여 다음을 구하시오
--직원의 입사 년월별로 몇명의 직원이 입사했는지 조회하는 쿼리를 작성하세요
SELECT TO_CHAR(hiredate, 'YYYYMM') hire_yyyymm, count(*) cnt
FROM emp
GROUP BY TO_CHAR(hiredate, 'YYYYMM')
ORDER BY TO_CHAR(hiredate, 'YYYYMM');

[실습 grp5]
--emp테이블을 이용하여 다음을 구하시오
--직원의 입사 년월별로 몇명의 직원이 입사했는지 조회하는 쿼리를 작성하세요
SELECT TO_CHAR(hiredate, 'YYYY') hire_yyyymm, count(*) cnt
FROM emp
GROUP BY TO_CHAR(hiredate, 'YYYY')
ORDER BY TO_CHAR(hiredate, 'YYYY');

[실습 grp6]
SELECT count(*)
FROM dept;

[실습 grp7]
--직원이 속한 부서의 개수를 조회하는 쿼리를 작성하시오(emp테이블)
SELECT count(*)
FROM (SELECT deptno
      FROM emp
      GROUP BY deptno);

=======================================================================

▣ 데이터 결합
■ JOIN
º RDBMS는 중복을 최소화 하는 형태의 데이터 베이스
º 다른 테이블과 결합하여 데이터를 조회

하나의 테이블에 모든 데이터를 구성시 중복데이터 발생(데이터 변경사항 발생시 하나하나 일일히 바꿔져야됨(변경할 SALES부서개수 6개를))
==> 테이블을 쪼개줘 참조하면 참조테이블에서만 정보를 바꿔주면 됨(참조테이블에서 SALE부서 정보만 바꿔주면 결합된emp 테이블이 참조하여 )

▣ 데이터를 확장(결합)
1. 컬럼에 대한 확장 : JOIN
2. 행에 대한 확장 : 집합연산자(UNION ALL, UNION(합집합), MINUS(차집합), INTERSECT(교집합))

º 중복을 최소화하는 RDBMS 방식으로 설계한 경우
º emp테이블에는 부서코드만 존재, 부서정보를 담은 dept테이블 별도로 생성
º emp테이블과 dept테이블의 연결고리로 조인하여 실제 부서명을 조회한다.

JOIN 
1. 표준 SQL => ANSI SQL
2. 비표준 SQL - DBMS를 만드는 회사에서 만든 고유의 SQL 문법

ANSI : SQL
ORACLE : SQL    

■ ANSI - NATURAL JOIN
 º 조인하고자 하는 테이블의 연결컬럼 명(타입도 동일)이 동일한 경우(emp.detpno, dept.deptno) 
 º 연결 컬럼의 값이 동일할 떄(=) 컬럼이 확장된다.
 
SELECT emp.empno, emp.ename, deptno
FROM emp NATURAL JOIN dept;

■ ORACLE join :
1. FROM절에 조인할 테이블을 (,)콤마로 구분하여 나열
2. WHERE : 조인할 테이블의 연결조건을 기술 (한정자(.)로 테이블 구분지어줌)
SELECT *
FROM emp,dept
WHERE emp.deptno = dept.deptno;

7369 SMITH, 7902 FORD
SELECT e.empno, e.ename, m.empno, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno;

■ ANSI SQL : JOIN WITH USING
조인하려고 하는 테이블의 컬럼명과 타입이 같은 컬럼이 두개 이상인 상황에서
두 컬럼을 모두 조인 조건으로 참여시키지 않고, 개발자가 원하는 특정 컬럼으로만 연결을 시키고 싶을 때 사용
SELECT *
FROM emp JOIN dept USING(deptno);

■ JOIN WITH ON : NATURAL JOIN, JOIN WITH USING을 대체할 수 있는 보편적인 문법
조인 컬럼 조건을 개발자가 임의 지정
SELECT *
FROM emp JOIN dept ON (emp.deptno = dept.deptno); -- 오라클에서 emp테이블 또는 dept테이블중 건수나 조건을 파악하여 먼저실행할지를 실행계획을 세움

사원 번호, 사원 이름, 해당사원의 상사 사번, 해당사원의 상사 이름 : JOIN WITH ON 을 이용하여 쿼리 작성
SELECT e.empno, e.ename, e.empno, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno)
WHERE e.empno BETWEEN 7369 AND 7698;

SELECT e.empno, e.ename, e.empno, m.ename
FROM emp e JOIN emp m
WHERE  e.mgr = m.empno 
  AND e.empno BETWEEN 7369 AND 7698;


▣ 논리적인 조인 형태
1. SELF JOIN : 조인 테이블이 같은 경우
 - 계층구조
2. NONEQUI-JOIN : 조인 조건이 =(equals)가 아닌 조인

SELECT *
FROM emp, dept
WHERE emp.deptno != dept.deptno
ORDER BY emp.ename;

SELECT *
FROM salgrade;

--salgrade를 이용하여 직원의 급여 등급 구하기
-- empno, ename, sal, 급여등급
SELECT e.empno, e.ename, e.sal, s.grade
FROM emp e, salgrade s
WHERE e.sal BETWEEN s.losal AND s.hisal;

SELECT e.empno, e.ename, e.sal, s.grade
FROM emp e JOIN salgrade s ON (e.sal BETWEEN s.losal AND s.hisal);


SELECT CASE sal
        WHEN sal BETWEEN 700 AND 1200 THEN 1
        WHEN sal BETWEEN 1201 AND 1400 THEN 2
        WHEN sal BETWEEN 1401 AND 2000 THEN 3
        WHEN sal BETWEEN 2001 AND 3000 THEN 4
        WHEN sal BETWEEN 3001 AND 9999 THEN 5 
       END grade
FROM emp

[실습 join 0]
-- emp, dept 테이블을 이용하여 다음과 같이 조회되도록 쿼리를 작성하세요
SELECT empno, ename, d.deptno, dname -- deptno컬럼은 emp와 dept 모두 존재하므로 한정자로 지정을 해줘야함
FROM emp e, dept d
WHERE e.deptno = d.deptno
ORDER BY d.deptno;

[실습 join 0_1]
-- emp, dept 테이블을 이용하여 다음과 같이 조회되도록 쿼리를 작성하세요(부서번호 10, 30)
SELECT empno, ename, e.deptno, dname 
FROM emp e, dept d
WHERE e.deptno = d.deptno
  --AND e.deptno IN (10, 30) 조건을 두번줘도 결과와 무방
  AND d.deptno IN (10, 30);

[실습 join 2]
--emp, dept 테이블을 이용하여 다음과 같이 조회되도록 쿼리를 작성하세요(급여가 2500초과)
SELECT empno, ename, emp.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND sal > 2500;

[실습 join 3]
--emp, dept 테이블을 이용하여 다음과 같이 조회되도록 쿼리를 작성하세요(급여가 2500초과, 사번이 7600보다 큰 직원)
SELECT empno, ename, emp.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND sal > 2500
  AND empno > 7600;

[실습 join 4]
--emp, dept 테이블을 이용하여 다음과 같이 조회되도록 쿼리를 작성하세요
--(급여가 2500초과, 사번이 7600보다 크고, RESEARCH 부서에 속하는 직원)
SELECT empno, ename, emp.deptno, dname
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND sal > 2500
  AND empno > 7600
  AND emp.deptno = 20
  AND dname = 'RESEARCH';

z






