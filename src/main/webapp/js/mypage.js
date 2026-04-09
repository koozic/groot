/* ── 탭 전환 ── */
function switchTab(id, btn) {
    document.querySelectorAll('.mp-tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.mp-tab').forEach(el => el.classList.remove('active'));
    document.getElementById('tab-' + id).classList.add('active');
    btn.classList.add('active');
}

/* ── 오늘 날짜 표시 ── */
(function () {
    var now = new Date();
    var y = now.getFullYear();
    var m = String(now.getMonth() + 1).padStart(2, '0');
    var d = String(now.getDate()).padStart(2, '0');
    var el = document.getElementById('todayDate');
    if (el) el.textContent = y + '.' + m + '.' + d;
})();

/* ── 비타민 체크 토글 ── */
function toggleCheck(el, suppId) {
    var isChecked = el.classList.toggle('checked');
    var box = el.querySelector('.vit-check-box');
    box.textContent = isChecked ? '✓' : '';
    updateProgress();

    /* TODO: AJAX로 서버에 체크 상태 저장
    fetch('mypage/check', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({ suppId: suppId, checked: isChecked, date: getTodayStr() })
    });
    */
}

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
