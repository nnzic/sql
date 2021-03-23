SELECT *
FROM prod;

SELECT
FROM lprod;

[실습 join1]
SELECT lprod.lprod_gu, lprod.lprod_nm, lprod_nm, prod.prod_id, prod.prod_name
FROM prod, lprod
WHERE lprod.lprod_gu = prod.prod_lgu;

[실습 join2]
erd다이어그램을 참고하여 buyer, prod 테이블을 조인하여 buyer별 담당하는 제품 정보를
다음과 같은 결과가 나오도록 쿼리를 작성해보세요.
SELECT buyer.buyer_id, buyer.buyer_name, prod.prod_id, prod.prod_name
FROM buyer, prod
WHERE buyer.buyer_id = prod.prod_buyer;

[실습 join3]
erd다이어그램을 참고하여 member, cart, prod 테이블을 조인하여 회원별 장바구니에 담은
제품 정보를 다음과 같은 결과가 나오는 쿼리를 작성해보세요.
SELECT member.mem_id, member.mem_name, prod.prod_id, prod.prod_name, cart.cart_qty
FROM  member, cart, prod
WHERE member.mem_id = cart.cart_member
  AND cart.cart_prod = prod.prod_id;

SELECT member.mem_id, member.mem_name, prod.prod_id, prod.prod_name, cart.cart_qty
FROM member JOIN cart ON (member.mem_id = cart.cart_member)
            JOIN prod ON (cart.cart_prod = prod.prod_id);


SELECT *
FROM product;

[실습 join 4]
erd다이어그램을 참고하여 customner, cycle 테이블을 조인하여 
고객별 애음제품, 애음요일, 개수를 다음과 같은 결과가 나오도록 쿼리를 작성하시오.
(고객명이 brown, sally인 고객만 조회)
(*정렬과 관계없이 값이 맞으면 정답)
SELECT customer.cid, cnm, cycle.pid, day, cnt
FROM customer, cycle
WHERE customer.cid = cycle.cid
  AND cnm IN ('brown', 'sally');
  
[실습 join 5]
erd다이어그램을 참고하여 customner, cycle, product 테이블을 조인하여 
고객별 애음제품, 애음요일, 개수, 제품명를 다음과 같은 결과가 나오도록 쿼리를 작성하시오.
(고객명이 brown, sally인 고객만 조회)
(*정렬과 관계없이 값이 맞으면 정답)
SELECT customer.cid, cnm, cycle.pid, pnm, day, cnt
FROM customer, cycle, product
WHERE customer.cid = cycle.cid
  AND cycle.pid = product.pid
  AND cnm IN ('brown', 'sally');

[실습 join 6]
erd다이어그램을 참고하여 customner, cycle, product 테이블을 조인하여 
애음요일과 관계없이 고객별 애음 제품별, 개수의 합과, 제품명을 다음과 같은 결과가 나오도록 쿼리를 작성하시오.
(*정렬과 관계없이 값이 맞으면 정답)  
SELECT customer.cid, cnm, cycle.pid, pnm, SUM(cycle.cnt) cnt
FROM customer, cycle, product
WHERE customer.cid = cycle.cid
  AND cycle.pid = product.pid
  --AND cnm IN ('brown', 'sally')
GROUP BY customer.cid, cnm, cycle.pid, pnm;

SELECT a.*
FROM(
SELECT cid, pid, count(*)
FROM cycle
GROUP BY cid, pid) a;


[실습 join 7]
erd다이어그램을 참고하여 cycle, product 테이블을 이용하여 
제품별, 개수의 합과, 제품명을 다음과 같은 결과가 나오도록 쿼리를 작성해보세요
(*정렬과 관계없이 값이 맞으면 정답)
SELECT cycle.pid, product.pnm, SUM(cycle.cnt) cnt
FROM cycle, product
WHERE cycle.pid = product.pid
GROUP BY cycle.pid, product.pnm;

아우터조인 : 연결조인이 실패했을 경우 한쪽 테이블 정보는 나옴

OUTER JOIN : 컬럼 연결이 실패해도 [기준]이 되는 테이블 쪽의 컬럼 정보는 나오도록 하는 조인
LEFT OUTER JOIN : 기준이 왼쪽에 기술한 테이블이 되는 OUTER JOIN
RIGHT OUTER JOIN : 기준이 오른쪽에 기술한 테이블이 되는 OUTER JOIN
FULL OUTER JOIN : LEFT OUTER + RIGHT OUTER - 중복 데이터 제거

테이블1 JOIN 테이블2
테이블1[기준] LEFT OUTER JOIN 테이블2
==
테이블2 RIGHT OUTER JOIN 테이블1[기준]


직원의 이름, 직원의 상사 이름 두개의 컬럼이 나오도록 join query 작성
13건(KING이 안나와도 괜찮음)
SELECT e.ename, m.ename, e.mgr
FROM emp e, emp m
WHERE e.mgr = m.empno;

SELECT e.ename, m.ename
FROM emp e JOIN emp m ON (e.mgr = m.empno);

SELECT e.ename, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);

SELECT e.ename, m.ename
FROM emp m RIGHT OUTER JOIN emp e ON (e.mgr = m.empno);


-- ORACLE SQL OUTER JOIN 표기 : (+)
-- OUTER 조인으로 인해 데이터가 안나오는 쪽 컬럼에 (+)를 붙여준다.
SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr = m.empno(+);

