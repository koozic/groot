<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>약쟁이 로그인</title>
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">

</head>
<body>

<div class="login-page">
    <div class="login-wrap">

        <div class="login-left">
            <div class="login-title-box">
                <h1 class="login-title">약쟁이</h1>
                <p class="login-subtitle">당신의 건강을 챙기는 영양제 습관</p>
            </div>

            <div class="login-img-box">
                <img src="${pageContext.request.contextPath}/img/pill.png" alt="알약 이미지" class="login-pill-img">
                <img src="${pageContext.request.contextPath}/img/bottle.png" alt="영양제 통 이미지" class="login-bottle-img">
            </div>
        </div>

        <div class="login-right">
            <div class="login-form-box">
                <h2 class="login-form-title">로그인</h2>

                <div class="login-msg">
                    ${loginMsg}
                </div>

                <form action="${pageContext.request.contextPath}/user-Login" method="post">
                    <div class="login-input-group">
                        <label for="user_id">아이디</label>
                        <input type="text" id="user_id" name="user_id" placeholder="아이디를 입력하세요" required>
                    </div>

                    <div class="login-input-group">
                        <label for="user_pw">비밀번호</label>
                        <input type="password" id="user_pw" name="user_pw" placeholder="비밀번호를 입력하세요" required>
                    </div>

                    <button class="login-btn">로그인</button>
                </form>

                <div class="login-bottom">
                    <span>회원이 아니신가요?</span>
                    <a href="${pageContext.request.contextPath}/join" class="join-link">회원가입</a>
                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>
