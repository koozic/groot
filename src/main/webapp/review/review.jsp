<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Groot - 상품 리뷰</title>
    <link rel="stylesheet" href="../css/review.css">
</head>
<body>

<div class="review-container">
    <div class="review-header">
        <h2>💬 상품 리뷰</h2>
        <div class="star-stats-container">
            <div class="avg-score-box">
                <div class="avg-score">${avgScore}</div>
                <div class="avg-stars-container">
                    <div class="avg-stars-base">★★★★★</div>
                    <div class="avg-stars-fill" style="width: ${avgScore * 20}%">★★★★★</div>
                </div>
                <div class="total-review-count">구매후기 평점 ${reviews.size()}개 기준</div>
            </div>

            <div class="stat-rows">
                <c:forEach var="i" begin="1" end="5" step="1">
                    <c:set var="score" value="${6 - i}" />
                    <c:set var="count" value="0" />
                    <c:forEach var="entry" items="${starStats}">
                        <c:if test="${entry.key == score}">
                            <c:set var="count" value="${entry.value}" />
                        </c:if>
                    </c:forEach>
                    <c:set var="rawPercent" value="${totalCount > 0 ? (count * 100.0 / totalCount) : 0}" />
                    <fmt:formatNumber var="cleanPercent" value="${rawPercent}" pattern="0" />

                    <div class="stat-row">
                        <span style="color:#f1c40f">★</span>
                        <span style="width:15px;">${score}</span>
                        <div class="bar-bg" style="flex-grow:1; height:12px; background:#eee; border-radius:6px; margin:0 10px; overflow:hidden;">
                            <div class="bar-fill" style="width: ${cleanPercent}%; height: 100%; background-color: #6a8d3a; border-radius: 6px;"></div>
                        </div>
                        <span style="width:30px; text-align:right;">${count}</span>
                    </div>
                </c:forEach>
            </div>
        </div>
        <a href="review/review_write.jsp?product_id=106" class="btn-write">✍️ 리뷰 작성하기</a>
    </div>

    <%-- 📸 1. 포토 갤러리 구역 --%>
    <div class="photo-gallery-container">
        <div class="gallery-header">
            <h2>📸 포토 리뷰 <span id="photo-count">(${allPhotoImages.size()})</span></h2>
            <a href="javascript:void(0)" class="view-all-photos" onclick="openPhotoGalleryModal()">포토 리뷰만 모아보기 </a>
        </div>
        <div class="photo-slider-wrapper">
            <button type="button" class="slider-btn prev-btn" onclick="slideGallery(-1)">&lt;</button>
            <div class="photo-slider" id="photo-slider">
                <c:forEach var="img" items="${allPhotoImages}">
                    <div class="photo-slide-item" onclick="openDetailModal('${img.r_title}', '${img.user_id}', '${img.r_score}', '${img.r_date}', '${img.r_content}', '${img.r_img}')">
                        <img src="../upload/${img.r_img}" alt="포토리뷰 이미지">
                    </div>
                </c:forEach>
            </div>
            <button type="button" class="slider-btn next-btn" onclick="slideGallery(1)">&gt;</button>
        </div>
    </div>

    <%-- 🎛️ 2. 리뷰 컨트롤 바 (정렬 & 필터) --%>
    <div class="review-control-bar">
        <div class="sort-options">
            <select id="sortType">
                <option value="like">👍 베스트순(좋아요순)</option>
                <option value="date" selected>🆕 최신순</option>
                <option value="high_score">⭐ 평점 높은순</option>
                <option value="low_score">📉 평점 낮은순</option>
            </select>
        </div>
        <div class="filter-options">
            <select id="starFilter">
                <option value="0" selected>모든 별점 보기</option>
                <option value="5">별점 5점만</option>
                <option value="4">별점 4점만</option>
                <option value="3">별점 3점만</option>
                <option value="2">별점 2점만</option>
                <option value="1">별점 1점만</option>
            </select>
        </div>
    </div>

    <%-- 1. 리뷰 리스트 쫙 뿌리기 --%>
    <div id="review-list-container">
        <c:forEach var="r" items="${reviews}">
            <div class="review-card" style="position: relative;">
                    <%-- 🛡️ 로그인 유저 방어막 --%>
                <c:if test="${sessionScope.loginUser.user_id == r.user_id || r.user_id == 'kim124'}">
                    <div class="review-more-menu">
                        <button type="button" class="btn-more" onclick="toggleMenu(${r.review_id})">⋮</button>
                        <div id="menu-content-${r.review_id}" class="menu-content" style="display:none;">
                            <a href="javascript:void(0)" onclick="openUpdateForm(${r.review_id})">수정하기</a>
                            <a href="javascript:void(0)" onclick="deleteReview(${r.review_id})" style="color:red;">삭제하기</a>
                        </div>
                    </div>
                </c:if>
                <div class="review-title">제목: ${r.r_title}</div>
                <div class="review-meta">
                    작성자: ${r.user_id} | 별점: ${r.r_score}점 | 작성일: ${r.r_date}
                </div>

                <c:if test="${not empty r.r_img}">
                    <div class="review-img-box" style="margin: 15px 0;">
                        <img src="../upload/${r.r_img}" alt="리뷰이미지" style="width: 150px; height: 150px; object-fit: cover; border-radius: 8px; border: 1px solid #eee; display: block;">
                    </div>
                </c:if>
                <hr style="border: 0; border-top: 1px solid #eee;">
                <div class="review-content">${r.r_content}</div>

                <div class="review-action-box">
                    <button type="button" id="like-btn-${r.review_id}" class="btn-like" onclick="toggleLike(${r.review_id}, 'kim124')">
                        👍 도움돼요 <span id="like-count-${r.review_id}" class="like-count">${r.r_like}</span>
                    </button>
                    <button type="button" class="btn-detail" onclick="openDetailModal('${r.r_title}', '${r.user_id}', '${r.r_score}', '${r.r_date}', '${r.r_content}', '${r.r_img}')">
                        🔍 리뷰 상세보기
                    </button>
                </div>
            </div>
        </c:forEach>
    </div>

    <%-- 2. 등록된 리뷰가 한 개도 없을 때 --%>
    <c:if test="${empty reviews}">
        <div class="empty-msg">
            <p>아직 작성된 리뷰가 없습니다.</p>
            <p>99년생 무영이가 1등으로 리뷰를 남겨주세요! 👊</p>
        </div>
    </c:if>

    <%-- ========================================================= --%>
    <%-- 🔍 1. 기존에 있던 상세보기 모달 --%>
    <div id="detailModal" onclick="closeDetailModal()" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.8); cursor:pointer;">
        <div onclick="event.stopPropagation()" style="background:#fff; width:600px; margin:50px auto; border-radius:15px; cursor:default; overflow: hidden;">
            <jsp:include page="review_detail.jsp" />
        </div>
    </div>

    <%-- ========================================================= --%>
    <%-- 🛠️ 2. 새로 추가한 '수정 전용 모달' --%>
    <div id="updateModal" onclick="closeUpdateModal()" style="display:none; position:fixed; z-index:2000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.8); cursor:pointer;">
        <div onclick="event.stopPropagation()">
            <jsp:include page="review_update.jsp" />
        </div>
    </div>

