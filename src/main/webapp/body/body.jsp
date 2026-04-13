<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Groot - 신체별 영양소 추천</title>
    <link rel="stylesheet" href="css/body.css">
</head>
<body>

<%-- 로그인 세션 정보를 JS로 전달 --%>
<script>
    // 1. loginUser 객체가 세션에 있으면 로그인된 상태입니다.
    window.IS_LOGIN = ${sessionScope.loginUser != null ? "true" : "false"};

    // 2. loginUser 객체 안에 있는 user_id를 가져옵니다.
    // 관리자든 일반유저든 UserDAO에서 loginUser에 담아주므로 공통으로 쓸 수 있습니다.
    window.LOGIN_USER_ID = "${sessionScope.loginUser != null ? sessionScope.loginUser.user_id : ''}";

    // 3. 관리자 여부 (필요할 경우 사용)
    window.IS_ADMIN = ${sessionScope.isAdmin == true ? "true" : "false"};

    console.log("--- [Groot 세션 체크] ---");
    console.log("로그인 여부:", window.IS_LOGIN);
    console.log("사용자 아이디:", window.LOGIN_USER_ID);
    console.log("관리자 여부:", window.IS_ADMIN);
</script>

<div class="wrap">
    <div class="layout">

        <%-- 왼쪽: SVG + 체크박스 (웹) / 위: SVG + 체크박스 (앱) --%>
        <div class="col-left">

            <%-- SVG 신체 캐릭터 --%>
            <div class="svg-wrap">
                <svg viewBox="0 0 200 380" xmlns="http://www.w3.org/2000/svg">
                    <ellipse class="body-part" data-part="hair" cx="100" cy="36" rx="38" ry="24" fill="#C084FC"
                             stroke="#9333EA" stroke-width="1.2"/>
                    <text x="100" y="40" text-anchor="middle" font-size="8" fill="#581C87" pointer-events="none">머리카락
                    </text>
                    <ellipse class="body-part" data-part="brain" cx="100" cy="34" rx="26" ry="16" fill="#F9A8D4"
                             stroke="#EC4899" stroke-width="1" opacity=".8"/>
                    <text x="100" y="38" text-anchor="middle" font-size="7" fill="#831843" pointer-events="none">뇌
                    </text>
                    <ellipse class="body-part" data-part="skin" cx="100" cy="64" rx="28" ry="26" fill="#FCA5A5"
                             stroke="#EF4444" stroke-width="1.2"/>
                    <text x="100" y="68" text-anchor="middle" font-size="8" fill="#7F1D1D" pointer-events="none">피부
                    </text>
                    <ellipse class="body-part" data-part="eye" cx="88" cy="58" rx="6" ry="4" fill="#60A5FA"
                             stroke="#2563EB" stroke-width="1"/>
                    <ellipse class="body-part" data-part="eye" cx="112" cy="58" rx="6" ry="4" fill="#60A5FA"
                             stroke="#2563EB" stroke-width="1"/>
                    <text x="100" y="50" text-anchor="middle" font-size="7" fill="#1E3A8A" pointer-events="none">눈
                    </text>
                    <rect x="86" y="88" width="28" height="14" rx="5" fill="#FDE68A" stroke="#D97706"
                          stroke-width=".8"/>
                    <rect class="body-part" data-part="skin" x="62" y="100" width="76" height="88" rx="16"
                          fill="#FCA5A5" stroke="#EF4444" stroke-width="1.2"/>
                    <ellipse class="body-part" data-part="lung" cx="80" cy="125" rx="14" ry="18" fill="#93C5FD"
                             stroke="#3B82F6" stroke-width="1"/>
                    <text x="80" y="129" text-anchor="middle" font-size="7" fill="#1E3A8A" pointer-events="none">폐
                    </text>
                    <ellipse class="body-part" data-part="lung" cx="120" cy="125" rx="14" ry="18" fill="#93C5FD"
                             stroke="#3B82F6" stroke-width="1"/>
                    <path class="body-part" data-part="heart"
                          d="M100,116 C100,109 91,104 85,109 C79,114 81,121 89,127 L100,135 L111,127 C119,121 121,114 115,109 C109,104 100,109 100,116Z"
                          fill="#F87171" stroke="#DC2626" stroke-width="1"/>
                    <text x="100" y="125" text-anchor="middle" font-size="7" fill="#7F1D1D" pointer-events="none">심장
                    </text>
                    <ellipse class="body-part" data-part="liver" cx="116" cy="152" rx="16" ry="11" fill="#6EE7B7"
                             stroke="#10B981" stroke-width="1"/>
                    <text x="116" y="156" text-anchor="middle" font-size="7" fill="#065F46" pointer-events="none">간
                    </text>
                    <ellipse class="body-part" data-part="stomach" cx="86" cy="158" rx="13" ry="9" fill="#FDE68A"
                             stroke="#F59E0B" stroke-width="1"/>
                    <text x="86" y="162" text-anchor="middle" font-size="7" fill="#78350F" pointer-events="none">위
                    </text>
                    <ellipse class="body-part" data-part="intestine" cx="100" cy="176" rx="22" ry="13" fill="#DDD6FE"
                             stroke="#7C3AED" stroke-width="1"/>
                    <text x="100" y="180" text-anchor="middle" font-size="7" fill="#4C1D95" pointer-events="none">장
                    </text>
                    <rect class="body-part" data-part="muscle" x="42" y="104" width="18" height="62" rx="9"
                          fill="#FCA5A5" stroke="#EF4444" stroke-width="1"/>
                    <rect class="body-part" data-part="muscle" x="140" y="104" width="18" height="62" rx="9"
                          fill="#FCA5A5" stroke="#EF4444" stroke-width="1"/>
                    <rect class="body-part" data-part="muscle" x="68" y="192" width="26" height="54" rx="10"
                          fill="#FCA5A5" stroke="#EF4444" stroke-width="1"/>
                    <rect class="body-part" data-part="muscle" x="106" y="192" width="26" height="54" rx="10"
                          fill="#FCA5A5" stroke="#EF4444" stroke-width="1"/>
                    <text x="100" y="222" text-anchor="middle" font-size="7" fill="#7F1D1D" pointer-events="none">근육
                    </text>
                    <rect class="body-part" data-part="bone" x="73" y="250" width="18" height="70" rx="8" fill="#E2E8F0"
                          stroke="#94A3B8" stroke-width="1"/>
                    <rect class="body-part" data-part="bone" x="109" y="250" width="18" height="70" rx="8"
                          fill="#E2E8F0" stroke="#94A3B8" stroke-width="1"/>
                    <text x="100" y="292" text-anchor="middle" font-size="7" fill="#1E293B" pointer-events="none">뼈
                    </text>
                    <ellipse cx="82" cy="326" rx="14" ry="7" fill="#E2E8F0" stroke="#94A3B8" stroke-width=".8"/>
                    <ellipse cx="118" cy="326" rx="14" ry="7" fill="#E2E8F0" stroke="#94A3B8" stroke-width=".8"/>
                </svg>
            </div>

            <%-- 체크박스 부위 선택 --%>
            <div class="cb-section">
                <div class="cb-title">부위 선택</div>
                <div class="cb-grid" id="cb-grid"></div>
                <div class="cb-actions">
                    <button class="cb-btn" onclick="resetAll()">초기화</button>
                    <button class="cb-btn primary" onclick="collectAll()">ALL</button>
                </div>
            </div>
        </div>

        <%-- 오른쪽: 영양제 리스트 (웹) / 아래: 리스트 (앱) --%>
        <div class="col-right">
            <div class="panel">
                <div class="panel-top">
                    <span class="panel-title" id="panel-title">부위를 선택하세요</span>
                    <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
                        <div class="sort-bar">
                            <button class="sort-btn" onclick="setSort('view',this)">조회순</button>
                            <button class="sort-btn" onclick="setSort('like',this)">인기순</button>
                        </div>
                        <%-- 관리자 세션일 때만 표시 --%>
                        <c:if test="${sessionScope.isAdmin == true}">
                            <button id="adminToggleBtn" onclick="toggleAdminMode()"
                                    style="padding:6px 14px; background:#FF9800; color:white;
                           border:none; border-radius:6px; cursor:pointer;
                           font-size:0.82em; font-weight:600; transition:background 0.2s;">
                                🛠️ 관리 모드
                            </button>
                            <button id="adminAddBtn" onclick="openAdminModal('insert')"
                                    style="display:none; padding:6px 14px; background:#4CAF50; color:white;
                           border:none; border-radius:6px; cursor:pointer;
                           font-size:0.82em; font-weight:600;">
                                + 영양소 추가
                            </button>
                        </c:if>
                    </div>
                </div>
                <div class="tags" id="tag-area"></div>
                <div id="list-area">
                    <p class="empty-msg">신체 부위를 선택하면 영양제 목록이 나타납니다.</p>
                </div>
                <div id="paging-area"></div>
            </div>
        </div>

    </div>

    <%-- 모달 영역 --%>
    <div id="modal-area"></div>
    <div id="login-modal-area"></div>
