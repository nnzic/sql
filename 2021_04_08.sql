
-- ★ 패키지, 펑션, 프로시져, 트리거 주로쓴다 - 익명블록을 기반함
-- 익명블록은 검토용도로 사용
-- PROCEDURE : 값 반환X
-- FUNCTION : 값 반환O (SELECT, WHERE절에서 활용)

■ 저장프로시져(Stored Procedure : Procedure)
º 특정 결과를 산출하기 위한 코드의 집합(모듈)
º 변환값이 없음 --독립적으로 시행(리턴문으로 인해 반환되는 값이 없다는 것임) -> 블록으로 매개변수 받아서 출력하자
º 컴파일되어 서버에 보관(실행속도를 증가, 은닉성, 보안성)
 (사용형식)
CREATE [OR REPLACE] PROCEDURE 프로시져명[( --프로시져명 앞에 PROC 주로 씀
    매개변수명 [IN | OUT | INOUT] 데이터타입 [[:= | DEFAULT] expr], -- IN  프로시저 밖에서 처리되어 진 것을 프로시저로 가져올때
    매개변수명 [IN | OUT | INOUT] 데이터타입 [[:= | DEFAULT] expr], -- OUT 프로시저 안에서 처리되어 진 것을 밖으로 내보낼때 
                                :                               -- 생략시 IN이 default 이다.
    매개변수명 [IN | OUT | INOUT] 데이터타입 [[:= | DEFAULT] expr] )] -- INOUT은 쓰지말라! 오라클 권고
AS | IS -- 둘중 아무거나 선택해서 쓰자(같다)
    선언영역;
BEGIN
    실행영역;
END;

--** 테이블 생성명령
CREATE TABLE 테이블명(
    컬럼명 데이터타입[(크기)] [NOT NULL] [DEFAULT 값[수식] [,]
    컬럼명 데이터타입[(크기)] [NOT NULL] [DEFAULT 값[수식] [,]
                            :
    컬럼명 데이터타입[(크기)] [NOT NULL] [DEFAULT 값[수식] [,]
    
    CONSTRAINT 기본키설정명  PRIMARY KEY (컬럼명1[, 컬럼명2, ...]) [,]
    CONSTRAINT 외래키설정명1 FOREIGN KEY (컬럼명1[, 컬럼명2, ...])
        REFERENCES 테이블명1(컬럼명1[, 컬럼명2, ...]) [,]
                            :
    CONSTRAINT 외래키설정명N FOREIGN KEY (컬럼명1[, 컬럼명2, ...])
        REFERENCES 테이블명1(컬럼명1[, 컬럼명2, ...]) );
        
--1.(테이블 컬럼명 변경)
ALTER TABLE 테이블명
    RENAME COLUMN 변경대상 컬럼명 TO 변경 컬럼명;
EX) ABC를 QAZ라는 컬럼명으로 변경
ALTER TABLE TEMP
    RENAME COLUMN ABC TO QAZ;

--2. 컬럼 데이터타입(크기) 변경
ALTER TABLE 테이블명
    MODIFY 컬럼명 데이터타입(크기);
EX) TEMP 테이블의 ABC컬럼을 NUMBER(10)으로 변경하는 경우
ALTER TABLE TEMP
    MODIFY ABC NUMBER(10); --해당컬럼의 내용을 모두 지워야 변경 가능

** 다음 조건에 맞는 재고수불 테이블을 생성하시오
1. 테이블명 : REMAIN
2. 컬럼
---------------------------------------------------------
 컬럼명          데이터타입               제약사항
---------------------------------------------------------
REMAIN_YEAR     CHAR(4)                 PK
PROD_ID         VARCHAR2(10)            PK & FK
REMAIN_J_00     NUMBER(5)               DEFAULT 0 --기초재고
REMAIN_I        NUMBER(5)               DEFAULT 0 --입고수량
REMAIN_O        NUMBER(5)               DEFAULT 0 --출고수량
REMAIN_J_99     NUMBER(5)               DEFAULT 0 --기말재고
REMAIN_DATE     DATE                    DEFAULT SYSDATE --처리일자


CREATE TABLE REMAIN(
  REMAIN_YEAR     CHAR(4),
  PROD_ID         VARCHAR2(10),
  REMAIN_J_00     NUMBER(5) DEFAULT 0,
  REMAIN_I        NUMBER(5) DEFAULT 0,
  REMAIN_O        NUMBER(5) DEFAULT 0,
  REMAIN_J_99     NUMBER(5) DEFAULT 0,
  REMAIN_DATE     DATE      DEFAULT SYSDATE,
  
  CONSTRAINT PK_REMAIN  PRIMARY KEY (REMAIN_YEAR, PROD_ID),
  CONSTRAINT FK_REMAIN_PROD FOREIGN KEY (PROD_ID)
    REFERENCES PROD(PROD_ID)
);

** REMAIN 테이블에 기초자료 삽입
 년도 : 2005
 상품코드 : 상품테이블의 상품코드
 기초재고 : 상품테이블의 적정재고(PROD_PROPERSTOCK)
 입고수량/출고수량 : 없음
 처리일자 : 2004/12/31
 
INSERT INTO REMAIN(REMAIN_YEAR, PROD_ID, REMAIN_J_00, REMAIN_J_99, REMAIN_DATE)
    SELECT '2005', PROD_ID, PROD_PROPERSTOCK, PROD_PROPERSTOCK, TO_DATE('20041231')
    FROM PROD;

SELECT * 
FROM REMAIN;

사용예) 오늘이 2005년 1월 31일이라고 가정하고 오늘까지 발생된 상품입고 정보를 이용하여 
       재고 수불테이블을 update하는 프로시져를 생성하시오
       1. 프로시져명 : PROC_REMAIN_IN
       2. 매개변수 : 상품코드, 매입수량
       3. 처리 내용 : 해당 상품코드에 대한 입고수량, 현재고수량, 날짜 UPDATE