</div> <%-- 🌟 review-container 닫히는 태그 --%>

<%-- ========================================================= --%>
<%-- 📸 3. 포토 리뷰만 모아보기 모달 (화면 밖으로 뺀 것) --%>
<div id="photoOnlyModal" onclick="closePhotoOnlyModal()" style="display:none; position:fixed; z-index:1100; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.85); cursor:pointer;">
    <div onclick="event.stopPropagation()" style="background:#fff; width:800px; max-height:80%; margin:50px auto; border-radius:15px; cursor:default; overflow-y: auto; padding: 20px;">
        <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:2px solid #34495e; padding-bottom:10px; margin-bottom:20px;">
            <h2 style="margin:0;">📸 포토 리뷰 모아보기</h2>
            <span onclick="closePhotoOnlyModal()" style="cursor:pointer; font-size:24px; font-weight:bold;">&times;</span>
        </div>
        <div id="photo-only-list-container"></div>
    </div>
</div>

<%-- ========================================================= --%>
<%-- ⚙️ 자바스크립트 구역 --%>
<script>
    function openDetailModal(title, user, score, date, content, img) {
        document.getElementById('detailModal').style.display = 'block';
        document.getElementById('detail_title').innerText = title;
        document.getElementById('detail_user').innerText = user;
        document.getElementById('detail_score').innerText = score;
        document.getElementById('detail_date').innerText = date;
        document.getElementById('detail_text').innerText = content;

        const imgBox = document.getElementById('detail_img_box');
        const imgTag = document.getElementById('detail_img');

        if(img && img !== 'null' && img !== '') {
            imgTag.src = '../upload/' + img;
            imgBox.style.display = 'block';
        } else {
            imgBox.style.display = 'none';
        }
    }

    function closeDetailModal() {
        document.getElementById('detailModal').style.display = 'none';
    }
</script>

<%-- 🌟 외부 JS 파일 연결은 무조건 맨 마지막에! --%>
<script src="../js/review.js"></script>

</body>
</html>