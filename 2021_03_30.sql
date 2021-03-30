
★★★★★★★★★★★★★★★★★★
■ 실행순서 : [START WITH]는 항상 이부분에서 실행되는 것은 아니다(보편적인 상황은 아래를 생각하자)
FROM -> [START WITH] -> WHERE -> GROUP BY -> SELECT -> ORDER BY

SELECT
FROM
WHERE
START WITH
CONNECT BY
GROUP BY
ORDER BY

가지치기 : Pruning branck

SELECT empno, LPAD(' ', (LEVEL-1)*4)||ename AS ename, mgr
FROM emp
WHERE job != 'ANALIST'
START WITH mgr IS NULL -- 시작은 이거고
CONNECT BY PRIOR empno = mgr; --내가 이미 읽은 empno와 일치하는 mgr을 찾겠다
-- START WITH절이 모두 수행되고나서 WHERE절이 수행됨 
-- 계층쿼리에서는 WHERE절에 쓰는 경우는 드뭄

SELECT empno, LPAD(' ', (LEVEL-1)*4)||ename AS ename, mgr
FROM emp
START WITH mgr IS NULL -- 시작은 이거고
CONNECT BY PRIOR empno = mgr AND job != 'ANALIST'; 
--내가 이미 읽은 empno와 일치하는 mgr을 찾고 내가 찾아간 행이 ANALIST가 아닌것
--START WITH이 수행되는 과정에서 조건이 적용 되므로 만족하지 않는 행의 하위의 LEVEL 까지도 안나오게 된다.

● 계층 쿼리와 관련된 특수 함수 ★
1. CONNECT_BY_ROOT(컬럼) : 최상위 노드의 해당 컬럼 값
2. SYS_CONNECT_BY_PATH(컬럼, '구분자문자열') : 최상위 행부터 현재 행까지의 해당 컬럼의 값을 구분자로 연결한 문자열
3. CONNECT_BY_ISLEAF : CHILD가 없는 leaf node 여부 0 - false(no leaf node) / 1 - true(leaf node)

--쿼리 작성시 10~15% 정도는 계층형 쿼리가 쓰인다 잘 알아두자!!★
SELECT empno, LPAD(' ', (LEVEL-1)*4)||ename AS ename, 
       CONNECT_BY_ROOT(ename) root_ename,
       LTRIM(SYS_CONNECT_BY_PATH(ename, '-'), '-') path_ename, --왼쪽 '-'제거
       -- INSTR('TEST', 'T', 2), 문자 짤라낼때 INSTR, SUBSTR 두가지를 활용한다!!
       CONNECT_BY_ISLEAF isleaf
FROM emp
START WITH mgr IS NULL
CONNECT BY PRIOR empno = mgr;

게시판은 루트가 많다
1. 제목
  ---2. 답글
3. 제목
  ---4. 답글

SELECT seq, parent_seq, LPAD(' ', (LEVEL-1)*4)|| title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER siblings BY seq DESC; --siblings : 뜻 형제/ 계층을 유지한체 정렬해주는 키워드

★시작(ROOT)글은 작성 순서의 역순으로
답글은 작성 순서대로 정렬★ -- root 넘버로 leaf까지 부여 후 디센딩, 디센딩 후 seq로 어센딩

방법1 : 컬럼을 만들어 정렬하는 방법
SELECT gn, CONNECT_BY_ROOT(seq) root_seq,
       seq, parent_seq, LPAD(' ', (LEVEL-1)*4)|| title title
FROM board_test
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER siblings BY gn DESC, seq ASC;

방법2 : START WITH의 CONNECT_BY_ROOT 컬럼을 활용하여 정렬하는 방법
SELECT * 
FROM
(SELECT CONNECT_BY_ROOT(seq) root_seq,
       seq, parent_seq, LPAD(' ', (LEVEL-1)*4)|| title title
 FROM board_test
 START WITH parent_seq IS NULL
 CONNECT BY PRIOR seq = parent_seq)
START WITH parent_seq IS NULL
CONNECT BY PRIOR seq = parent_seq
ORDER siblings BY root_seq DESC, seq ASC;

시작글부터 관련 답글까지 그룹번호를 부여하기 위해 새로운 컬럼 추가
ALTER TABLE board_test ADD (gn NUMBER);
DESC board_test;

UPDATE board_test SET gn = 1
WHERE seq IN (1, 9);

UPDATE board_test SET gn = 2
WHERE seq IN (2, 3);

UPDATE board_test SET gn = 4
WHERE seq NOT IN (1, 2, 3, 9);
COMMIT;

