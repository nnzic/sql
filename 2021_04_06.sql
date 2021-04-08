
SQL문에 의해서 영향받은 행들의 집합
■ 커서(CURSOR)
 - 커서는 쿼리문의 영향을 받은 행들의 집합
 - 묵시적커서(IMPLICITE), 명시적(EXPLICITE) 커서로 구분
 - 커서의 선언은 선언부에서 수행
 - 커서의 OPEN, FETCH, CLOSE는 실행부에서 기술
 1) 묵시적 커서
 · 이름이 없는 커서
 · 항상 CLOSE 상태이기 때문에 커서내로 접근 불가능
 (커서 속성) 이름이 없기 때문에 %앞에 SQL붙임
-------------------------------------------------------------------------
   속성               의미
-------------------------------------------------------------------------
 SQL%ISOPEN         커서가 OPEN되었으면 참(TRUE) 반환 - 묵시적커서는 항상 FALSE
 SQL%NOTFOUND       커서내에 읽을 자료가 없으면 참(TRUE) 반환
 SQL%FOUND          커서내에 읽을 자료가 남아 있으면 참(TRUE) 반환
 SQL%ROWCOUNT       커서내 자료의 수 반환(행의 수)
-------------------------------------------------------------------------
 2) 명시적 커서
 · 이름이 있는 커서
 · 생성 -> OPEN -> FETCH(행 읽어오기) -> CLOSE 순으로 처리해야함(단, FOR문은 예외)
 
 (1) 생성
 (사용형식)
 CURSOR 커서명 [(매개변수 LIST)]
 IS
    SELECT 문;
    
-- 사용예) 상품매입테이블(BUYPROD)에서 2005년 3월 상품별 매입현황(상품코드, 상품명, 거래처명, 매입수량)을
--        출력하는 쿼리를 커서를 사용하여 작성하시오 -- 조인이 많이 될때의 단점을 줄여줌
DECLARE
    V_PCODE PROD.PROD_ID%TYPE; --참조형변수를 통해 동일한 타입으로 지정 가능
    V_PNAME PROD.PROD_NAME%TYPE; -- 변수 반드시 지정!
    V_BNAME BUYER.BUYER_NAME%TYPE;
    V_AMT NUMBER = 0; --타입의 크기를 모르면 생략할 수 있다. 하지만 초기화는 필수!!

    CURSOR CUR_BUY_INFO 
    IS
        SELECT BUY_PROD,
               SUM(BUY_QTY)
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050301' AND '20050331'
        GROUP BY BUY_PROD;

BEGIN

END;

 (2) OPEN문
  - 명시적 커서를 사용하기전 커서를 OPEN
  (사용형식)
  OPEN 커서명 [(매개변수 LIST)];
 
DECLARE
    V_PCODE PROD.PROD_ID%TYPE; --참조형변수를 통해 동일한 타입으로 지정 가능
    V_PNAME PROD.PROD_NAME%TYPE; -- 변수 반드시 지정!
    V_BNAME BUYER.BUYER_NAME%TYPE;
    V_AMT NUMBER = 0; --타입의 크기를 모르면 생략할 수 있다. 하지만 초기화는 필수!!

    CURSOR CUR_BUY_INFO 
    IS
        SELECT BUY_PROD,
               SUM(BUY_QTY) AS AMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050301' AND '20050331'
        GROUP BY BUY_PROD;

BEGIN
    OPEN CUR_BUY_INFO;
END;

 (3) FETCH문 (읽어서 넘겨줌 SELECT문과 비슷)
  - 커서 내의 자료를 읽어오는 명령
  - 보통 반복문 내에 사용
  (사용형식)
  FETCH 커서명 INTO 변수명
   커서내의 컬럼값을 INTO 다음에 기술된 변수에 할당
   
DECLARE --(선언부)
    V_PCODE PROD.PROD_ID%TYPE; --참조형변수를 통해 동일한 타입으로 지정 가능
    V_PNAME PROD.PROD_NAME%TYPE; -- 변수 반드시 지정!
    V_BNAME BUYER.BUYER_NAME%TYPE;
    V_AMT NUMBER := 0; --타입의 크기를 모르면 생략할 수 있다. 하지만 초기화는 필수!!

    CURSOR CUR_BUY_INFO 
    IS -- 선언부내에서 1.커서 생성
        SELECT BUY_PROD,
               SUM(BUY_QTY) AS AMT
        FROM BUYPROD
        WHERE BUY_DATE BETWEEN '20050301' AND '20050331' --날짜 타입이라 LIKE안쓰고 BETWEEN씀
        GROUP BY BUY_PROD;

