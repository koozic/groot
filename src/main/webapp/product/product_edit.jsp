<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <a href="hello-servlet" class="logo">약<span>쟁</span>이</a>
    <div class="hdr-right">
        <c:choose>
            <c:when test="${not empty sessionScope.loginUser}">
                <span class="hdr-link">${sessionScope.loginUser.name}님</span>
                <a href="mypage" class="hdr-link">마이페이지</a>
                <a href="logout" class="btn-login">로그아웃.</a>
            </c:when>
            <c:otherwise>
                <a href="join" class="hdr-link">회원가입</a>
                <a href="user-Login" class="btn-login">로그인</a>
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
        <a href="supplements" class="nav-item ${activeTab == 'nutrition' ? 'active' : ''}">영양성분</a>
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


<form action="product-edit" method="post" enctype="multipart/form-data">
    <div class="app-container">
        <header class="app-header">
            <input type="hidden" name="productId" value="${product.productId}">
            <input type="hidden" name="oldProductImage" value="${product.productImage}">
            <button type="button" class="back-btn" onclick="history.back()">이전</button>
            <h1 class="header-title">제품 편집</h1>
            <button type="submit" class="back-btn">저장</button>
        </header>

        <main class="content-wrapper">
            <section class="product-hero">
                <div class="product-img-box" onclick="document.getElementById('productImage').click()"
                     style="cursor: pointer;">
                    <img src="${product.productImage}" class="product-img"
                         id="previewImg">

                    <input type="file" id="productImage" name="productImage" accept="image/*"
                           style="display: none;" onchange="handleImagePreview(this)">
                </div>

                <div class="product-basic-info">
                    <span>제조사 명</span>
                    <input class="brand-name" type="text" name="productBrand" value="${product.productBrand}">
                    <span>제품 명</span>
                    <h2 class="product-title"><input type="text" name="productName" value="${product.productName}"></h2>
                    <div class="detail-meta">
                        <p>영양소 식별 번호:

                            <select name="productNutrient">
                                <c:forEach items="${nutrients}" var="n">
                                    <option value="${n.nutrientId}" ${n.nutrientId == product.productNutrient ? 'selected' : ''}>
                                            ${n.nutrientName}
                                    </option>
                                </c:forEach>
                            </select>

                        </p>
                        <p class="current-stock">
                        </p>
                    </div>
                    <span>가격</span>
                    <p class="product-price"><strong><input type="number" name="productPrice"
                                                            value="${product.productPrice}">
                    </strong>원</p>
                </div>
            </section>

            <hr class="divider">

            <section class="info-section">
                <h3 class="section-title">복용 가이드</h3>
                <ul class="guide-list">
                    <li>총 용량 <span class="val"><input type="number" name="productTotal" value="${product.productTotal}"></span>정
                    </li>
                    <li>1회 섭취 <span class="val"><input type="number" name="productServe"
                                                       value="${product.productServe}"></span>정
                    </li>
                    <li>1일 횟수 <span class="val"><input type="number"
                                                       name="productPerDay" value="${product.productPerDay}"></span>회
                    </li>
                </ul>
                <div class="timing-box">
                    <strong>복용 시점:</strong>
                    <select name="productTimeInfo">
                        <option value="식전" ${product.productTimeInfo == '식전' ? 'selected' : ''}>식전</option>
                        <option value="식후" ${product.productTimeInfo == '식후' ? 'selected' : ''}>식후</option>
                        <option value="식사 직후" ${product.productTimeInfo == '식사 직후' ? 'selected' : ''}>식사 직후</option>
                        <option value="공복" ${product.productTimeInfo == '공복' ? 'selected' : ''}>공복</option>
                        <option value="취침 전" ${product.productTimeInfo == '취침 전' ? 'selected' : ''}>취침 전</option>
                        <option value="상관없음" ${product.productTimeInfo == '상관없음' ? 'selected' : ''}>시간 상관없음</option>
                    </select>
                </div>
            </section>

            <hr class="divider">

            <section class="info-section">
                <h3 class="section-title"><textarea name="productDescription" rows="10"
                                                    cols="50">${product.productDescription}</textarea></h3>


            </section>
        </main>
    </div>
</form>


<div>review 부분</div>


</body>

<%-- body 태그가 끝나기 직전에 삽입 --%>
<script src="${pageContext.request.contextPath}/js/product.js?v=<%=System.currentTimeMillis()%>"></script>
</html>
