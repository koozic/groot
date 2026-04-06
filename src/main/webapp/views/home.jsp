<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- =============================================
히어로 섹션 (알약 떠다니는 배너)
============================================= -->
<section class="hero-section">
    <div class="hero-text">
        <h1>내 몸에 맞는<br>영양제 조합은?</h1>
        <p>지금 먹는 영양제를 선택하면<br>부족한 영양소와 최적 복용법을 알려드려요</p>
        <a href="recommend" class="btn btn-accent">지금 분석하기 →</a>
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
        <a href="recommend" class="btn btn-primary btn-full" style="margin-top: 16px;">
            선택한 영양제 분석하기 →
        </a>
    </div>
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

<!-- =============================================
home.jsp 전용 스타일
============================================= -->
<style>
    /* 히어로 */
    .hero-section {
        background: #1e3a6e;
        border-radius: 14px;
        padding: 44px 40px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 32px;
        overflow: hidden;
        position: relative;
    }
    .hero-text h1 {
        font-size: 30px;
        font-weight: 900;
        color: #fff;
        line-height: 1.35;
        margin-bottom: 12px;
    }
    .hero-text p {
        font-size: 15px;
        color: rgba(255,255,255,0.65);
        line-height: 1.7;
        margin-bottom: 22px;
    }
    .btn-accent {
        background: #f97316;
        color: #fff;
        font-size: 15px;
        font-weight: 700;
        padding: 13px 28px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        transition: background .2s, transform .15s;
    }
    .btn-accent:hover { background: #ea6c0a; transform: translateY(-2px); }

    /* 알약 애니메이션 */
    .hero-pills {
        position: relative;
        width: 220px;
        height: 160px;
        flex-shrink: 0;
    }
    .pill {
        position: absolute;
        border-radius: 50px;
        opacity: 0.88;
        animation: floatPill linear infinite;
    }
    .p1 { width:52px; height:22px; background:#60a5fa; top:10px;  left:20px;  transform:rotate(-20deg); animation-duration:4.2s; animation-delay:0s; }
    .p2 { width:24px; height:24px; border-radius:50%; background:#facc15; top:20px; left:130px; animation-duration:5.1s; animation-delay:.8s; }
    .p3 { width:44px; height:18px; background:#4ade80; top:60px;  left:60px;  transform:rotate(12deg); animation-duration:3.8s; animation-delay:.3s; }
    .p4 { width:20px; height:20px; border-radius:50%; background:#fb7185; top:80px; left:160px; animation-duration:4.6s; animation-delay:1.2s; }
    .p5 { width:58px; height:20px; background:#c084fc; top:110px; left:10px;  transform:rotate(-8deg); animation-duration:5.4s; animation-delay:.5s; }
    .p6 { width:30px; height:14px; background:#f97316; top:40px;  left:80px;  transform:rotate(25deg); animation-duration:4.0s; animation-delay:1.8s; }
    .p7 { width:18px; height:18px; border-radius:50%; background:#34d399; top:130px; left:120px; animation-duration:3.5s; animation-delay:.9s; }

    @keyframes floatPill {
        0%,100% { transform: translateY(0)   rotate(var(--r, 0deg)); }
        50%      { transform: translateY(-10px) rotate(var(--r, 0deg)); }
    }

    /* 영양제 체커 */
    .checker-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 10px;
    }
    .check-item { display: block; cursor: pointer; }
    .check-item input { display: none; }
    .check-inner {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 6px;
        padding: 14px 8px;
        border: 1.5px solid #e5e7eb;
        border-radius: 10px;
        transition: all .15s;
        background: #fff;
    }
    .check-item input:checked + .check-inner {
        border-color: #2563eb;
        background: #eff6ff;
    }
    .check-icon { font-size: 24px; line-height: 1; }
    .check-name { font-size: 12px; font-weight: 700; color: #444; }
    .check-item input:checked + .check-inner .check-name { color: #2563eb; }

    /* 리뷰 카드 */
    .review-card      { display: flex; flex-direction: column; gap: 6px; }
    .review-title     { font-size: 13px; font-weight: 700; color: #1a1a1a; }
    .review-body      { font-size: 12px; color: #6b7280; line-height: 1.5; flex: 1; }
    .review-stars     { font-size: 13px; color: #f97316; }
    .review-author    { font-size: 11px; color: #9ca3af; }

    /* 반응형 */
    @media (max-width: 1024px) {
        .hero-section  { padding: 32px 28px; }
        .hero-text h1  { font-size: 24px; }
        .hero-pills    { width: 160px; height: 130px; }
        .checker-grid  { grid-template-columns: repeat(4, 1fr); }
    }
    @media (max-width: 768px) {
        .hero-section  { flex-direction: column; padding: 28px 20px; gap: 24px; text-align: center; }
        .hero-pills    { width: 100%; height: 80px; }
        .hero-text h1  { font-size: 22px; }
        .checker-grid  { grid-template-columns: repeat(4, 1fr); gap: 8px; }
    }
    @media (max-width: 480px) {
        .checker-grid  { grid-template-columns: repeat(2, 1fr); }
    }
</style>
