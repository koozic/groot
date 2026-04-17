-- users 테이블의 모든 유저가 products 테이블의 모든 제품에 대해
-- user_id + product_id 조합별로 리뷰 1건씩 남기는 가데이터 시드 SQL
-- 이미지(r_img)는 추후 별도 업로드 예정이므로 NULL로 둡니다.
-- 같은 유저가 같은 제품에 이미 리뷰를 남겼다면 다시 넣지 않습니다.

-- 실행 전 예상 삽입 건수 확인용
SELECT COUNT(*) AS target_review_count
FROM users u
         CROSS JOIN products p
WHERE NOT EXISTS (
    SELECT 1
    FROM reviews r
    WHERE r.user_id = u.user_id
      AND r.product_id = p.product_id
);

INSERT INTO reviews (
    review_id,
    user_id,
    product_id,
    r_title,
    r_content,
    r_img,
    r_score,
    r_date
)
SELECT
    reviews_seq.NEXTVAL,
    seed.user_id,
    seed.product_id,
    seed.r_title,
    seed.r_content,
    NULL AS r_img,
    seed.r_score,
    seed.r_date
FROM (
         SELECT
             base.user_id,
             base.product_id,
             CASE MOD(base.seed_no, 12)
                 WHEN 0 THEN '만족한 '
                 WHEN 1 THEN '무난한 '
                 WHEN 2 THEN '재구매한 '
                 WHEN 3 THEN '추천하는 '
                 WHEN 4 THEN '가볍게 먹는 '
                 WHEN 5 THEN '루틴용 '
                 WHEN 6 THEN '매일 먹는 '
                 WHEN 7 THEN '입문용 '
                 WHEN 8 THEN '꾸준히 먹은 '
                 WHEN 9 THEN '기본템 '
                 WHEN 10 THEN '생각보다 좋은 '
                 ELSE '정착한 '
                 END
                 || SUBSTR(base.product_name, 1, 14)
                 || CASE MOD(base.product_id, 6)
                        WHEN 0 THEN ' 후기'
                        WHEN 1 THEN ' 리뷰'
                        WHEN 2 THEN ' 체감'
                        WHEN 3 THEN ' 기록'
                        WHEN 4 THEN ' 메모'
                        ELSE ' 정리'
                 END AS r_title,
             SUBSTR(
                     CASE MOD(base.seed_no, 14)
                         WHEN 0 THEN '처음에는 큰 기대 없이 시작했는데 '
                         WHEN 1 THEN '며칠 가볍게 챙겨 보니 '
                         WHEN 2 THEN '다른 제품과 번갈아 먹다가 '
                         WHEN 3 THEN '바쁜 날에도 놓치지 않고 챙기다 보니 '
                         WHEN 4 THEN '공복보다는 식후에 맞춰 먹었더니 '
                         WHEN 5 THEN '한 통 가까이 먹어 보면서 느낀 건 '
                         WHEN 6 THEN '가족이 같이 먹는 제품 찾다가 '
                         WHEN 7 THEN '성분표 먼저 보고 선택했는데 '
                         WHEN 8 THEN '가격대가 부담스럽지 않아서 시작했고 '
                         WHEN 9 THEN '매일 같은 시간에 먹으려고 하다 보니 '
                         WHEN 10 THEN '기존에 먹던 제품과 비교하면 '
                         WHEN 11 THEN '기대했던 포인트가 분명한 제품이었고 '
                         WHEN 12 THEN '일단 냄새나 목 넘김부터 체크했는데 '
                         ELSE '처음 주문할 때는 무난한 기본템을 찾고 있었는데 '
                         END
                         || base.product_brand || '의 ' || base.product_name || '은 '
                         || CASE MOD(base.product_id + base.seed_no, 12)
                                WHEN 0 THEN '알 크기와 섭취 루틴이 생각보다 무난한 편입니다.'
                                WHEN 1 THEN '맛이나 향이 튀지 않아서 손이 자주 갑니다.'
                                WHEN 2 THEN '하루 한 번 챙기기 편한 점이 가장 마음에 들었습니다.'
                                WHEN 3 THEN '과하게 자극적이지 않아 꾸준히 먹기 편했습니다.'
                                WHEN 4 THEN '패키지가 단순해서 보관하고 꺼내 먹기 편합니다.'
                                WHEN 5 THEN '가격 대비 구성이 나쁘지 않다고 느꼈습니다.'
                                WHEN 6 THEN '일정하게 챙겨 먹기 좋은 타입이라 루틴 잡기가 쉬웠습니다.'
                                WHEN 7 THEN '개인적으로는 성분 대비 밸런스가 괜찮았습니다.'
                                WHEN 8 THEN '비슷한 제품들 사이에서 무난하게 선택할 만했습니다.'
                                WHEN 9 THEN '첫인상보다 실제 복용 편의성이 더 좋았습니다.'
                                WHEN 10 THEN '과장된 느낌 없이 기본기에 충실한 쪽에 가깝습니다.'
                                ELSE '꾸준히 먹을수록 장점이 보이는 제품이라는 인상이었습니다.'
                         END
                         || ' '
                         || CASE MOD(base.seed_no + LENGTH(base.user_id), 10)
                                WHEN 0 THEN '특히 출근 전에 챙겨도 부담이 적었습니다.'
                                WHEN 1 THEN '특히 물만 있으면 바로 먹기 편한 점이 좋았습니다.'
                                WHEN 2 THEN '특히 냄새 때문에 거슬리는 구간이 거의 없었습니다.'
                                WHEN 3 THEN '특히 복용 시간을 정해 두면 빠뜨릴 일이 적었습니다.'
                                WHEN 4 THEN '특히 다른 영양제와 같이 먹어도 루틴이 꼬이지 않았습니다.'
                                WHEN 5 THEN '특히 알약 크기나 제형 때문에 망설일 정도는 아니었습니다.'
                                WHEN 6 THEN '특히 가족이 같이 써도 무난하겠다는 생각이 들었습니다.'
                                WHEN 7 THEN '특히 재구매 여부를 고민할 정도로 완성도는 괜찮았습니다.'
                                WHEN 8 THEN '특히 휴대하기 편해서 외출할 때도 챙기기 좋았습니다.'
                                ELSE '특히 기대한 기본 역할에는 충분히 맞는 편이었습니다.'
                         END
                         || ' '
                         || CASE MOD(base.seed_no + LENGTH(base.product_name), 8)
                                WHEN 0 THEN '아주 강한 변화보다는 꾸준히 먹을 때 만족감이 올라가는 타입입니다.'
                                WHEN 1 THEN '단기간 체감보다도 루틴 유지용으로는 꽤 괜찮았습니다.'
                                WHEN 2 THEN '취향 차이는 있겠지만 기본 제품으로 두기에는 무난합니다.'
                                WHEN 3 THEN '크게 튀지는 않지만 전체적인 사용감은 안정적이었습니다.'
                                WHEN 4 THEN '다음에도 비슷한 조건이면 다시 고를 가능성이 있습니다.'
                                WHEN 5 THEN '한 번에 확 좋아진다기보다 누적 만족도가 쌓이는 느낌입니다.'
                                WHEN 6 THEN '과한 기대만 없으면 실망할 가능성은 크지 않은 제품입니다.'
                                ELSE '처음 입문용으로도 부담이 적은 쪽이라고 느꼈습니다.'
                         END,
                     1,
                     2000
             ) AS r_content,
             CASE MOD(base.seed_no + base.product_id, 10)
                 WHEN 0 THEN 1
                 WHEN 1 THEN 2
                 WHEN 2 THEN 3
                 WHEN 3 THEN 3
                 WHEN 4 THEN 4
                 WHEN 5 THEN 4
                 WHEN 6 THEN 5
                 WHEN 7 THEN 5
                 WHEN 8 THEN 4
                 ELSE 5
                 END AS r_score,
             TRUNC(SYSDATE) - MOD((base.seed_no * 5) + base.product_id, 120) AS r_date
         FROM (
                 SELECT
                      u.user_id,
                      p.product_id,
                      p.product_name,
                      p.product_brand,
                      ROW_NUMBER() OVER (ORDER BY p.product_id, u.user_id) AS seed_no
                  FROM users u
                           CROSS JOIN products p
              ) base
     ) seed
WHERE NOT EXISTS (
    SELECT 1
    FROM reviews r
    WHERE r.user_id = seed.user_id
      AND r.product_id = seed.product_id
);

COMMIT;

-- 확인용
SELECT product_id, COUNT(*) AS review_count
FROM reviews
GROUP BY product_id
ORDER BY product_id;
