SELECT product.*, :cid, NVL(cycle.day, 0) day, NVL(cycle.cnt, 0) cnt
FROM cycle, product
WHERE product.pid = cycle.pid(+)
  AND cid(+) = :cid;  
  
[outerjoin5] ******* 과제 *******
[outerjoin4]를 바탕으로 고객 이동 컬럼 추가하기
SELECT product.*, cycle.cid, NVL(cycle.day, 0) day, NVL(cycle.cnt, 0) cnt, customer.cnm
FROM cycle, product, customer
WHERE product.pid = cycle.pid(+)
  AND cycle.cid = customer.cid(+);
  
1. 파일 시스템 VS DBMS이 갖는 장점
데이터중복방지
백업/복구
보안/공유
SQL 표준에 따른 프로그램 비종속

트랜잭션 : 여러 단계의 과정을 하나의 작업 행위로 묶는 단위, 원자성(All or Nothing), 일관성, 격리성, 지속성
출금O->atm->입금O
출금O->atm->입금X
 (<-출금취소)
  
**** 여태까지 배운 중요한 개념 WHERE, GROUP BY, JOIN ****

★★ 시험문제 ★★
NOT IN 개념, 서브쿼리에서 NOT IN개념도 동일
SELECT *
FROM emp
WHERE empno NOT IN (SELECT NVL(mgr, 9999)
                    FROM emp);
 ======================================================================================
SMITH가 속한 부서에 있는 직원들을 조회하기? ==> 20번 부서에 속하는 직원들 조회하기
1. SMITH가 속한 부서 이름을 알아 낸다.
2. 1번에서 알아낸 부서번호로 해당 부서에 속하는 직원을 emp테이블에서 검색한다.

1. 20
SELECT deptno
FROM emp
WHERE ename = 'SMITH';

2. 
SELECT *
FROM emp
WHERE deptno = 20;

SUBQUERY를 활용;
SELECT *
FROM emp
WHERE deptno = (SELECT deptno
                FROM emp
                WHERE ename = 'SMITH');  
-- 실행 안됨 WHERE deptno = (20, 'SMITH')
SELECT *
FROM emp
WHERE deptno = (SELECT deptno, ename
                FROM emp
                WHERE ename = 'SMITH');  
-- 실행 안됨
SELECT *
FROM emp
WHERE deptno = (SELECT deptno
                FROM emp
                WHERE ename = 'SMITH' OR ename = 'ALLEN'); 

-- 이렇게 활용 해야함 WHERE deptno IN (20, 30)
SELECT *
FROM emp
WHERE deptno IN (SELECT deptno
                FROM emp
                WHERE ename = 'SMITH' OR ename = 'ALLEN'); 

--비상호 연관 서브 쿼리                
SELECT *
FROM emp m
WHERE m.deptno = (SELECT e.deptno
                FROM emp e
                WHERE e.ename = 'SMITH');

■ SUBQUERY : 쿼리의 일부로 사용되는 쿼리(밖의 쿼리는 메인 쿼리)
1. 사용위치에 따른 분류
 º SELECT : 스칼라 서브 쿼리(스칼라: 단일행이라는 뜻) - 서브쿼리의 실행결과가 하나의 행, 하나의 컬럼을 반환하는 쿼리
 º FROM : 인라인 뷰
 º WHERE : 서브쿼리
        - 메인쿼리의 컬럼을 가져다가 사용할 수 있다.
        - 반대로 서브쿼리의 컬럼을 메인쿼리에 가져가서 사용할 수 없다.

2. 반환값에 따른 분류(행, 컬럼의 개수에 따른 분류)
 º 행 - 다중행, 단일행 // 컬럼 - 단일 컬럼, 복수 컬럼
 º 다중행 단일 컬럼 IN, NOT IN
 º 다중행 복수 컬럼 (pari-wise)
 º 단일행 단일 컬럼
 º 단일행 복수 컬럼

3. MAIN-SUB QUERY의 관계에 따른 분류
 º 상호 연관 서브 쿼리(correlated subquery) - 메인 쿼리의 컬럼을 서브 쿼리에서 가져다 쓴 경우
   ==> 메인쿼리가 없으면 서브쿼리만 독자적으로 실행 불가능
   실행순서 : min->sub
 º 비상호 연관 서브 쿼리(non-correlated subquery) - 메인 쿼리의 컬럼을 서브 쿼리에서 가져다 쓰지 않는 경우
   ==> 메인쿼리가 없어도 독자적으로 실행 가능
   실행 순서 : min->sub, sub->main

