/* ── 탭 전환 ── */
function switchTab(id, btn) {
    document.querySelectorAll('.mp-tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.mp-tab').forEach(el => el.classList.remove('active'));

    var targetTab = document.getElementById('tab-' + id);
    if (targetTab) targetTab.classList.add('active');

    if (btn) {
        btn.classList.add('active');
    } else {
        var targetBtn = document.querySelector(".mp-tab[onclick*=\"'" + id + "'\"]");
        if (targetBtn) targetBtn.classList.add('active');
    }

    // 영구 저장소(localStorage) 대신 임시 저장소(sessionStorage) 사용
    sessionStorage.setItem('activeTab', id);
}
/* ── 페이지 로드 시 마지막 활성 탭 복구 ── */
(function () {
// 1. 현재 페이지 진입 방식 확인 (새로고침인지, 메뉴 클릭해서 온 건지)
    var isReload = false;
    if (window.performance && window.performance.getEntriesByType) {
        var navEntries = window.performance.getEntriesByType("navigation");
        if (navEntries.length > 0 && navEntries[0].type === "reload") {
            isReload = true; // location.reload() 로 인한 진입
        }
    }

    if (isReload) {
        // 2. 추가/삭제 등으로 새로고침 된 경우: 방금 보던 탭 유지
        var savedTab = sessionStorage.getItem('activeTab');
        if (savedTab) {
            switchTab(savedTab);
        }
    } else {
        // 3. 네비게이션 메뉴 등으로 처음 진입한 경우: 무조건 'info(회원정보)' 탭
        sessionStorage.setItem('activeTab', 'info');
        switchTab('info');
    }
})();


/* ── 오늘 날짜 표시 ── */
(function () {
    var now = new Date();
    var y = now.getFullYear();
    var m = String(now.getMonth() + 1).padStart(2, '0');
    var d = String(now.getDate()).padStart(2, '0');
    var el = document.getElementById('todayDate');
    if (el) el.textContent = y + '.' + m + '.' + d;
})();



/* ── 진행률 업데이트 ── */
function updateProgress() {
    var total = document.querySelectorAll('.vit-item').length;
    var checked = document.querySelectorAll('.vit-item.checked').length;
    var pct = total > 0 ? Math.round((checked / total) * 100) : 0;
    var fill = document.getElementById('progressFill');
    var text = document.getElementById('progressText');
    if (fill) fill.style.width = pct + '%';
    if (text) text.textContent = checked + ' / ' + total;
}

/* 페이지 로드 시 진행률 초기화 */
updateProgress();

/* ── 캘린더 ── */
var calYear, calMonth;

(function () {
    var now = new Date();
    calYear = now.getFullYear();
    calMonth = now.getMonth();
    renderCalendar();
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
    var grid = document.getElementById('calGrid');
    var title = document.getElementById('calTitle');
    if (!grid || !title) return;

    var today = new Date();
    var firstDay = new Date(calYear, calMonth, 1).getDay();
    var lastDate = new Date(calYear, calMonth + 1, 0).getDate();

    title.textContent = calYear + '년 ' + (calMonth + 1) + '월';

    /* TODO: 서버에서 이 달의 소진일/구매권장일/체크기록 받아오기
    fetch('mypage/calData?year=' + calYear + '&month=' + (calMonth+1))
      .then(r => r.json())
      .then(data => buildCal(data.warnDates, data.buyDates, data.checkedDates));
    지금은 더미 데이터로 렌더링 */

    /* 더미 데이터 */
    var warnDates = [24, 25];      // 소진 예정일
    var buyDates = [17, 19];      // 구매 권장일 (5일 전)
    var checkedDates = [1, 2, 3, 4, 5, 6, 7, 8]; // 복용 기록 있는 날

    buildCal(warnDates, buyDates, checkedDates, firstDay, lastDate, today);
}

function buildCal(warnDates, buyDates, checkedDates, firstDay, lastDate, today) {
    var grid = document.getElementById('calGrid');
    var html = '<div class="cal-day-name">일</div>'
        + '<div class="cal-day-name">월</div>'
        + '<div class="cal-day-name">화</div>'
        + '<div class="cal-day-name">수</div>'
        + '<div class="cal-day-name">목</div>'
        + '<div class="cal-day-name">금</div>'
        + '<div class="cal-day-name">토</div>';

    for (var i = 0; i < firstDay; i++) {
        html += '<div class="cal-day empty"></div>';
    }

    for (var d = 1; d <= lastDate; d++) {
        var cls = 'cal-day';
        var isToday = (today.getFullYear() === calYear &&
            today.getMonth() === calMonth &&
            today.getDate() === d);

        if (isToday) cls += ' today';
        else if (warnDates.indexOf(d) > -1) cls += ' warn';
        else if (buyDates.indexOf(d) > -1) cls += ' buy-day';
        else if (checkedDates.indexOf(d) > -1) cls += ' checked';

        html += '<div class="' + cls + '">' + d + '</div>';
    }
    grid.innerHTML = html;
}


// 모달 열기/닫기
function openProductModal() {
    document.getElementById('productModal').style.display = 'block';
}
function closeProductModal() {
    document.getElementById('productModal').style.display = 'none';
}

// 1. 내 리스트에 영양제 추가
function addSupplement(productId) {
    if(!confirm("이 영양제를 내 리스트에 추가할까요?")) return;

    fetch('mypage/add-product', { // TODO: 매핑할 서블릿 URL
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'productId=' + productId
    })
        .then(response => {
            if(response.ok) {
                alert("추가되었습니다.");
                location.reload(); // 가장 쉬운 방법: 성공 시 페이지 새로고침하여 내 리스트 갱신
            } else {
                alert("추가 실패. 다시 시도해주세요.");
            }
        });
}

// 2. 복용 여부 체크 토글
function toggleCheck(element, productId) {
    // 1. 화면 UI 먼저 변경 (체크 표시 토글)
    let isChecked = element.classList.toggle('checked');
    let checkBox = element.querySelector('.vit-check-box');
    checkBox.textContent = isChecked ? '✓' : '';

    // 2. 진행률 바 실시간 업데이트 (추가된 부분)
    updateProgress();

    // 3. 서버에 복용 기록 저장 (비동기)
    fetch('mypage/check-intake', { // TODO: 매핑할 서블릿 URL
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'productId=' + productId + '&isTaken=' + isChecked
    }).catch(err => {
        console.error("복용 체크 업데이트 실패", err);
        // 실패 시 UI 원상복구 로직 추가 가능
    });
}

/* ── 내 영양제 삭제 ── */
function removeSupplement(productId) {
    if(!confirm("이 영양제를 내 리스트에서 삭제하시겠습니까?")) return;

    fetch('mypage/remove-product', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'productId=' + productId
    })
        .then(response => {
            if(response.ok) {
                alert("삭제되었습니다.");
                location.reload(); // 새로고침 시 localStorage에 의해 현재 탭 유지됨
            } else {
                alert("삭제 실패. 서버 오류가 발생했습니다.");
            }
        }).catch(err => {
        console.error("삭제 요청 에러:", err);
    });
}