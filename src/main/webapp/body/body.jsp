<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>

    <script>
        /* 세션에 저장된 user 객체에서 아이디를 가져와 'admin'인지 확인합니다.
           이전 질문에서 getId() 오류가 났으므로, 실제 UserDTO의 필드명인 getUser_id()
           또는 getUserId() 중 맞는 것을 사용하세요. (여기선 일반적인 getUserId로 예시)
        */
        const isAdmin = ${not empty sessionScope.user and sessionScope.user.userId == 'admin' ? true : false};

        // 만약 UserDTO 필드명이 user_id라면 아래처럼 쓰세요:
        // const isAdmin = ${not empty sessionScope.user and sessionScope.user.user_id == 'admin' ? true : false};
    </script>

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