<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>약쟁이</title>
    <script>
        const IS_LOGIN = ${ (not empty sessionScope.loginUser) or (sessionScope.isAdmin == true) };
        window.IS_LOGIN = IS_LOGIN;
        window.IS_ADMIN = ${ sessionScope.isAdmin == true };
        window.LOGIN_USER_ID = "${not empty sessionScope.loginUser ? sessionScope.loginUser.user_id : ''}";
    </script>
    <script src="js/app.js"></script>
    <link rel="stylesheet" href="css/app.css">
    <link rel="stylesheet" href="css/recommend.css">
    <link rel="stylesheet" href="css/home.css">
    <c:if test="${content == 'body/body.jsp'}">
        <link rel="stylesheet" href="css/body.css">
    </c:if>
    <c:if test="${content == 'body/body.jsp'}">
        <script src="js/body.js" defer></script>
    </c:if>
    <link rel="stylesheet" href="css/product.css">
    <link rel="stylesheet" href="css/product_detail.css">
    <link rel="stylesheet" href="css/product_edit.css">
</head>
<body>


<!-- =============================================
     1. 헤더
     ============================================= -->
<header class="site-header">
    <%-- 로고가 있어야 로그인이 오른쪽으로 밀려납니다 --%>
    <div class="logo" onclick="location.href='hello-servlet'">약<span>쟁이</span></div>

    <%-- 직접 썼던 style은 지우고 클래스명만 유지! --%>
    <div class="hdr-right">
        <c:choose>
            <%-- [1] 로그인 했을 때 --%>
            <c:when test="${not empty sessionScope.loginUser}">
                <span class="hdr-link">${sessionScope.loginUser.name}님 어서오세요. 당신의 건강을 챙기세요</span>
                <img
                        src="${pageContext.request.contextPath}/user/userImg/${sessionScope.loginUser.user_profile}"
                        alt="프로필"
                        style="width:40px; height:40px; border-radius:50%; object-fit:cover;"
                        onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/user/userImg/Ayanokoji.jfif';"
                >


                <a href="mypage" class="hdr-link">마이페이지</a>
                <a href="logout" class="btn-login" style="padding: 5px 12px;">로그아웃</a>
            </c:when>

            <%-- [2] 로그인 안 했을 때 --%>
            <c:otherwise>
                <a href="join" class="hdr-link">회원가입</a>
                <a href="user-Login" class="btn-login">로그인</a>
            </c:otherwise>
        </c:choose>
    </div>
</header>
<!-- =============================================
     2. 네비게이션
     ============================================= -->
<nav class="site-nav">
    <div class="nav-left">
        <a href="product" class="nav-item ${activeTab == 'product'   ? 'active' : ''}">제품</a>
        <a href="supplements" class="nav-item ${activeTab == 'nutrition' ? 'active' : ''}">영양성분</a>
        <a href="recommend" class="nav-item ${activeTab == 'recommend' ? 'active' : ''}">영양추천</a>
        <%-- ✅ 추가: 관리자 세션일 때만 탭 표시 --%>
        <c:if test="${sessionScope.isAdmin == true}">
            <a href="admin" class="nav-item ${activeTab == 'admin' ? 'active' : ''}">🛠️ 영양제 관리</a>
        </c:if>

    </div>
    <div class="nav-cart" onclick="toggleCart()">
        <span class="nav-cart-icon">🛒</span>
        <span>장바구니</span>
        <c:if test="${not empty sessionScope.cartCount and sessionScope.cartCount > 0}">
            <div class="nav-badge">${sessionScope.cartCount}</div>
        </c:if>
    </div>
</nav>
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

</body>
</html>
