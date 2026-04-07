// ==========================================
// 🌟 0. 전역 변수 & 초기화
// ==========================================
const currentLoginId = 'kim124';

document.addEventListener('DOMContentLoaded', function() {
    const sortSelect = document.getElementById('sortType');
    const starSelect = document.getElementById('starFilter');
    if(sortSelect) sortSelect.addEventListener('change', fetchReviews);
    if(starSelect) starSelect.addEventListener('change', fetchReviews);
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
                    <div style="color:#777; font-size:0.9em;">작성자: ${r.user_id} | 별점: ${r.r_score}점</div>
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

// ==========================================
// 🎛️ 3. 비동기 정렬 리스트
// ==========================================
function fetchReviews() {
    const urlParams = new URLSearchParams(window.location.search);
    let pId = urlParams.get('PRODUCT_ID') || 106;
    const sortType = document.getElementById('sortType').value;
    const starFilter = document.getElementById('starFilter').value;

    fetch(`review?PRODUCT_ID=${pId}&sortType=${sortType}&starFilter=${starFilter}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => renderReviews(data));
}

function renderReviews(reviews) {
    const container = document.getElementById('review-list-container');
    container.innerHTML = '';
    if (reviews.length === 0) {
        container.innerHTML = `<div class="empty-msg" style="text-align:center; padding:50px;"><p>해당 조건에 맞는 리뷰가 없습니다.</p></div>`;
        return;
    }

    reviews.forEach(r => {
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
                <div class="review-meta">작성자: ${r.user_id} | 별점: ${r.r_score}점 | 작성일: ${r.r_date}</div>
                ${imgHtml}
                <hr style="border:0; border-top:1px solid #eee;">
                <div class="review-content">${r.r_content}</div>
                <div class="review-action-box">
                    <button type="button" class="btn-like" onclick="toggleLike(${r.review_id}, '${currentLoginId}')">👍 <span id="like-count-${r.review_id}">${r.r_like}</span></button>
                    <button type="button" class="btn-detail" onclick="openDetailModal('${r.r_title}', '${r.user_id}', '${r.r_score}', '${r.r_date}', '${r.r_content}', '${r.r_img}')">🔍 리뷰 상세보기</button>
                </div>
            </div>`;
    });
}

// ==========================================
// 🔍 4. 리뷰 상세보기
// ==========================================
function openDetailModal(title, user, score, date, content, img) {
    document.getElementById('detailModal').style.display = 'block';
    document.getElementById('detail_title').innerText = title;
    document.getElementById('detail_user').innerText = user;
    document.getElementById('detail_score').innerText = score;
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