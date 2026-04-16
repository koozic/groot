<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <link rel="icon" type="image/png"
          href="${pageContext.request.contextPath}/img/favicon.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OTTERCARE</title>

    <script>
        let IS_LOGIN = ${(not empty sessionScope.loginUser) or (sessionScope.isAdmin == true)};
        window.IS_LOGIN = IS_LOGIN;
        window.IS_ADMIN = ${sessionScope.isAdmin == true};
        window.LOGIN_USER_ID = "${not empty sessionScope.loginUser ? sessionScope.loginUser.user_id : ''}";
    </script>
    <script src="${pageContext.request.contextPath}/js/app.js?v=<%=System.currentTimeMillis()%>"></script>
    <link rel="stylesheet" href="css/app.css">
    <link rel="stylesheet" href="css/recommend.css">
    <link rel="stylesheet" href="css/home.css">
    <c:if test="${content == 'body/body.jsp'}">
        <link rel="stylesheet" href="css/body.css">
    </c:if>
    <%--    <c:if test="${content == 'body/body.jsp'}">--%>
    <%--        <script src="js/body.js" charset="UTF-8" defer></script>--%>
    <%--    </c:if>--%>
    <link rel="stylesheet" href="css/product.css">
    <link rel="stylesheet" href="css/product_edit.css">
</head>
<body>


<!-- =============================================
     1. 헤더
     ============================================= -->
<header class="site-header">

    <%-- 왼쪽: 햄버거 메뉴 버튼 + 드롭다운 --%>
    <div class="hdr-menu-wrap">
        <button class="hdr-menu-btn" id="menuBtn" onclick="toggleMenu()" aria-label="메뉴">
            <span class="menu-bar"></span>
            <span class="menu-bar"></span>
            <span class="menu-bar"></span>
        </button>
        <%-- 드롭다운 메뉴 --%>
        <nav class="dropdown-menu" id="dropdownMenu">
            <a href="product" class="dropdown-item ${activeTab == 'product'   ? 'active' : ''}">💊 제품</a>
            <a href="supplements" class="dropdown-item ${activeTab == 'nutrition' ? 'active' : ''}">🧪 영양성분</a>
            <a href="recommend" class="dropdown-item ${activeTab == 'recommend' ? 'active' : ''}">✨ 영양추천</a>
            <c:if test="${sessionScope.isAdmin == true}">
                <a href="admin" class="dropdown-item ${activeTab == 'admin'     ? 'active' : ''}">🛠️ 영양제 관리</a>
            </c:if>
            <div class="dropdown-divider"></div>
            <a href="cart" class="dropdown-item">🛒 장바구니</a>
        </nav>
    </div>

    <%-- 중앙: 이미지 로고 --%>
    <div style="position:absolute; left:50%; transform:translateX(-50%);">
        <a href="hello-servlet">
            <img src="img/logo.png"
                 alt="Otter Care 로고"
                 class="logo-img"
                 style="height:160px; width:auto; display:block; cursor:pointer; object-fit:contain;
            transition: height .35s ease;">
        </a>
    </div>

    <%-- 오른쪽: 프로필/마이페이지/로그인 --%>
    <div class="hdr-right">
        <c:choose>
            <c:when test="${not empty sessionScope.loginUser}">
                <c:set var="profilePath" value="${fn:trim(sessionScope.loginUser.user_profile)}"/>
                <img
                        src="${(fn:startsWith(profilePath, 'http://') or fn:startsWith(profilePath, 'https://')) ? profilePath : pageContext.request.contextPath.concat('/').concat(profilePath)}"
                        alt="프로필"
                        style="width:40px; height:40px; border-radius:50%; object-fit:cover;"
                        onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/user/userImg/Ayanokoji.jfif';"
                >
                <a href="mypage" class="hdr-link">마이페이지</a>
                <a href="logout" class="btn-login" style="padding: 5px 12px;">로그아웃</a>
            </c:when>
            <c:otherwise>
                <a href="join" class="hdr-link">회원가입</a>
                <a href="user-Login" class="btn-login">로그인</a>
            </c:otherwise>
        </c:choose>
    </div>
</header>


<!-- =============================================
     3. 메인 콘텐츠 (여기만 바뀜)
     ============================================= -->
<main class="site-body" id="siteBody">
    <%-- Servlet에서 content 속성으로 페이지 지정 --%>
    <c:if test="${not empty msg}">
        <div class="alert alert-info">${msg}</div>
    </c:if>

    <jsp:include page="${content}"/>
</main>

<!-- =============================================
     4. 플로팅 장바구니 버튼 (항상 표시)
     ============================================= -->
<div class="float-cart" id="floatCart" onclick="toggleCart()">
    <div class="float-icon">🛒</div>
    <c:if test="${not empty sessionScope.cartCount and sessionScope.cartCount > 0}">
        <div class="float-badge">${sessionScope.cartCount}</div>
    </c:if>
</div>

<!-- =============================================
     5. 장바구니 슬라이드 패널
     ============================================= -->
