<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>영양성분 리스트</title>
    <style>
        .supplements-container { display: flex; flex-wrap: wrap; gap: 20px; justify-content: center; margin-bottom: 20px; }
        .supp-wrap { border: 1px solid #ddd; padding: 15px; border-radius: 8px; width: 250px; text-align: center; }
        .supp-img img { width: 100%; height: 200px; object-fit: cover; cursor: pointer; border-radius: 4px; }
        .supp-title { font-size: 1.2em; font-weight: bold; margin: 10px 0; }
        .supp-efficacy { color: #666; font-size: 0.9em; height: 40px; overflow: hidden; margin-bottom: 10px; }
        .supp-btn { padding: 5px 10px; cursor: pointer; background-color: #f0f0f0; border: 1px solid #ccc; border-radius: 4px; }
        .supp-btn:hover { background-color: #e0e0e0; }
    </style>
</head>

<body>
<h1 style="text-align: center;">영양성분 리스트</h1>

<button onclick="location.href='supplementAdd'">새 영양성분 등록</button>

<div style="width: 100%; display: flex; flex-direction: column; align-items: center;">
    <div class="supplements-container">
        <c:forEach var="supp" items="${supplementsList}">
        <div class="supp-wrap">

            <div class="supp-img" onclick="location.href='detailSupplements?id=${supp.supplementId}'">
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

</body>

<script>
    // 삭제 전 확인 창을 띄우는 함수
    function delSupplement(id) {
        let ok = confirm('정말로 이 영양성분 정보를 삭제하시겠습니까?');
        if(ok){
            // 사용자가 '확인'을 누르면 삭제 서블릿으로 요청을 보냄
            // 컨트롤러(서블릿)의 주소(@WebServlet)도 반드시 deleteSupplement여야 합니다.
            location.href = 'deleteSupplement?id=' + id;
        }

    }

</script>
</html>