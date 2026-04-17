<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="css/product_edit.css">
<link rel="stylesheet" href="css/site-theme.css">

<form action="product-edit" method="post" enctype="multipart/form-data">
    <div class="pe-wrap">
        <div class="pe-container">
            <header class="pe-header">
                <input type="hidden" name="productId" value="${product.productId}">
                <input type="hidden" name="oldProductImage" value="${product.productImage}">
                <button type="button" class="pe-btn pe-btn-back" onclick="history.back()">이전</button>
                <h1 class="pe-title">제품 편집</h1>
                <button type="submit" class="pe-btn pe-btn-save">저장</button>
            </header>

            <main class="pe-content">
                <section class="pe-hero">
                    <div class="pe-img-box" onclick="document.getElementById('productImage').click()">
                        <img src="${product.productImage}" class="pe-img" id="previewImg">
                        <input type="file" id="productImage" name="productImage" accept="image/*" style="display: none;" onchange="handleImagePreview(this)">
                    </div>

                    <div class="pe-basic-info">
                        <span>제조사 명</span>
                        <input type="text" name="productBrand" value="${product.productBrand}">

                        <span>제품 명</span>
                        <input type="text" name="productName" value="${product.productName}" class="pe-input-title">

                        <div class="pe-meta">
                            <p>영양소 식별 번호:
                                <select name="productNutrient">
                                    <c:forEach items="${nutrients}" var="n">
                                        <option value="${n.nutrientId}" ${n.nutrientId == product.productNutrient ? 'selected' : ''}>
                                                ${n.nutrientName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </p>
                        </div>

                        <span>가격</span>
                        <div class="pe-price-row">
                            <input type="number" name="productPrice" value="${product.productPrice}" class="pe-input-price">
                            <strong>원</strong>
                        </div>
                    </div>
                </section>

                <hr class="pe-divider">

                <section class="pe-section">
                    <h3 class="pe-section-title">복용 가이드</h3>
                    <ul class="pe-guide-list">
                        <li>총 용량 <input type="number" name="productTotal" value="${product.productTotal}">정</li>
                        <li>1회 섭취 <input type="number" name="productServe" value="${product.productServe}">정</li>
                        <li>1일 횟수 <input type="number" name="productPerDay" value="${product.productPerDay}">회</li>
                    </ul>
                    <div class="pe-timing-box">
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

                <hr class="pe-divider">

                <section class="pe-section">
                    <h3 class="pe-section-title">제품 상세 설명</h3>
                    <textarea name="productDescription" rows="10">${product.productDescription}</textarea>
                </section>
            </main>
        </div>
    </div>
</form>

<script src="${pageContext.request.contextPath}/js/product.js?v=<%=System.currentTimeMillis()%>"></script>
