<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Groot - 리뷰 작성하기</title>
    <%-- 💡 경로 확인! 만약 안 나오면 ../ 빼고 css/review.css 로도 해봐 --%>
    <link rel="stylesheet" href="../css/review.css">
</head>
<body>

<div class="write-box">
    <h2>✍️ 솔직한 리뷰를 작성해주세요!</h2>
    <hr>

    <form action="../review-write" method="post" enctype="multipart/form-data">
        <%-- 🌟 주소창에 있는 번호(?product_id=105)를 그대로 훔쳐오는 마법의 코드! --%>
        <input type="hidden" name="product_id" value="${param.product_id}">

        <div class="form-group">
            <label>리뷰 제목</label>
            <input type="text" name="r_title" required placeholder="핵심만 짧게 적어주세요!">
        </div>

        <div class="form-group">
            <label>별점 선택 (1~5점)</label>
            <div class="star-rating" id="star-container">
                <span class="star" data-value="1">★</span>
                <span class="star" data-value="2">★</span>
                <span class="star" data-value="3">★</span>
                <span class="star" data-value="4">★</span>
                <span class="star" data-value="5">★</span>
            </div>
            <input type="hidden" name="r_score" id="r_score" value="5">
        </div> <div class="form-group">
        <label>리뷰 내용</label>
        <textarea name="r_content" rows="6" required placeholder="상품을 사용해 본 솔직한 후기를 남겨주세요."></textarea>
    </div>

        <div class="form-group">
            <label>사진 첨부 (선택)</label>
            <input type="file" name="r_img" accept="image/*">
        </div>

        <button type="submit" class="btn-submit">🚀 리뷰 등록하기</button>
    </form>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const stars = document.querySelectorAll('.star');
        const scoreInput = document.getElementById('r_score');

        stars.forEach(star => {
            star.addEventListener('mouseover', function() {
                fillStars(this.getAttribute('data-value'));
            });
            star.addEventListener('mouseout', function() {
                fillStars(scoreInput.value);
            });
            star.addEventListener('click', function() {
                scoreInput.value = this.getAttribute('data-value');
                fillStars(scoreInput.value);
            });
        });

        function fillStars(value) {
            stars.forEach(s => {
                if (parseInt(s.getAttribute('data-value')) <= parseInt(value)) {
                    s.classList.add('on');
                } else {
                    s.classList.remove('on');
                }
            });
        }
        fillStars(5); // 초기값 세팅
    });
</script>
</body>
</html>