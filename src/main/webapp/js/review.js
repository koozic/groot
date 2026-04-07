// ==========================================
// 📸 1. 포토 갤러리 슬라이드 모터
// ==========================================
function slideGallery(direction) {
    const slider = document.getElementById('photo-slider');
    const scrollAmount = direction * 165; // 사진 너비(150) + 여백(15)

    slider.scrollBy({
        left: scrollAmount,
        behavior: 'smooth'
    });
}

// 🚀 포토 리뷰만 모아보기 모달 열기
function openPhotoGalleryModal() {
    document.getElementById('photoOnlyModal').style.display = 'block';

    const urlParams = new URLSearchParams(window.location.search);
    let pId = urlParams.get('PRODUCT_ID') || 105; // 105번으로 기본값 체크!

    fetch(`/review?PRODUCT_ID=${pId}&sortType=photo`, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
        .then(response => response.json())
        .then(data => {
            const container = document.getElementById('photo-only-list-container');
            container.innerHTML = '';

            const photoReviews = data.filter(r => r.r_img && r.r_img !== 'null');

            if (photoReviews.length === 0) {
                container.innerHTML = '<p style="text-align:center; padding:30px;">등록된 포토 리뷰가 없습니다.</p>';
                return;
            }

            photoReviews.forEach(r => {
                const itemHtml = `
                <div class="photo-item" style="display:flex; gap:20px; padding:15px; border-bottom:1px solid #eee; align-items:center;">
                    <img src="../upload/${r.r_img}" style="width:120px; height:120px; object-fit:cover; border-radius:8px;">
                    <div style="flex-grow:1;">
                        <div style="font-weight:bold; font-size:1.1em; margin-bottom:5px;">${r.r_title}</div>
                        <div style="color:#777; font-size:0.9em; margin-bottom:10px;">
                            작성자: ${r.user_id} | 별점: ${r.r_score}점
                        </div>
                        <div style="font-size:0.95em; color:#333;">${r.r_content}</div>
                    </div>
                </div>
            `;
                container.innerHTML += itemHtml;
            });
        });
}

function closePhotoOnlyModal() {
    document.getElementById('photoOnlyModal').style.display = 'none';
}

// ==========================================
// 🚀 2. 좋아요 비동기(Ajax) 처리
// ==========================================
function toggleLike(reviewId, userId) {
    if (!userId || userId === 'null' || userId === '') {
        alert('로그인이 필요한 서비스입니다.');
        return;
    }

    const formData = new URLSearchParams();
    formData.append('review_id', reviewId);
    formData.append('user_id', userId);

    fetch('/review-like', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData
    })
        .then(response => response.text())
        .then(data => {
            // 서버에서 받은 최종 좋아요 개수 업데이트
            const countSpan = document.getElementById(`like-count-${reviewId}`);
            countSpan.innerText = data;

            // 버튼 클릭 시 시각적 피드백 (CSS 클래스 토글)
            const likeBtn = document.getElementById(`like-btn-${reviewId}`);
            likeBtn.classList.add('clicked');
            setTimeout(() => { likeBtn.classList.remove('clicked'); }, 300);
        })
        .catch(error => console.error("❌ 좋아요 통신 에러!", error));
}

// ==========================================
// 🚀 3. 비동기(Ajax) 정렬 & 필터링
// ==========================================
const sortSelect = document.getElementById('sortType');
const starSelect = document.getElementById('starFilter');

if(sortSelect && starSelect) {
    sortSelect.addEventListener('change', fetchReviews);
    starSelect.addEventListener('change', fetchReviews);
}

function fetchReviews() {
    const urlParams = new URLSearchParams(window.location.search);
    let pId = urlParams.get('PRODUCT_ID') || 105;

    const sortType = sortSelect.value;
    const starFilter = starSelect.value;

    fetch(`/review?PRODUCT_ID=${pId}&sortType=${sortType}&starFilter=${starFilter}`, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
        .then(response => response.json())
        .then(data => {
            renderReviews(data);
        })
        .catch(error => console.error("비동기 통신 에러!", error));
}

// 🌟 [핵심] 정렬 후 화면을 다시 그릴 때 버튼들도 같이 그려주는 함수!
function renderReviews(reviews) {
    const container = document.getElementById('review-list-container');
    container.innerHTML = '';

    if (reviews.length === 0) {
        container.innerHTML = `
            <div class="empty-msg" style="text-align:center; padding:50px;">
                <p>해당 조건에 맞는 리뷰가 없습니다. ㅠㅠ</p>
            </div>`;
        return;
    }

    reviews.forEach(r => {
        let imgHtml = '';
        if (r.r_img && r.r_img !== 'null') {
            imgHtml = `
                <div class="review-img-box" style="margin: 15px 0;">
                    <img src="../upload/${r.r_img}" alt="리뷰이미지" style="width: 150px; height: 150px; object-fit: cover; border-radius: 8px; border: 1px solid #eee; display: block;">
                </div>`;
        }

        const cardHtml = `
            <div class="review-card">
                <div class="review-title">제목: ${r.r_title}</div>
                <div class="review-meta">
                    작성자: ${r.user_id} | 별점: ${r.r_score}점 | 작성일: ${r.r_date}
                </div>
                
                ${imgHtml}
                
                <hr style="border: 0; border-top: 1px solid #eee;">
                <div class="review-content">
                    ${r.r_content}
                </div>
                
                <div class="review-action-box">
                    <button type="button" 
                            id="like-btn-${r.review_id}" 
                            class="btn-like" 
                            onclick="toggleLike(${r.review_id}, 'kim124')">
                        👍 도움돼요 <span id="like-count-${r.review_id}" class="like-count">${r.r_like}</span>
                    </button>
                    
                    <button type="button" 
                            class="btn-detail"
                            onclick="openDetailModal('${r.r_title}', '${r.user_id}', '${r.r_score}', '${r.r_date}', '${r.r_content}', '${r.r_img}')">
                        🔍 리뷰 상세보기
                    </button>
                </div>
            </div>
        `;
        container.innerHTML += cardHtml;
    });
}