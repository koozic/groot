<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Groot - 상품 리뷰</title>
    <style>
        .review-container { max-width: 800px; margin: 0 auto; padding: 20px; font-family: sans-serif; }
        .review-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #333; padding-bottom: 10px; margin-bottom: 20px; }
        .btn-write { padding: 10px 20px; background-color: #3498db; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; text-decoration: none; }
        .btn-write:hover { background-color: #2980b9; }
        .review-card { border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 8px; background: #f9f9f9; }
        .review-meta { font-size: 0.9em; color: #7f8c8d; margin-bottom: 10px; }
        .review-title { font-weight: bold; font-size: 1.1em; margin-bottom: 10px; color: #2c3e50; }
        .review-content { line-height: 1.5; }
        .empty-msg { text-align: center; color: #7f8c8d; padding: 40px; font-weight: bold; }
    </style>
</head>
<body>

<div class="review-container">
    <div class="review-header">
        <h2>💬 상품 리뷰</h2>

        <%-- 🌟 여기가 리뷰 작성 폼으로 넘어가는 버튼! (임시로 101번 상품으로 세팅) --%>
        <a href="review/review_write.jsp?product_id=101" class="btn-write">✍️ 리뷰 작성하기</a>
    </div>

    <%-- 1. DAO에서 가져온 리뷰 리스트 쫙 뿌리기 (DTO 소문자로 맞춘 거 적용됨!) --%>
    <c:forEach var="r" items="${reviews}">
        <div class="review-card">
            <div class="review-title">제목: ${r.r_title}</div>
            <div class="review-meta">
                작성자: ${r.user_id} | 별점: ${r.r_score}점 | 작성일: ${r.r_date}
            </div>
            <hr style="border: 0; border-top: 1px solid #eee;">
            <div class="review-content">
                    ${r.r_content}
            </div>
        </div>
    </c:forEach>

    <%-- 2. 등록된 리뷰가 한 개도 없을 때 --%>
    <c:if test="${empty reviews}">
        <div class="empty-msg">
            <p>아직 작성된 리뷰가 없습니다.</p>
            <p>99년생 무영이가 1등으로 리뷰를 남겨주세요! 👊</p>
        </div>
    </c:if>

</div>

</body>
</html>