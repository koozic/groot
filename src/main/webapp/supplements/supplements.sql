-- 영양성분 테이블
CREATE TABLE supplements (
    supplements_id NUMBER PRIMARY KEY,              -- 영양성분 고유번호 (PK)
    supplements_name VARCHAR2(255) NOT NULL,        -- 이름
    supplements_efficacy VARCHAR2(4000) NOT NULL,   -- 효능
    supplements_dosage VARCHAR2(255),               -- 1일 권장 복용량
    supplements_timing VARCHAR2(255),               -- 권장 복용 시간
    supplements_caution VARCHAR2(4000),             -- 주의사항
    supplements_image_path VARCHAR2(255),           -- 이미지 경로
    supplements_reg_date DATE DEFAULT SYSDATE,      -- 등록일
    supplements_view_count NUMBER DEFAULT 0         -- 조회수
);

-- 고유번호 자동 증가를 위한 시퀀스
CREATE SEQUENCE seq_supplements_id START WITH 1 INCREMENT BY 1;

-- 영양성분 좋아요 테이블
CREATE TABLE supplements_like (
    supplements_like_id NUMBER PRIMARY KEY,        -- 좋아요 고유번호 (PK)
    user_id VARCHAR2(50) NOT NULL,                  -- 유저 아이디 (FK)
    supplements_id NUMBER NOT NULL,                 -- 영양성분 고유번호 (FK)
    supplements_like_date DATE DEFAULT SYSDATE,        -- 찜한 날짜

    -- [복합 기본키 설정] 한 유저가 같은 성분을 중복해서 좋아요 할 수 없도록 방지
       CONSTRAINT id_supplements_like PRIMARY KEY (user_id, supplements_id),

    -- [외래키 및 삭제 옵션 설정]
    -- 1. 유저가 탈퇴하면 해당 유저의 좋아요 기록도 함께 삭제
       CONSTRAINT fk_like_user FOREIGN KEY (user_id)
       REFERENCES USERS(user_id)
       ON DELETE CASCADE,

    -- 2. 영양성분 정보가 삭제되면 해당 성분에 달린 좋아요 기록도 함께 삭제
       CONSTRAINT fk_like_supp FOREIGN KEY (supplements_id)
       REFERENCES supplements(supplements_id)
       ON DELETE CASCADE
);
