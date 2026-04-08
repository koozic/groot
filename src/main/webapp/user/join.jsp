<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>약쟁이 회원가입</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body>

<div class="login-page">
    <div class="login-wrap">

        <div class="login-left">
            <div class="login-title-box">
                <h1 class="login-title">약쟁이</h1>
                <p class="login-subtitle">건강한 습관의 시작, 회원가입 후 다양한 기능을 이용해보세요.</p>
            </div>

            <div class="login-img-box">
                <img src="${pageContext.request.contextPath}/img/pill.png" alt="알약 이미지" class="login-pill-img">
                <img src="${pageContext.request.contextPath}/img/bottle.png" alt="영양제 통 이미지" class="login-bottle-img">
            </div>
        </div>

        <div class="login-right">
            <div class="login-form-box">
                <h2 class="login-form-title">회원가입</h2>

                <div class="login-msg">
                    ${msg}
                </div>

                <form action="${pageContext.request.contextPath}/join" method="post">

                    <div class="login-input-group">
                        <label for="user_id">아이디</label>
                        <input type="text" id="user_id" name="user_id" placeholder="아이디를 입력하세요" required>
                    </div>

                    <div class="login-input-group">
                        <label for="user_pw">비밀번호</label>
                        <input type="password" id="user_pw" name="user_pw" placeholder="비밀번호를 입력하세요" required>
                    </div>

                    <div class="login-input-group">
                        <label for="user_email">이메일</label>
                        <input type="email" id="user_email" name="user_email" placeholder="이메일을 입력하세요" required>
                    </div>

                    <div class="login-input-group">
                        <label for="email_auth_btn">이메일 본인인증</label>
                        <div style="display:flex; gap:8px;">
                            <input type="button" id="email_auth_btn" value="인증번호 전송" class="login-btn" style="width:40%; height:46px;">
                            <input type="text" name="email_code" placeholder="인증번호 입력" style="width:60%; height:46px; border:1px solid #ddd; border-radius:8px; padding:0 10px;">
                        </div>
                    </div>

                    <div class="login-input-group">
                        <label>성별</label>
                        <div style="display:flex; gap:18px; margin-top:6px;">
                            <label><input type="radio" name="user_gender" value="남" required> 남</label>
                            <label><input type="radio" name="user_gender" value="여"> 여</label>
                        </div>
                    </div>

                    <div class="login-input-group">
                        <label for="user_age">나이</label>
                        <input
                                type="number"
                                id="user_age"
                                name="user_age"
                                placeholder="나이를 입력하세요"
                                min="1"
                                max="120"
                                required
                        >
                    </div>





                    <div class="login-input-group">
                        <label for="user_join_path">이 사이트를 알게 된 경로</label>
                        <select id="user_join_path" name="user_join_path" style="width:100%; height:46px; border:1px solid #ddd; border-radius:8px; padding:0 10px;">
                            <option value="">선택하세요</option>
                            <option value="GOOGLE">구글 검색</option>
                            <option value="YOUTUBE">유튜브</option>
                            <option value="INSTAGRAM">인스타그램</option>
                            <option value="FRIEND">지인 추천</option>
                            <option value="ETC">기타</option>
                        </select>
                    </div>

                    <div class="login-input-group" style="margin-top:14px;">
                        <label style="display:flex; align-items:center; gap:8px; font-size:14px;">
                            <input type="checkbox" name="user_agree" value="Y" required>
                            개인정보 제공에 동의합니다.
                        </label>
                    </div>

                    <button type="submit" class="login-btn">회원가입</button>
                </form>

                <div class="login-bottom">
                    <span>이미 회원이신가요?</span>
                    <a href="${pageContext.request.contextPath}/user-Login" class="join-link">로그인</a>
                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>