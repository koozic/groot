<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>영양성분 정보 수정</title>
    <link rel="stylesheet" href="css/supplements.css">
</head>

<body>

<div class="update-wrapper">
<h1 class="detail-title">- 영양성분 정보 수정 -</h1>
    <form action="updateSupplement" method="post" enctype="multipart/form-data">

        <%-- hidden하는 이유! --%>
        <input type="hidden" name="supplementId" value="${detailSupp.supplementId}">
        <input type="hidden" name="oldSupplementFile" value="${detailSupp.supplementImagePath}">

    <div class="supp-update-box">
        <div class="detail-img-area">
            <img src="${detailSupp.supplementImagePath}" alt="${detailSupp.supplementName}">
            <br>
            <span style="font-weight: bold; color: #e74c3c;">사진 변경 (선택): </span>
            <input type="file" name="supplementFile" style="margin-top: 10px;">
        </div>

        <%-- 자바에서 getParameter("supplementName")라고 부를 수 있는 유일한 이유가 바로
        JSP 파일의 input 태그에 name="supplementName"이라고 적어두었기 때문 --%>

        <div class="form-group">
            <div class="col-1">🆔 No.</div>
            <div class="col-2" style="padding-top: 5px; color: #7f8c8d;">${detailSupp.supplementId}</div>
        </div>

        <div class="form-group">
            <div class="col-1">🏷️ Name.</div>
            <div class="col-2">
            <input type="text" name="supplementName" class="update-input" value="${detailSupp.supplementName}">
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">✨ Efficacy.</div>
            <div class="col-2">
            <textarea name="supplementEfficacy" class="update-textarea">${detailSupp.supplementEfficacy}</textarea>
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">💊 Dosage.</div>
            <div class="col-2">
                <input type="text" name="supplementDosage" class="update-input" value="${detailSupp.supplementDosage}">
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">⏰ Timing.</div>
            <div class="col-2">
                <input type="text" name="supplementTiming" class="update-input" value="${detailSupp.supplementTiming}">
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">⚠️ Caution.</div>
            <div class="col-2">
                <textarea name="supplementCaution" class="update-textarea">${detailSupp.supplementCaution}</textarea>
            </div>
        </div>

    </div>

    <%-- <form> 태그 안에 있는 <button>은 type="button"을 명시하지 않으면
    무조건 제출(Submit) 버튼으로 작동합니다.
    그래서 "목록으로 돌아가기" 버튼에 type="button"을 안 적어주면,
    목록으로 안 가고 냅다 수정을 진행해 버릴 수 있습니다.--%>

    <div class="btn-group">
        <button type="submit" class="btn-submit">수정 완료</button>
        <button type="button" class="btn-list" onclick="location.href='supplements'">목록으로 돌아가기</button>
<%--        <button type="button" class="btn-cancel" onclick="history.back()">취소</button>--%>
    </div>
    </form>
</div>

</body>
</html>
