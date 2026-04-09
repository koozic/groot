<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>약쟁이 회원가입</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/app.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
    <style>
        .id-check-btn {
            background-color: #2e7d32;
            color: white;
            border: none;
            padding: 10px 14px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            white-space: nowrap;
        }

        .id-check-btn:hover {
            background-color: #256628;
        }

        #idCheckMsg {
            display: block;
            margin-top: 8px;
            font-size: 13px;
        }




    </style>


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

                <form action="${pageContext.request.contextPath}/join" method="post" enctype="multipart/form-data">

                    <div class="login-input-group">
                        <label for="user_id">아이디</label>
                        <input type="text" id="user_id" name="user_id" placeholder="아이디를 입력하세요" required>
                        <button type="button" class="id-check-btn" onclick="checkUserId()">아이디 중복확인</button>

                        <small id="idCheckMsg"></small>
                        <input type="hidden" id="idCheckResult" value="false">

                    </div>

                    <div class="login-input-group">
                        <label for="user_pw">비밀번호</label>
                        <input type="password" id="user_pw" name="user_pw" placeholder="비밀번호를 입력하세요" required>
                    </div>

                    <div class="login-input-group">
                        <label for="user_name">이름</label>
                        <input
                                type="text"
                                id="user_name"
                                name="user_name"
                                placeholder="이름을 입력하세요"
                                required
                        >
                    </div>



                    <div class="login-input-group">
                        <label for="user_email">이메일</label>
                        <input type="email" id="user_email" name="user_email" placeholder="이메일을 입력하세요" required>
                    </div>

                    <div class="login-input-group">
                        <label for="email_auth_btn">이메일 본인인증</label>
                        <div style="display:flex; gap:8px;">
                            <input type="button"
                                   id="email_auth_btn"
                                   value="인증번호 전송"
                                   class="login-btn"
                                   style="width:40%; height:46px;"
                                   onclick="sendEmailAuth()">

                            <input type="text"
                                   id="email_code"
                                   name="email_code"
                                   placeholder="인증번호 입력"
                                   style="width:60%; height:46px; border:1px solid #ddd; border-radius:8px; padding:0 10px;">
                        </div>

                        <small id="emailAuthMsg"></small>
                        <input type="hidden" id="emailAuthPassed" value="false">
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


                        <!-- 기본 프로필 6개 중 선택 -->
                        <div>
                            <label>
                                <input type="radio" name="default_profile" value="Ayanokoji.jfif" checked>
                                <img src="${pageContext.request.contextPath}/user/userImg/Ayanokoji.jfif" width="80">
                            </label>

                            <label>
                                <input type="radio" name="default_profile" value="Ryuen.jfif">
                                <img src="${pageContext.request.contextPath}/user/userImg/Ryuen.jfif" width="80">
                            </label>

                            <label>
                                <input type="radio" name="default_profile" value="Horikita.jfif">
                                <img src="${pageContext.request.contextPath}/user/userImg/Horikita.jfif" width="80">
                            </label>

                            <!-- 나머지 3개도 동일 -->
                        </div>

                        <!-- 직접 업로드 -->
                        <div>
                            <p>직접 업로드(선택사항)</p>
                            <input type="file" name="user_profile" accept="image/*">
                        </div>


                        <!-- 주소 -->
                    <div class="login-input-group">
                        <label for="user_zipcode">우편번호</label>
                        <div style="display:flex; gap:8px;">
                            <input type="text" id="user_zipcode" name="user_zipcode" placeholder="우편번호" readonly style="width:60%;">
                            <input type="button" value="주소찾기" class="login-btn" style="width:40%; height:46px;" onclick="execDaumPostcode()">
                        </div>
                    </div>

                    <div class="login-input-group">
                        <label for="user_road_address">도로명주소</label>
                        <input type="text" id="user_road_address" name="user_road_address" placeholder="도로명주소" readonly>
                    </div>

                    <div class="login-input-group">
                        <label for="user_detail_address">상세주소</label>
                        <input type="text" id="user_detail_address" name="user_detail_address" placeholder="상세주소를 입력하세요">
                    </div>

                    <div class="login-input-group">
                        <label for="user_extra_address">참고항목</label>
                        <input type="text" id="user_extra_address" name="user_extra_address" placeholder="참고항목" readonly>
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
<script>
<<<<<<< HEAD
    // 1. 파일 업로드 칸과 라디오 버튼들을 찾아서 변수에 담기
    const fileInput = document.querySelector('input[name="user_profile"]');
    const defaultProfiles = document.querySelectorAll('input[name="default_profile"]');
