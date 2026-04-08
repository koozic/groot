<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- =============================================
     마이페이지 - views/user/mypage.jsp
     3개 탭: 회원정보 수정 / 오늘의 영양제 체크 / 복용 캘린더
     팀원 기능 연결 포인트: TODO 주석 참고
     ============================================= --%>

<div class="mypage-wrap">

  <%-- ── 프로필 배너 ── --%>
  <div class="profile-banner">
    <div class="avatar">
      <%-- TODO: 프로필 이미지 있으면 <img> 태그로 교체 --%>
      ${sessionScope.loginUser.name.charAt(0)}
    </div>
<%--    <div class="profile-info">--%>
<%--      <h2>${sessionScope.loginUser.name} 님</h2>--%>
<%--      <p>${sessionScope.loginUser.email} · 가입일 ${sessionScope.loginUser.regDate}</p>--%>
<%--    </div>--%>
  </div>

  <%-- ── 탭 메뉴 ── --%>
  <div class="mp-tabs">
    <button class="mp-tab active" onclick="switchTab('info',   this)">👤 회원정보</button>
    <button class="mp-tab"        onclick="switchTab('check',  this)">💊 오늘의 영양제</button>
    <button class="mp-tab"        onclick="switchTab('cal',    this)">📅 복용 캘린더</button>
  </div>

  <%-- ============================================
       탭 1. 회원정보 수정
       TODO: form action → UserUpdateServlet 연결
       ============================================ --%>
  <div id="tab-info" class="mp-tab-content active">
    <div class="mp-card">
      <div class="mp-sec-title">회원정보 수정</div>

      <%-- 메시지 출력 (저장 성공/실패) --%>
      <c:if test="${not empty msg}">
        <div class="mp-alert ${msgType eq 'success' ? 'mp-alert-ok' : 'mp-alert-err'}">
          ${msg}
        </div>
      </c:if>

      <%-- TODO: action="userUpdate" 로 연결 --%>
      <form id="infoForm"  action="user-update" method="post">
        <div class="mp-grid2">
          <div class="mp-form-group">
            <label class="mp-label">닉네임</label>
            <input class="mp-input" type="text" name="name"
                   value="${sessionScope.loginUser.name}" placeholder="닉네임">
          </div>
          <div class="mp-form-group">
            <label class="mp-label">이메일</label>
            <input class="mp-input" type="email" name="email"
                   value="${sessionScope.loginUser.email}" placeholder="이메일" readonly>
          </div>
          <div class="mp-form-group">
            <label class="mp-label">현재 비밀번호</label>
            <input class="mp-input" type="password" name="currentPw"
                   placeholder="현재 비밀번호 입력">
          </div>
          <div class="mp-form-group">
            <label class="mp-label">새 비밀번호</label>
            <input class="mp-input" type="password" name="newPw"
                   placeholder="새 비밀번호 (변경 시에만)">
          </div>
        </div>

        <%-- TODO: 프로필 이미지 업로드 기능 (S3 연동) --%>
        <%--
        <div class="mp-form-group" style="margin-top:12px;">
          <label class="mp-label">프로필 이미지</label>
          <input class="mp-input" type="file" name="profileImage" accept="image/*">
        </div>
        --%>

        <button type="submit" class="mp-save-btn">저장하기</button>
      </form>

      <%-- 회원 탈퇴 --%>
      <div style="margin-top:20px;padding-top:16px;border-top:1px solid #f3f4f6;text-align:right;">
        <%-- TODO: action="userDelete" 연결 --%>
        <a href="#" class="mp-withdraw-link"
           onclick="return confirm('정말 탈퇴하시겠어요?')">회원 탈퇴</a>
      </div>
    </div>
  </div>

  <%-- ============================================
       탭 2. 오늘의 영양제 체크
       TODO: 체크 상태 → DailyCheckServlet AJAX 연결
       ============================================ --%>
  <div id="tab-check" class="mp-tab-content">
    <div class="mp-card">
      <div class="mp-sec-title">
        오늘의 영양제 체크
        <span class="today-badge" id="todayDate"></span>
      </div>

      <div class="vit-list" id="vitaminList">
        <c:choose>
          <c:when test="${not empty mySupplements}">
            <c:forEach var="supp" items="${mySupplements}">
              <%-- TODO: checkedToday 값은 DailyCheckDAO에서 오늘 체크 여부 조회 --%>
              <div class="vit-item ${supp.checkedToday ? 'checked' : ''}"
                   data-supp-id="${supp.suppId}"
                   onclick="toggleCheck(this, ${supp.suppId})">
                <span class="vit-icon">${supp.icon}</span>
                <div class="vit-info">
                  <div class="vit-name">${supp.name}</div>
                  <div class="vit-dose">${supp.timing} · ${supp.dose}</div>
                </div>
                <div class="vit-check-box">
                  <c:if test="${supp.checkedToday}">✓</c:if>
                </div>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <%-- 더미 데이터 (DB 연결 전 확인용) --%>
            <div class="vit-item checked" data-supp-id="1" onclick="toggleCheck(this, 1)">
              <span class="vit-icon">🍊</span>
              <div class="vit-info">
                <div class="vit-name">비타민C 1000mg</div>
                <div class="vit-dose">아침 식후 · 1정</div>
              </div>
              <div class="vit-check-box">✓</div>
            </div>
            <div class="vit-item checked" data-supp-id="2" onclick="toggleCheck(this, 2)">
              <span class="vit-icon">🐟</span>
              <div class="vit-info">
                <div class="vit-name">오메가3</div>
                <div class="vit-dose">점심 식중 · 2정</div>
              </div>
              <div class="vit-check-box">✓</div>
            </div>
            <div class="vit-item" data-supp-id="3" onclick="toggleCheck(this, 3)">
              <span class="vit-icon">☀️</span>
              <div class="vit-info">
                <div class="vit-name">비타민D 2000IU</div>
                <div class="vit-dose">저녁 식후 · 1정</div>
              </div>
              <div class="vit-check-box"></div>
            </div>
            <div class="vit-item" data-supp-id="4" onclick="toggleCheck(this, 4)">
              <span class="vit-icon">🌿</span>
              <div class="vit-info">
                <div class="vit-name">마그네슘</div>
                <div class="vit-dose">취침 전 · 1정</div>
              </div>
              <div class="vit-check-box"></div>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <%-- 오늘 복용 진행률 --%>
      <div class="progress-wrap">
        <div class="progress-label">
          <span>오늘 복용 현황</span>
          <span id="progressText">2 / 4</span>
        </div>
        <div class="progress-bar">
          <div class="progress-fill" id="progressFill" style="width:50%"></div>
        </div>
      </div>

      <%-- TODO: 영양제 추가 버튼 → supplement 페이지 연결 --%>
      <a href="supplement" class="mp-add-btn">+ 복용 영양제 추가하기</a>
    </div>
  </div>

  <%-- ============================================
       탭 3. 복용 캘린더 & 구매 알림
       TODO: 캘린더 데이터 → CalendarServlet에서 JSON으로 받아 JS 렌더링
       ============================================ --%>
  <div id="tab-cal" class="mp-tab-content">

    <%-- 구매 알림 카드들 --%>
    <div class="mp-card" style="margin-bottom:16px;">
      <div class="mp-sec-title">구매 알림</div>
      <div id="alertList">
        <c:choose>
          <c:when test="${not empty alertList}">
            <c:forEach var="alert" items="${alertList}">
              <div class="mp-alert-card mp-alert-${alert.type}">
                <span class="alert-icon">${alert.icon}</span>
                <div>
                  <strong>${alert.suppName}</strong>
                  ${alert.message}
                </div>
                <%-- TODO: 장바구니 바로 담기 버튼 --%>
                <button class="quick-cart-btn"
                        onclick="addCart(${alert.productId}, '${alert.suppName}', '')">
                  🛒
                </button>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <%-- 더미 데이터 --%>
            <div class="mp-alert-card mp-alert-warn">
              <span class="alert-icon">⚠️</span>
              <div><strong>비타민C</strong> 5일 후 소진! 미리 구매하세요</div>
              <button class="quick-cart-btn">🛒</button>
            </div>
            <div class="mp-alert-card mp-alert-buy">
              <span class="alert-icon">🛒</span>
              <div><strong>오메가3</strong> 잔여 12일 · 4월 20일까지 구매 권장</div>
              <button class="quick-cart-btn">🛒</button>
            </div>
            <div class="mp-alert-card mp-alert-ok">
              <span class="alert-icon">✅</span>
              <div><strong>비타민D</strong> 잔여 28일 · 여유 있어요</div>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <%-- 캘린더 --%>
    <div class="mp-card">
      <div class="mp-sec-title">복용 캘린더</div>
      <div class="cal-header">
        <span class="cal-month-title" id="calTitle"></span>
        <div class="cal-nav">
          <button onclick="changeMonth(-1)">‹</button>
          <button onclick="changeMonth(1)">›</button>
        </div>
      </div>
      <div class="cal-grid" id="calGrid"></div>
      <div class="cal-legend">
        <div class="leg"><div class="leg-dot" style="background:#2563eb;"></div>오늘</div>
        <div class="leg"><div class="leg-dot" style="background:#fef2f2;border:1px solid #fecaca;"></div>소진 예정일</div>
        <div class="leg"><div class="leg-dot" style="background:#fffbeb;border:1px solid #fde68a;"></div>구매 권장일 (5일 전)</div>
        <div class="leg"><div class="leg-dot" style="background:#eff6ff;border:1px solid #bfdbfe;"></div>복용 기록 있음</div>
      </div>
    </div>

  </div>
