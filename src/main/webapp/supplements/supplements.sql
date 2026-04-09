-- [1단계] 기존에 잘못 만들어진 흔적들 깔끔하게 지우기 (먼저 실행)
DROP TABLE supplements_like CASCADE CONSTRAINTS;
DROP TABLE supplements CASCADE CONSTRAINTS;
DROP SEQUENCE seq_supplements_id;
DROP SEQUENCE seq_supplements_like_id;

-- 영양성분 테이블
CREATE TABLE supplements (
    supplement_id NUMBER PRIMARY KEY,              -- 영양성분 고유번호 (PK)
    supplement_name VARCHAR2(255) NOT NULL,        -- 이름
    supplement_efficacy VARCHAR2(4000) NOT NULL,   -- 효능
    supplement_dosage VARCHAR2(255),               -- 1일 권장 복용량
    supplement_timing VARCHAR2(255),               -- 권장 복용 시간
    supplement_caution VARCHAR2(4000),             -- 주의사항
    supplement_image_path VARCHAR2(1000),           -- 이미지 경로
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

CREATE SEQUENCE seq_supplements_like_id START WITH 1 INCREMENT BY 1;

SELECT * FROM SUPPLEMENTS;
-- 진짜 데이터
-- 1. 비타민 A
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 A', '세포 성장 조절, 눈·피부 건강 유지 및 면역 체계 강화에 필수적임. 망막 색소 구성 성분으로 시력을 유지하며, 결핍 시 야맹증·안구건조증 등이 발생할 수 있음.', '약 5,000IU', '식후', '지용성으로 체내 축적이 쉬워 식후 섭취를 권장함. 과다 섭취 시 구역질, 두통, 간 손상 위험이 있으며 임산부는 복용 전 전문가 상담이 필수적임.', 'https://media.istockphoto.com/id/1388371433/ko/%EB%B2%A1%ED%84%B0/%EB%B9%84%ED%83%80%EB%AF%BC-a-%EA%B3%A8%EB%93%9C-%EB%B9%9B%EB%82%98%EB%8A%94-%EC%95%84%EC%9D%B4%EC%BD%98-%EC%95%84%EC%8A%A4%EC%BD%94%EB%A5%B4%EB%B8%8C-%EC%82%B0-%EB%B9%9B%EB%82%98%EB%8A%94-%ED%99%A9%EA%B8%88-%EB%AC%BC%EC%A7%88-%EB%93%9C%EB%A1%AD-%EC%98%81%EC%96%91-%EC%8A%A4%ED%82%A8-%EC%BC%80%EC%96%B4-%EB%B2%A1%ED%84%B0.jpg?s=612x612&w=0&k=20&c=P3g82tq9nwRt6HduCiSAdSLoieqJyuqxV9ypIXzk4Y0=');

-- 2. 비타민 B1(티아민)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
<<<<<<< HEAD
VALUES (seq_supplements_id.NEXTVAL, '비타민 B1(티아민)');
=======
VALUES (seq_supplements_id.NEXTVAL, '비타민 B1(티아민)', '탄수화물 에너지 전환을 돕고 피로 물질을 제거함. 신경 기능을 정상화하며, 부족 시 각기병·말초신경장애 등이 나타남.', '약 1.2mg', '식전', '수용성으로 식전 복용이 흡수에 유리하나, 고함량 복용 시 속 쓰림이 있다면 식후 30분에 복용함. 신진대사 증진으로 수면을 방해할 수 있어 이른 시간에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 3. 비타민 B2(리보플라빈)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 B2(리보플라빈)', '3대 영양소 대사의 조효소로 작용하며 소변을 노란색으로 변하게 함. 시각·점막·피부·손발톱 등의 세포 성장과 유지에 필수적임.', '약 1.3mg', '식전', '수용성으로 식전 복용이 흡수에 유리하나, 고함량 복용 시 속 쓰림이 있다면 식후 30분에 복용함. 신진대사 증진으로 수면을 방해할 수 있어 이른 시간에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 4. 비타민 B3(니아신/나이아신)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 B3(니아신/나이아신)', '생체 내 산화-환원 반응 및 세포 호흡, 지질 합성 등에 광범위하게 관여하여 생명 유지에 핵심적인 역할을 함.', '약 14~16mg', '식전', '수용성으로 식전 복용이 흡수에 유리하나, 고함량 복용 시 속 쓰림이 있다면 식후 30분에 복용함. 신진대사 증진으로 수면을 방해할 수 있어 이른 시간에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 5. 비타민 B5(판토텐산)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 B5(판토텐산)', '신경전달물질인 아세틸콜린 합성을 도움. 에너지 생성 및 콜라겐 합성에 필수적인 성분임.', '약 5mg', '식전', '수용성으로 식전 복용이 흡수에 유리하나, 고함량 복용 시 속 쓰림이 있다면 식후 30분에 복용함. 신진대사 증진으로 수면을 방해할 수 있어 이른 시간에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 6. 비타민 B6(피리독신)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 B6(피리독신)', '단백질 대사와 헤모글로빈 합성에 관여함. 심혈관 질환 위험 인자인 호모시스테인을 분해하는 역할을 함.', '약 1.3 ~ 1.7mg', '식전', '수용성으로 식전 복용이 흡수에 유리하나, 고함량 복용 시 속 쓰림이 있다면 식후 30분에 복용함. 신진대사 증진으로 수면을 방해할 수 있어 이른 시간에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 7. 비타민 B7(비오틴)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 B7(비오틴)', '모발·피부·손발톱 건강을 도움. 에너지 전환 및 인지 기능 유지, 혈당 조절을 통해 대사 질환 관리에 기여함.', '약 30mcg', '식전', '수용성으로 식전 복용이 흡수에 유리하나, 고함량 복용 시 속 쓰림이 있다면 식후 30분에 복용함. 신진대사 증진으로 수면을 방해할 수 있어 이른 시간에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 8. 비타민 B9(엽산)
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 B9(엽산)', 'DNA·아미노산 합성 및 태아의 신경 발달에 필수적임. 적혈구 생성에 관여하여 결핍 시 빈혈을 유발함.', '약 1.3mg', '식전', '수용성으로 식전 복용이 흡수에 유리하나, 고함량 복용 시 속 쓰림이 있다면 식후 30분에 복용함. 신진대사 증진으로 수면을 방해할 수 있어 이른 시간에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 9. 비타민 C
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 C', '강력한 항산화제로 활성산소로부터 조직을 보호함. 콜라겐 합성, 면역력 향상, 철분 흡수 촉진 작용을 함.', '약 100mg', '식후', '산성 성분으로 공복 섭취 시 위장 장애를 유발할 수 있어 식후 복용을 권장함. 체내 유지 시간이 짧아 하루 여러 번 나누어 복용하는 것이 효과적임.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 10. 비타민 D
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 D', '뼈 형성과 칼슘 항상성 유지에 필수적임. 장내 칼슘 흡수를 돕고 혈중 칼슘을 뼈에 침착시키는 역할을 함.', '약 600IU', '식후', '지용성 비타민으로 식후 복용이 권장됨. 칼슘제와 과다 병용 시 고칼슘혈증을 일으킬 수 있어 주의가 필요함.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 11. 비타민 E
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 E', '항산화 작용을 통해 세포막의 불포화지방산 산화를 억제하고 조직 손상을 방지함.', '약 12mg', '식후', '지용성으로 식후 또는 지방 성분이 포함된 음식과 함께 섭취 시 흡수율이 높아짐.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 12. 비타민 K
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '비타민 K', '혈액 응고 반응에 직접적으로 관여함.', '제한 없음', '식후', '음식에 있는 지방 성분과 먹어야 체내에 더 잘 흡수되며, 장기간 고용량을 섭취해도 독성이 없으므로 최대 섭취량의 제한은 없는 것으로 알려져 있음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 13. 아연
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '아연', '항산화 효소의 구성 성분으로 염증을 줄이고 황반변성 등 질환을 예방함. 전립선 건강 및 정자 생성·활동성 증가 등 남성 성 기능 강화에 효과적임.', '약 10mg', '식후', '공복 섭취 시 속 쓰림을 유발할 수 있어 식후 복용함. 칼슘과 함께 섭취하면 흡수율이 떨어지므로 주의해야 함.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 14. 마그네슘
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '마그네슘', '뼈와 치아를 구성하는 필수 미네랄로 350종 이상의 효소 반응에 관여함. 에너지 생성, 신경 안정, 혈당 조절 및 체내 생화학적 균형 유지에 핵심적인 역할을 함.', '약 350mg', '식후', '근육 이완과 숙면을 돕기 위해 저녁 복용을 권장함. 위산이 분비되어야 흡수가 잘 되므로 식후 30분 이내에 섭취하는 것이 좋음.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 15. 철분
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '철분', '적혈구 생성 및 체내 산소 운반을 담당함. 피로 회복을 돕고 빈혈로 인한 수면장애나 우울증 개선에 기여하며, 특히 여성의 편두통 완화에 효과적임.', '약 10~14mg', '식후', '커피나 녹차와 함께 섭취 시 흡수율이 떨어지므로 주의해야 함. 흡수 효율을 위해 저녁 식후에 복용하는 것을 권장함.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 16. 칼슘
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '칼슘', '뼈와 치아의 핵심 구성 요소이며 근육과 신경 기능을 조절함. 비타민 D와 함께 복용 시 흡수율을 높일 수 있음.', '약 700mg', '식후', '과잉 섭취 시 요로 결석 위험이 있음. 위장장애나 변비를 유발할 수 있으며, 마그네슘과 함께 복용하면 변비 부작용 완화에 도움이 됨.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');

-- 17. 코엔자임Q10
INSERT INTO supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution, supplement_image_path)
VALUES (seq_supplements_id.NEXTVAL, '코엔자임Q10', '세포 내 미토콘드리아에서 에너지 생성을 돕는 핵심 성분임. 혈압 조절, 심장 건강 증진 및 강력한 항산화 작용을 통해 노화를 억제하고 피로 회복을 도움.', '약 90~100mg', '식후', '지용성 성분이므로 공복 복용 시 흡수율이 떨어짐. 반드시 식후에 섭취해야 하며, 오메가3와 병용 시 흡수 효과가 더욱 높아짐.', 'https://weekly.chosun.com/news/photo/202305/26499_49726_360.gif');
>>>>>>> 1e28f0728626b7b237c7ee652659fbd7e33dfd8e

-- 데이터베이스에 영구 반영 (필수)
COMMIT;

SELECT * FROM SUPPLEMENTS;
