<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--(글자 검사 기능)--%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
<%--    모바일 환경--%>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>영양성분 리스트</title>
    <link rel="stylesheet" href="css/supplements.css">
</head>

<body>
<h1 style="text-align: center;">영양성분 리스트</h1>

<button class="supp-btn" onclick="openAddModal()">새 영양성분 등록</button>

<div style="width: 100%; display: flex; flex-direction: column; align-items: center;">
    <div class="supplements-container">
        <c:forEach var="supp" items="${supplementsList}">
            <div class="supp-wrap">
                <div class="supp-img" onclick="openDetailModal(this)"
                data-id="${supp.supplementId}" data-name="${supp.supplementName}" data-efficacy="${supp.supplementEfficacy}" data-dosage="${supp.supplementDosage}" data-timing="${supp.supplementTiming}" data-caution="${supp.supplementCaution}" data-imgPath="${supp.supplementImagePath}">
<%--                    <img src="${supp.supplementImagePath}" alt="${supp.supplementName}">--%>

                    <%-- 💡 똑똑한 이미지 출력 로직 --%>
                <c:choose>
                    <%-- 1. DB 값이 'http'로 시작하면? (인터넷 주소면) -> 경로 안 붙이고 그대로 출력! --%>
                    <c:when test="${fn:startsWith(supp.supplementImagePath, 'http')}">
                        <img src="${supp.supplementImagePath}" alt="${supp.supplementName}">
                    </c:when>

                    <%-- 2. 그게 아니면? (직접 올린 'test.png' 같은 파일이면) -> 앞에 폴더 경로를 싹 붙여서 출력! --%>
                    <c:otherwise>
                        <img src="/supplementImg/supplementImgFile/${supp.supplementImagePath}" alt="${supp.supplementName}">
                    </c:otherwise>
                </c:choose>

                </div>

                <div class="supp-name">${supp.supplementName}</div>
                <div class="supp-efficacy">${supp.supplementEfficacy}</div>

                    <%-- ★ 좋아요 버튼 부분 수정 --%>
                <button class="like-btn ${likedIds.contains(supp.supplementId) ? 'liked' : ''}"
                        onclick="toggleLike(this, ${supp.supplementId})">
                    ♥
                </button>

                <div style="margin-top: 10px;">
                    <button class="supp-btn" onclick="delSupplement('${supp.supplementId}')">삭제</button>
                    <button class="supp-btn" onclick="updateSupplement('${supp.supplementId}')">수정</button>
                </div>
            </div>
        </c:forEach>
    </div>

    <div class="page-container">
        <c:choose>
            <c:when test="${currentPage != 1}">
                <a href="supplements?p=${currentPage - 1}" class="page-btn">이전</a>
            </c:when>
            <c:otherwise>
                <span class="page-btn disabled">이전</span>
            </c:otherwise>
        </c:choose>

        <c:forEach begin="1" end="${totalPage}" var="i">
            <c:choose>
                <c:when test="${currentPage == i}">
                    <a href="supplements?p=${i}" class="page-btn active">${i}</a>
                </c:when>
                <c:otherwise>
                    <a href="supplements?p=${i}" class="page-btn">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <c:choose>
            <c:when test="${currentPage != totalPage}">
                <a href="supplements?p=${currentPage + 1}" class="page-btn">다음</a>
            </c:when>
            <c:otherwise>
                <span class="page-btn disabled">다음</span>
            </c:otherwise>
        </c:choose>
    </div>

</div>

        <dialog id="commonModal">
<%--            <button id="closeBtn">x</button>--%>
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