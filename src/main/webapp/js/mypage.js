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
    const sortRecentBtn = document.getElementById('sort-recent');
    if (sortRecentBtn) loadLikedSupplements('recent', sortRecentBtn);

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
            showMpToast("리스트에 추가되었습니다.");
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

// 1. 함수명을 showMpToast로 변경하고 클래스명을 mp-toast로 통일
function showMpToast(message, type = 'success') {
    const container = document.getElementById('toast-container') || createToastContainer();
    const toast = document.createElement('div');
    toast.className = `mp-toast ${type}`; // 👈 클래스명 mp-toast로 변경
    toast.innerHTML = `<span>${type === 'success' ? '✅' : '❌'}</span> ${message}`;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

// 2. 실행취소 토스트 함수 (버튼 id 중복 방지를 위해 class="undo-btn" 사용)
function showUndoToast(message, undoAction) {
    const container = document.getElementById('toast-container') || createToastContainer();
    const toast = document.createElement('div');
    toast.className = 'mp-toast success'; // 👈 클래스명 mp-toast로 유지

    toast.innerHTML = `<span>${message}</span><button class="undo-btn" style="margin-left:15px; background:none; border:none; color:#93c5fd; font-weight:800; cursor:pointer; text-decoration:underline;">실행 취소</button>`;
    container.appendChild(toast);

    toast.querySelector('.undo-btn').onclick = () => {
        undoAction();
        toast.remove();
    };

    setTimeout(() => {
        if (toast) toast.remove();
    }, 3000);
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
            // 1. trim()을 사용하여 불필요한 공백/줄바꿈 제거
            if (text.trim() === 'success') {
                if (typeof renderCalendar === 'function') {
                    // 2. DB 업데이트가 반영될 수 있도록 미세한 딜레이 부여 (필요 시)
                    setTimeout(() => {
                        renderCalendar();
                    }, 100);
                }
            } else {
                console.warn("Status update failed response:", text);
            }
        })
        .catch(err => console.error("체크 상태 업데이트 실패", err));
}


function removeSupplement(productId, btnElement) {
    const item = btnElement.closest('.vit-item');
    if (!item) return;

    // 1. 화면에서 즉시 숨김 처리 (사용자 체감 속도 향상)
    item.style.display = 'none';
    updateProgress();

    // 2. 3초(3000ms) 뒤에 실제 백엔드(DB)로 삭제 요청을 보냄
    // 변수(timeoutId)에 담아두어야 나중에 '실행 취소'를 눌렀을 때 통신을 막을 수 있습니다.
    const timeoutId = setTimeout(() => {
        fetch('mypage/remove-product', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'productId=' + productId
        }).catch(() => {
            // 서버 오류 시 원상 복구
            item.style.display = 'flex';
            updateProgress();
            showMpToast("삭제 실패", "error");
        });
    }, 10000);

    // 3. 하단에 '실행 취소' 토스트 팝업 노출
    showUndoToast("영양제가 삭제되었습니다.", () => {
        // [실행 취소] 버튼을 눌렀을 때 실행될 동작
        clearTimeout(timeoutId);     // 백엔드로 가는 통신(fetch)을 강제로 취소!
        item.style.display = 'flex'; // 화면에 영양제를 다시 나타나게 함
        updateProgress();            // 진행률 바 다시 계산
    });
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

