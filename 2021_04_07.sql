
■ 반복문
 º 개발언어의 반복문과 같은 기능 제공
 º loop, while, for문
● 1) LOOP문
 - 반복문의 기본 구조
 - JAVA의 DO문과 유사한 구조임
 - 기본적으로 무한 루프 구조
 (사용형식)
 LOOP
    반복처리문(들);
    [EXIT WHEN 조건;]
 END LOOP;
 - 'EXIT WHEN 조건' : '조건'이 참인 경우 반복문의 범위를 벗어남(자바의 WHILE문과 반대임)
 
 사용예) 구구단의 7단의 출력
DECLARE
    V_CNT NUMBER := 1;
    V_RES NUMBER := 0; -- NUMBER는 반드시 초기화 시켜야함
BEGIN
    LOOP
        V_RES := 7*V_CNT;
        DBMS_OUTPUT.PUT_LINE(7||'*'||V_CNT||'='||V_RES);
        V_CNT := V_CNT+1;
        EXIT WHEN V_CNT>9;        
    END LOOP;
END;
    
사용예) 1~50사이의 피보나치수를 구하여 출력 --검색알고리즘에 사용(피보나치 서칭)
    FIBONACCI NUMBER : 첫번째와 두번째 수가 1,1로 주어지고 세번째 수부터 전 두수의 합이 
    현재수가 되는 수역 -> 검색 알고리즘에 사용
DECLARE
    V_PNUM NUMBER := 1; --전수
    V_PPNUM NUMBER := 1; --전전수
    V_CURRNUM NUMBER := 0; --현재수
    V_RES VARCHAR(100);
BEGIN
    V_RES := V_PPNUM||', '||V_PNUM;
    
    LOOP
        V_CURRNUM := V_PPNUM + V_PNUM;
        EXIT WHEN V_CURRNUM >= 50;
        V_RES := V_RES||', '||V_CURRNUM;
        V_PPNUM := V_PNUM;
        V_PNUM := V_CURRNUM;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('1~50사이의 피보나치 수 : '||V_RES);
END;

● 2) WHILE문
 - 개발언어의 WHILE문과 같은 기능
 - 조건을 미리 체크하여 조건이 참인 경우에만 반복 처리
 (사용형식)
 WHILE 조건
    LOOP
        반복처리문(들);
    END LOOP;

사용예) 첫날에 100원 둘째날 부터 전날의 2배씩 저축할 경우 최초로 100만원을 넘는 날과
      저축한 금액을 구하시오
DECLARE
    V_DAYS NUMBER := 1; --날짜
    V_AMT NUMBER := 100; --날짜별 저축할 금액
    V_SUM NUMBER := 0; --저축한 금액 합계
BEGIN
    WHILE V_SUM < 1000000 LOOP
        V_SUM := V_SUM + V_AMT;
        V_DAYS := V_DAYS + 1;
        V_AMT := V_AMT * 2;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('날수 : '||V_DAYS-1);
    DBMS_OUTPUT.PUT_LINE('금액 : '||V_SUM);
END;

SELECT * FROM MEMBER;
SELECT * FROM CART;
SELECT * FROM PROD;


사용예)회원테이블(MEMBER)에서 마일리지가 3000이상인 회원들을 찾아
     그들이 2005년 5월 구매한 횟수와 구매금액합계를 구하시오(커서사용)
     출력은 회원번호, 회원명, 구매횟수, 구매금액
DECLARE
V_MID   MEMBER.MEM_ID%TYPE; --회원번호
V_MNAME MEMBER.MEM_NAME%TYPE; --회원이름
V_CNT NUMBER := 0; --구매횟수
V_AMT NUMBER := 0; --구매금액 합계
    
    CURSOR CUR_CART_AMT
    IS
        SELECT MEM_ID, MEM_NAME
        FROM MEMBER
        WHERE MEM_MILEAGE >= 3000;
BEGIN
    OPEN CUR_CART_AMT;    
    LOOP
        FETCH CUR_CART_AMT INTO V_MID, V_MNAME;
        EXIT WHEN CUR_CART_AMT%NOTFOUND;
            SELECT SUM(A.CART_QTY * B.PROD_PRICE),
                   COUNT(A.CART_PROD) INTO V_AMT, V_CNT
            FROM CART A, PROD B
            WHERE A.CART_PROD = B.PROD_ID
              AND A.CART_MEMBER = V_MID
              AND SUBSTR(CART_NO, 1, 6) = '200505';
        DBMS_OUTPUT.PUT_LINE(V_MID||', '||V_MNAME||' => '||V_AMT||'('||V_CNT||')');
    END LOOP;    
    CLOSE CUR_CART_AMT;
END;

--(WHILE문 사용) *FETCH 주의
DECLARE
V_MID   MEMBER.MEM_ID%TYPE; --회원번호
V_MNAME MEMBER.MEM_NAME%TYPE; --회원이름
V_CNT NUMBER := 0; --구매횟수
V_AMT NUMBER := 0; --구매금액 합계
    
    CURSOR CUR_CART_AMT
    IS
        SELECT MEM_ID, MEM_NAME
        FROM MEMBER
        WHERE MEM_MILEAGE >= 3000;
