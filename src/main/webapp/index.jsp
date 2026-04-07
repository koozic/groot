<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title >약쟁이</title>
    <link rel="stylesheet" href="css/app.css">
    <link rel="stylesheet" href="css/login.css">

</head>
<body>

<!-- =============================================
     1. 헤더
     ============================================= -->
<header class="site-header">
    <a href="hello-servlet" class="logo">약<span>쟁</span>이</a>
    <div class="hdr-right">
        <c:choose>
            <c:when test="${not empty sessionScope.loginUser}">
                <span class="hdr-link">어서오세요. 당신의 건강을 챙기세요</span>
                <img
                        src="${sessionScope.loginUser.user_profile}"
                        alt="프로필"
                        style="width:40px; height:40px; border-radius:50%; object-fit:cover;"
                >
                <span class="hdr-link">${sessionScope.loginUser.name}님</span>
                <a href="mypage" class="hdr-link">마이페이지</a>
                <a href="logout" class="btn-login">로그아웃.</a>
            </c:when>
            <c:otherwise>
                <a href="join"  class="hdr-link">회원가입</a>
                <a href="login" class="btn-login">로그인</a>
            </c:otherwise>
        </c:choose>
    </div>
</header>

<!-- =============================================
     2. 네비게이션 (PC용 상단 nav)
     ============================================= -->
<nav class="site-nav">
    <div class="nav-left">
        <a href="product"   class="nav-item ${activeTab == 'product'   ? 'active' : ''}">제품</a>
        <a href="nutrition" class="nav-item ${activeTab == 'nutrition' ? 'active' : ''}">영양성분</a>
        <a href="recommend" class="nav-item ${activeTab == 'recommend' ? 'active' : ''}">영양추천</a>

    </div>
    <%-- nav 장바구니 버튼 --%>
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
    <jsp:include page="${content}" />
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
            <c:if test="${not empty sessionScope.cartCount}">
                <span class="cp-count">${sessionScope.cartCount}</span>
            </c:if>
        </div>
        <button class="cp-close" onclick="toggleCart()">✕</button>
    </div>

    <div class="cp-body">
        <c:choose>
            <c:when test="${not empty sessionScope.cartList}">
                <c:forEach var="item" items="${sessionScope.cartList}">
                    <div class="cart-item">
                        <div class="ci-icon" style="background: #eff6ff;">💊</div>
                        <div class="ci-info">
                            <div class="ci-name">${item.productName}</div>
                            <div class="ci-sub">${item.brand}</div>
                        </div>
                        <button class="ci-del" onclick="removeCart(${item.cartId})">✕</button>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="cp-empty">
                    <span class="cp-empty-icon">🛒</span>
                    <p>장바구니가 비어있어요</p>
                    <span>마음에 드는 제품을 담아보세요!</span>
                </div>
            </c:otherwise>
        </c:choose>
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
    <a href="home"      class="tab-item ${activeTab == 'home'      ? 'active' : ''}">
        <span class="tab-icon">🏠</span>홈
    </a>
    <a href="product"   class="tab-item ${activeTab == 'product'   ? 'active' : ''}">
        <span class="tab-icon">💊</span>제품
    </a>
    <a href="nutrition" class="tab-item ${activeTab == 'nutrition' ? 'active' : ''}">
        <span class="tab-icon">🧪</span>영양
    </a>
    <a href="recommend" class="tab-item ${activeTab == 'recommend' ? 'active' : ''}">
        <span class="tab-icon">✨</span>추천
    </a>
    <c:choose>
        <c:when test="${not empty sessionScope.loginUser}">
            <a href="mypage" class="tab-item ${activeTab == 'mypage' ? 'active' : ''}">
                <span class="tab-icon">👤</span>마이
            </a>
        </c:when>
        <c:otherwise>
            <a href="login" class="tab-item ${activeTab == 'login' ? 'active' : ''}">
                <span class="tab-icon">🔑</span>로그인
            </a>
        </c:otherwise>
    </c:choose>
</nav>

<!-- =============================================
     7. JavaScript
     ============================================= -->
<script>
    // 장바구니 토글
    function toggleCart() {
        const panel    = document.getElementById('cartPanel');
        const floatBtn = document.getElementById('floatCart');
        const body     = document.getElementById('siteBody');
        const isOpen   = panel.classList.toggle('open');
        floatBtn.classList.toggle('open', isOpen);
        // 모바일에서는 본문 안 밀림
        if (window.innerWidth > 768) {
            body.classList.toggle('shifted', isOpen);
        }
    }

    // 장바구니 삭제 (AJAX)
    function removeCart(cartId) {
        fetch('cart/remove?id=' + cartId, { method: 'POST' })
            .then(res => res.json())
            .then(data => {
                if (data.success) location.reload();
            });
    }

    // 패널 바깥 클릭시 닫기
    document.addEventListener('click', function(e) {
        const panel    = document.getElementById('cartPanel');
        const floatBtn = document.getElementById('floatCart');
        const navCart  = document.querySelector('.nav-cart');
        if (panel.classList.contains('open') &&
            !panel.contains(e.target) &&
            !floatBtn.contains(e.target) &&
            !navCart.contains(e.target)) {
            panel.classList.remove('open');
            floatBtn.classList.remove('open');
            document.getElementById('siteBody').classList.remove('shifted');
        }
    });
</script>

</body>
</html>
