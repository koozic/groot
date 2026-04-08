// ==========================================
// 🌟 0. 전역 변수 & 초기화
// ==========================================
const currentLoginId = 'kim124';

document.addEventListener('DOMContentLoaded', function() {
    const sortSelect = document.getElementById('sortType');
    const starSelect = document.getElementById('starFilter');
    const myReviewCheck = document.getElementById('myReviewCheck'); // 🌟 체크박스 찾기

    if(sortSelect) sortSelect.addEventListener('change', fetchReviews);
    if(starSelect) starSelect.addEventListener('change', fetchReviews);
    if(myReviewCheck) myReviewCheck.addEventListener('change', fetchReviews); // 🌟 누르면 리스트 다시 부르기!

    fetchReviews();
});

window.onclick = function(event) {
    if (!event.target.matches('.btn-more')) {
        document.querySelectorAll('.menu-content').forEach(m => m.style.display = 'none');
    }
}

// ==========================================
// 📸 1. 포토 갤러리 슬라이드 & 모달
// ==========================================
function slideGallery(direction) {
    const slider = document.getElementById('photo-slider');
    slider.scrollBy({ left: direction * 165, behavior: 'smooth' });
}

function openPhotoGalleryModal() {
    document.getElementById('photoOnlyModal').style.display = 'block';
    const pId = new URLSearchParams(window.location.search).get('PRODUCT_ID') || 106;

    fetch(`review?PRODUCT_ID=${pId}&sortType=photo`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
            const container = document.getElementById('photo-only-list-container');
            container.innerHTML = '';
            const photoReviews = data.filter(r => r.r_img && r.r_img !== 'null');

            if (photoReviews.length === 0) {
                container.innerHTML = '<p style="text-align:center; padding:30px;">등록된 포토 리뷰가 없습니다.</p>';
                return;
            }
            photoReviews.forEach(r => {
                container.innerHTML += `
            <div class="photo-item" style="display:flex; gap:20px; padding:15px; border-bottom:1px solid #eee; align-items:center;">
                <img src="../upload/${r.r_img}" style="width:120px; height:120px; object-fit:cover; border-radius:8px;">
                <div style="flex-grow:1;">
                    <div style="font-weight:bold;">${r.r_title}</div>
                   <div style="color:#777; font-size:0.9em;">작성자: ${r.user_id} | ${makeStarHtml(r.r_score)}</div>
                    <div style="font-size:0.95em;">${r.r_content}</div>
                </div>
            </div>`;
            });
        });
}

function closePhotoOnlyModal() { document.getElementById('photoOnlyModal').style.display = 'none'; }

