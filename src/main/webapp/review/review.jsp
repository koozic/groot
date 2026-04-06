<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Groot - 상품 리뷰</title>
    <link rel="stylesheet" href="../css/review.css">
</head>
<body>


<div class="review-container">
    <div class="review-header">
        <h2>💬 상품 리뷰</h2>
        <div class="star-stats-container">
            <div class="avg-score-box">
                <div class="avg-score">${avgScore}</div> <div class="avg-stars">★★★★★</div>
                <div class="total-review-count">구매후기 평점 ${reviews.size()}개 기준</div>
            </div>

            <div class="stat-rows">
                <c:forEach var="i" begin="1" end="5" step="1">
                    <c:set var="score" value="${6 - i}" />

                    <%-- 🌟 JSTL 숫자 버그 완벽 우회법: Map을 직접 뒤져서 일치하는 점수 찾기! --%>
                    <c:set var="count" value="0" /> <%-- 기본값은 0으로 세팅 --%>
                    <c:forEach var="entry" items="${starStats}">
                        <c:if test="${entry.key == score}">
                            <c:set var="count" value="${entry.value}" />
                        </c:if>
                    </c:forEach>

                    <%-- 🌟 퍼센트 계산 (소수점 날리고 깔끔하게) --%>
                    <c:set var="rawPercent" value="${totalCount > 0 ? (count * 100.0 / totalCount) : 0}" />
                    <fmt:formatNumber var="cleanPercent" value="${rawPercent}" pattern="0" />

                    <div class="stat-row">
                        <span style="color:#f1c40f">★</span>
                        <span style="width:15px;">${score}</span>
                        <div class="bar-bg" style="flex-grow:1; height:12px; background:#eee; border-radius:6px; margin:0 10px; overflow:hidden;">
                                <%-- 🌟 막대기 쫙! --%>
                            <div class="bar-fill" style="width: ${cleanPercent}%; height: 100%; background-color: #6a8d3a; border-radius: 6px;"></div>
                        </div>
                            <%-- 🌟 이제 14, 4, 2 같은 숫자가 무조건 찍힘! --%>
                        <span style="width:30px; text-align:right;">${count}</span>
                    </div>
                </c:forEach>
            </div>
        </div>
        <%-- 🌟 여기가 리뷰 작성 폼으로 넘어가는 버튼! (임시로 101번 상품으로 세팅) --%>
        <a href="review/review_write.jsp?product_id=101" class="btn-write">✍️ 리뷰 작성하기</a>
    </div>

    <%-- 1. DAO에서 가져온 리뷰 리스트 쫙 뿌리기 (DTO 소문자로 맞춘 거 적용됨!) --%>
    <c:forEach var="r" items="${reviews}">
        <div class="review-card">
            <div class="review-title">제목: ${r.r_title}</div>
            <div class="review-meta">
                작성자: ${r.user_id} | 별점: ${r.r_score}점 | 작성일: ${r.r_date}
            </div>

            <div style="text-align: right; margin-bottom: 10px;">
                <button type="button"
                        onclick="openDetailModal('${r.r_title}', '${r.user_id}', '${r.r_score}', '${r.r_date}', '${r.r_content}', '${r.r_img}')"
                        style="padding: 5px 12px; background: #34495e; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 0.85em;">
                    🔍 리뷰 상세보기
                </button>
            </div>
                <%-- 🌟 [사진 위치] 별점 밑, 구분선(hr) 위에 넣어야 예뻐! --%>
            <c:if test="${not empty r.r_img}">
                <div class="review-img-box" style="margin: 15px 0;">
                    <img src="../upload/${r.r_img}"
                         alt="리뷰이미지"
                         style="width: 150px; height: 150px; object-fit: cover; border-radius: 8px; border: 1px solid #eee; display: block;">
                </div>
            </c:if>
            <hr style="border: 0; border-top: 1px solid #eee;">
            <div class="review-content">
                    ${r.r_content}
            </div>

        </div>
    </c:forEach>


    <%-- 2. 등록된 리뷰가 한 개도 없을 때 --%>
    <c:if test="${empty reviews}">
        <div class="empty-msg">
            <p>아직 작성된 리뷰가 없습니다.</p>
            <p>99년생 무영이가 1등으로 리뷰를 남겨주세요! 👊</p>
        </div>
    </c:if>
    <div id="detailModal" onclick="closeDetailModal()" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.8); cursor:pointer;">
        <div onclick="event.stopPropagation()" style="background:#fff; width:600px; margin:50px auto; border-radius:15px; cursor:default; overflow: hidden;">

            <%-- 🌟 여기가 포인트! 만든 파일을 불러온다 --%>
            <jsp:include page="review_detail.jsp" />

        </div>
    </div>
</div>

<script>
    // 이 함수가 버튼의 onclick이랑 연결되는 거야!
    function openDetailModal(title, user, score, date, content, img) {
        // 1. 숨겨놨던 모달 틀을 보이게 한다
        document.getElementById('detailModal').style.display = 'block';

        // 2. 부품 파일(review_detail.jsp)에 있는 id값들에 데이터를 채운다
        document.getElementById('detail_title').innerText = title;
        document.getElementById('detail_user').innerText = user;
        document.getElementById('detail_score').innerText = score;
        document.getElementById('detail_date').innerText = date;
        document.getElementById('detail_text').innerText = content;

        // 3. 이미지 처리
        const imgBox = document.getElementById('detail_img_box');
        const imgTag = document.getElementById('detail_img');

        if(img && img !== 'null' && img !== '') {
            imgTag.src = '../upload/' + img;
            imgBox.style.display = 'block';
        } else {
            imgBox.style.display = 'none';
        }
    }

    function closeDetailModal() {
        document.getElementById('detailModal').style.display = 'none';
    }
</script>
</body>
</html>