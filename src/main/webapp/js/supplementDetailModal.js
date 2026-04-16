// Supplement Detail Modal for MyPage
// '마이페이지 전용 영양성분 상세 보기 모달창'을 띄우고, 관리하고, 닫기 위해 존재하는 한 세트(Set)

function showSupplementDetail(suppId, name, efficacy, dosage, timing, caution, imgPath) {
    // HTML escaping for security
    const escapedName = name.replace(/</g, "&lt;").replace(/>/g, "&gt;");
    const escapedEfficacy = efficacy.replace(/</g, "&lt;").replace(/>/g, "&gt;");
    const escapedDosage = dosage ? dosage.replace(/</g, "&lt;").replace(/>/g, "&gt;") : 'N/A';
    const escapedTiming = timing ? timing.replace(/</g, "&lt;").replace(/>/g, "&gt;") : 'N/A';
    const escapedCaution = caution ? caution.replace(/</g, "&lt;").replace(/>/g, "&gt;") : 'N/A';

    // Image path handling
    // imgPath - 파라미터(매개변수)
    let imgSrc;
    if (imgPath && imgPath.startsWith('http')) {
        imgSrc = imgPath;
    } else {
        imgSrc = '/supplementImg/supplementImgFile/' + (imgPath || 'default.png');
    }

    // Create modal HTML
    const modalHTML = `
        <div id="supplementDetailModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 9999; display: flex; align-items: center; justify-content: center;">
            <div style="background: white; padding: 30px; border-radius: 15px; max-width: 700px; width: 90%; max-height: 80vh; overflow-y: auto; position: relative;">
                <button onclick="closeSupplementDetailModal()" style="position: absolute; top: 15px; right: 15px; background: none; border: none; font-size: 24px; cursor: pointer;">×</button>
                
                <div style="text-align: center; margin-bottom: 20px;">
                    <img src="${imgSrc}" alt="${escapedName}" style="max-width: 100%; height: 300px; object-fit: cover; border-radius: 10px;">
                </div>
                
                <h2 style="margin-bottom: 20px; color: #2c3e50;">${escapedName}</h2>
                
                <div style="display: flex; flex-direction: column; gap: 15px;">
                    <div style="border-bottom: 1px solid #f5f5f5; padding: 10px 0;">
                        <strong style="color: #2c3e50;">1. Name:</strong> ${escapedName}
                    </div>
                    <div style="border-bottom: 1px solid #f5f5f5; padding: 10px 0;">
                        <strong style="color: #2c3e50;">2. Efficacy:</strong> ${escapedEfficacy}
                    </div>
                    <div style="border-bottom: 1px solid #f5f5f5; padding: 10px 0;">
                        <strong style="color: #2c3e50;">3. Dosage:</strong> ${escapedDosage}
                    </div>
                    <div style="border-bottom: 1px solid #f5f5f5; padding: 10px 0;">
                        <strong style="color: #2c3e50;">4. Timing:</strong> ${escapedTiming}
                    </div>
                    <div style="padding: 10px 0;">
                        <strong style="color: #2c3e50;">5. Caution:</strong> ${escapedCaution}
                    </div>
                </div>
            </div>
        </div>
    `;

    // Add modal to body and show
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    document.body.style.overflow = 'hidden'; // Prevent background scrolling
}

function closeSupplementDetailModal() {
    const modal = document.getElementById('supplementDetailModal');
    if (modal) {
        modal.remove();
        document.body.style.overflow = 'auto'; // Restore scrolling
    }
    // if (modal){} :  "내가 찾은 모달창이 진짜로 화면에 존재할 때만 괄호 안의 일을 실행해!" 라는 뜻
}


// ==============================================================================

// Close modal when clicking outside
// 감시대상.addEventListener('사건의종류', 실행할_함수);
document.addEventListener('click', function(event) {
    const modal = document.getElementById('supplementDetailModal');
    if (modal && event.target === modal) {
        // 모달창(modal)이라는 녀석이 지금 메모리상에 진짜로 존재해?
        // event.target : "사용자의 마우스 커서가 정확히 꽂힌 바로 그 지점(태그)"을 의미
        // "마우스로 정확히 찌른 곳이, 하필이면 그 거대한 어두운 배경(modal)이랑 완전히 일치해?
        closeSupplementDetailModal();
    }
});

// Close modal with ESC key
document.addEventListener('keydown', function(event) {
    // keydown : 키보드 버튼을 눌렀을 때
    if (event.key === 'Escape') {
        closeSupplementDetailModal();
    }
});
