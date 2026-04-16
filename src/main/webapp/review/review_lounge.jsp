<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- 🌟 CSS 파일 연결 --%>
<link rel="stylesheet" href="../css/review_lounge.css">

<div class="lounge-wrap">
    <div class="lounge-header">
        <h1>🏆 약쟁이 명예의 전당</h1>
        <p>유저들이 인정한 가장 도움되는 찐 후기들을 모아봤어요!</p>
    </div>

    <div class="category-pills">
        <button class="pill-btn active" data-category="all">✨ 전체보기</button>

        <%-- 🌟 1. 비타민 드롭다운 (수용성/지용성) --%>
        <div class="dropdown-container">
            <button class="pill-btn dropdown-toggle" id="vitamin-main-btn">💊 비타민 ▼</button>
            <div class="dropdown-menu">
                <div class="vitamin-grid">
                    <%-- 🌟 수용성 비타민 --%>
                    <div class="vitamin-column" style="flex: 1.5;">
                        <h4>수용성 비타민 Water-soluble</h4>
                        <div class="water-soluble-grid">
                            <button class="sub-pill-btn" data-category="비타민 B1">B1(티아민)</button>
                            <button class="sub-pill-btn" data-category="비타민 B2">B2(리보플라빈)</button>
                            <button class="sub-pill-btn" data-category="비타민 B3">B3(니아신/나이아신)</button>
                            <button class="sub-pill-btn" data-category="비타민 B5">B5(판토텐산)</button>
                            <button class="sub-pill-btn" data-category="비타민 B6">B6(피리독신)</button>
                            <button class="sub-pill-btn" data-category="비타민 B7">B7(비오틴)</button>
                            <button class="sub-pill-btn" data-category="비타민 B9">B9(엽산)</button>
                            <button class="sub-pill-btn" data-category="비타민 C">C</button>
                        </div>
                    </div>

                    <%-- 🌟 지용성 비타민 --%>
                    <div class="vitamin-column" style="flex: 1;">
                        <h4>지용성 비타민 Fat-soluble</h4>
                        <div class="fat-soluble-grid">
                            <button class="sub-pill-btn" data-category="비타민 A">A</button>
                            <button class="sub-pill-btn" data-category="비타민 D">D</button>
                            <button class="sub-pill-btn" data-category="비타민 E">E</button>
                            <button class="sub-pill-btn" data-category="비타민 K">K</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- 🌟 2. 나머지 영양제들 총출동 --%>
        <button class="pill-btn" data-category="아연">🦪 아연</button>
        <button class="pill-btn" data-category="마그네슘">🌿 마그네슘</button>
        <button class="pill-btn" data-category="철분">🩸 철분</button>
        <button class="pill-btn" data-category="칼슘">🦴 칼슘</button>
        <button class="pill-btn" data-category="코엔자임Q10">⚡ 코엔자임Q10</button>
        <button class="pill-btn" data-category="오메가3">🐟 오메가3</button>
        <button class="pill-btn" data-category="콜린">🧠 콜린</button>
        <button class="pill-btn" data-category="루테인 지아잔틴">👁️ 루테인 지아잔틴</button>
        <button class="pill-btn" data-category="히알루론산">💧 히알루론산</button>
        <button class="pill-btn" data-category="MSM">🦴 MSM</button>
        <button class="pill-btn" data-category="글루코사민 콘드로이틴">🏃 글루코사민 콘드로이틴</button>
        <button class="pill-btn" data-category="크레아틴">💪 크레아틴</button>
        <button class="pill-btn" data-category="칼륨">🍌 칼륨</button>
        <button class="pill-btn" data-category="프로바이오틱스">🦠 프로바이오틱스</button>
        <button class="pill-btn" data-category="프리바이오틱스">🍎 프리바이오틱스</button>
        <button class="pill-btn" data-category="식이섬유">🥗 식이섬유</button>
        <button class="pill-btn" data-category="글루타민">💪 글루타민</button>
        <button class="pill-btn" data-category="밀크씨슬">🌱 밀크씨슬</button>
        <button class="pill-btn" data-category="NAC">🛡️ NAC</button>
        <button class="pill-btn" data-category="퀘르세틴">🧅 퀘르세틴</button>

        <%-- 📸 3. 포토 리뷰 버튼 --%>
        <button class="pill-btn btn-photo-only" data-category="photo">📸 포토리뷰만 보기</button>
    </div>

    <%-- 🌟 옛날 코드 다 날아간 아주 깔끔한 그리드! (JS가 채워줌) --%>
    <div class="lounge-grid"></div>

    <%-- 🌟 [무한 스크롤] 바닥 센서 및 로딩 UI 추가! --%>
    <div id="scroll-anchor" style="height: 20px; width: 100%;"></div>

    <div id="loading-spinner" style="display: none; text-align: center; padding: 40px;">
        <div class="bounce-spinner">
            <div></div><div></div><div></div>
        </div>
        <p style="color: #6a8d3a; margin-top: 15px; font-weight: bold;">리뷰를 더 가져오는 중... 🌱</p>
    </div>

    <div id="end-message" style="display: none; text-align: center; padding: 60px 0; margin-top: 20px; color: #bbb; font-weight: bold; border-top: 2px dashed #eee;">
        더 이상 리뷰가 없어요! 모든 리뷰를 다 보셨습니다 🎉
    </div>

