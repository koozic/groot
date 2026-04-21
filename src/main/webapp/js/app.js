/* ================================================
   약쟁이 - app.js
   비동기(AJAX) + 로컬스토리지 장바구니 처리
   ================================================ */

const isLogin = (typeof IS_LOGIN !== 'undefined' && IS_LOGIN === true);
console.log("현재 로그인 상태:", isLogin); // 디버깅용: F12 콘솔에서 확인 가능

/* ── 중복 제출 방지 ── */
const submitLockState = new WeakMap();

function readActionControlText(control) {
    if (!control) return '';
    if (control.tagName === 'INPUT') return control.value || '';
    return control.textContent || '';
}

function writeActionControlText(control, text) {
    if (!control) return;
    if (control.tagName === 'INPUT') {
        control.value = text;
        return;
    }
    control.textContent = text;
}

function buildPendingText(control, fallback = '처리 중...') {
    const customText = control?.dataset?.pendingText?.trim();
    if (customText) return customText;

    const baseText = readActionControlText(control).trim();
    if (!baseText) return fallback;
    if (baseText.endsWith('중...')) return baseText;
    if (baseText.includes('가입')) return '가입 중...';
    if (baseText.includes('등록')) return '등록 중...';
    if (baseText.includes('수정')) return '수정 중...';
    if (baseText.includes('저장')) return '저장 중...';
    if (baseText.includes('추가') || baseText.includes('+')) return '추가 중...';
    if (baseText.includes('삭제')) return '삭제 중...';
    return fallback;
}

function lockActionControl(control, options = {}) {
    if (!control || control.dataset.grootPending === 'true') return false;

    submitLockState.set(control, {
        disabled: typeof control.disabled === 'boolean' ? control.disabled : null,
        text: readActionControlText(control),
        pointerEvents: control.style.pointerEvents,
        opacity: control.style.opacity,
        cursor: control.style.cursor,
        ariaDisabled: control.getAttribute('aria-disabled'),
        ariaBusy: control.getAttribute('aria-busy')
    });

    control.dataset.grootPending = 'true';
    if (typeof control.disabled === 'boolean') {
        control.disabled = true;
    }
    control.style.pointerEvents = 'none';
    control.style.opacity = '0.7';
    control.style.cursor = 'wait';
    control.setAttribute('aria-disabled', 'true');
    control.setAttribute('aria-busy', 'true');

    if (control.tagName === 'BUTTON' || control.tagName === 'INPUT') {
        writeActionControlText(control, options.pendingText || buildPendingText(control, options.fallbackText));
    }

    return true;
}

function unlockActionControl(control) {
    if (!control) return;

    const snapshot = submitLockState.get(control);
    if (!snapshot) {
        delete control.dataset.grootPending;
        return;
    }

    if (snapshot.disabled !== null) {
        control.disabled = snapshot.disabled;
    }
    if (control.tagName === 'BUTTON' || control.tagName === 'INPUT') {
        writeActionControlText(control, snapshot.text);
    }

    control.style.pointerEvents = snapshot.pointerEvents;
    control.style.opacity = snapshot.opacity;
    control.style.cursor = snapshot.cursor;

    if (snapshot.ariaDisabled === null) control.removeAttribute('aria-disabled');
    else control.setAttribute('aria-disabled', snapshot.ariaDisabled);

    if (snapshot.ariaBusy === null) control.removeAttribute('aria-busy');
    else control.setAttribute('aria-busy', snapshot.ariaBusy);

    delete control.dataset.grootPending;
    submitLockState.delete(control);
}

function getFormSubmitControls(form, submitter) {
    const controls = Array.from(form.querySelectorAll('button[type="submit"], input[type="submit"]'));
    if (submitter && !controls.includes(submitter)) {
        controls.push(submitter);
    }
    return controls;
}

function lockFormSubmission(form, submitter) {
    if (!form || form.dataset.grootSubmitting === 'true') return false;

    form.dataset.grootSubmitting = 'true';
    form.setAttribute('aria-busy', 'true');

    getFormSubmitControls(form, submitter).forEach(control => {
        lockActionControl(control);
    });

    return true;
}