BEGIN --(실행부)
    OPEN CUR_BUY_INFO; --2.커서 오픈
    
    LOOP
        FETCH CUR_BUY_INFO INTO V_PCODE, V_AMT; --3.FETCH(행 읽어오기)
        EXIT WHEN CUR_BUY_INFO%NOTFOUND; -- 추가로 커서와 조인해주고 값 받아오기
          SELECT PROD_NAME, BUYER_NAME INTO V_PNAME, V_BNAME
          FROM PROD, BUYER
          WHERE PROD_ID = V_PCODE
            AND PROD_BUYER = BUYER_ID;
        DBMS_OUTPUT.PUT_LINE('상품코드 : '||V_PCODE);
        DBMS_OUTPUT.PUT_LINE('상품명 : '||V_PNAME);
        DBMS_OUTPUT.PUT_LINE('거래처명 : '||V_BNAME);
        DBMS_OUTPUT.PUT_LINE('매입수량 : '||V_AMT);
        DBMS_OUTPUT.PUT_LINE('------------------------');        
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('자료수 : '||CUR_BUY_INFO%ROWCOUNT);
    CLOSE CUR_BUY_INFO; --4.커서 클로즈
END;


--사용예) 상품분류코드 'P102'에 속한 상품의 상품명, 매입가격, 마일리지를 출력하는 커서를 작성하시오.
(표준SQL) --PL/SQL에서는 여러행 출력이 불가 -> 그래서 커서를 사용하고 반복문을 이용해야 한다.
SELECT PROD_NAME,
       PROD_COST,
       PROD_MILEAGE
FROM PROD
WHERE PROD_LGU = 'P102';
(익명블록)
ACCEPT P_LCODE PROMPT 'P_LGU 입력 : ' --입력받음
DECLARE
    V_PNAME PROD.PROD_NAME%TYPE;
    V_COST PROD.PROD_COST%TYPE;
    V_MILE PROD.PROD_MILEAGE%TYPE;
    
    CURSOR CUR_PROD_COST(P_LGU LPROD.LPROD_GU%TYPE) 
    IS --커서에서 매개변수 사용 예(좋은 커서는 아님)
        SELECT PROD_NAME, PROD_COST, PROD_MILEAGE
        FROM PROD
        WHERE PROD_LGU = P_LGU;
BEGIN
    OPEN CUR_PROD_COST('%P_LCODE'); -- 여기에 매개변수의 값을 기술
    DBMS_OUTPUT.PUT_LINE('상품명      '||'   '||'     단  가'||'   '||'마일리지');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------');
    LOOP
        FETCH CUR_PROD_COST INTO V_PNAME, V_COST, V_MILE;
        EXIT WHEN CUR_PROD_COST%NOTFOUND;        
        DBMS_OUTPUT.PUT_LINE(V_PNAME||'   '||V_COST||'   '||NVL(V_MILE, 0));
    END LOOP;
    CLOSE CUR_PROD_COST;
END;


-----------------------------------------------------------------------------------------------------

■ 조건문
● IF문
- 개발언어의 조건문(IF문)과 동일 기능 제공
--(사용형식1)
IF 조건식 THEN
  명령문1;
[ELSE
  명령문2;]
END IF;

--(사용형식2) 조건 많음
IF 조건식1 THEN
  명령문1;
ELSIF 조건식2
  명령문2;
[ELSIF 조건식3
  명령문3;
   :
ELSE
  명령문N;]
END IF;

--(사용형식3) 중첩IF
IF 조건식1 THEN
  명령문1;
    IF 조건식2
      명령문2;
    ELSE
      명령문3;
    END IF;
ELSE
  명령문4;
END IF;

