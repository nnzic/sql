월별실적
                반도체     핸드폰     냉장고
2021년 1월 :      500       300       400
2021년 2월 :        0         0         0
2021년 3월 :      500       300       400
.
.
.
2021년 12월 :      500       300       400

테이블 : 
SELECT buy_date, buy_prod, prod_id, prod_name, NVL(buy_qty, 0)
FROM prod, buyprod
WHERE buyprod.buy_prod(+) = prod.prod_id
  AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');
  
SELECT buy_date, buy_prod, prod_id, prod_name, NVL(buy_qty, 0)
FROM prod, buyprod
WHERE buyprod.buy_prod = prod.prod_id
  AND buy_date = TO_DATE('2005/01/25', 'YYYY/MM/DD');
  
[outerjoin2] 
outerjoin1에서 작업을 시작. buy_date컬럼이 null인 항목이 안나오도록 
다음처럼 데이터를 채워지도록 쿼리를 작성 하세요.
SELECT NVL(buy_date, '2005/01/25'), buy_prod, prod_id, prod_name, NVL(buy_qty, 0)
FROM prod, buyprod
WHERE buyprod.buy_prod(+) = prod.prod_id
  AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');
  
SELECT TO_DATE('2005/01/25', 'YYYY/MM/DD'), buy_prod, prod_id, prod_name, NVL(buy_qty, 0)
FROM prod, buyprod
WHERE buyprod.buy_prod(+) = prod.prod_id
  AND buy_date(+) = TO_DATE('2005/01/25', 'YYYY/MM/DD');

[outerjoin4]
cycle, product 테이블을 이용하여 고객이 애음하는 제품 명칭을 표현하고, 애음하지 않는 제품도
다음과 같이 조회되도록 쿼리를 작성하세요(고객은 cid=1인 고객만 나오도록 제한, null처리)
SELECT *
FROM cycle; 

SELECT *
FROM product; 

SELECT product.*, cycle.cid, cycle.day, cycle.cnt
FROM product LEFT OUTER JOIN cycle ON (product.pid = cycle.pid AND cid = 1);

SELECT product.*, :cid, NVL(cycle.day, 0) day, NVL(cycle.cnt, 0) cnt
FROM product LEFT OUTER JOIN cycle ON (product.pid = cycle.pid AND cid = :cid);

SELECT product.*, :cid, NVL(cycle.day, 0) day, NVL(cycle.cnt, 0) cnt
FROM cycle, product
WHERE product.pid = cycle.pid(+)
  AND cid(+) = :cid

[outerjoin5] ******* 과제 *******
[outerjoin4]를 바탕으로 고객 이동 컬럼 추가하기

WHERE, GROUP BY(그룹핑), JOIN

JOIN
문법
 : ANSI / ORACLE
논리적 형태 
 : SELF JOIN, NON-EQUI-JOIN <==> EQUI-JOIN
연결조건 성공 실패에 따라 조회여부 결정
 : OUTERJOIN <==> INNER JOIN : 연결이 성공적으로 이루어진 행에 대해서만 조회가 되는 조인
 
SELECT * 
FROM dept INNER JOIN emp ON (dept.deptno = emp.deptno);

CROSS JOIN
 º 별도의 연결 조건이 없는 조인
 º 묻지마 조인
 º 두 테이블의 행간 연결가능한 모든 경우의 수로 연결
  ==> CROSS JOIN의 결과는 두 테이블의 행의 수를 곱한 값과 같은 행이 반환된다.
 [º 데이터 복제를 위해 사용] 지금은 몰라도 됨(적당한 예제시 설명)
 
SELECT *
FROM emp, dept;
-- 동일
SELECT *
FROM emp CROSS JOIN dept;

[실습 corssjoin 1]
customer, product 테이블을 이용하여 고객이 애음 가능한 모든 제품의 정보를 결합하여 다음과 같이 조회되도록 쿼리를 작성
SELECT *
FROM customer, product; -- 고객이 먹을 수 있는 전체 조합

