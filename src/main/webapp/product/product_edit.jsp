<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <link rel="stylesheet" href="css/app.css">
    <link rel="stylesheet" href="css/product_edit.css">
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


<form action="product-edit" method="post" >
    <div class="app-container">
        <header class="app-header">
            <input type="hidden" name="productId" value="${product.productId}">
            <button type="button" class="back-btn" onclick="history.back()">이전</button>
            <h1 class="header-title">제품 편집</h1>
            <button class="back-btn" >저장</button>
        </header>

        <main class="content-wrapper">
            <section class="product-hero">
                <div class="product-img-box">
                    <img src="placeholder.png" name="productImage" class="product-img">
                </div>
                <div class="product-basic-info">
                    <span>제조사 명</span>
                    <input class="brand-name" type="text" name="productBrand" value="${product.productBrand}">
                    <span>제품 명</span>
                    <h2 class="product-title"><input type="text" name="productName" value="${product.productName}"></h2>
                   <span>가격</span>
                    <p class="product-price"><strong><input type="number" name="productPrice" value="${product.productPrice}">
                    </strong>원</p>
                </div>
            </section>

            <hr class="divider">

            <section class="info-section">
                <h3 class="section-title">복용 가이드</h3>
                <ul class="guide-list">
                    <li>총 용량 <span class="val"><input type="number" name="productTotal" value="${product.productTotal}"></span>정
                    </li>
                    <li>1회 섭취 <span class="val"><input type="number" name="productServe" value="${product.productServe}"></span>정
                    </li>
                    <li>1일 횟수 <span class="val"><input type="number"
                                                       name="productPerDay" value="${product.productPerDay}"></span>회
                    </li>
                </ul>
                <div class="timing-box">
                    <strong>복용 시점:</strong> <span><input type="select"
                                                         name="productTimeInfo" value="${product.productTimeInfo}"></span>
                </div>
            </section>

            <hr class="divider">

            <section class="info-section">
                <h3 class="section-title"><textarea name="productDescription" rows="10" cols="50">${product.productDescription}</textarea></h3>

                <div class="detail-meta">
                    <p>영양소 식별 번호: <span><input type="number" name="productNutrient" value="${product.productNutrient}"></span>
                    </p>
                    <p class="current-stock">
                    </p>
                </div>
            </section>
        </main>
    </div>
</form>


<div>review 부분</div>


</body>
</html>
