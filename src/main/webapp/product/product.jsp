<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>제품 상세 페이지</title>
    <link rel="stylesheet" href="css/product.css">
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


<div class="product-container">
    <c:forEach items="${products}" var="p">

        <div class="product-card" onclick="location.href='product-detail?id=${p.productId}'">


            <div class="product-image">이미지 영역
                <button class="btn-delete" onclick="event.stopPropagation(); location.href='product-del?id=${p.productId}'">&times;</button>
            </div>
            <div class="product-info">
                <div class="product-name">${p.productName}</div>
                <div class="product-brand">${p.productBrand}</div>
                <div class="product-nutrient">${p.productNutrient}</div>
                <div class="product-price">${p.productPrice}원</div>
                <div class="product-date">${p.productStartDate}</div>
            </div>
        </div>

    </c:forEach>
</div>
</body>


</html>