<div class="cart-panel" id="cartPanel">
    <div class="cp-header">
        <div class="cp-title">
            장바구니
            <span class="cp-count">
                <c:choose>
                    <c:when test="${not empty sessionScope.cartCount}">${sessionScope.cartCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </span>
        </div>
        <button class="cp-close" onclick="toggleCart()">✕</button>
    </div>

    <div class="cp-body">
        <div class="cp-empty">
            <span class="cp-empty-icon">🛒</span>
            <p>장바구니가 비어있어요</p>
            <span>마음에 드는 제품을 담아보세요!</span>
        </div>
    </div>

    <div class="cp-footer">
        <div class="cp-note">결제 기능은 추후 추가 예정입니다</div>
        <a href="cart" class="btn btn-primary btn-full">장바구니 전체보기</a>
    </div>
</div>

<!-- =============================================
     6. 하단 탭바 (모바일 전용)
     ============================================= -->
<nav class="bottom-tab">
    <a href="hello-servlet" class="tab-item ${activeTab == 'home'      ? 'active' : ''}">
        <span class="tab-icon">🏠</span>홈
    </a>
    <a href="product" class="tab-item ${activeTab == 'product'   ? 'active' : ''}">
        <span class="tab-icon">💊</span>제품
    </a>
    <a href="supplements" class="tab-item ${activeTab == 'nutrition' ? 'active' : ''}">
        <span class="tab-icon">🧪</span>영양
    </a>
    <a href="recommend" class="tab-item ${activeTab == 'recommend' ? 'active' : ''}">
        <span class="tab-icon">✨</span>추천
    </a>
    <c:if test="${sessionScope.isAdmin == true}">
        <a href="admin" class="tab-item ${activeTab == 'admin' ? 'active' : ''}">
            <span class="tab-icon">🛠️</span>관리
        </a>
    </c:if>
    <c:choose>
        <c:when test="${not empty sessionScope.loginUser}">
            <a href="mypage" class="tab-item ${activeTab == 'mypage' ? 'active' : ''}">
                <span class="tab-icon">👤</span>마이
            </a>
        </c:when>
        <c:otherwise>
            <a href="user-Login" class="tab-item ${activeTab == 'login' ? 'active' : ''}">
                <span class="tab-icon">🔑</span>로그인
            </a>
        </c:otherwise>
    </c:choose>
</nav>

<%--body.js는 body.jsp가 include된 경우에만, body 태그 닫히기 직전에 로드--%>
<c:if test="${content == 'body/body.jsp'}">
    <script src="js/body.js"></script>
</c:if>
<script>
    /* ── 1. 햄버거 드롭다운 ── */
    function toggleMenu() {
        const menu = document.getElementById('dropdownMenu');
        const btn = document.getElementById('menuBtn');
        if (!menu || !btn) return;
        menu.classList.toggle('open');
        btn.classList.toggle('open');
    }

    document.addEventListener('click', function (e) {
        const wrap = document.querySelector('.hdr-menu-wrap');
        if (wrap && !wrap.contains(e.target)) {
            const menu = document.getElementById('dropdownMenu');
            const btn = document.getElementById('menuBtn');
            if (menu) menu.classList.remove('open');
            if (btn) btn.classList.remove('open');
        }
    });

    /* ── 2. 스크롤 헤더 동작 ── */
    (function () {
        var header = document.querySelector('.site-header');
        var root = document.documentElement;
        var H_FULL = 170;
        var H_SMALL = 64;
        var TOP_ZONE = 100;
        var DEAD = 12;        /* 12px 이상 움직여야 반응 */

        /* lastTriggerY: 마지막으로 상태가 바뀐 시점의 Y값
           → 여기서 DEAD px 이상 차이나야 다음 판단 실행
           → 이 방식이면 TOP_ZONE 근처 진동이 원천 차단됨 */
        var lastTriggerY = window.scrollY;
        var state = window.scrollY <= TOP_ZONE ? 'full' : 'small';

        function go(next) {
            if (next === state) return;
            state = next;

            if (next === 'full') {
                header.classList.remove('hide', 'scrolled');
                root.style.setProperty('--header-h', H_FULL + 'px');

            } else if (next === 'small') {
                header.classList.add('scrolled');
                root.style.setProperty('--header-h', H_SMALL + 'px');
                /* rAF 두 번 중첩: 첫 번째 프레임에 scrolled 반영,
                   두 번째 프레임에 hide 제거 → 반드시 작은 크기로 나옴 */
                requestAnimationFrame(function () {
                    requestAnimationFrame(function () {
                        header.classList.remove('hide');
                    });
                });

            } else { /* hidden */
                /* scrolled는 그대로 두고 hide만 추가
                   → 풀사이즈 상태에서 처음 내릴 땐 풀 채로 올라가고
                   → 이미 small이면 작은 채로 올라감 */
                header.classList.add('hide');
            }
        }

        window.addEventListener('scroll', function () {
            var y = window.scrollY;
            var diff = y - lastTriggerY;   /* lastY가 아닌 lastTriggerY 기준 */

            if (Math.abs(diff) < DEAD) return;

            /* 상태 판단 */
            var next;
            if (y <= TOP_ZONE) {
                next = 'full';
            } else if (diff > 0) {
                next = 'hidden';
            } else {
                next = 'small';
            }

            /* 상태가 실제로 바뀔 때만 lastTriggerY 갱신
               → 바뀌지 않으면 기준점 유지 → 진동 원천 차단 */
            if (next !== state) {
                lastTriggerY = y;
                go(next);
            }

        }, {passive: true});

        /* 초기 상태 */
        if (window.scrollY > TOP_ZONE) go('small');
    })();
</script>
</body>
</html>
