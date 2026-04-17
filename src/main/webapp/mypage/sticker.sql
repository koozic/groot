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