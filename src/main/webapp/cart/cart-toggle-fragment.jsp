<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    =============================================
    장바구니 토글 공통 조각
    사용법: 팀원 JSP 파일 </body> 바로 위에 붙여넣기
    <%@ include file="/views/common/cart-toggle-fragment.jsp" %>
    =============================================
--%>

<%-- 플로팅 버튼 --%>
<div class="float-cart" id="floatCart" onclick="toggleCart()">
    <span class="float-icon">🛒</span>
    <c:if test="${not empty sessionScope.cartCount and sessionScope.cartCount > 0}">
        <div class="float-badge">${sessionScope.cartCount}</div>
    </c:if>
</div>

<%-- 장바구니 슬라이드 패널 --%>
<div class="cart-panel" id="cartPanel">
    <div class="cp-header">
        <div class="cp-title">
            장바구니
            <span class="cp-count" id="cpCount">
                <c:choose>
                    <c:when test="${not empty sessionScope.cartCount}">${sessionScope.cartCount}</c:when>
                    <c:otherwise>0</c:otherwise>
                </c:choose>
            </span>
        </div>
        <button class="cp-close" onclick="toggleCart()">✕</button>
    </div>

    <div class="cp-body" id="cpBody">
        <%-- JS가 채워줌 --%>
        <div class="cp-loading">불러오는 중...</div>
    </div>

    <div class="cp-footer" id="cpFooter">
        <c:choose>
            <c:when test="${empty sessionScope.loginUser}">
                <div class="cp-note">
                    로그인하면 장바구니가 저장돼요
                    <a href="user-Login" style="color:#2563eb;font-weight:700;">로그인</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="cp-note">결제 기능은 추후 추가 예정입니다</div>
            </c:otherwise>
        </c:choose>
        <a href="cart" class="cp-btn">장바구니 전체보기</a>
    </div>
</div>

