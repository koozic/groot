// ==========================================
// 🌟 0. 전역 변수 & 공통 이미지 경로 판별기
// ==========================================
// 클라우드(http)면 그대로, 옛날거면 ../upload/ 붙여주는 마법의 함수!
function getImgPath(img) {
    if (!img || img === 'null' || img === '' || img === 'undefined') return '';
    return img.startsWith('http') ? img : `../upload/${img}`;
}

document.addEventListener('DOMContentLoaded', function() {

    // 🌟 [핵심 해결책] 이벤트 위임(Event Delegation) 기법!
    // 버튼들이 통째로 갈아끼워져도 절대 지워지지 않는 body에 센서를 달아둡니다.
    document.body.addEventListener('change', function(event) {
        // 폼 안에서 무언가 변경되었을 때, 그게 우리가 찾는 필터 버튼들이 맞는지 확인!
        const id = event.target.id;
        if (id === 'sortType' || id === 'starFilter' || id === 'myReviewCheck') {
            fetchReviews();
        }
    });

    // 화면 켜지자마자 리스트 1번 불러오기
    fetchReviews();
});

window.onclick = function(event) {
    if (!event.target.matches('.btn-more')) {
        document.querySelectorAll('.menu-content').forEach(m => m.style.display = 'none');
    }
}

// ... (이하 코드들은 기존 그대로 두시면 됩니다!) ...

// ==========================================
// 📸 1. 포토 갤러리 모달
// ==========================================
function slideGallery(direction) {
    const slider = document.getElementById('photo-slider');
    slider.scrollBy({ left: direction * 165, behavior: 'smooth' });
}

function openPhotoGalleryModal() {
    document.getElementById('photoOnlyModal').style.display = 'block';
    fetchModalPhotoReviews();
}

function closePhotoOnlyModal() {
    document.getElementById('photoOnlyModal').style.display = 'none';
}

function fetchModalPhotoReviews() {
    let pId = currentProductId;
    const sortType = document.getElementById('modalSortType').value;
    const starFilter = document.getElementById('modalStarFilter').value;
    const isMyReview = document.getElementById('modalMyReviewCheck').checked;

    fetch(`review?PRODUCT_ID=${pId}&sortType=${sortType}&starFilter=${starFilter}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
            const container = document.getElementById('photo-only-list-container');
            container.innerHTML = '';

            let photoReviews = data.filter(r => r.r_img && r.r_img !== 'null' && r.r_img !== '');
            if (isMyReview) photoReviews = photoReviews.filter(r => r.user_id && r.user_id.trim() === currentLoginId);

            if (photoReviews.length === 0) {
                container.innerHTML = '<p style="text-align:center; padding:50px; font-weight:bold; color:#777;">조건에 맞는 포토 리뷰가 없습니다.</p>';
                return;
            }

            photoReviews.forEach(r => {
                // 🌟 마법의 함수 getImgPath() 적용!
                container.innerHTML += `
                <div class="photo-item" style="display:flex; gap:20px; padding:20px 10px; border-bottom:1px solid #eee; align-items:center;">
                    <img src="${getImgPath(r.r_img)}" style="width:130px; height:130px; object-fit:cover; border-radius:10px; border:1px solid #ddd;">
                    <div style="flex-grow:1;">
                        <div style="font-weight:bold; font-size:1.15em; margin-bottom:5px;">${r.r_title}</div>
                        <div style="color:#777; font-size:0.9em; margin-bottom:10px;">
                           작성자: ${r.user_id} | ${makeStarHtml(r.r_score)} | ${formatKoreanDate(r.r_date)}
                        </div>
                        <div style="font-size:0.95em; line-height:1.5; margin-bottom: 15px;">${r.r_content}</div>
                        <button type="button" class="btn-like" onclick="toggleLike(${r.review_id}, '${currentLoginId}')" style="padding: 6px 12px; font-size: 0.85em;">
                            👍 도움돼요 <span id="like-count-modal-${r.review_id}">${r.r_like}</span>
                        </button>
                    </div>
                </div>`;
            });
        });
}

// ==========================================
// 🚀 2. 좋아요 처리
// ==========================================
function toggleLike(reviewId, userId) {
    if (!userId || userId === 'null' || userId === '') {
        showToast("로그인이 필요한 기능입니다! 🔒", "error");
        return;
    }
    const params = new URLSearchParams();
    params.append('review_id', reviewId);
    params.append('user_id', userId);

    fetch('review-like', { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' }, body: params })
        .then(res => res.text())
        .then(data => {
            const mainLike = document.getElementById(`like-count-${reviewId}`);
            if (mainLike) mainLike.innerText = data;
            const modalLike = document.getElementById(`like-count-modal-${reviewId}`);
            if (modalLike) modalLike.innerText = data;
        });
}

// ==========================================
// 🎛️ 3. 비동기 하단 리스트 & 페이징
// ==========================================
let allReviewsData = [];
let filteredReviewsData = [];
let currentPage = 1;
const itemsPerPage = 5;
let isMobile = window.innerWidth <= 768;

window.addEventListener('resize', () => {
    const checkMobile = window.innerWidth <= 768;
    if (isMobile !== checkMobile) {
        isMobile = checkMobile;
        currentPage = 1;
        renderPaginatedReviews(false);
    }
});

function fetchReviews() {
    let pId = currentProductId;
    const sortType = document.getElementById('sortType').value;
    const starFilter = document.getElementById('starFilter').value;

    fetch(`review?PRODUCT_ID=${pId}&sortType=${sortType}&starFilter=${starFilter}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
            allReviewsData = data;
            const isMyReview = document.getElementById('myReviewCheck') ? document.getElementById('myReviewCheck').checked : false;

            filteredReviewsData = isMyReview ? allReviewsData.filter(r => r.user_id && r.user_id.trim() === currentLoginId) : allReviewsData;
            currentPage = 1;
            renderPaginatedReviews(false);
        });
}

