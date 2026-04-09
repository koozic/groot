// ==========================================
// 🌟 0. 전역 변수 & 초기화
// ==========================================


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
// 📸 1. 포토 갤러리 슬라이드 & 모달 (정렬/필터 기능 완벽 이식!)
// ==========================================
function slideGallery(direction) {
    const slider = document.getElementById('photo-slider');
    slider.scrollBy({ left: direction * 165, behavior: 'smooth' });
}

function openPhotoGalleryModal() {
    document.getElementById('photoOnlyModal').style.display = 'block';
    fetchModalPhotoReviews(); // 모달 열자마자 비동기로 데이터 한번 땡겨오기!
}

function closePhotoOnlyModal() {
    document.getElementById('photoOnlyModal').style.display = 'none';
}

// 🌟 모달 전용 비동기 호출 함수
function fetchModalPhotoReviews() {
    const urlParams = new URLSearchParams(window.location.search);
    let pId = currentProductId;

    // 모달 안에 있는 select, checkbox 값 가져오기
    const sortType = document.getElementById('modalSortType').value;
    const starFilter = document.getElementById('modalStarFilter').value;
    const isMyReview = document.getElementById('modalMyReviewCheck').checked;

    fetch(`review?PRODUCT_ID=${pId}&sortType=${sortType}&starFilter=${starFilter}`, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        .then(res => res.json())
        .then(data => {
            const container = document.getElementById('photo-only-list-container');
            container.innerHTML = '';

            // 1. 사진이 있는 리뷰만 1차 필터링
            let photoReviews = data.filter(r => r.r_img && r.r_img !== 'null' && r.r_img !== '');

            // 2. 내가 쓴 글 체크박스 2차 필터링
            if (isMyReview) {
                photoReviews = photoReviews.filter(r => r.user_id && r.user_id.trim() === currentLoginId);
            }

            if (photoReviews.length === 0) {
                container.innerHTML = '<p style="text-align:center; padding:50px; font-weight:bold; color:#777;">조건에 맞는 포토 리뷰가 없습니다.</p>';
                return;
            }

            // 3. 화면에 그리기
            photoReviews.forEach(r => {
                container.innerHTML += `
                <div class="photo-item" style="display:flex; gap:20px; padding:20px 10px; border-bottom:1px solid #eee; align-items:center;">
                    <img src="../upload/${r.r_img}" style="width:130px; height:130px; object-fit:cover; border-radius:10px; border:1px solid #ddd;">
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
// 🚀 2. 좋아요 비동기 처리 (메인/모달 동시 적용)
// ==========================================
function toggleLike(reviewId, userId) {
    if (!userId || userId === 'null') { alert('로그인이 필요합니다.'); return; }

    const params = new URLSearchParams();
    params.append('review_id', reviewId);
    params.append('user_id', userId);

    fetch('review-like', { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' }, body: params })
        .then(res => res.text())
        .then(data => {
            // 메인 화면 좋아요 숫자 업데이트
            const mainLike = document.getElementById(`like-count-${reviewId}`);
            if (mainLike) mainLike.innerText = data;

            // 모달 화면 좋아요 숫자 업데이트
            const modalLike = document.getElementById(`like-count-modal-${reviewId}`);
            if (modalLike) modalLike.innerText = data;
        });
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
    let pId = currentProductId;
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

// 🌟 핵심: 페이징 처리해서 화면에 그리는 함수
function renderPaginatedReviews(isAppend = false) {
    const container = document.getElementById('review-list-container');
    const emptyUi = document.getElementById('empty-review-ui');
    const fullUi = document.getElementById('full-review-ui');

    if (!isAppend) {
        container.innerHTML = '';
    }

    // 🌟 [추가된 로직] 데이터가 0개면 텅 빈 화면 ON, 풀세트 OFF!
    if (filteredReviewsData.length === 0) {
        if(emptyUi) emptyUi.style.display = 'block';
        if(fullUi) fullUi.style.display = 'none';

        // (기존의 못생긴 텍스트 문구는 지워줍니다)
        // container.innerHTML = `<div class="empty-msg">...</div>`;

        renderPaginationButtons();
        return;
    }

    // 🌟 [추가된 로직] 데이터가 1개라도 있으면 텅 빈 화면 OFF, 풀세트 ON!
    if(emptyUi) emptyUi.style.display = 'none';
    if(fullUi) fullUi.style.display = 'block';

    // ... (이 아래로는 무영님이 만든 5개씩 자르기 로직 그대로 유지!) ...

    // ✂️ 5개씩 데이터 자르기!
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const pageData = filteredReviewsData.slice(startIndex, endIndex);

    // 잘라낸 5개 데이터 화면에 붙이기 (이전 renderReviews 안의 로직과 동일)
    pageData.forEach(r => {
        let imgHtml = (r.r_img && r.r_img !== 'null') ? `<div class="review-img-box" style="margin: 15px 0;"><img src="../upload/${r.r_img}" style="width: 150px; border-radius: 8px;"></div>` : '';
        const rUser = r.user_id ? r.user_id.trim() : "";
        let menuHtml = '';

        // 🌟 'kim124' 하드코딩 완벽 삭제!
        // 조건: 1. 로그인을 한 상태여야 함 (currentLoginId !== "")
        // 조건: 2. 현재 로그인한 아이디와 글 작성자의 아이디가 완벽히 똑같아야 함!
        if (currentLoginId !== "" && rUser === currentLoginId) {
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
             <div class="review-meta">작성자: ${r.user_id} | ${makeStarHtml(r.r_score)} | 작성일: ${formatKoreanDate(r.r_date)}</div>
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
        pageArea = document.createElement('div');
        pageArea.id = 'pagination-area';
        pageArea.style.textAlign = 'center';
        pageArea.style.margin = '30px 0 50px 0';
        document.getElementById('review-list-container').after(pageArea);
    }

    pageArea.innerHTML = '';
    const totalPages = Math.ceil(filteredReviewsData.length / itemsPerPage);

    if (totalPages <= 1) return; // 1페이지만 있으면 숨김

    if (isMobile) {
        // 📱 모바일 화면일 때: [올리브영 스타일 더보기]
        if (currentPage < totalPages) {
            pageArea.innerHTML = `
                <button type="button" onclick="loadMoreReviews()" style="width:100%; padding:15px; background:#fff; border:1px solid #ddd; border-radius:8px; font-weight:bold; font-size:1.1em; color:#333; cursor:pointer; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                    리뷰 더보기 (${currentPage * itemsPerPage} / ${filteredReviewsData.length}) ⬇️
                </button>`;
        }
    } else {
        // 💻 PC 화면일 때: [아이허브 스타일 고급 번호판]
        let html = '';

        // 1. 이전(<) 버튼 (1페이지가 아닐 때만 보임)
        if (currentPage > 1) {
            html += `<a href="javascript:void(0)" onclick="goToPage(${currentPage - 1})" style="display:inline-block; margin:0 8px; font-weight:bold; font-size:1.2em; color:#555; text-decoration:none;">&lt;</a>`;
        }

        // 🌟 복잡한 페이징 번호 계산 (최대 5개 번호만 보여주기)
        let start = Math.max(1, currentPage - 2);
        let end = Math.min(totalPages, currentPage + 2);

        if (currentPage <= 3) {
            start = 1;
            end = Math.min(5, totalPages);
        } else if (currentPage + 2 >= totalPages) {
            start = Math.max(1, totalPages - 4);
            end = totalPages;
        }

        // 2. 번호 찍기
        for (let i = start; i <= end; i++) {
            if (i === currentPage) {
                // 현재 페이지 (아이허브처럼 초록색 박스 칠하기)
                html += `<span style="display:inline-block; margin:0 5px; padding: 6px 14px; background-color:#6a8d3a; color:white; font-weight:bold; border-radius:4px; font-size:1.1em; cursor:default;">${i}</span>`;
            } else {
                // 다른 페이지
                html += `<a href="javascript:void(0)" onclick="goToPage(${i})" style="display:inline-block; margin:0 5px; padding: 6px 14px; color:#555; text-decoration:none; font-size:1.1em; border-radius:4px;">${i}</a>`;
            }
        }

        // 3. 말줄임표(...) 와 마지막 페이지
        if (end < totalPages) {
            if (end < totalPages - 1) {
                html += `<span style="display:inline-block; margin:0 5px; color:#777; font-size:1.1em;">...</span>`;
            }
            html += `<a href="javascript:void(0)" onclick="goToPage(${totalPages})" style="display:inline-block; margin:0 5px; padding: 6px 14px; color:#555; text-decoration:none; font-size:1.1em; border-radius:4px;">${totalPages}</a>`;
        }

        // 4. 다음(>) 버튼 (마지막 페이지가 아닐 때만 보임)
        if (currentPage < totalPages) {
            html += `<a href="javascript:void(0)" onclick="goToPage(${currentPage + 1})" style="display:inline-block; margin:0 8px; font-weight:bold; font-size:1.2em; color:#555; text-decoration:none;">&gt;</a>`;
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
    renderPaginatedReviews(false);

    // 🌟 상단 파란색 고정 메뉴바에 가려지지 않게 여백을 넉넉하게(-150) 뺍니다!
    const controlBar = document.querySelector('.review-control-bar');
    if (controlBar) {
        const targetY = controlBar.getBoundingClientRect().top + window.scrollY - 110;
        window.scrollTo({ top: targetY, behavior: 'smooth' });
    } else {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
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
// ==========================================
// 🗑️ 리뷰 삭제 (깜빡임 없는 스무스 삭제)
// ==========================================
function deleteReview(reviewId) {
    if (!confirm("정말 삭제하시겠습니까?")) return;

    fetch(`review-delete?review_id=${reviewId}`)
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                showToast("리뷰를 삭제했습니다. 🗑️");

                // 🌟 [핵심] 새로고침(reload)을 지우고 스르륵 효과 추가!
                const card = document.getElementById(`menu-content-${reviewId}`).closest('.review-card');
                if(card) {
                    card.style.transition = 'all 0.5s ease';
                    card.style.opacity = '0';
                    card.style.transform = 'translateX(100px)'; // 오른쪽으로 밀려나며 삭제

                    setTimeout(() => {
                        card.remove(); // 화면에서 완전히 지우기
                        fetchReviews(); // 🆕 서버에서 새 리스트만 조용히 땡겨오기
                    }, 500);
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

        // 🌟 주소창 찾을 필요 없이 우리가 전역으로 세팅해둔 currentProductId를 씁니다!
        if(document.getElementById('upd_p_id')) document.getElementById('upd_p_id').value = currentProductId;
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

// ==========================================
// 🪄 6. 리뷰 수정 (깜빡임 없는 비동기 수정)
// ==========================================
function submitUpdate() {
    const formData = new FormData(document.getElementById('updateForm'));
    fetch('ReviewUpdateC', { method: 'POST', body: formData })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                showToast("리뷰 수정을 완료했습니다! 🪄");
                closeUpdateModal(); // 모달창 부드럽게 닫기

                // 🌟 [핵심] 새로고침(reload) 완전 삭제!
                // 대신 서버에서 바뀐 데이터로 리스트만 조용히 다시 땡겨옵니다.
                fetchReviews();
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
    // 🌟 문지기 출동: 로그인이 안 되어 있다면?
    if (!currentLoginId || currentLoginId === "") {
        showToast("로그인이 필요한 기능입니다! 🔒", "error");
        return; // 여기서 함수를 끝내버려서 모달창이 안 뜨게 막음!
    }
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

// ==========================================
// 🚀 리뷰 등록 (깜빡임 없는 비동기 등록)
// ==========================================
function submitReview() {
    const form = document.getElementById('writeForm');
    const formData = new FormData(form);

    fetch('review-write', {
        method: 'POST',
        body: formData
    })
        .then(res => res.text())
        .then(data => {
            if (data.trim() === "1") {
                showToast("리뷰가 등록되었습니다! ✨");
                closeWriteModal();

                // 🌟 [핵심] location.reload() 지우고, 함수 하나만 부릅니다!
                fetchReviews();

            } else {
                alert("리뷰 등록 실패 ㅠㅠ 다시 시도해주세요.");
            }
        })
        .catch(err => console.error("등록 에러:", err));
}
// =========================================================
// 🍞 토스트 알림 띄우기 함수 (경용씨 '가운데 빵!' UI 완벽 동기화)
// =========================================================
function showToast(message, type = "success") {
    // 경용씨의 product_detail.jsp에 있는 toast 태그를 가져옵니다!
    const toast = document.getElementById("toast");

    if (toast) {
        toast.innerText = message;
        toast.className = "toast";
        toast.classList.add("show", type);

        // 3초 뒤에 사라짐
        setTimeout(() => {
            toast.classList.remove("show", type);
        }, 3000);
    } else {
        alert(message);
    }
}
// ==========================================
// 📅 9. 날짜 예쁘게 바꾸는 함수 (Gson 포맷 교정)
// ==========================================
function formatKoreanDate(dateStr) {
    if (!dateStr) return "";

    // "4월 8, 2026" 같은 요상한 패턴을 찾아서 "2026년 4월 8일"로 변환
    const regex = /(\d+)\s*월\s+(\d+),\s+(\d+)/;
    const match = dateStr.match(regex);

    if (match) {
        // match[3] = 연도, match[1] = 월, match[2] = 일
        return `${match[3]}년 ${match[1]}월 ${match[2]}일`;
    }

    // 만약 다른 형식이면 그냥 원래대로 출력 (에러 방지)
    return dateStr;
}