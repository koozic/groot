<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>영양성분 정보 수정</title>
</head>

<body>

<h1 class="detail-title">- 영양성분 정보 수정 -</h1>

<div class="update-form">
    <form action="updateSupplement" method="post" enctype="multipart/form-data">

        <%-- hidden하는 이유! --%>
        <input type="hidden" name="supplementId" value="${detailSupp.supplementId}">
        <input type="hidden" name="oldSupplementFile" value="${detailSupp.supplementImagePath}">

    <div class="supp-update-box">
        <div class="form-group">
            <label>사진 변경 (변경할 때만 파일을 선택하세요)</label>
            <input type="file" name="supplementFile">
            <div style="font-size: 0.85em; color: gray; margin-top: 5px;">
                현재 저장된 사진: ${detailSupp.supplementImagePath}
            </div>
        </div>


        <div class="detail-row">
            <div class="col-1">🆔 No.</div>
            <div class="col-2">${detailSupp.supplementId}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">🏷️ Name.</div>
            <div class="col-2" style="font-size: 1.3em; font-weight: bold; color: #4CAF50;">${detailSupp.supplementName}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">✨ Efficacy.</div>
            <div class="col-2">${detailSupp.supplementEfficacy}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">💊 Dosage.</div>
            <div class="col-2">${detailSupp.supplementDosage}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">⏰ Timing.</div>
            <div class="col-2">${detailSupp.supplementTiming}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">⚠️ Caution.</div>
            <div class="col-2">${detailSupp.supplementCaution}</div>
        </div>

    </div>

    <div class="btn-group">
        <button class="btn-list" onclick="location.href='supplements'">목록으로 돌아가기</button>
    </div>
    </form>
</div>

</body>
</html>

</body>
</html>
