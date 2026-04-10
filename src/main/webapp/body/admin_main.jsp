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

            <a href="admin?action=form" class="btn-add">+ 새 영양소 등록</a>
        </div>

    </div>
    <%-- /admin-top-bar --%>

    <%-- ── 테이블 ── --%>
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
                            <a href="admin?action=form&suppId=${s.supplementId}">
                                <button class="btn btn-edit">수정</button>
                            </a>
                            &nbsp;
                            <form action="admin" method="post" style="display:inline"
                                  onsubmit="return confirm('${s.supplementName}을(를) 삭제하시겠습니까?')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="suppId" value="${s.supplementId}">
                                <button type="submit" class="btn btn-del">삭제</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>

</div><%-- /admin-wrap --%>