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
        <button href="recommend" class="btn btn-primary btn-full" type="submit" style="margin-top: 16px;">
            선택한 영양제 분석하기 →
        </button>
    </div>
    </form>
</section>

<!-- =============================================
베스트 리뷰
============================================= -->
<section style="margin-bottom: 36px;">
    <div class="sec-header">
        <div class="sec-title">베스트 리뷰</div>
        <a href="review" class="sec-more">전체보기 ›</a>
    </div>
    <div class="grid-4">
        <c:choose>
            <c:when test="${not empty reviewList}">
                <c:forEach var="review" items="${reviewList}">
                    <div class="card review-card">
                        <span class="badge badge-blue">${review.category}</span>
                        <div class="review-title">${review.title}</div>
                        <div class="review-body">${review.content}</div>
                        <div class="review-stars">
                            <c:forEach begin="1" end="${review.rating}" var="i">★</c:forEach>
                            <c:forEach begin="${review.rating + 1}" end="5" var="i">☆</c:forEach>
                        </div>
                        <div class="review-author">${review.author}</div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <%-- 더미 데이터 (DB 연결 전 확인용) --%>
                <div class="card review-card">
                    <span class="badge badge-blue">비타민C</span>
                    <div class="review-title">오메가3 + 마그네슘</div>
                    <div class="review-body">잠이 훨씬 잘 와요! 이 조합 강추합니다</div>
                    <div class="review-stars">★★★★★</div>
                    <div class="review-author">건강맨</div>
                </div>
                <div class="card review-card">
                    <span class="badge badge-yellow">비타민D</span>
                    <div class="review-title">비타민D + 칼슘</div>
                    <div class="review-body">뼈 건강에 확실히 효과 봤어요</div>
                    <div class="review-stars">★★★★☆</div>
                    <div class="review-author">뼈튼튼</div>
                </div>
                <div class="card review-card">
                    <span class="badge badge-green">종합비타민</span>
                    <div class="review-title">아연 + 비타민C</div>
                    <div class="review-body">환절기 면역력에 진짜 좋아요</div>
                    <div class="review-stars">★★★★★</div>
                    <div class="review-author">면역왕</div>
                </div>
                <div class="card review-card">
                    <span class="badge badge-orange">비타민B</span>
                    <div class="review-title">비타민B군 복합체</div>
                    <div class="review-body">피로회복이 눈에 띄게 달라짐</div>
                    <div class="review-stars">★★★★☆</div>
                    <div class="review-author">직장인A</div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