</div>
<%-- ===== 관리자 CRUD 모달 (isAdmin일 때만 렌더) ===== --%>
<c:if test="${sessionScope.isAdmin == true}">
    <div id="adminModalOverlay"
         style="display:none; position:fixed; inset:0;
            background:rgba(0,0,0,0.55); z-index:10001;
            justify-content:center; align-items:center; padding:16px;"
         onclick="if(event.target===this) closeAdminModal()">

        <div style="background:#fff; border-radius:14px; padding:28px 24px;
                width:min(500px,95vw); max-height:88vh; overflow-y:auto;
                position:relative; box-shadow:0 12px 30px rgba(0,0,0,0.2);">

                <%-- 닫기 버튼 --%>
            <button onclick="closeAdminModal()"
                    style="position:absolute; top:14px; right:16px;
                       background:none; border:none; font-size:1.5em;
                       cursor:pointer; color:#999; line-height:1;">✕
            </button>

            <h3 id="adminModalTitle"
                style="margin:0 0 20px; font-size:1.1em; color:#333;">➕ 영양소 등록</h3>

                <%-- hidden 값 --%>
            <input type="hidden" id="adminAction" value="insert">
            <input type="hidden" id="adminSuppId" value="">

            <div style="display:flex; flex-direction:column; gap:14px;">

                <div>
                    <label style="display:block; font-size:0.85em; font-weight:700;
                               color:#555; margin-bottom:5px;">영양소 이름 *</label>
                    <input id="adminName" type="text" placeholder="예: 루테인"
                           style="width:100%; padding:9px 11px; border:1px solid #ddd;
                              border-radius:7px; font-size:0.95em; box-sizing:border-box;">
                </div>

                <div>
                    <label style="display:block; font-size:0.85em; font-weight:700;
                               color:#555; margin-bottom:5px;">효능 *</label>
                    <textarea id="adminEfficacy" placeholder="예: 눈 건강 보호 및 황반변성 예방"
                              style="width:100%; padding:9px 11px; border:1px solid #ddd;
                                 border-radius:7px; font-size:0.95em; box-sizing:border-box;
                                 height:72px; resize:vertical;"></textarea>
                </div>

                <div>
                    <label style="display:block; font-size:0.85em; font-weight:700;
                               color:#555; margin-bottom:5px;">복용법</label>
                    <input id="adminDosage" type="text" placeholder="예: 하루 1정 (20mg)"
                           style="width:100%; padding:9px 11px; border:1px solid #ddd;
                              border-radius:7px; font-size:0.95em; box-sizing:border-box;">
                </div>

                <div>
                    <label style="display:block; font-size:0.85em; font-weight:700;
                               color:#555; margin-bottom:5px;">복용 시기</label>
                    <input id="adminTiming" type="text" placeholder="예: 식후 복용 권장"
                           style="width:100%; padding:9px 11px; border:1px solid #ddd;
                              border-radius:7px; font-size:0.95em; box-sizing:border-box;">
                </div>

                <div>
                    <label style="display:block; font-size:0.85em; font-weight:700;
                               color:#555; margin-bottom:5px;">주의사항</label>
                    <textarea id="adminCaution" placeholder="예: 과다복용 시 피부 황변 가능"
                              style="width:100%; padding:9px 11px; border:1px solid #ddd;
                                 border-radius:7px; font-size:0.95em; box-sizing:border-box;
                                 height:60px; resize:vertical;"></textarea>
                </div>

                <div>
                    <label style="display:block; font-size:0.85em; font-weight:700;
                               color:#555; margin-bottom:5px;">이미지 경로</label>
                    <input id="adminImgPath" type="text" placeholder="예: images/supp/lutein.png"
                           style="width:100%; padding:9px 11px; border:1px solid #ddd;
                              border-radius:7px; font-size:0.95em; box-sizing:border-box;">
                </div>

                    <%-- 등록 시에만 신체 부위 선택 표시, 수정 시 JS로 숨김 --%>
                <div id="adminBodyIdWrap">
                    <label style="display:block; font-size:0.85em; font-weight:700;
                               color:#555; margin-bottom:5px;">연결할 신체 부위</label>
                    <select id="adminBodyId"
                            style="width:100%; padding:9px 11px; border:1px solid #ddd;
                               border-radius:7px; font-size:0.95em;">
                        <option value="">선택 안함</option>
                        <option value="1">👁️ 눈</option>
                        <option value="2">🥩 간</option>
                        <option value="3">💤 피로개선</option>
                        <option value="4">🦴 뼈/관절</option>
                    </select>
                </div>

            </div>
                <%-- /flex column --%>

                <%-- 하단 버튼 --%>
            <div style="display:flex; gap:10px; margin-top:22px;">
                <button onclick="submitAdminModal()"
                        style="flex:1; padding:11px; background:#4CAF50; color:white;
                           border:none; border-radius:8px; cursor:pointer;
                           font-size:0.98em; font-weight:700;">
                    저장하기
                </button>
                <button onclick="closeAdminModal()"
                        style="padding:11px 22px; background:#f5f5f5; color:#666;
                           border:1px solid #ddd; border-radius:8px; cursor:pointer; font-size:0.95em;">
                    취소
                </button>
            </div>

        </div>
            <%-- /modal box --%>
    </div><%-- /overlay --%>
</c:if>
<script src="js/body.js"></script>
</body>
</html>