<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Groot - 신체별 영양소 추천</title>
    <script src="js/body.js" defer></script>
</head>
<body>
<h2>👤 어떤 부위가 고민이신가요?</h2>

<div id="body-buttons">
    <button onclick="loadSupplements(1)">👁️ 눈</button>
    <button onclick="loadSupplements(2)">🥩 간</button>
    <button onclick="loadSupplements(4)">💤 피로개선</button>
    <button onclick="loadSupplements(5)">🦴 뼈/관절</button>
</div>

<hr>


<%-- ✅ 처음엔 숨기고 목록 로드 후 표시 --%>
<div id="sort-section" style="display:none;">
    <button onclick="changeSort('view')">🔥 많이 본 순</button>
    <button onclick="changeSort('like')">❤️ 인기순</button>
    <hr>
</div>

<div id="result" style="min-height:200px;">
    <p style="color:#999;">신체 부위를 선택하면 영양소 목록이 나타납니다.</p>
</div>
</body>
</html>