-- 1. body 테이블
CREATE TABLE body (
                      body_id NUMBER PRIMARY KEY,            -- 신체 부위 PK
                      body_name VARCHAR2(50) NOT NULL,       -- 예: 눈, 간, 피부
                      body_image VARCHAR2(255)               -- 이미지 경로
);

-- 2. body_supplement 관계 테이블 (수정됨: 복합 PK 추가)
CREATE TABLE body_supplement (
                                 body_id NUMBER,                    -- 어떤 신체 부위인지
                                 supplement_id NUMBER,              -- 어떤 영양제인지

    -- 두 컬럼을 묶어서 PK로 지정하여 중복 데이터 방지
                                 CONSTRAINT body_supplement_id PRIMARY KEY (body_id, supplement_id),

                                 CONSTRAINT fk_body
                                     FOREIGN KEY (body_id)
                                         REFERENCES body(body_id),

                                 CONSTRAINT fk_supplements
                                     FOREIGN KEY (supplement_id)
                                         REFERENCES supplements(supplement_id)
    -- 주의: DB에 supplement 테이블이 먼저 있어야 함!
);

-- 3. curation 테이블
CREATE TABLE curation (
                          curation_id NUMBER PRIMARY KEY,          -- 큐레이션 PK
                          curation_name VARCHAR2(100) NOT NULL,    -- 예: 수험생, 임산부
                          curation_description VARCHAR2(1000),     -- 설명

                          view_count NUMBER DEFAULT 0,       -- 조회수
                          like_count NUMBER DEFAULT 0,       -- 좋아요 수

                          user_id varchar2(30 CHAR),                    -- 어느 유저인지
                          body_id NUMBER,                    -- 어느 신체인지

                          curation_image VARCHAR2(255),      -- 이미지

                          CONSTRAINT fk_user
                              FOREIGN KEY (user_id)
                                  REFERENCES users(user_id),
    -- 주의: DB에 users 테이블이 먼저 있어야 함!

                          CONSTRAINT fk_body_curation
                              FOREIGN KEY (body_id)
                                  REFERENCES body(body_id)
);

-- 2. 큐레이션 좋아요/북마크 테이블 (기능 2, 3용)
CREATE TABLE curation_likes (
                                curation_like_id NUMBER PRIMARY KEY,
                                user_id varchar2(30 CHAR) NOT NULL,
                                curation_id NUMBER NOT NULL,
                                created_at DATE DEFAULT SYSDATE, -- 최신순 정렬용

                                CONSTRAINT fk_cur_like_user FOREIGN KEY (user_id) REFERENCES users(user_id),
                                CONSTRAINT fk_cur_like_item FOREIGN KEY (curation_id) REFERENCES curation(curation_id),
    -- 한 유저가 동일 큐레이션에 중복 좋아요 방지
                                CONSTRAINT uk_cur_like UNIQUE (user_id, curation_id)
);

-- 4. 시퀀스 생성
CREATE SEQUENCE seq_body START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_curation START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_curation_likes START WITH 1 INCREMENT BY 1;

INSERT INTO body (body_id, body_name)
VALUES (1, '눈');
INSERT INTO body_supplement (body_id, supplement_id) VALUES (1, 10);
