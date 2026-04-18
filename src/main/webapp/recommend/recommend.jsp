<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- recommend 페이지 body 패딩 제거 --%>
<style>
    .site-body {
        padding-bottom: 0 !important;

    }
</style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/recommend_benr.css">

<div class="recommend-scene">

    <div class="star" style="width:2px;height:2px;top:8%;left:12%;--d:2.8s;--delay:0s;--op:0.7;"></div>
    <div class="star" style="width:1.5px;height:1.5px;top:15%;left:80%;--d:3.5s;--delay:0.4s;--op:0.5;"></div>
    <div class="star" style="width:2px;height:2px;top:6%;left:55%;--d:4s;--delay:1s;--op:0.6;"></div>
    <div class="star" style="width:1px;height:1px;top:22%;left:35%;--d:2.5s;--delay:0.8s;--op:0.8;"></div>

    <p class="recommend-label">choose your path</p>
    <p class="recommend-heading">어떤 추천이 필요하신가요?</p>

    <div class="recommend-row">

        <%-- 카드 1: 신체별 추천 --%>
        <div class="recommend-card" id="card1" onclick="flipCard('card1', event)">
            <div class="recommend-card-inner">

                <%-- 뒷면 --%>
                <div class="card-face card-back">
                    <div class="card-bg card-bg-1"></div>

                    <svg class="card-border-svg" viewBox="0 0 190 310" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <rect x="8" y="8" width="174" height="294" rx="12" stroke="rgba(200,150,230,0.45)"
                              stroke-width="1.2"/>
                        <rect x="14" y="14" width="162" height="282" rx="10" stroke="rgba(210,170,240,0.3)"
                              stroke-width="0.7"/>
                        <path d="M8 40 Q20 20 40 8" stroke="rgba(220,180,255,0.5)" stroke-width="1.2" fill="none"/>
                        <path d="M150 8 Q170 20 182 40" stroke="rgba(220,180,255,0.5)" stroke-width="1.2" fill="none"/>
                        <path d="M8 270 Q20 290 40 302" stroke="rgba(220,180,255,0.5)" stroke-width="1.2" fill="none"/>
                        <path d="M150 302 Q170 290 182 270" stroke="rgba(220,180,255,0.5)" stroke-width="1.2"
                              fill="none"/>
                        <circle cx="95" cy="8" r="4" fill="rgba(220,180,255,0.5)"/>
                        <circle cx="95" cy="302" r="4" fill="rgba(220,180,255,0.5)"/>
                        <circle cx="8" cy="155" r="3" fill="rgba(220,180,255,0.4)"/>
                        <circle cx="182" cy="155" r="3" fill="rgba(220,180,255,0.4)"/>
                        <path d="M75 8 Q80 14 85 8 Q90 2 95 8 Q100 14 105 8 Q110 2 115 8"
                              stroke="rgba(200,160,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M75 302 Q80 296 85 302 Q90 308 95 302 Q100 296 105 302 Q110 308 115 302"
                              stroke="rgba(200,160,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M8 130 Q2 135 8 140 Q14 145 8 150 Q2 155 8 160 Q14 165 8 170 Q2 175 8 180"
                              stroke="rgba(200,160,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M182 130 Q188 135 182 140 Q176 145 182 150 Q188 155 182 160 Q176 165 182 170 Q188 175 182 180"
                              stroke="rgba(200,160,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M60 280 Q70 275 80 280 L95 272 L110 280 Q120 275 130 280"
                              stroke="rgba(200,160,230,0.3)" stroke-width="0.8" fill="none"/>
                        <path d="M60 30 Q70 35 80 30 L95 38 L110 30 Q120 35 130 30" stroke="rgba(200,160,230,0.3)"
                              stroke-width="0.8" fill="none"/>
                    </svg>

                    <div class="shimmer-bar"></div>

                    <div class="card-content">
                        <img src="${pageContext.request.contextPath}/img/ottos/real_search.png"
                             alt="신체별 추천"
                             style="width:360px;height:360px;object-fit:contain;margin-bottom:3px; margin-top: -33px;">
                        <p class="card-title">신체별 추천</p>
                        <div class="card-divider"></div>
                        <p class="card-subtitle">눈, 간, 피부 등 아픈 부위에<br>딱 맞는 영양소를 찾아보세요.</p>
                        <span class="card-tag">Body Care</span>
                    </div>
                </div>

                <%-- 앞면: 클릭 후 보이는 타로카드 이미지 --%>
                <div class="card-face card-front">
                    <img src="${pageContext.request.contextPath}/img/ottos/body_otto_taro.png"
                         alt="신체별 추천 타로카드">
                </div>

            </div>
        </div>

        <%-- 카드 2: AI 테마 추천 --%>
        <div class="recommend-card" id="card2" onclick="flipCard('card2', event)">
            <div class="recommend-card-inner">

                <%-- 뒷면 --%>
                <div class="card-face card-back">
                    <div class="card-bg card-bg-2"></div>

                    <svg class="card-border-svg" viewBox="0 0 190 310" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <rect x="8" y="8" width="174" height="294" rx="12" stroke="rgba(150,180,230,0.45)"
                              stroke-width="1.2"/>
                        <rect x="14" y="14" width="162" height="282" rx="10" stroke="rgba(170,200,240,0.3)"
                              stroke-width="0.7"/>
                        <path d="M8 40 Q20 20 40 8" stroke="rgba(180,210,255,0.5)" stroke-width="1.2" fill="none"/>
                        <path d="M150 8 Q170 20 182 40" stroke="rgba(180,210,255,0.5)" stroke-width="1.2" fill="none"/>
                        <path d="M8 270 Q20 290 40 302" stroke="rgba(180,210,255,0.5)" stroke-width="1.2" fill="none"/>
                        <path d="M150 302 Q170 290 182 270" stroke="rgba(180,210,255,0.5)" stroke-width="1.2"
                              fill="none"/>
                        <circle cx="95" cy="8" r="4" fill="rgba(180,210,255,0.5)"/>
                        <circle cx="95" cy="302" r="4" fill="rgba(180,210,255,0.5)"/>
                        <circle cx="8" cy="155" r="3" fill="rgba(180,210,255,0.4)"/>
                        <circle cx="182" cy="155" r="3" fill="rgba(180,210,255,0.4)"/>
                        <path d="M75 8 Q80 14 85 8 Q90 2 95 8 Q100 14 105 8 Q110 2 115 8"
                              stroke="rgba(160,195,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M75 302 Q80 296 85 302 Q90 308 95 302 Q100 296 105 302 Q110 308 115 302"
                              stroke="rgba(160,195,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M8 130 Q2 135 8 140 Q14 145 8 150 Q2 155 8 160 Q14 165 8 170 Q2 175 8 180"
                              stroke="rgba(160,195,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M182 130 Q188 135 182 140 Q176 145 182 150 Q188 155 182 160 Q176 165 182 170 Q188 175 182 180"
                              stroke="rgba(160,195,240,0.35)" stroke-width="0.8" fill="none"/>
                        <path d="M60 280 Q70 275 80 280 L95 272 L110 280 Q120 275 130 280"
                              stroke="rgba(160,185,230,0.3)" stroke-width="0.8" fill="none"/>
                        <path d="M60 30 Q70 35 80 30 L95 38 L110 30 Q120 35 130 30" stroke="rgba(160,185,230,0.3)"
                              stroke-width="0.8" fill="none"/>
                    </svg>

                    <div class="shimmer-bar"></div>

                    <div class="card-content">
                        <img src="${pageContext.request.contextPath}/img/ottos/wink_otter.png"
                             alt="AI 테마 추천"
                             style="width:390px;height:390px;object-fit:contain;margin-bottom:10px; margin-top: -75px;">
                        <p class="card-title" style="color:#20406a;">AI 테마 추천</p>
                        <div class="card-divider"
                             style="background:linear-gradient(90deg,transparent,rgba(130,170,230,0.5),transparent);"></div>
                        <p class="card-subtitle" style="color:#4a6090;">수험생, 임산부 등 상황에 맞는<br>최적의 조합을 AI가 추천합니다.</p>
                        <span class="card-tag" style="color:rgba(80,120,180,0.7);">AI Pick</span>
                    </div>
                </div>

                <%-- 앞면: 클릭 후 보이는 타로카드 이미지 --%>
                <div class="card-face card-front">
                    <img src="${pageContext.request.contextPath}/img/ottos/ai_otto_taro.png"
                         alt="AI 테마 추천 타로카드">
                </div>

            </div>
        </div>

    </div>
