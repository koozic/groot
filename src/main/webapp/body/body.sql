-- 1. body 테이블
CREATE TABLE body
(
    body_id    NUMBER PRIMARY KEY,    -- 신체 부위 PK
    body_name  VARCHAR2(50) NOT NULL, -- 예: 눈, 간, 피부
    body_image VARCHAR2(255)          -- 이미지 경로
);

-- 2. body_supplement 관계 테이블 (수정됨: 복합 PK 추가)
CREATE TABLE body_supplement
(
    body_id       NUMBER, -- 어떤 신체 부위인지
    supplement_id NUMBER, -- 어떤 영양제인지

    -- 두 컬럼을 묶어서 PK로 지정하여 중복 데이터 방지
    CONSTRAINT body_supplement_id PRIMARY KEY (body_id, supplement_id),

    CONSTRAINT fk_body
        FOREIGN KEY (body_id)
            REFERENCES body (body_id),

    CONSTRAINT fk_supplements
        FOREIGN KEY (supplement_id)
            REFERENCES supplements (supplement_id)
    -- 주의: DB에 supplement 테이블이 먼저 있어야 함!
);

-- 3. curation 테이블
CREATE TABLE curation
(
    curation_id          NUMBER PRIMARY KEY,     -- 큐레이션 PK
    curation_name        VARCHAR2(100) NOT NULL, -- 예: 수험생, 임산부
    curation_description VARCHAR2(1000),         -- 설명

    view_count           NUMBER DEFAULT 0,       -- 조회수
    like_count           NUMBER DEFAULT 0,       -- 좋아요 수

    user_id              varchar2(30 CHAR),      -- 어느 유저인지
    body_id              NUMBER,                 -- 어느 신체인지

    curation_image       VARCHAR2(255),          -- 이미지

    CONSTRAINT fk_user
        FOREIGN KEY (user_id)
            REFERENCES users (user_id),
    -- 주의: DB에 users 테이블이 먼저 있어야 함!

    CONSTRAINT fk_body_curation
        FOREIGN KEY (body_id)
            REFERENCES body (body_id)
);

-- 2. 큐레이션 좋아요/북마크 테이블 (기능 2, 3용)
CREATE TABLE curation_likes
(
    curation_like_id NUMBER PRIMARY KEY,
    user_id          varchar2(30 CHAR) NOT NULL,
    curation_id      NUMBER            NOT NULL,
    created_at       DATE DEFAULT SYSDATE, -- 최신순 정렬용

    CONSTRAINT fk_cur_like_user FOREIGN KEY (user_id) REFERENCES users (user_id),
    CONSTRAINT fk_cur_like_item FOREIGN KEY (curation_id) REFERENCES curation (curation_id),
    -- 한 유저가 동일 큐레이션에 중복 좋아요 방지
    CONSTRAINT uk_cur_like UNIQUE (user_id, curation_id)
);

-- 4. 시퀀스 생성
CREATE SEQUENCE seq_body START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_curation START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_curation_likes START WITH 1 INCREMENT BY 1;

INSERT INTO body
VALUES (2, '눈', null);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (1, 1);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (1, 2);

-- ① 현재 데이터 확인
SELECT *
FROM body;
SELECT *
FROM supplements;
SELECT *
FROM body_supplement;

select user
from dual;

SELECT owner, table_name
FROM all_tables
WHERE table_name = 'SUPPLEMENTS';

SELECT constraint_type
FROM user_constraints
WHERE table_name = 'SUPPLEMENTS';

-- ② body 테이블에 신체 부위 데이터가 없으면 INSERT
-- (이미 있으면 생략)

INSERT INTO body (body_id, body_name, body_image)
VALUES (seq_body.NEXTVAL, '눈', 'images/body/eye.png');

INSERT INTO body (body_id, body_name, body_image)
VALUES (seq_body.NEXTVAL, '간', 'images/body/liver.png');

