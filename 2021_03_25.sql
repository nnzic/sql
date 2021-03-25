[outerjoin5]
[outerjoin4]를 바탕으로 고객 이름 컬럼 추가하기

SELECT product.*, cycle.cid, NVL(cycle.day, 0) day, NVL(cycle.cnt, 0) cnt, customer.cnm
FROM cycle, product, customer
WHERE product.pid = cycle.pid(+) 
  AND cycle.cid(+) = 1
  AND cycle.cid = customer.cid(+);

SELECT product.*, cycle.cid, NVL(cycle.day, 0) day, NVL(cycle.cnt, 0) cnt, customer.cnm
FROM product LEFT OUTER JOIN cycle ON (product.pid = cycle.pid AND cid = 1)
     LEFT OUTER JOIN customer ON (cycle.cid = customer.cid);
     
===============================================================

[실습 sub6]
cycle 테이블을 이용하여 cid=1인 고객이 애음하는 제품중 
cid=2인 고객도 애음하는 제품의 애음정보를 조죄하는 쿼리를 작성
-- 비상호 연관 서브쿼리
SELECT *
FROM cycle
WHERE cid = 1
  AND pid IN (SELECT pid
              FROM cycle
              WHERE cid = 2);

[실습 sub7]
customer, cycle, product 테이블을 이용하여 cid=1인 고객이 
애음하는 제품중 cid=2인 고객도 애음하는 제품의 애음정보를 조회하고
고객명과 제품명까지 포함하는 쿼리를 작성

SELECT 
--cnm, cc.*, pnm
*
FROM customer, product, 
(SELECT * FROM cycle
 WHERE cid = 1
  AND pid IN (SELECT pid
              FROM cycle
              WHERE cid = 2)) cycle
WHERE customer.cid = cycle.cid
  AND cycle.pid = product.pid;

SELECT *
FROM cycle, customer, product
WHERE cycle.cid = 1
  AND cycle.cid = customer.cid
  AND cycle.pid = product.pid
  AND cycle.pid IN (SELECT pid FROM cycle WHERE cid = 2);
  
==========================================================

■ EXISTS 서브쿼리 연산자 : 단항
[NOT] IN : WHERE 컬럼 | EXPRESSION IN (값1, 값2, 값3, ...)
[NOT] EXISTS : WHERE EXISTS (서브쿼리)
   ==> 서브쿼리의 실행결과로 조회되는 행이 **하나라도 있으면 TRUE, 없으면 FALSE (값이 중요한게 아님)
   EXISTS 연산자와 사용되는 서브쿼리는 상호 연관, 비상호연관 서브쿼리 둘다 사용 가능하지만
   행을 제한하기 위해서 상호연관 서브쿼리와 사용되는 경우가 일반적이다
   
   서브쿼리에서 EXISTS 연산자를 만족하는 행을 하나라도 발견을 하면 더이상 진행하지 않고 효율적으로 일을 끊어 버린다.
   서브쿼리가 1억건이라 하더라도 10번째 행에서 EXISTS 연산을 만족하는 행을 발견하면 나머지 9999만 건 정도의 데이터는 확인 안한다.
연산자 고민 : 몇항 인지? 대다수는 2항

-- 매니저가 존재하는 직원
SELECT *
FROM emp
WHERE mgr IS NOT NULL;
-- 상호 연관 서브쿼리 관습적으로 'X' 씀
SELECT *
FROM emp e
WHERE EXISTS (SELECT 'X'
              FROM emp m
              WHERE e.mgr = m.empno);
-- 비상호 연관 서브쿼리로 모두 true로 emp행 모두 출력, 일반적으로 비상호 연관 서브쿼리 안쓴다 all or nothing 이므로 별 의미 없다.
SELECT *
FROM emp e
WHERE EXISTS (SELECT 'X'
              FROM dual);

SELECT *
FROM dual
WHERE EXISTS (SELECT 'X' FROM emp WHERE deptno = 10);

[실습 sub9]
--cycle, product 테이블을 이용하여 cid=1인 고객이 애음하는 제품을 조회하는
--쿼리를 EXISTS 연산자를 이용하여 작성하세요
SELECT *
FROM product
WHERE EXISTS (SELECT 'X' 
              FROM cycle 
              WHERE cid = 1
                AND product.pid = cycle.pid);
SELECT *
FROM product
WHERE NOT EXISTS (SELECT 'X' 
                  FROM cycle 
                  WHERE cid = 1
                    AND product.pid = cycle.pid);

■ 집합연산
UNION : [A, B] U [A, C] = [A, A, B, C] ==> [A, B, C]
수학에서 이야기하는 일반적인 합집합

UNION ALL : [A, B] U [A, C] = [A, A, B, C]
중복을 허용하는 합집합

- 데이터를 확장하는 SQL의 한 방버
- 집합에는 중복, 순서가 없다.

º 집합연산 : 행을 확장 -> 위 아래
   -위 아래 집합의 COL의 개수와 타입이 일치해야 한다
º JOIN : 열확장 -> 양 옆

