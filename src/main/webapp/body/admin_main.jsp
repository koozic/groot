<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
  <title>관리자 - 영양소 관리</title>
  <style>
    body { font-family: sans-serif; padding: 20px; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 10px; text-align: center; }
    th { background: #4CAF50; color: white; }
    tr:hover { background: #f5f5f5; }
    .btn { padding: 5px 12px; border: none; border-radius:5px;
      cursor: pointer; font-size: 0.9em; }
    .btn-edit { background: #2196F3; color: white; }
    .btn-del  { background: #f44336; color: white; }
    .btn-add  { background: #4CAF50; color: white;
      padding: 10px 20px; font-size: 1em; }
  </style>
</head>
<body>

<h2>🛠️ 영양소 관리</h2>

<%-- 등록 버튼 --%>
<a href="admin?action=form">
  <button class="btn btn-add">+ 새 영양소 등록</button>
</a>

<table>
  <tr>
    <th>ID</th>
    <th>이름</th>
    <th>효능</th>
    <th>이미지</th>
    <th>조회수</th>
    <th>등록일</th>
    <th>관리</th>
  </tr>

  <%-- JSTL forEach로 목록 출력 --%>
  <c:forEach var="s" items="${suppList}">
    <tr>
      <td>${s.supplementId}</td>
      <td>${s.supplementName}</td>
      <td>${s.supplementEfficacy}</td>
      <td>
        <img src="${s.supplementImagePath}" width="60"
             onerror="this.src='images/default.png'">
      </td>
      <td>${s.supplementViewCount}</td>
      <td>${s.supplementRegDate}</td>
      <td>
          <%-- 수정 버튼 --%>
        <a href="admin?action=form&suppId=${s.supplementId}">
          <button class="btn btn-edit">수정</button>
        </a>

          <%-- 삭제 버튼 --%>
        <form action="admin" method="post" style="display:inline;"
              onsubmit="return confirm('${s.supplementName}을(를) 삭제하시겠습니까?')">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="suppId" value="${s.supplementId}">
          <button type="submit" class="btn btn-del">삭제</button>
        </form>
      </td>
    </tr>
  </c:forEach>
</table>

</body>
</html>