// ==========================================
// 🌟 0. 전역 변수 & 초기화
// ==========================================
const currentLoginId = 'kim124';

// 페이지 로드 시 정렬 이벤트 연결
document.addEventListener('DOMContentLoaded', function() {
    const sortSelect = document.getElementById('sortType');
    const starSelect = document.getElementById('starFilter');
    if(sortSelect) sortSelect.addEventListener('change', fetchReviews);
    if(starSelect) starSelect.addEventListener('change', fetchReviews);
});

// ==========================================
// 📸 1. 포토 갤러리 슬라이드 & 모달
// ==========================================
function slideGallery(direction) {
    const slider = document.getElementById('photo-slider');
    const scrollAmount = direction * 165;
    slider.scrollBy({ left: scrollAmount, behavior: 'smooth' });
}

function openPhotoGalleryModal() {
    document.getElementById('photoOnlyModal').style.display = 'block';
    const urlParams = new URLSearchParams(window.location.search);
    let pId = urlParams.get('PRODUCT_ID') || 106;

    fetch(`review?PRODUCT_ID=${pId}&sortType=photo`, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
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
                        <div style="color:#777; font-size:0.9em;">작성자: ${r.user_id} | 별점: ${r.r_score}점</div>
                        <div style="font-size:0.95em;">${r.r_content}</div>
                    </div>
                </div>`;
            });
        });
}

function closePhotoOnlyModal() {
    document.getElementById('photoOnlyModal').style.display = 'none';
}

// ==========================================
// 🚀 2. 좋아요 비동기 처리
// ==========================================
function toggleLike(reviewId, userId) {
    if (!userId || userId === 'null' || userId === '') {
        alert('로그인이 필요한 서비스입니다.');
        return;
    }
    const params = new URLSearchParams();
    params.append('review_id', reviewId);
    params.append('user_id', userId);

    fetch('review-like', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
        body: params
    })
        .then(res => res.text())
        .then(data => {
            document.getElementById(`like-count-${reviewId}`).innerText = data;
            const likeBtn = document.getElementById(`like-btn-${reviewId}`);
            likeBtn.classList.add('clicked');
            setTimeout(() => { likeBtn.classList.remove('clicked'); }, 300);
        });
}

// ==========================================
// 🎛️ 3. 비동기 정렬 & 리스트 렌더링 (상세보기 버튼 포함!)
// ==========================================
function fetchReviews() {
    const urlParams = new URLSearchParams(window.location.search);
    let pId = urlParams.get('PRODUCT_ID') || 106;
    const sortType = document.getElementById('sortType').value;
    const starFilter = document.getElementById('starFilter').value;

    fetch(`review?PRODUCT_ID=${pId}&sortType=${sortType}&starFilter=${starFilter}`, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
        .then(res => res.json())
        .then(data => renderReviews(data))
        .catch(err => console.error("❌ 정렬 에러:", err));
}

function renderReviews(reviews) {
    const container = document.getElementById('review-list-container');
    container.innerHTML = '';
    if (reviews.length === 0) {
        container.innerHTML = `<div class="empty-msg" style="text-align:center; padding:50px;"><p>리뷰가 없습니다.</p></div>`;
        return;
    }
    reviews.forEach(r => {
        let imgHtml = (r.r_img && r.r_img !== 'null') ? `<div class="review-img-box" style="margin: 15px 0;"><img src="../upload/${r.r_img}" style="width: 150px; border-radius: 8px;"></div>` : '';
        let menuHtml = (r.user_id === currentLoginId) ? `
            <div class="review-more-menu">
                <button type="button" class="btn-more" onclick="toggleMenu(${r.review_id})">⋮</button>
                <div id="menu-content-${r.review_id}" class="menu-content" style="display:none;">
                    <a href="javascript:void(0)" onclick="openUpdateForm(${r.review_id})">수정하기</a>
                    <a href="javascript:void(0)" onclick="deleteReview(${r.review_id})" style="color:red;">삭제하기</a>
                </div>
            </div>` : '';

        container.innerHTML += `
            <div class="review-card" id="card-${r.review_id}">
                ${menuHtml}
                <div class="review-title">제목: ${r.r_title}</div>
                <div class="review-meta">작성자: ${r.user_id} | 별점: ${r.r_score}점 | 작성일: ${r.r_date}</div>
                ${imgHtml}
                <hr style="border:0; border-top:1px solid #eee;">
                <div class="review-content">${r.r_content}</div>
                <div class="review-action-box">
                    <button type="button" id="like-btn-${r.review_id}" class="btn-like" onclick="toggleLike(${r.review_id}, '${currentLoginId}')">
                        👍 도움돼요 <span id="like-count-${r.review_id}">${r.r_like}</span>
                    </button>
                    <button type="button" class="btn-detail" onclick="openDetailModal('${r.r_title}', '${r.user_id}', '${r.r_score}', '${r.r_date}', '${r.r_content}', '${r.r_img}')">
                        🔍 리뷰 상세보기
                    </button>
                </div>
            </div>`;
    });
}

// ==========================================
// 🔍 4. 리뷰 상세보기 모달 (이거 없어져서 속상하셨죠?)
// ==========================================
function openDetailModal(title, userId, score, date, content, img) {
    document.getElementById('detail-title').innerText = title;
    document.getElementById('detail-user').innerText = userId;
    document.getElementById('detail-score').innerText = score + '점';
    document.getElementById('detail-date').innerText = date;
    document.getElementById('detail-content').innerText = content;

    const imgEl = document.getElementById('detail-img');
    if (img && img !== 'null' && img !== 'undefined') {
        imgEl.src = '../upload/' + img;
        imgEl.style.display = 'block';
    } else {
        imgEl.style.display = 'none';
    }
    document.getElementById('reviewDetailModal').style.display = 'block';
}

function closeDetailModal() {
    document.getElementById('reviewDetailModal').style.display = 'none';
}

// ==========================================
// ⚙️ 5. 기타 동작 (메뉴 토글, 닫기 등)
// ==========================================
function toggleMenu(id) {
    const menu = document.getElementById(`menu-content-${id}`);
    document.querySelectorAll('.menu-content').forEach(m => { if(m.id !== `menu-content-${id}`) m.style.display = 'none'; });
    menu.style.display = (menu.style.display === 'none') ? 'block' : 'none';
}

window.onclick = function(e) {
    if (!e.target.matches('.btn-more')) { document.querySelectorAll('.menu-content').forEach(m => m.style.display = 'none'); }
}

// ==========================================
// 🗑️ 6. 리뷰 삭제 (Ajax)
// ==========================================
function deleteReview(reviewId) {
    if (!confirm("정말 이 리뷰를 삭제하시겠습니까?")) return;
    fetch(`ReviewDeleteC?review_id=${reviewId}`)
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") { alert("삭제되었습니다! ✨"); fetchReviews(); }
            else { alert("삭제 실패!"); }
        });
}

// ==========================================
// 🪄 7. 리뷰 수정 (모달 데이터 세팅 & 별점)
// ==========================================
function openUpdateForm(reviewId) {
    const card = document.getElementById(`card-${reviewId}`);
    let title = card.querySelector('.review-title').innerText.replace('제목: ', '').trim();
    let content = card.querySelector('.review-content').innerHTML.replace(/<br>/g, '\n').trim();
    let score = card.querySelector('.review-meta').innerText.match(/별점: (\d+)점/)[1];
    let imgTag = card.querySelector('.review-img-box img');
    let imgSrc = imgTag ? imgTag.src.split('/').pop() : "";

    document.getElementById('upd_review_id').value = reviewId;
    document.getElementById('upd_title').value = title;
    document.getElementById('upd_score').value = score;
    document.getElementById('upd_content').value = content;
    document.getElementById('old_img_name').value = imgSrc;

    const urlParams = new URLSearchParams(window.location.search);
    document.getElementById('upd_p_id').value = urlParams.get('PRODUCT_ID') || 106;

    setUpdateStars(score);
    document.getElementById('updateModal').style.display = 'block';
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

// ==========================================
// 🚀 8. 수정 제출 & 모달 닫기
// ==========================================
function closeUpdateModal() { document.getElementById('updateModal').style.display = 'none'; }

function submitUpdate() {
    const formData = new FormData(document.getElementById('updateForm'));
    fetch('ReviewUpdateC', { method: 'POST', body: formData })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") { alert("수정 완료! ✨"); closeUpdateModal(); fetchReviews(); }
            else { alert("수정 실패!"); }
        }).catch(err => alert("통신 오류!"));
}