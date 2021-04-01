
■ VIEW 객체
º view는 table과 유사한 객체이다
º view는 기존의 테이블이나 다른 view 객체를 통하여 새로운 select문의 결과를 테이블처럼 사용한다.(가상테이블)
º view는 select문에 귀속되는 것이 아니고, 독립적으로 테이블처럼 존재
º view를 이용하는 경우
 - 필요한 정보가 한 개의 테이블에 있지 않고, 여러 개의 테이블에 분산되어 있는 경우
 - 테이블에 들어 있는 자료의 일부분만 필요하고 자료 전체 row나 column이 필요하지 않은 경우
 - 특정 자료에 대한 접근 제한하고자 할 경우(보안)

ex)
테이블의은 데이터 access시간이 오래걸림
조인, 서브쿼리로 얻은 결과 - 코드가 굉장히 복잡하게 구성(depts가 깊다)
 => 이 결과가 여러 군데에서 쓰인다? view를 만들어 효율적으로 쓰자
 
비용과 시간을 많이 들여 테이블 만듬
민감한 정보가 많은 테이블이다?
 => view를 만들어 제공(허용되는 범위만 공개)
 
 
■ 시퀀스
 오라클에서 시퀀스 테이블에 독립적임 
 1씩 증감
 
 
■ 인덱스
 별도 파일이 만들어짐 => 찾기의 효율성 증대
 자료구조 - 해싱기법을 통해 인덱스 구성
 b(이진)트리를 통해 인덱스 관리(정렬됨) - 검색 이진트리(왼쪽 자식은 부모보다 작고 오른쪽 자식을 부모보다 크다)
 인덱스 파일의 유지보수가 오래걸린다 => 많이 만든다고 좋은게 아니다. 적당히 만들자
 
 =======================================================================
 
■ view객체
 º TABLE과 유사한 기능 제공
 º 보안, Query 실행의 효율성, TABLE의 은닉성을 위하여 사용
 (사용형식)
 CREATE [OR REPLACE] [FORCE | NOFORCE] VIEW 뷰이름[(컬럼LIST)]
 AS
    SELECT문
    [WITH CHECK OPTION;]
    [WITH READ ONLY;]
    
 º 'OR REPLACE' 옵션 : 뷰가 존재하면 대치되고 없으면 신규로 생성
 º 'FORCE | NOFORCE' 옵션 : 원본 테이블의 존재하지 않아도 뷰를 생성(FORCE), 생성불가(NOFORCE)
 º '컬럼LIST' : 생성된 뷰의 컬럼명
 º 'WITH CHECK OPTION' : SELECT문의 조건절에 위배되는 경우 DML명령 실행 거부(insert, update, delete)
 º 'WITH READ ONLY' : 읽기전용 뷰 생성(원본 테이블에 영향을 주지 않는다) --WITH CHECK OPTION와 동시에 못씀
 
사용예) 사원테이블에서 부모부서코드가 90번부서에 속한 자원정보를 조회하시오.
       조회항 데이터 : 사원번호, 사원명, 부서명, 급여
SELECT
FROM emp

사용예) 회원테이블에서 마일리지가 3000이상인 회원의 회원번호, 회원명을 조회하시오.
SELECT mem_id AS 회원번호,
       mem_name AS 회원명,
       mem_job AS 직업,
       mem_mileage AS 마일리지
FROM member
WHERE mem_mileage >= 3000;

=> 뷰생성
CREATE OR REPLACE VIEW V_MEMBER01
AS
    SELECT mem_id AS 회원번호,
           mem_name AS 회원명,
           mem_job AS 직업,
           mem_mileage AS 마일리지
    FROM member
    WHERE mem_mileage >= 3000;

SELECT *
FROM V_MEMBER01;

(신용환회원의 자료 검색) -- 7거지약 좌변을 가공하지 말라!!!
SELECT mem_name, mem_job, mem_mileage
FROM member
WHERE UPPER(mem_id) = 'C001';

