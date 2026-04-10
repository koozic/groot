CREATE TABLE favorite_products
(
    favorite_id NUMBER(20) PRIMARY KEY,     -- 관심제품 레코드 고유번호
    user_id     varchar2(30 char) NULL,     -- 유저 FK
    product_id  NUMBER(3)         NOT NULL, -- 상품 FK

    CONSTRAINT uq_favorite_user_product
        UNIQUE (user_id, product_id),       -- 같은 유저가 같은 상품 중복 찜 방지

    CONSTRAINT fk_favorite_user
        FOREIGN KEY (user_id)
            REFERENCES users (user_id)
                ON DELETE CASCADE,

    CONSTRAINT fk_favorite_product
        FOREIGN KEY (product_id)
            REFERENCES products (product_id)
                ON DELETE CASCADE
);

create sequence favorite_products_seq

-- 시퀀스를 사용하여 10개의 가데이터 입력
-- 상황: 유저 4명(user01~04)이 서로 다른 다양한 제품(1~10번)을 찜한 시나리오

INSERT INTO favorite_products (favorite_id, user_id, product_id)
VALUES (favorite_products_seq.NEXTVAL, 'kim123', 101);

INSERT INTO favorite_products (favorite_id, user_id, product_id)
VALUES (favorite_products_seq.NEXTVAL, 'lee01', 102);

INSERT INTO favorite_products (favorite_id, user_id, product_id)
VALUES (favorite_products_seq.NEXTVAL, 'park02', 103);

INSERT INTO favorite_products (favorite_id, user_id, product_id)
VALUES (favorite_products_seq.NEXTVAL, 'choi03', 104);

INSERT INTO favorite_products (favorite_id, user_id, product_id)
VALUES (favorite_products_seq.NEXTVAL, 'jung04',105);
