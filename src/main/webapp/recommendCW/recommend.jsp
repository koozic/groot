<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Groot - 영양 추천 선택</title>
    <style>
        .select-container { display: flex; justify-content: center; gap: 50px; margin-top: 100px; }
        .select-box {
            width: 300px; padding: 40px; border: 2px solid #eee; border-radius: 20px;
            text-align: center; cursor: pointer; transition: 0.3s;
        }
        .select-box:hover { border-color: #4CAF50; transform: translateY(-10px); }
        .select-box h2 { color: #333; }
        .select-box p { color: #666; }
    </style>
</head>
<body>
<div class="select-container">
    <div class="select-box" onclick="location.href='body_view'">
        <h2>👤 신체별 추천</h2>
        <p>눈, 간, 피부 등 아픈 부위에<br>딱 맞는 영양소를 찾아보세요.</p>
    </div>

    <div class="select-box" onclick="location.href='curation_view'">
        <h2>🤖 AI 테마 추천</h2>
        <p>수험생, 임산부 등 상황에 맞는<br>최적의 조합을 AI가 추천합니다.</p>
    </div>
</div>

<script>
    function goCuration() {
        // 로그인 여부 체크 (세션의 userId가 있는지 확인)
        <% if (session.getAttribute("userId") == null) { %>
        alert("AI 기능은 로그인이 필요합니다.");
        location.href = "login_view"; // 로그인 페이지 URL
        <% } else { %>
        location.href = "curation_view";
        <% } %>
    }
</script>
</body>
</html>