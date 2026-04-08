<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>Title</title>
    <link rel="stylesheet" href="css/app.css">
    <link rel="stylesheet" href="css/product_detail.css">
</head>
<body>

<!-- =============================================
     1. 헤더
     ============================================= -->
<header class="site-header">
    <a href="home" class="logo">약<span>쟁</span>이</a>
    <div class="hdr-right">
        <c:choose>
            <c:when test="${not empty sessionScope.loginUser}">
                <span class="hdr-link">${sessionScope.loginUser.nickname}님</span>
                <a href="mypage" class="hdr-link">마이페이지</a>
                <a href="logout" class="btn-login">로그아웃.</a>
            </c:when>
            <c:otherwise>
                <a href="join" class="hdr-link">회원가입</a>
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
        <a href="product" class="nav-item ${activeTab == 'product'   ? 'active' : ''}">제품</a>
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


<div class="app-container">
    <header class="app-header">
        <button class="back-btn" onclick="history.back()">이전</button>
        <h1 class="header-title">제품 정보</h1>
        <button class="back-btn" onclick="location.href='product-edit?id=${product.productId}'">수정</button>
    </header>

    <main class="content-wrapper">
        <section class="product-hero">
            <div class="product-img-box">
                <img src="placeholder.png" class="product-img">
            </div>
            <div class="product-basic-info">
                <span class="brand-name">${product.productBrand}</span>
                <h2 class="product-title">${product.productName}</h2>
                <span class="supplement-name">${nutrient.nutrientName}</span>
                <p class="product-price"><strong>${product.productPrice}</strong>원</p>
            </div>
        </section>

        <hr class="divider">

        <section class="info-section">
            <h3 class="section-title">복용 가이드</h3>
            <ul class="guide-list">
                <li>총 용량 <span class="val">${product.productTotal}</span>정</li>
                <li>1회 섭취 <span class="val">${product.productServe}</span>정</li>
                <li>1일 횟수 <span class="val">${product.productPerDay}</span>회</li>
            </ul>
            <div class="timing-box">
                <strong>복용 시점:</strong> <span>${product.productTimeInfo}</span>
            </div>
        </section>

        <hr class="divider">

        <section class="info-section">
            <h3 class="section-title">제품 설명</h3>
            <p class="description-text">${product.productDescription}</p>

            <div class="detail-meta">
                <p>등록일: <span>${product.productStartDate}</span></p>
            </div>
        </section>
    </main>
</div>


<div>review 부분</div>


</body>
</html>