function unlockFormSubmission(form) {
    if (!form) return;

    getFormSubmitControls(form).forEach(control => unlockActionControl(control));
    delete form.dataset.grootSubmitting;
    form.removeAttribute('aria-busy');
}

function runWithActionLock(control, action, options = {}) {
    const target = control?.currentTarget || control;
    if (target?.dataset?.grootPending === 'true') {
        return Promise.resolve(false);
    }

    if (target) {
        lockActionControl(target, {pendingText: options.pendingText, fallbackText: options.fallbackText});
    }

    let result;
    try {
        result = action();
    } catch (error) {
        if (target) unlockActionControl(target);
        throw error;
    }

    return Promise.resolve(result)
        .then(value => {
            if (target && !options.keepLocked) unlockActionControl(target);
            return value;
        })
        .catch(error => {
            if (target) unlockActionControl(target);
            throw error;
        });
}

window.GrootSubmitGuard = {
    lockActionControl,
    unlockActionControl,
    lockFormSubmission,
    unlockFormSubmission,
    runWithActionLock
};

document.addEventListener('submit', function (event) {
    const form = event.target;
    if (!(form instanceof HTMLFormElement)) return;
    if ((form.method || 'get').toLowerCase() !== 'post') return;
    if (form.dataset.allowRepeatSubmit === 'true') return;

    if (form.dataset.grootSubmitting === 'true') {
        event.preventDefault();
        return;
    }

    if (event.defaultPrevented) return;

    const submitter = event.submitter || form.querySelector('button[type="submit"], input[type="submit"]');
    lockFormSubmission(form, submitter);
});

/* ── 로컬스토리지 장바구니 (비회원) ── */
const LOCAL_CART_KEY = 'yakjaengi_cart';
const LOCAL_WISH_KEY = 'yakjaengi_wish';

const LocalCart = {
    getAll() {
        try {
            return JSON.parse(localStorage.getItem(LOCAL_CART_KEY)) || [];
        } catch {
            return [];
        }
    },
    save(items) {
        localStorage.setItem(LOCAL_CART_KEY, JSON.stringify(items));
    },
    add(product) {
        const items = this.getAll();
        const exists = items.find(i => i.productId === product.productId);
        if (exists) {
            showToast('이미 담긴 제품이에요', 'info');
            return false;
        }
        items.push({
            cartId: Date.now(), productId: product.productId,
            productName: product.productName, brand: product.brand,
            icon: product.icon || '💊'
        });
        this.save(items);
        return true;
    },
    remove(cartId) {
        this.save(this.getAll().filter(i => i.cartId !== cartId));
    },
    count() {
        return this.getAll().length;
    },
    clear() {
        localStorage.removeItem(LOCAL_CART_KEY);
    }
};

/* ── 장바구니 담기 ── */
function addCart(productId, productName, brand, icon = '💊') {
    if (isLogin) {
        fetch('cart/add', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({productId, productName, brand})
        })
            .then(r => r.json())
            .then(d => {
                if (d.success) {
                    updateCartBadge(d.cartCount);
                    if (document.getElementById('cartPanel')?.classList.contains('open')) {
                        loadServerCartPanel();
                    }
                    showToast('장바구니에 담았어요 🛒');
                } else showToast(d.message || '오류', 'error');
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
        fetch('cart/remove', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({cartId})
        })
            .then(r => r.json())
            .then(d => {
                if (d.success) {
                    removeCartItemDOM(cartId);
                    updateCartBadge(d.cartCount);
                    if (document.getElementById('cartPanel')?.classList.contains('open')) {
                        loadServerCartPanel();
                    }
                }
            });
    } else {
        LocalCart.remove(cartId);
        removeCartItemDOM(cartId);
        updateCartBadge(LocalCart.count());
        if (LocalCart.count() === 0) renderLocalCartPanel();
    }
}