</div>

<%-- 오버레이 1 --%>
<div class="recommend-overlay" id="overlay1" onclick="closeOverlay('overlay1')">
    <div class="ov-card" onclick="event.stopPropagation()">
        <img style="cursor:pointer;"
             onclick="goTo('body_view', event)"
             src="${pageContext.request.contextPath}/img/ottos/body_otto_taro.png"
             alt="신체별 추천">
        <div class="ov-label">
            <p class="ov-title">신체별 추천</p>
            <p class="ov-sub">Body Care · 이미지를 클릭하면 이동합니다</p>
        </div>
        <div class="ov-close" onclick="closeOverlay('overlay1')">✕</div>
    </div>
</div>

<%-- 오버레이 2 --%>
<div class="recommend-overlay" id="overlay2" onclick="closeOverlay('overlay2')">
    <div class="ov-card" onclick="event.stopPropagation()">
        <img style="cursor:pointer;"
             onclick="goTo('curation_view', event)"
             src="${pageContext.request.contextPath}/img/ottos/ai_otto_taro.png"
             alt="AI 테마 추천">
        <div class="ov-label">
            <p class="ov-title">AI 테마 추천</p>
            <p class="ov-sub">AI Pick · 이미지를 클릭하면 이동합니다</p>
        </div>
        <div class="ov-close" onclick="closeOverlay('overlay2')">✕</div>
    </div>
</div>

<script>
    const cardConfig = {
        card1: {overlayId: 'overlay1', href: 'body_view'},
        card2: {overlayId: 'overlay2', href: 'curation_view'}
    };

    function flipCard(cardId, e) {
        e.stopPropagation();
        const card = document.getElementById(cardId);
        const inner = card.querySelector('.recommend-card-inner');
        const {overlayId} = cardConfig[cardId];

        if (card.classList.contains('flipped')) {
            openOverlay(overlayId);
            return;
        }

        card.classList.add('flipped');
        inner.style.transform = 'rotateY(180deg)';
        setTimeout(() => openOverlay(overlayId), 420);
    }

    function openOverlay(overlayId) {
        const overlay = document.getElementById(overlayId);
        overlay.classList.add('active');
        requestAnimationFrame(() => requestAnimationFrame(() =>
            overlay.classList.add('visible')
        ));
    }

    function closeOverlay(overlayId) {
        const overlay = document.getElementById(overlayId);
        overlay.classList.remove('visible');
        setTimeout(() => overlay.classList.remove('active'), 400);
    }

    function goTo(href, e) {
        e.stopPropagation();
        location.href = href;
    }
</script>
