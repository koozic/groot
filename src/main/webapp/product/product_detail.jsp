<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<div class="app-container">
    <header class="app-header">
        <button class="back-btn" onclick="location.href='product'">이전</button>
        <h1 class="header-title">제품 정보</h1>
        <button class="back-btn" onclick="location.href='product-edit?id=${product.productId}'">수정</button>
    </header>

    <main class="content-wrapper">
        <section class="product-hero">
            <div class="product-img-box">
                <img src="${product.productImage}"
                     class="product-img"
                     alt="${product.productName} 이미지">
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
<div id="toast" class="toast"></div>

<%-- ========================================================= --%>
<%-- 🌟 3. 상품 리뷰 구역 (무영님 코드 합체!) --%>
<%-- ========================================================= --%>
<div class="review-section-wrapper" style="max-width: 800px; margin: 40px auto; padding: 0 20px;">

    <%-- ../review/review.jsp 로 경로를 맞춰서 다른 폴더에 있는 파일을 정확히 불러옵니다! --%>
    <jsp:include page="../review/review.jsp">
        <jsp:param name="PRODUCT_ID" value="${product.productId}"/>
    </jsp:include>

</div>


<script src="js/product.js?v=3"></script>

