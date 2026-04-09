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

<section style="margin-bottom: 36px; margin-top: 40px;">
<div class="sec-header">
    <div class="sec-title">🏆 지금 가장 핫한 베스트 리뷰</div>
    <a href="review" class="sec-more">전체보기 ›</a>
</div>

<div class="grid-4">
    <c:choose>
        <%-- 데이터가 있을 때 --%>
        <c:when test="${not empty bestReviews}">
            <c:forEach var="best" items="${bestReviews}" varStatus="status">

                <c:set var="badgeColor" value="${status.index % 4 == 0 ? 'badge-blue' : (status.index % 4 == 1 ? 'badge-yellow' : (status.index % 4 == 2 ? 'badge-green' : 'badge-orange'))}" />

                <div class="card review-card" onclick="location.href='product-detail?id=${best.product_id}'" style="cursor: pointer; padding: 20px;">

                        <%-- 1. 상단: 은사님의 영양성분 태그 + 평균 평점 --%>
                    <div style="display: flex; justify-content: space-between; margin-bottom: 15px;">
                        <span class="badge ${badgeColor}">${not empty best.supp_name ? best.supp_name : '종합영양제'}</span>
                        <span style="font-size: 12px; font-weight: bold; color: #555;">⭐ 상품평점: ${best.p_avg_score}</span>
                    </div>

                        <%-- 2. 제품 정보 영역 (사진 + 이름) --%>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px dashed #eee;">
                        <img src="${not empty best.p_img ? best.p_img : '../images/default.jpg'}" alt="제품사진" style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px;">
                        <div style="font-weight: bold; font-size: 14px; color: #333;">${not empty best.p_name ? best.p_name : '제품명 없음'}</div>
                    </div>

                        <%-- 3. 리뷰 제목 및 내용 (2줄 요약 처리) --%>
                    <div class="review-title" style="margin-bottom: 5px;">${best.r_title}</div>
                    <div class="review-body" style="overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; margin-bottom: 10px;">
                            ${best.r_content}
                    </div>

                        <%-- 4. 리뷰 별점 --%>
                    <div class="review-stars" style="margin-bottom: 10px;">
                        <c:forEach begin="1" end="${best.r_score}">★</c:forEach>
                        <c:forEach begin="${best.r_score + 1}" end="5">☆</c:forEach>
                    </div>

                        <%-- 5. 하단: 작성자 및 좋아요 --%>
                    <div class="review-author" style="display: flex; justify-content: space-between; align-items: center;">
                        <span>${best.user_id}</span>
                        <span style="font-weight: bold; font-size: 11px;">👍 ${best.r_like}</span>
                    </div>
                </div>
            </c:forEach>
        </c:when>

        <%-- 데이터가 없을 때 (무영님 확인용) --%>
        <c:otherwise>
            <div style="grid-column: span 4; text-align: center; padding: 40px; color: #777; background: #f8f9fa; border-radius: 12px;">
                앗! DB에서 데이터를 못 가져왔습니다. 서버 로그를 확인해주세요!
            </div>
        </c:otherwise>
    </c:choose>
</div>
</section>