// 🌟 핵심: 페이징 처리해서 화면에 그리는 함수
function renderPaginatedReviews(isAppend = false) {
    const container = document.getElementById('review-list-container');
    const emptyUi = document.getElementById('empty-review-ui');
    const fullUi = document.getElementById('full-review-ui');

    if (!isAppend) container.innerHTML = '';

    // 🌟 현재 필터가 걸려있는지 눈치껏 확인 (별점 필터가 0이 아니거나, 내 글 보기 체크됨)
    const starFilter = document.getElementById('starFilter') ? document.getElementById('starFilter').value : "0";
    const isMyReview = document.getElementById('myReviewCheck') ? document.getElementById('myReviewCheck').checked : false;
    const isFiltering = (starFilter !== "0") || isMyReview;

    // 1️⃣ [진짜 텅 빈 상태] 아예 필터도 안 걸었는데 리뷰가 1개도 없을 때
    if (allReviewsData.length === 0 && !isFiltering) {
        if (emptyUi) emptyUi.style.display = 'block';
        if (fullUi) fullUi.style.display = 'none';
        const pageArea = document.getElementById('pagination-area');
        if (pageArea) pageArea.innerHTML = ''; // 페이징 날리기
        return;
    }

    // 2️⃣ [필터 결과 0개] 별점 3점을 눌렀는데 없거나, 내 글이 없을 때
    if (filteredReviewsData.length === 0 || (allReviewsData.length === 0 && isFiltering)) {
        if (fullUi) fullUi.style.display = 'block'; // 🌟 컨트롤 바(필터)는 무조건 살려둠!
        if (emptyUi) emptyUi.style.display = 'none';

        // 말씀하신 동그라미 친 영역에만 텍스트 띄우기
        container.innerHTML = `
            <div style="text-align:center; padding:60px 20px; color:#777;">
                <div style="font-size:2.5rem; margin-bottom:15px;">🔍</div>
                <h3 style="margin-bottom:10px;">조건에 맞는 리뷰가 없습니다.</h3>
                <p>필터를 해제하거나 다른 조건을 선택해 보세요.</p>
            </div>`;

        const pageArea = document.getElementById('pagination-area');
        if (pageArea) pageArea.innerHTML = ''; // 🌟 페이징 버튼 깔끔하게 숨기기
        return;
    }

    // 3️⃣ [정상 출력] 데이터가 있을 때
    if (emptyUi) emptyUi.style.display = 'none';
    if (fullUi) fullUi.style.display = 'block';

    // ✂️ 5개씩 자르기 로직 시작...
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const pageData = filteredReviewsData.slice(startIndex, endIndex);

    pageData.forEach(r => {
        let imgHtml = (r.r_img && r.r_img !== 'null' && r.r_img !== '')
            ? `<div class="review-img-box" style="margin: 15px 0;"><img src="${getImgPath(r.r_img)}" style="width: 150px; border-radius: 8px;"></div>`
            : '';

        const rUser = r.user_id ? r.user_id.trim() : "";

        // 🌟 [핵심 변경] 여기에 관리자 아이디 조건을 추가합니다! (예: 'admin')
        // 만약 팀에서 정한 관리자 아이디가 다르다면 'admin' 글자를 바꿔주세요!
        const isAdmin = (currentLoginId === 'admin');

        // 내 글이거나 OR 관리자일 때만 메뉴 버튼을 보여줌!
        let menuHtml = (currentLoginId !== "" && (rUser === currentLoginId || isAdmin)) ? `
            <div class="review-more-menu">
                <button type="button" class="btn-more" onclick="toggleMenu(${r.review_id})">⋮</button>
                <div id="menu-content-${r.review_id}" class="menu-content" style="display:none;">
                    ${rUser === currentLoginId ? `<a href="javascript:void(0)" onclick="openUpdateForm(${r.review_id})">수정하기</a>` : ''}
                    <a href="javascript:void(0)" onclick="deleteReview(${r.review_id})" style="color:red;">삭제하기</a>
                </div>
            </div>` : '';

        const safeTitle = r.r_title ? r.r_title.replace(/'/g, "\\'") : '';
        const safeContent = r.r_content ? r.r_content.replace(/'/g, "\\'") : '';
        container.innerHTML += `
            <div class="review-card" style="position: relative;">
                ${menuHtml}
                <div class="review-title">제목: ${r.r_title}</div>
                <div class="review-meta">작성자: ${r.user_id} | ${makeStarHtml(r.r_score)} | 작성일: ${formatKoreanDate(r.r_date)}</div>
                ${imgHtml}
                <hr style="border:0; border-top:1px solid #eee;">
                <div class="review-content">${r.r_content}</div>
                <div class="review-action-box">
                    <button type="button" class="btn-like" onclick="toggleLike(${r.review_id}, '${currentLoginId}')">👍 <span id="like-count-${r.review_id}">${r.r_like}</span></button>
                    <button type="button" class="btn-detail" onclick="openDetailModal('${safeTitle}', '${r.user_id}', '${r.r_score}', '${formatKoreanDate(r.r_date)}', '${safeContent}', '${r.r_img}')">🔍 리뷰 상세보기</button>
                </div>
            </div>`;
    });

    renderPaginationButtons();
}

// 하단 페이징 처리 (PC/모바일)
function renderPaginationButtons() {
    let pageArea = document.getElementById('pagination-area');
    if(!pageArea) {
        pageArea = document.createElement('div');
        pageArea.id = 'pagination-area';
        pageArea.style.textAlign = 'center';
        pageArea.style.margin = '30px 0 50px 0';
        document.getElementById('review-list-container').after(pageArea);
    }
    pageArea.innerHTML = '';
    const totalPages = Math.ceil(filteredReviewsData.length / itemsPerPage);
    if (totalPages <= 1) return;

    if (isMobile) {
        if (currentPage < totalPages) {
            pageArea.innerHTML = `<button type="button" onclick="loadMoreReviews()" style="width:100%; padding:15px; background:#fff; border:1px solid #ddd; border-radius:8px; font-weight:bold; font-size:1.1em; color:#333; cursor:pointer;">리뷰 더보기 ⬇️</button>`;
        }
    } else {
        let html = '';
        if (currentPage > 1) html += `<a href="javascript:void(0)" onclick="goToPage(${currentPage - 1})" style="margin:0 8px; font-weight:bold; color:#555; text-decoration:none;">&lt;</a>`;
        for (let i = Math.max(1, currentPage-2); i <= Math.min(totalPages, currentPage+2); i++) {
            if (i === currentPage) html += `<span style="margin:0 5px; padding:6px 14px; background:#6a8d3a; color:#fff; border-radius:4px;">${i}</span>`;
            else html += `<a href="javascript:void(0)" onclick="goToPage(${i})" style="margin:0 5px; padding:6px 14px; color:#555; text-decoration:none;">${i}</a>`;
        }
        if (currentPage < totalPages) html += `<a href="javascript:void(0)" onclick="goToPage(${currentPage + 1})" style="margin:0 8px; font-weight:bold; color:#555; text-decoration:none;">&gt;</a>`;
        pageArea.innerHTML = html;
    }
}
function loadMoreReviews() { currentPage++; renderPaginatedReviews(true); }
function goToPage(page) { currentPage = page; renderPaginatedReviews(false); window.scrollTo({ top: document.querySelector('.review-control-bar').offsetTop - 110, behavior: 'smooth' }); }

// ==========================================
// 🔍 4. 리뷰 상세보기 모달
// ==========================================
function openDetailModal(title, user, score, date, content, img) {
    document.getElementById('detailModal').style.display = 'block';
    document.getElementById('detail_title').innerText = title;
    document.getElementById('detail_user').innerText = user;
    document.getElementById('detail_score').innerHTML = makeStarHtml(score);
    document.getElementById('detail_date').innerText = date;
    document.getElementById('detail_text').innerHTML = content;

    const imgBox = document.getElementById('detail_img_box');
    const imgTag = document.getElementById('detail_img');

    if(img && img !== 'null' && img !== '' && img !== 'undefined') {
        // 🌟 마법의 함수 getImgPath() 적용!
        imgTag.src = getImgPath(img);
        imgBox.style.display = 'block';
    } else {
        imgBox.style.display = 'none';
    }
}
function closeDetailModal() { document.getElementById('detailModal').style.display = 'none'; }

// ==========================================
// 🗑️ 5. 리뷰 삭제
// ==========================================
function deleteReview(reviewId) {
    if (!confirm("정말 삭제하시겠습니까?")) return;
    fetch(`review-delete?review_id=${reviewId}`)
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                showToast("리뷰를 삭제했습니다. 🗑️");
                refreshReviewUI();
                fetchReviews();
            } else alert("삭제 실패!");
        });
}

