인덱스
컬럼 구성 순서 영향있다

SELECT ename, job, ROWID
FROM emp
ORDER BY ename, job;

job, ename 컬럼으로 구성된 IDX_emp_03 인덱스 삭세

CREATE 객체타입(INDEX, TABLE, ) 객체명;
DROP 객체타입 객체명;

DROP INDEX idx_emp_03;

CREATE INDEX idx_emp_04 ON emp (ename, job);

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';
  
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

RANGE 스캔후 JOB, ENAME 으로 구성된 인덱스 찾은 후 밑에 더 만족하는 행이 있나 찾은 후 ROWID를 가지고 테이블에서 해당 행을 찾는다.

------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_04 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ENAME" LIKE 'C%' AND "JOB"='MANAGER')
       filter("JOB"='MANAGER' AND "ENAME" LIKE 'C%')

SELECT ROWID, dept.*
FROM dept;

CREATE INDEX idx_dept_01 ON dept (deptno);

emp
 1. table full access
 2. idx_emp_01
 3. idx_emp_02
 4. idx_emp_04
 
dept
 1. table full access
 2. idx_dept_01

emp(4) => dept(2) : 8
dept(2) => emp(4): 8
16가지
접근방법 * 테이블^개수

EXPLAIN PLAN FOR
SELECT ename, dname, loc
FROM emp, dept
WHERE emp.deptno = dept.deptno
  AND emp.empno = 7788;
  
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

응답성 : OLTP (Online Transaction Processing)
퍼포먼스 : OLAP (Online Analysis Processing)
        - 은행이자 계산

 순서 : 4 - 3 - 5 - 2 - 6 - 1 - 0
---------------------------------------------------------------------------------------------
| Id  | Operation                     | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT              |             |     1 |    63 |     3   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                 |             |       |       |            |          |
|   2 |   NESTED LOOPS                |             |     1 |    63 |     3   (0)| 00:00:01 |
|   3 |    TABLE ACCESS BY INDEX ROWID| EMP         |     1 |    33 |     2   (0)| 00:00:01 |
|*  4 |     INDEX RANGE SCAN          | IDX_EMP_01  |     1 |       |     1   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN           | IDX_DEPT_01 |     1 |       |     0   (0)| 00:00:01 |
|   6 |   TABLE ACCESS BY INDEX ROWID | DEPT        |     1 |    30 |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   4 - access("EMP"."EMPNO"=7788)
   5 - access("EMP"."DEPTNO"="DEPT"."DEPTNO")

정렬된 정보로 트리로 접근하여 판별 : 7788

단점 :  저장공간 차지

Index Access
 º 소수의 데이터를 조회할 때 유리(응답속도가 필용할 때)
  - Index를 사용하는 Input/Output Single Block I/O
 º 다량의 데이터를 인덱스로 접근할 경우 속도가 느리다(2~3000건)
 : 웹개발에서는 많은 데이터를 한 화면에 보여주지 않으므로 인덱스가 많이 쓰임
  
Table Access
 º 테이블에 모든 데이터를 읽고서 처리를 해야하는 경우 인덱스를 통해 모든 데이터를 테이블로 접근하는 경우보다 빠름
  - I/O 기준이 multi block
  
DDL(테이블에 인덱스가 많다면)
1. 데이블의 빈공간을 찾아 데이터를 입력한다
2. 인덱스의 구성 컬럼을 기준으로 정렬된 위치를 찾아 인덱스 저장
3. 인덱스는 B*(밸런스드) 트리 구조이고 root node부터 leaf node까지의 depth가 항상 같도록 밸런스를 유지한다
4. 즉 데이터 입력으로 밸런스가 무너질경우 밸런스를 맞추는 추가작업이 필요
5. 2~4까지의 과정을 각 인덱스 별로 반복한다.

º 인덱스가 많아 질 경우 위 과정이 인덱스 개수 만큼 반복되기 때문에 UPDATE, INSERT, DELETE시 부하가 커진다.
º 인덱스는 SELECT 실행시 조회 성능개선에 유리하지만 데이터 변경시 부하가 생긴다.
º 테이블에 과도한 수의 인덱스를 생성하는 것은 바람직 하지 않음
º 하나의 쿼리를 위한 인덱스 설계는 쉬움
º 시스템에서 실행되는 모든 쿼리를 분석하여 적절한 개수의 최적의 인덱스를 설계하는 것이 힘듬

[Index 실습 idx3]
시스템에서 사용하는 쿼리가 다음과 

달력만들기
º 데이터의 행을 열로 바꾸는 방법
º 레포트 쿼리에서 활용할 수 있는 예제 연습
주어진 것 : 년월 6자리 문자열 ex-202103
만들것 : 해당 년월에 해당하는 달력 (7칸 짜리 테이블)

20210301 - 날짜
20210302
20210303
.
.
.
20210331

'202103' => 31;
SELECT TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD')
FROM dual

주차 : IW
주간 요일 : D
--(LEVEL은 1부터 시작)
SELECT dt, d, 
       일요일이면 dt-아니면 null, 월요일이면 dt-아니면 null, 
       화요일이면 dt-아니면 null, 수요일이면 dt-아니면 null,
       목요일이면 dt-아니면 null, 금요일이면 dt-아니면 null,
       토요일이면 dt-아니면 null
FROM 
    (SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL-1) dt,
            TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL-1), 'D') d /*,
            TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL-1), 'IW') iw*/
     FROM dual
     CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD'));