★★★★★★ 계층형 게시판에 페이징처리 적용 ★★★★★★
pageSize : 5
page : 2
SELECT *
FROM 
(SELECT ROWNUM rn, a.* -- 이쪽 영역은 기술적인 부분 껍데기로 감싸자
 FROM (SELECT gn, CONNECT_BY_ROOT(seq) root_seq, -- 우리는 이부분만 잘 짜면 된다
       seq, parent_seq, LPAD(' ', (LEVEL-1)*4)|| title title
       FROM board_test
       START WITH parent_seq IS NULL
       CONNECT BY PRIOR seq = parent_seq
       ORDER siblings BY gn DESC, seq ASC) a ) 
WHERE rn BETWEEN 6 AND 10;


SELECT *
FROM emp
WHERE deptno = 10
  AND sal = (SELECT MAX(sal)
             FROM emp
             WHERE deptno = 10);

-------------------------------------------------------------------------------------------------

■ 분석함수(WINDOW 함수)
º SQL에서 행간 연산을 지원하는 함수
º 해당 행의 범위를 넘어서 다른 행과 연산이 가능
 - SQL의 약점 보완
 - 이전행의 특정 컬럼을 참조
 - 특정 범위의 행들의 컬럼의 합
 - 특정 범위의 행중 특정 컬럼을 기준으로 순위, 행번호 부여 
 - SUM, COUNT, AVG, MAX, MIN
 - RANK, LEAD, LAG, ...

SELECT WINDOW_FUNCTION([인자]) OVER( [PARTITION BY 컬럼] [ORDER BY 컬럼] )
FROM ...

PARTITION BY : 영역 설정
ORDER BY [ASC/DESC] : 영역 안에서의 순서 정하기

[부서별 급여 순위]
-- 오라클 내부에서 RANK()때 이미 정렬을 하므로 ORDER BY 기술 안해줘도됨
SELECT ename, sal, deptno, RANK() OVER(PARTITION BY deptno ORDER BY sal DESC) sal_rank
FROM emp;

○ RANK() OVER(PARTITION BY deptno ORDER BY sal DESC) sal_rank 동작 방식
PARTITION BY deptno : 같은 부서코드를 갖는 row를 그룹으로 묶는다
ORDER BY sal DESC : 그룹내에서 sal로 row의 순서를 정한다
RANK() : 파티션 단위안에서 정렬 순서대로 순위를 부여한다.

-- WINDOW 함수 안썼을 때
SELECT a.ename, a.sal, a.deptno, b.rank
FROM 
(SELECT a.*, ROWNUM rn
FROM 
(SELECT ename, sal, deptno
 FROM emp
 ORDER BY deptno, sal DESC) a ) a,

(SELECT ROWNUM rn, rank
FROM 
(SELECT a.rn rank
FROM
    (SELECT ROWNUM rn
     FROM emp) a,
     
    (SELECT deptno, COUNT(*) cnt
     FROM emp
     GROUP BY deptno
     ORDER BY deptno) b
 WHERE a.rn <= b.cnt
ORDER BY b.deptno, a.rn)) b
WHERE a.rn = b.rn;

순위 관련된 함수(중복값을 어떻게 처리하는가)
RANK : 동일 값에 대해 동일 순위 부여하고, 후순위는 동일값 갯수 만큼 건너뛴다
       1등 2명이면 그 다음 순위는 3위
DENSE_RANK : 동일 값에 대해 동일 순위 부여하고, 후순위는 이어서 부여한다
             1등이 2명이면 그 다음 순위는 2위
ROW_NUMBER : 중복 없이 행에 순차적인 번호를 부여(ROWNUM)

SELECT ename, sal, deptno, 
       RANK() OVER(PARTITION BY deptno ORDER BY sal DESC) sal_rank,
       DENSE_RANK() OVER(PARTITION BY deptno ORDER BY sal DESC) dense_rank,
       ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY sal DESC) row_number
FROM emp;

[실습 ana1]
사원 전체 급여 순위를 rank, dense_rank, row_number를 이용하여 구해라
단 급여가 동일할 경우 사번이 빠른 사람이 높은 순위가 되도록 작성

SELECT empno, ename, sal, deptno, 
       RANK() OVER(ORDER BY sal DESC, empno) sal_rank,
       DENSE_RANK() OVER(ORDER BY sal DESC, empno) sal_dense_rank,
       ROW_NUMBER() OVER(ORDER BY sal DESC, empno) sal_row_number
FROM emp;

[실습 no_ana2]
기존의 배운 내용을 활용하여, 모든 사원에 대해 사원번호, 사원이름, 
해당 사원이 속한 부서의 사원수를 조회하는 쿼리 작성

SELECT empno, ename, deptno,
       count(*) OVER(PARTITION BY deptno) cnt
FROM emp
ORDER BY deptno;

SELECT emp.empno, emp.ename, emp.deptno, cnt
FROM emp,
    (SELECT deptno, count(*) cnt
     FROM emp
     GROUP BY deptno) b
WHERE emp.deptno = b.deptno
ORDER BY emp.deptno;