// ==========================================
// 🪄 6. 리뷰 수정 (미리보기)
// ==========================================
function openUpdateForm(reviewId) {
    try {
        const card = document.getElementById(`menu-content-${reviewId}`).closest('.review-card');
        let title = card.querySelector('.review-title').innerText.replace('제목: ', '').trim();
        let content = card.querySelector('.review-content').innerHTML.replace(/<br>/g, '\n').trim();
        let scoreMatch = card.querySelector('.review-meta').innerText.match(/별점: (\d+)점/);
        let score = scoreMatch ? scoreMatch[1] : 5;
        let imgTag = card.querySelector('.review-img-box img');

        let fullSrc = imgTag ? imgTag.src : "";

        if(document.getElementById('upd_review_id')) document.getElementById('upd_review_id').value = reviewId;
        if(document.getElementById('upd_title')) document.getElementById('upd_title').value = title;
        if(document.getElementById('upd_score')) document.getElementById('upd_score').value = score;
        if(document.getElementById('upd_content')) { document.getElementById('upd_content').value = content; updateCharCount(); }
        if(document.getElementById('upd_p_id')) document.getElementById('upd_p_id').value = currentProductId;

        const existImgBox = document.getElementById('existing_img_box');
        const previewImg = document.getElementById('preview_old_img');
        const isDelHidden = document.getElementById('isImgDeleted');
        const oldImgInput = document.getElementById('old_img_name');

        if (existImgBox && isDelHidden) {
            document.getElementById('delete_img_check').checked = false;
            isDelHidden.value = "false";

            if (fullSrc) {
                existImgBox.style.display = 'block';
                if(previewImg) previewImg.src = fullSrc;
                // 🌟 클라우드 주소면 통째로 유지, 아니면 파일명만 따기
                oldImgInput.value = fullSrc.includes('http') ? fullSrc : fullSrc.split('/').pop();
            } else {
                existImgBox.style.display = 'none';
            }
        }
        setUpdateStars(score);
        document.getElementById('updateModal').style.display = 'block';
    } catch (e) { alert("오류 발생!"); }
}