-- null은 값이 무시됨 max, min 둘다 사용 가능 하지만 오라클에서는 min권장
SELECT /*DECODE(d, 1, iw+1, iw),*/ d, iw
       MIN(DECODE(d, 1, dt)) sun, MIN(DECODE(d, 2, dt)) mon,
       MIN(DECODE(d, 3, dt)) tue, MIN(DECODE(d, 4, dt)) wed,
       MIN(DECODE(d, 5, dt)) thu, MIN(DECODE(d, 6, dt)) fri,
       MIN(DECODE(d, 7, dt)) sat
FROM 
    (SELECT TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL-1) dt,
            TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL-1), 'D') d,
            TO_CHAR(TO_DATE(:YYYYMM, 'YYYYMM') + (LEVEL-1), 'IW') iw -- 주의 시작을 일요일이 아닌 월요일로 인식
     FROM dual
     CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(TO_DATE(:YYYYMM, 'YYYYMM')), 'DD'))
--GROUP BY DECODE(d, 1, iw+1, iw)
--ORDER BY DECODE(d, 1, iw+1, iw);

계층쿼리
- 조직도, BOM(Bill of Material), 게시판(답변형 게시판)  BOM은 설명서같은거
- 데이터의 상하 관계를 나타내는 쿼리
오라클 쓰는 이유라 해도 됨(계층형 잘되있음)

사용방법 
1. 시작위치를 설정
2. 행과 행의 연결 조건을 기술

SELECT empno, ename, mgr
FROM emp;

PRIOR - 이전의 , 사전의, 이미 읽은 데이터(오라클에서는 이런 뜻으로 해석하자)
CONNECT BY 내가 읽은 행의 사번과 = 앞으로 읽을 행의 mgr 컬럼;
LEVEL - 계층쿼리에서만 쓸 수 있는 특수 키워드

SELECT empno, LPAD(' ' , (LEVEL-1)*4)||ename, mgr, LEVEL
FROM emp
START WITH empno = 7839 --START WITH mgr IS NULL;
CONNECT BY PRIOR empno = mgr;
-- CONNECT BY (PRIOR empno) = mgr; 이게 셋트다 CONNECT BY mgr = PRIOR empno; 이렇게 써도 동일
--CONNECT BY mgr = PRIOR empno AND dept

SELECT LPAD('TEST', 1*10) -- 세번째 인자 안쓰면 기본값 공백 처리됨
FROM dual;

이미 읽은데이터        앞으로 읽어야 할 데이터
KING의 사번 = mgr 컬럼의 값이 KING의 사번인 녀석
empno = mgr

KING
    JONES
        SOCTT
            AMAMS
        FORD

계층쿼리 방향에 따른 분류
상향식 : 최하위 노드(lear)에서 자신의 부모를 방문하는 형태
하향식 : 최상의 노드(root)에서 모든 자식 노드를 방문하는 형태


상향식 쿼리
SMITH부터 시작하여 노드의 부모를 따라가는 계층형 쿼리
SELECT empno, LPAD(' ', (LEVEL-1)*4)||ename, mgr, LEVEL
FROM emp
START WITH empno = 7369
CONNECT BY PRIOR mgr = empno;
--CONNECT BY SMITH의 mgr컬럼값 = 앞으로 읽을 행 empno

SMITH- FORD


SELECT *
FROM dept_h;

[실습 h]
최상위 노드부터 리프 노드까지 탐색하는 계층 쿼리 작성
(LPAD를 이용한 시각적 표현까지 포함)
SELECT deptcd, p_deptcd, LEVEL, LPAD(' ', (LEVEL-1)*6)||deptnm
FROM dept_h
START WITH deptcd = 'dept0' -- p_deptcd IS NULL 동일
CONNECT BY PRIOR deptcd = p_deptcd;
-- PSUEDO CODE - 가상코드
--CONNECT BY 현재행의 deptcd = 앞으로 읽을 행의 p_deptcd

--Pre-order 방식

--binary search 알고리즘

[실습 h_2]
정보시스템부 하위의 부서계층 구조를 조회하는 쿼리를 작성
SELECT LEVEL ,deptcd, LPAD(' ', (LEVEL-1)*6)||deptnm deptnm, p_deptcd
FROM dept_h
START WITH deptcd = 'dept0_02'
CONNECT BY PRIOR deptcd = p_deptcd;

[실습 h_3]
디자인팀에서 시작하는 상향식 계층 쿼리를 작성하세요
SELECT LEVEL, deptcd, LPAD(' ', (LEVEL-1)*6)||deptnm deptnm, p_deptcd
FROM dept_h
START WITH deptcd = 'dept0_00_0'
CONNECT BY PRIOR p_deptcd = deptcd;




[실습 h_4]
계층형쿼리 복습.sql을 이용하여 테이블을 생성하고 다음과 같은 결과가 나오도록 쿼리 작성
s_id : 노드 아이디
ps_id : 부모 노드 아이디
value : 노드 값;
SELECT *
FROM h_sum;
DESC h_sum;

SELECT LPAD(' ', (LEVEL-1)*4)||s_id s_id, value
FROM h_sum
START WITH s_id = '0'
CONNECT BY PRIOR s_id = ps_id;
--CONNECT BY (현재 읽은 행=PRIOR)의 s_id = 앞으로 읽을 행의 ps_id;