[실습 sub1]
SELECT AVG(sal)
FROM emp;

SELECT count(*)
FROM emp
WHERE sal >= 2073;
-- 두개의 형태를 서브쿼리를 사용하여 표현
SELECT count(*)
FROM emp
WHERE sal >= (SELECT AVG(sal)
              FROM emp) ;

[실습 sub2]
평균 급여보다 높은 급여를 받는 직원의 정보 조회
SELECT *
FROM emp
WHERE sal >= (SELECT AVG(sal)
              FROM emp) ;

[실습 sub3]
SMITH와 WARD사원이 속한 부서의 모든 사원 정보를 조회하는 쿼리를 다음과 같이 작성
SELECT *
FROM emp m
WHERE m.deptno IN (SELECT s.deptno
                 FROM emp s
                 WHERE s.ename IN ('SMITH', 'WARD'));

MULTI ROW 연산자 -- 많이 쓰지는 않음
 º IN : = + OR
 º 비교 연산자 ANY
 º 비교 연산자 ALL
 
 -- ANY 연산
직원중에 급여값이 SMITH(800)나 WARD(1250)의 급여보다 작은 직원을 조회
  ==> 직원중에 급여값이 1250보다 작은 직원 조회
SELECT *
FROM emp e
WHERE e.sal < ANY ( SELECT s.sal
                    FROM emp s
                    WHERE s.ename IN ('SMITH', 'WARD') );
SELECT *
FROM emp e
WHERE e.sal < ( SELECT MAX(s.sal)
                FROM emp s
                WHERE s.ename IN ('SMITH', 'WARD') );

-- ALL 연산                
직원의 급여가 800보다 작고 1250보다 작은 직원 조회
  ==> 직원의 급여가 800보다 작은 직원 조회
SELECT *
FROM emp e
WHERE e.sal < ALL ( SELECT s.sal
                    FROM emp s
                    WHERE s.ename IN ('SMITH', 'WARD') );
SELECT *
FROM emp e
WHERE e.sal < ( SELECT MIN(s.sal)
                FROM emp s
                WHERE s.ename IN ('SMITH', 'WARD') );

★★★★ subquery 사용시 주의점 NULL 값 ★★★★
-- 쿼리 잘 짠것 같은데 NOT IN에 비교 되는 값이 NULL값 포함시 조회 안됨(NVL함수로 처리해줘야함)
IN ()
NOT IN ()

SELECT *
FROM emp
WHERE deptno IN ( 10, 20, NULL);
==> deptno = 10 OR deptno = 20 OR deptno = NULL
    --실행에 문제 안됨                  FALSE 

SELECT *
FROM emp
WHERE deptno NOT IN ( 10, 20, NULL);
==> !(deptno = 10 OR deptno = 20 OR deptno = NULL)
  ==> deptno != 10 AND deptno != 20 AND deptno != NULL
      -- AND연산이므로 실행에 문제됨!!         FALSE

TRUE AND TRUE AND TRUE ==> TRUE
TRUE AND TRUE AND FALSE ==> FALSE

-- mgr 값에 NULL값이 포함되어있어 아무것도 조회되지 않음!!
SELECT *
FROM emp
WHERE empno NOT IN (SELECT mgr
                    FROM emp);
SELECT *
FROM emp
WHERE empno NOT IN (SELECT NVL(mgr, 9999)
                    FROM emp);

■ PAIR WISE : 순서쌍
-- NON PAIR WISE
SELECT *
FROM emp
WHERE mgr IN (SELECT mgr
              FROM emp
              WHERE empno IN(7499, 7782))
  AND deptno IN (SELECT deptno
                 FROM emp
                 WHERE empno IN(7499, 7782));

--ALLEN (90, 7698), CLARK(10, 7839)
SELECT ename, mgr, deptno
FROM emp
WHERE empno IN(7499, 7782);

SELECT ename, mgr, deptno
FROM emp
WHERE mgr IN(7698, 7839)
  AND deptno IN (10, 20);