<%-- 토글 스타일 --%>
<style>
.float-cart {
    position: fixed;
    right: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 46px;
    background: #fff;
    border: 1px solid #e5e7eb;
    border-right: none;
    border-radius: 10px 0 0 10px;
    box-shadow: -3px 0 16px rgba(0,0,0,.08);
    cursor: pointer;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 12px 0;
    gap: 5px;
    z-index: 500;
    transition: right .3s, background .2s;
}
.float-cart:hover  { background: #eff6ff; }
.float-cart.open   { right: 300px; background: #eff6ff; }
.float-icon  { font-size: 20px; line-height: 1; }
.float-badge {
    background: #f97316;
    color: #fff;
    border-radius: 999px;
    font-size: 10px;
    font-weight: 900;
    min-width: 16px;
    height: 16px;
    padding: 0 4px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.cart-panel {
    position: fixed;
    right: -300px;
    top: 0;
    width: 300px;
    height: 100vh;
    background: #fff;
    border-left: 1px solid #e5e7eb;
    box-shadow: -4px 0 20px rgba(0,0,0,.1);
    z-index: 499;
    display: flex;
    flex-direction: column;
    transition: right .3s;
    font-family: 'Noto Sans KR', sans-serif;
}
.cart-panel.open { right: 0; }

.cp-header {
    padding: 16px 18px;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.cp-title  { font-size: 15px; font-weight: 700; display: flex; align-items: center; gap: 7px; }
.cp-count  { background: #2563eb; color: #fff; border-radius: 999px; font-size: 11px; font-weight: 700; padding: 2px 9px; }
.cp-close  { background: none; border: none; font-size: 18px; color: #ccc; cursor: pointer; }

.cp-body   { flex: 1; overflow-y: auto; padding: 12px 18px; }
.cp-loading{ text-align: center; padding: 30px; color: #9ca3af; font-size: 13px; }

.cp-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 0;
    border-bottom: 1px solid #f3f4f6;
}
.cp-item-img  { width: 38px; height: 38px; border-radius: 8px; background: #eff6ff; display: flex; align-items: center; justify-content: center; font-size: 18px; flex-shrink: 0; }
.cp-item-info { flex: 1; min-width: 0; }
.cp-item-name { font-size: 13px; font-weight: 700; color: #1a1a1a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.cp-item-brand{ font-size: 11px; color: #9ca3af; margin-top: 2px; }
.cp-item-del  { background: none; border: none; font-size: 14px; color: #ddd; cursor: pointer; flex-shrink: 0; }
.cp-item-del:hover { color: #f97316; }

.cp-empty { text-align: center; padding: 50px 20px; color: #9ca3af; }
.cp-empty-icon { font-size: 40px; display: block; margin-bottom: 10px; }

.cp-footer { padding: 14px 18px; border-top: 1px solid #e5e7eb; }
.cp-note   { font-size: 11px; color: #aaa; text-align: center; margin-bottom: 10px; }
.cp-btn    {
    display: block; text-align: center;
    background: #2563eb; color: #fff;
    border-radius: 8px; padding: 11px;
    font-size: 13px; font-weight: 700;
    text-decoration: none;
    transition: background .2s;
}
.cp-btn:hover { background: #1d4ed8; }

/* 모바일: 패널 전체 너비 */
@media (max-width: 768px) {
    .float-cart { top: auto; bottom: 70px; transform: none; }
    .float-cart.open { right: 0; }
    .cart-panel { width: 100%; right: -100%; }
    .cart-panel.open { right: 0; }
}
</style>

<%-- 장바구니 토글 스크립트 --%>
<script>
/* ── 로그인 여부 (JSP → JS) ── */
var IS_LOGIN = ${not empty sessionScope.loginUser};
var LOCAL_CART_KEY = 'yakjaengi_cart';

/* ── 토글 열기/닫기 ── */
function toggleCart() {
    var panel  = document.getElementById('cartPanel');
    var btn    = document.getElementById('floatCart');
    var isOpen = panel.classList.toggle('open');
    btn.classList.toggle('open', isOpen);

    /* 모바일 아닐 때만 본문 밀기 */
    if (window.innerWidth > 768) {
        var body = document.getElementById('siteBody');
        if (body) body.style.marginRight = isOpen ? '300px' : '0';
    }

    /* 패널 열릴 때 목록 로드 */
    if (isOpen) loadCartPanel();
}

/* ── 패널 목록 렌더링 ── */
function loadCartPanel() {
    if (IS_LOGIN) {
        /* 회원: 서버에서 가져오기 */
        fetch('cart/list')
            .then(function(r){ return r.json(); })
            .then(function(data){
                if (data.success) renderCartItems(data.list, data.count);
            })
            .catch(function(){ renderCartEmpty(); });
    } else {
        /* 비회원: 로컬스토리지 */
        var items = getLocalCart();
        renderCartItems(items, items.length);
    }
}

/* ── 아이템 렌더링 ── */
function renderCartItems(items, count) {
    var body  = document.getElementById('cpBody');
    var badge = document.querySelector('.float-badge');
    var cpCnt = document.getElementById('cpCount');

    if (cpCnt) cpCnt.textContent = count;
    if (badge) { badge.textContent = count; badge.style.display = count > 0 ? 'flex' : 'none'; }

    if (!items || items.length === 0) {
        renderCartEmpty();
        return;
    }
    body.innerHTML = items.map(function(item) {
        return '<div class="cp-item" data-cart-id="' + (item.favoriteId || item.cartId) + '">'
             +   '<div class="cp-item-img">💊</div>'
             +   '<div class="cp-item-info">'
             +     '<div class="cp-item-name">' + (item.productName) + '</div>'
             +     '<div class="cp-item-brand">' + (item.productBrand || item.brand || '') + '</div>'
             +   '</div>'
             +   '<button class="cp-item-del" onclick="removeCartItem(' + (item.favoriteId || item.cartId) + ')">✕</button>'
             + '</div>';
    }).join('');
}

function renderCartEmpty() {
    document.getElementById('cpBody').innerHTML =
        '<div class="cp-empty"><span class="cp-empty-icon">🛒</span><p>장바구니가 비어있어요</p></div>';
}

/* ── 담기 (비동기) ── */
function addCart(productId, productName, brand) {
    if (IS_LOGIN) {
        fetch('cart/add', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({productId: productId, productName: productName, brand: brand})
        })
        .then(function(r){ return r.json(); })
        .then(function(data){
            showCartToast(data.message);
            if (data.success) updateCartBadge(data.cartCount);
        });
    } else {
        /* 비회원: 로컬스토리지 */
        var items  = getLocalCart();
        var exists = items.find(function(i){ return i.productId == productId; });
        if (exists) { showCartToast('이미 담긴 제품이에요'); return; }
        items.push({ cartId: Date.now(), productId: productId, productName: productName, brand: brand });
        localStorage.setItem(LOCAL_CART_KEY, JSON.stringify(items));
        updateCartBadge(items.length);
        showCartToast('장바구니에 담았어요 🛒');
    }
}

/* ── 빼기 ── */
function removeCartItem(cartId) {
    if (IS_LOGIN) {
        fetch('cart/remove', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({cartId: cartId})
        })
        .then(function(r){ return r.json(); })
        .then(function(data){
            if (data.success) {
                removeItemDOM(cartId);
                updateCartBadge(data.cartCount);
            }
        });
    } else {
        var items = getLocalCart().filter(function(i){ return i.cartId != cartId; });
        localStorage.setItem(LOCAL_CART_KEY, JSON.stringify(items));
        removeItemDOM(cartId);
        updateCartBadge(items.length);
        if (items.length === 0) renderCartEmpty();
    }
}

function removeItemDOM(cartId) {
    var el = document.querySelector('[data-cart-id="' + cartId + '"]');
    if (el) { el.style.opacity = '0'; setTimeout(function(){ el.remove(); }, 200); }
}

/* ── 배지 업데이트 ── */
function updateCartBadge(count) {
    document.querySelectorAll('.float-badge, .nav-badge').forEach(function(b){
        b.textContent   = count;
        b.style.display = count > 0 ? 'flex' : 'none';
    });
    var cpCnt = document.getElementById('cpCount');
    if (cpCnt) cpCnt.textContent = count;
}

/* ── 로컬스토리지 헬퍼 ── */
function getLocalCart() {
    try { return JSON.parse(localStorage.getItem(LOCAL_CART_KEY)) || []; }
    catch(e) { return []; }
}

/* ── 토스트 알림 ── */
function showCartToast(msg) {
    var t = document.getElementById('toast');
    if (!t) {
        t = document.createElement('div');
        t.id = 'toast';
        t.style.cssText = 'position:fixed;bottom:80px;left:50%;transform:translateX(-50%) translateY(20px);'
                        + 'background:#1a1a1a;color:#fff;font-size:13px;font-weight:700;'
                        + 'padding:10px 20px;border-radius:999px;opacity:0;transition:opacity .3s,transform .3s;'
                        + 'z-index:9999;white-space:nowrap;font-family:Noto Sans KR,sans-serif;';
        document.body.appendChild(t);
    }
    t.textContent = msg;
    setTimeout(function(){ t.style.opacity='1'; t.style.transform='translateX(-50%) translateY(0)'; }, 10);
    setTimeout(function(){ t.style.opacity='0'; t.style.transform='translateX(-50%) translateY(20px)'; }, 2500);
}

/* ── 바깥 클릭 시 닫기 ── */
document.addEventListener('click', function(e) {
    var panel = document.getElementById('cartPanel');
    var btn   = document.getElementById('floatCart');
    var nav   = document.querySelector('.nav-cart');
    if (!panel || !panel.classList.contains('open')) return;
    if (!panel.contains(e.target) && !btn.contains(e.target) && (!nav || !nav.contains(e.target))) {
        panel.classList.remove('open');
        btn.classList.remove('open');
        var body = document.getElementById('siteBody');
        if (body) body.style.marginRight = '0';
    }
});

/* ── 페이지 로드 시 배지 복원 ── */
document.addEventListener('DOMContentLoaded', function() {
    if (!IS_LOGIN) {
        var count = getLocalCart().length;
        if (count > 0) updateCartBadge(count);
    }
});
</script>
