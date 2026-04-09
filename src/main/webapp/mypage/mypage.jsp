<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- =============================================
     마이페이지 - views/user/mypage.jsp
     3개 탭: 회원정보 수정 / 오늘의 영양제 체크 / 복용 캘린더
     팀원 기능 연결 포인트: TODO 주석 참고
     ============================================= --%>
<link rel="stylesheet" href="css/mypage.css">
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
        <button class="mp-tab" onclick="switchTab('check',  this)">💊 오늘의 영양제</button>
        <button class="mp-tab" onclick="switchTab('cal',    this)">📅 복용 캘린더</button>
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
            <form id="infoForm" action="user-update" method="post">
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
            TODO: List<ProductDTO>를 받아와서 반복문 출력
    ============================================ --%>

        <%-- ============================================
         탭 2. 오늘의 영양제 체크
         ============================================ --%>
        <div id="tab-check" class="mp-tab-content">
            <div class="mp-card">
                <div class="mp-sec-title">
                    오늘의 영양제
                    <span class="today-badge" id="todayDate"></span>
                </div>

                <%-- 진행률 바 (Progress Bar) --%>
                <div class="progress-wrap" style="margin-bottom: 20px;">
                    <div class="progress-label">
                        <span>오늘의 달성도</span>
                        <span id="progressText">0 / 0</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" id="progressFill" style="width: 0%;"></div>
                    </div>
                </div>

                <%-- 복구된 부분: vit-list 컨테이너와 c:choose / c:forEach 블록 --%>
                <div class="vit-list">
                    <c:choose>
                        <c:when test="${not empty myProducts}">
                            <c:forEach var="p" items="${myProducts}">
                                <div class="vit-item" onclick="toggleCheck(this, '${p.productId}')">
                                        <%-- 1. 좌측: 아이콘 --%>
                                    <div class="vit-icon">💊</div>

                                        <%-- 2. 중앙 좌측: 핵심 제품 정보 --%>
                                    <div class="vit-content">
                                        <div class="vit-nutrient">
                                            <c:forEach items="${nutrients}" var="n">
                                                <c:if test="${p.productNutrient == n.nutrientId}">${n.nutrientName}</c:if>
                                            </c:forEach>
                                        </div>
                                        <div class="vit-sub-info">${p.productName} <span>|</span> ${p.productBrand}</div>
                                    </div>

                                        <%-- 3. 중앙 우측: 복용 시간 --%>
                                    <div class="vit-details">
                                        <div class="vit-time">⏰ ${p.productTimeInfo}</div>
                                    </div>

                                        <%-- 4. 우측: 액션 버튼 --%>
                                    <div class="vit-actions">
                                        <div class="vit-check-box"></div>
                                        <button class="vit-delete-btn" onclick="event.stopPropagation(); removeSupplement('${p.productId}');">
                                            &times;
                                        </button>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p style="text-align:center; font-size:13px; color:#9ca3af; padding:20px 0;">
                                등록된 영양제가 없습니다. 추가해주세요!
                            </p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- 영양제 추가 버튼 --%>
                <button type="button" class="mp-add-btn" onclick="openProductModal()" style="width:100%; margin-top: 16px;">
                    + 영양제 추가하기
                </button>
            </div>

            <%-- 모달 영역 --%>
            <div id="productModal" class="mp-modal">
                <div class="mp-modal-content">
                    <div class="mp-modal-header">
                        <div class="mp-sec-title">영양제 선택</div>
                        <button class="modal-close" onclick="closeProductModal()">&times;</button>
                    </div>
                    <div class="modal-search">
                        <input type="text" id="modalSearchInput" placeholder="제품명 검색..." onkeyup="filterProducts()">
                    </div>
                    <div class="modal-product-list" id="modalProductList">
                        <c:forEach var="p" items="${products}">
                            <div class="modal-item" onclick="addSupplement('${p.productId}')">
                                <div class="vit-icon">💊</div>
                                <div class="vit-info">
                                    <div class="vit-name">${p.productName}</div>
                                    <div class="vit-dose">${p.productBrand}</div>
                                </div>
                                <button class="add-select-btn">+</button>
                            </div>
                        </c:forEach>
                    </div>
                </div>
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
                <div class="leg">
                    <div class="leg-dot" style="background:#2563eb;"></div>
                    오늘
                </div>
                <div class="leg">
                    <div class="leg-dot" style="background:#fef2f2;border:1px solid #fecaca;"></div>
                    소진 예정일
                </div>
                <div class="leg">
                    <div class="leg-dot" style="background:#fffbeb;border:1px solid #fde68a;"></div>
                    구매 권장일 (5일 전)
                </div>
                <div class="leg">
                    <div class="leg-dot" style="background:#eff6ff;border:1px solid #bfdbfe;"></div>
                    복용 기록 있음
                </div>
            </div>
        </div>

    </div>
</div>

<script src="js/mypage.js"></script>