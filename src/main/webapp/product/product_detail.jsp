<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="app-container">
    <header class="app-header">
        <button class="back-btn" onclick="location.href='product'">이전</button>
        <h1 class="header-title">제품 정보</h1>
        <c:if test="${sessionScope.isAdmin == true}">
            <button class="back-btn" onclick="location.href='product-edit?id=${product.productId}'">수정</button>
        </c:if>
    </header>

    <main class="content-wrapper">
        <section class="product-hero">
            <div class="product-img-box">
                <img src="${product.productImage}" class="product-img" alt="${product.productName} 이미지">
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

<div class="review-section-wrapper" style="max-width: 800px; margin: 40px auto; padding: 0 20px;">
<%--    여기에 이 파일을 끼워 넣어라 그때 사용하는 게 <jsp:param>입니다. 이건 일종의 **포스트잇(메모)**이에요.name="PRODUCT_ID": "이 메모의 제목은 PRODUCT_ID야." value="${product.productId}": "메모의 내용은 현재 보고 있는 제품의 번호(ID)야." 즉, 전체 코드를 해석하면 이렇습니다.
"여기다 리뷰 블록(review.jsp)을 조립해 줘. 아! 그리고 조립할 때 '이건 106번 제품 리뷰용이야'라고 메모(PRODUCT_ID)해서 전달해 줘!"--%>
    <jsp:include page="../review/review.jsp">
        <jsp:param name="PRODUCT_ID" value="${product.productId}"/>
    </jsp:include>
</div>

<script src="js/product.js?v=3"></script>