// 실행취소 토스트 함수
function showUndoToast(message, undoAction) {
    const container = document.getElementById('toast-container') || createToastContainer();
    const toast = document.createElement('div');
    toast.className = 'mp-toast success';
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


// 컨테이너 생성 함수
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
        location.reload();      //새로고침해서 리로드
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
            // ▼ 이 부분의 주석을 해제합니다.
            if (data.statistics) {
                renderStatistics(data.statistics);
            }
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

    // [추가] 넘어온 배열이 없으면 빈 배열 할당, 문자열이 섞여 있어도 무조건 숫자로 변환
    var safeCheckedDates = (checkedDates || []).map(Number);

    // 1. 1일 이전의 빈 칸 그리기
    for (var i = 0; i < firstDay; i++) {
        html += '<div class="cal-day empty"></div>';
    }

    // [수정된 부분] 날짜 비교를 위해 '오늘 자정(00:00:00)' 기준 객체 생성
    var todayMidnight = new Date();
    todayMidnight.setHours(0, 0, 0, 0);

    // 2. 실제 날짜 셀 그리기
    for (var d = 1; d <= lastDate; d++) {
        var cls = 'cal-day';
        var isToday = (today.getFullYear() === calYear && today.getMonth() === calMonth && today.getDate() === d);

        // [수정된 부분] 현재 렌더링 중인 캘린더 셀의 날짜 객체 생성 (자정 기준)
        var currentCellDate = new Date(calYear, calMonth, d);
        currentCellDate.setHours(0, 0, 0, 0);

        if (isToday) cls += ' today';

        html += `<div class="${cls}">`;
        html += `<span class="day-num">${d}</span>`;

        // [수정된 부분] 복용/미복용 상태 판단 로직
        if (checkedDates && checkedDates.includes(d)) {
            html += `<div class="day-status status-ok">완료</div>`;
        } else if (currentCellDate < todayMidnight) {
            // 셀의 날짜가 오늘 자정보다 과거일 경우에만 미복용 처리
            html += `<div class="day-status status-miss">미복용</div>`;
        }

        // 3. 구매 알림 데이터(배지) 렌더링
        if (mappedAlerts && mappedAlerts[d]) {
            let alertHtml = '';

            mappedAlerts[d].forEach(alert => {
                // 상태(warn/buy)를 따지지 않고, 넘어온 알람은 무조건 '재구매'로 렌더링
                alertHtml += `<div class="alert-item badge-buy">🛒 ${alert.productName} 재구매</div>`;
            });

            // 알림 영역 추가
            if (alertHtml !== '') {
                html += `<div class="day-alerts">`;
                html += alertHtml;
                html += `</div>`;
            }
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

/* ── 영양제 모달 검색 필터링 ── */
function filterProducts() {
    // 1. 입력된 검색어 가져오기 (대소문자 구분 없이 검색하기 위해 소문자로 변환)
    const keyword = document.getElementById('modalSearchInput').value.toLowerCase();

    // 2. 모달 리스트 안의 모든 제품 아이템 선택
    const productItems = document.querySelectorAll('#modalProductList .modal-item');

    // 3. 각 아이템을 순회하며 검색어 포함 여부 확인
    productItems.forEach(item => {
        // 제품명 텍스트 추출 (앞서 공유해주신 코드의 클래스명 기준)
        const nameElement = item.querySelector('.vit-name');

        // 추가로 브랜드명도 같이 검색되게 하려면 아래 주석 해제
        // const brandElement = item.querySelector('.vit-dose');

        if (nameElement) {
            const productName = nameElement.textContent.toLowerCase();
            // const brandName = brandElement ? brandElement.textContent.toLowerCase() : '';

            // ✨ 인라인 스타일(display) 조작 대신 CSS 클래스 제어로 부드러운 전환 ✨
            if (productName.includes(keyword)) {
                item.classList.remove('filtered-out');
            } else {
                item.classList.add('filtered-out');
            }
        }
    });
}

/* ── 이번 달 복용 통계 렌더링 ── */
function renderStatistics(stats) {
    const container = document.getElementById('statsContainer');
    if (!container) return;

    // 통계 데이터가 없을 경우
    if (!stats || stats.length === 0) {
        container.innerHTML = '<p class="mp-stat-empty">이번 달 복용 기록이 없습니다.</p>';
        return;
    }

    // 통계 데이터가 있을 경우 HTML 동적 생성
    let html = '<ul class="mp-stat-list">';
    stats.forEach(stat => {
        html += `
            <li class="mp-stat-item">
                <span class="mp-stat-name">
                    <img style="width: 20px;" class="icon" src="img/stickers/pill.png" alt=""> 
                    ${stat.productName}
                </span>
                <span class="mp-stat-count">${stat.intakeCount}회 복용</span>
            </li>
        `;
    });
    html += '</ul>';

    container.innerHTML = html;
}


// ── 찜한 영양성분 정렬 로드 ──
// ── 찜한 영양성분 전역 상태 ──
let likedData = [];       // 전체 데이터 캐시
let currentPage = 1;
const PAGE_SIZE = 6;      // 한 페이지에 보여줄 카드 수

// ── 찜한 영양성분 정렬 로드 ──
function loadLikedSupplements(sort, btn) {
    // 버튼 스타일 토글
    document.querySelectorAll('#sort-recent, #sort-oldest').forEach(b => {
        b.style.background = '#fff';
        b.style.color = '#666';
        b.style.borderColor = '#ccc';
        b.style.fontWeight = 'normal';
    });
    btn.style.background = '#eff6ff';
    btn.style.color = '#1d4ed8';
    btn.style.borderColor = '#3b82f6';
    btn.style.fontWeight = '500';

    fetch(`mypage?action=myLikes&sort=${sort}`)
        .then(r => r.json())
        .then(data => {
            likedData = data || [];
            currentPage = 1;         // 정렬 변경 시 1페이지로 리셋
            renderLikedPage();
        })
        .catch(() => showToast('불러오기 실패', 'error'));
}

// ── 현재 페이지 카드 렌더링 ──
function renderLikedPage() {
    const container = document.getElementById('liked-list');
    const pagination = document.getElementById('liked-pagination');

    if (!likedData || likedData.length === 0) {
        container.innerHTML = `
            <div style="grid-column:1/-1; text-align:center; padding:40px 0;
                        color:#9ca3af; font-size:14px;">
                <div style="font-size:3em; margin-bottom:10px;">🩶</div>
                아직 찜한 영양성분이 없습니다.
            </div>`;
        if (pagination) pagination.innerHTML = '';
        return;
    }

    const totalPages = Math.ceil(likedData.length / PAGE_SIZE);
    const start = (currentPage - 1) * PAGE_SIZE;
    const pageData = likedData.slice(start, start + PAGE_SIZE);

    container.innerHTML = pageData.map(s => `
        <div id="liked-card-${s.supplementId}" class="like-card"
             style="border:1px solid #eee; border-radius:10px; padding:15px;
                    text-align:center; box-shadow:0 2px 8px rgba(0,0,0,0.05);
                    background:#fff; display:flex; flex-direction:column;
                    justify-content:space-between;">
            <div>
                <div style="width:100%; height:150px; border-radius:8px;
                     overflow:hidden; background:#f8f9fa; margin-bottom:12px;">
                    <img src="${getImgSrc(s.supplementImagePath)}"
                         style="width:100%; height:100%; object-fit:cover;"
                         onerror="this.src='images/default.png'">
                </div>
                <div style="font-weight:bold; font-size:1.1em; color:#333; margin-bottom:5px;">
                    ${s.supplementName}
                </div>
                <div style="font-size:0.85em; color:#666; height:35px;
                     overflow:hidden; line-height:1.4;">
                    ${s.supplementEfficacy || ''}
                </div>
            </div>
            <button onclick="showSupplementDetail(
                        '${s.supplementId}','${escHtml(s.supplementName)}',
                        '${escHtml(s.supplementEfficacy)}','${escHtml(s.supplementDosage)}',
                        '${escHtml(s.supplementTiming)}','${escHtml(s.supplementCaution)}',
                        '${s.supplementImagePath}')"
                style="margin-top:15px; padding:8px 10px; background:#f0fdf4;
                       border:1px solid #bbf7d0; color:#166534; border-radius:5px;
                       cursor:pointer; font-size:0.9em; width:100%; font-weight:bold;">
                자세히 보기
            </button>
        </div>`).join('');

    // ── 페이지네이션 버튼 렌더링 ──
    renderPagination(totalPages);
}

function renderPagination(totalPages) {
    const pagination = document.getElementById('liked-pagination');
    if (!pagination) return;

    let html = '';

    // 이전 버튼
    html += `<button onclick="goLikedPage(${currentPage - 1})"
        ${currentPage === 1 ? 'disabled' : ''}
        style="padding:6px 12px; border:1px solid #ddd; border-radius:6px;
               background:${currentPage === 1 ? '#f3f4f6' : '#fff'};
               color:${currentPage === 1 ? '#9ca3af' : '#374151'};
               cursor:${currentPage === 1 ? 'default' : 'pointer'};">‹</button>`;

    // 페이지 번호 버튼
    for (let i = 1; i <= totalPages; i++) {
        html += `<button onclick="goLikedPage(${i})"
            style="padding:6px 12px; border:1px solid ${i === currentPage ? '#3b82f6' : '#ddd'};
                   border-radius:6px; margin:0 2px;
                   background:${i === currentPage ? '#3b82f6' : '#fff'};
                   color:${i === currentPage ? '#fff' : '#374151'};
                   cursor:pointer; font-weight:${i === currentPage ? 'bold' : 'normal'};">
            ${i}
        </button>`;
    }

    // 다음 버튼
    html += `<button onclick="goLikedPage(${currentPage + 1})"
        ${currentPage === totalPages ? 'disabled' : ''}
        style="padding:6px 12px; border:1px solid #ddd; border-radius:6px;
               background:${currentPage === totalPages ? '#f3f4f6' : '#fff'};
               color:${currentPage === totalPages ? '#9ca3af' : '#374151'};
               cursor:${currentPage === totalPages ? 'default' : 'pointer'};">›</button>`;

    pagination.innerHTML = html;
}

function goLikedPage(page) {
    const totalPages = Math.ceil(likedData.length / PAGE_SIZE);
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    renderLikedPage();
    // 탭 상단으로 스크롤
    document.getElementById('tab-like')?.scrollIntoView({behavior: 'smooth', block: 'start'});
}

// 이미지 경로 판별 헬퍼
function getImgSrc(path) {
    if (!path) return 'images/default.png';
    if (path.startsWith('http')) return path;
    return '/supplementImg/supplementImgFile/' + path;
}

// XSS 방지용 이스케이프
function escHtml(str) {
    if (!str) return '';
    return str.replace(/'/g, "\\'").replace(/"/g, '&quot;');
}

/* ====================================================
   스티커 꾸미기 모듈 (MVC 패턴 + 비동기 CRUD)
   ==================================================== */

// ── Model: 현재 스티커 상태 관리 ──
const StickerModel = {
    stickers: [],
    savedStickers: [],

    add(stickerData) {
        this.stickers.push(stickerData);
    },

    // ★ 수정: 타입 통일해서 비교
    removeByTempId(tempId) {
        const id = String(tempId);
        this.stickers = this.stickers.filter(s => String(s.tempId) !== id);
    },

    rollback() {
        this.stickers = this.savedStickers.map(s => ({...s}));
    },

    // mypage.js 내 StickerModel 객체 수정
    commit(savedList, year, month) {
        // 1. 현재 편집 중인 '해당 년/월'이 아닌 스티커들만 추출 (보존용)
        const otherMonths = this.stickers.filter(s => {
            const sYear = Number(s.cal_year || s.calYear);
            const sMonth = Number(s.cal_month || s.calMonth);
            return !(sYear === Number(year) && sMonth === Number(month));
        });

        // 2. 서버에서 받은 새 목록 정규화
        const normalized = (savedList || []).map(s => ({
            ...s,
            tempId: String(s.sticker_id || s.stickerId || s.tempId),
            cal_year: Number(s.cal_year || s.calYear || year),
            cal_month: Number(s.cal_month || s.calMonth || month),
            cal_day: Number(s.cal_day || s.calDay),
            pos_x: parseFloat(s.pos_x || s.posX),
            pos_y: parseFloat(s.pos_y || s.posY),
            sticker_type: s.sticker_type || s.stickerType
        }));

        // 3. 보존된 데이터 + 서버에서 새로 받은 데이터를 합침
        this.stickers = [...otherMonths, ...normalized];
        this.savedStickers = this.stickers.map(s => ({...s}));
    }
};

// ── 전역 상태 ──
let isStickerEditMode = false;
let dragStickerType = null;   // 드래그 중인 스티커 종류

// ── Controller: 편집 모드 토글 ──
function toggleStickerEdit() {
    isStickerEditMode = !isStickerEditMode;

    const panel = document.getElementById('stickerPanel');
    const editBtn = document.getElementById('stickerEditToggle');
    const saveBtn = document.getElementById('stickerSaveBtn');
    const cancelBtn = document.getElementById('stickerCancelBtn');
    const hint = document.getElementById('stickerEditHint');
    const tray = document.querySelector('.sticker-tray');

    if (isStickerEditMode) {
        // 편집 모드 진입: 현재 상태를 백업
        StickerModel.savedStickers = StickerModel.stickers.map(s => ({...s}));

        panel.classList.add('edit-mode');
        tray.style.display = 'flex';
        editBtn.style.display = 'none';
        saveBtn.style.display = 'inline-block';
        cancelBtn.style.display = 'inline-block';
        hint.style.display = 'block';

        // 캘린더 셀에 드롭 이벤트 활성화
        activateDropZones();
    } else {
        exitStickerEditMode();
    }
}

function exitStickerEditMode() {
    isStickerEditMode = false;
    const panel = document.getElementById('stickerPanel');
    const editBtn = document.getElementById('stickerEditToggle');
    const saveBtn = document.getElementById('stickerSaveBtn');
    const cancelBtn = document.getElementById('stickerCancelBtn');
    const hint = document.getElementById('stickerEditHint');
    const tray = document.querySelector('.sticker-tray');

    panel.classList.remove('edit-mode');
    tray.style.display = 'none';
    editBtn.style.display = 'inline-block';
    saveBtn.style.display = 'none';
    cancelBtn.style.display = 'none';
    hint.style.display = 'none';
}

// ── 편집 취소 ──
function cancelStickerEdit() {
    StickerModel.rollback();          // 저장 전 상태로 복원
    renderStickersOnCalendar();       // 화면 다시 그리기
    exitStickerEditMode();
    showMpToast('수정이 취소되었습니다.');
}

// ── View: 드래그 시작 이벤트 (스티커 트레이) ──
function initStickerTray() {
    document.querySelectorAll('.sticker-item').forEach(el => {
        el.addEventListener('dragstart', function (e) {
            dragStickerType = this.dataset.sticker;
            e.dataTransfer.effectAllowed = 'copy';
        });
    });
}

// ── Controller: 캘린더 셀에 드롭 존 활성화 ──
function activateDropZones() {
    document.querySelectorAll('#calGrid .cal-day:not(.empty)').forEach(cell => {
        // ★ 이미 등록된 이벤트 제거 후 재등록 (중복 방지)
        if (cell.dataset.dropBound === 'true') return;
        cell.dataset.dropBound = 'true';

        cell.classList.add('drop-zone');

        cell.addEventListener('dragover', function (e) {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'copy';
            this.classList.add('drag-over');
        });

        cell.addEventListener('dragleave', function () {
            this.classList.remove('drag-over');
        });

        cell.addEventListener('drop', function (e) {
            e.preventDefault();
            this.classList.remove('drag-over');
            if (!dragStickerType) return;

            const rect = this.getBoundingClientRect();
            const posX = ((e.clientX - rect.left) / rect.width * 100).toFixed(1);
            const posY = ((e.clientY - rect.top) / rect.height * 100).toFixed(1);

            const dayNum = parseInt(this.querySelector('.day-num')?.textContent || '0');
            if (!dayNum) return;

            const newSticker = {
                tempId: String(Date.now() + Math.random()), // ★ String으로 통일
                sticker_type: dragStickerType,
                cal_year: calYear,
                cal_month: calMonth + 1,
                cal_day: dayNum,
                pos_x: parseFloat(posX),
                pos_y: parseFloat(posY)
            };

            StickerModel.add(newSticker);
            renderStickersOnCalendar();
        });
    });
}

// ── View: 스티커를 캘린더 위에 렌더링 ──
function renderStickersOnCalendar() {
    document.querySelectorAll('.placed-sticker').forEach(el => el.remove());

    // ★ Number()로 타입 통일해서 필터링
    const currentStickers = StickerModel.stickers.filter(
        s => Number(s.cal_year) === calYear && Number(s.cal_month) === calMonth + 1
    );

    currentStickers.forEach(s => {
        const cells = document.querySelectorAll('#calGrid .cal-day:not(.empty)');
        let targetCell = null;
        cells.forEach(cell => {
            const dayNum = parseInt(cell.querySelector('.day-num')?.textContent || '0');
            if (dayNum === Number(s.cal_day)) targetCell = cell;
        });
        if (!targetCell) return;

        const stickerEl = document.createElement('span');
        stickerEl.className = 'placed-sticker';
        stickerEl.style.left = s.pos_x + '%';
        stickerEl.style.top = s.pos_y + '%';
        // ★ tempId를 String으로 통일
        stickerEl.dataset.tempId = String(s.tempId || s.sticker_id);

        if (s.sticker_type.startsWith('img:')) {
            const imgPath = s.sticker_type.replace('img:', '');
            const base = (typeof window.contextPath !== 'undefined' && window.contextPath !== '')
                ? window.contextPath : '';
            const img = document.createElement('img');
            img.src = base + '/img/' + imgPath;
            img.className = 'placed-sticker-img';
            img.alt = '스티커';
            img.draggable = false;
            stickerEl.appendChild(img);
        } else {
            stickerEl.textContent = s.sticker_type;
        }

        stickerEl.addEventListener('click', function (e) {
            if (!isStickerEditMode) return;
            e.stopPropagation();
            // ★ String으로 통일해서 삭제
            StickerModel.removeByTempId(String(this.dataset.tempId));
            this.remove();
            showMpToast('스티커가 삭제되었습니다.');
        });

        targetCell.style.position = 'relative';
        targetCell.appendChild(stickerEl);
    });
}

// ── Controller: 저장 (비동기 POST) ──
async function saveStickers() {
    const saveBtn = document.getElementById('stickerSaveBtn');
    saveBtn.disabled = true;
    saveBtn.textContent = '저장 중...';

    const year = calYear;
    const month = calMonth + 1;

    try {
        // ★ 불필요한 sticker_id 제거, 꼭 필요한 필드만 깔끔하게 전송
        const toSave = StickerModel.stickers
            .filter(s =>
                Number(s.cal_year) === year &&
                Number(s.cal_month) === month
            )
            .map(s => ({
                sticker_type: String(s.sticker_type),
                cal_year: year,
                cal_month: month,
                cal_day: Number(s.cal_day),
                pos_x: parseFloat(s.pos_x),
                pos_y: parseFloat(s.pos_y)
            }));

        console.log('📤 전송 데이터:', JSON.stringify(toSave)); // 디버깅

        const response = await fetch('mypage/sticker', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({year, month, stickers: toSave})
        });

        if (!response.ok) throw new Error('서버 오류: ' + response.status);

        const saved = await response.json();
        console.log('📥 서버 응답:', JSON.stringify(saved)); // 디버깅

        StickerModel.commit(saved, year, month);
        renderStickersOnCalendar();
        exitStickerEditMode();
        showMpToast('🎉 스티커가 저장되었습니다!');

    } catch (err) {
        console.error('스티커 저장 실패', err);
        showMpToast('저장에 실패했습니다. 다시 시도해주세요.', 'error');
    } finally {
        saveBtn.disabled = false;
        saveBtn.textContent = '💾 저장하기';
    }
}

// ── Controller: 불러오기 (비동기 GET) ──
async function loadStickers() {
    try {
        const res = await fetch(`mypage/sticker?year=${calYear}&month=${calMonth + 1}`);
        if (!res.ok) return;
        const list = await res.json();

        // commit 함수에서 정규화를 처리하므로 바로 전달하되, year/month를 명시
        StickerModel.commit(list, calYear, calMonth + 1);
        renderStickersOnCalendar();
    } catch (err) {
        console.error('스티커 불러오기 실패', err);
    }
}


const _origBuildCal = buildCal;
window.buildCal = function (...args) {
    _origBuildCal(...args);

    // ★ 월 이동 시 drop 이벤트 중복 방지 플래그 초기화
    document.querySelectorAll('#calGrid .cal-day').forEach(cell => {
        delete cell.dataset.dropBound;
    });

    loadStickers();
    if (isStickerEditMode) activateDropZones();
    initStickerTray();
};