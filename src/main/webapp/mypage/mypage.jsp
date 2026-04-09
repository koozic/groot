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
            <form id="deleteUser" action="user-delete" method="post" onsubmit="return confirmDelete()">
                <div style="margin-top:20px; padding-top:16px; border-top:1px solid #f3f4f6; text-align:right;">
                    <button type="submit" class="mp-withdraw-link">회원 탈퇴</button>
                </div>
            </form>

            <script>
                function confirmDelete() {
                    return confirm("정말 탈퇴하시겠어요?");
                }
            </script>
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

                            <%-- [추가] 현재 제품이 오늘 복용 리스트(intakeList)에 있는지 확인하는 로직 --%>
                            <c:set var="isTaken" value="false"/>
                            <c:forEach var="takenId" items="${intakeList}">
                                <c:if test="${takenId == p.productId}">
                                    <c:set var="isTaken" value="true"/>
                                </c:if>
                            </c:forEach>

                            <%-- [수정] 복용 여부에 따라 'checked' 클래스 자동 부여 --%>
                            <div class="vit-item ${isTaken ? 'checked' : ''}"
                                 onclick="toggleCheck(this, '${p.productId}')">
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
                                        <%-- [수정] 복용 여부에 따라 '✓' 표시 자동 생성 --%>
                                    <div class="vit-check-box">${isTaken ? '✓' : ''}</div>
                                    <button class="vit-delete-btn"
                                            onclick="event.stopPropagation(); removeSupplement('${p.productId}', this);">
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

        <%-- 모달 영역 수정 --%>
        <div id="productModal" class="mp-modal">
            <div class="mp-modal-content">
                <div class="mp-modal-header">
                    <div class="mp-sec-title">영양제 선택</div>
                    <button class="modal-close" onclick="closeProductModal()">&times;</button>
                </div>

                <div class="modal-search">
                    <input type="text" id="modalSearchInput" placeholder="제품명 검색..." onkeyup="filterProducts()">
                </div>

                <%-- 제품 리스트 --%>
                <div class="modal-product-list" id="modalProductList">
                    <c:forEach var="p" items="${products}">
                        <%-- 기존 중복 체크 로직 유지 --%>
                        <c:set var="isAlreadyAdded" value="false"/>
                        <c:forEach var="myP" items="${myProducts}">
                            <c:if test="${p.productId == myP.productId}">
                                <c:set var="isAlreadyAdded" value="true"/>
                            </c:if>
                        </c:forEach>

                        <c:if test="${not isAlreadyAdded}">
                            <%-- [수정] onclick 시 event와 this 전달 --%>
                            <div class="modal-item" onclick="addSupplement('${p.productId}', this)">
                                <div class="vit-icon">💊</div>
                                <div class="vit-info">
                                    <div class="vit-name">${p.productName}</div>
                                    <div class="vit-dose">${p.productBrand}</div>
                                </div>
                                <button class="add-select-btn">+</button>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <%-- [추가] 모달 하단 완료 버튼 --%>
                <div style="margin-top: 20px;">
                    <button type="button" class="mp-save-btn" onclick="closeAndRefresh()">완료</button>
                </div>
            </div>
        </div>

        <div id="confirmModal" class="mp-modal">
            <div class="mp-modal-content" style="max-width: 320px; text-align: center;">
                <div id="confirmMessage" style="margin-bottom: 20px; font-weight: 700; color: #1a1a1a;"></div>
                <div style="display: flex; gap: 8px;">
                    <button onclick="closeConfirm()"
                            style="flex:1; padding: 10px; border:none; border-radius:8px; background:#f3f4f6; cursor:pointer;">
                        취소
                    </button>
                    <button id="confirmBtn"
                            style="flex:1; padding: 10px; border:none; border-radius:8px; background:#2563eb; color:#fff; cursor:pointer;">
                        확인
                    </button>
                </div>
            </div>
        </div>
    </div>
    <%-- ============================================
         탭 3. 복용 캘린더 & 구매 알림
         TODO: 캘린더 데이터 → CalendarServlet에서 JSON으로 받아 JS 렌더링
         ============================================ --%>
    <div id="tab-cal" class="mp-tab-content">

        <%-- 1. 구매 알림 영역 --%>
        <div class="mp-card" style="margin-bottom:16px;">
            <div class="mp-sec-title">구매 알림</div>
            <%-- JS(renderAlerts)에서 동적으로 HTML을 삽입할 빈 컨테이너 --%>
            <div id="alertList">
                <p style="text-align:center; font-size:13px; color:#9ca3af; padding:10px;">데이터를 불러오는 중입니다...</p>
            </div>
        </div>

            <%-- 2. 전체 복용 통계 영역 --%>
            <div class="mp-card" style="margin-bottom:16px;">
                <details class="mp-stat-details">

                    <summary class="mp-sec-title mp-accordion-summary">
                        이번 달 복용 통계
                        <span class="mp-accordion-toggle">▼ 펼쳐보기</span>
                    </summary>

                    <div id="statsContainer" class="mp-stat-content">
                        <c:choose>
                            <c:when test="${not empty monthlyStats}">
                                <ul class="mp-stat-list">
                                    <c:forEach var="stat" items="${monthlyStats}">
                                        <li class="mp-stat-item">
                                <span class="mp-stat-name">
                                    💊 ${stat.productName}
                                </span>
                                            <span class="mp-stat-count">
                                    ${stat.intakeCount}회 복용
                                </span>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:when>
                            <c:otherwise>
                                <p class="mp-stat-empty">이번 달 복용 기록이 없습니다.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                </details>
            </div>
        <%-- 3. 복용 캘린더 영역 --%>
        <div class="mp-card">
            <div class="mp-sec-title">복용 캘린더</div>
            <div class="cal-header">
                <span class="cal-month-title" id="calTitle"></span>
                <div class="cal-nav">
                    <button onclick="changeMonth(-1)">‹</button>
                    <button onclick="changeMonth(1)">›</button>
                </div>
            </div>

            <%-- JS(buildCal)에서 동적으로 날짜 셀을 삽입할 빈 컨테이너 --%>
            <div class="cal-grid" id="calGrid"></div>

            <%-- 범례 (JS 로직에 맞게 스타일 및 텍스트 수정) --%>
            <div class="cal-legend"
                 style="margin-top: 10px; display: flex; flex-wrap: wrap; gap: 10px; font-size: 11px;">
                <div class="leg">
                    <div class="leg-dot"
                         style="background:#dcfce7; border:1px solid #166534; width:10px; height:10px; border-radius:50%; display:inline-block;"></div>
                    복용 완료
                </div>
                <div class="leg">
                    <div class="leg-dot"
                         style="background:#fee2e2; border:1px solid #991b1b; width:10px; height:10px; border-radius:50%; display:inline-block;"></div>
                    미복용
                </div>
                <div class="leg">
                    <div class="leg-dot"
                         style="background:#ffedd5; width:10px; height:10px; display:inline-block;"></div>
                    소진 임박
                </div>
                <div class="leg">
                    <div class="leg-dot"
                         style="background:#dbeafe; width:10px; height:10px; display:inline-block;"></div>
                    재구매
                </div>
            </div>
        </div>

    </div>

</div>
</div>

<script src="js/mypage.js"></script>