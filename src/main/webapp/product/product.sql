select *
from products;


drop table products;


CREATE TABLE products
(
    product_id          number(3) PRIMARY KEY,       --'제품 고유 번호'
    product_admin       VARCHAR2(50 char)  NOT NULL, -- '관리자 ID 정보'
    product_name        VARCHAR2(255 char) NOT NULL, -- '제품명'
    product_brand       VARCHAR2(100 char) NOT NULL, -- '제조사'
    product_price       number(5)          NOT NULL, -- '가격'
    product_nutrient    number(3)          NOT NULL, -- '영양소 식별자 (FK)'
    product_description varchar2(1000 char),         -- '제품 설명'
    product_image       VARCHAR2(255 char),          -- '제품 이미지 URL/경로'
    product_total       number(3),                   -- '1통당 총 알약 수'
    product_serve       number(2),                   -- '1회 섭취량'
    product_per_day     number(2),                      -- '1일 섭취 횟수'
    product_time_info   VARCHAR2(500),               -- '복용 시점 설명'
    product_date        DATE default sysdate,                        -- '복용 시작일'
    product_current     number(3),                   -- '현재 잔여량'

    -- 외래키 설정 (영양소 테이블 참조)
    CONSTRAINT fk_nutrient FOREIGN KEY (product_nutrient) REFERENCES supplements (supplement_id)

);
create sequence products_seq;

-- drop table calendar;
create table calendar
(
    user_id    varchar2(30 char) not null,
    product_id number(3),

    CONSTRAINT fk_calendar_user FOREIGN KEY (user_id) REFERENCES USERS (user_id),
    CONSTRAINT fk_calendar_product FOREIGN KEY (product_id) REFERENCES products (product_id)


);

-- drop table calender;
-- 1. 비타민 C (기본 영양제)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (products_seq.nextval, 'admin_kyy', '메가도스 비타민C 3000', '고려은단', 25000, 1, '영국산 비타민C 원료 사용', '/images/vitamin_c.jpg', 100, 1, 1,
        '식사 직후 또는 식사 중 복용', TO_DATE('2026-03-01', 'YYYY-MM-DD'), 85);

-- 2. 루테인 (눈 건강)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (102, 'admin_kyy', '아이케어 루테인 지아잔틴', '안국건강', 18500, 2, '황반 색소 밀도 유지를 위한 루테인', '/images/lutein.jpg', 60, 1, 1,
        '충분한 물과 함께 섭취', TO_DATE('2026-03-10', 'YYYY-MM-DD'), 45);

-- 3. 오메가3 (혈행 개선)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (103, 'admin_kyy', '초임계 알티지 오메가3', '종근당건강', 32000, 3, 'rTG형으로 흡수율이 높은 오메가3', '/images/omega3.jpg', 90, 1, 1,
        '식후 즉시 복용 권장', TO_DATE('2026-02-20', 'YYYY-MM-DD'), 20);

-- 4. 유산균 (장 건강)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (104, 'admin_kyy', '락토핏 생유산균 골드', '종근당건강', 15900, 4, '온 가족 맞춤형 생유산균', '/images/lactofit.jpg', 50, 1, 1,
        '기상 직후 공복에 섭취', TO_DATE('2026-03-15', 'YYYY-MM-DD'), 42);

-- 5. 밀크씨슬 (간 건강)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (105, 'admin_kyy', '간건강 밀크씨슬 로얄', 'GNM', 12000, 5, '실리마린 추출물 함유로 간 보호', '/images/milkthistle.jpg', 30, 1, 1,
        '하루 중 편한 시간에 복용', TO_DATE('2026-04-01', 'YYYY-MM-DD'), 28);

-- 6. 멀티비타민 (종합 건강)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (106, 'admin_kyy', '얼라이브 원스데일리 멀티비타민', '네이처스웨이', 28000, 6, '21가지 비타민과 미네랄 함유', '/images/multivitamin.jpg', 60, 1,
        1, '아침 식사 후 복용', TO_DATE('2026-03-05', 'YYYY-MM-DD'), 35);

-- 7. 단백질 보충제 (근력 운동)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (107, 'admin_kyy', '마이프로틴 웨이 프로틴', '마이프로틴', 45000, 7, '고품질 유청 단백질 분말', '/images/whey.jpg', 40, 1, 2,
        '운동 직후 또는 식간에 섭취', TO_DATE('2026-03-20', 'YYYY-MM-DD'), 30);

-- 8. 마그네슘 (신경 및 근육 건강)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (108, 'admin_kyy', '킬레이트 마그네슘 200mg', '블루보넷', 38000, 8, '흡수율이 높은 킬레이트 형태', '/images/magnesium.jpg', 120, 2, 1,
        '취침 1시간 전 복용 권장', TO_DATE('2026-03-25', 'YYYY-MM-DD'), 110);

-- 9. 코엔자임 Q10 (항산화)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (109, 'admin_kyy', '코큐텐 항산화 플러스', '세노비스', 22000, 9, '높은 혈압 감소 및 항산화 도움', '/images/coq10.jpg', 60, 1, 1,
        '점심 식사 직후 복용', TO_DATE('2026-04-02', 'YYYY-MM-DD'), 58);

-- 10. 비타민 D (뼈 건강)
INSERT INTO products (product_id, product_admin, product_name, product_brand, product_price, product_nutrient,
                      product_description, product_image, product_total, product_serve, product_per_day,
                      product_time_info, product_start_date, product_current)
VALUES (110, 'admin_kyy', '액상 비타민D3 2000IU', '닥터라인', 19000, 10, '흡수가 빠른 액상 타입 비타민D', '/images/vitamind.jpg', 30, 1, 1,
        '식사 중 혹은 식후 즉시', TO_DATE('2026-03-28', 'YYYY-MM-DD'), 25);


-- 캘린더 테이블 샘플 데이터
INSERT INTO calendar (user_id, product_id)
VALUES ('lee01', 101);

INSERT INTO calendar (user_id, product_id)
VALUES ('kim123', 101);

select *
from calendar;
