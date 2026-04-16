<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <link rel="icon" type="image/png"
          href="${pageContext.request.contextPath}/img/favicon.png">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OTTERCARE</title>
</head>
<body>
<div class="wrap">
    <div class="layout">

        <%-- 왼쪽: SVG + 체크박스 (웹) / 위: SVG + 체크박스 (앱) --%>
        <div class="col-left">

            <%-- SVG 신체 캐릭터 --%>
            <div class="svg-wrap">
                <svg viewBox="0 30 200 280" xmlns="http://www.w3.org/2000/svg">
                    <ellipse class="body-part" data-part="hair" cx="98" cy="16" rx="38" ry="24" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="brain" cx="98" cy="16" rx="26" ry="16" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="skin" cx="98" cy="52" rx="30" ry="22" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="eye" cx="78" cy="50" rx="8" ry="8" fill="transparent"
                             stroke="none"/>
                    <ellipse class="body-part" data-part="eye" cx="116" cy="50" rx="8" ry="8" fill="transparent"
                             stroke="none"/>


                    <ellipse class="body-part" data-part="lung" cx="80" cy="105" rx="14" ry="18" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="lung" cx="120" cy="105" rx="14" ry="18" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="heart" cx="100" cy="105" rx="13" ry="13" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="liver" cx="90" cy="125" rx="16" ry="11" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="stomach" cx="108" cy="134" rx="13" ry="13" fill="transparent"
                             stroke="none"/>

                    <ellipse class="body-part" data-part="intestine" cx="100" cy="156" rx="22" ry="15"
                             fill="transparent"
                             stroke="none"/>

                    <rect class="body-part" data-part="hair" x="50" y="61" width="28" height="27" rx="15"
                          fill="transparent"
                          stroke="none"/>
                    <rect class="body-part" data-part="hair" x="118" y="61" width="28" height="27" rx="15"
                          fill="transparent"
                          stroke="none"/>
                    <rect class="body-part" data-part="muscle" x="64" y="153" width="26" height="90" rx="15"
                          fill="transparent"
                          stroke="none"/>
                    <rect class="body-part" data-part="bone" x="102" y="173" width="26" height="187" rx="10"
                          fill="transparent"
                          stroke="none"/>

                    <rect class="body-part" data-part="bone" x="73" y="245" width="18" height="115" rx="8"
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
    <div id="adminModalOverlay" class="admin-modal-overlay" onclick="if(event.target===this) closeAdminModal()">
        <div class="admin-modal-content">

                <%-- 닫기 버튼 --%>
            <button onclick="closeAdminModal()"
                    style="position:absolute; top:20px; right:20px; background:none; border:none; font-size:1.5em; cursor:pointer; color:#bbb;">
                ✕
            </button>

            <h3 id="adminModalTitle" style="margin-top:0; margin-bottom:25px; font-size:1.2em;">➕ 영양소 등록</h3>

            <input type="hidden" id="adminAction" value="insert">
            <input type="hidden" id="adminSuppId" value="">

            <div style="display:flex; flex-direction:column; gap:16px;">
                <div>
                    <label style="display:block; font-size:0.9em; font-weight:700; margin-bottom:6px;">영양소 이름 *</label>
                    <input id="adminName" type="text"
                           style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;">
                </div>

                <div>
                    <label style="display:block; font-size:0.9em; font-weight:700; margin-bottom:6px;">효능 *</label>
                    <textarea id="adminEfficacy"
                              style="width:100%; height:80px; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box; resize:none;"></textarea>
                </div>

                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:10px;">
                    <div>
                        <label style="display:block; font-size:0.9em; font-weight:700; margin-bottom:6px;">복용법</label>
                        <input id="adminDosage" type="text"
                               style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;">
                    </div>
                    <div>
                        <label style="display:block; font-size:0.9em; font-weight:700; margin-bottom:6px;">복용 시기</label>
                        <input id="adminTiming" type="text"
                               style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;">
                    </div>
                </div>

                <div>
                    <label style="display:block; font-size:0.9em; font-weight:700; margin-bottom:6px;">주의사항</label>
                    <textarea id="adminCaution"
                              style="width:100%; height:60px; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box; resize:none;"></textarea>
                </div>

                <div id="adminBodyIdWrap">
                    <label style="display:block; font-size:0.9em; font-weight:700; margin-bottom:6px;">연결할 신체 부위</label>
                    <select id="adminBodyId"
                            style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px;">
                        <option value="">선택 안함</option>
                        <c:forEach var="part" items="${partsMap}"> <%-- 기존 로직에 맞춰 option 유지 --%>
                            <option value="${part.value}">${part.label}</option>
                        </c:forEach>
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

            <div style="display:flex; gap:12px; margin-top:30px;">
                <button onclick="submitAdminModal()"
                        style="flex:1; padding:13px; background:#4CAF50; color:white; border:none; border-radius:8px; font-weight:700; cursor:pointer;">
                    저장하기
                </button>
                <button onclick="closeAdminModal()"
                        style="padding:13px 25px; background:#eee; border:none; border-radius:8px; cursor:pointer;">취소
                </button>
            </div>
        </div>
    </div>
    <%-- /overlay --%>
</c:if>
</body>
</html>