
INSERT 단건, 여러건

INSERT INTO 테이블명
SELECT ...
--9999사번(empno)을 갖는 brown 직원(ename)을 입력
INSERT INTO emp (empno, ename) VALUES(9999, 'brown');
INSERT INTO emp (ename, empno) VALUES('brown', 9999);


UPDATE 테이블명 SET 컬럼명1 = (스칼라 서브쿼리),
                   컬럼명2 = (스칼라 서브쿼리),
                   컬럼명3 = 'TEST';
--9999번 직원의 deptno와 job 정보를 SMITH 사원의 deptno, job 정보로 업데이트
UPDATE emp SET deptno = (SELECT deptno
                         FROM emp
                         WHERE ename = 'SMITH'),
               job = (SELECT job
                      FROM emp
                      WHERE ename = 'SMITH')
WHERE empno = 9999; --이렇게 잘 안씀

MERGE -- 나중에~

DESC emp;
SELECT * FROM emp;

■ DELETE : 기존에 존재하는 데이터를 삭제
DELETE 테이블명
WHERE 조건;

DELETE emp;-- 테이블 전체 삭제됨 주의! where조건 확인

--삭제 테스트를 위한 데이터 입력
INSERT INTO emp (empno, ename) VALUES(9999, 'brown');

DELETE emp
WHERE empno = 9999;

-- 업데이트, 삭제 전에 SELECT문으로 먼저 확인해 보는 것도 좋은 방법
mgr가 7698사번(BLAKE)인 직원들 모두 삭제
SELECT *
FROM emp
WHERE mgr = 7698;

DELETE emp
WHERE empno IN (SELECT empno
                FROM emp
                WHERE mgr = 7698);
ROLLBACK;

DBMS는 DML 문장을 실행하게 되면 LOG를 남긴다
    UNDO(REDE) LOG
    
■ 로그를 남기지 않고 더 빠르게 데이터를 삭제하는 방법 : TRUNCATE
 º DML이 아니고 DDL이다
 º ROLLBACK이 불가(복구 불가)
 º 주로 테스트 환경에서 사용
TRUNCATE TABLE 테이블명;


CREATE TABLE emp_test AS
SELECT *
FROM emp;

SELECT *
FROM emp_test;

TRUNCATE TABLE emp_test;
ROLLBACK;

논리적인 일의 단위

■ 트랜잭션
관련된 여러 작업을 하나
첫번째 DML문을 실행함과 동시에 트랜잭션 시작
이후 다른 DML문 실행
COMMIT : 트랜잭션을 종료, 데이터를 확정
ROLLBACK : 트랜잭션에서 실행한 dml문을 취소하고 트랜잭션 종료

게시글 입력시(제목, 내용, 복수개의 첨부파일)
게시글 테이블, 게이글 첨부파일 테이블
1.dml : 게시글 입력
2.dml : 게시글 첨부파일입력
1번 dml은 정상적으로 실행후 2번 dml실행시 에러가 발생한다면?


☞ 읽기 일관성 (DAP, SQLP에 관련내용 나옴)
읽기 일관성 레벨(0 -> 3)
트랜잭션에서 실행한 결과가 다른 트랜잭션에 어떻게 영향을 미치는지

정의한 레벨(단계)
LEVEL 0 : READ UNCOMMITED
 - dirty(변경이 가해졌다) read
 - 커밋을 하지 않은 변경 사항도 다른 트랜잭션에서 확인 가능
 - oracle에서는 지원하지 않음

LEVEL 1 : READ COMMITED
- 대부분의 DBMS 읽기 일관성 설정 레벨
- 커밋한 데이터만 다른 트랜잭션에서 읽을 수 있다
- 커밋하지 않은 데이터는 다른 트랜잭션에서 볼 수 없다.

LEVEL 2 : Reapeatable Read
- 선행 트랜잭션에서 읽은 데이터를 후행 트랜잭션에서 수정하지 못하도록 방지
- 선행 트랜잭션에서 읽었던 데이터를 트랜잭션의 마지막에서 다시 조회를 해도 동일한 결과가 나오게끔 유지
- 신규 입력 데이터에 대해서는 막을 수 없음
  ==> Phantom Read(유령 읽기) : 없던 데이터가 조회 되는 현상
  기존 데이터에 대해서는 동일한 데이터가 조회되도록 유지
- oracle에서는 LEVEL2에 대해 공식적으로 지원하지 않으나 FOR UPDATE 구문을 이용하여 효과를 만들어 낼 수 있다.
  SELET * FROM emp FOR UPDATE; --트랜재션 자원을 잡아둠 ROLLBACK 으로 해제
  
LEVEL 3 : Serializable Read 직열화 읽기
- 후행 트랜잭션에서 수정, 입력 샂제한 데이터가 선행 트랜잭션에 영향을 주지 않음
- 선 : 데이터 조회(14)
  후 : 신규 입력(15)
  선 : 데이터 조회(14)


■ 인덱스
 º 눈에 안보여
 º 테이블의 일부 컬럼을 사용하여 데이터를 정렬한 객체(테이블이 존재해야지만 생성가능)
    ==> 원하는 데이터를 빠르게 찾을 수 있다
 º 일부 컬럼과 함께 그 컬럼의 행을 찾을 수 있는 ROWID가 같이 저장됨
 º ROWID : 테이블에 저장된 행의 물리적 위치, 집 주소 같은 개념
           주소를 통해서 해당 행의 위치로 빠르게 접근하는 것이 가능
           데이터가 입력이 될 때 생성
   -- INDEX는 정렬이 되어있기 때문에 해당 위치를 빠르게 찾을 수 있다
