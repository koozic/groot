<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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

<div class="header-actions">
    <button type="button" class="btn-add-item" onclick="openModal()">
        <span class="icon">+</span> 영양제 등록
    </button>
</div>

<div id="productModal" class="modal">
    <div class="modal-content visual-enhanced">
        <div class="modal-header">
            <h2>신규 영양제 등록</h2>
            <span class="close" onclick="closeModal()">&times;</span>
        </div>

        <form action="product-add" class="modal-form" method="post" enctype="multipart/form-data">
            <input type="hidden" name="productAdmin" value="ky11">
            <input type="hidden" id="product_current" name="productCurrent" value="0">
            <div class="modal-body-visual">

                <div class="image-preview-container">
                    <label for="product_image_file" class="image-preview-frame" style="cursor: pointer;">
                        <img id="modal-img-preview" src="" alt="제품 이미지 미리보기" class="hidden">
                        <div class="image-placeholder">
                            <span class="icon">🖼️</span>
                            <p>클릭하여 사진을 첨부하세요</p>
                        </div>
                    </label>

                    <input type="file" id="product_image_file" name="productImage"
                           accept="image/*" onchange="previewImage(this)"
                           style="display: none;" required>
                </div>

                <div class="form-inputs-container">
                    <div class="form-grid single-col">
                        <div class="input-group full">
                            <label>제품명</label>
                            <input type="text" name="productName" placeholder="제품명을 입력하세요" required>
                        </div>

                        <div class="input-group">
                            <label>제조사(브랜드)</label>
                            <input type="text" name="productBrand" placeholder="제조사" required>
                        </div>

                        <div class="input-group">
                            <label>가격</label>
                            <input type="number" name="productPrice" placeholder="판매가(원)" min="0" max="99999" required>
                        </div>

                        <div class="input-group">
                            <label>영양소</label>
                            <select name="productNutrient">
                                <c:forEach items="${nutrients}" var="n">
                                    <option value="${n.nutrientId}">${n.nutrientName}</option>
                                </c:forEach>
                            </select>
                        </div>


                        <div class="input-group-row">
                            <div class="input-group">
                                <label>총 알약 수</label>
                                <input type="number" name="productTotal" placeholder="60" min="1">
                            </div>
                            <div class="input-group">
                                <label>1회 섭취량</label>
                                <input type="number" name="productServe" placeholder="2" min="1">
                            </div>
                            <div class="input-group">
                                <label>1일 횟수</label>
                                <input type="number" name="productPerDay" placeholder="3" min="1">
                            </div>
                        </div>

                        <div class="input-group full">
                            <label>제품 설명</label>
                            <textarea name="productDescription" rows="5"
                                      placeholder="제품에 대한 상세 설명을 입력하세요 (최대 1000자)"></textarea>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal()">취소</button>
                <button type="submit" class="btn-save">데이터 저장</button>

            </div>
        </form>

    </div>
</div>

<div id="toast" class="toast">등록 완료!</div>

<div class="product-container">
    <c:forEach items="${products}" var="p">

        <div class="product-card" onclick="location.href='product-detail?id=${p.productId}'">


            <div class="product-image">이미지 영역
                <button class="btn-delete"
                        onclick="event.stopPropagation(); confirmDelete('${p.productId}')">&times;
                </button>
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

<div id="deleteConfirmModal" class="modal">
    <div class="modal-content confirm-mini">
        <div class="modal-header">
            <h2>⚠️ 삭제 확인</h2>
            <span class="close" onclick="closeDeleteModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p>정말로 이 제품을 삭제하시겠습니까?</p>
            <p class="sub-text">삭제된 데이터는 복구할 수 없습니다.</p>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn-cancel" onclick="closeDeleteModal()">취소</button>
            <button type="button" id="btn-confirm-delete" class="btn-danger">삭제하기</button>
        </div>
    </div>
</div>

</body>

<script src="js/product.js"></script>

</html>




