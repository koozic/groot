/* ================================================
   약쟁이 - app.js
   비동기(AJAX) + 로컬스토리지 장바구니 처리
   ================================================ */

const isLogin = typeof IS_LOGIN !== 'undefined' && IS_LOGIN;

/* ── 로컬스토리지 장바구니 (비회원) ── */
const LOCAL_CART_KEY = 'yakjaengi_cart';
const LOCAL_WISH_KEY = 'yakjaengi_wish';

const LocalCart = {
    getAll() {
        try { return JSON.parse(localStorage.getItem(LOCAL_CART_KEY)) || []; }
        catch { return []; }
    },
    save(items) { localStorage.setItem(LOCAL_CART_KEY, JSON.stringify(items)); },
    add(product) {
        const items  = this.getAll();
        const exists = items.find(i => i.productId === product.productId);
        if (exists) { showToast('이미 담긴 제품이에요', 'info'); return false; }
        items.push({ cartId: Date.now(), productId: product.productId,
            productName: product.productName, brand: product.brand,
            icon: product.icon || '💊' });
        this.save(items); return true;
    },
    remove(cartId) { this.save(this.getAll().filter(i => i.cartId !== cartId)); },
    count()        { return this.getAll().length; },
    clear()        { localStorage.removeItem(LOCAL_CART_KEY); }
};

/* ── 장바구니 담기 ── */
function addCart(productId, productName, brand, icon = '💊') {
    if (isLogin) {
        fetch('cart/add', { method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({productId, productName, brand}) })
            .then(r => r.json())
            .then(d => {
                if (d.success) { updateCartBadge(d.cartCount); showToast('장바구니에 담았어요 🛒'); }
                else showToast(d.message || '오류', 'error');
            }).catch(() => showToast('서버 연결 실패', 'error'));
    } else {
        if (LocalCart.add({productId, productName, brand, icon})) {
            updateCartBadge(LocalCart.count());
            renderLocalCartPanel();
            showToast('장바구니에 담았어요 🛒');
        }
    }
}

/* ── 장바구니 삭제 ── */
function removeCart(cartId) {
    if (isLogin) {
        fetch('cart/remove', { method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({cartId}) })
            .then(r => r.json())
            .then(d => { if (d.success) { removeCartItemDOM(cartId); updateCartBadge(d.cartCount); } });
    } else {
        LocalCart.remove(cartId);
        removeCartItemDOM(cartId);
        updateCartBadge(LocalCart.count());
        if (LocalCart.count() === 0) renderLocalCartPanel();
    }
}

function removeCartItemDOM(cartId) {
    const el = document.querySelector(`[data-cart-id="${cartId}"]`);
    if (el) { el.style.transition='opacity .2s,transform .2s';
        el.style.opacity='0'; el.style.transform='translateX(20px)';
        setTimeout(() => el.remove(), 200); }
}

/* ── 비회원 패널 렌더링 ── */
function renderLocalCartPanel() {
    const body  = document.querySelector('.cp-body');
    const count = document.querySelector('.cp-count');
    if (!body) return;
    const items = LocalCart.getAll();
    if (count) count.textContent = items.length;

    if (items.length === 0) {
        body.innerHTML = `<div class="cp-empty">
            <span class="cp-empty-icon">🛒</span>
            <p>장바구니가 비어있어요</p>
            <span>마음에 드는 제품을 담아보세요!</span></div>`;
    } else {
        body.innerHTML = items.map(i => `
            <div class="cart-item" data-cart-id="${i.cartId}">
                <div class="ci-icon" style="background:#eff6ff;">${i.icon}</div>
                <div class="ci-info">
                    <div class="ci-name">${i.productName}</div>
                    <div class="ci-sub">${i.brand}</div>
                </div>
                <button class="ci-del" onclick="removeCart(${i.cartId})">✕</button>
            </div>`).join('');
    }
    const footer = document.querySelector('.cp-footer');
    if (footer) footer.innerHTML = `
        <div class="cp-note">로그인하면 장바구니가 저장돼요
            <a href="login" style="color:#2563eb;font-weight:700;">로그인</a>
        </div>
        <a href="cart" class="btn btn-primary btn-full">장바구니 전체보기</a>`;
}

/* ── 배지 업데이트 ── */
function updateCartBadge(count) {
    document.querySelectorAll('.nav-badge,.float-badge').forEach(b => {
        b.textContent = count; b.style.display = count > 0 ? 'flex' : 'none';
    });
}

/* ── 찜 버튼 ── */
function toggleWish(btn, productId) {
    const isWished = btn.classList.contains('wished');
    if (isLogin) {
        fetch('wish/toggle', { method:'POST',
            headers:{'Content-Type':'application/json'},
            body: JSON.stringify({productId, action: isWished ? 'remove':'add'}) })
            .then(r => r.json())
            .then(d => {
                if (d.success) {
                    btn.classList.toggle('wished', !isWished);
                    btn.textContent = isWished ? '🤍' : '❤️';
                    showToast(isWished ? '찜 해제했어요' : '찜했어요 ❤️');
                }
            });
    } else {
        try {
            const wishes = JSON.parse(localStorage.getItem(LOCAL_WISH_KEY)) || [];
            const idx    = wishes.indexOf(productId);
            if (idx > -1) { wishes.splice(idx,1); btn.classList.remove('wished'); btn.textContent='🤍'; showToast('찜 해제했어요'); }
            else           { wishes.push(productId); btn.classList.add('wished');   btn.textContent='❤️'; showToast('찜했어요 ❤️'); }
            localStorage.setItem(LOCAL_WISH_KEY, JSON.stringify(wishes));
        } catch { showToast('오류가 발생했어요','error'); }
    }
}