SELECT emp.*
FROM emp
WHERE empno = 7782; -- 전체 행을 탐색 후 해당 조건을 조회

SELECT ROWID, emp.*
FROM emp;

SELECT ROWID, emp.*
FROM emp
WHERE ROWID = 'AAAE5gAAFAAAACLAAA';

--실행계획 먼저실행
EXPLAIN PLAN FOR
SELECT emp.*
FROM emp
WHERE empno = 7782;
--DBMS_XPLAN(자파의 패키지로 생각하자), 그 후 실행
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 3956160932
 
---------------------------------- 뒤의 숫자는 상대적인 것이기 때문에 신경쓰지 말자
| Id  | Operation         | Name | 
----------------------------------
|   0 | SELECT STATEMENT  |      | 
|*  1 |  TABLE ACCESS FULL| EMP  | 
---------------------------------- 
Predicate Information (identified by operation id):
--------------------------------------------------- 
   1 - filter("EMPNO"=7782)

■ 오라클 객체 생성
CREATE 객체 타입(INDEX, TABLE, ...) 객체명
       int 변수명

■ 인덱스 생성
CREATE [UNIQUE] INDEX 인덱스이름 ON 테이블명(컬럼1, 컬럼2, ...);

CREATE UNIQUE INDEX PK_emp ON emp(empno);
--emp테이블에 인덱스 생성 후 실행계획 다시 살펴보자!!
EXPLAIN PLAN FOR
SELECT emp.*
FROM emp
WHERE empno = 7782;
--DBMS_XPLAN(자파의 패키지로 생각하자), 그 후 실행
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 2949544139
실행순서 : 2 - 1 - 0
--------------------------------------------------------------------------------------
| Id  | Operation                   | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |        |     1 |    87 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP    |     1 |    87 |     1   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_EMP |     1 |       |     0   (0)| 00:00:01 |
--------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------
   2 - access("EMPNO"=7782) --이 위치를 찾아갔다(빠르게 접근 했다)
   -- 해당 인덱스를 찾고 ROWID로 해당 데이터를 최종적으로 찾아준다

-- emp 테이블의 인덱스는 이러한 값을 가진다.
SELECT empno, ROWID
FROM emp
ORDER BY empno;


EXPLAIN PLAN FOR
SELECT empno
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 56244932
 실행순서 : 1 - 0 // 인덱스에 empno값을 갖고 있기 때문에 테이블까지 접근 안함
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |     1 |    13 |     0   (0)| 00:00:01 |
|*  1 |  INDEX UNIQUE SCAN| PK_EMP |     1 |    13 |     0   (0)| 00:00:01 |
---------------------------------------------------------------------------- 
Predicate Information (identified by operation id):
--------------------------------------------------- 
   1 - access("EMPNO"=7782) 



-- 인덱스 삭제
DROP INDEX PK_EMP;

-- 
CREATE INDEX IDX_emp_01 ON emp (empno);

EXPLAIN PLAN FOR
SELECT *
FROM emp
WHERE empno = 7782;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

Plan hash value: 4208888661
 
------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_01 |     1 |       |     1   (0)| 00:00:01 | 
------------------------------------------------------------------------------------------
// ★ UNIQUE 인덱스가 아닐경우 RANGE 인덱스의 전체 범위를 조회(중복이 있을 수 있기 때문이다)
 Predicate Information (identified by operation id):
--------------------------------------------------- 
   2 - access("EMPNO"=7782)
 


--job 컬럼에 인덱스 생성
CREATE INDEX idx_emp_02 ON emp (job);

SELECT job, ROWID
FROM emp
ORDER BY job;

EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE job = 'MANAGER';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     3 |   261 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     3 |   261 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_02 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
 Predicate Information (identified by operation id):
---------------------------------------------------
 2 - access("JOB"='MANAGER')



EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
 
------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    87 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_02 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
--------------------------------------------------- 
   1 - filter("ENAME" LIKE 'C%')
   2 - access("JOB"='MANAGER')



CREATE INDEX IDX_emp_03 ON emp (job, ename);

SELECT job, ename, ROWID
FROM emp
ORDER BY job, ename;

EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE 'C%';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);
 
------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    87 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_03 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
--------------------------------------------------- 
   2 - access("JOB"='MANAGER' AND "ENAME" LIKE 'C%') 그 위치를 찾아 갔다
       filter("ENAME" LIKE 'C%') 읽고 나서 버렸다

access 그 위치를 찾아 갔다
filter 읽고 나서 버렸다



EXPLAIN PLAN FOR
SELECT * 
FROM emp
WHERE job = 'MANAGER'
  AND ename LIKE '%C'; -- 인덱스에 일치하는 것이 없다

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);

------------------------------------------------------------------------------------------
| Id  | Operation                   | Name       | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |            |     1 |    87 |     2   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID| EMP        |     1 |    87 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_EMP_02 |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
--------------------------------------------------- 
   1 - filter("ENAME" IS NOT NULL AND "ENAME" LIKE '%C') -- 오라클에서 filter까지 실행계획을 세웠지만 이 경우에는 실행까진 안됨
   2 - access("JOB"='MANAGER') -- 이 단계에서 찾아짐
 
 
 
 
 
 