=======
    // 문서의 모든 HTML 요소가 로드된 후 실행되도록 감싸기
    document.addEventListener('DOMContentLoaded', function() {
>>>>>>> d7cf8b58995511605dfbf24f89d12361c334b712

        // 1. 요소 찾기 (안전하게 변수에 담기)
        const fileInput = document.querySelector('input[name="user_profile"]');
        const defaultProfiles = document.querySelectorAll('input[name="default_profile"]');

        // [방어 코드] 요소가 페이지에 존재할 때만 로직 실행
        if (fileInput && defaultProfiles.length > 0) {

            // 2. 사용자가 '파일 업로드'에 사진을 넣었을 때!
            fileInput.addEventListener('change', function() {
                if (this.value) { // 파일이 선택되었다면
                    // 라디오 버튼들의 체크를 전부 해제!
                    defaultProfiles.forEach(function(radio) {
                        radio.checked = false;
                    });
                } else {
                    // 사용자가 파일 선택창을 열었다가 '취소'를 눌러서 파일이 없어지면?
                    // 첫 번째 라디오 버튼(Ayanokoji)을 다시 체크!
                    if (defaultProfiles[0]) {
                        defaultProfiles[0].checked = true;
                    }
                }
            });

            // 3. 사용자가 다시 '기본 이미지(라디오 버튼)'를 클릭했을 때!
            defaultProfiles.forEach(function(radio) {
                radio.addEventListener('click', function() {
                    // 올려뒀던 파일 입력을 초기화!
                    fileInput.value = '';
                });
            });

            console.log("프로필 선택 로직이 성공적으로 연결되었습니다.");

        } else {
            // 요소를 못 찾았을 때 콘솔에 띄워줌 (디버깅용)
            console.error("오류: 프로필 관련 input 요소를 찾을 수 없습니다. HTML의 name 속성을 확인하세요.");
        }
    });
</script>

<script>
    const userIdInput = document.getElementById("user_id");
    const idCheckMsg = document.getElementById("idCheckMsg");
    const idCheckResult = document.getElementById("idCheckResult");

    // 아이디를 다시 입력하면 중복확인 상태 초기화
    userIdInput.addEventListener("input", function () {
        idCheckResult.value = "false";
        idCheckMsg.innerText = "";
    });

    function checkUserId() {
        const userId = userIdInput.value.trim();

        if (userId === "") {
            idCheckMsg.innerText = "아이디를 입력하세요.";
            idCheckMsg.style.color = "red";
            userIdInput.focus();
            return;
        }

        fetch("${pageContext.request.contextPath}/user.id.check?user_id=" + encodeURIComponent(userId))
            .then(function (response) {
                return response.text();
            })
            .then(function (result) {
                console.log("서버 응답값:", "[" + result + "]");

                // 공백/줄바꿈 제거 + 대문자 변환
                result = result.trim().toUpperCase();

                // 사용 가능 처리
                if (result === "OK" || result === "AVAILABLE" || result === "FALSE" || result === "0") {
                    idCheckMsg.innerText = "사용 가능한 아이디입니다.";
                    idCheckMsg.style.color = "green";
                    idCheckResult.value = "true";
                }
                // 중복 처리
                else if (result === "DUPLICATE" || result === "TAKEN" || result === "TRUE" || result === "1") {
                    idCheckMsg.innerText = "이미 사용 중인 아이디입니다.";
                    idCheckMsg.style.color = "red";
                    idCheckResult.value = "false";
                }

            })
            .catch(function (error) {
                console.log(error);
                idCheckMsg.innerText = "중복확인 중 오류가 발생했습니다.";
                idCheckMsg.style.color = "red";
                idCheckResult.value = "false";
            });
    }
</script>

<script>
    function sendEmailAuth() {
        const emailInput = document.getElementById("user_email");   // 네 이메일 input id
        const codeInput = document.getElementById("email_code");
        const msg = document.getElementById("emailAuthMsg");
        const passed = document.getElementById("emailAuthPassed");

        if (!emailInput || emailInput.value.trim() === "") {
            msg.innerText = "이메일을 먼저 입력하세요.";
            msg.style.color = "red";
            return;
        }

        fetch("email-auth-send?user_email=" + encodeURIComponent(emailInput.value.trim()))
            .then(res => res.json())
            .then(data => {
                if (data.result === "success") {
                    codeInput.value = data.authCode;   // 자동으로 인증번호 찍힘
                    msg.innerText = "인증번호가 전송되었습니다.";
                    msg.style.color = "green";
                    passed.value = "true";   // 테스트용이니까 바로 true 처리
                } else {
                    msg.innerText = "인증번호 전송 실패";
                    msg.style.color = "red";
                    passed.value = "false";
                }
            })
            .catch(() => {
                msg.innerText = "오류가 발생했습니다.";
                msg.style.color = "red";
                passed.value = "false";
            });
    }
</script>




</body>
</html>
