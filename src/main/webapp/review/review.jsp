    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    <!DOCTYPE html>
    <html>
    <head>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css" />

        <script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>
        <meta charset="UTF-8">
        <title>Groot - 상품 리뷰</title>
        <link rel="stylesheet" href="../css/review.css">
    </head>
    <body>

    <%-- 🌟 전체를 감싸는 메인 컨테이너 시작 --%>


        <%-- 🌟 전체를 감싸는 메인 컨테이너 시작 --%>
        <div class="review-container">

            <%-- ========================================================= --%>
            <%-- 🪹 0. 텅 빈 화면 (리뷰가 0개일 때만 보임) --%>
            <%-- ========================================================= --%>
            <div id="empty-review-ui" style="display: ${totalCount == 0 ? 'block' : 'none'}; text-align: center; padding: 60px 20px; background: #f8f9fa; border-radius: 12px; margin-bottom: 20px; border: 1px dashed #ced4da;">
                <div style="font-size: 3rem; margin-bottom: 15px;">🌿</div>
                <h3 style="color: #495057; font-size: 1.3rem; margin-bottom: 10px;">아직 등록된 리뷰가 없습니다.</h3>
                <p style="color: #868e96; margin-bottom: 25px;">이 제품의 첫 번째 리뷰어가 되어주세요! 경험을 공유해주시면 큰 도움이 됩니다.</p>
                <button type="button" onclick="openWriteModal()" style="padding: 12px 24px; background: #6a8d3a; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: bold; font-size: 1.1em; transition: 0.2s;">
                    ✍️ 첫 리뷰 작성하기
                </button>
            </div>

            <%-- ========================================================= --%>
            <%-- 🚀 1. 리뷰 풀세트 화면 (리뷰가 1개 이상일 때만 보임) --%>
            <%-- ========================================================= --%>
            <div id="full-review-ui" style="display: ${totalCount == 0 ? 'none' : 'block'};">

                <%-- 📊 1-1. 리뷰 헤더 및 통계 그래프 구역 --%>
                <div class="review-header">
                    <h2>💬 상품 리뷰</h2>
                    <div class="star-stats-container">
                        <div class="avg-score-box">
                            <div class="avg-score">${avgScore}</div>
                            <div class="avg-stars-container">
                                <div class="avg-stars-base">★★★★★</div>
                                <div class="avg-stars-fill" style="width: ${avgScore * 20}%">★★★★★</div>
                            </div>
                            <div class="total-review-count">구매후기 평점 ${totalCount}개 기준</div>
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
                    </div> <%-- star-stats-container 닫기 --%>

                    <%-- ✍️ 리뷰 작성하기 버튼 (위치 조정) --%>
                    <div style="text-align: right; margin-bottom: 20px;">
                        <button type="button" onclick="openWriteModal()" style="padding: 10px 20px; background: #6a8d3a; color: white; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; font-size: 1.1em;">
                            ✍️ 리뷰 작성하기
                        </button>
                    </div>
                </div> <%-- review-header 닫기 --%>

                    <%-- 📸 1-2. 포토 갤러리 구역 --%>
                    <div class="photo-gallery-container" style="display: ${empty allPhotoImages or allPhotoImages.size() == 0 ? 'none' : 'block'};">
                        <div class="gallery-header">
                            <h2>📸 포토 리뷰 <span id="photo-count">(${allPhotoImages.size()})</span></h2>
                            <a href="javascript:void(0)" class="view-all-photos" onclick="openPhotoGalleryModal()">포토 리뷰만 모아보기 </a>
                        </div>

                        <div class="photo-slider-wrapper">
                            <%-- 왼쪽 버튼 --%>
                                <div class="photo-slider" id="photo-slider">
                                    <c:forEach var="img" items="${allPhotoImages}">
                                        <div class="photo-slide-item" onclick="openDetailModal('${img.r_title}', '${img.user_id}', '${img.r_score}', '${img.r_date}', '${img.r_content}', '${img.r_img}')">

                                                <%-- 🌟 마법의 분기 처리 시작! --%>
                                            <c:choose>
                                                <%-- 1. DB에 저장된 주소가 'http'로 시작하면? -> 클라우드 사진! --%>
                                                <c:when test="${fn:startsWith(img.r_img, 'http')}">
                                                    <img src="${img.r_img}" alt="포토리뷰 이미지" style="width:100%; height:100%; object-fit:cover; border-radius:8px;">
                                                </c:when>

                                                <%-- 2. 아니면? -> 옛날에 올린 로컬 사진! (../upload/ 붙이기) --%>
                                                <c:otherwise>
                                                    <img src="../upload/${img.r_img}" alt="포토리뷰 이미지" style="width:100%; height:100%; object-fit:cover; border-radius:8px;">
                                                </c:otherwise>
                                            </c:choose>

                                        </div>
                                    </c:forEach>
                                </div>

                            <%-- 오른쪽 버튼 --%>
                            <button type="button" class="slider-btn next-btn" onclick="slideGallery(1)"
                                    style="display: ${allPhotoImages.size() > 4 ? 'block' : 'none'};">&gt;</button>
                        </div>
                    </div> <%-- 🌟 [수정] 여기가 포토 갤러리 끝! --%>


                    <%-- 🎛️ 1-3. 리뷰 컨트롤 바 (정렬 & 필터 & 내 글 보기) --%>
                    <div class="review-control-bar" style="display: flex; justify-content: space-between; align-items: center; margin-top: 30px; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 2px solid #222;">

                        <div class="sort-options" style="display: flex; align-items: center; gap: 20px;">
                            <%-- 1. 정렬 셀렉트 박스 --%>
                            <select id="sortType" style="padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; outline: none; cursor: pointer;">
                                <option value="like">👍 베스트순(좋아요순)</option>
                                <option value="date" selected>🆕 최신순</option>
                                <option value="high_score">⭐ 별점 높은순</option>
                                <option value="low_score">📉 별점 낮은순</option>
                            </select>

                            <%-- 🌟 [수정 포인트] 로그인이 되어 있을 때만 체크박스 태그를 생성한다! --%>
                            <c:if test="${not empty sessionScope.loginUser}">
                                <label style="cursor: pointer; display: flex; align-items: center; font-weight: bold; font-size: 0.95em; color: #34495e; user-select: none;">
                                    <input type="checkbox" id="myReviewCheck" style="margin-right: 8px; transform: scale(1.3); cursor: pointer;">
                                    내가 쓴 글만 보기 🙋‍♂️
                                </label>
                            </c:if>
                        </div>

                        <%-- 2. 별점 필터 박스 --%>
                        <div class="filter-options">
                            <select id="starFilter" style="padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; outline: none; cursor: pointer;">
                                <option value="0" selected>모든 별점 보기</option>
                                <option value="5">별점 5점만</option>
                                <option value="4">별점 4점만</option>
                                <option value="3">별점 3점만</option>
                                <option value="2">별점 2점만</option>
                                <option value="1">별점 1점만</option>
                            </select>
                        </div>

                    </div> <%-- 🌟 컨트롤 바 끝 --%>


            </div> <%-- 🌟 full-review-ui 닫기 --%>

                <%-- 📝 4. 리뷰 리스트 뿌려지는 구역 --%>
                <div id="review-list-container">
                </div>

        </div> <%-- 🌟 review-container (메인 박스) 닫기 --%>

    <%-- ========================================================= --%>
    <%-- 🚧 모달(Modal) 창들 모음 (화면 위로 뜨는 애들) --%>
    <%-- ========================================================= --%>

    <%-- 🔍 1. 기존 상세보기 모달 --%>
    <div id="detailModal" onclick="closeDetailModal()" style="display:none; position:fixed; z-index:1000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.8); cursor:pointer;">
        <div onclick="event.stopPropagation()" style="background:#fff; width:600px; margin:50px auto; border-radius:15px; cursor:default; overflow: hidden;">
            <jsp:include page="review_detail.jsp" />
        </div>
    </div>

    <%-- 🛠️ 2. 수정 전용 모달 --%>
    <div id="updateModal" onclick="closeUpdateModal()" style="display:none; position:fixed; z-index:2000; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.8); cursor:pointer;">
        <div onclick="event.stopPropagation()">
            <jsp:include page="review_update.jsp" />
        </div>
    </div>

    <%-- ========================================================= --%>
    <%-- 📸 3. 포토 리뷰만 모아보기 모달 (정렬/필터 추가 풀버전!) --%>
    <%-- ========================================================= --%>
    <div id="photoOnlyModal" onclick="closePhotoOnlyModal()" style="display:none; position:fixed; z-index:1100; left:0; top:0; width:100%; height:100%; background:rgba(0,0,0,0.85); cursor:pointer;">
        <div onclick="event.stopPropagation()" style="background:#fff; width:800px; max-height:80%; margin:50px auto; border-radius:15px; cursor:default; overflow-y: auto; padding: 25px;">

            <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:2px solid #34495e; padding-bottom:10px; margin-bottom:15px;">
                <h2 style="margin:0;">📸 포토 리뷰 모아보기</h2>
                <span onclick="closePhotoOnlyModal()" style="cursor:pointer; font-size:24px; font-weight:bold;">&times;</span>
            </div>

            <%-- 🌟 모달 전용 컨트롤 바 (비동기 트리거 onchange 탑재) --%>
            <div class="review-control-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #eee;">
                <div class="sort-options" style="display: flex; align-items: center; gap: 15px;">
                    <select id="modalSortType" onchange="fetchModalPhotoReviews()" style="padding: 6px 10px; border: 1px solid #ddd; border-radius: 4px; outline: none; cursor: pointer;">
                        <option value="date" selected>🆕 최신순</option>
                        <option value="like">👍 베스트순(좋아요순)</option>
                        <option value="high_score">⭐ 평점 높은순</option>
                        <option value="low_score">📉 평점 낮은순</option>
                    </select>
                    <label style="cursor: pointer; display: flex; align-items: center; font-weight: bold; font-size: 0.9em; color: #34495e; user-select: none;">
                        <input type="checkbox" id="modalMyReviewCheck" onchange="fetchModalPhotoReviews()" style="margin-right: 5px; transform: scale(1.2); cursor: pointer;">
                        내가 쓴 글만 보기 🙋‍♂️
                    </label>
                </div>
                <div class="filter-options">
                    <select id="modalStarFilter" onchange="fetchModalPhotoReviews()" style="padding: 6px 10px; border: 1px solid #ddd; border-radius: 4px; outline: none; cursor: pointer;">
                        <option value="0" selected>모든 별점 보기</option>
                        <option value="5">별점 5점만</option>
                        <option value="4">별점 4점만</option>
                        <option value="3">별점 3점만</option>
                        <option value="2">별점 2점만</option>
                        <option value="1">별점 1점만</option>
                    </select>
                </div>
            </div>

            <div id="photo-only-list-container"></div>
        </div>
    </div>

    <%-- ✍️ 4. 리뷰 작성하기 모달 --%>
    <div id="writeModal" class="modal" style="display:none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6);">
        <%-- 🌟 마진(margin)을 5%에서 15vh(화면 높이의 15%)로 늘려서 파란 헤더 밑으로 쏙 내렸습니다 --%>
        <div class="modal-content" style="background: white; margin: 15vh auto 50px auto; padding: 30px; width: 500px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2 style="margin: 0;">✍️ 리뷰 작성하기</h2>
                <span onclick="closeWriteModal()" style="cursor: pointer; font-size: 24px;">&times;</span>
            </div>

            <form id="writeForm" enctype="multipart/form-data">
                <%-- 🌟 하드코딩 106을 지우고, 메인 페이지에서 넘겨받은 진짜 ID로 바꿉니다! --%>
                <input type="hidden" name="product_id" value="${param.PRODUCT_ID}">

                <div style="margin-bottom:15px;">
                    <label style="font-weight: bold;">제목</label>
                    <input type="text" name="r_title" required style="width:100%; padding:8px; margin-top:5px; border:1px solid #ddd; border-radius:5px;">
                </div>

                <div style="margin-bottom:15px;">
                    <label style="font-weight: bold;">별점</label>
                    <div class="star-rating" style="margin-top:5px;">
                        <span class="write-star" data-value="1">★</span>
                        <span class="write-star" data-value="2">★</span>
                        <span class="write-star" data-value="3">★</span>
                        <span class="write-star" data-value="4">★</span>
                        <span class="write-star" data-value="5">★</span>
                    </div>
                    <input type="hidden" name="r_score" id="write_score" value="5">
                </div>

                <div style="margin-bottom:15px;">
                    <label style="font-weight: bold;">내용</label>
                    <textarea name="r_content" rows="5" maxlength="500" required style="width:100%; padding:8px; margin-top:5px; border:1px solid #ddd; border-radius:5px; resize:none;"></textarea>
                </div>

                <div style="margin-bottom:20px;">
                    <label style="font-weight: bold;">사진 첨부</label>
                    <input type="file" name="r_img" accept="image/*" style="display: block; margin-top: 10px;">
                </div>

                <div style="text-align: center;">
                    <button type="button" onclick="submitReview()" style="width: 100%; padding: 12px; background: #6a8d3a; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: bold; font-size: 1.1em;">리뷰 등록하기</button>
                </div>
            </form>
        </div>
    </div>
    <%-- ========================================================= --%>
    <%-- ⚙️ 자바스크립트 전역 변수 세팅 (가데이터 탈출!) --%>
    <script>
        // 1. 도혁씨의 로그인 세션 연동 (UserDTO의 user_id 사용)
        const currentLoginId = "${empty sessionScope.loginUser ? '' : sessionScope.loginUser.user_id}";

        // 2. 경용씨의 제품 ID 연동 (product_detail.jsp에서 넘겨준 값)
        const currentProductId = "${param.PRODUCT_ID != null ? param.PRODUCT_ID : '106'}";
    </script>


    <%-- 🌟 외부 JS 파일 연결은 무조건 맨 마지막에! --%>
    <script src="../js/review.js"></script>

    </body>
    </html>