INSERT INTO body (body_id, body_name, body_image)
VALUES (seq_body.NEXTVAL, '피로개선', 'images/body/tired.png');

INSERT INTO body (body_id, body_name, body_image)
VALUES (seq_body.NEXTVAL, '뼈/관절', 'images/body/bone.png');

-- ③ supplements 테이블에 영양소 데이터가 없으면 INSERT
-- supplement_id는 실제 DB에 맞는 시퀀스명으로 변경하세요
INSERT INTO supplements
(supplement_id, supplement_name, supplement_efficacy,
 supplement_dosage, supplement_timing, supplement_caution,
 supplement_image_path, supplement_view_count, supplement_reg_date)
VALUES (1, '루테인', '눈 건강 및 황반 보호',
        '하루 1정 (20mg)', '식후 복용 권장', '과다복용 시 피부 황변 가능',
        'images/supp/lutein.png', 0, SYSDATE);

INSERT INTO supplements
(supplement_id, supplement_name, supplement_efficacy,
 supplement_dosage, supplement_timing, supplement_caution,
 supplement_image_path, supplement_view_count, supplement_reg_date)
VALUES (2, '비타민A', '시력 유지 및 야맹증 예방',
        '하루 1정', '아침 식후', '임산부 과다복용 주의',
        'images/supp/vitaminA.png', 0, SYSDATE);

INSERT INTO supplements
(supplement_id, supplement_name, supplement_efficacy,
 supplement_dosage, supplement_timing, supplement_caution,
 supplement_image_path, supplement_view_count, supplement_reg_date)
VALUES (3, '밀크씨슬', '간 기능 개선 및 해독',
        '하루 1~2정 (150mg)', '식전 30분', '담도 폐색 환자 주의',
        'images/supp/milk_thistle.png', 0, SYSDATE);

-- ④ body_supplement 연결 테이블 (가장 중요!)
-- 눈(body_id=1) ↔ 루테인(1), 비타민A(2)
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (1, 1);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (1, 2);

-- 간(body_id=2) ↔ 밀크씨슬(3)
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (2, 3);

COMMIT;

-- ⑤ 연결 확인 쿼리 (이게 데이터 나와야 화면에 표시됨)
SELECT s.supplement_name, b.body_name
FROM body_supplement bs
         JOIN body b ON bs.body_id = b.body_id
         JOIN supplements s ON bs.supplement_id = s.supplement_id;

-- supplements 테이블 PK 시퀀스
CREATE SEQUENCE seq_supplements
    START WITH 1 INCREMENT BY 1 NOCACHE;

select *
from ADMIN;

SELECT sequence_name, last_number
FROM user_sequences
WHERE sequence_name LIKE 'SEQ_SUPPLEMENTS%';

SELECT *
FROM admin
WHERE admin_id = 'admin1';

select *
from USERS;

-- =============================================
-- 기존 데이터 정리 (FK 순서 주의)
-- =============================================
DELETE
FROM body_supplement;
DELETE
FROM supplements_like;
DELETE
FROM supplements;
DELETE
FROM body;
COMMIT;

