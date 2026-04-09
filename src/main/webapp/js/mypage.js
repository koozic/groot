/* ── 탭 전환 로직 ── */
function switchTab(id, btn) {
    document.querySelectorAll('.mp-tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.mp-tab').forEach(el => el.classList.remove('active'));

    const targetTab = document.getElementById('tab-' + id);
    if (targetTab) targetTab.classList.add('active');

    if (btn) {
        btn.classList.add('active');
    } else {
        const targetBtn = document.querySelector(".mp-tab[onclick*=\"'" + id + "'\"]");
        if (targetBtn) targetBtn.classList.add('active');
    }
    sessionStorage.setItem('activeTab', id);
}

/* ── 초기화 및 이벤트 바인딩 ── */
document.addEventListener('DOMContentLoaded', function () {
    const isReload = window.performance && window.performance.getEntriesByType("navigation")[0]?.type === "reload";
    if (isReload) {
        const savedTab = sessionStorage.getItem('activeTab');
        if (savedTab) switchTab(savedTab);
    } else {
        sessionStorage.setItem('activeTab', 'info');
        switchTab('info');
    }

    const now = new Date();
    const dateStr = now.getFullYear() + '.' + String(now.getMonth() + 1).padStart(2, '0') + '.' + String(now.getDate()).padStart(2, '0');
    const dateEl = document.getElementById('todayDate');
    if (dateEl) dateEl.textContent = dateStr;

    updateProgress();
    if (typeof renderCalendar === 'function') renderCalendar();

    const confirmBtn = document.getElementById('confirmBtn');
    if (confirmBtn) {
        confirmBtn.onclick = function () {
            if (typeof confirmCallback === 'function') confirmCallback();
            closeConfirm();
        };
    }
});

/* ── 기능 로직 ── */
function updateProgress() {
    const items = document.querySelectorAll('.vit-item');
    const visibleItems = Array.from(items).filter(el => el.style.display !== 'none');
    const total = visibleItems.length;
    const checked = visibleItems.filter(el => el.classList.contains('checked')).length;

    const pct = total > 0 ? Math.round((checked / total) * 100) : 0;
    const fill = document.getElementById('progressFill');
    const text = document.getElementById('progressText');

    if (fill) fill.style.width = pct + '%';
    if (text) text.textContent = checked + ' / ' + total;
}

function addSupplement(productId, element) {
    fetch('mypage/add-product', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'productId=' + productId
    }).then(response => {
        if (response.ok) {
            showToast("리스트에 추가되었습니다.");
            element.style.opacity = '0';
            element.style.transition = '0.3s';
            setTimeout(() => {
                element.remove();
                const list = document.getElementById('modalProductList');
                if (list && list.children.length === 0) {
                    list.innerHTML = '<p style="text-align:center; padding:20px; color:#9ca3af;">모든 제품을 추가했습니다.</p>';
                }
            }, 300);
            window.isDataChanged = true;
        }
    });
}

function toggleCheck(element, productId) {
    let isChecked = element.classList.toggle('checked');
    element.querySelector('.vit-check-box').textContent = isChecked ? '✓' : '';
    updateProgress();

    fetch('mypage/check-intake', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'productId=' + productId + '&isTaken=' + isChecked
    })
        .then(response => response.text())
        .then(text => {
            if (text === 'success') {
                if (typeof renderCalendar === 'function') {
                    renderCalendar();
                }
            }
        })
        .catch(err => console.error("체크 상태 업데이트 실패", err));
}

let deleteTimeout = null;

function removeSupplement(productId, btnElement) {
    const item = btnElement.closest('.vit-item');
    if (!item) return;

    item.style.display = 'none';
    updateProgress();

    showUndoToast("영양제가 삭제되었습니다.", () => {
        clearTimeout(deleteTimeout);
        item.style.display = 'flex';
        updateProgress();
    });

    deleteTimeout = setTimeout(() => {
        fetch('mypage/remove-product', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'productId=' + productId
        }).catch(() => {
            item.style.display = 'flex';
            updateProgress();
            showToast("삭제 실패", "error");
        });
    }, 3000);
}

