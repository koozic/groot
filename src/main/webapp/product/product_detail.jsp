<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<link rel="stylesheet" href="css/product_detail.css">
<link rel="stylesheet" href="css/site-theme.css">



<script>
function openImgModal(imgSrc) {
    const modal = document.getElementById("pdImageModal");
    const expandedImg = document.getElementById("pdExpandedImg");

    if (modal && expandedImg) {
        modal.style.display = "block";
        expandedImg.src = imgSrc;
        document.body.style.overflow = "hidden";

        // Add keyboard escape key support
        const handleEscape = (e) => {
            if (e.key === 'Escape') {
                closeImgModal();
            }
        };
        document.addEventListener('keydown', handleEscape);

        // Store handler reference for cleanup
        modal._escapeHandler = handleEscape;
    }
}

function closeImgModal() {
    const modal = document.getElementById("pdImageModal");
    if (modal) {
        modal.style.display = "none";
        document.body.style.overflow = "auto";

        // Remove escape key listener
        if (modal._escapeHandler) {
            document.removeEventListener('keydown', modal._escapeHandler);
            modal._escapeHandler = null;
        }
    }
}
</script>


<div class="product-detail-page">
    <div class="pd-container">
        <main class="pd-content">
            <section class="pd-hero">
                <%-- 추가된 상단 액션 바 (이전 버튼 & 수정 버튼) --%>
                <div class="pd-action-bar" style="display: flex; justify-content: space-between; padding: 15px 30px; border-bottom: 1px solid #eee; background-color: #fff;">
                    <%-- 왼쪽: 이전 버튼 --%>
                    <button type="button" class="btn-back" onclick="location.href='product'" >
                        ← 이전
                    </button>

                    <%-- 오른쪽: 관리자 수정 버튼 --%>
                    <c:if test="${not empty sessionScope.isAdmin}">
                        <button type="button" class="btn-edit" onclick="location.href='product-edit?id=${product.productId}'" >
                            상품 수정
                        </button>
                    </c:if>
                </div>
                <div class="pd-img-box">
                    <img src="${product.productImage}"
                         class="pd-main-img"
                         alt="${product.productName}"
                         onclick="openImgModal('${product.productImage}')"
                         style="cursor: pointer;">
                </div>

                <div class="pd-info-box">
                    <span class="pd-nutrient-tag">${nutrient.nutrientName}</span>
                    <span class="pd-brand">${product.productBrand}</span>
                    <h2 class="pd-title">${product.productName}</h2>
                    <div class="pd-price-row">
                        <span class="pd-price-val"><strong>${product.productPrice}</strong>원</span>
                    </div>


                </div>
            </section>

            <div class="pd-divider-line"></div>

            <section class="pd-section">
                <h3 class="pd-section-title">복용 가이드</h3>
                <ul class="pd-guide-grid">
                    <li>
                        <span class="label">총 용량</span>
                        <span class="val">${product.productTotal}정</span>
                    </li>
                    <li>
                        <span class="label">1회 섭취</span>
                        <span class="val">${product.productServe}정</span>
                    </li>
                    <li>
                        <span class="label">1일 횟수</span>
                        <span class="val">${product.productPerDay}회</span>
                    </li>
                </ul>
                <div class="pd-timing-note">
                    <strong>💡 복용 시점:</strong> ${product.productTimeInfo}
                </div>
            </section>

            <div class="pd-divider-line"></div>

            <section class="pd-section">
                <h3 class="pd-section-title">제품 상세 설명</h3>
                <div class="pd-description">
                    ${product.productDescription}
                </div>
                <div class="pd-meta">
                    등록일: ${product.productStartDate}
                </div>
            </section>
        </main>
    </div>
</div>

<!-- Image Modal -->
<div id="pdImageModal" class="pd-image-modal" onclick="closeImgModal()">
    <span class="pd-modal-close" onclick="closeImgModal()">&times;</span>
    <img class="pd-modal-content" id="pdExpandedImg">
</div>


<%--review 영역 시작--%>
<%--review 영역 시작--%>
<%--review 영역 시작--%>


<div class="review-section-wrapper" style="max-width: 800px; margin: 40px auto; padding: 0 20px;">
<%--    여기에 이 파일을 끼워 넣어라 그때 사용하는 게 <jsp:param>입니다. 이건 일종의 **포스트잇(메모)**이에요.name="PRODUCT_ID": "이 메모의 제목은 PRODUCT_ID야." value="${product.productId}": "메모의 내용은 현재 보고 있는 제품의 번호(ID)야." 즉, 전체 코드를 해석하면 이렇습니다.
"여기다 리뷰 블록(review.jsp)을 조립해 줘. 아! 그리고 조립할 때 '이건 106번 제품 리뷰용이야'라고 메모(PRODUCT_ID)해서 전달해 줘!"--%>
    <jsp:include page="../review/review.jsp">
        <jsp:param name="PRODUCT_ID" value="${product.productId}"/>
    </jsp:include>
</div>


<script src="js/product.js?v=3"></script>
