<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .cart-page {
        display: grid;
        grid-template-columns: 1fr 280px;
        gap: 20px;
        align-items: start;
    }
    .cart-page-card {
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 10px;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
    }
    .cart-page-head {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 16px 18px;
        border-bottom: 1px solid #e5e7eb;
    }
    .cart-page-title {
        font-size: 18px;
        font-weight: 800;
        color: #111827;
    }
    .cart-page-count {
        font-size: 13px;
        color: #6b7280;
        font-weight: 700;
    }
    .cart-page-list {
        padding: 6px 18px 10px;
    }
    .cart-page-item {
        display: grid;
        grid-template-columns: 72px 1fr auto auto;
        gap: 14px;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #f3f4f6;
    }
    .cart-page-item:last-child {
        border-bottom: 0;
    }
    .cart-page-thumb {
        width: 72px;
        height: 72px;
        border-radius: 10px;
        object-fit: cover;
        border: 1px solid #e5e7eb;
        background: #f9fafb;
    }
    .cart-page-name {
        font-size: 15px;
        font-weight: 800;
        color: #111827;
    }
    .cart-page-brand {
        margin-top: 4px;
        font-size: 12px;
        color: #6b7280;
    }
    .cart-page-price {
        font-size: 15px;
        font-weight: 800;
        color: #111827;
        white-space: nowrap;
    }
    .cart-page-remove {
        border: 1px solid #e5e7eb;
        background: #fff;
        color: #6b7280;
        border-radius: 8px;
        padding: 8px 10px;
        font-size: 12px;
        font-weight: 700;
        cursor: pointer;
    }
    .cart-page-remove:hover {
        color: #ef4444;
        border-color: #fecaca;
        background: #fef2f2;
    }
    .cart-page-empty {
        padding: 46px 16px;
        text-align: center;
        color: #6b7280;
    }
    .cart-page-empty p {
        margin-top: 10px;
        font-size: 14px;
        font-weight: 700;
        color: #111827;
    }
    .cart-page-side {
        padding: 16px 18px;
    }
    .cart-page-side h3 {
        font-size: 15px;
        font-weight: 800;
        margin-bottom: 12px;
    }
    .cart-page-summary {
        display: flex;
        justify-content: space-between;
        margin: 8px 0;
        font-size: 14px;
    }
    .cart-page-summary strong {
        font-size: 16px;
    }
    .cart-page-go {
        width: 100%;
        margin-top: 14px;
        border: 0;
        border-radius: 8px;
        background: #2563eb;
        color: #fff;
        font-weight: 800;
        padding: 12px;
        cursor: pointer;
    }
    .cart-page-go:hover {
        background: #1d4ed8;
    }
    @media (max-width: 900px) {
        .cart-page {
            grid-template-columns: 1fr;
        }
    }
    @media (max-width: 640px) {
        .cart-page-item {
            grid-template-columns: 56px 1fr;
            grid-template-areas:
                "thumb info"
                "thumb meta";
            gap: 8px 10px;
        }
        .cart-page-thumb { grid-area: thumb; width: 56px; height: 56px; }
        .cart-page-info { grid-area: info; }
        .cart-page-meta {
            grid-area: meta;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
    }
</style>

<section class="cart-page">
    <div class="cart-page-card">
        <div class="cart-page-head">
            <h2 class="cart-page-title">장바구니 전체보기</h2>
            <div class="cart-page-count">총 <span id="cartPageCount">${sessionScope.cartCount}</span>개</div>
        </div>

        <div class="cart-page-list" id="cartPageList">
            <c:choose>
                <c:when test="${not empty favoriteList}">
                    <c:forEach var="item" items="${favoriteList}">
                        <article class="cart-page-item" data-cart-id="${item.favorite_id}">
                            <img class="cart-page-thumb"
                                 src="${item.product_image}"
                                 alt="${item.product_name}"
                                 onerror="this.onerror=null;this.src='img/pill.png';">
                            <div class="cart-page-info">
                                <div class="cart-page-name">${item.product_name}</div>
                                <div class="cart-page-brand">${item.product_brand}</div>
                            </div>
                            <div class="cart-page-meta">
                                <div class="cart-page-price">${item.product_price}원</div>
                                <button class="cart-page-remove" onclick="removeCartFromPage(${item.favorite_id})">삭제</button>
                            </div>
                        </article>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="cart-page-empty" id="cartPageEmpty">
                        <div>🛒</div>
                        <p>장바구니가 비어있어요</p>
                        <span>제품 페이지에서 담기를 눌러 추가해보세요.</span>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <aside class="cart-page-card cart-page-side">
        <h3>주문 요약</h3>
        <div class="cart-page-summary">
            <span>상품 개수</span>
            <strong><span id="cartPageCountSide">${sessionScope.cartCount}</span>개</strong>
        </div>
        <button type="button" class="cart-page-go" onclick="alert('결제 기능은 추후 추가 예정입니다.')">주문하기(준비중)</button>
    </aside>
</section>

<script>
    function updateCartPageCounter() {
        var count = document.querySelectorAll('#cartPageList .cart-page-item').length;
        var top = document.getElementById('cartPageCount');
        var side = document.getElementById('cartPageCountSide');
        if (top) top.textContent = count;
        if (side) side.textContent = count;

        if (count === 0 && !document.getElementById('cartPageEmpty')) {
            var list = document.getElementById('cartPageList');
            list.innerHTML = '<div class="cart-page-empty" id="cartPageEmpty"><div>🛒</div><p>장바구니가 비어있어요</p><span>제품 페이지에서 담기를 눌러 추가해보세요.</span></div>';
        }
    }

    function removeCartFromPage(cartId) {
        removeCart(cartId);
        setTimeout(updateCartPageCounter, 250);
    }
</script>