mgr, deptno
-- (7698, 10) (7698, 30) (7839, 10) (7839, 30)
-- 경우의수에 의해 발생 (7698, 10) (7839, 30)
--PAIR WISE
요구사항 : ALLEN 또는 CLARK의 소속 부서번호와 같으면서 상사도 같은 직원들을 조회
SELECT *
FROM emp
WHERE (mgr, deptno) IN (SELECT mgr, deptno
                        FROM emp
                        WHERE ename IN ('ALLEN', 'CLARK') ;

-- 남용 하지 말자, 성능에 독이 될수도...
DISTINCT
1. 설계가 잘못된 경우
2. 개발자가 SQL을 잘 작성하지 못하는 사람인 경우
3. 요구사항이 이상한 경우

■ 스칼라 서브쿼리 : SELECT 절에 사용된 쿼리(하나의 행, 하나의 컬럼을 반환하는 서브쿼리)
** select행의 개수만큼 스칼라 서브쿼리 실행된다. 건수가 많으면 비효율적
SELECT empno, ename, SYSDATE
FROM emp;

SELECT SYSDATE
FROM dual;

SELECT empno, ename, (SELECT SYSDATE FROM dual)
FROM emp;

emp 테이블에는 해당 직원이 속한 부서번호는 관리하지만 해당 부서명 정보는 dept 테이블에만 있다
해당 직원이 속한 부서 이름을 알고 싶으면 dept 테이블과 조인을 해야한다.
★ 상호연관 서브쿼리는 항상 메인 쿼리가 먼저 실행된다 
(메인쿼리 1회실행, 서브쿼리는 메인쿼리의 행의 개수만큼 실행 14회 실행 = 총 15회)
SELECT empno, ename, deptno,
       (SELECT dname FROM dept WHERE dept.deptno = emp.deptno)
FROM emp;
비상호연관 서브쿼리는 메인쿼리가 먼저 실행 될 수도 있고
                   서브쿼리가 먼저 실행 될 수도 있다
                ==> 성능 측면에서 유리한 쪽으로 오라클이 선택

■ 인라인 뷰 : SELECT QUERY
 º inline : 해당위치에 직접 기술 함
 º inline view : 해당위치에 직접 기술한 view
 º view : QUERY 이다(데이터를 정의한 쿼리) ==> view table(X) (테이블이 아니다, 테이블은 물리적으로 저장되어 있음)

SELECT *
FROM
(SELECT deptno, ROUND(AVG(sal), 2) avg_sal
 FROM emp);

--★ 비상호 연관
아래 쿼리는 전체 직원의 급여 평균보다 높은 급여를 받는 직원을 조회 하는 쿼리
SELECT *
FROM emp
WHERE sal >= (SELECT AVG(sal)
              FROM emp) ;
--★ 상호 연관              
직원이 속한 부서의 급여 평균보다 높은 급여를 받는 직원을 조회
SELECT empno, ename, sal, deptno
FROM emp e
WHERE e.sal > (SELECT AVG(sal)
               FROM emp a
               WHERE a.deptno = e.deptno);
               
SELECT e.empno, e.ename, e.sal, e.deptno, a.avg_sal --서브쿼리의 컬럼을 메인쿼리에서 사용할 수 없다
FROM emp e
WHERE e.sal > (SELECT AVG(sal) avg_sal
               FROM emp a
               WHERE a.deptno = e.deptno);
               
SELECT e.empno, e.ename, e.sal, e.deptno, -- 부서별 평균급여도 조회
       (SELECT AVG(sal) avg_sal
        FROM emp a
        WHERE a.deptno = e.deptno)
FROM emp e
WHERE e.sal > (SELECT AVG(sal) avg_sal
               FROM emp a
               WHERE a.deptno = e.deptno);

20번 부서의 급여 평균 (2175)
SELECT AVG(sal)
FROM emp
WHERE deptno = 20;

20번 부서의 급여 평균 (2916.666)
SELECT AVG(sal)
FROM emp
WHERE deptno = 10;

--deptno, dname, loc
INSERT INTO dept VALUES (99, 'ddit', 'daejeon');
COMMIT;

[실습 sub 4]
dept 테이블에는 신규 등록된 99번 부서에 속한 사람은 없음
직원이 속하지 않은 부서를 조회하는 쿼리를 작성해 보세요 ==> 우리가 알 수 있는건 직원이 속한 부서
SELECT * 
FROM dept
WHERE deptno NOT IN (SELECT deptno
                     FROM emp);

SELECT *
FROM dept

[실습 sub 5]
cycle, product 테이블을 이용하여 cid=1인 고객이 애음하지 않는 제품을 조회하는 쿼리를 작성
SELECT *
FROM product
WHERE pid NOT IN (SELECT PID
                  FROM cycle
                  WHERE cid=1);

SELECT *
FROM cycle
WHERE pid NOT IN (100, 100, 400, 400);



