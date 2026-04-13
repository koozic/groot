<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<div class="wrap">
    <div class="layout">

        <%-- 왼쪽: SVG + 체크박스 (웹) / 위: SVG + 체크박스 (앱) --%>
        <div class="col-left">

            <%-- SVG 신체 캐릭터 --%>
            <div class="svg-wrap">
                <svg viewBox="0 30 200 280" xmlns="http://www.w3.org/2000/svg">
                    <ellipse class="body-part" data-part="hair" cx="100" cy="30" rx="38" ry="24" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="brain" cx="100" cy="30" rx="26" ry="16" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="skin" cx="100" cy="66" rx="30" ry="22" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="eye" cx="80" cy="64" rx="8" ry="8" fill="transparent"
                             stroke="none"/>
                    <ellipse class="body-part" data-part="eye" cx="118" cy="64" rx="8" ry="8" fill="transparent"
                             stroke="none"/>

                    <rect x="86" y="88" width="28" height="14" rx="5" fill="transparent"
                          stroke="none"/>
                    <rect class="body-part" data-part="skin" x="62" y="100" width="76" height="88" rx="16"
                          fill="transparent"
                          stroke="none"/>
                    <ellipse class="body-part" data-part="lung" cx="80" cy="125" rx="14" ry="18" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="lung" cx="120" cy="125" rx="14" ry="18" fill="transparent"
                             stroke="none"/>
                    <path class="body-part" data-part="heart"
                          d="M100,116 C100,109 91,104 85,109 C79,114 81,121 89,127 L100,135 L111,127 C119,121 121,114 115,109 C109,104 100,109 100,116Z"
                          fill="transparent"
                          stroke="none"/>

                    <ellipse class="body-part" data-part="liver" cx="94" cy="140" rx="16" ry="11" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="stomach" cx="110" cy="152" rx="13" ry="13" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="intestine" cx="100" cy="170" rx="22" ry="15"
                             fill="transparent"
                             stroke="none"/>

                    <rect class="body-part" data-part="hair" x="52" y="75" width="28" height="27" rx="15"
                          fill="transparent"
                          stroke="none"/>
                    <rect class="body-part" data-part="hair" x="120" y="75" width="28" height="27" rx="15"
                          fill="transparent"
                          stroke="none"/>
                    <rect class="body-part" data-part="muscle" x="68" y="187" width="26" height="50" rx="10"
                          fill="transparent"
                          stroke="none"/>
                    <rect class="body-part" data-part="bone" x="106" y="187" width="26" height="148" rx="10"
                          fill="transparent"
                          stroke="none"/>

                    <rect class="body-part" data-part="bone" x="73" y="235" width="18" height="98" rx="8"
                          fill="transparent"
                          stroke="none"/>

                </svg>
            </div>

            <%-- 체크박스 부위 선택 --%>
        </div>

        <%-- 오른쪽: 영양제 리스트 (웹) / 아래: 리스트 (앱) --%>
        <div class="col-right">
            <div class="cb-section">
                <div class="cb-title">부위 선택</div>
                <div class="cb-grid" id="cb-grid"></div>
                <div class="cb-actions">
                    <button class="cb-btn" onclick="resetAll()">초기화</button>
                    <button class="cb-btn primary" onclick="collectAll()">ALL</button>
                </div>
            </div>
            <br>
            <div class="panel">
                <div class="panel-top">
                    <span class="panel-title" id="panel-title">부위를 선택하세요</span>
                    <div class="panel-btn-group">   <%-- style 인라인 제거, 클래스로 교체 --%>
                        <div class="sort-bar">
                            <button class="sort-btn" onclick="setSort('view',this)">조회순</button>
                            <button class="sort-btn" onclick="setSort('like',this)">인기순</button>
                        </div>
                        <c:if test="${sessionScope.isAdmin == true}">
                            <button id="adminToggleBtn" onclick="toggleAdminMode()"
                                    class="admin-toggle-btn">
                                🛠️ 관리 모드
                            </button>
                            <button id="adminAddBtn" onclick="openAdminModal('insert')"
                                    class="admin-add-btn" style="display:none;">
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
                        <option value="1">💇 머리카락 (hair)</option>
                        <option value="2">🧴 피부 (skin)</option>
                        <option value="3">👁️ 눈 (eye)</option>
                        <option value="4">🧠 뇌 (brain)</option>
                        <option value="5">🫁 폐 (lung)</option>
                        <option value="6">❤️ 심장 (heart)</option>
                        <option value="7">🫀 간 (liver)</option>
                        <option value="8">🫃 위 (stomach)</option>
                        <option value="9">🌀 장 (intestine)</option>
                        <option value="10">🦴 뼈 (bone)</option>
                        <option value="11">💪 근육 (muscle)</option>
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
