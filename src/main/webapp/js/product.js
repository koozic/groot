function showToast() {
    const toast = document.getElementById("toast");
    toast.className = "toast show";
    setTimeout(() => { toast.className = toast.className.replace("show", ""); }, 3000);
}

window.onload = function() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('insert') === 'success') {
        showToast();
        history.replaceState({}, null, location.pathname);
    }
}

const modal = document.getElementById("productModal");

// 모달 열기
function openModal() {
    modal.style.display = "flex";
    document.body.style.overflow = "hidden"; // 배경 스크롤 방지
}

// 모달 닫기
function closeModal() {
    modal.style.display = "none";
    document.body.style.overflow = "auto"; // 스크롤 복원
}

// 모달 바깥 영역 클릭 시 닫기
window.onclick = function (event) {
    if (event.target == modal) {
        closeModal();
    }
}



//effect

document.addEventListener("DOMContentLoaded", function () {
    const urlParams = new URLSearchParams(window.location.search);

    // URL에 insert=success가 포함되어 있다면 실행
    if (urlParams.get('insert') === 'success') {
        const toast = document.getElementById("toast");

        if (toast) {
            // 문구 변경 (상황에 맞게)
            toast.innerText = "💊 영양제가 성공적으로 등록되었습니다!";
            toast.classList.add("show");

            // 3초 후 제거
            setTimeout(() => {
                toast.classList.remove("show");
            }, 3000);
        }

        // 브라우저 주소창에서 ?insert=success 깔끔하게 제거 (새로고침 시 중복 방지)
        history.replaceState({}, null, location.pathname);
    }
});