SELECT *
FROM emp;

SELECT empno, ename
FROM emp;

--[nnic계정]에 있는 prod 테이블의 모든 컬럼을 조회하는 SELECT 쿼리(SQL) 작성
SELECT *
FROM prod;

--[nnic계정]에 있는 prod 테이블의 prod_id, prod_name 두개의 컬럼만 조회하는 SELECT 쿼리(SQL) 작성
SELECT prod_id, prod_name
FROM prod;

SELECT[실습 select1]
-- lprod 테이블에서 모든 데이터를 조회하는 쿼리를 작성하세요
SELECT *
FROM lprod;

-- buyer 테이블에서 buyer_id, buyer_name 컬럼만 조회하는 쿼리를 작성하세요
SELECT buyer_id, buyer_name
FROM buyer;

-- cart 테이블에서 모든 테이터를 조회하는 쿼리를 작성하세요
SELECT *
FROM cart;

-- member 테이블에서 mem_id, mem_pass, mem_name 컬럼만 조회하는 쿼리를 작성하세요
SELECT mem_id, mem_pass, mem_name
FROM member;

* 데이터 타입(우선 3가지 타입 기억)
NUMBER(4,0) 전체자리는 4자리, 소수점은 없다
NUMBER(7,2) 전체자리는 7자리, 소수점 2자리
VARCHAR2는 문자열(자바의 STRING과 비슷)
DATE

컬럼 정보를 보는 방법
1. SELECT * ==> 컬럼의 이름을 알 수 있다
2. SQL DEVELOPER의 테이블
3. DESC 테이블명; //DESCRIBE 설명하다

숫자, 날짜에서 사용가능한 연산자
일반적인 사칙연산 + - / *, 우선순위 연산자 ()

DESC emp;
empno : number;
empno + 10 ==> expression 표현;
ALIAS : 컬럼의 이름을 변경
        컬럼 | expression [AS] [별칭명];
        ""을 사용시 공백, 소문자 등으로 표현 가능
--SELECT {[DISTINCT]column, expression [ALIAS]};
SELECT empno "empno", empno + 10 AS emp_plus, 10, hiredate, hiredate + 10
FROM emp;

NULL : 아직 모르는 값
       0과 공백은 NULL과 다르다
       **** NULL을 포함한 연산은 결과가 항상 NULL ****
       ==> NULL 값을 다른 값으로 치환해주는 함수
SELECT ename, sal, comm, sal + comm, comm + 100
FROM emp;

column alias[실습 select2]
--prod 테이블에서 prod_id, prod_name 두 컬럼을 조회하는 쿼리를 작성하시오.
--(단, prod_id -> id, prod_name -> name 으로 컬럼 별칭을 지정)
SELECT prod_id "id", prod_name "name"
FROM prod;
--lprod 테이블에서 lprod_gu, lprod_nm 두 컬럼을 조회하는 쿼리를 작성하시오.
--(단, lprod_gu -> gu, lprod_nm -> nm 으로 컬럼 별칭을 지정)
SELECT lprod_gu AS gu, lprod_nm AS nm
FROM lprod;
--buyer 테이블에서 buyer_id, buyer_name 두 컬럼을 조회하는 쿼리를 작성하시오.
--(단, buyer_id -> 바이어아이디, buyer_name -> 이름으로 컬럼 별칭을 지정)
SELECT buyer_id 바이어아이디, buyer_name "이름"
FROM buyer;

literal : 값
literal 표기법 : 값을 표현하는 방법
문자열은 싱글쿼테이션('')으로 표기

java 정수 값을 어떻게 표현할까 (10)?
int a = 10;
float l = 10L;
String s = "Hello, World!";

* | { 컬럼 | 표현식 [AS] [ALIAS], ...}
SELECT empno, 10, 'Hello World'
FROM emp;

문자열 연산
java : String msg = "Hello" + ", World";

SELECT empno + 10, ename || 'Hello' || ', World', 
       CONCAT(ename, ', World') --결합할 두개의 문자열을 입력받아 결합하고 결합된 문자열을 반환 해준다
FROM emp;
CONCAT(문자열1, 문자열2, 문자열3) ==> CONCAT(문자열1과 문자열2가 결합된 문자열, 문자열3)
                               ==> CONCAT(CONCAT(문자열1, 문자열2), 문자열3)

desc emp;

함수
INPUT x => FUNCTION f => OUTPUT f(x)

아이디 : brown
아이디 : apeach
SELECT '아이디 : ' || userid, CONCAT('아이디 : ', userid)
FROM users;

--오라클에서 내부 적으로 관리하는 테이블(user_tables, 현재 계정의 테이블 정보를 출력)
SELECT table_name 
FROM user_tables;


SELECT 'SELECT * FROM ' || table_name || ';',
        CONCAT('SELECT * FROM ' || table_name, ';'),
        CONCAT(CONCAT('SELECT * FROM ', table_name), ';')
FROM user_tables;


***조건에 맞는 데이터 조회하기
WHERE : 기술한 조건을 참(TRUE)으로 만족하는 행들만 조회한다(FILTER)
WHERE절 조건연산자
 연산자      의미
=          같은 값
!=, <>     다른 값
>          클 때
>=         크거나 같을 때
<          작을 때
<=         작거나 같을 때

--부서번호가 10인 직원들만 조회
--부서번호 : deptno
SELECT *
FROM emp
WHERE deptno =10;

--users 테이블에서 userid 컬럼의 값이 brown인 사용자만 조회
SELECT *
FROM users
WHERE userid = 'brown'; --데이터값은 대소문자 가림

--emp 테이블에서 부서번호가 20번보다 큰부서에 속한 직원 조회
SELECT *
FROM emp
WHERE deptno > 20;

--emp 테이블에서 부서번호가 20번 부서에 속하지 않은 모든 직원 조회
SELECT *
FROM emp
WHERE deptno <> 20;

SELECT *
FROM emp
WHERE 1=1;

SELECT empno, ename, hiredate
FROM emp
WHERE hiredate >= '81/03/01'; --81년 3월 1일 날짜 값을 표기하는 방법
-- 미국 같은 경우 우리나라와 날짜 표기법이 달라 데이터'81/03/01'로 표현시 문제가 생길 수 있음(또는 설정에 따라 출력 값이 달라 문제될 수 있음)

문자열을 날짜 타입으로 변환하는 방법
TO_DATE(날짜 문자열, 날짜 문자열의 포맷팅)
TO_DATE('1981/12/11', 'YYYY/MM/DD')

SELECT empno, ename, hiredate
FROM emp
WHERE hiredate >= TO_DATE('1981/03/01', 'YYYY/MM/DD'); --쿼리가 길어도 이게 안전함!!! 권장 : YYYY(4자리 표기법)













