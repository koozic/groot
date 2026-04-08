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