□ UNION : 합집합, 두개의 SELECT 결과를 하나로 합친다, 단 중복되는 데이터는 중복을 제거한다
    ==> 수학적 집합 개념과 동일
SELECT empno, ename, NULL --컬럼 수를 맞추기 위해 가짜 컬럼 하나 만들어준다.
FROM emp
WHERE empno IN (7369,7499)

UNION

SELECT empno, ename, deptno
FROM emp
WHERE empno IN (7369,7521);

□ UNION ALL : 중복을 허용하는 합집합
              중복 제거 로직이 없기 때문에 속도가 빠르다(중복을 제거하지 않음 - > UNION 연산자에 비해 속도가 빠르다)
              합집합 하려는 집합간 중복이 없다는 것을 알고 있을 경우 UNION 연산자 보다 UNION ALL 연산자가 유리하다
SELECT empno, ename
FROM emp
WHERE empno IN (7369,7499)

UNION ALL

SELECT empno, ename
FROM emp
WHERE empno IN (7369,7521);

□ INTERSECT 두 집합중 중복되는 부분만 조회(교집합)
SELECT empno, ename
FROM emp
WHERE empno IN (7369,7499)

INTERSECT

SELECT empno, ename
FROM emp
WHERE empno IN (7369,7521);

□ MINUS : 한쪽 집합에서 다른 한쪽 집합을 제외한 나머지 요소들을 반환
차집합 : 한 집합에 속하는 데이터
SELECT empno, ename
FROM emp
WHERE empno IN (7369,7499)

MINUS

SELECT empno, ename
FROM emp
WHERE empno IN (7369,7521);

■ 교환 법칙
A U B == B U A (UNION, UNION ALL)
A ^ B == B ^ A 
A - B != B - A => 합집합의 순서에 따라 결과가 달라질 수 있다[주의]

★ 집합연산 특징
1. 집합연산의 결과로 조회되는 데이터의 컬럼 이름은 첫번째 집합의 컬럼을 따른다.(윗쪽 에만 알리아스 주면됨)
2. 집합연산의 결과를 정렬하고 싶으면 가장 마지막 집합 뒤에 ORDER BY를 기술한다
  - 개별 집합에 ORDER BY 를 사용한 경우 에러
   · 단 ORDER BY를 적용한 인라인 뷰를 사용하는 것은 가능
3. 중복 제거 된다 (예외 UNION ALL)
[4. 9i 이전버전 그룹연산을 하게되면 기본적으로 오름차순으로 정렬되어 나온다
    이후 버전 ==> 정렬을 보장하지 않음]

■ DML
º SELECT
º 데이터 신규 입력: INSERT
º 기존 데이터 수정 : UPDATE
º 기존 데이터 삭제 : DELETE

□ INSERT 문법
INSERT INTO 테이블명 [(column),]VALUES ((value,))
INSERT INTO 테이블명 (컬럼명1, 컬럼명2, 컬럼명3, ...)
            VALUES (값1, 값2, 값3, ...)
만약 테이블에 존재하는 모든 컬럼에 데이터를 입력하는 경우 컬럼명은 생략 가능하고
값을 기술하는 순서를 테이블에 정의된 컬럼 순서와 일치시킨다
INSERT INTO 테이블명 VALUES (값1, 값2, 값3, ...)
INSERT INTO dept VALUES (99, 'ddit', 'deajeon');
INSERT INTO dept (deptno, dname, loc)
          VALUES (99, 'ddit', 'deajeon'); -- 데이터 중복을 허용하지 않게 하려면 추가설정 필요
          
DESC dept;
INSERT INTO emp (empno, ename, job, hiredate, sal, comm)  -- empno가 not null 조건이라 꼭 입력해줘야함
         VALUES (9998, 'sally', 'RANGER', TO_DATE('2021-03-25', 'YYYY-MM-DD'), 1000, NULL);

select * 
from emp;

★ 여러건을 한번에 입력하기 -- INSERT에서 한건한건 입력하는 것보다 테이블 가공을 통해 SELECT문으로 넣는게 빠름
INSERT INTO 테이블명
SELECT 쿼리

INSERT INTO dept
SELECT 90, 'DDIT', '대전' FROM dual UNION ALL
SELECT 80, 'DDIT8', '대전' FROM dual;

ROLLBACK; -- 트랜잭션에 묶여 있던 처리과정들 취소

□ UPDATE : 테이블에 존재하는 기존 데이터의 값을 변경
UPDATE 테이블명 SET 컬럼명1=값1, 컬럼명2=값2, 컬럼명3=값3, ...
WHERE ; 
★★ WHERE 절이 누락 되었는지 확인 ★★
WHERE 절이 누락 된 경우 테이블의 모든 행에 대해 업데이트를 진행

부서번호 99번 부서정보를 부서명 = 대덕IT로, loc = 영민빌딩으로 변경
UPDATE dept SET dname='대덕IT', loc='영민빌딩'
WHERE deptno = 99;

SELECT *
FROM dept;

  




