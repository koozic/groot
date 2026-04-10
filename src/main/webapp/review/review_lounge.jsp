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
        <button class="pill-btn" data-category="비타민 C">🍊 비타민C</button>
        <button class="pill-btn" data-category="오메가3">🐟 오메가3</button>
        <button class="pill-btn" data-category="마그네슘">🌿 마그네슘</button>
        <button class="pill-btn" data-category="photo" style="border-style: dashed;">📸 포토리뷰만 보기</button>
    </div>

    <%-- 🌟 옛날 코드 다 날아간 아주 깔끔한 그리드! (JS가 채워줌) --%>
    <div class="lounge-grid">
    </div>
</div>

<script>
    // 🌟 1. 좋아요 기능을 위해 현재 로그인한 유저 아이디 가져오기!
    const currentLoginId = '${sessionScope.loginUser.user_id}';

    document.querySelectorAll('.pill-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.pill-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            const category = this.getAttribute('data-category');
            fetchLoungeData(category);
        });
    });

    function fetchLoungeData(category) {
        fetch(`lounge-api?category=\${category}`)
            .then(res => res.json())
            .then(data => {
                const grid = document.querySelector('.lounge-grid');

                if (!data || data.length === 0) {
                    grid.innerHTML = '<div style="grid-column: 1/-1; padding: 60px; text-align: center; color: #777; font-size: 1.1em; background: #fff; border-radius: 12px; border: 1px dashed #ddd;">조건에 맞는 베스트 리뷰가 없습니다 🥲</div>';
                    return;
                }

                let finalHtml = '';

                // 🌟 [시상대 렌더링 - 탑 3]
                if (data.length >= 3) {
                    const top3 = data.slice(0, 3);
                    const rankClasses = ['rank-1', 'rank-2', 'rank-3'];
                    const crowns = ['👑', '🥈', '🥉'];

                    finalHtml += '<div class="podium-wrap">';

                    top3.forEach((r, index) => {
                        let imgSrc = r.r_img && r.r_img !== 'null' ? (r.r_img.startsWith('http') ? r.r_img : '../upload/' + r.r_img) : '';
                        let imgHtml = imgSrc ? `<div class="review-img-box"><img src="\${imgSrc}" alt="리뷰사진"></div>` : '';
                        let pImgSrc = r.p_img ? r.p_img : '../images/default.jpg';
                        let safeUser = r.user_id ? r.user_id.substring(0,3) + '***' : '익명';

                        finalHtml += `
                        <div class="podium-card \${rankClasses[index]}">
                            <div class="crown-badge">\${crowns[index]}</div>
                            <div class="card-prod-info" onclick="location.href='product-detail?id=\${r.product_id}'" style="border-radius: 13px 13px 0 0;">
                                <img src="\${pImgSrc}">
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

                // 🌟 [일반 카드 렌더링 - 4등부터]
                const restData = data.length >= 3 ? data.slice(3) : data;

                finalHtml += restData.map(r => {
                    let imgSrc = r.r_img && r.r_img !== 'null' ? (r.r_img.startsWith('http') ? r.r_img : '../upload/' + r.r_img) : '';
                    let imgHtml = imgSrc ? `<div class="review-img-box"><img src="\${imgSrc}" alt="리뷰사진"></div>` : '';
                    let pImgSrc = r.p_img ? r.p_img : '../images/default.jpg';
                    let safeUser = r.user_id ? r.user_id.substring(0,3) + '***' : '익명';

                    return `
                    <div class="lounge-card">
                        <div class="card-prod-info" onclick="location.href='product-detail?id=\${r.product_id}'">
                            <img src="\${pImgSrc}">
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
            });
    }

    // 🌟 [핵심] 실제 DB 통신 & 쫀득한 애니메이션 함수!
    function loungeToggleLike(btnElement, reviewId) {
        // 로그인 안 한 유저는 컷!
        if (!currentLoginId || currentLoginId === '') {
            alert('로그인이 필요한 기능입니다! 🔒');
            return;
        }

        const params = new URLSearchParams();
        params.append('review_id', reviewId);
        params.append('user_id', currentLoginId);

        // 기존 상품 상세 페이지에서 쓰던 좋아요 컨트롤러 찌르기!
        fetch('review-like', {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            body: params
        })
            .then(res => res.text())
            .then(newCount => {
                // 숫자 바꿔치기
                btnElement.innerHTML = `👍 <span>\${newCount}</span>`;

                // 애니메이션 껐다 켜기 (연타해도 계속 터지게!)
                btnElement.classList.remove('pop-anim');
                void btnElement.offsetWidth;
                btnElement.classList.add('pop-anim');
                btnElement.classList.add('active-like');
            })
            .catch(err => {
                console.error("좋아요 처리 에러:", err);
            });
    }

    // 🌟 페이지 켜지자마자 무조건 실행!
    window.addEventListener('DOMContentLoaded', () => {
        fetchLoungeData('all');
    });
</script>