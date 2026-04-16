-- 추천 조합 테이블
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE supplement_bad_pair CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE supplement_good_pair CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_supplement_bad_pair_id';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_supplement_good_pair_id';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE supplement_good_pair (
    good_pair_id NUMBER PRIMARY KEY,
    supplement_id_1 NUMBER NOT NULL,
    supplement_id_2 NUMBER NOT NULL,
    reason VARCHAR2(1000) NOT NULL,
    CONSTRAINT fk_good_pair_supp_1 FOREIGN KEY (supplement_id_1)
        REFERENCES supplements(supplement_id),
    CONSTRAINT fk_good_pair_supp_2 FOREIGN KEY (supplement_id_2)
        REFERENCES supplements(supplement_id),
    CONSTRAINT uq_good_pair UNIQUE (supplement_id_1, supplement_id_2),
    CONSTRAINT ck_good_pair_order CHECK (supplement_id_1 < supplement_id_2)
);

CREATE TABLE supplement_bad_pair (
    bad_pair_id NUMBER PRIMARY KEY,
    supplement_id_1 NUMBER NOT NULL,
    supplement_id_2 NUMBER NOT NULL,
    reason VARCHAR2(1000) NOT NULL,
    interval_hours NUMBER DEFAULT 0,
    CONSTRAINT fk_bad_pair_supp_1 FOREIGN KEY (supplement_id_1)
        REFERENCES supplements(supplement_id),
    CONSTRAINT fk_bad_pair_supp_2 FOREIGN KEY (supplement_id_2)
        REFERENCES supplements(supplement_id),
    CONSTRAINT uq_bad_pair UNIQUE (supplement_id_1, supplement_id_2),
    CONSTRAINT ck_bad_pair_order CHECK (supplement_id_1 < supplement_id_2)
);

CREATE SEQUENCE seq_supplement_good_pair_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_supplement_bad_pair_id START WITH 1 INCREMENT BY 1;

-- 대표 시너지 조합 시드 데이터
-- 아래 일부는 직접 흡수 상승 조합이고, 일부는 같은 건강 목적에서 함께 고려되는 추천 조합입니다.
INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '비타민 C가 철분 흡수를 도와 함께 먹으면 시너지 효과가 좋아요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '비타민 C' AND b.supplement_name = '철분';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '비타민 D가 칼슘 흡수를 도와 뼈 건강 관리에 도움이 돼요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '비타민 D' AND b.supplement_name = '칼슘';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '비타민 K는 뼈 대사에 관여해 칼슘과 함께 관리하는 조합으로 자주 고려돼요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '비타민 K' AND b.supplement_name = '칼슘';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '비타민 D와 비타민 K는 뼈 건강 루틴에서 함께 고려되는 대표 조합이에요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '비타민 D' AND b.supplement_name = '비타민 K';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '마그네슘은 활성형 비타민 D 조절에 관여해 함께 챙기면 균형 관리에 도움이 돼요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '마그네슘' AND b.supplement_name = '비타민 D';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '오메가3와 비타민 E를 함께 챙기면 산화 방지에 도움이 돼요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '오메가3' AND b.supplement_name = '비타민 E';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '칼슘과 마그네슘을 함께 챙기면 근육과 뼈 컨디션 관리에 도움이 돼요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '칼슘' AND b.supplement_name = '마그네슘';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '철분과 엽산은 적혈구 생성 관리에서 함께 고려되는 조합이에요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '철분' AND b.supplement_name = '비타민 B9(엽산)';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '비타민 B6는 헤모글로빈 형성에 관여해 철분과 함께 챙기는 경우가 많아요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '비타민 B6(피리독신)' AND b.supplement_name = '철분';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '코엔자임Q10은 오메가3와 함께 챙기면 흡수 루틴을 구성하기 좋아요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '코엔자임Q10' AND b.supplement_name = '오메가3';

INSERT INTO supplement_good_pair (good_pair_id, supplement_id_1, supplement_id_2, reason)
SELECT seq_supplement_good_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '프로바이오틱스와 프리바이오틱스를 같이 챙기면 장내 환경 관리에 좋아요.'
FROM supplements a, supplements b
WHERE a.supplement_name = '프로바이오틱스' AND b.supplement_name = '프리바이오틱스';

-- 함께 섭취 시 주의할 조합 시드 데이터
INSERT INTO supplement_bad_pair (bad_pair_id, supplement_id_1, supplement_id_2, reason, interval_hours)
SELECT seq_supplement_bad_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '칼슘과 철분은 서로 흡수를 방해할 수 있어요.',
       2
FROM supplements a, supplements b
WHERE a.supplement_name = '칼슘' AND b.supplement_name = '철분';

INSERT INTO supplement_bad_pair (bad_pair_id, supplement_id_1, supplement_id_2, reason, interval_hours)
SELECT seq_supplement_bad_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '아연과 철분은 흡수 경쟁이 생길 수 있어요.',
       2
FROM supplements a, supplements b
WHERE a.supplement_name = '아연' AND b.supplement_name = '철분';

INSERT INTO supplement_bad_pair (bad_pair_id, supplement_id_1, supplement_id_2, reason, interval_hours)
SELECT seq_supplement_bad_pair_id.NEXTVAL,
       LEAST(a.supplement_id, b.supplement_id),
       GREATEST(a.supplement_id, b.supplement_id),
       '아연과 칼슘은 함께 먹으면 아연 흡수율이 떨어질 수 있어요.',
       2
FROM supplements a, supplements b
WHERE a.supplement_name = '아연' AND b.supplement_name = '칼슘';

COMMIT;