--[사용예] 상품테이블에서 'P201'분류에 속한 상품들의 평균단가를 구하고 해당 분류에 속한 상품들의
--       판매단가를 비교하여 같으면 '평균가격 상품', 적으면 '평균가격 이하 상품',
--       많으면 '평균가격 이상 상품'을 비고난에 출력(상품코드, 상품명, 가격, 비고)
DECLARE -- 익명블록 선언부
    V_PCODE PROD.PROD_ID%TYPE; --변수 선언(참조변수로 타입 지정)
    V_PNAME PROD.PROD_NAME%TYPE;
    V_PRICE PROD.PROD_PRICE%TYPE;
    V_REMARKS VARCHAR2(50); -- 직접 타입지정
    V_AVG_PRICE PROD.PROD_PRICE%TYPE;
    
    CURSOR CUR_PROD_PRICE -- 커서생성
    IS 
        SELECT PROD_ID, PROD_NAME, PROD_PRICE --커서로로 만들어서 값 넣어준 컬럼들
        FROM PROD
        WHERE PROD_LGU = 'P201';
BEGIN -- 실행영역
    SELECT ROUND(AVG(PROD_PRICE)) INTO V_AVG_PRICE --평균가격 구하는 SELECT문
    FROM PROD
    WHERE PROD_LGU='P201';
    
    OPEN CUR_PROD_PRICE; -- 커서 OPEN
    LOOP -- 반복문 돌려서 다중행 값 저장
        FETCH CUR_PROD_PRICE INTO V_PCODE, V_PNAME, V_PRICE; --(FETCH) 커서로 만든 컬럼 행 값들을 사용하기 위해 위의 선언한 변수로 받아옴
        EXIT WHEN CUR_PROD_PRICE%NOTFOUND; --커서의 값이 없을 때 LOOP문 빠져나가라
            IF V_PRICE > V_AVG_PRICE THEN V_REMARKS := '평균가격 이상 상품'; -- 한행 씩 조건 검사 후 V_REMARKS에 값 넣어줌
            ELSIF V_PRICE < V_AVG_PRICE THEN V_REMARKS := '평균가격 이하 상품';
            ELSE V_REMARKS := '평균가격 상품';
            END IF; --IF문 종료
        DBMS_OUTPUT.PUT_LINE(V_PCODE||', '||V_PNAME||', '||V_PRICE||', '||V_REMARKS); -- 출력
    END LOOP; --반복문 종료
    CLOSE CUR_PROD_PRICE; -- 커서 CLOSE
--    SELECT PROD_ID, PROD_NAME, PROD_PRICE INTO V_PCODE, V_PNAME, V_PRICE --스칼라변수는 오직 하나의 값만 들어감
--    FROM PROD
--    WHERE PROD_LGU='P201';
END; --익명블록 종료


● CASE문
 - JAVA의 SWITCH CASE문과 유사기능 제공
 - 다방향 분기 기능 제공
 (사용형식)
 CASE 변수명|수식 
        WHEN 값1 THEN
            명령1;
        WHEN 값2 THEN
            명령2;
             :
        ELSE
            명령N;
 END CASE;
    
CASE WHEN 조건식1 THEN
          명령1;
     WHEN 조건식2 THEN
          명령2;
           :
     ELSE
          명령N;
END CASE;

전기세, 수도요금 (누진세, 여러범위)
사용예) 수도요금 계산
       물 사용요금(톤당 단가)
        1 - 10 : 350원
       11 - 20 : 550원
       21 - 30 : 900원
       그 이상  : 1500원

       하수도 사용료
       사용량 * 450원
26톤 사용시 요금
       (10 * 350) + (10 * 550) + (6 * 900) + (26 * 450) = 
          3500    +    5500    +    5400   +    11700   =  26100원

ACCEPT P_AMOUNT PROMPT '물 사용량 : '
DECLARE
    V_AMT NUMBER := TO_NUMBER('&P_AMOUNT');
    V_WA1 NUMBER := 0; -- 물 사용요금
    V_WA2 NUMBER := 0; -- 하수도 사용요금
    V_HAP NUMBER := 0; -- 요금 합계
BEGIN
    CASE WHEN V_AMT BETWEEN 1 AND 10 THEN V_WA1 := V_AMT*350;
         WHEN V_AMT BETWEEN 11 AND 20 THEN V_WA1 := 3500 + (V_AMT-10) * 550;
         WHEN V_AMT BETWEEN 21 AND 30 THEN V_WA1 := 3500 + 5500 + (V_AMT-20) * 900;
         ELSE V_WA1 := 3500 + 5500 + 9000 + (V_AMT-30) * 1500;
    END CASE;
    V_WA2 := V_AMT*450;
    V_HAP := V_WA1 + V_WA2;
    
    DBMS_OUTPUT.PUT_LINE(V_AMT||'톤의 수도요금 : '||V_HAP);
END;