function setUpdateStars(score) {
    document.querySelectorAll('.upd-star').forEach(s => { s.style.color = (s.getAttribute('data-value') <= score) ? '#ffc107' : '#ddd'; });
}
document.querySelectorAll('.upd-star').forEach(star => {
    star.addEventListener('click', function() {
        const s = this.getAttribute('data-value');
        document.getElementById('upd_score').value = s;
        setUpdateStars(s);
    });
});
function toggleImgDelete() { document.getElementById('isImgDeleted').value = document.getElementById('delete_img_check').checked ? "true" : "false"; }
function closeUpdateModal() { document.getElementById('updateModal').style.display = 'none'; }

function submitUpdate() {
    fetch('ReviewUpdateC', { method: 'POST', body: new FormData(document.getElementById('updateForm')) })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                showToast("리뷰 수정을 완료했습니다! 🪄");
                closeUpdateModal();
                refreshReviewUI();
                fetchReviews();
            } else alert("수정 실패!");
        });
}

function toggleMenu(id) {
    const m = document.getElementById(`menu-content-${id}`);
    document.querySelectorAll('.menu-content').forEach(el => { if(el.id !== `menu-content-${id}`) el.style.display = 'none'; });
    m.style.display = (m.style.display === 'none') ? 'block' : 'none';
}

