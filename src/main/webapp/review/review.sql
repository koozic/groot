-- ==========================================
-- 0. 기존 연습용 흔적 지우기 (초기화)
-- ==========================================
-- 내가 만든 테이블부터 지워야 부모(친구들) 테이블 지울 때 에러 안 남!
DROP TABLE review_likes CASCADE CONSTRAINTS;
DROP TABLE reviews CASCADE CONSTRAINTS;

-- 번호표 기계도 새로 시작하기 위해 삭제
DROP SEQUENCE reviews_seq;
DROP SEQUENCE review_likes_seq;


-- ==========================================
-- 1. 번호표 자동 발급 기계 (시퀀스) 생성
-- ==========================================
-- 리뷰 번호(r_no)용
CREATE SEQUENCE reviews_seq START WITH 1 INCREMENT BY 1;

-- 좋아요 번호(rl_no)용
CREATE SEQUENCE review_likes_seq START WITH 1 INCREMENT BY 1;


-- ==========================================
-- 2. 리뷰 본문 테이블 (reviews)
-- ==========================================
CREATE TABLE reviews (
                         review_id NUMBER PRIMARY KEY, -- r_no에서 이름 변경!
                         user_id varchar2(30 char),
                         product_id NUMBER(3) NOT NULL,
                         r_title VARCHAR2(100) NOT NULL,
                         r_content VARCHAR2(2000) NOT NULL,
                         r_img VARCHAR2(200),
                         r_score NUMBER(1) DEFAULT 5,
                         r_like NUMBER DEFAULT 0,
                         r_date DATE DEFAULT SYSDATE,

                         CONSTRAINT fk_r_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE SET NULL,
                         CONSTRAINT fk_r_product FOREIGN KEY(product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- ==========================================
-- 3. 좋아요 기록 테이블 (review_likes)
-- ==========================================
CREATE TABLE review_likes (
                              reviewlike_id NUMBER PRIMARY KEY, -- 언더바 넣어서 통일!
                              review_id  NUMBER NOT NULL,
                              user_id  varchar2(30 char) NULL,

                              CONSTRAINT rl_unique UNIQUE(review_id, user_id),

    -- [수정포인트] REFERENCES reviews(r_no)였던 걸 (review_id)로 변경!
                              CONSTRAINT fk_rl_review FOREIGN KEY(review_id) REFERENCES reviews(review_id) ON DELETE CASCADE,

                              CONSTRAINT fk_rl_user FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- ==========================================
-- 4. 실전 가데이터 넣기 (도혁/경용 데이터 활용)
-- ==========================================
-- 조원들이 넣은 데이터가 진짜 있는지 확인하고 실행해!
-- (만약 1번 유저나 101번 상품이 없으면 에러 나니까 걔네 데이터 번호로 바꿔줘)
INSERT INTO reviews (review_id, user_id, product_id, r_title, r_content, r_score)
VALUES (reviews_seq.NEXTVAL, 'kim123', 101, '합체 대성공!', '진짜 테이블에 연결하니 마음이 편안하네요.', 1);

INSERT INTO review_likes (reviewLike_id, review_id, user_id)
VALUES (review_likes_seq.NEXTVAL, 3, 'kim123');


-- ==========================================
-- 5. 데이터 확인 및 최종 저장
-- ==========================================
SELECT * FROM reviews;
SELECT * FROM review_likes;

-- ★★★ 이거 안 하면 조원들 컴퓨터에서 네 리뷰 안 보임! ★★★
COMMIT;