/* ── UI 유틸리티 ── */
function showToast(message, type = 'success') {
    const container = document.getElementById('toast-container') || createToastContainer();
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `<span>${type === 'success' ? '✅' : '❌'}</span> ${message}`;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

function showUndoToast(message, undoAction) {
    const container = document.getElementById('toast-container') || createToastContainer();
    const toast = document.createElement('div');
    toast.className = 'toast success';
    toast.innerHTML = `<span>${message}</span><button id="undoBtn" style="margin-left:15px; background:none; border:none; color:#93c5fd; font-weight:800; cursor:pointer; text-decoration:underline;">실행 취소</button>`;
    container.appendChild(toast);
    toast.querySelector('#undoBtn').onclick = () => {
        undoAction();
        toast.remove();
    };
    setTimeout(() => {
        if (toast) toast.remove();
    }, 3000);
}

function createToastContainer() {
    const c = document.createElement('div');
    c.id = 'toast-container';
    document.body.appendChild(c);
    return c;
}

function openProductModal() {
    document.getElementById('productModal').style.display = 'block';
}

function closeProductModal() {
    document.getElementById('productModal').style.display = 'none';
}

function closeConfirm() {
    const m = document.getElementById('confirmModal');
    if (m) m.style.display = 'none';
}

function closeAndRefresh() {
    if (window.isDataChanged) {
        sessionStorage.setItem('activeTab', 'check');
        location.reload();
    } else {
        closeProductModal();
    }
}

/* ── 캘린더 및 통계 ── */
var calYear, calMonth;

(function () {
    var now = new Date();
    calYear = now.getFullYear();
    calMonth = now.getMonth();
    // DOMContentLoaded에서 호출하므로 여기서는 생략해도 무방합니다.
})();

function changeMonth(dir) {
    calMonth += dir;
    if (calMonth < 0) {
        calMonth = 11;
        calYear--;
    }
    if (calMonth > 11) {
        calMonth = 0;
        calYear++;
    }
    renderCalendar();
}

function renderCalendar() {
    var title = document.getElementById('calTitle');
    var grid = document.getElementById('calGrid');
    if (!title || !grid) return;

    var today = new Date();
    var firstDay = new Date(calYear, calMonth, 1).getDay();
    var lastDate = new Date(calYear, calMonth + 1, 0).getDate();

    title.textContent = calYear + '년 ' + (calMonth + 1) + '월';

    fetch(`mypage/calData?year=${calYear}&month=${calMonth + 1}`)
        .then(response => response.json())
        .then(data => {
            // renderStatistics(data.statistics);
            renderAlerts(data.alerts);

            let mappedAlerts = {};
            if (data.alerts) {
                data.alerts.forEach(alert => {
                    let targetDate = new Date();
                    targetDate.setDate(today.getDate() + alert.remainDays);

                    if (targetDate.getFullYear() === calYear && targetDate.getMonth() === calMonth) {
                        let d = targetDate.getDate();
                        if (!mappedAlerts[d]) mappedAlerts[d] = [];
                        mappedAlerts[d].push(alert);
                    }
                });
            }

            buildCal(mappedAlerts, data.checkedDates, firstDay, lastDate, today);
        })
        .catch(err => console.error("캘린더 데이터 로드 실패", err));
}

function buildCal(mappedAlerts, checkedDates, firstDay, lastDate, today) {
    var grid = document.getElementById('calGrid');
    var html = '<div class="cal-day-name">일</div><div class="cal-day-name">월</div><div class="cal-day-name">화</div><div class="cal-day-name">수</div><div class="cal-day-name">목</div><div class="cal-day-name">금</div><div class="cal-day-name">토</div>';

    for (var i = 0; i < firstDay; i++) {
        html += '<div class="cal-day empty"></div>';
    }

    for (var d = 1; d <= lastDate; d++) {
        var cls = 'cal-day';
        var isToday = (today.getFullYear() === calYear && today.getMonth() === calMonth && today.getDate() === d);

        if (isToday) cls += ' today';

        html += `<div class="${cls}">`;
        html += `<span class="day-num">${d}</span>`;

        if (checkedDates && checkedDates.indexOf(d) > -1) {
            html += `<div class="day-status status-ok">✅ 완료</div>`;
        } else if (d < today.getDate() && calMonth <= today.getMonth() || calYear < today.getFullYear()) {
            html += `<div class="day-status status-miss">⚠️ 미복용</div>`;
        }

        if (mappedAlerts && mappedAlerts[d]) {
            html += `<div class="day-alerts">`;
            mappedAlerts[d].forEach(alert => {
                let badgeClass = alert.status === 'warn' ? 'badge-warn' : 'badge-buy';
                let icon = alert.status === 'warn' ? '소진임박' : '재구매';
                html += `<div class="alert-item ${badgeClass}">🛒 ${alert.productName} ${icon}</div>`;
            });
            html += `</div>`;
        }

        html += `</div>`;
    }
    grid.innerHTML = html;
}



function renderAlerts(alerts) {
    const alertList = document.getElementById('alertList');
    if (!alertList) return;
    alertList.innerHTML = '';

    if (!alerts || alerts.length === 0) {
        alertList.innerHTML = '<p style="text-align:center; color:#9ca3af; padding:10px;">등록된 영양제가 없거나 데이터가 없습니다.</p>';
        return;
    }

    alerts.forEach(alert => {
        let icon = alert.status === 'warn' ? '⚠️' : (alert.status === 'buy' ? '🛒' : '✅');
        let msg = alert.status === 'warn' ? `${alert.remainDays}일 후 소진! 미리 구매하세요`
            : (alert.status === 'buy' ? `잔여 ${alert.remainDays}일 · 구매 권장` : `잔여 ${alert.remainDays}일 · 여유 있어요`);

        alertList.innerHTML += `
            <div class="mp-alert-card mp-alert-${alert.status}">
                <span class="alert-icon">${icon}</span>
                <div><strong>${alert.productName}</strong> ${msg}</div>
            </div>
        `;
    });
}