** 1. 2005년 상품별 매입수량 집계 -- 프로시져 밖에서 처리
   2. 1의 결과 각 행을 PROCEDURE에 전달
   3. PROCEDURE에서 재고 수불테이블 UPDATE
   
(PROCEDURE 생성)
CREATE OR REPLACE PROCEDURE PROC_REMAIN_IN( -- 프로시져 선언부
  P_CODE IN PROD.PROD_ID%TYPE, -- IN을 사용했으므로 값을 외부에서 받아오는 변수
  P_CNT IN NUMBER)
IS
BEGIN -- 실행영역
  UPDATE REMAIN -- 프로시져 실행하면 업데이트문 실행
  SET (REMAIN_I, REMAIN_J_99, REMAIN_DATE) 
       = (SELECT REMAIN_I + P_CNT, REMAIN_J_99 + P_CNT, TO_DATE('20050131') -- 외부에서 받아온 변수 P_CNT값을 더해줌
          FROM REMAIN
          WHERE REMAIN_YEAR = '2005'
            AND PROD_ID = P_CODE) -- REMAIN테이블의 PROD_ID값과 외부에서 받아온 변수 P_CODE값이 일치 하였을 경우
  WHERE REMAIN_YEAR = '2005'
    AND PROD_ID = P_CODE;
END;

2. 프로시져 실행명령
EXEC|EXECUTE 프로시져명[(매개변수 LIST)];
 - 단, 익명블록 등 또다른 프로시져나 함수에서 프로시져 호출시 'EXEX|EXECUTE'는 생략해야 한다.
(2005년 1월 상품별 매입집계)
SELECT BUY_PROD AS BCODE, SUM(BUY_QTY) AS BAMT
FROM BUYPROD
WHERE BUY_DATE BETWEEN '20050101' AND '20050131'
GROUP BY BUY_PROD;

(익명블록 작성) -- 익명블록을 활용하여 위의 프로시져를 실행
DECLARE
 CURSOR CUR_BUY_AMT -- 변경해주어할 행들이 여러개 이므로 커서를 사용
 IS -- 아래 실행 결과들을 커서에 저장
    SELECT BUY_PROD AS BCODE, SUM(BUY_QTY) AS BAMT
    FROM BUYPROD
    WHERE BUY_DATE BETWEEN '20050101' AND '20050131'
    GROUP BY BUY_PROD;
BEGIN --FOR문은 OPEN, FETCH, CLOSE 생략
 FOR REC01 IN CUR_BUY_AMT LOOP --CUR_BUY_AMT커서에 담긴 행만큼 실행 -> REC01레코드에 한행씩 값 전달
     PROC_REMAIN_IN(REC01.BCODE, REC01.BAMT); --즉 프로시져에 BCODE, BAMT값을 전달해주게되고 행의 갯수만큼 계속 실행
 END LOOP;
END;

**REMAIN 테이블의 내용을 VIEW로 구성
CREATE OR REPLACE VIEW V_REMAIN01
AS
  SELECT * FROM REMAIN
WITH READ ONLY;
  
CREATE OR REPLACE VIEW V_REMAIN02
AS
  SELECT * FROM REMAIN
WITH READ ONLY;

SELECT * FROM V_REMAIN01;
SELECT * FROM V_REMAIN02;

--============================
사용예) 회원아이디를 입력받아 그 회원의 이름, 주소와 직업을 반환하는 프로시져를 작성
    1. 프로시져명 : PROC_MEM_INFO
    2. 매개변수 : 입력용 : 회원아이디
                출력용 : 이름, 주소, 직업
