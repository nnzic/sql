
-- ★ 패키지, 펑션, 프로시져, 트리거 주로쓴다 - 익명블록을 기반함(기본적으로 익명블록 사용법을 알아야함)
-- 익명블록은 검토용도로 사용

■ PL / SQL
 
 - PROCEDURAL LANGUAGE sql의 약자
 - 표준 SQL에 절차적 언어의 기능이 추가(비교, 반복, 변수 등)이 추가
 - 블록(BLOCK) 구조로 구성
 - 미리 컴파일되어 실행 가능한 상태로 서버에 저장되어 필요시 호출되어 사용됨
 - 모듈화, 캡슐화 기능 제공
 - Anonymous Block, Stored Procedure, User Defined Function, Package, Trigger 등으로 구성

-- -기본적으로 하나의 행만 출력할 수 있는데, 다중행 출력을 위해서는 CURSOR를 사용해야 한다.
콜 바이 밸류
콜 바이 래퍼런스

1.익명블록
 - pl/sql의 기본 구조
 - 선언부와 실행부로 구성
(구성형식)
DECLARE
 --선언영역
 --변수, 상수 커서 선언
BEGIN
 --실행영역
 --BUSINESS LOGIC 처리

 [EXCEPTION
  예외처리명령;
  ]
END;
/ (<== SQLPLUS같은 라인에디터에서는 필요)
예외처리 : 비정상적(인터럽트) 종료를 막고 (실행권한-> 프로그램이 운영체제에 반납) 정상적 종료로 유도
데이터타입

사용예) 키보드로 2~9사이의 값을 입력 받아 그 수에 해당하는 구구단을 작성하시오
ACCEPT P_NUM PROMPT '수 입력(2~9) : '  --ACCEPT : 입력받는 기능, PROMPT : 메시지
DECLARE
    V_BASE NUMBER := TO_NUMBER('&P_NUM'); -- '&P_NUM' : 입력값 받는 표기법
    V_CNT NUMBER := 0; -- 파스칼 문법 (:=) 할당연산자
    V_RES NUMBER := 0; --변수는 보통 V로 시작 // 오라클은 초기화 안할기 기본값으로 NULL할당
BEGIN
    LOOP -- 무한루프
        V_CNT := V_CNT+1;
        EXIT WHEN V_CNT > 9; -- 무한루프 탈출 조건
        V_RES := V_BASE * V_CNT;
        
        DBMS_OUTPUT.PUT_LINE(V_BASE || '*' || V_CNT || '=' || V_RES); -- DBMS_OUTPUT.PUT_LINE() : System.out.println()
    END LOOP; -- 반드시 END로 범위를 맺어줘야함
    
    EXCEPTION WHEN OTHERS THEN -- 자바의 EXCEPTION 이라 생각하자(모든 예외의 경우)
        DBMS_OUTPUT.PUT_LINE('예외발생 : ' || SQLERRM); --SQLERRM의 에러메시지를 출력
END;

1)변수, 상수 선언
 - 실행영역에서 사용할 변수 및 상수 선언
 (1)변수의 종류
  · SCLAR 변수 - 하나의 데이터를 저장하는 일반적 변수
  · REFERENCES 변수 - 해당 테이블의 컬럼이나 행에 대응하는 타입과 크기를 참조하는 변수
  · COMPOSITE 변수 - PL/SQL에서 사용하는 배열 변수
  · RECORD TYPE
    TABLE TYPE변수
  · BIND 변수 - 파라메터로 넘겨지는 IN, OUT, INOUT에서 사용되는 변수 --INOUT은 부하가 많아 될수록 사용하지 않는 것을 권고
                RETURN 되는 값을 전달받기 위한 변수                
바인딩 : 변수의 값을 저장하는 행위?
 
 (2)선언방식
  변수명 [CONSTANT] 데이터타입 [:=초기값]
  변수명 테이블명.컬럼명%TYPE [:=초기값], --> 컬럼 참조형
  변수명 테이블명%ROWTYPE --> 행참조형
 (3)데이터타입
  · 표준 SQL에서 사용하는 데이터 타입
  · PLS_INTEGER, BINARY_INTEGER : 2147483647~2147483648까지 자료처리
  · BOOLEAN : TRUE, FALSE, NULL 처리
  · LONG, LONG RAW : DEPRECATED(업데이트 지원X)

예)장바구니에서 2005년 5월 가장 많은 구매를 한(구매금액 기준) 회원정보를 조회하시오(회원번호, 회원명, 구매금액합)
SELECT 
FROM(
SELECT B.MEM_ID 회원번호, B.MEM_NAME 회원명, SUM(CART_QTY * PROD_PRICE) 구매금액합
FROM CART A, MEMBER B, PROD C
WHERE A.CART_PROD = C.PROD_ID
  AND A.CART_MEMBER = B.MEM_ID
GROUP BY MEM_ID, MEM_NAME
ORDER BY 3 DESC
)

SELECT * FROM MEMBER

SELECT * FROM CART
SELECT * FROM PROD

SELECT A.CART_MEMBER, B.MEM_NAME, AA
FROM ( SELECT A.CART_MEMBER, SUM(CART_QTY * PROD_PRICE)AA
       FROM CART A, PROD B
       WHERE A.CART_PROD = B.PROD_ID
       ORDER BY A.CART_MEMBER DESC ) A, MEMBER B
WHERE A.CART_MEMBER = B.MEM_ID
  AND ROWNUM = 1


예)장바구니에서 2005년 5월 가장 많은 구매를 한(구매금액 기준) 회원정보를 조회하시오(회원번호, 회원명, 구매금액합)
CREATE OR REPLACE VIEW V_MAXAMT
AS
SELECT D.MID AS 회원번호,
       B.MEM_NAME 회원명,
       D.AMT 구매금액합
FROM( SELECT A.CART_MEMBER AS MID, SUM(A.CART_QTY * C.PROD_PRICE) AS AMT
      FROM CART A, PROD C
      WHERE A.CART_PROD = C.PROD_ID
      GROUP BY A.CART_MEMBER
      ORDER BY 2 DESC) D, MEMBER B
WHERE D.MID = B.MEM_ID
  AND ROWNUM =1;
  
SELECT * FROM V_MAXAMT;

(익명블록)

DECLARE
    V_MID V_MAXAMT.회원번호%TYPE;
    V_NAME V_MAXAMT.회원명%TYPE;
    V_AMT V_MAXAMT.구매금액합%TYPE;
    V_RES VARCHAR2(100);
BEGIN
    SELECT 회원번호, 회원명, 구매금액합 INTO V_MID, V_NAME, V_AMT --INTO 반드시 기술(정보 받는 역할)
    FROM V_MAXAMT;
    
    V_RES := V_MID || ', ' || V_NAME || ', ' || TO_CHAR(V_AMT, '99,999,999');
    
    DBMS_OUTPUT.PUT_LINE(V_RES);
END;
  
(상수사용예)
키보드로 수하나를 입력 받아 그 값을 반지름으로 하는 원의 넓이를 구하시오

ACCEPT P_NUM PROMPT '원의 반지름 : '
DECLARE
    V_RADIUS NUMBER := TO_NUMBER('&P_NUM');
    V_PI CONSTANT NUMBER := 3.1415926;
    V_RES NUMBER := 0;
BEGIN
    V_RES := V_RADIUS * V_RADIUS * V_PI;
    DBMS_OUTPUT.PUT_LINE('원의 너비 = '||V_RES);
END;


     
     