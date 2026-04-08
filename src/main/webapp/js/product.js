/**
 * 전역 변수 및 요소 참조
 */
let deleteTargetId = null;
const regModal = document.getElementById("productModal");
const delModal = document.getElementById("deleteConfirmModal");


document.addEventListener("DOMContentLoaded", function () {
    const urlParams = new URLSearchParams(window.location.search);
    const toast = document.getElementById("toast");

    if (toast) {
        let message = "";
        let toastType = "";
        let paramToClear = "";

        if (urlParams.get('insert') === 'success') {
            message = "💊 영양제가 성공적으로 등록되었습니다!";
            toastType = "success";
            paramToClear = "insert";
        } else if (urlParams.get('delete') === 'success') {
            message = "🗑️ 제품이 성공적으로 삭제되었습니다.";
            toastType = "delete";
            paramToClear = "delete";
        } else if (urlParams.get('update') === 'success') {
            message = "✨ 수정이 완료되었습니다!";
            toastType = "update"; // 하늘색 테마
            paramToClear = "update";
        }

        if (message) {
            toast.innerText = message;
            toast.className = "toast";
            toast.classList.add("show", toastType);

            setTimeout(() => {
                toast.classList.remove("show", toastType);
            }, 3000);

            // 성공 파라미터만 제거하고 id는 유지
            urlParams.delete(paramToClear);
            const newSearch = urlParams.toString();
            const newUrl = window.location.pathname + (newSearch ? "?" + newSearch : "");
            history.replaceState({}, null, newUrl);
        }
    }

    const btnConfirm = document.getElementById("btn-confirm-delete");
    if (btnConfirm) {
        btnConfirm.addEventListener("click", function () {
            if (deleteTargetId) {
                location.href = `product-del?id=${deleteTargetId}`;
            }
        });
    }
});

// --- 모달 제어 및 유효성 검사 함수들은 기존과 동일하게 유지하되,
// 맨 마지막에 남는 불필요한 '}' 가 없는지 꼭 확인하세요! ---


/**
 * 모달 제어 함수 (등록)
 */
function openModal() {
    toggleModal(regModal, true);
}

function closeModal() {
    toggleModal(regModal, false);
}

/**
 * 모달 제어 함수 (삭제)
 */
function confirmDelete(productId) {
    deleteTargetId = productId;
    toggleModal(delModal, true);
}

function closeDeleteModal() {
    toggleModal(delModal, false);
    deleteTargetId = null;
}

/**
 * 모달 상태 토글 공통 함수
 */
function toggleModal(modalTarget, isShow) {
    if (!modalTarget) return;
    modalTarget.style.display = isShow ? "flex" : "none";
    document.body.style.overflow = isShow ? "hidden" : "auto";
}

/**
 * 전역 클릭 이벤트 (모달 바깥 영역 클릭 시 닫기)
 */
window.onclick = function (event) {
    if (event.target === regModal) closeModal();
    if (event.target === delModal) closeDeleteModal();
};


/**
 * 유효성 검사 함수
 */
function validateProductForm() {
    console.log("검증 시작..."); // 버튼 클릭 시 브라우저 콘솔(F12)에 찍히는지 확인하세요.

    // 1. 폼 요소 참조 (클래스명이 일치하는지 확인)
    const form = document.querySelector('.modal-form');
    if (!form) {
        console.error("폼 요소를 찾을 수 없습니다. 클래스명을 확인하세요.");
        return false;
    }

    // 2. 체크 대상: input, select, textarea 중 required 속성이 있는 것들
    const requiredInputs = form.querySelectorAll('input[required], select[required], textarea[required]');

    for (let input of requiredInputs) {
        // 공백 제거 후 값 확인
        if (!input.value || !input.value.trim()) {
            // 가장 가까운 .input-group 내의 label 텍스트를 가져옴
            const labelElement = input.closest('.input-group')?.querySelector('label');
            const labelName = labelElement ? labelElement.innerText : "필수 항목";

            alert(`${labelName}을(를) 입력해주세요.`);
            input.focus(); // 해당 칸으로 커서 이동
            return false; // 전송 중단
        }
    }

    console.log("검증 완료, 데이터 전송");
    return true; // 전송 승인
}


//edit 영역

function handleImagePreview(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function (e) {
            document.getElementById('previewImg').src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    }
}


// edit 부분 js
function handleImagePreview(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function (e) {
            // 변경된 사진 데이터를 img 태그의 src에 즉시 반영
            document.getElementById('previewImg').src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    }
}