function restoreWishState() {
    if (isLogin) return;
    try {
        const wishes = JSON.parse(localStorage.getItem(LOCAL_WISH_KEY)) || [];
        document.querySelectorAll('[data-product-id]').forEach(btn => {
            if (wishes.includes(btn.dataset.productId)) {
                btn.classList.add('wished'); btn.textContent = '❤️';
            }
        });
    } catch {}
}

/* ── 영양제 분석 ── */
function analyzeSupplements(type = 'my') {
    const checked = Array.from(document.querySelectorAll('input[name="supp"]:checked')).map(e => e.value);
    if (checked.length === 0) { showAnalysisError('영양제를 하나 이상 선택해주세요 💊'); return; }
    showAnalysisLoading();
    fetch('recommend/analyze', { method:'post',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({supplements: checked, type}) })
        .then(r => r.json())
        .then(d => {
            if (d.success) { showAnalysisResult(d); if (!isLogin) appendLoginNudge(); }
            else showAnalysisError(d.message || '분석 오류');
        }).catch(() => showAnalysisError('서버 연결에 실패했어요'));
}

function showAnalysisLoading() {
    const box = document.getElementById('analysisResult');
    if (!box) return;
    box.style.display = 'block';
    box.innerHTML = `<div class="analysis-loading"><div class="loading-spinner"></div><p>분석 중이에요...</p></div>`;
    box.scrollIntoView({behavior:'smooth', block:'nearest'});
}

function showAnalysisResult(data) {
    const box = document.getElementById('analysisResult');
    if (!box) return;
    const mk = (items, cls, icon, title, tpl) =>
        items && items.length ? `<div class="result-section"><div class="result-title">${icon} ${title}</div>
            ${items.map(tpl).join('')}</div>` : '';

    box.innerHTML = `<div class="analysis-result">
        ${mk(data.missing,       'result-missing', '⚠️', '부족할 수 있는 영양소',
        m => `<div class="result-item result-missing"><span class="result-icon">${m.icon}</span>
                  <div class="result-info"><strong>${m.name}</strong><span>${m.reason}</span></div></div>`)}
        ${mk(data.goodCombo,     'result-good',    '💚', '좋은 조합',
        g => `<div class="result-item result-good"><span class="result-icon">✅</span>
                  <div class="result-info"><strong>${g.combo}</strong><span>${g.effect}</span></div></div>`)}
        ${mk(data.compatibility, 'result-compat',  '🔄', '상성 분석',
        c => `<div class="result-item ${c.status==='bad'?'result-missing':'result-good'}">
                  <span class="result-icon">${c.status==='bad'?'⚠️':'💚'}</span>
                  <div class="result-info"><strong>${c.suppA} + ${c.suppB}</strong><span>${c.reason}</span></div></div>`)}
        ${mk(data.timing,        'result-time',    '⏰', '복용 시간 추천',
        t => `<div class="result-item result-time"><span class="result-icon">${t.icon}</span>
                  <div class="result-info"><strong>${t.name}</strong><span>${t.when}</span></div></div>`)}
        <a href="recommend" class="btn btn-primary btn-full" style="margin-top:16px;">자세한 분석 보기 →</a>
    </div>`;
    box.scrollIntoView({behavior:'smooth', block:'nearest'});
}

function appendLoginNudge() {
    const result = document.querySelector('.analysis-result');
    if (!result) return;
    const nudge = document.createElement('div');
    nudge.className = 'login-nudge';
    nudge.innerHTML = `<span>🔑</span>
        <div><strong>로그인하면 분석 기록이 저장돼요!</strong>
             <span>나의 영양제 히스토리를 관리해보세요</span></div>
        <a href="login" class="btn btn-outline" style="padding:8px 16px;font-size:13px;">로그인</a>`;
    result.appendChild(nudge);
}

function showAnalysisError(msg) {
    const box = document.getElementById('analysisResult');
    if (!box) return;
    box.style.display = 'block';
    box.innerHTML = `<div class="analysis-error"><span>⚠️</span><p>${msg}</p></div>`;
}

/* ── 장바구니 패널 토글 ── */
function toggleCart() {
    const panel = document.getElementById('cartPanel');
    const float = document.getElementById('floatCart');
    const body  = document.getElementById('siteBody');
    const open  = panel.classList.toggle('open');
    float.classList.toggle('open', open);
    if (window.innerWidth > 768) body.classList.toggle('shifted', open);
    if (open && !isLogin) renderLocalCartPanel();
}

document.addEventListener('click', function(e) {
    const panel = document.getElementById('cartPanel');
    const float = document.getElementById('floatCart');
    const nav   = document.querySelector('.nav-cart');
    if (!panel || !float) return;
    if (panel.classList.contains('open') &&
        !panel.contains(e.target) && !float.contains(e.target) &&
        nav && !nav.contains(e.target)) {
        panel.classList.remove('open'); float.classList.remove('open');
        const body = document.getElementById('siteBody');
        if (body) body.classList.remove('shifted');
    }
});

/* ── 토스트 ── */
function showToast(msg, type = 'success') {
    const old = document.getElementById('toast');
    if (old) old.remove();
    const t = document.createElement('div');
    t.id = 'toast'; t.className = `toast toast-${type}`; t.textContent = msg;
    document.body.appendChild(t);
    requestAnimationFrame(() => t.classList.add('show'));
    setTimeout(() => { t.classList.remove('show'); setTimeout(() => t.remove(), 300); }, 2500);
}

/* ── 초기화 ── */
document.addEventListener('DOMContentLoaded', () => {
    if (!isLogin) {
        const count = LocalCart.count();
        if (count > 0) updateCartBadge(count);
        restoreWishState();
    }
});