</div>

<script>
    const currentLoginId = '${sessionScope.loginUser.user_id}';

    // 🌟 무한 스크롤용 전역 변수들
    let allLoungeData = [];     // DB에서 가져온 전체 데이터 보관소
    let currentRenderIndex = 0; // 현재 화면에 몇 개까지 그렸는지 추적
    const ITEMS_PER_LOAD = 8;   // 한 번 스크롤할 때마다 추가할 카드 개수 (테트리스 블록 수)
    let scrollObserver = null;  // 바닥 감지 센서

    // 🌟 1. 메인 데이터 통신 (DB에서 데이터 가져와서 창고에 넣기)
    function fetchLoungeData(category) {
        // 로딩바 & 끝 메시지 초기화
       // document.getElementById('loading-spinner').style.display = 'block';
        document.getElementById('end-message').style.display = 'none';

        fetch(`lounge-api?category=\${category}`)
            .then(res => res.json())
            .then(data => {
                const grid = document.querySelector('.lounge-grid');
                grid.innerHTML = ''; // 화면 리셋

                if (!data || data.length === 0) {
                  //  document.getElementById('loading-spinner').style.display = 'none';
                    grid.innerHTML = '<div style="column-span: all; padding: 60px; text-align: center; color: #777; font-size: 1.1em; background: #fff; border-radius: 12px; border: 1px dashed #ddd;">조건에 맞는 베스트 리뷰가 없습니다 🥲</div>';

                    // 🚨🚨🚨 [여기 3줄 추가!!] 좀비 데이터 박멸 부적!!! 🚨🚨🚨
                    allLoungeData = [];
                    currentRenderIndex = 0;
                    if (scrollObserver) scrollObserver.disconnect();

                    return;
                }
                // 🌟 데이터를 창고에 저장하고 인덱스 초기화!
                allLoungeData = data;
                currentRenderIndex = 0;
                let initialHtml = '';

                // 🏆 [전체보기] 일 때 시상대 처리 (맨 처음에만 그림)
                if (category === 'all' && allLoungeData.length >= 3) {
                    const top3 = allLoungeData.slice(0, 3);
                    const rankClasses = ['rank-1', 'rank-2', 'rank-3'];
                    const crowns = ['👑', '🥈', '🥉'];

                    initialHtml += '<div class="podium-wrap">';
                    top3.forEach((r, index) => {
                        let imgSrc = (r.r_img && r.r_img !== 'null' && r.r_img !== 'undefined' && r.r_img.trim() !== '') ? (r.r_img.startsWith('http') ? r.r_img : '../upload/' + r.r_img) : '';
                        let imgHtml = imgSrc
                            ? `<div class="review-img-box"><img src="\${imgSrc}" alt="리뷰사진" onerror="this.onerror=null; this.parentElement.style.display='none';"></div>`
                            : `<div class="review-img-box empty-img" style="background:#f1f3f5; display:flex; align-items:center; justify-content:center;"><span style="font-size:3em; color:#ddd;">🌿</span></div>`;

                        let pImgSrc = (r.p_img && r.p_img !== 'null') ? r.p_img : '';
                        let pImgHtml = pImgSrc ? `<img src="\${pImgSrc}" onerror="this.style.display='none';">` : '';
                        let safeUser = r.user_id ? r.user_id.substring(0,3) + '***' : '익명';

                        initialHtml += `
                        <div class="podium-card \${rankClasses[index]}">
                            <div class="crown-badge">\${crowns[index]}</div>
                            <div class="card-prod-info" onclick="location.href='product-detail?id=\${r.product_id}'" style="border-radius: 13px 13px 0 0;">
                                \${pImgHtml}
                                <div class="prod-name">\${r.p_name || '제품명 없음'}</div>
                            </div>
                            <div class="card-body">
                                <div class="review-stars">\${'★'.repeat(r.r_score)}\${'☆'.repeat(5-r.r_score)}</div>
                                <div class="review-title">\${r.r_title}</div>
                                \${imgHtml}
                                <div class="review-content" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;">\${r.r_content}</div>
                            </div>
                            <div class="card-footer" style="border-radius: 0 0 13px 13px; background: #fafafa;">
                                <div class="author">\${safeUser}</div>
                                <button class="like-btn" onclick="loungeToggleLike(this, \${r.review_id})">👍 <span>\${r.r_like}</span></button>
                            </div>
                        </div>`;
                    });
                    initialHtml += '</div>';

                    // 시상대 3개 그렸으니까, 다음엔 4번째 것부터 그리기 시작!
                    currentRenderIndex = 3;
                }

                grid.innerHTML = initialHtml;

                // 🌟 센서 켜기 & 첫 번째 8개 카드 장전!
                initScrollObserver();
                loadMoreReviews();
            })
            .catch(err => {
                console.error("데이터 불러오기 에러:", err);
                document.getElementById('loading-spinner').style.display = 'none';
            });
    }

    // 🌟 2. 8개씩 잘라서 화면에 갖다 붙이는 로직 (핵심!)
    function loadMoreReviews() {
        // 이미 창고에 있는 데이터를 다 털어 썼다면?
        if (currentRenderIndex >= allLoungeData.length) {
            document.getElementById('loading-spinner').style.display = 'none';
            document.getElementById('end-message').style.display = 'block'; // 뚜껑 덮기!
            if (scrollObserver) scrollObserver.disconnect(); // 센서 끄기
            return;
        }

       // document.getElementById('loading-spinner').style.display = 'flex';

        // 🌟 너무 빠르면 무한 스크롤의 쫀득한 맛이 없으니 일부러 0.3초 딜레이를 줍니다 (감성 한 스푼)
        setTimeout(() => {
            // 이번 턴에 그릴 8개 데이터 쏙 빼오기
            const nextChunk = allLoungeData.slice(currentRenderIndex, currentRenderIndex + ITEMS_PER_LOAD);
            let chunkHtml = '';

            nextChunk.forEach(r => {
                let imgSrc = (r.r_img && r.r_img !== 'null' && r.r_img !== 'undefined' && r.r_img.trim() !== '') ? (r.r_img.startsWith('http') ? r.r_img : '../upload/' + r.r_img) : '';
                let imgHtml = imgSrc ? `<div class="review-img-box"><img src="\${imgSrc}" alt="리뷰사진" onerror="this.onerror=null; this.parentElement.style.display='none';"></div>` : '';
                let pImgSrc = (r.p_img && r.p_img !== 'null') ? r.p_img : '';
                let pImgHtml = pImgSrc ? `<img src="\${pImgSrc}" onerror="this.style.display='none';">` : '';
                let safeUser = r.user_id ? r.user_id.substring(0,3) + '***' : '익명';

                chunkHtml += `
                <div class="lounge-card">
                    <div class="card-prod-info" onclick="location.href='product-detail?id=\${r.product_id}'">
                        \${pImgHtml}
                        <div class="prod-name">\${r.p_name || '제품명 없음'}</div>
                    </div>
                    <div class="card-body">
                        <div class="review-stars">\${'★'.repeat(r.r_score)}\${'☆'.repeat(5-r.r_score)}</div>
                        <div class="review-title">\${r.r_title}</div>
                        \${imgHtml}
                        <div class="review-content" style="display: -webkit-box; -webkit-line-clamp: 4; -webkit-box-orient: vertical; overflow: hidden;">\${r.r_content}</div>
                    </div>
                    <div class="card-footer">
                        <div class="author">\${safeUser}</div>
                        <button class="like-btn" onclick="loungeToggleLike(this, \${r.review_id})">👍 <span>\${r.r_like}</span></button>
                    </div>
                </div>`;
            });

            // 화면 맨 밑에 8개 카드 끼워 넣기!
            document.querySelector('.lounge-grid').insertAdjacentHTML('beforeend', chunkHtml);

            // 인덱스 업데이트
            currentRenderIndex += nextChunk.length;
            document.getElementById('loading-spinner').style.display = 'none';

            // 넣고 났더니 다 떨어졌으면 뚜껑 덮기!
            if (currentRenderIndex >= allLoungeData.length) {
                document.getElementById('end-message').style.display = 'block';
                if (scrollObserver) scrollObserver.disconnect();
            }
        }, 100); // 0.3초 딜레이
    }

    // 🌟 3. 바닥 감지 센서 (Intersection Observer API)
    function initScrollObserver() {
        if (scrollObserver) scrollObserver.disconnect(); // 기존 센서 제거

        const anchor = document.getElementById('scroll-anchor');

        scrollObserver = new IntersectionObserver((entries) => {
            // 바닥 센서가 화면에 나타나면?!
            if (entries[0].isIntersecting) {
                loadMoreReviews(); // 다음 8개 가져와!!
            }
        }, { rootMargin: '100px' }); // 바닥에 닿기 100px 전에 미리 발동! (끊김 없는 스크롤)

        if (anchor) scrollObserver.observe(anchor);
    }

    // 🌟 4. 좋아요 버튼 로직 (기존과 동일)
    function loungeToggleLike(btnElement, reviewId) {
        if (!currentLoginId || currentLoginId === '') {
            alert('로그인이 필요한 기능입니다! 🔒'); return;
        }
        const params = new URLSearchParams();
        params.append('review_id', reviewId);
        params.append('user_id', currentLoginId);

        fetch('review-like', { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' }, body: params })
            .then(res => res.text())
            .then(newCount => {
                btnElement.innerHTML = `👍 <span>\${newCount}</span>`;
                btnElement.classList.remove('pop-anim');
                void btnElement.offsetWidth;
                btnElement.classList.add('pop-anim');
                btnElement.classList.add('active-like');
            })
            .catch(err => console.error("좋아요 처리 에러:", err));
    }

    // 🌟 5. 카테고리 클릭 로직
    const allMainBtns = document.querySelectorAll('.pill-btn:not(.dropdown-toggle)');
    const vitaminMainBtn = document.getElementById('vitamin-main-btn');
    const allSubBtns = document.querySelectorAll('.sub-pill-btn');
    const dropMenu = document.querySelector('.dropdown-menu');

    vitaminMainBtn.addEventListener('click', function(e) { e.stopPropagation(); dropMenu.classList.toggle('show'); });
    document.addEventListener('click', function(e) { if (!e.target.closest('.dropdown-container')) dropMenu.classList.remove('show'); });

    allSubBtns.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            document.querySelectorAll('.pill-btn, .sub-pill-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            vitaminMainBtn.classList.add('active');

            let shortName = this.innerText;
            if(shortName.includes('(')) shortName = shortName.split('(')[0];
            vitaminMainBtn.innerText = `💊 비타민 (\${shortName}) ▼`;

            const category = this.getAttribute('data-category');
            fetchLoungeData(category);
        });
    });

    allMainBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.pill-btn, .sub-pill-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            vitaminMainBtn.innerText = '💊 비타민 ▼';
            dropMenu.classList.remove('show');

            const category = this.getAttribute('data-category');
            fetchLoungeData(category);
        });
    });

    // 🌟 6. 페이지 시작 시 냅다 실행!
    fetchLoungeData('all');
</script>