BEGIN
    OPEN CUR_CART_AMT;   
    FETCH CUR_CART_AMT INTO V_MID, V_MNAME; --여기서 첫행을 읽어 와야 while문에서 found가 true로 실행 가능함
    WHILE CUR_CART_AMT%FOUND LOOP -- WHILE문에서는 앞단에 FETCH문이 있어야 %FOUND여부를 판단할 수 있다.
        --FETCH CUR_CART_AMT INTO V_MID, V_MNAME; 여기에 써주면 
            SELECT SUM(A.CART_QTY * B.PROD_PRICE),
                   COUNT(A.CART_PROD) INTO V_AMT, V_CNT
            FROM CART A, PROD B
            WHERE A.CART_PROD = B.PROD_ID
              AND A.CART_MEMBER = V_MID
              AND SUBSTR(CART_NO, 1, 6) = '200505';
        DBMS_OUTPUT.PUT_LINE(V_MID||', '||V_MNAME||' => '||V_AMT||'('||V_CNT||')');
        FETCH CUR_CART_AMT INTO V_MID, V_MNAME; -- WHILE문 밖에 FETCH가 왔으므로 첫줄에 배치하면 한 행을 건너 뛰게 된다.
    END LOOP;    
    CLOSE CUR_CART_AMT;
END;


● 3)FOR문 --FOR문은 OPEN, FETCH, CLOSE 생략
 - 반복횟수를 알고 있거나 횟수가 중요한 경우 사용
  ▶(사용형식① : 일반적 FOR)
  FOR 인덱스 IN[REVERSE] 최소값..최대값
  LOOP
    반복처리문(들)
  END LOOP;

사용예) 구구단 7단 출력
DECLARE
--    V_RES NUMBER := 0; --결과
BEGIN
    FOR I IN 1..9 LOOP
--        V_RES := 7*I;
        DBMS_OUTPUT.PUT_LINE(7||'*'||I||'='||7*I);
    END LOOP;
END;

 ▶(사용형식② : CURSOR에 사용하는 FOR)
 FOR 레코드명 IN 커서명|커서 선언문
 LOOP
    반복처리문(들);
 END LOOP;
 - '레코드명'은 시스템에서 자동으로 설정
 - 커서 컬럼 참조형식 : 레코드명.커서컬럼명 (변수 필요 없음)
 - 커서명 대신 커서 선언문(선언부에 존재했던)이 INLINE형식으로 기술 할 수 있음
 - FOR문을 사용하는 경우 커서의 OPEN, FETCH, CLOSE 문은 생략함
DECLARE 
V_CNT NUMBER := 0; --구매횟수
V_AMT NUMBER := 0; --구매금액 합계
    CURSOR CUR_CART_AMT
    IS
        SELECT MEM_ID, MEM_NAME
        FROM MEMBER
        WHERE MEM_MILEAGE >= 3000;
BEGIN
    FOR REC_CART IN CUR_CART_AMT LOOP -- CUR_CART_AMT가 실행되면 한 행씩 칼럼값을 REC_CART에 넣어준다.
            SELECT SUM(A.CART_QTY * B.PROD_PRICE),
                   COUNT(A.CART_PROD) INTO V_AMT, V_CNT
            FROM CART A, PROD B
            WHERE A.CART_PROD = B.PROD_ID
              AND A.CART_MEMBER = REC_CART.MEM_ID
              AND SUBSTR(CART_NO, 1, 6) = '200505';
        DBMS_OUTPUT.PUT_LINE(REC_CART.MEM_ID||', '||REC_CART.MEM_NAME||' => '||V_AMT||'('||V_CNT||')');
    END LOOP;    
END;

--(FOR문에서 INLINE 커서를 사용하는 방법) --제일 많이 쓰는 형식임!!!
DECLARE 
V_CNT NUMBER := 0; --구매횟수
V_AMT NUMBER := 0; --구매금액 합계    
BEGIN --DECLARE에서 CURSOR 선언 안하고 FOR문의 커서 선언부에 서브쿼리로 직접 기술
    FOR REC_CART IN (SELECT MEM_ID, MEM_NAME 
                     FROM MEMBER
                     WHERE MEM_MILEAGE >= 3000)
    LOOP
        SELECT SUM(A.CART_QTY * B.PROD_PRICE),
               COUNT(A.CART_PROD) INTO V_AMT, V_CNT
        FROM CART A, PROD B
        WHERE A.CART_PROD = B.PROD_ID
          AND A.CART_MEMBER = REC_CART.MEM_ID
          AND SUBSTR(CART_NO, 1, 6) = '200505';
    DBMS_OUTPUT.PUT_LINE(REC_CART.MEM_ID||', '||REC_CART.MEM_NAME||' => '||V_AMT||'('||V_CNT||')');
    END LOOP;    
END;

=============================================================




