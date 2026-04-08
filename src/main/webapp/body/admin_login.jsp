<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>관리자 로그인</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            font-family: sans-serif;
            background: #f5f5f5;
        }

        .box {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            width: 320px;
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
        }

        input {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }

        button {
            width: 100%;
            padding: 12px;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
        }

        .error {
            color: red;
            text-align: center;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<div class="box">
    <h2>🛠️ 관리자 로그인</h2>

    <%-- 로그인 실패 메시지 --%>
    <c:if test="${not empty errorMsg}">
        <p class="error">${errorMsg}</p>
    </c:if>

    <form action="admin_login" method="post">
        <input type="text" name="adminId"
               placeholder="관리자 ID" required>
        <input type="password" name="adminPw"
               placeholder="비밀번호" required>
        <button type="submit">로그인</button>
    </form>
</div>
</body>
</html>