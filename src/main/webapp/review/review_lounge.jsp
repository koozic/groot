<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- 🌟 방금 만든 CSS 파일 연결! (위치는 보통 태그들 맨 위에 둡니다) --%>
<link rel="stylesheet" href="../css/review_lounge.css">

<%-- 🌟 여기부터 딱 알맹이(content)만 시작! --%>
<div class="lounge-wrap">
    <div class="lounge-header">
        <h1>🏆 약쟁이 명예의 전당</h1>
        <p>유저들이 인정한 가장 도움되는 찐 후기들을 모아봤어요!</p>
    </div>

    <div class="category-pills">
        <button class="pill-btn active" data-category="all">✨ 전체보기</button>
        <button class="pill-btn" data-category="vitC">🍊 비타민C</button>
        <button class="pill-btn" data-category="omega3">🐟 오메가3</button>
        <button class="pill-btn" data-category="lactic">🦠 유산균</button>
        <button class="pill-btn" data-category="magnesium">🌿 마그네슘</button>
        <button class="pill-btn" style="border-style: dashed;">📸 포토리뷰만 보기</button>
    </div>

    <div class="lounge-grid">
        <c:forEach var="best" items="${bestReviews}">
            <div class="lounge-card">

                <div class="card-prod-info" onclick="location.href='product-detail?id=${best.product_id}'">
                    <img src="${not empty best.p_img ? best.p_img : '../images/default.jpg'}">
                    <div class="prod-name">${not empty best.p_name ? best.p_name : '제품명 없음'}</div>
                </div>

                <div class="card-body">
                    <div class="review-stars">
                        <c:forEach begin="1" end="${best.r_score}">★</c:forEach><c:forEach begin="${best.r_score + 1}" end="5" step="1"><span style="color:#ddd;">★</span></c:forEach>
                    </div>

                    <div class="review-title">${best.r_title}</div>

                    <c:if test="${not empty best.r_img and best.r_img ne 'null'}">
                        <div class="review-img-box">
                            <c:choose>
                                <c:when test="${fn:startsWith(best.r_img, 'http')}">
                                    <img src="${best.r_img}" alt="리뷰사진">
                                </c:when>
                                <c:otherwise>
                                    <img src="../upload/${best.r_img}" alt="리뷰사진">
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>

                    <div class="review-content">${best.r_content}</div>
                </div>

                <div class="card-footer">
                    <div class="author">${fn:substring(best.user_id, 0, 3)}***</div>
                    <button class="like-btn">👍 ${best.r_like}</button>
                </div>

            </div>
        </c:forEach>
    </div>
</div>