==================================BURGERSTORE 실습=================================================
-- 대전 중구
도시발전지수 : (KFC + 맥도날드 + 버거킹) / 롯데리아

SELECT SIDO, SIGUNGU, 도시발전지수
FROM BURGERSTORE
WHERE SIDO = '대전'
  AND SIGUNGU = '중구'

SELECT A.SIDO, A.SIGUNGU, (MAC_CNT + KFC_CNT + KING_CNT) / LOTTE_CNT "도시발전지수"
FROM 
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) MAC_CNT
      FROM BURGERSTORE
      WHERE SIDO = '대전'
        AND SIGUNGU = '중구'
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'MACDONALD') A,
      
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) KFC_CNT
      FROM BURGERSTORE
      WHERE SIDO = '대전'
        AND SIGUNGU = '중구'
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'KFC') B,
      
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) KING_CNT
      FROM BURGERSTORE
      WHERE SIDO = '대전'
        AND SIGUNGU = '중구'
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'BURGER KING') C,
      
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) LOTTE_CNT
      FROM BURGERSTORE
      WHERE SIDO = '대전'
        AND SIGUNGU = '중구'
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'LOTTERIA') D
WHERE A.SIDO||A.SIGUNGU = B.SIDO||B.SIGUNGU
  AND B.SIDO||B.SIGUNGU = C.SIDO||C.SIGUNGU
  AND C.SIDO||C.SIGUNGU = D.SIDO||D.SIGUNGU;


SELECT :SIDO, :SIGUNGU, (MAC_CNT + KFC_CNT + KING_CNT) / LOTTE_CNT "도시발전지수"
FROM 
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) MAC_CNT
      FROM BURGERSTORE
      WHERE SIDO = :SIDO
        AND SIGUNGU = :SIGUNGU
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'MACDONALD') A,
      
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) KFC_CNT
      FROM BURGERSTORE
      WHERE SIDO = :SIDO
        AND SIGUNGU = :SIGUNGU
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'KFC') B,
      
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) KING_CNT
      FROM BURGERSTORE
      WHERE SIDO = :SIDO
        AND SIGUNGU = :SIGUNGU
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'BURGER KING') C,
      
     (SELECT SIDO, SIGUNGU, STORECATEGORY, COUNT(*) LOTTE_CNT
      FROM BURGERSTORE
      WHERE SIDO = :SIDO
        AND SIGUNGU = :SIGUNGU
      GROUP BY SIDO, SIGUNGU, STORECATEGORY
      HAVING STORECATEGORY = 'LOTTERIA') D
WHERE A.SIDO||A.SIGUNGU = B.SIDO||B.SIGUNGU
  AND B.SIDO||B.SIGUNGU = C.SIDO||C.SIGUNGU
  AND C.SIDO||C.SIGUNGU = D.SIDO||D.SIGUNGU;

**** 정 답 ****
-- 행을 컬럼으로 변경(PIVOT)
SELECT sido, sigungu,
       SUM(DECODE(storecategory, 'BURGER KING', 1, 0)) bk,
       SUM(DECODE(storecategory, 'KFC', 1, 0)) kfc,
       SUM(DECODE(storecategory, 'MACDONALD', 1, 0)) mac,
       SUM(DECODE(storecategory, 'LOTTERIA', 1, 0)) lote      
FROM burgerstore
GROUP BY sido, sigungu
ORDER BY sido, sigungu;

SELECT sido, sigungu,
       ROUND( (SUM(DECODE(storecategory, 'BURGER KING', 1, 0)) +
               SUM(DECODE(storecategory, 'KFC', 1, 0)) +
               SUM(DECODE(storecategory, 'MACDONALD', 1, 0)) ) /
               DECODE(SUM(DECODE(storecategory, 'LOTTERIA', 1, 0)), 0, 1, SUM(DECODE(storecategory, 'LOTTERIA', 1, 0))), 2) idx
FROM burgerstore
GROUP BY sido, sigungu
ORDER BY idx DESC;


SELECT *
FROM dual
