</div>

<%-- =============================================
     마이페이지 전용 스타일
     ============================================= --%>
<style>
.mypage-wrap { max-width: 760px; margin: 0 auto; }

/* 프로필 배너 */
.profile-banner {
  background: #1e3a6e;
  border-radius: 14px;
  padding: 24px 28px;
  display: flex;
  align-items: center;
  gap: 18px;
  margin-bottom: 20px;
}
.avatar {
  width: 58px; height: 58px;
  border-radius: 50%;
  background: #f97316;
  display: flex; align-items: center; justify-content: center;
  font-size: 24px; font-weight: 900; color: #fff;
  flex-shrink: 0;
}
.profile-info h2 { font-size: 18px; font-weight: 900; color: #fff; margin-bottom: 4px; }
.profile-info p  { font-size: 12px; color: rgba(255,255,255,.65); }

/* 탭 */
.mp-tabs { display: flex; gap: 0; border-bottom: 2px solid #e5e7eb; margin-bottom: 20px; }
.mp-tab  {
  padding: 11px 20px;
  font-family: 'Noto Sans KR', sans-serif;
  font-size: 13px; font-weight: 700;
  color: #9ca3af; background: none; border: none;
  border-bottom: 3px solid transparent; margin-bottom: -2px;
  cursor: pointer; transition: all .15s;
}
.mp-tab.active { color: #2563eb; border-bottom-color: #2563eb; }

/* 탭 콘텐츠 */
.mp-tab-content          { display: none; }
.mp-tab-content.active   { display: block; }

/* 카드 */
.mp-card {
  background: #fff;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
  padding: 20px;
  margin-bottom: 16px;
}

/* 섹션 타이틀 */
.mp-sec-title {
  font-size: 14px; font-weight: 700; color: #1a1a1a;
  display: flex; align-items: center; gap: 6px;
  margin-bottom: 16px;
}
.mp-sec-title::before {
  content: ''; display: inline-block;
  width: 4px; height: 15px;
  background: #2563eb; border-radius: 2px; flex-shrink: 0;
}

/* 폼 */
.mp-grid2     { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px; }
.mp-form-group{ display: flex; flex-direction: column; gap: 5px; }
.mp-label     { font-size: 11px; font-weight: 700; color: #9ca3af; letter-spacing: .5px; }
.mp-input     {
  padding: 10px 13px;
  border: 1.5px solid #e5e7eb; border-radius: 8px;
  font-family: 'Noto Sans KR', sans-serif; font-size: 13px; color: #1a1a1a;
  outline: none; transition: border-color .15s;
}
.mp-input:focus { border-color: #2563eb; }
.mp-save-btn  {
  width: 100%; background: #2563eb; color: #fff;
  border: none; border-radius: 8px; padding: 12px;
  font-family: 'Noto Sans KR', sans-serif; font-size: 14px; font-weight: 700;
  cursor: pointer; transition: background .2s;
}
.mp-save-btn:hover { background: #1d4ed8; }
.mp-withdraw-link { font-size: 12px; color: #9ca3af; text-decoration: none; }
.mp-withdraw-link:hover { color: #dc2626; }

/* 알림 메시지 */
.mp-alert     { padding: 10px 14px; border-radius: 8px; font-size: 13px; font-weight: 600; margin-bottom: 14px; }
.mp-alert-ok  { background: #f0fdf4; color: #16a34a; border-left: 4px solid #16a34a; }
.mp-alert-err { background: #fef2f2; color: #dc2626; border-left: 4px solid #dc2626; }

/* 오늘 날짜 배지 */
.today-badge {
  background: #eff6ff; color: #2563eb;
  font-size: 11px; font-weight: 700;
  padding: 2px 9px; border-radius: 999px; margin-left: 4px;
}

/* 비타민 체크 리스트 */
.vit-list  { display: flex; flex-direction: column; gap: 8px; margin-bottom: 16px; }
.vit-item  {
  display: flex; align-items: center; gap: 12px;
  padding: 12px 14px;
  border: 1.5px solid #e5e7eb; border-radius: 10px;
  cursor: pointer; transition: all .15s;
}
.vit-item:hover   { border-color: #93c5fd; background: #f8faff; }
.vit-item.checked { background: #f0fdf4; border-color: #16a34a; }
.vit-icon  { font-size: 22px; flex-shrink: 0; }
.vit-info  { flex: 1; }
.vit-name  { font-size: 13px; font-weight: 700; }
.vit-dose  { font-size: 11px; color: #9ca3af; margin-top: 2px; }
.vit-check-box {
  width: 24px; height: 24px; border-radius: 6px;
  border: 2px solid #e5e7eb;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; font-size: 13px; font-weight: 700;
  transition: all .15s;
}
.vit-item.checked .vit-check-box {
  background: #16a34a; border-color: #16a34a; color: #fff;
}

/* 진행률 바 */
.progress-wrap { margin-bottom: 14px; }
.progress-label {
  display: flex; justify-content: space-between;
  font-size: 12px; font-weight: 700; color: #6b7280;
  margin-bottom: 6px;
}
.progress-bar  { background: #e5e7eb; border-radius: 999px; height: 8px; overflow: hidden; }
.progress-fill { background: #2563eb; height: 100%; border-radius: 999px; transition: width .4s ease; }

/* 영양제 추가 버튼 */
.mp-add-btn {
  display: block; text-align: center;
  padding: 10px; border: 1.5px dashed #93c5fd;
  border-radius: 10px; font-size: 13px; font-weight: 700;
  color: #2563eb; text-decoration: none;
  transition: background .15s;
}
.mp-add-btn:hover { background: #eff6ff; }

/* 알림 카드 */
.mp-alert-card {
  display: flex; align-items: center; gap: 12px;
  padding: 12px 14px; border-radius: 10px; margin-bottom: 8px;
  font-size: 13px;
}
.mp-alert-warn { background: #fef2f2; border: 1px solid #fecaca; color: #dc2626; }
.mp-alert-buy  { background: #fffbeb; border: 1px solid #fde68a; color: #d97706; }
.mp-alert-ok   { background: #f0fdf4; border: 1px solid #bbf7d0; color: #16a34a; }
.alert-icon    { font-size: 18px; flex-shrink: 0; }
.quick-cart-btn{
  margin-left: auto; background: none; border: 1px solid currentColor;
  border-radius: 6px; padding: 4px 8px; font-size: 14px; cursor: pointer;
  flex-shrink: 0;
}

/* 캘린더 */
.cal-header       { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.cal-month-title  { font-size: 14px; font-weight: 700; }
.cal-nav          { display: flex; gap: 6px; }
.cal-nav button   { background: #f3f4f6; border: none; border-radius: 6px; width: 28px; height: 28px; cursor: pointer; font-size: 15px; }
.cal-grid         { display: grid; grid-template-columns: repeat(7,1fr); gap: 3px; }
.cal-day-name     { text-align: center; font-size: 11px; font-weight: 700; color: #9ca3af; padding: 4px 0; }
.cal-day          { text-align: center; padding: 7px 2px; border-radius: 8px; font-size: 12px; cursor: pointer; }
.cal-day.today    { background: #2563eb; color: #fff; font-weight: 700; }
.cal-day.warn     { background: #fef2f2; color: #dc2626; font-weight: 700; }
.cal-day.buy-day  { background: #fffbeb; color: #d97706; font-weight: 700; }
.cal-day.checked  { background: #eff6ff; color: #2563eb; }
.cal-day.empty    { opacity: 0; pointer-events: none; }
.cal-legend       { display: flex; gap: 14px; margin-top: 12px; flex-wrap: wrap; }
.leg              { display: flex; align-items: center; gap: 5px; font-size: 11px; color: #6b7280; }
.leg-dot          { width: 10px; height: 10px; border-radius: 3px; flex-shrink: 0; }

/* 반응형 */
@media (max-width: 600px) {
  .mp-grid2       { grid-template-columns: 1fr; }
  .profile-banner { padding: 18px 16px; }
  .mp-tab         { padding: 10px 12px; font-size: 12px; }
  .cal-day        { font-size: 11px; padding: 5px 1px; }
}
</style>

<%-- =============================================
     마이페이지 전용 스크립트
     ============================================= --%>
<script>
/* ── 탭 전환 ── */
function switchTab(id, btn) {
  document.querySelectorAll('.mp-tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.mp-tab').forEach(el => el.classList.remove('active'));
  document.getElementById('tab-' + id).classList.add('active');
  btn.classList.add('active');
}

/* ── 오늘 날짜 표시 ── */
(function() {
  var now = new Date();
  var y   = now.getFullYear();
  var m   = String(now.getMonth() + 1).padStart(2, '0');
  var d   = String(now.getDate()).padStart(2, '0');
  var el  = document.getElementById('todayDate');
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
  var total   = document.querySelectorAll('.vit-item').length;
  var checked = document.querySelectorAll('.vit-item.checked').length;
  var pct     = total > 0 ? Math.round((checked / total) * 100) : 0;
  var fill    = document.getElementById('progressFill');
  var text    = document.getElementById('progressText');
  if (fill) fill.style.width = pct + '%';
  if (text) text.textContent  = checked + ' / ' + total;
}

/* 페이지 로드 시 진행률 초기화 */
updateProgress();

/* ── 캘린더 ── */
var calYear, calMonth;

(function() {
  var now = new Date();
  calYear  = now.getFullYear();
  calMonth = now.getMonth();
  renderCalendar();
})();

function changeMonth(dir) {
  calMonth += dir;
  if (calMonth < 0)  { calMonth = 11; calYear--; }
  if (calMonth > 11) { calMonth = 0;  calYear++; }
  renderCalendar();
}

function renderCalendar() {
  var grid  = document.getElementById('calGrid');
  var title = document.getElementById('calTitle');
  if (!grid || !title) return;

  var today    = new Date();
  var firstDay = new Date(calYear, calMonth, 1).getDay();
  var lastDate = new Date(calYear, calMonth + 1, 0).getDate();

  title.textContent = calYear + '년 ' + (calMonth + 1) + '월';

  /* TODO: 서버에서 이 달의 소진일/구매권장일/체크기록 받아오기
  fetch('mypage/calData?year=' + calYear + '&month=' + (calMonth+1))
    .then(r => r.json())
    .then(data => buildCal(data.warnDates, data.buyDates, data.checkedDates));
  지금은 더미 데이터로 렌더링 */

  /* 더미 데이터 */
  var warnDates    = [24, 25];      // 소진 예정일
  var buyDates     = [17, 19];      // 구매 권장일 (5일 전)
  var checkedDates = [1,2,3,4,5,6,7,8]; // 복용 기록 있는 날

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
                   today.getMonth()    === calMonth &&
                   today.getDate()     === d);

    if (isToday)                        cls += ' today';
    else if (warnDates.indexOf(d) > -1) cls += ' warn';
    else if (buyDates.indexOf(d) > -1)  cls += ' buy-day';
    else if (checkedDates.indexOf(d) > -1) cls += ' checked';

    html += '<div class="' + cls + '">' + d + '</div>';
  }
  grid.innerHTML = html;
}
</script>