-- =============================================
-- body 테이블 — DB의 body_id에 맞게 직접 INSERT
-- =============================================
INSERT INTO body (body_id, body_name, body_image)
VALUES (1, 'hair', 'images/body/hair.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (2, 'skin', 'images/body/skin.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (3, 'eye', 'images/body/eye.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (4, 'brain', 'images/body/brain.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (5, 'lung', 'images/body/lung.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (6, 'heart', 'images/body/heart.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (7, 'liver', 'images/body/liver.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (8, 'stomach', 'images/body/stomach.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (9, 'intestine', 'images/body/intestine.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (10, 'bone', 'images/body/bone.png');
INSERT INTO body (body_id, body_name, body_image)
VALUES (11, 'muscle', 'images/body/muscle.png');
COMMIT;

select *
from body;

drop table body;

DELETE
FROM body_supplement;
DELETE
FROM body;

-- 1. supplements 테이블에 데이터 있는지 확인
SELECT supplement_id, supplement_name
FROM supplements
ORDER BY supplement_id;

-- 2. body_supplement 연결 데이터 있는지 확인
SELECT *
FROM body_supplement;

-- 3. 연결이 제대로 됐는지 JOIN 확인
SELECT b.body_id, b.body_name, s.supplement_id, s.supplement_name
FROM body_supplement bs
         JOIN body b ON bs.body_id = b.body_id
         JOIN supplements s ON bs.supplement_id = s.supplement_id
ORDER BY b.body_id;

-- =============================================
-- body_supplement 연결 데이터
-- body_id 기준: 1=hair, 2=skin, 3=eye, 4=brain,
--              5=lung, 6=heart, 7=liver, 8=stomach,
--              9=intestine, 10=bone, 11=muscle
-- =============================================

-- 1. hair (머리카락) — 비오틴B7=7, 아연=13, 철분=15
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (1, 7);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (1, 13);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (1, 15);

-- 2. skin (피부) — 비타민C=9, 비타민E=11, 히알루론산=28
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (2, 9);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (2, 11);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (2, 28);

-- 3. eye (눈) — 루테인지아잔틴=27, 비타민A=1, 오메가3=25, 아연=13
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (3, 27);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (3, 1);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (3, 25);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (3, 13);

-- 4. brain (뇌) — 오메가3=25, 콜린=26, 비타민B6=6, 마그네슘=14
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (4, 25);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (4, 26);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (4, 6);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (4, 14);

-- 5. lung (폐) — 비타민C=9, NAC=38, 퀘르세틴=39, 오메가3=25
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (5, 9);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (5, 38);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (5, 39);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (5, 25);

-- 6. heart (심장) — 오메가3=25, 코엔자임Q10=17, 마그네슘=14, 식이섬유=35
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (6, 25);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (6, 17);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (6, 14);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (6, 35);

-- 7. liver (간) — 밀크씨슬=37, 비타민B2=3, 비타민B6=6, NAC=38
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (7, 37);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (7, 3);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (7, 6);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (7, 38);

-- 8. stomach (위) — 글루타민=36, 프로바이오틱스=33, 아연=13
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (8, 36);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (8, 33);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (8, 13);

-- 9. intestine (장) — 프로바이오틱스=33, 프리바이오틱스=34, 식이섬유=35, 글루타민=36
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (9, 33);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (9, 34);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (9, 35);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (9, 36);

-- 10. bone (뼈) — 칼슘=16, 비타민D=10, MSM=29, 글루코사민콘드로이틴=30
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (10, 16);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (10, 10);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (10, 29);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (10, 30);

-- 11. muscle (근육) — 크레아틴=31, 마그네슘=14, 칼륨=32
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (11, 31);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (11, 14);
INSERT INTO body_supplement (body_id, supplement_id)
VALUES (11, 32);

COMMIT;

-- =============================================
-- 확인 쿼리
-- =============================================
SELECT b.body_id, b.body_name, s.supplement_id, s.supplement_name
FROM body_supplement bs
         JOIN body b ON bs.body_id = b.body_id
         JOIN supplements s ON bs.supplement_id = s.supplement_id
ORDER BY b.body_id, s.supplement_id;


--=================================================
-- 영양소 등록 안돼서

-- 1. 현재 테이블에 있는 가장 큰 ID 값을 확인합니다.
SELECT MAX(supplement_id)
FROM supplements;

-- 2. 기존 시퀀스를 삭제합니다.
DROP SEQUENCE seq_supplements;

-- 3. 위 1번에서 나온 최대값에 +1을 한 숫자로 시퀀스를 다시 만듭니다.
-- (예: 최대값이 50이었다면 START WITH 51)
CREATE SEQUENCE seq_supplements START WITH 40 INCREMENT BY 1;