(member테이블에서 신용환의 마일리지를 10000으로 변경)
UPDATE member 
   SET mem_mileage = 10000 
WHERE mem_name = '신용환';

(view V_MEMBER01에서 신용환의 마일리지를 10000으로 변경)
UPDATE V_MEMBER01
   SET 마일리지 = 500
WHERE 회원명 = '신용환';

-- WITH CHECK OPTION 사용 VIEW생성
CREATE OR REPLACE VIEW V_MEMBER01(mid, mname, mjob, mile) --사용자 지정(최우선)
AS
    SELECT mem_id AS 회원번호, -- 별칭(두번째)
           mem_name AS 회원명, -- 별칭 없으면 select문 속성명(세번째)
           mem_job AS 직업,
           mem_mileage AS 마일리지
    FROM member
    WHERE mem_mileage >= 3000    
    WITH CHECK OPTION;

SELECT * FROM V_MEMBER01;

(뷰 V_MEMBER01에서 신용환 회원의 마일리지를 2000 으로 변경)
UPDATE V_MEMBER01
SET mile = 2000
WHERE mid = 'c001'; -- 뷰의 where절 조건 위배

(테이블 member에서 신용환 회원의 마일리지를 2000 으로 변경)
UPDATE member
SET mem_mileage = 2000
WHERE mem_ID = 'c001'

테이블에서는 제약 없이 DML가능 -> 뷰에 반영
but 뷰에서는 제약에 따라 DML수행

ROLLBACK;

CREATE OR REPLACE VIEW V_MEMBER01(mid, mname, mjob, mile)
AS
    SELECT mem_id AS 회원번호, 
           mem_name AS 회원명, 
           mem_job AS 직업,
           mem_mileage AS 마일리지
    FROM member
    WHERE mem_mileage >= 3000    
    WITH READ ONLY;
    --WITH CHECK OPTION; //WITH READ ONLY와 동시에 못씀

SELECT mem_name, mem_job, mem_mileage
FROM member
WHERE UPPER(mem_id) = 'C001';
SELECT * FROM V_MEMBER01;

(뷰 V_MEMBER01에서 오철희 회원의 마일리지를 5700 으로 변경)
UPDATE V_MEMBER01
SET mile = 5700
WHERE mid = 'k001'


-- 오라클은 보안문제와 사용자마다 다른 구조를 갖고 있기때문에 데이터를 파일로 import / export 해서 사용해야 한다.

SELECT hr.departments.department_id, -- 계정.테이블명.컬럼명
       department_name, manager_id
FROM hr.departments

========================================================================

[문제1] HR계정의 사원테이블(employees)에서 50번 부서에 속한 사원 중 급여가 5000이상인 
      사원번호, 사원명, 입사일, 급여를 읽기 전용 뷰로 생성하시오.
      뷰 이릉은 v_emp_sal01이고 컬럼명은 원본테이블의 컬럼명을 사용
      뷰가 생성된 후 뷰와 테이블을 이용하여 해당 사원의 사원번호, 사원명, 직무명, 급여를 출력하는 sql작성
CREATE OR REPLACE VIEW v_emp_sal01
AS
    SELECT employee_id, emp_name, hire_date, salary
    FROM employees
    WHERE department_id = 50
      AND salary >= 5000
WITH READ ONLY;

SELECT * FROM v_emp_sal01;
SELECT * FROM employees;
SELECT * FROM jobs;

-- VIEW목적에 위배
SELECT employees.employee_id AS 사원번호, employees.emp_name AS 사원명,
       jobs.job_title AS 직무명, employees.salary AS 급여
FROM employees, v_emp_sal01, jobs
WHERE employees.employee_id = v_emp_sal01.employee_id
  AND employees.job_id = jobs.job_id

-- 나중에 pl/sql
묵시적 커서 
명시적 커서 - 하나하나씩 꺼내서 읽을 수 있다 fetch






