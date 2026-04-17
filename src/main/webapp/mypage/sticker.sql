CREATE TABLE calendar_stickers
(
    sticker_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id      VARCHAR2(50) NOT NULL,
    sticker_type VARCHAR2(50) NOT NULL,
    cal_year     NUMBER       NOT NULL,
    cal_month    NUMBER       NOT NULL,
    cal_day      NUMBER       NOT NULL,
    pos_x        FLOAT        NOT NULL,
    pos_y        FLOAT        NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE calendar_stickers
    MODIFY sticker_type VARCHAR2(100);

-- 테이블 존재 확인
SELECT * FROM calendar_stickers WHERE ROWNUM <= 5;

-- 컬럼 구조 확인
DESC calendar_stickers;
SELECT * FROM calendar_stickers;