// ==========================================
// 📝 7. 글자 수 카운팅 및 별점 조립
// ==========================================
function updateCharCount() {
    const charCount = document.getElementById('charCount');
    if (charCount) charCount.innerText = document.getElementById('upd_content').value.length;
}

function makeStarHtml(score) {
    let stars = '';
    for (let i = 1; i <= 5; i++) stars += (i <= score) ? '<span class="star-gold">★</span>' : '<span class="star-gray">☆</span>';
    return stars;
}

// ==========================================
// ✍️ 8. 리뷰 작성 모달 제어
// ==========================================
function openWriteModal() {
    if (!currentLoginId || currentLoginId === "") { showToast("로그인이 필요한 기능입니다! 🔒", "error"); return; }
    document.getElementById('writeForm').reset();
    setWriteStars(5);
    document.getElementById('writeModal').style.display = 'block';
}

function closeWriteModal() { document.getElementById('writeModal').style.display = 'none'; }

document.querySelectorAll('.write-star').forEach(star => {
    star.addEventListener('click', function() {
        const val = this.getAttribute('data-value');
        document.getElementById('write_score').value = val;
        setWriteStars(val);
    });
});

function setWriteStars(score) {
    document.querySelectorAll('.write-star').forEach(s => { s.style.color = (s.getAttribute('data-value') <= score) ? '#ffc107' : '#ddd'; });
}

function submitReview() {
    fetch('review-write', { method: 'POST', body: new FormData(document.getElementById('writeForm')) })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                showToast("리뷰가 등록되었습니다! ✨");
                closeWriteModal();
                refreshReviewUI();
                fetchReviews();
            } else alert("등록 실패!");
        });
}

// ==========================================
// 🍞 기타 유틸 (토스트, 날짜, 새로고침)
// ==========================================
function showToast(message, type = "success") {
    const toast = document.getElementById("toast");
    if (toast) {
        toast.innerText = message;
        toast.className = `toast show ${type}`;
        setTimeout(() => toast.classList.remove("show"), 1300);
    } else alert(message);
}

function formatKoreanDate(dateStr) {
    if (!dateStr) return "";
    const regex = /(\d+)\s*월\s+(\d+),\s+(\d+)/;
    const match = dateStr.match(regex);
    return match ? `${match[3]}년 ${match[1]}월 ${match[2]}일` : dateStr;
}

function refreshReviewUI() {
    fetch(window.location.href)
        .then(res => res.text())
        .then(html => {
            const doc = new DOMParser().parseFromString(html, 'text/html');
            const selectors = ['.review-header', '.photo-gallery-container', '#empty-review-ui', '#full-review-ui'];
            selectors.forEach(s => {
                const oldEl = document.querySelector(s);
                const newEl = doc.querySelector(s);
                if(oldEl && newEl) {
                    oldEl.innerHTML = newEl.innerHTML;
                    if(s.includes('ui')) oldEl.style.display = newEl.style.display;
                }
            });
        });
}