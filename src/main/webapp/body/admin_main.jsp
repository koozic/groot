<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- <html><head><body> 없음 — index.jsp의 <jsp:include>로 삽입됩니다 --%>

<style>
    .admin-wrap {
        padding: 24px;
        max-width: 1100px;
        margin: 0 auto;
    }

    /* 상단 바 */
    .admin-top-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        margin-bottom: 18px;
    }

    .admin-top-bar h2 {
        margin: 0;
        font-size: 1.2em;
        color: #333;
    }

    /* 총 개수 뱃지 */
    .count-badge {
        display: inline-block;
        background: #e8f5e9;
        color: #2E7D32;
        padding: 2px 10px;
        border-radius: 20px;
        font-size: 0.85em;
        font-weight: 600;
        margin-left: 8px;
    }

    /* 정렬 셀렉트 */
    .sort-select-wrap {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.9em;
        color: #555;
    }

    .sort-select-wrap select {
        padding: 7px 12px;
        border: 1px solid #ddd;
        border-radius: 7px;
        font-size: 0.92em;
        cursor: pointer;
        background: #fff;
        outline: none;
    }

    .sort-select-wrap select:focus {
        border-color: #4CAF50;
    }

    /* 등록 버튼 */
    .btn-add {
        padding: 8px 18px;
        background: #4CAF50;
        color: white;
        border: none;
        border-radius: 7px;
        cursor: pointer;
        font-size: 0.92em;
        font-weight: 600;
        text-decoration: none;
        display: inline-block;
        transition: background 0.2s;
    }

    .btn-add:hover {
        background: #43A047;
    }

    /* 테이블 */
    .admin-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.92em;
    }

    .admin-table th,
    .admin-table td {
        border: 1px solid #e8e8e8;
        padding: 10px 12px;
        text-align: center;
        vertical-align: middle;
    }

    .admin-table th {
        background: #f7f7f7;
        color: #444;
        font-weight: 700;
        white-space: nowrap;
    }

    /* 현재 정렬 기준 컬럼 초록 하이라이트 */
    .admin-table th.sort-active {
        background: #E8F5E9;
        color: #2E7D32;
    }

    .admin-table tr:hover td {
        background: #fafafa;
    }

    /* 관리 버튼 */
    .btn {
        padding: 5px 13px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-size: 0.85em;
        font-weight: 600;
    }

    .btn-edit {
        background: #2196F3;
        color: white;
    }

    .btn-edit:hover {
        background: #1976D2;
    }

    .btn-del {
        background: #f44336;
        color: white;
    }

    .btn-del:hover {
        background: #D32F2F;
    }

    /* ── 모바일 대응 (680px 이하) ── */
    @media (max-width: 680px) {

        .admin-wrap {
            padding: 14px 12px;
        }

        /* 상단 바 세로 배치 */
        .admin-top-bar {
            flex-direction: column;
            align-items: flex-start;
            gap: 10px;
        }

        /* 정렬 + 등록버튼 묶음 세로 배치 */
        .admin-top-bar > div:last-child {
            flex-direction: column;
            align-items: flex-start;
            width: 100%;
            gap: 8px;
        }

        /* 정렬 셀렉트 전체 너비 */
        .sort-select-wrap {
            width: 100%;
        }

        .sort-select-wrap select {
            flex: 1;
            width: 100%;
        }

        /* 등록 버튼 전체 너비 */
        .btn-add {
            width: 100%;
            text-align: center;
            padding: 10px;
        }

        /* 테이블 — 가로 스크롤 */
        .admin-table-wrap {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        .admin-table {
            min-width: 560px; /* 최소 너비 — 이 이하로는 안 줄어들고 스크롤 */
            font-size: 0.82em;
        }

        .admin-table th,
        .admin-table td {
            padding: 8px 8px;
            white-space: nowrap;
        }

        /* 효능 컬럼 최대 너비 제한 */
        .admin-table td:nth-child(3) {
            max-width: 120px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
    }
</style>

<div class="admin-wrap">

    <%-- ── 상단 바 ── --%>
    <div class="admin-top-bar">

        <%-- 제목 + 총 개수 --%>
        <div style="display:flex; align-items:center;">
            <h2>🛠️ 영양소 관리</h2>
            <span class="count-badge">총 ${suppList.size()}개</span>
        </div>

        <%-- 정렬 + 등록 버튼 --%>
        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">

            <div class="sort-select-wrap">
                <span>정렬</span>
                <%-- 셀렉트 변경 시 바로 해당 정렬로 페이지 이동 --%>
                <select onchange="location.href='admin?sortBy=' + this.value">
                    <option value="id_desc"
                    ${sortBy == 'id_desc' || empty sortBy ? 'selected' : ''}>
                        ID 최신순 (기본)
                    </option>
                    <option value="id_asc"
                    ${sortBy == 'id_asc' ? 'selected' : ''}>
                        ID 오래된순
                    </option>
                    <option value="date_desc"
                    ${sortBy == 'date_desc' ? 'selected' : ''}>
                        등록일 최신순
                    </option>
                    <option value="date_asc"
                    ${sortBy == 'date_asc' ? 'selected' : ''}>
                        등록일 오래된순
                    </option>
                    <option value="name_asc"
                    ${sortBy == 'name_asc' ? 'selected' : ''}>
                        이름 가나다순
                    </option>
                </select>
            </div>

            <button type="button" class="btn-add"
                    onclick="openAdminModal('insert')">
                + 새 영양소 등록
            </button>
        </div>

    </div>
    <%-- /admin-top-bar --%>

    <%-- ── 테이블 ── --%>
    <div class="admin-table-wrap">
        <table class="admin-table">
            <thead>
            <tr>
                <%-- 현재 정렬 기준 컬럼에 sort-active 클래스 + 화살표 표시 --%>
                <th class="${(sortBy == 'id_desc' || sortBy == 'id_asc' || empty sortBy) ? 'sort-active' : ''}">
                    ID
                    <c:choose>
                        <c:when test="${sortBy == 'id_asc'}">▲</c:when>
                        <c:otherwise>▼</c:otherwise><%-- 기본 id_desc --%>
                    </c:choose>
                </th>
                <th class="${sortBy == 'name_asc' ? 'sort-active' : ''}">
                    이름
                    <c:if test="${sortBy == 'name_asc'}">▲</c:if>
                </th>
                <th>효능</th>
                <th>이미지</th>
                <th>조회수</th>
                <th class="${(sortBy == 'date_desc' || sortBy == 'date_asc') ? 'sort-active' : ''}">
                    등록일
                    <c:choose>
                        <c:when test="${sortBy == 'date_asc'}">▲</c:when>
                        <c:when test="${sortBy == 'date_desc'}">▼</c:when>
                    </c:choose>
                </th>
                <th>관리</th>
            </tr>
            </thead>
            <tbody>
            <c:choose>
                <c:when test="${empty suppList}">
                    <tr>
                        <td colspan="7"
                            style="padding:30px; color:#999; font-size:0.95em;">
                            등록된 영양소가 없습니다.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach var="s" items="${suppList}">
                        <tr>
                            <td style="color:#999; font-size:0.85em;">${s.supplementId}</td>
                            <td style="font-weight:600; text-align:left;">${s.supplementName}</td>
                            <td style="text-align:left; max-width:220px;
                                       overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                    ${s.supplementEfficacy}
                            </td>
                            <td>
                                <img src="${s.supplementImagePath}" width="50" height="50"
                                     style="object-fit:cover; border-radius:6px;"
                                     onerror="this.style.display='none'">
                            </td>
                            <td style="color:#777;">${s.supplementViewCount}</td>
                            <td style="color:#777; font-size:0.88em;">${s.supplementRegDate}</td>
                            <td style="white-space:nowrap;">
                                <button type="button" class="btn btn-edit"
                                        onclick="openAdminModal('update', ${s.supplementId})">
                                    수정
                                </button>
                                &nbsp;
                                <button type="button" class="btn btn-del"
                                        onclick="deleteSupp(${s.supplementId}, '${s.supplementName}', this)">
                                    삭제
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
            </tbody>
        </table>
    </div>

</div><%-- /admin-wrap --%>
<%-- ===== 관리자 모달 (admin_main.jsp 전용) ===== --%>
<div id="adminModalOverlay"
     style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.6);
            z-index:99999; justify-content:center; align-items:center; padding:20px;"
     onclick="if(event.target===this) closeAdminModal()">
    <div style="background:#fff; border-radius:14px; padding:30px; width:100%;
                max-width:550px; max-height:90vh; overflow-y:auto; position:relative;
                box-shadow:0 15px 35px rgba(0,0,0,0.3);">

        <button onclick="closeAdminModal()"
                style="position:absolute; top:16px; right:16px; background:none;
                       border:none; font-size:1.5em; cursor:pointer; color:#bbb;">✕
        </button>

        <h3 id="adminModalTitle" style="margin-top:0; margin-bottom:25px;">➕ 영양소 등록</h3>

        <input type="hidden" id="adminAction" value="insert">
        <input type="hidden" id="adminSuppId" value="">

        <div style="display:flex; flex-direction:column; gap:16px;">
            <div>
                <label style="display:block; font-weight:700; margin-bottom:6px; font-size:0.9em;">영양소 이름 *</label>
                <input id="adminName" type="text"
                       style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;">
            </div>
            <div>
                <label style="display:block; font-weight:700; margin-bottom:6px; font-size:0.9em;">효능 *</label>
                <textarea id="adminEfficacy"
                          style="width:100%; height:80px; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box; resize:none;"></textarea>
            </div>
            <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                <div>
                    <label style="display:block; font-weight:700; margin-bottom:6px; font-size:0.9em;">복용법</label>
                    <input id="adminDosage" type="text"
                           style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;">
                </div>
                <div>
                    <label style="display:block; font-weight:700; margin-bottom:6px; font-size:0.9em;">복용 시기</label>
                    <input id="adminTiming" type="text"
                           style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;">
                </div>
            </div>
            <div>
                <label style="display:block; font-weight:700; margin-bottom:6px; font-size:0.9em;">주의사항</label>
                <textarea id="adminCaution"
                          style="width:100%; height:60px; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box; resize:none;"></textarea>
            </div>
            <div>
                <label style="display:block; font-weight:700; margin-bottom:6px; font-size:0.9em;">이미지 경로</label>
                <input id="adminImgPath" type="text"
                       style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px; box-sizing:border-box;">
            </div>
            <div id="adminBodyIdWrap">
                <label style="display:block; font-weight:700; margin-bottom:6px; font-size:0.9em;">연결할 신체 부위</label>
                <select id="adminBodyId"
                        style="width:100%; padding:10px; border:1px solid #ddd; border-radius:8px;">
                    <option value="">선택 안함</option>
                    <option value="1">💇 머리카락</option>
                    <option value="2">🧴 피부</option>
                    <option value="3">👁️ 눈</option>
                    <option value="4">🧠 뇌</option>
                    <option value="5">🫁 폐</option>
                    <option value="6">❤️ 심장</option>
                    <option value="7">🫀 간</option>
                    <option value="8">🫃 위</option>
                    <option value="9">🌀 장</option>
                    <option value="10">🦴 뼈</option>
                    <option value="11">💪 근육</option>
                </select>
            </div>
        </div>

        <div style="display:flex; gap:12px; margin-top:30px;">
            <button onclick="submitAdminModal()"
                    style="flex:1; padding:13px; background:#4CAF50; color:white;
                           border:none; border-radius:8px; font-weight:700; cursor:pointer;">저장하기
            </button>
            <button onclick="closeAdminModal()"
                    style="padding:13px 25px; background:#eee; border:none;
                           border-radius:8px; cursor:pointer;">취소
            </button>
        </div>
    </div>
</div>

<script>
    function openAdminModal(mode, suppId) {
        const overlay = document.getElementById('adminModalOverlay');
        overlay.style.display = 'flex';
        document.body.style.overflow = 'hidden';

        document.getElementById('adminAction').value = mode;
        document.getElementById('adminSuppId').value = suppId || '';

        const bodyIdWrap = document.getElementById('adminBodyIdWrap');

        if (mode === 'update') {
            document.getElementById('adminModalTitle').textContent = '✏️ 영양소 수정';
            if (bodyIdWrap) bodyIdWrap.style.display = 'none'; // 수정 시 부위 선택 숨김

            fetch('admin?action=getOne&suppId=' + suppId)
                .then(res => res.json())
                .then(res => {
                    if (!res.success) {
                        alert(res.message);
                        return;
                    }
                    const d = res.data;
                    document.getElementById('adminName').value = d.supplementName || '';
                    document.getElementById('adminEfficacy').value = d.supplementEfficacy || '';
                    document.getElementById('adminDosage').value = d.supplementDosage || '';
                    document.getElementById('adminTiming').value = d.supplementTiming || '';
                    document.getElementById('adminCaution').value = d.supplementCaution || '';
                    document.getElementById('adminImgPath').value = d.supplementImagePath || '';
                });
        } else {
            document.getElementById('adminModalTitle').textContent = '➕ 새 영양소 등록';
            if (bodyIdWrap) bodyIdWrap.style.display = 'block';
            ['adminName', 'adminEfficacy', 'adminDosage', 'adminTiming', 'adminCaution', 'adminImgPath']
                .forEach(id => document.getElementById(id).value = '');
        }
    }

    function closeAdminModal() {
        document.getElementById('adminModalOverlay').style.display = 'none';
        document.body.style.overflow = '';
    }

    function submitAdminModal() {
        const action = document.getElementById('adminAction').value;
        const suppId = document.getElementById('adminSuppId').value;
        const bodyIdEl = document.getElementById('adminBodyId');

        const payload = {
            action: action,
            suppId: suppId,
            supplementName: document.getElementById('adminName').value.trim(),
            supplementEfficacy: document.getElementById('adminEfficacy').value.trim(),
            supplementDosage: document.getElementById('adminDosage').value.trim(),
            supplementTiming: document.getElementById('adminTiming').value.trim(),
            supplementCaution: document.getElementById('adminCaution').value.trim(),
            supplementImagePath: document.getElementById('adminImgPath').value.trim(),
            bodyId: bodyIdEl ? bodyIdEl.value : ''
        };

        fetch('admin', {
            method: 'POST',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: JSON.stringify(payload)
        })
            .then(r => r.json())
            .then(data => {
                alert(data.message);
                if (data.success) location.reload();
            })
            .catch(err => alert('오류: ' + err));
    }

    function deleteSupp(suppId, suppName, btn) {
        if (!confirm('"' + suppName + '"을(를) 삭제하시겠습니까?')) return;

        fetch('admin', {
            method: 'POST',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: JSON.stringify({action: 'delete', suppId: suppId})
        })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    btn.closest('tr').remove();
                } else {
                    alert(data.message);
                }
            })
            .catch(err => alert('오류: ' + err));
    }
</script>