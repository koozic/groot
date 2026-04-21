<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (request.getAttribute("content") == null) {
        String target = request.getContextPath() + "/user-Login";
        String redirect = request.getParameter("redirect");
        if (redirect != null && !redirect.trim().isEmpty()) {
            target += "?redirect=" + java.net.URLEncoder.encode(redirect, java.nio.charset.StandardCharsets.UTF_8);
        }
        response.sendRedirect(target);
        return;
    }
%>



<!DOCTYPE html>
<html>
<head>
    <title>OtterCare 로그인</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/site-theme.css">


</head>
<body>

<!-- 1. 배경 비디오 추가 -->
<div class="video-background">
    <!--
       autoplay: 자동 재생
       muted: 소리 끔 (크롬 등에서 자동 재생을 위해 필수)
       loop: 무한 반복
       playsinline: 모바일 환경 대응
    -->
    <video autoplay muted loop playsinline id="bg-video">
        <source src="${pageContext.request.contextPath}/video/login_sea.mp4" type="video/mp4">
    </video>
</div>
<div class="login-wrapper">
    <div class="login-page2">
        <div class="login-wrap glass-effect">

            <div class="login-left">
                <div class="login-title-box">
                    <h1 class="login-title">OtterCare</h1>
                    <p class="login-subtitle">당신의 건강을 챙기는 영양제 습관</p>

                </div>

                <div class="login-img-box">
                    <img src="${pageContext.request.contextPath}/img/ottos/haribo_otter.png" alt="알약 이미지"
                         class="login-haribo_otto-img">
                </div>
            </div>

            <div class="login-right">
                <div class="login-form-box">
                    <h2 class="login-form-title">로그인</h2>

                    <div class="login-msg">
                        ${loginMsg}
                    </div>

                    <form action="${pageContext.request.contextPath}/user-Login" method="post">
                        <%-- 로그인 후 돌아갈 페이지 유지 (body_view 등) --%>
                        <input type="hidden" name="redirect" value="${param.redirect}">

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
</div>
</body>
</html>
