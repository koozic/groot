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
                    <%-- 🌟 수용성 비타민 (경용씨 버전 똑같이 8개!) --%>
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

                    <%-- 🌟 지용성 비타민 (경용씨 버전 4개!) --%>
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

        <%-- 🌟 2. 나머지 영양제들 총출동 (13, 10 제외!) --%>
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

        <%-- 📸 3. 포토 리뷰 버튼 (항상 맨 끝에!) --%>
        <button class="pill-btn btn-photo-only" data-category="photo">📸 포토리뷰만 보기</button>
    </div>

    <%-- 🌟 옛날 코드 다 날아간 아주 깔끔한 그리드! (JS가 채워줌) --%>
    <div class="lounge-grid">
    </div>
</div>

<script>
    // 🌟 1. 좋아요 기능을 위해 현재 로그인한 유저 아이디 가져오기!
    const currentLoginId = '${sessionScope.loginUser.user_id}';

    // 🌟 2. 메인 데이터 통신 & 화면 그리기 함수
    function fetchLoungeData(category) {
        fetch(`lounge-api?category=\${category}`)
            .then(res => res.json())
            .then(data => {
                const grid = document.querySelector('.lounge-grid');

                if (!data || data.length === 0) {
                    grid.innerHTML = '<div style="column-span: all; padding: 60px; text-align: center; color: #777; font-size: 1.1em; background: #fff; border-radius: 12px; border: 1px dashed #ddd;">조건에 맞는 베스트 리뷰가 없습니다 🥲</div>';
                    return;
                }

                let finalHtml = '';

                // 🏆 [전체보기] 일 때만 시상대 띄우기!
                if (category === 'all' && data.length >= 3) {
                    const top3 = data.slice(0, 3);
                    const rankClasses = ['rank-1', 'rank-2', 'rank-3'];
                    const crowns = ['👑', '🥈', '🥉'];

                    finalHtml += '<div class="podium-wrap">';
                    top3.forEach((r, index) => {
                        // 🌟 무한루프 완벽 차단! (onerror=null 추가 및 엑박 시 숨김 처리)
                        let imgSrc = (r.r_img && r.r_img !== 'null' && r.r_img !== 'undefined' && r.r_img.trim() !== '') ? (r.r_img.startsWith('http') ? r.r_img : '../upload/' + r.r_img) : '';
                        let imgHtml = imgSrc
                            ? `<div class="review-img-box"><img src="\${imgSrc}" alt="리뷰사진" onerror="this.onerror=null; this.parentElement.style.display='none';"></div>`
                            : `<div class="review-img-box empty-img" style="background:#f1f3f5; display:flex; align-items:center; justify-content:center;"><span style="font-size:3em; color:#ddd;">🌿</span></div>`;

                        // 🌟 상품 이미지도 엑박 나면 숨기기! (무한루프 방지)
                        let pImgSrc = (r.p_img && r.p_img !== 'null') ? r.p_img : '';
                        let pImgHtml = pImgSrc ? `<img src="\${pImgSrc}" onerror="this.style.display='none';">` : '';

                        let safeUser = r.user_id ? r.user_id.substring(0,3) + '***' : '익명';

                        finalHtml += `
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
                    finalHtml += '</div>';
                }

                // 🧱 전체보기가 아니면, 1등부터 꼴등까지 전부 다 일반 카드로 렌더링!
                const restData = (category === 'all' && data.length >= 3) ? data.slice(3) : data;

                finalHtml += restData.map(r => {
                    let imgSrc = (r.r_img && r.r_img !== 'null' && r.r_img !== 'undefined' && r.r_img.trim() !== '') ? (r.r_img.startsWith('http') ? r.r_img : '../upload/' + r.r_img) : '';
                    let imgHtml = imgSrc ? `<div class="review-img-box"><img src="\${imgSrc}" alt="리뷰사진" onerror="this.onerror=null; this.parentElement.style.display='none';"></div>` : '';

                    let pImgSrc = (r.p_img && r.p_img !== 'null') ? r.p_img : '';
                    let pImgHtml = pImgSrc ? `<img src="\${pImgSrc}" onerror="this.style.display='none';">` : '';

                    let safeUser = r.user_id ? r.user_id.substring(0,3) + '***' : '익명';

                    return `
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
                }).join('');

                grid.innerHTML = finalHtml;
            })
            .catch(err => console.error("데이터 불러오기 에러:", err));
    }

    // 🌟 3. 좋아요 버튼 애니메이션 함수!
    function loungeToggleLike(btnElement, reviewId) {
        if (!currentLoginId || currentLoginId === '') {
            alert('로그인이 필요한 기능입니다! 🔒');
            return;
        }
        const params = new URLSearchParams();
        params.append('review_id', reviewId);
        params.append('user_id', currentLoginId);

        fetch('review-like', {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            body: params
        })
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

    // 🌟 4. 카테고리 클릭 이벤트 로직 (버튼 색칠 & 팝업창 완벽 제어!)
    const allMainBtns = document.querySelectorAll('.pill-btn:not(.dropdown-toggle)');
    const vitaminMainBtn = document.getElementById('vitamin-main-btn');
    const allSubBtns = document.querySelectorAll('.sub-pill-btn');
    const dropMenu = document.querySelector('.dropdown-menu');

    // ① 비타민 메인 버튼 누를 때 -> 팝업 열기/닫기
    vitaminMainBtn.addEventListener('click', function(e) {
        e.stopPropagation();
        dropMenu.classList.toggle('show');
    });

    // ② 허공(바탕화면) 누를 때 -> 팝업 무조건 닫기
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.dropdown-container')) {
            dropMenu.classList.remove('show');
        }
    });

    // ③ 안쪽 쪼꼬미 비타민(A, B, C) 누를 때
    allSubBtns.forEach(btn => {
        btn.addEventListener('click', function(e) {
            // 🌟 팝업창 클릭했다고 허공 클릭으로 인식해서 꺼지는 현상 방지!
            e.stopPropagation();

            document.querySelectorAll('.pill-btn, .sub-pill-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            vitaminMainBtn.classList.add('active');

            // 글자 예쁘게 자르기
            let shortName = this.innerText;
            if(shortName.includes('(')) shortName = shortName.split('(')[0];
            vitaminMainBtn.innerText = `💊 비타민 (\${shortName}) ▼`;

            // ❌ [여기 있던 dropMenu.classList.remove('show'); 를 지웠습니다! 이제 안 꺼짐!]

            const category = this.getAttribute('data-category');
            fetchLoungeData(category);
        });
    });

    // ④ 다른 일반 버튼(오메가, 마그네슘 등) 누를 때
    allMainBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.pill-btn, .sub-pill-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            vitaminMainBtn.innerText = '💊 비타민 ▼';

            // 🌟 다른 영양제 누를 때는 비타민 팝업창 닫아주기!
            dropMenu.classList.remove('show');

                const category = this.getAttribute('data-category');
                fetchLoungeData(category);
            });
    });
    fetchLoungeData('all');
</script>