// ==========================================
// 🚀 2. 좋아요 비동기 처리
// ==========================================
function toggleLike(reviewId, userId) {
    if (!userId || userId === 'null') { alert('로그인이 필요합니다.'); return; }
    const params = new URLSearchParams();
    params.append('review_id', reviewId);
    params.append('user_id', userId);

    fetch('review-like', { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' }, body: params })
        .then(res => res.text())
        .then(data => { document.getElementById(`like-count-${reviewId}`).innerText = data; });
}

// =========================================================
// 🎛️ 3. 비동기 정렬 리스트 & 하이브리드 페이징 (PC/모바일)
// =========================================================
let allReviewsData = [];       // 전체 데이터 백업
let filteredReviewsData = [];  // 필터링(내가 쓴 글) 완료된 데이터
let currentPage = 1;
const itemsPerPage = 5;        // 한 번에 5개씩 보여주기!
let isMobile = window.innerWidth <= 768; // 화면 크기 감지 (768px 이하면 모바일)

// 🌟 프로의 디테일: 창 크기를 줄이거나 늘리면 실시간으로 PC/모바일 모드 전환!
window.addEventListener('resize', () => {
    const checkMobile = window.innerWidth <= 768;
    if (isMobile !== checkMobile) {
        isMobile = checkMobile;
        currentPage = 1; // 화면 바뀌면 1페이지로 깔끔하게 리셋
        renderPaginatedReviews(false);
    }
});

function fetchReviews() {
    const urlParams = new URLSearchParams(window.location.search);
    let pId = urlParams.get('PRODUCT_ID') || 106;
    const sortType = document.getElementById('sortType').value;
    const starFilter = document.getElementById('starFilter').value;

    fetch(`review?PRODUCT_ID=${pId}&sortType=${sortType}&starFilter=${starFilter}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
            allReviewsData = data;

            // '내가 쓴 글만 보기' 체크 확인
            const myReviewCheck = document.getElementById('myReviewCheck');
            const isMyReview = myReviewCheck ? myReviewCheck.checked : false;

            if (isMyReview) {
                filteredReviewsData = allReviewsData.filter(r => r.user_id && r.user_id.trim() === currentLoginId);
            } else {
                filteredReviewsData = allReviewsData;
            }

            currentPage = 1; // 새 데이터 가져오면 1페이지로 리셋
            renderPaginatedReviews(false); // 🌟 화면 그리기 출동!
        });
}

// 🌟 핵심: 페이징 처리해서 화면에 그리는 함수 (isAppend: 모바일 더보기용)
function renderPaginatedReviews(isAppend = false) {
    const container = document.getElementById('review-list-container');

    if (!isAppend) {
        container.innerHTML = ''; // PC 번호 이동이거나 첫 로딩이면 싹 비우기
    }

    if (filteredReviewsData.length === 0) {
        container.innerHTML = `<div class="empty-msg" style="text-align:center; padding:50px;"><p>해당 조건에 맞는 리뷰가 없습니다.</p></div>`;
        renderPaginationButtons(); // 데이터 없으면 하단 버튼도 지우기
        return;
    }

    // ✂️ 5개씩 데이터 자르기!
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const pageData = filteredReviewsData.slice(startIndex, endIndex);

    // 잘라낸 5개 데이터 화면에 붙이기 (이전 renderReviews 안의 로직과 동일)
    pageData.forEach(r => {
        let imgHtml = (r.r_img && r.r_img !== 'null') ? `<div class="review-img-box" style="margin: 15px 0;"><img src="../upload/${r.r_img}" style="width: 150px; border-radius: 8px;"></div>` : '';
        const rUser = r.user_id ? r.user_id.trim() : "";
        let menuHtml = '';

        if (rUser === currentLoginId || rUser === 'kim124') {
            menuHtml = `
            <div class="review-more-menu">
                <button type="button" class="btn-more" onclick="toggleMenu(${r.review_id})">⋮</button>
                <div id="menu-content-${r.review_id}" class="menu-content" style="display:none;">
                    <a href="javascript:void(0)" onclick="openUpdateForm(${r.review_id})">수정하기</a>
                    <a href="javascript:void(0)" onclick="deleteReview(${r.review_id})" style="color:red;">삭제하기</a>
                </div>
            </div>`;
        }

        container.innerHTML += `
            <div class="review-card" style="position: relative;">
                ${menuHtml}
                <div class="review-title">제목: ${r.r_title}</div>
                <div class="review-meta">작성자: ${r.user_id} | ${makeStarHtml(r.r_score)} | 작성일: ${r.r_date}</div>
                ${imgHtml}
                <hr style="border:0; border-top:1px solid #eee;">
                <div class="review-content">${r.r_content}</div>
                <div class="review-action-box">
                    <button type="button" class="btn-like" onclick="toggleLike(${r.review_id}, '${currentLoginId}')">👍 <span id="like-count-${r.review_id}">${r.r_like}</span></button>
                    <button type="button" class="btn-detail" onclick="openDetailModal('${r.r_title}', '${r.user_id}', '${r.r_score}', '${r.r_date}', '${r.r_content}', '${r.r_img}')">🔍 리뷰 상세보기</button>
                </div>
            </div>`;
    });

    renderPaginationButtons(); // 다 그렸으면 하단 버튼 그리기
}

// 🌟 PC(번호판) / 모바일(더보기) 하단 버튼 자동 변환 마술
function renderPaginationButtons() {
    let pageArea = document.getElementById('pagination-area');
    if(!pageArea) {
        // html에 구역이 없으면 자바스크립트가 알아서 html 뼈대까지 만들어줍니다!
        pageArea = document.createElement('div');
        pageArea.id = 'pagination-area';
        pageArea.style.textAlign = 'center';
        pageArea.style.margin = '30px 0 50px 0';
        document.getElementById('review-list-container').after(pageArea);
    }

    pageArea.innerHTML = '';
    const totalPages = Math.ceil(filteredReviewsData.length / itemsPerPage);

    if (totalPages <= 1) return; // 1페이지만 있으면 버튼 숨김

    if (isMobile) {
        // 📱 모바일 화면일 때: [올리브영 스타일 더보기]
        if (currentPage < totalPages) {
            pageArea.innerHTML = `
                <button type="button" onclick="loadMoreReviews()" style="width:100%; padding:15px; background:#fff; border:1px solid #ddd; border-radius:8px; font-weight:bold; font-size:1.1em; color:#333; cursor:pointer; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                    리뷰 더보기 (${currentPage * itemsPerPage} / ${filteredReviewsData.length}) ⬇️
                </button>`;
        }
    } else {
        // 💻 PC 화면일 때: [쿠팡 스타일 1, 2, 3 번호판]
        let html = '';
        for (let i = 1; i <= totalPages; i++) {
            if (i === currentPage) {
                // 현재 페이지는 굵은 초록색
                html += `<span style="display:inline-block; margin:0 10px; font-weight:bold; color:#6a8d3a; font-size:1.3em; cursor:default;">${i}</span>`;
            } else {
                // 다른 페이지는 누를 수 있는 링크
                html += `<a href="javascript:void(0)" onclick="goToPage(${i})" style="display:inline-block; margin:0 10px; color:#777; text-decoration:none; font-size:1.1em;">${i}</a>`;
            }
        }
        pageArea.innerHTML = html;
    }
}

// 📱 모바일 전용: 더보기 버튼 누를 때
function loadMoreReviews() {
    currentPage++;
    renderPaginatedReviews(true); // true = 기존 리스트 밑에 추가(Append)!
}

// 💻 PC 전용: 번호 누를 때
function goToPage(page) {
    currentPage = page;
    renderPaginatedReviews(false); // false = 리스트 싹 지우고 새로 쓰기!

    // 번호 누르면 화면 살짝 위로 올려주는 센스
    document.getElementById('review-list-container').scrollIntoView({ behavior: 'smooth' });
}
// ==========================================
// 🔍 4. 리뷰 상세보기
// ==========================================
function openDetailModal(title, user, score, date, content, img) {
    document.getElementById('detailModal').style.display = 'block';
    document.getElementById('detail_title').innerText = title;
    document.getElementById('detail_user').innerText = user;
    document.getElementById('detail_score').innerHTML = makeStarHtml(score);
    document.getElementById('detail_date').innerText = date;
    document.getElementById('detail_text').innerText = content;

    const imgBox = document.getElementById('detail_img_box');
    const imgTag = document.getElementById('detail_img');

    if(img && img !== 'null' && img !== '' && img !== 'undefined') {
        imgTag.src = '../upload/' + img;
        imgBox.style.display = 'block';
    } else {
        imgBox.style.display = 'none';
    }
}
function closeDetailModal() { document.getElementById('detailModal').style.display = 'none'; }

// ==========================================
// 🗑️ 5. 리뷰 삭제 (삭제 후 자동 새로고침!)
// ==========================================
function deleteReview(reviewId) {
    if (!confirm("정말 삭제하시겠습니까?")) return;

    fetch(`review-delete?review_id=${reviewId}`)
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                alert("삭제완료!");
                const card = document.getElementById(`menu-content-${reviewId}`).closest('.review-card');
                if(card) {
                    card.style.opacity = '0';
                    card.style.transition = 'opacity 0.3s ease';
                    // 🌟 스르륵 지워지고 나서 페이지 전체 새로고침! (그래프/숫자 동기화)
                    setTimeout(() => location.reload(), 300);
                } else {
                    location.reload();
                }
            } else {
                alert("삭제 실패!");
            }
        });
}

// ==========================================
// 🪄 6. 리뷰 수정 (미리보기 사진 추가 완료!)
// ==========================================
function openUpdateForm(reviewId) {
    try {
        const card = document.getElementById(`menu-content-${reviewId}`).closest('.review-card');
        let title = card.querySelector('.review-title').innerText.replace('제목: ', '').trim();
        let content = card.querySelector('.review-content').innerHTML.replace(/<br>/g, '\n').trim();
        let scoreMatch = card.querySelector('.review-meta').innerText.match(/별점: (\d+)점/);
        let score = scoreMatch ? scoreMatch[1] : 5;
        let imgTag = card.querySelector('.review-img-box img');
        let imgSrc = imgTag ? imgTag.src.split('/').pop() : "";

        if(document.getElementById('upd_review_id')) document.getElementById('upd_review_id').value = reviewId;
        if(document.getElementById('upd_title')) document.getElementById('upd_title').value = title;
        if(document.getElementById('upd_score')) document.getElementById('upd_score').value = score;

        if(document.getElementById('upd_content')) {
            document.getElementById('upd_content').value = content;
            updateCharCount(); // 글자 수 카운팅
        }

        if(document.getElementById('old_img_name')) document.getElementById('old_img_name').value = imgSrc;

        const urlParams = new URLSearchParams(window.location.search);
        if(document.getElementById('upd_p_id')) document.getElementById('upd_p_id').value = urlParams.get('PRODUCT_ID') || 106;

        // 사진 삭제 UI & 미리보기 셋팅
        const existImgBox = document.getElementById('existing_img_box');
        const delCheck = document.getElementById('delete_img_check');
        const isDelHidden = document.getElementById('isImgDeleted');
        const previewImg = document.getElementById('preview_old_img'); // 🌟 추가: 미리보기 태그

        if (existImgBox && delCheck && isDelHidden) {
            delCheck.checked = false;
            isDelHidden.value = "false";

            // 기존 사진이 있으면 박스 보여주고, 미리보기 태그에 사진 경로 꽂아주기!
            if (imgSrc && imgSrc !== 'null' && imgSrc !== '') {
                existImgBox.style.display = 'block';
                if(previewImg) previewImg.src = '../upload/' + imgSrc;
            } else {
                existImgBox.style.display = 'none';
            }
        }

        setUpdateStars(score);
        document.getElementById('updateModal').style.display = 'block';
    } catch (e) {
        console.error(e);
        alert("모달창을 여는 중 일시적인 오류가 발생했습니다. 새로고침(F5) 후 다시 시도해주세요!");
    }
}

function setUpdateStars(score) {
    document.querySelectorAll('.upd-star').forEach(s => {
        s.style.color = (s.getAttribute('data-value') <= score) ? '#ffc107' : '#ddd';
    });
}

document.querySelectorAll('.upd-star').forEach(star => {
    star.addEventListener('click', function() {
        const s = this.getAttribute('data-value');
        document.getElementById('upd_score').value = s;
        setUpdateStars(s);
    });
});

function toggleImgDelete() {
    const isChecked = document.getElementById('delete_img_check').checked;
    document.getElementById('isImgDeleted').value = isChecked ? "true" : "false";
}

function closeUpdateModal() { document.getElementById('updateModal').style.display = 'none'; }

function submitUpdate() {
    const formData = new FormData(document.getElementById('updateForm'));
    fetch('ReviewUpdateC', { method: 'POST', body: formData })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                alert("수정완료! ✨");
                closeUpdateModal();
                location.reload(); // 🌟 수정 후 페이지 전체 새로고침! (그래프/사진 동기화)
            } else {
                alert("수정 실패!");
            }
        });
}

function toggleMenu(id) {
    const m = document.getElementById(`menu-content-${id}`);
    document.querySelectorAll('.menu-content').forEach(el => {
        if(el.id !== `menu-content-${id}`) el.style.display = 'none';
    });
    m.style.display = (m.style.display === 'none') ? 'block' : 'none';
}
// ==========================================
// 📝 7. 글자 수 카운팅 로직
// ==========================================
function updateCharCount() {
    const content = document.getElementById('upd_content').value;
    const charCount = document.getElementById('charCount');
    if (charCount) {
        charCount.innerText = content.length;
    }
}
// ==========================================
//8.숫자 점수를 별 모양 HTML로 바꿔주는 함수
// ==========================================

function makeStarHtml(score) {
    let stars = '';
    for (let i = 1; i <= 5; i++) {
        // 현재 번호가 점수보다 작거나 같으면 꽉 찬 별, 아니면 빈 별
        if (i <= score) {
            stars += '<span class="star-gold">★</span>';
        } else {
            stars += '<span class="star-gray">☆</span>';
        }
    }
    return stars;
}// ==========================================
// ✍️ 8. 리뷰 작성 모달 제어
// ==========================================
function openWriteModal() {
    document.getElementById('writeForm').reset(); // 폼 초기화
    setWriteStars(5); // 기본 별점 5점 세팅
    document.getElementById('writeModal').style.display = 'block';
}

function closeWriteModal() {
    document.getElementById('writeModal').style.display = 'none';
}

// 별점 선택 로직
document.querySelectorAll('.write-star').forEach(star => {
    star.addEventListener('click', function() {
        const val = this.getAttribute('data-value');
        document.getElementById('write_score').value = val;
        setWriteStars(val);
    });
});

function setWriteStars(score) {
    document.querySelectorAll('.write-star').forEach(s => {
        s.style.color = (s.getAttribute('data-value') <= score) ? '#ffc107' : '#ddd';
    });
}

// 🚀 [핵심] 비동기 리뷰 등록
function submitReview() {
    const form = document.getElementById('writeForm');
    const formData = new FormData(form);

    // ReviewInsertC 서블릿으로 비동기 요청 전송
    fetch('review-write', {
        method: 'POST',
        body: formData
    })
        .then(res => res.text())
        .then(data => {
            // 서블릿에서 성공 시 "1"을 응답하도록 수정할 예정입니다.
            if (data.trim() === "1") {
                alert("리뷰가 등록되었습니다! ✨");
                closeWriteModal();

                // 🌟 fetchReviews() 대신 location.reload()를 씁니다!
                // 페이지를 한 번 새로고침해서 위쪽 통계 그래프와 사진첩 숫자까지 완벽하게 최신화시킵니다.
                location.reload()

                // 등록 후 페이지 상단 통계 그래프도 갱신하고 싶다면 새로고침이 가장 확실하긴 합니다.
                // location.reload();
            } else {
                alert("리뷰 등록 실패 ㅠㅠ 다시 시도해주세요.");
            }
        })
        .catch(err => console.error("등록 에러:", err));
}