<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<input type="hidden" id="isAdmin" value="${sessionScope.isAdmin}">

<div class="action-bar-container">
    <div class="nutrient-filter-list">
        <button type="button" class="filter-btn active" id="filter-all" onclick="loadProductList('')">
            <span class="icon">🔍</span> 전체
        </button>

        <div class="filter-dropdown">
            <button type="button" class="filter-btn dropdown-toggle" onclick="toggleDropdown(this)">
                <span class="icon">💊</span> 비타민 <span class="arrow">▼</span>
            </button>

            <div class="dropdown-menu vitamin-mega-menu">

                <div class="vitamin-section">
                    <h4 class="section-header water-soluble">수용성 비타민 <small>Water-soluble</small></h4>
                    <div class="vitamin-grid">
                        <c:forEach items="${nutrients}" var="n">
                            <c:if test="${fn:contains(n.nutrientName, '비타민 B') || fn:contains(n.nutrientName, '비타민 C') || fn:contains(n.nutrientName, '엽산') || fn:contains(n.nutrientName, '비오틴')}">
                                <button type="button" class="v-item filter-item" data-id="${n.nutrientId}" onclick="loadProductList('${n.nutrientId}')">
                                        ${fn:replace(n.nutrientName, '비타민 ', '')}
                                </button>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>

                <div class="vitamin-section">
                    <h4 class="section-header fat-soluble">지용성 비타민 <small>Fat-soluble</small></h4>
                    <div class="vitamin-grid">
                        <c:forEach items="${nutrients}" var="n">
                            <c:if test="${fn:contains(n.nutrientName, '비타민 A') || fn:contains(n.nutrientName, '비타민 D') || fn:contains(n.nutrientName, '비타민 E') || fn:contains(n.nutrientName, '비타민 K')}">
                                <button type="button" class="v-item filter-item" data-id="${n.nutrientId}" onclick="loadProductList('${n.nutrientId}')">
                                        ${fn:replace(n.nutrientName, '비타민 ', '')}
                                </button>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>

            </div>
        </div>

        <c:forEach items="${nutrients}" var="n">
            <c:if test="${!fn:contains(n.nutrientName, '비타민') && !fn:contains(n.nutrientName, '엽산') && !fn:contains(n.nutrientName, '비오틴')}">
                <button type="button" class="filter-btn filter-item" data-id="${n.nutrientId}" onclick="loadProductList('${n.nutrientId}')">
                    <span class="icon">💊</span> ${n.nutrientName}
                </button>
            </c:if>
        </c:forEach>
    </div>

    <div class="header-actions">
        <c:if test="${sessionScope.isAdmin == true}">
            <button type="button" class="btn-add-item" onclick="openModal()">
                <span class="icon">+</span> 영양제 등록
            </button>
        </c:if>
    </div>
</div>

<div class="product-container" id="product-list-container"></div>



<div id="productModal" class="modal">
    <div class="modal-content visual-enhanced">
        <div class="modal-header">
            <h2>신규 영양제 등록</h2>
            <span class="close" onclick="closeModal()">&times;</span>
        </div>

        <%--ADD 부분 모달--%>
        <form action="product-add" class="modal-form" method="post" enctype="multipart/form-data"
              onsubmit="return validateProductForm()">
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
                           style="display: none;">
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
                            <input type="number" name="productPrice" placeholder="판매가(원)" min="0" max="99999"
                                   required>
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
                                <input type="number" name="productTotal" placeholder="60" min="1" required>
                            </div>
                            <div class="input-group">
                                <label>1회 섭취량</label>
                                <input type="number" name="productServe" placeholder="2" min="1" required>
                            </div>
                            <div class="input-group">
                                <label>1일 횟수</label>
                                <input type="number" name="productPerDay" placeholder="3" min="1" required>
                            </div>

                            <div class="input-group full">
                                <label>섭취 시간 상세</label>
                                <select name="productTimeInfo" required>
                                    <option value="" disabled selected>섭취 타이밍을 선택하세요</option>
                                    <option value="식전">식전 (식사 30분 전)</option>
                                    <option value="식후">식후 (식사 30분 후)</option>
                                    <option value="식사 직후">식사 직후</option>
                                    <option value="공복">공복</option>
                                    <option value="취침 전">취침 전</option>
                                    <option value="상관없음">시간 상관없음</option>
                                </select>
                            </div>
                        </div>

                        <div class="input-group full">
                            <label>제품 설명</label>
                            <textarea name="productDescription" rows="5"
                                      placeholder="제품에 대한 상세 설명을 입력하세요 (최대 1000자)" required></textarea>
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


<%--<script src="js/product.js"></script>--%>
<script src="js/product.js?v=20260408"></script>




