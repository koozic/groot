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
    <link rel="stylesheet" href="css/body.css">
    <link rel="stylesheet" href="../css/body-theme-v10.css">
</head>
<body>
<div class="wrap">
    <div class="layout">

        <div class="col-left">
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
                             fill="transparent" stroke="none"/>
                    <rect class="body-part" data-part="hair" x="50" y="61" width="28" height="27" rx="15"
                          fill="transparent" stroke="none"/>
                    <rect class="body-part" data-part="hair" x="118" y="61" width="28" height="27" rx="15"
                          fill="transparent" stroke="none"/>
                    <rect class="body-part" data-part="muscle" x="64" y="153" width="26" height="90" rx="15"
                          fill="transparent" stroke="none"/>
                    <rect class="body-part" data-part="bone" x="102" y="173" width="26" height="187" rx="10"
                          fill="transparent" stroke="none"/>
                    <rect class="body-part" data-part="bone" x="73" y="245" width="18" height="115" rx="8"
                          fill="transparent" stroke="none"/>
                </svg>
            </div>
        </div>

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
                    <div class="panel-btn-group">
                        <div class="sort-bar">
                            <button class="sort-btn" onclick="setSort('view',this)">조회순</button>
                            <button class="sort-btn" onclick="setSort('like',this)">인기순</button>
                        </div>
                        <c:if test="${sessionScope.isAdmin == true}">
                            <button id="adminToggleBtn" onclick="toggleAdminMode()"
                                    class="admin-toggle-btn">
                                🛠️ 관리 모드
                            </button>
                            <%-- display:none → JS가 제어하므로 인라인으로 유지 --%>
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

    <div id="modal-area"></div>
    <div id="login-modal-area"></div>
</div>

<%-- 관리자 모달 --%>
<c:if test="${sessionScope.isAdmin == true}">
    <div id="adminModalOverlay"
         class="admin-modal-overlay"
         onclick="if(event.target===this) closeAdminModal()">
        <div class="admin-modal-content">

            <button onclick="closeAdminModal()" class="modal-close-btn">✕</button>

            <h3 id="adminModalTitle" class="modal-title">➕ 영양소 등록</h3>

            <input type="hidden" id="adminAction" value="insert">
            <input type="hidden" id="adminSuppId" value="">

            <div class="modal-form">
                <div class="modal-field">
                    <label class="modal-label">영양소 이름 *</label>
                    <input id="adminName" type="text" class="modal-input">
                </div>

                <div class="modal-field">
                    <label class="modal-label">효능 *</label>
                    <textarea id="adminEfficacy" class="modal-textarea"></textarea>
                </div>

                <div class="modal-grid2">
                    <div class="modal-field">
                        <label class="modal-label">복용법</label>
                        <input id="adminDosage" type="text" class="modal-input">
                    </div>
                    <div class="modal-field">
                        <label class="modal-label">복용 시기</label>
                        <input id="adminTiming" type="text" class="modal-input">
                    </div>
                </div>

                <div class="modal-field">
                    <label class="modal-label">주의사항</label>
                    <textarea id="adminCaution" class="modal-textarea modal-textarea-sm"></textarea>
                </div>

                <div id="adminBodyIdWrap" class="modal-field">
                    <label class="modal-label">연결할 신체 부위</label>
                    <select id="adminBodyId" class="modal-select">
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

            <div class="modal-btn-row">
                <button onclick="submitAdminModal()" class="modal-submit-btn">저장하기</button>
                <button onclick="closeAdminModal()" class="modal-cancel-btn">취소</button>
            </div>

        </div>
    </div>
</c:if>

</body>
</html>