function removeCartItemDOM(cartId) {
    const el = document.querySelector(`[data-cart-id="${cartId}"]`);
    if (el) {
        el.style.transition = 'opacity .2s,transform .2s';
        el.style.opacity = '0';
        el.style.transform = 'translateX(20px)';
        setTimeout(() => el.remove(), 200);
    }
}

/* ── 비회원 패널 렌더링 ── */
function renderLocalCartPanel() {
    const body = document.querySelector('.cp-body');
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
            <a href="user-Login" style="color:#2563eb;font-weight:700;">로그인</a>
        </div>
        <a href="cart" class="btn btn-primary btn-full">장바구니 전체보기</a>`;
}

/* ── 배지 업데이트 ── */
function updateCartBadge(count) {
    ensureCartBadges();
    document.querySelectorAll('.nav-badge,.float-badge').forEach(b => {
        b.textContent = count;
        b.style.display = count > 0 ? 'flex' : 'none';
    });
    const panelCount = document.querySelector('.cp-count');
    if (panelCount) panelCount.textContent = String(count);
}

function ensureCartBadges() {
    const navCart = document.querySelector('.nav-cart');
    if (navCart && !navCart.querySelector('.nav-badge')) {
        const badge = document.createElement('div');
        badge.className = 'nav-badge';
        badge.style.display = 'none';
        navCart.appendChild(badge);
    }

    const floatCart = document.getElementById('floatCart');
    if (floatCart && !floatCart.querySelector('.float-badge')) {
        const badge = document.createElement('div');
        badge.className = 'float-badge';
        badge.style.display = 'none';
        floatCart.appendChild(badge);
    }
}

/* ── 찜 버튼 ── */
function toggleWish(btn, productId) {
    const isWished = btn.classList.contains('wished');
    if (isLogin) {
        fetch('wish/toggle', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({productId, action: isWished ? 'remove' : 'add'})
        })
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
            const idx = wishes.indexOf(productId);
            if (idx > -1) {
                wishes.splice(idx, 1);
                btn.classList.remove('wished');
                btn.textContent = '🤍';
                showToast('찜 해제했어요');
            } else {
                wishes.push(productId);
                btn.classList.add('wished');
                btn.textContent = '❤️';
                showToast('찜했어요 ❤️');
            }
            localStorage.setItem(LOCAL_WISH_KEY, JSON.stringify(wishes));
        } catch {
            showToast('오류가 발생했어요', 'error');
        }
    }
}

function restoreWishState() {
    if (isLogin) return;
    try {
        const wishes = JSON.parse(localStorage.getItem(LOCAL_WISH_KEY)) || [];
        document.querySelectorAll('[data-product-id]').forEach(btn => {
            if (wishes.includes(btn.dataset.productId)) {
                btn.classList.add('wished');
                btn.textContent = '❤️';
            }
        });
    } catch {
    }
}

/* ── 영양제 분석 ── */
window.latestAnalysisData = null;
window.currentResultTab = 'good';
window.analysisCompleted = false;

function analyzeSupplements(type = 'my') {
    const checked = Array.from(document.querySelectorAll('input[name="supp"]:checked')).map(e => e.value);
    if (checked.length === 0) {
        showAnalysisError('영양제를 하나 이상 선택해주세요 💊');
        return;
    }
    showAnalysisLoading();
    fetch('recommend/analyze', {
        method: 'post',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({supplements: checked, type})
    })
        .then(r => r.json())
        .then(d => {
            if (d.success) {
                window.latestAnalysisData = d;
                window.analysisCompleted = true;
                showAnalysisResult(d);
                if (!isLogin) appendLoginNudge();
                if (typeof window.onAnalysisRendered === 'function') {
                    window.onAnalysisRendered(d);
                }
            } else showAnalysisError(d.message || '분석 오류');
        }).catch(() => showAnalysisError('서버 연결에 실패했어요'));
}

function showAnalysisLoading() {
    const box = document.getElementById('analysisResult');
    const reviewSection = document.getElementById('bestReviewsSection');
    if (!box) return;
    window.analysisCompleted = false;
    box.style.display = 'block';
    box.innerHTML = `<div class="analysis-loading"><div class="loading-spinner"></div><p>분석 중이에요...</p></div>`;
    if (reviewSection) reviewSection.style.display = 'none';
    box.scrollIntoView({behavior: 'smooth', block: 'nearest'});
}

function renderResultList(items, template, emptyText) {
    if (!items || items.length === 0) {
        return `<div class="result-empty">${emptyText}</div>`;
    }
    return `<div class="result-list">${items.map(template).join('')}</div>`;
}

function renderResultBlock(title, description, content) {
    return `<div class="result-block">
        <div class="result-block-head">
            <strong>${title}</strong>
            <span>${description}</span>
        </div>
        ${content}
    </div>`;
}

function setResultTab(tabName, shouldRefresh = true) {
    window.currentResultTab = tabName;

    document.querySelectorAll('.result-tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabName);
    });

    document.querySelectorAll('.result-panel').forEach(panel => {
        panel.classList.toggle('active', panel.dataset.panel === tabName);
    });

    if (shouldRefresh && window.analysisCompleted && typeof window.refreshReviewSection === 'function') {
        window.refreshReviewSection();
    }
}

function showAnalysisResult(data) {
    const box = document.getElementById('analysisResult');
    if (!box) return;

    const checkedNames = Array.from(document.querySelectorAll('input[name="supp"]:checked'))
        .map(input => input.dataset.reviewKey)
        .filter(Boolean);
    const goodCombos = Array.isArray(data.goodCombo) ? data.goodCombo : [];
    const recommendedSupps = Array.isArray(data.missing) ? data.missing : [];
    const timingItems = Array.isArray(data.timing) ? data.timing : [];
    const warningCombos = Array.isArray(data.compatibility)
        ? data.compatibility.filter(item => item.status === 'bad')
        : [];

    const previewNames = checkedNames.slice(0, 4).join(', ');
    const summaryText = checkedNames.length === 0
        ? '선택한 영양제를 기준으로 결과를 정리했어요.'
        : `${previewNames}${checkedNames.length > 4 ? ` 외 ${checkedNames.length - 4}개` : ''} 기준으로 결과를 정리했어요.`;

    box.innerHTML = `<div class="analysis-workspace">
        <div class="analysis-summary-card">
            <div class="analysis-summary-copy">
                <span class="selection-badge">STEP 2</span>
                <strong>${checkedNames.length}개 영양제 분석 완료</strong>
                <p>${summaryText}</p>
            </div>
            <div class="analysis-summary-stats">
                <div class="summary-stat">
                    <span>좋은 조합</span>
                    <strong>${goodCombos.length}</strong>
                </div>
                <div class="summary-stat">
                    <span>추가 추천</span>
                    <strong>${recommendedSupps.length}</strong>
                </div>
                <div class="summary-stat">
                    <span>주의/시간</span>
                    <strong>${warningCombos.length + timingItems.length}</strong>
                </div>
            </div>
        </div>

        <div class="result-tab-bar">
            <button type="button" class="result-tab-btn active" data-tab="good" onclick="setResultTab('good')">
                좋은 조합
                <span>${goodCombos.length}</span>
            </button>
            <button type="button" class="result-tab-btn" data-tab="recommend" onclick="setResultTab('recommend')">
                추가 추천
                <span>${recommendedSupps.length}</span>
            </button>
            <button type="button" class="result-tab-btn" data-tab="caution" onclick="setResultTab('caution')">
                주의/복용시간
                <span>${warningCombos.length + timingItems.length}</span>
            </button>
        </div>

        <div class="result-panels">
            <section class="result-panel active" data-panel="good">
                ${renderResultBlock(
                    '같이 먹으면 좋은 조합',
                    '선택한 영양제 안에서 시너지가 나는 조합만 모아봤어요.',
                    renderResultList(
                        goodCombos,
                        g => `<div class="result-item result-good">
                                <span class="result-icon">✅</span>
                                <div class="result-info">
                                    <strong>${g.combo}</strong>
                                    <span>${g.effect}</span>
                                </div>
                              </div>`,
                        '선택한 영양제끼리 등록된 좋은 조합은 아직 없어요.'
                    )
                )}
            </section>

            <section class="result-panel" data-panel="recommend">
                ${renderResultBlock(
                    '함께 고려하면 좋은 영양제',
                    '현재 선택한 영양제를 기준으로 추가로 보면 좋은 항목이에요.',
                    renderResultList(
                        recommendedSupps,
                        m => `<div class="result-item result-missing">
                                <span class="result-icon">${m.icon}</span>
                                <div class="result-info">
                                    <strong>${m.name}</strong>
                                    <span>${m.reason}</span>
                                </div>
                              </div>`,
                        '추가로 추천할 영양제가 없어요.'
                    )
                )}
            </section>

            <section class="result-panel" data-panel="caution">
                ${renderResultBlock(
                    '같이 먹을 때 주의할 조합',
                    '같은 시간에 함께 먹지 않는 편이 좋은 조합이에요.',
                    renderResultList(
                        warningCombos,
                        c => `<div class="result-item result-caution">
                                <span class="result-icon">⚠️</span>
                                <div class="result-info">
                                    <strong>${c.suppA} + ${c.suppB}</strong>
                                    <span>${c.reason}</span>
                                </div>
                              </div>`,
                        '선택한 영양제끼리 큰 주의 조합은 없어요.'
                    )
                )}
                ${renderResultBlock(
                    '영양제별 복용 시간',
                    '아침, 저녁, 식후 여부처럼 섭취 루틴을 한 번에 볼 수 있어요.',
                    renderResultList(
                        timingItems,
                        t => `<div class="result-item result-time">
                                <span class="result-icon">${t.icon}</span>
                                <div class="result-info">
                                    <strong>${t.name}</strong>
                                    <span>${t.when}</span>
                                </div>
                              </div>`,
                        '복용 시간 정보가 아직 준비되지 않았어요.'
                    )
                )}
            </section>
        </div>

        <div class="analysis-actions">
            <a href="reco" class="btn btn-primary btn-full">다른 영양제 다시 보기 →</a>
        </div>
    </div>`;

    setResultTab('good', false);
    box.scrollIntoView({behavior: 'smooth', block: 'nearest'});
}

function appendLoginNudge() {
    const result = document.querySelector('.analysis-workspace');
    const actions = document.querySelector('.analysis-actions');
    if (!result || result.querySelector('.login-nudge')) return;
    const nudge = document.createElement('div');
    nudge.className = 'login-nudge';
    nudge.innerHTML = `<span>🔑</span>
        <div><strong>로그인하면 분석 기록이 저장돼요!</strong>
             <span>나의 영양제 히스토리를 관리해보세요</span></div>
        <a href="user-Login" class="btn btn-outline" style="padding:8px 16px;font-size:13px;">로그인</a>`;
    if (actions) {
        result.insertBefore(nudge, actions);
    } else {
        result.appendChild(nudge);
    }
}

function showAnalysisError(msg) {
    const box = document.getElementById('analysisResult');
    const reviewSection = document.getElementById('bestReviewsSection');
    if (!box) return;
    window.latestAnalysisData = null;
    window.analysisCompleted = false;
    box.style.display = 'block';
    box.innerHTML = `<div class="analysis-error"><span>⚠️</span><p>${msg}</p></div>`;
    if (reviewSection) reviewSection.style.display = 'none';
}

/* ── 장바구니 패널 토글 ── */
// function toggleCart() {
//     const panel = document.getElementById('cartPanel');
//     const float = document.getElementById('floatCart');
//     const body = document.getElementById('siteBody');
//     const open = panel.classList.toggle('open');
//     float.classList.toggle('open', open);
//     if (window.innerWidth > 768) body.classList.toggle('shifted', open);
//     if (open && !isLogin) renderLocalCartPanel();
// }

document.addEventListener('click', function (e) {
    const panel = document.getElementById('cartPanel');
    const float = document.getElementById('floatCart');
    const nav = document.querySelector('.nav-cart');
    if (!panel || !float) return;
    if (panel.classList.contains('open') &&
        !panel.contains(e.target) && !float.contains(e.target) &&
        nav && !nav.contains(e.target)) {
        panel.classList.remove('open');
        float.classList.remove('open');
        const body = document.getElementById('siteBody');
        if (body) body.classList.remove('shifted');
    }
});

/* ── 토스트 ── */
function showToast(msg, type = 'success') {
    const old = document.getElementById('toast');
    if (old) old.remove();
    const t = document.createElement('div');
    t.id = 'toast';
    t.className = `toast toast-${type}`;
    t.textContent = msg;
    document.body.appendChild(t);
    requestAnimationFrame(() => t.classList.add('show'));
    setTimeout(() => {
        t.classList.remove('show');
        setTimeout(() => t.remove(), 300);
    }, 2500);
}

/* ── 초기화 ── */
document.addEventListener('DOMContentLoaded', () => {
    ensureCartBadges();
    if (!isLogin) {
        updateCartBadge(LocalCart.count());
        restoreWishState();
    } else {
        mergeCartOnLogin().finally(syncServerCartBadge);
    }
});

function syncServerCartBadge() {
    fetch('cart/list')
        .then(r => r.json())
        .then(data => {
            if (data && data.success) updateCartBadge(data.count || 0);
        })
        .catch(() => {});
}
function toggleCart() {
    const panel = document.getElementById('cartPanel');
    const float = document.getElementById('floatCart');
    const body  = document.getElementById('siteBody');
    if (!panel || !float) return;
    const open  = panel.classList.toggle('open');//open있으면 열리고 없으면 닫힌다
    float.classList.toggle('open', open);
    if (window.innerWidth > 768 && body) body.classList.toggle('shifted', open);

    if (open) {
        if (isLogin) loadServerCartPanel(); // ← 이거 추가
        else renderLocalCartPanel();
    }
}

// 로그인 유저 패널 로드
function loadServerCartPanel() {
    fetch('cart/list')
        .then(r => r.json())
        .then(data => {
            const body  = document.querySelector('.cp-body');
            const footer = document.querySelector('.cp-footer');
            const count = document.querySelector('.cp-count');
            if (!body) return;
            if (!data.success) {
                if (count) count.textContent = '0';
                updateCartBadge(0);
                body.innerHTML = `<div class="cp-empty"><span class="cp-empty-icon">🛒</span><p>장바구니가 비어있어요</p></div>`;
                return;
            }
            if (count) count.textContent = data.count;
            updateCartBadge(data.count);
            if (footer) {
                footer.innerHTML = `<div class="cp-note">결제 기능은 추후 추가 예정입니다</div>
                    <a href="cart" class="btn btn-primary btn-full">장바구니 전체보기</a>`;
            }
            if (!data.list || data.list.length === 0) {
                body.innerHTML = `<div class="cp-empty"><span class="cp-empty-icon">🛒</span><p>장바구니가 비어있어요</p></div>`;
                return;
            }
            body.innerHTML = data.list.map(i => `
                <div class="cart-item" data-cart-id="${i.favorite_id}">
                    <div class="ci-icon" style="background:#eff6ff;">💊</div>
                    <div class="ci-info">
                        <div class="ci-name">${i.product_name}</div>
                        <div class="ci-sub">${i.product_brand}</div>
                    </div>
                    <button class="ci-del" onclick="removeCart(${i.favorite_id})">✕</button>
                </div>`).join('');
        });
}
function mergeCartOnLogin() {
    const localItems = LocalCart.getAll();
    if (localItems.length === 0) return Promise.resolve(false);

    return fetch('cart/merge', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ localCart: JSON.stringify(localItems) })
    })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                LocalCart.clear(); // 로컬스토리지 비우기
                updateCartBadge(data.cartCount);
                showToast(data.message);
                if (document.getElementById('cartPanel')?.classList.contains('open')) {
                    loadServerCartPanel();
                }
                return true;
            }
            return false;
        })
        .catch(() => {
            return false;
        });
}
