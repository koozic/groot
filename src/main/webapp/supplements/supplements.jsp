<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>영양성분 리스트</title>
    <link rel="stylesheet" href="css/supplements.css">
</head>

<body>
<h1 style="text-align: center;">영양성분 리스트</h1>

<button onclick="openAddModal()">새 영양성분 등록</button>

<div style="width: 100%; display: flex; flex-direction: column; align-items: center;">
    <div class="supplements-container">
        <c:forEach var="supp" items="${supplementsList}">
            <div class="supp-wrap">
                <div class="supp-img" onclick="openDetailModal(this)"
                data-id="${supp.supplementId}" data-name="${supp.supplementName}" data-efficacy="${supp.supplementEfficacy}" data-dosage="${supp.supplementDosage}" data-timing="${supp.supplementTiming}" data-caution="${supp.supplementCaution}" data-imgPath="${supp.supplementImagePath}">
                <img src="/supplementImg/supplementImgFile/${supp.supplementImagePath}">
                </div>

                <div class="supp-name">${supp.supplementName}</div>
                <div class="supp-efficacy">${supp.supplementEfficacy}</div>

                <div style="margin-top: 10px;">
                    <button class="supp-btn" onclick="delSupplement('${supp.supplementId}')">삭제</button>
                    <button class="supp-btn" onclick="updateSupplement('${supp.supplementId}')">수정</button>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

        <dialog id="commonModal"> <button id="closeBtn">x</button>
            <div id="modalContent">
            </div>
        </dialog>

</body>

<script>
    // 삭제 전 확인 창을 띄우는 함수
    function delSupplement(id) {
        let ok = confirm('정말로 이 영양성분 정보를 삭제하시겠습니까?');
        if (ok) {
            // 사용자가 '확인'을 누르면 삭제 서블릿으로 요청을 보냄
            // 컨트롤러(서블릿)의 주소(@WebServlet)도 반드시 deleteSupplement여야 합니다.
            location.href = 'deleteSupplement?id=' + id;
        }
    }

    function updateSupplement(id) {
        let ok = confirm('정말로 이 영양성분 정보를 수정하시겠습니까?');
        if (ok) {
            // 사용자가 '확인'을 누르면 수정 서블릿으로 요청을 보냄
            location.href = 'updateSupplement?id=' + id;
        }
    }
</script>

<script src="js/supplements.js"></script>

</html>