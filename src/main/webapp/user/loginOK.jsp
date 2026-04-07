<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
${sessionScope.user.id}(${sessionScope.user.name})님 환영합니다
<button onclick="location.href='user-info'">mypage</button>
<button onclick="location.href='user-Login'">logout</button>
</body>
</html>