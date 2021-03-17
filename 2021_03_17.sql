WHERE 조건1 : 10건

WHERE 조건1
  AND 조건2 : 10건을 넘을 수 없음
  
WHERE deptno = 10
  AND sal > 500
  
ORDER BY 1차, 2차 --1차 정렬된 컬럼이 다중일때 2차를 통해 정렬을 함

--오라클에서 변수 바인딩처리? :(콜론)으로 표기

WHERE ROWNUM = 1
WHERE ROWNUM <= n
WHERE ROWNUM < n
WHERE ROWNUM BETWEEN 1 AND 10

시험문제 
1. 트랜잭션
2. NOT IN 연산자 사용시 주의점!! : 비교값 중에 NULL이 포함되면 데이터가 조회되지 않는다
3. 페이징처리

엔코아 :데이터베이스 컨설팅업체 ==> 엔코아_부사장 : b2en ==> b2en 대표컨설턴트 : dbian;
=================================================================================

함수명을 보고
1. 파라미터가 어떤게 들어갈까?
2. 몇개의 파라미터가 들어갈까?
3. 반환되는 값은 무엇일까?

■ Function
○ Single row function
 - 단일 행을 기준으로 작업하고, 행당 하나의 결과를 반환
 - 특정 컬럼의 문자열 길이 : length(ename)
 
○ Multi row function
 - 여러 행을 기준으로 작업하고, 하나의 결과를 반환
 - 그룹합수
 º count, sum, avg

○ character
- 대소문자
 º LOWER : 문자열로 대문자로 변환
 º UPPER : 문자열을 소문자로 변환
 º INITCAP : 첫글짜 대문자 다음은 소문자로 표현
- 문자열조작
 º CONCAT : 두개의 문자열 결합
 º SUBSTR : 문자열 중 원하는 문자 선택
 º LENGTH : 문자열 길이 반환
 º INSTR :
 º LPAD|RPAD : 왼쪽 오른쪽에 특정 문자열 집어넣음
 º TRIM : 문자열의 시작과 마지막 공백제거 
 º REPLACE : 문자열을 특정 문자열로 치환(인자 3개)
 
○ DUAL table
 - sys 계정에 있는 테이블
 - 누구나 사용가능
 - DUMMY컬럼 하나만 존재하며 값은 'X'이며 데이터는 한 행만 존재
 - 사용용도
 º 데이터와 관련없이
  · 함수실행
  · 시퀀스 실행
 º merge문에서
 º 데이터 복제시(connect by level)
 
○ numbers
 - 숫자조작
 º ROUND
  · 반올림
 º TRUNC
  · 내림
 º MOD
  · 나눗셈 나머지
  
○ date --외우자!
 - FORMAT
 º YYYY : 4자리 년도
 º MM : 2자리월
 º DD : 2자리 일자
 º D : 주간 일자(1~7)
 º IW : 주차(1~53)
 º HH, HH12 : 2자리 시간(12시간 표현)
 º HH24 : 2자리 시간(24시간 표현)
 º MI : 2자리 분
 º SS : 2자리 초 
** TO_DATE(문자열, 문자열 포맷) 날짜->문자->날짜 변경패턴 자주 쓰임
** TO_CHAR(날짜, 포맷팅 문자열) 문자->날짜->문자
 
SINGLE ROW FUNCTION : WHERE 절에서도 사용 가능
emp 테이블에 등록된 직원들 중에 직원의 이름이 길이가 5글자를 초과하는 직원만 조회
SELECT *
FROM emp
WHERE LENGTH(ename) > 5;

SELECT * | { column | expression }

SELECT *
FROM emp
WHERE LOWER(ename) = 'smith'; --권장하지 않음, 전체 행 14번 함수변환이 실행되므로 아래 방법을 권장

SELECT *
FROM emp
WHERE ename = UPPER('smith'); -- 위와 같은 결과 출력

SELECT LENGTH('TEST')
FROM DUAL;

SELECT ename, LOWER(ename), UPPER(ename), INITCAP(ename), UPPER('ename'),
       SUBSTR(ename, 2, 3), SUBSTR(ename, 2)
FROM emp;

==================================================
ORACLE 문자열 함수

SELECT 'HELLO' || ', ' || 'WORLD',
        CONCAT('HELLO', CONCAT(', ', 'WORLD')) CONCAT,
        SUBSTR('HELLO, WORLD', 1, 5) SUBSTR, --외우려하지 말고 직접 실행 후 인덱스 확인한뒤 결정
        LENGTH('HELLO, WORLD') LENGTH,
        INSTR('HELLO, WORLD', 'O') INSTR, -- 지정한 특정 문자열 찾아서 인덱스 반환(왼쪽에서 오른쪽으로 검사)
        INSTR('HELLO, WORLD', 'O', 6) INSTR2, -- 지정한 특정 문자열을 6번째부터 찾아서 인덱스 반환(왼쪽에서 오른쪽으로 검사)
        LPAD('HELLO, WORLD', 15, '-') LPAD,
        RPAD('HELLO, WORLD', 15, '-') RPAD,
        REPLACE('HELLO, WORLD', 'O', 'X') REPLACE, -- O에해당하는 문자를 X로 대체한다.
        TRIM('    HELLO, WORLD   ') TRIM, -- 공백을 제거, 문자열의 앞과 뒷부분에 있는 공백만 제거(문자열 중간 공백은 X)
        TRIM('D' FROM 'HELLO, WORLD') TRIM -- FROM에 있는 물자열 중 D에 해당되는 문자 제거
