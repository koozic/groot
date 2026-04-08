<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>${detail.supplementName} 상세정보</title>
</head>
<body>
<h2>💊 영양소 상세 정보</h2>
<hr>
<div class="detail-container">
    <img src="${d.supplementImagePath}" width="250" onerror="this.src='images/default.png'"><br>

    <h3>${d.supplementName}</h3>
    <p><strong>효능:</strong> ${d.supplementEfficacy}</p>
    <p><strong>복용법:</strong> ${d.supplementDosage}</p>
    <p><strong>권장 시간:</strong> ${d.supplementTiming}</p>
    <p><strong>주의사항:</strong> <span style="color:red;">${d.supplementCaution}</span></p>

    <hr>
    <p>👁️ 조회수: ${d.supplementViewCount} | ❤️ 좋아요: ${d.likeCount}</p>
    <p>📅 등록일: ${d.supplementRegDate}</p>
</div>

<button onclick="history.back()">뒤로가기</button>
<button onclick="location.href='body_view'">메인으로</button>
</body>
</html>