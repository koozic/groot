<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- =============================================
히어로 섹션 (알약 떠다니는 배너)
============================================= -->
<section class="hero-section">
    <div class="hero-text">
        <h1>내 몸에 맞는<br>영양제 조합은?</h1>
        <p>지금 먹는 영양제를 선택하면<br>부족한 영양소와 최적 복용법을 알려드려요</p>
        <a href="reco" class="btn btn-accent">지금 분석하기 →</a>
    </div>
    <div class="hero-pills" aria-hidden="true">
        <div class="pill p1"></div>
        <div class="pill p2"></div>
        <div class="pill p3"></div>
        <div class="pill p4"></div>
        <div class="pill p5"></div>
        <div class="pill p6"></div>
        <div class="pill p7"></div>
    </div>
</section>

<!-- =============================================
영양제 체크 (간단 분석기)
============================================= -->
<section style="margin-bottom: 36px;">
    <form action="reco" method="get">
    <div class="sec-header">
        <div class="sec-title">지금 먹는 영양제 체크하기</div>
    </div>
    <div class="checker-card card">
        <div class="checker-grid">
            <label class="check-item">
                <input type="checkbox" name="supp" value="vitC">
                <div class="check-inner">
                    <span class="check-icon">🍊</span>
                    <span class="check-name">비타민C</span>
                </div>
            </label>
            <label class="check-item">
                <input type="checkbox" name="supp" value="vitD">
                <div class="check-inner">
                    <span class="check-icon">☀️</span>
                    <span class="check-name">비타민D</span>
                </div>
            </label>
            <label class="check-item">
                <input type="checkbox" name="supp" value="omega3">
                <div class="check-inner">
                    <span class="check-icon">🐟</span>
                    <span class="check-name">오메가3</span>
                </div>
            </label>
            <label class="check-item">
                <input type="checkbox" name="supp" value="calcium">
                <div class="check-inner">
                    <span class="check-icon">🦴</span>
                    <span class="check-name">칼슘</span>
                </div>
            </label>
            <label class="check-item">
                <input type="checkbox" name="supp" value="magnesium">
                <div class="check-inner">
                    <span class="check-icon">🌿</span>
                    <span class="check-name">마그네슘</span>
                </div>
            </label>
            <label class="check-item">
                <input type="checkbox" name="supp" value="zinc">
                <div class="check-inner">
                    <span class="check-icon">⚡</span>
                    <span class="check-name">아연</span>
                </div>
            </label>
            <label class="check-item">
                <input type="checkbox" name="supp" value="iron">
                <div class="check-inner">
                    <span class="check-icon">💪</span>
                    <span class="check-name">철분</span>
                </div>
            </label>
            <label class="check-item">
                <input type="checkbox" name="supp" value="vitB">
                <div class="check-inner">
                    <span class="check-icon">🌾</span>
                    <span class="check-name">비타민B</span>
                </div>
            </label>
        </div>
        <button type="submit" class="btn btn-primary btn-full" style="margin-top: 16px; width: 100%; border: none;">
            선택한 영양제 분석하기 →
        </button>
    </div>
    </form>
</section>

<div class="grid-4">
    <%-- 🌟 컨트롤러가 넘겨준 무영표 베스트 리뷰 4개 반복문 시작! --%>
    <c:forEach var="best" items="${bestReviews}" varStatus="status">

        <%-- 🎨 배지 색상 로테이션 (파, 노, 초, 주 순서대로 돌려 입히기) --%>
        <c:set var="badgeColor" value="${status.index % 4 == 0 ? 'badge-blue' : (status.index % 4 == 1 ? 'badge-yellow' : (status.index % 4 == 2 ? 'badge-green' : 'badge-orange'))}" />

        <div class="card review-card" onclick="location.href='product-detail?id=${best.product_id}'" style="cursor: pointer;">

                <%-- 🚨 수정된 부분: 에러 안 나게 '베스트'로 텍스트 고정! --%>
            <span class="badge ${badgeColor}">베스트</span>

                <%-- 2. 리뷰 제목 --%>
            <div class="review-title">${best.r_title}</div>

                <%-- 3. 리뷰 내용 --%>
            <div class="review-body">${best.r_content}</div>

                <%-- 4. 별점 --%>
            <div class="review-stars">
                <c:forEach begin="1" end="${best.r_score}">★</c:forEach>
                <c:forEach begin="${best.r_score + 1}" end="5">☆</c:forEach>
            </div>

                <%-- 5. 작성자 --%>
            <div class="review-author">${best.user_id} &nbsp;|&nbsp; 👍 ${best.r_like}</div>

        </div>

    </c:forEach>
</div>

<!-- =============================================
home.jsp 전용 스타일
============================================= -->
