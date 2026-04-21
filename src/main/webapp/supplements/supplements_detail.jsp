<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>영양성분 상세정보</title>
    <link rel="stylesheet" href="css/supplements.css">
</head>

<body>
<div class="detail-wrapper">
    <h1 class="detail-title">- Supplement Detail -</h1>

    <div class="supp-detail-box content">

        <div class="detail-img-area">
            <%--            <img src="/supplementImg/supplementImgFile/${detailSupp.supplementImagePath}" alt="${detailSupp.supplementName}">--%>
            <img src="${detailSupp.supplementImagePath}" alt="${detailSupp.supplementName}">
        </div>

        <div class="detail-row">
            <div class="col-1">🆔 No.</div>
            <div class="col-2">${detailSupp.supplementId}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">🏷️ Name.</div>
            <div class="col-2"
                 style="font-size: 1.3em; font-weight: bold; color: #4CAF50;">${detailSupp.supplementName}</div>
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
        <%--        <c:if test="${isAdmin == true}">--%>
        <button class="btn-list" onclick="updateSupplement('${detailSupp.supplementId}')">수정</button>
        <%--        </c:if>--%>
    </div>
</div>

<script>
    function updateSupplement(id) {
        let ok = confirm('정말로 이 영양성분 정보를 수정하시겠습니까?');
        if (ok) {
            // 사용자가 '확인'을 누르면 수정 서블릿으로 요청을 보냄
            location.href = 'updateSupplement?id=' + id;
        }
    }
</script>
<%-- <script> 태그는 반드시 </body>안쪽으로!! --%>
</body>
</html>

