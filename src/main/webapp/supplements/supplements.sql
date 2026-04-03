-- [1단계] 기존에 잘못 만들어진 흔적들 깔끔하게 지우기 (먼저 실행)
DROP TABLE supplements_like CASCADE CONSTRAINTS;
DROP TABLE supplements CASCADE CONSTRAINTS;
DROP SEQUENCE seq_supplements_id;

-- 영양성분 테이블
CREATE TABLE supplements (
    supplement_id NUMBER PRIMARY KEY,              -- 영양성분 고유번호 (PK)
    supplement_name VARCHAR2(255) NOT NULL,        -- 이름
    supplement_efficacy VARCHAR2(4000) NOT NULL,   -- 효능
    supplement_dosage VARCHAR2(255),               -- 1일 권장 복용량
    supplement_timing VARCHAR2(255),               -- 권장 복용 시간
    supplement_caution VARCHAR2(4000),             -- 주의사항
    supplement_image_path VARCHAR2(255),           -- 이미지 경로
    supplement_reg_date DATE DEFAULT SYSDATE,      -- 등록일
    supplement_view_count NUMBER DEFAULT 0         -- 조회수
);

-- 고유번호 자동 증가를 위한 시퀀스
CREATE SEQUENCE seq_supplements_id START WITH 1 INCREMENT BY 1;

-- 영양성분 좋아요 테이블
CREATE TABLE supplements_like (
    supplement_like_id NUMBER PRIMARY KEY,        -- 좋아요 고유번호 (PK)
    user_id VARCHAR2(50) NOT NULL,                  -- 유저 아이디 (FK)
    supplement_id NUMBER NOT NULL,                 -- 영양성분 고유번호 (FK)
    supplement_like_date DATE DEFAULT SYSDATE,        -- 찜한 날짜

    -- [유니크 제약조건 설정] 한 유저가 같은 성분을 중복해서 좋아요 할 수 없도록 방지
    -- 💡 PRIMARY KEY 대신 UNIQUE를 사용하여 중복만 막아줍니다.
    CONSTRAINT uq_supplements_like UNIQUE (user_id, supplement_id),

    -- [외래키 및 삭제 옵션 설정]
    -- 1. 유저가 탈퇴하면 해당 유저의 좋아요 기록도 함께 삭제
        CONSTRAINT fk_like_user FOREIGN KEY (user_id)
        REFERENCES USERS(user_id)
        ON DELETE CASCADE,

    -- 2. 영양성분 정보가 삭제되면 해당 성분에 달린 좋아요 기록도 함께 삭제
        CONSTRAINT fk_like_supp FOREIGN KEY (supplement_id)
        REFERENCES supplements(supplement_id)
        ON DELETE CASCADE
);

-- 가데이터
-- 1. 비타민 C
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 C', '항산화 작용, 면역력 증진, 피로 회복', '1일 1정 (1000mg)', '식후', '공복 섭취 시 위장장애나 속쓰림이 있을 수 있습니다.', '/img/supp/vit_c.png');

-- 2. 오메가3
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '오메가3', '혈중 중성지질 개선, 혈행 개선, 건조한 눈 개선', '1일 1캡슐 (1000mg)', '식후', '어류 알레르기가 있는 경우 섭취에 주의하세요.', '/img/supp/omega3.png');

-- 3. 마그네슘
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '마그네슘', '근육 및 신경 기능 유지, 에너지 이용에 필요', '1일 1정 (300mg)', '취침 전', '신장 질환이 있는 경우 전문가와 상담 후 섭취하세요.', '/img/supp/magnesium.png');

-- 4. 유산균 (프로바이오틱스)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '프로바이오틱스', '유산균 증식 및 유해균 억제, 배변활동 원활, 장 건강', '1일 1캡슐', '기상 직후 공복', '면역 억제제를 복용 중인 환자는 주의가 필요합니다.', '/img/supp/probiotics.png');

-- 5. 비타민 B 컴플렉스
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 B 컴플렉스', '체내 에너지 생성, 육체 피로 회복', '1일 1정', '아침 식전 또는 식후', '섭취 후 소변 색이 노랗게 변할 수 있으나 정상적인 반응입니다.', '/img/supp/vit_b.png');

-- 6. 루테인
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '루테인', '노화로 인해 감소될 수 있는 황반색소밀도를 유지하여 눈 건강에 도움', '1일 1캡슐 (20mg)', '식후', '과다 섭취 시 피부가 일시적으로 황색으로 변할 수 있습니다.', '/img/supp/lutein.png');

-- 7. 칼슘
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '칼슘', '뼈와 치아 형성, 신경과 근육 기능 유지, 골다공증 발생 위험 감소', '1일 2정 (총 600mg)', '식후', '고칼슘혈증이 있거나 관련 의약품 복용 시 전문가와 상담하세요.', '/img/supp/calcium.png');

-- 8. 밀크씨슬
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '밀크씨슬 (실리마린)', '간 건강에 도움을 줄 수 있음', '1일 1정 (130mg)', '식후', '국화과 식물 알레르기가 있는 경우 섭취를 피하십시오.', '/img/supp/milk_thistle.png');

-- 9. 코엔자임 Q10
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '코엔자임 Q10', '항산화, 높은 혈압 감소에 도움을 줄 수 있음', '1일 1캡슐 (100mg)', '식후', '임산부, 수유부 및 어린이는 섭취를 피하는 것이 좋습니다.', '/img/supp/coq10.png');

-- 10. 아연
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '아연', '정상적인 면역 기능, 정상적인 세포 분열에 필요', '1일 1정 (15mg)', '식후', '과다 섭취 시 체내 구리 흡수를 방해할 수 있습니다.', '/img/supp/zinc.png');

-- 데이터베이스에 영구 반영 (필수)
COMMIT;

SELECT * FROM SUPPLEMENTS;
