/**
 * 전역 변수 및 요소 참조
 */
let deleteTargetId = null;
const regModal = document.getElementById("productModal");
const delModal = document.getElementById("deleteConfirmModal");
const toast = document.getElementById("toast");

/**
 * 초기화 및 이벤트 바인딩
 */
document.addEventListener("DOMContentLoaded", function () {
    const urlParams = new URLSearchParams(window.location.search);

    // 1. URL 파라미터에 따른 토스트 알림 처리
    if (toast) {
        let message = "";
        if (urlParams.get('insert') === 'success') {
            message = "💊 영양제가 성공적으로 등록되었습니다!";
        } else if (urlParams.get('delete') === 'success') {
            message = "🗑️ 제품이 성공적으로 삭제되었습니다.";
        }

        if (message) {
            showToast(message);
            // URL 파라미터 제거 (새로고침 시 중복 방지)
            history.replaceState({}, null, location.pathname);
        }
    }

    // 2. 삭제 확인 버튼 이벤트 바인딩
    const btnConfirm = document.getElementById("btn-confirm-delete");
    if (btnConfirm) {
        btnConfirm.addEventListener("click", function () {
            if (deleteTargetId) {
                location.href = `product-del?id=${deleteTargetId}`;
            }
        });
    }
});

/**
 * 토스트 메시지 표시 함수
 */
if (toast) {
    let message = "";
    let toastType = ""; // 상태 클래스 저장용 변수

    if (urlParams.get('insert') === 'success') {
        message = "💊 영양제가 성공적으로 등록되었습니다!";
        toastType = "success";
    } else if (urlParams.get('delete') === 'success') {
        message = "🗑️ 제품이 성공적으로 삭제되었습니다.";
        toastType = "delete";
    }

    if (message) {
        toast.innerText = message;
        toast.classList.add("show", toastType); // show와 함께 상태 클래스 추가

        setTimeout(() => {
            // 알림이 꺼질 때 추가했던 클래스들을 모두 초기화
            toast.classList.remove("show", "success", "delete");
            history.replaceState({}, null, location.pathname);
        }, 3000);
    }
}

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