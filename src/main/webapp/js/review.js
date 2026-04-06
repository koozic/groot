// 🌟 포토 갤러리 슬라이드 모터!
function slideGallery(direction) {
    const slider = document.getElementById('photo-slider');

    // 사진 한 칸 너비(150px) + 여백(15px) = 165px씩 스르륵 이동!
    const scrollAmount = direction * 165;

    slider.scrollBy({
        left: scrollAmount,
        behavior: 'smooth' // 부드럽게 스르륵~ ㅋㅋㅋ
    });
}

// 🚀 포토 리뷰만 모아보기 기능
function openPhotoGalleryModal() {
    // 1. 모달 먼저 열기
    document.getElementById('photoOnlyModal').style.display = 'block';

    // 2. 상품 번호 가져오기
    const urlParams = new URLSearchParams(window.location.search);
    let pId = urlParams.get('PRODUCT_ID') || 101;

    // 3. 서버에 "사진 있는 리뷰만 줘!" 하고 요청 (이미 만들어둔 컨트롤러 활용)
    // 🌟 팁: 별점 필터나 정렬 없이 '사진 전용' 요청임을 알리기 위해 sortType을 'photo'라고 보내보자!
    fetch(`/review?PRODUCT_ID=${pId}&sortType=photo`, {
        method: 'GET',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
        .then(response => response.json())
        .then(data => {
            const container = document.getElementById('photo-only-list-container');
            container.innerHTML = ''; // 초기화

            // 🌟 사진이 있는 놈들만 필터링 (서버에서 걸러와도 되지만 여기서 한 번 더!)
            const photoReviews = data.filter(r => r.r_img && r.r_img !== 'null');

            if (photoReviews.length === 0) {
                container.innerHTML = '<p style="text-align:center; padding:30px;">등록된 포토 리뷰가 없습니다.</p>';
                return;
            }

            // 4. 리스트 그리기
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