=============================== 주 의 =================================
-- outer join 연결조건에 조건을 추가하였을 때 오른쪽에 데이터 출력됨
SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno AND m.deptno = 10);
-- oracle sql 표현법 오른쪽 컬럼에 데이터가 출력되게 하는경우
SELECT e.ename, m.ename, m.deptno
FROM emp e, emp m
WHERE e.mgr = m.empno(+)
  AND m.deptno(+) = 10;
  
-- 먼저 아우터 조인이 되고 조인된 테이블에서 추가 조건만 출력됨
SELECT e.ename, m.ename, m.deptno
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno)
WHERE m.deptno = 10;

SELECT e.ename, m.ename, m.deptno
FROM emp e, emp m
WHERE e.mgr = m.empno(+)
  AND m.deptno = 10;
======================================================================

SELECT e.ename, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);

SELECT e.ename, m.ename
FROM emp m RIGHT OUTER JOIN emp e ON (e.mgr = m.empno);

--데이터 몇건이 나올까? 그려볼것 21건?
SELECT e.ename, m.ename
FROM emp e RIGHT OUTER JOIN emp m ON (e.mgr = m.empno);

--FULL OUTER : LEFT OUTER + RIGHT OUTER - 중복 데이터 1개만 남기고 제거
SELECT e.ename, m.ename
FROM emp e LEFT OUTER JOIN emp m ON (e.mgr = m.empno);

SELECT e.ename, m.ename
FROM emp e FULL OUTER JOIN emp m ON (e.mgr = m.empno);

-- FULL OUTER 조인은 오라클 SQL 문법으로 제공하지 않는다.
SELECT e.ename, m.ename
FROM emp e, emp m
WHERE e.mgr(+) = m.empno(+);


[실습 outer join 1]
SELECT *
FROM buyprod
WHERE buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD');

SELECT count(*)
FROM prod;

모든 제품을 다 보여주고, 실제 구매가 있을 때는 구매수량을 조회, 없을 경우는 null
제품 코드 : 수량
SELECT buy_date, buy_prod, prod_id, prod_name, buy_qty
FROM prod, buyprod
WHERE buyprod.buy_prod(+) = prod.prod_id
  AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');

SELECT buy_date, buy_prod, prod_id, prod_name, buy_qty
FROM buyprod RIGHT OUTER JOIN prod ON (buyprod.buy_prod = prod.prod_id AND buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD'));


--==============================================================================================================
-- 과제
[실습 join 8]
erd 다이어그램을 참고하여 countries, regions 테이블을 이용하여 지역별
소속 국가를 다음과 같은 결과가 나오도록 쿼리를 작성해보세요(지역은 유럽만 한정)
SELECT c.region_id, region_name, country_name
FROM regions r, countries c
WHERE r.region_id = c.region_id
  AND region_name IN ('Europe');
  

[실습 join 9]
erd 다이어그램을 참고하여 countries, rejions, locaions테이블을 이용하여
지역별 소속 국가, 국가에 소속된 도시 이름을 다음과 같은 결과가 나오도록 쿼리를 작성해보세요(지역은 유럽만 한정)
SELECT c.region_id, region_name, country_name, city, location_id
FROM regions r, countries c, locations l
WHERE r.region_id = c.region_id
  AND c.country_id = l.country_id
  AND region_name IN ('Europe');

[실습 join 10]
erd 다이어그램을 참고하여 countries, rejions, locaions, departments테이블을 이용하여
지역별 소속 국가, 국가에 소속된 도시 이름 및 도시에 있는 부서를 
다음과 같은 결과가 나오도록 쿼리를 작성해보세요(지역은 유럽만 한정)
SELECT c.region_id, region_name, country_name, city, department_name, department_id
FROM regions r, countries c, locations l, departments d
WHERE r.region_id = c.region_id
  AND c.country_id = l.country_id
  AND l.location_id = d.location_id
  AND region_name IN ('Europe');
  
SELECT *
FROM regions;

SELECT *
FROM countries ;

SELECT *
FROM locations ;

SELECT *
FROM departments ;

SELECT *
FROM job_history ;

SELECT *
FROM employees ;


[실습 join 11]
erd 다이어그램을 참고하여 countries, rejions, locaions, departments, employees 테이블을 이용하여
지역별 소속 국가, 국가에 소속된 도시 이름 및 도시에 있는 부서, 부서에 소속된 직원 정보를 다음과 같은 
결과가 나오도록 쿼리를 작성해보세요(지역은 유럽만 한정)
SELECT c.region_id, region_name, country_name, city, department_name, first_name || last_name AS name
FROM regions r, countries c, locations l, departments d, employees e
WHERE r.region_id = c.region_id
  AND c.country_id = l.country_id
  AND l.location_id = d.location_id
  AND d.department_id = e.department_id
  AND region_name IN ('Europe');

실습 join 12]
erd 다이어그램을 참고하여 employees, jobs 테이블을 이용하여 직원의 담당업무 명칭을
포함하여 다음과 같은 결과가 나오도록 쿼리를 작성해보세요.
SELECT employee_id, first_name || last_name AS name, j.job_id, job_title
FROM employees e, jobs j
WHERE e.job_id = j.job_id

실습 join 13]
erd 다이어그램을 참고하여 employees, jobs 테이블을 이용하여 직원의 담당업무 명칭,
직원의 매니저 정보 포함하여 다음과 같은 결과가 나오도록 쿼리를 작성해보세요.
SELECT m.employee_id mgr_id, m.first_name || m.last_name AS mgr_name,
       e.employee_id, e.first_name || e.last_name AS name, j.job_id, job_title
FROM employees e, jobs j, employees m
WHERE e.job_id = j.job_id
  AND e.manager_id = m.employee_id;