(프로시져 생성)
CREATE OR REPLACE PROCEDURE PROC_MEM_INFO(
  P_ID IN MEMBER.MEM_ID%TYPE, -- IN생략가능
  P_NAME OUT MEMBER.MEM_NAME%TYPE,
  P_ADDR OUT VARCHAR2,
  P_JOB OUT MEMBER.MEM_JOB%TYPE)
AS
BEGIN
  SELECT MEM_NAME, MEM_ADD1||' '||MEM_ADD2, MEM_JOB
    INTO P_NAME, P_ADDR, P_JOB
    FROM MEMBER
  WHERE MEM_ID = P_ID;
END;
--프로시져의 OUT매개변수를 받아 주려면 받드시 PL/SQL에서 블럭을 통해 변수를 선언해줘서 받아야한다
-- =>
(실행)
ACCEPT PID PROMPT '회원아이디 : '
DECLARE 
  V_NAME MEMBER.MEM_NAME%TYPE;
  V_ADDR VARCHAR2(200);
  V_JOB MEMBER.MEM_JOB%TYPE;
BEGIN
  PROC_MEM_INFO (LOWER('&PID'), V_NAME, V_ADDR, V_JOB);
  DBMS_OUTPUT.PUT_LINE('회원아이디 : ' || '&PID');
  DBMS_OUTPUT.PUT_LINE('회원이름 : ' || V_NAME);
  DBMS_OUTPUT.PUT_LINE('주소 : ' || V_ADDR);
  DBMS_OUTPUT.PUT_LINE('직업 : ' || V_JOB);
END;

--프로시져 문제]
년도를 입력 받아 해당년도에 구매를 가장 많이한 회원이름과 구매액을 반환하는 프로시져를 작성
 1. 프로시져명 : PROC_MEM_PTOP
 2. 매개변수 : 입력용 : 년도
             출력용 : 회원명, 구매액
-- 프로시져 생성      
CREATE OR REPLACE PROCEDURE PROC_MEM_PTOP(
    P_YEAR IN CHAR,
    P_NAME OUT MEMBER.MEM_NAME%TYPE,
    P_COST OUT NUMBER
)
IS
BEGIN
  SELECT A.MEM_NAME, D.AMT INTO P_NAME, P_COST --2.SELECT 되어 실행된 결과를 OUT변수 P_NAME, P_COST에 넣어준다
  FROM MEMBER A, (SELECT CART_MEMBER, SUM(B.CART_QTY * C.PROD_PRICE) AS AMT 
                  FROM CART B, PROD C
                  WHERE B.CART_PROD = C.PROD_ID
                    AND SUBSTR(B.CART_NO,1,4) = P_YEAR --1.입력받은 년도를 P_YEAR IN 변수에 넣어주면
                  GROUP BY CART_MEMBER
                  ORDER BY AMT DESC) D
  WHERE A.MEM_ID = D.CART_MEMBER
    AND ROWNUM = 1;
END;

-- 프로시져 입력변수 입력받아 OUT변수 출력(OUT변수는 반드시 블록에서만 가능!)
ACCEPT YEAR PROMPT '년도 입력 : '
DECLARE
  V_NAME MEMBER.MEM_NAME%TYPE;
  V_COST NUMBER := 0;

BEGIN
  PROC_MEM_PTOP('&YEAR', V_NAME, V_COST); --'&YEAR'는 입력용 변수이고 V_NAME, V_COST는 프로시져 실행결과로 반환받은 OUT변수이다.
  DBMS_OUTPUT.PUT_LINE('&YEAR'||'년도에 가장 많이 구매한 사람은 : '||V_NAME);
  DBMS_OUTPUT.PUT_LINE('구매금액 : '||TO_CHAR(V_COST, '99,999,999'));
END;


SELECT * FROM MEMBER;
SELECT * FROM PROD;
SELECT * FROM CART;

문제] 2005년도 구매금액이 없는 회원을 찾아 회원테이블(MEMBER)의 삭제여부 컬럼(MEM_DELETE)의 
     값을 'Y'로 변경하는 프로시져를 작성
-- 업데이트 프로시져 작성
CREATE OR REPLACE PROCEDURE PROC_MEM_DLT(
  P_ID IN MEMBER.MEM_ID%TYPE )
IS
BEGIN
  UPDATE MEMBER SET MEM_DELETE = 'Y' WHERE MEM_ID = P_ID;
END;

-- 프로시져 실행
DECLARE    
BEGIN
  FOR REC_MEM IN (SELECT MEM_ID
                  FROM MEMBER M
                  WHERE NOT EXISTS (SELECT 1 
                                    FROM CART C 
                                    WHERE C.CART_MEMBER = M.MEM_ID 
                                      AND CART_NO LIKE '2005%'))
  LOOP
  PROC_MEM_DLT(REC_MEM.MEM_ID);
  END LOOP;
END;

SELECT * FROM MEMBER;












