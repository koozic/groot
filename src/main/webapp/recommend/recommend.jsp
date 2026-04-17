<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- index.jsp include 구조 — html/head/body 없음 --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/recommend_benr.css">

<!-- 이미지 추가 -->
<div class="select-container">
    <div class="select-box" onclick="location.href='body_view'">
        <div class="recommend-image-wrap">
            <img src="${pageContext.request.contextPath}/img/ottos/real_search.png" alt="약 찾는 수달"
                 class="recommend-img">
        </div>
        <h2>신체별 추천</h2>
        <p>눈, 간, 피부 등 아픈 부위에<br>딱 맞는 영양소를 찾아보세요.</p>
    </div>

    <div class="select-box" onclick="location.href='curation_view'">
        <div class="recommend-image-wrap">
            <img src="${pageContext.request.contextPath}/img/ottos/wink_otter.png" alt="약 찾는 수달"
                 class="recommend-img">
        </div>
        <h2>AI 테마 추천</h2>
        <p>수험생, 임산부 등 상황에 맞는<br>최적의 조합을 AI가 추천합니다.</p>
    </div>
</div>