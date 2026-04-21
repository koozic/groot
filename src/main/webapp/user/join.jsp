<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (request.getAttribute("content") == null) {
        response.sendRedirect(request.getContextPath() + "/join");
        return;
    }
%>
<style>
    .join-wrap .login-right {
        align-items: center;
    }

    .join-form-box {
        max-width: 460px;
    }

    .join-progress {
        display: flex;
        gap: 10px;
        margin-bottom: 22px;
    }

    .join-progress-step {
        flex: 1 1 0;
        padding: 12px 14px;
        border: 1px solid var(--border);
        border-radius: 14px;
        background: #f8fafc;
        color: var(--text-sub);
        transition: border-color .2s, background .2s, color .2s, transform .2s;
    }

    .join-progress-step strong,
    .join-progress-step span {
        display: block;
    }

    .join-progress-step strong {
        font-size: 12px;
        letter-spacing: .04em;
        text-transform: uppercase;
        margin-bottom: 4px;
    }

    .join-progress-step span {
        font-size: 14px;
        font-weight: 700;
    }

    .join-progress-step.is-current {
        border-color: rgba(37, 99, 235, 0.35);
        background: rgba(37, 99, 235, 0.08);
        color: var(--primary);
        transform: translateY(-1px);
    }

    .join-progress-step.is-done {
        border-color: rgba(22, 163, 74, 0.25);
        background: rgba(22, 163, 74, 0.08);
        color: #15803d;
    }

    .join-step {
        display: none;
    }

    .join-step.is-active {
        display: block;
        animation: joinFadeIn .22s ease;
    }

    .join-step-head {
        margin-bottom: 18px;
    }

    .join-step-badge {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 10px;
        border-radius: 999px;
        background: rgba(37, 99, 235, 0.08);
        color: var(--primary);
        font-size: 12px;
        font-weight: 800;
        margin-bottom: 10px;
    }

    .join-step-title {
        font-size: 26px;
        font-weight: 900;
        letter-spacing: -0.4px;
        margin-bottom: 6px;
        color: var(--text);
    }

    .join-step-copy {
        font-size: 14px;
        line-height: 1.6;
        color: var(--text-sub);
    }

    .join-step-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 0 14px;
    }

    .span-2 {
        grid-column: 1 / -1;
    }

    .field-action-row {
        display: flex;
        gap: 8px;
        align-items: center;
    }

    .field-action-row .field-input {
        flex: 1 1 auto;
        width: auto;
    }

    .field-action-row .login-btn {
        width: 140px;
        min-width: 140px;
        height: 50px;
        margin-top: 0;
        padding: 0 14px;
    }

    .field-msg {
        display: block;
        min-height: 18px;
        margin-top: 8px;
        font-size: 13px;
    }

    .verify-btn {
        margin-top: 10px;
    }

    .radio-inline {
        display: flex;
        gap: 18px;
        align-items: center;
        min-height: 50px;
    }

    .radio-inline label {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 0;
        font-size: 14px;
        color: var(--text);
    }

    .radio-inline input {
        width: auto;
        height: auto;
        padding: 0;
        border: 0;
        box-shadow: none;
    }

    .join-select {
        width: 100%;
        height: 50px;
        padding: 0 15px;
        border: 1.5px solid var(--border);
        border-radius: 12px;
        font-family: 'Noto Sans KR', sans-serif;
        font-size: 14px;
        color: var(--text);
        background: #fff;
        outline: none;
    }

    .join-select:focus {
        border-color: var(--primary);
        box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.10);
    }

    .profile-choice-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 8px;
        margin-top: 8px;
    }

    .profile-choice {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 6px;
        padding: 8px 8px 10px;
        border: 1px solid var(--border);
        border-radius: 16px;
        background: #fff;
        cursor: pointer;
        transition: border-color .2s, box-shadow .2s, transform .12s;
    }

    .profile-choice:hover {
        transform: translateY(-1px);
        border-color: rgba(37, 99, 235, 0.24);
    }

    .profile-choice.is-selected {
        border-color: rgba(37, 99, 235, 0.4);
        box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.08);
        background: #f8fbff;
    }

    .profile-choice input {
        position: absolute;
        opacity: 0;
        pointer-events: none;
    }

    .profile-choice img {
        width: 58px;
        height: 58px;
        object-fit: cover;
        border-radius: 12px;
    }

    .profile-choice span {
        font-size: 12px;
        font-weight: 700;
        color: var(--text-sub);
    }

    .join-collapsible {
        margin-bottom: 16px;
        border: 1px solid var(--border);
        border-radius: 16px;
        background: #fbfcfe;
        overflow: hidden;
    }

    .join-collapsible summary {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 14px 16px;
        cursor: pointer;
        list-style: none;
    }

    .join-collapsible summary::-webkit-details-marker {
        display: none;
    }

    .join-collapsible summary::after {
        content: '+';
        width: 28px;
        height: 28px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        background: rgba(37, 99, 235, 0.08);
        color: var(--primary);
        font-size: 18px;
        font-weight: 700;
        flex: 0 0 auto;
    }

    .join-collapsible[open] summary::after {
        content: '-';
    }

    .join-collapsible-title strong,
    .join-collapsible-title span {
        display: block;
    }

    .join-collapsible-title strong {
        font-size: 14px;
        color: var(--text);
        margin-bottom: 3px;
    }

    .join-collapsible-title span {
        font-size: 12px;
        color: var(--text-sub);
    }

    .join-collapsible-body {
        padding: 0 16px 16px;
        border-top: 1px solid var(--border);
    }

    .join-collapsible-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 0 12px;
        margin-top: 14px;
    }

    .upload-box {
        padding: 12px 14px;
        border: 1px dashed var(--border);
        border-radius: 14px;
        background: #fafbfd;
    }

    .upload-box p {
        margin-bottom: 8px;
        font-size: 13px;
        color: var(--text-sub);
    }

    .step-actions {
        display: flex;
        gap: 10px;
        margin-top: 26px;
    }

    .step-actions .login-btn,
    .step-actions .ghost-btn {
        flex: 1 1 0;
        margin-top: 0;
        height: 52px;
        border-radius: 12px;
        font-family: 'Noto Sans KR', sans-serif;
        font-size: 15px;
        font-weight: 800;
        cursor: pointer;
    }

    .ghost-btn {
        border: 1px solid var(--border);
        background: #fff;
        color: var(--text);
        box-shadow: none;
    }

    .join-agree {
        display: flex;
        align-items: center;
        gap: 8px;
        min-height: 50px;
        padding: 0 4px;
        font-size: 14px;
        color: var(--text);
    }

    .join-agree input {
        width: auto;
        height: auto;
        padding: 0;
        border: 0;
        box-shadow: none;
    }

    @keyframes joinFadeIn {
        from {
            opacity: 0;
            transform: translateY(6px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    @media (max-width: 768px) {
        .join-progress {
            margin-bottom: 18px;
        }

        .join-step-title {
            font-size: 23px;
        }

        .join-step-grid {
            grid-template-columns: 1fr;
            gap: 0;
        }

        .span-2 {
            grid-column: auto;
        }

        .field-action-row {
            flex-direction: column;
            align-items: stretch;
        }

        .field-action-row .login-btn {
            width: 100%;
            min-width: 0;
        }

        .profile-choice-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
        }

        .join-collapsible-grid {
            grid-template-columns: 1fr;
            gap: 0;
        }

        .step-actions {
            flex-direction: column;
        }
    }
</style>

<div class="login-page">
    <div class="login-wrap join-wrap">
        <div class="login-left">
            <div class="login-title-box">
                <h1 class="login-title">OTTERCARE</h1>
                <p class="login-subtitle">건강한 습관의 시작, 회원가입 후 다양한 기능을 이용해보세요.</p>
            </div>
            
        </div>

        <div class="login-right">
            <div class="login-form-box join-form-box">
                <h2 class="login-form-title">회원가입</h2>


                <div class="login-msg">
                    ${msg}
                </div>

                <form action="${pageContext.request.contextPath}/join" method="post" enctype="multipart/form-data"
                      onsubmit="return joinCheck()">

                    <section class="join-step is-active" data-step="1">

                        <div class="login-input-group">
                            <label for="user_id">아이디</label>
                            <div class="field-action-row">
                                <input type="text" id="user_id" name="user_id" class="field-input"
                                       placeholder="아이디를 입력하세요" required>
                                <button type="button" class="login-btn" onclick="checkUserId()">아이디 중복확인</button>
                            </div>
                            <small id="idCheckMsg" class="field-msg"></small>
                            <input type="hidden" id="idCheckResult" value="false">
                        </div>

                        <div class="login-input-group">
                            <label for="user_pw">비밀번호</label>
                            <input type="password" id="user_pw" name="user_pw" placeholder="비밀번호를 입력하세요" required>
                        </div>

                        <div class="login-input-group">
                            <label for="user_name">닉네임</label>
                            <input type="text" id="user_name" name="user_name" placeholder="닉네임을 입력하세요" required>
                        </div>

                        <div class="login-input-group">
                            <label for="user_email">이메일</label>
                            <div class="field-action-row">
                                <input type="email" id="user_email" name="user_email" class="field-input"
                                       placeholder="이메일을 입력하세요" required>
                                <button type="button" class="login-btn" onclick="checkUserEmail()">이메일 중복확인</button>
                            </div>
                            <small id="emailCheckMsg" class="field-msg"></small>
                            <input type="hidden" id="emailCheckResult" value="false">
                        </div>

                        <div class="login-input-group">
                            <label for="email_auth_btn">이메일 본인인증</label>
                            <div class="field-action-row">
                                <input type="button"
                                       id="email_auth_btn"
                                       value="인증번호 전송"
                                       class="login-btn"
                                       onclick="sendEmailAuth()">

                                <input type="text"
                                       id="email_code"
                                       name="email_code"
                                       class="field-input"
                                       placeholder="인증번호 입력">
                            </div>

                            <button type="button" id="verify_btn" class="login-btn verify-btn" onclick="checkEmailAuth()">
                                인증완료
                            </button>

                            <div id="emailAuthMsg" class="field-msg"></div>
                            <input type="hidden" id="emailAuthPassed" value="false">
                        </div>

                        <div class="step-actions">
                            <button type="button" class="login-btn" onclick="goToJoinStep(2)">다음 단계</button>
                        </div>
                    </section>

                    <section class="join-step" data-step="2">
                        <div class="join-step-head">
                            <div class="join-step-badge">2 / 2</div>
                            <div class="join-step-title">나머지 프로필을 마무리해요</div>
                            <p class="join-step-copy">추가 정보는 추천과 마이페이지 경험을 맞추는 데 사용됩니다.</p>
                        </div>

                        <div class="join-step-grid">
                            <div class="login-input-group">
                                <label>성별</label>
                                <div class="radio-inline">
                                    <label><input type="radio" name="user_gender" value="남" required> 남</label>
                                    <label><input type="radio" name="user_gender" value="여"> 여</label>
                                </div>
                            </div>

                            <div class="login-input-group">
                                <label for="user_age">나이</label>
                                <input type="number" id="user_age" name="user_age" placeholder="나이를 입력하세요"
                                       min="1" max="120" required>
                            </div>

                            <div class="login-input-group span-2">
                                <label for="user_join_path">이 사이트를 알게 된 경로</label>
                                <select id="user_join_path" name="user_join_path" class="join-select">
                                    <option value="">선택하세요</option>
                                    <option value="GOOGLE">구글 검색</option>
                                    <option value="YOUTUBE">유튜브</option>
                                    <option value="INSTAGRAM">인스타그램</option>
                                    <option value="FRIEND">지인 추천</option>
                                    <option value="ETC">기타</option>
                                </select>
                            </div>

                            <div class="login-input-group span-2" style="margin-top: 4px;">
                                <label>개인정보 동의</label>
                                <label class="join-agree">
                                    <input type="checkbox" name="user_agree" value="Y" required>
                                    개인정보 제공에 동의합니다.
                                </label>
                            </div>
                        </div>

                        <details class="join-collapsible">
                            <summary>
                                <div class="join-collapsible-title">
                                    <strong>프로필 설정</strong>
                                    <span>기본 이미지 선택 또는 직접 업로드</span>
                                </div>
                            </summary>
                            <div class="join-collapsible-body">
                                <div class="profile-choice-grid">
                                    <label class="profile-choice is-selected">
                                        <input type="radio" name="default_profile" value="Ayanokoji.jfif" checked>
                                        <img src="${pageContext.request.contextPath}/user/userImg/Ayanokoji.jfif" alt="기본 프로필 1">
                                        <span>Ayanokoji</span>
                                    </label>

                                    <label class="profile-choice">
                                        <input type="radio" name="default_profile" value="Ryuen.jfif">
                                        <img src="${pageContext.request.contextPath}/user/userImg/Ryuen.jfif" alt="기본 프로필 2">
                                        <span>Ryuen</span>
                                    </label>

                                    <label class="profile-choice">
                                        <input type="radio" name="default_profile" value="Horikita.jfif">
                                        <img src="${pageContext.request.contextPath}/user/userImg/Horikita.jfif" alt="기본 프로필 3">
                                        <span>Horikita</span>
                                    </label>
                                </div>

                                <div class="upload-box" style="margin-top: 14px;">
                                    <p>선택한 기본 프로필 대신 직접 이미지를 올릴 수 있습니다.</p>
                                    <input type="file" id="user_profile" name="user_profile" accept="image/*">
                                </div>
                            </div>
                        </details>

                        <details class="join-collapsible">
                            <summary>
                                <div class="join-collapsible-title">
                                    <strong>주소 정보</strong>
                                    <span>배송지나 개인화 추천에 쓸 추가 입력 항목</span>
                                </div>
                            </summary>
                            <div class="join-collapsible-body">
                                <div class="join-collapsible-grid">
                                    <div class="login-input-group span-2">
                                        <label for="user_zipcode">우편번호</label>
                                        <div class="field-action-row">
                                            <input type="text" id="user_zipcode" name="user_zipcode" class="field-input"
                                                   placeholder="우편번호" readonly>
                                            <input type="button" value="주소찾기" class="login-btn" onclick="execDaumPostcode()">
                                        </div>
                                    </div>

                                    <div class="login-input-group">
                                        <label for="user_road_address">도로명주소</label>
                                        <input type="text" id="user_road_address" name="user_road_address" placeholder="도로명주소" readonly>
                                    </div>

                                    <div class="login-input-group">
                                        <label for="user_detail_address">상세주소</label>
                                        <input type="text" id="user_detail_address" name="user_detail_address"
                                               placeholder="상세주소를 입력하세요">
                                    </div>

                                    <div class="login-input-group span-2">
                                        <label for="user_extra_address">참고항목</label>
                                        <input type="text" id="user_extra_address" name="user_extra_address" placeholder="참고항목"
                                               readonly>
                                    </div>
                                </div>
                            </div>
                        </details>

                        <div class="step-actions">
                            <button type="button" class="ghost-btn" onclick="goToJoinStep(1)">이전 단계</button>
                            <button type="submit" class="login-btn">회원가입 완료</button>
                        </div>
                    </section>
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
    const joinSteps = Array.from(document.querySelectorAll("[data-step]"));
    const joinProgressSteps = Array.from(document.querySelectorAll("[data-progress-step]"));
    let currentJoinStep = 1;

    const userIdInput = document.getElementById("user_id");
    const userPwInput = document.getElementById("user_pw");
    const userNameInput = document.getElementById("user_name");
    const idCheckMsg = document.getElementById("idCheckMsg");
    const idCheckResult = document.getElementById("idCheckResult");

    const emailInput = document.getElementById("user_email");
    const emailCodeInput = document.getElementById("email_code");
    const emailCheckMsg = document.getElementById("emailCheckMsg");
    const emailCheckResult = document.getElementById("emailCheckResult");
    const emailAuthMsg = document.getElementById("emailAuthMsg");
    const emailAuthPassed = document.getElementById("emailAuthPassed");

    function setFieldMessage(target, message, color) {
        target.innerText = message;
        target.style.color = color || "";
        target.style.fontWeight = color === "green" ? "700" : "400";
    }

    function showJoinStep(step) {
        currentJoinStep = step;

        joinSteps.forEach(function (section) {
            section.classList.toggle("is-active", Number(section.dataset.step) === step);
        });

        joinProgressSteps.forEach(function (progress) {
            const progressStep = Number(progress.dataset.progressStep);
            progress.classList.toggle("is-current", progressStep === step);
            progress.classList.toggle("is-done", progressStep < step);
        });
    }

    function validateAccountStep() {
        const requiredFields = [userIdInput, userPwInput, userNameInput, emailInput];

        for (const field of requiredFields) {
            if (!field.reportValidity()) {
                return false;
            }
        }

        if (idCheckResult.value !== "true") {
            alert("아이디 중복확인을 완료해주세요.");
            userIdInput.focus();
            return false;
        }

        if (emailCheckResult.value !== "true") {
            alert("이메일 중복확인을 완료해주세요.");
            emailInput.focus();
            return false;
        }

        if (emailAuthPassed.value !== "true") {
            alert("이메일 인증을 완료해주세요.");
            emailCodeInput.focus();
            return false;
        }

        return true;
    }

    function goToJoinStep(step) {
        if (step === 2 && !validateAccountStep()) {
            return;
        }

        showJoinStep(step);
    }

    function updateProfileSelectionVisuals() {
        document.querySelectorAll(".profile-choice").forEach(function (choice) {
            const radio = choice.querySelector("input[type='radio']");
            choice.classList.toggle("is-selected", !!radio && radio.checked);
        });
    }

    document.addEventListener("DOMContentLoaded", function () {
        const fileInput = document.getElementById("user_profile");
        const defaultProfiles = document.querySelectorAll("input[name='default_profile']");

        showJoinStep(1);
        updateProfileSelectionVisuals();

        if (fileInput && defaultProfiles.length > 0) {
            fileInput.addEventListener("change", function () {
                if (this.value) {
                    defaultProfiles.forEach(function (radio) {
                        radio.checked = false;
                    });
                } else if (defaultProfiles[0]) {
                    defaultProfiles[0].checked = true;
                }

                updateProfileSelectionVisuals();
            });

            defaultProfiles.forEach(function (radio) {
                radio.addEventListener("change", function () {
                    fileInput.value = "";
                    updateProfileSelectionVisuals();
                });
            });
        }
    });

    userIdInput.addEventListener("input", function () {
        idCheckResult.value = "false";
        setFieldMessage(idCheckMsg, "", "");
    });

    emailInput.addEventListener("input", function () {
        emailCheckResult.value = "false";
        emailAuthPassed.value = "false";
        setFieldMessage(emailCheckMsg, "", "");
        setFieldMessage(emailAuthMsg, "", "");
        emailCodeInput.value = "";
        emailInput.readOnly = false;
        emailCodeInput.readOnly = false;
    });

    function checkUserId() {
        const userId = userIdInput.value.trim();

        if (userId === "") {
            setFieldMessage(idCheckMsg, "아이디를 입력하세요.", "red");
            userIdInput.focus();
            return;
        }

        fetch("${pageContext.request.contextPath}/user.id.check?user_id=" + encodeURIComponent(userId))
            .then(function (response) {
                return response.text();
            })
            .then(function (result) {
                result = result.trim().toUpperCase();

                if (result === "OK" || result === "AVAILABLE" || result === "FALSE" || result === "0") {
                    setFieldMessage(idCheckMsg, "사용 가능한 아이디입니다.", "green");
                    idCheckResult.value = "true";
                } else if (result === "DUPLICATE" || result === "TAKEN" || result === "TRUE" || result === "1") {
                    setFieldMessage(idCheckMsg, "이미 사용 중인 아이디입니다.", "red");
                    idCheckResult.value = "false";
                } else {
                    setFieldMessage(idCheckMsg, "중복확인 중 오류가 발생했습니다.", "red");
                    idCheckResult.value = "false";
                }
            })
            .catch(function () {
                setFieldMessage(idCheckMsg, "중복확인 중 오류가 발생했습니다.", "red");
                idCheckResult.value = "false";
            });
    }

    function checkUserEmail() {
        const email = emailInput.value.trim();

        if (email === "") {
            setFieldMessage(emailCheckMsg, "이메일을 입력하세요.", "red");
            emailInput.focus();
            return;
        }

        fetch("${pageContext.request.contextPath}/user.email.check?user_email=" + encodeURIComponent(email))
            .then(function (response) {
                return response.text();
            })
            .then(function (result) {
                result = result.trim().toUpperCase();

                if (result === "OK" || result === "AVAILABLE" || result === "FALSE" || result === "0") {
                    setFieldMessage(emailCheckMsg, "사용 가능한 이메일입니다.", "green");
                    emailCheckResult.value = "true";
                } else if (result === "DUPLICATE" || result === "TAKEN" || result === "TRUE" || result === "1") {
                    setFieldMessage(emailCheckMsg, "이미 사용 중인 이메일입니다.", "red");
                    emailCheckResult.value = "false";
                } else {
                    setFieldMessage(emailCheckMsg, "이메일 중복확인 중 오류가 발생했습니다.", "red");
                    emailCheckResult.value = "false";
                }
            })
            .catch(function () {
                setFieldMessage(emailCheckMsg, "이메일 중복확인 중 오류가 발생했습니다.", "red");
                emailCheckResult.value = "false";
            });
    }

    function sendEmailAuth() {
        const email = emailInput.value.trim();

        if (email === "") {
            setFieldMessage(emailAuthMsg, "이메일을 먼저 입력하세요.", "red");
            emailInput.focus();
            return;
        }

        if (emailCheckResult.value !== "true") {
            setFieldMessage(emailAuthMsg, "이메일 중복확인을 먼저 완료해주세요.", "red");
            return;
        }

        fetch("${pageContext.request.contextPath}/user/email-auth-send?user_email=" + encodeURIComponent(email))
            .then(res => res.json())
            .then(data => {
                if (data.result === "success") {
                    setFieldMessage(emailAuthMsg, "인증번호가 전송되었습니다.", "green");
                } else if (data.result === "duplicate") {
                    emailCheckResult.value = "false";
                    setFieldMessage(emailCheckMsg, "이미 사용 중인 이메일입니다.", "red");
                    setFieldMessage(emailAuthMsg, "이미 가입된 이메일은 인증할 수 없습니다.", "red");
                } else {
                    setFieldMessage(emailAuthMsg, "인증번호 전송 실패", "red");
                }
            })
            .catch(() => {
                setFieldMessage(emailAuthMsg, "오류가 발생했습니다.", "red");
                emailAuthPassed.value = "false";
            });
    }

    function checkEmailAuth() {
        const email = emailInput.value.trim();
        const code = emailCodeInput.value.trim();

        if (code === "") {
            setFieldMessage(emailAuthMsg, "인증번호를 입력하세요.", "red");
            return;
        }

        fetch("${pageContext.request.contextPath}/user/email-auth-verify?user_email=" + encodeURIComponent(email) + "&auth_code=" + encodeURIComponent(code))
            .then(res => res.json())
            .then(data => {
                if (data.result === "success") {
                    setFieldMessage(emailAuthMsg, "이메일 인증이 완료되었습니다.", "green");
                    emailAuthPassed.value = "true";
                    emailInput.readOnly = true;
                    emailCodeInput.readOnly = true;
                } else {
                    setFieldMessage(emailAuthMsg, "인증번호가 일치하지 않습니다.", "red");
                    emailAuthPassed.value = "false";
                }
            })
            .catch(() => {
                setFieldMessage(emailAuthMsg, "오류가 발생했습니다.", "red");
                emailAuthPassed.value = "false";
            });
    }

    function joinCheck() {
        if (!validateAccountStep()) {
            showJoinStep(1);
            return false;
        }

        return true;
    }
</script>