FROM DUAL;

--피제수10, 제수3
SELECT MOD(10,3)
FROM DUAL;

SELECT 
ROUND(105.54, 1) round1, --반올림 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째자리에서 반올림 : 105.5
ROUND(105.55, 1) round2, --반올림 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째자리에서 반올림 : 105.6
ROUND(105.55, 0) round3, --반올림 결과가 첫번째 자리(일의 자리)까지 나오도록 : 소수점 첫째 자리에서 반올림 : 106
ROUND(105.55, -1) round4, --반올림 결과가 두번째 자리(십의 자리)까지 나오도록 : 정수 첫째 자리에서 반올림 : 110
ROUND(105.55) round5 --round3와 동일
FROM DUAL;

SELECT 
TRUNC(105.54, 1) trunc1, --절삭 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째자리에서 절삭 : 105.5
TRUNC(105.55, 1) trunc2, --절삭 결과가 소수점 첫번째 자리까지 나오도록 : 소수점 둘째자리에서 절삭 : 105.5
TRUNC(105.55, 0) trunc3, --절삭 결과가 첫번째 자리(일의 자리)까지 나오도록 : 소수점 첫째 자리에서 절삭 : 105
TRUNC(105.55, -1) trunc4, --절삭 결과가 두번째 자리(십의 자리)까지 나오도록 : 정수 첫째 자리에서 절삭 : 100
TRUNC(105.55) trunc5 --trunc3와 동일
FROM DUAL;

--ex : 7499, ALLEN, 1600, 1, 600
SELECT empno, ename, sal, sal을 1000으로 나눴을 때의 몫, sal을 1000나눴을 때의 나머지
FROM emp;

SELECT empno, ename, sal, TRUNC(sal/1000) , MOD(sal, 1000)
FROM emp;

날짜 <==> 문자
서버의 현재 시간: SYSDATE - 오라클에서 제공하는 함수(인자가 없어서 ()가 없다)

SELECT SYSDATE
FROM dual;

SELECT SYSDATE, SYSDATE + 1/24/60 --1/24(1시간), 1/24/60(1분)
FROM dual;

[date 실습 fn1]
1. 2019년 12월 31일을 date 형으로 표현
2. 2019년 12월 31일을 date형으로 표현하고 5일 이전 날짜
3. 현재 날짜
4. 현재 날짜에서 3일 전 값

SELECT TO_DATE('20191231', 'YYYY/MM/DD') LASTDAY, 
       TO_DATE('20191231', 'YYYY/MM/DD') - 5 LASTDAY_BEFORE5, 
       SYSDATE NOW, 
       SYSDATE - 3 NOW_BEFORE3
FROM dual;

TO_DATE : 인자-문자, 문자의 형식 TO_DATE(문자, 'YYYY/MM/DD')
TO_CHAR : 인자-날짜, 문자의 형식

NLS : YYYY/MM/DD/ HH24:MI:SS
-- 52~53주 주차 IW
-- 주간요일(D) - 0:일요일, 1:월요일, 2:화요일, ..., 6:토요일
SELECT TO_CHAR(SYSDATE, 'D')
FROM dual;

[date 실습 fn2]
-- 오늘 날짜를 다음과 같은 포맷으로 조회하는 쿼리를 작성하시오
1. 년-월-일
2. 년-월-일 시간(24)-분-초
3. 일-월-년

SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD') DT_DASH,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24-MI-SS') DT_DASH_WITH_TIME,
       TO_CHAR(SYSDATE, 'MM-DD-YYYY') DT_DD_MM_YYYY
FROM dual;

** TO_DATE(문자열, 문자열 포맷) 날짜->문자->날짜 변경패턴 자주 쓰임
SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYY-MM-DD'), 'YYYY-MM-DD') DT_DASH
FROM dual;

** TO_CHAR(날짜, 포맷팅 문자열) 문자->날짜->문자
SELECT TO_CHAR(TO_DATE('2021-03-17', 'YYYY-MM-DD'), 'YYYY-MM-DD HH24-MI-SS')
FROM dual;

SELECT SYSDATE, TO_DATE( TO_CHAR(SYSDATE-5, 'YYYYMMDD'), 'YYYYMMDD') -- 5일전 0시0분0초로 주기위해 (날짜->문자->날짜)패턴 사용
FROM dual;

















