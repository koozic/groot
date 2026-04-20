/**
 * 전역 변수 및 요소 참조
 */
let currentPage = 1;
let isFetching = false;
let isLastPage = false;
let currentNutrientId = '';

let deleteTargetId = null;

const regModal = document.getElementById("productModal");
const delModal = document.getElementById("deleteConfirmModal");


document.addEventListener("DOMContentLoaded", function () {
    // 1. 초기 로드 시 전체 리스트 비동기 호출
    loadProductList('');

    // 스크롤 감지 옵저버 설정
    setupScrollObserver();

    // 2. 동기식 처리에 따른 토스트 알림 로직 (기존 코드 유지)
    const urlParams = new URLSearchParams(window.location.search);
    // new URLSearchParams(window.location.searc 웹 페이지가 이동할 때 주소 뒤에 ?key=value 형태로 붙는 데이터를 읽을 때 사용합니다.

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
            toastType = "update";
            paramToClear = "update";
        }

        if (message) {
            toast.innerText = message;
            toast.className = "toast";
            toast.classList.add("show", toastType);

            setTimeout(() => {
                toast.classList.remove("show", toastType);
            }, 3000);

            urlParams.delete(paramToClear);
            const newSearch = urlParams.toString();
            const newUrl = window.location.pathname + (newSearch ? "?" + newSearch : "");
            history.replaceState({}, null, newUrl);
        }
    }

    // 3. 동기식 삭제 처리 로직 (기존 코드 유지)
    const btnConfirm = document.getElementById("btn-confirm-delete");
    if (btnConfirm) {
        btnConfirm.addEventListener("click", function () {
            if (deleteTargetId) {
                location.href = `product-del?id=${deleteTargetId}`;
            }
        });
    }
});

function setupScrollObserver() {
    const observer = new IntersectionObserver((entries) => {
        // scroll-anchor가 화면에 보이고, 데이터를 가져오는 중이 아니며, 마지막 페이지가 아닐 때
        if (entries[0].isIntersecting && !isFetching && !isLastPage) {
            currentPage++;
            fetchProductData(currentNutrientId, currentPage);
        }
    }, { threshold: 0.5 }); // 50% 정도 보였을 때 트리거

    const anchor = document.getElementById("scroll-anchor");
    if (anchor) observer.observe(anchor);
}

// 실제 데이터를 가져오는 비동기 함수
async function fetchProductData(nutrientId, page) {
    isFetching = true;

    // 백엔드로 page 파라미터 전달
    const url = nutrientId
        ? `product?cmd=list&nutrientId=${nutrientId}&page=${page}`
        : `product?cmd=list&page=${page}`;

    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error("네트워크 응답 오류");
        const products = await response.json();

        // 받아온 데이터가 10개 미만이면 마지막 페이지로 간주 (LIMIT 기준)
        if (products.length < 9) {
            isLastPage = true;
        }

        renderProducts(products, page);
    } catch (error) {
        console.error("데이터 로드 실패:", error);
    } finally {
        isFetching = false;
    }
}

async function loadProductList(nutrientId) {
    updateFilterUI(nutrientId);


    // 상태 초기화
    currentNutrientId = nutrientId || '';
    currentPage = 1;
    isLastPage = false;
    document.getElementById("product-list-container").innerHTML = "";

    // 1페이지 데이터 로드
    fetchProductData(currentNutrientId, currentPage);


}
function renderProducts(products, page) {
    const container = document.getElementById("product-list-container");
    const isAdmin = document.getElementById("isAdmin").value === "true";

    // 1페이지인데 데이터가 없는 경우
    if (page === 1 && products.length === 0) {
        container.innerHTML = "<p style='text-align:center; width:100%;'>등록된 상품이 없습니다.</p>";
        return;
    }

    let htmlString = "";
    products.forEach((p, index) => {
        const safeName = String(p.productName || '').replace(/\\/g, "\\\\").replace(/'/g, "\\'");
        const safeBrand = String(p.productBrand || '').replace(/\\/g, "\\\\").replace(/'/g, "\\'");
        const nutrientName = p.nutrientName || (window.NUTRIENT_MAP && window.NUTRIENT_MAP[String(p.productNutrient)]) || '';
        // 기존 동기식 삭제 모달을 띄우는 confirmlocation.href = 'product-del?id=${deleteTargetId}';함수 호출
        const deleteBtnHtml = isAdmin ?
            `<button class="btn-delete" onclick="event.stopPropagation(); confirmDelete('${p.productId}')">&times;</button>` : '';
        //event.stopPropagation() 버튼을 눌렀을 때 부모 요소인 카드의 클릭 이벤트(상세 페이지 이동)가 발생하는 것을 막습니다.

// append 방식이므로 index 딜레이는 고정값 사용 혹은 계산식 조정
        const delay = (index % 9) * 0.05;
        htmlString += `
            <div class="product-card" style="animation-delay: ${delay}s" onclick="location.href='product-detail?id=${p.productId}'">
                <div class="product-image">
                    <img src="${p.productImage}" alt="상품 이미지" onerror="this.src='img/pill.png'">
                    ${deleteBtnHtml}
                </div>
                <div class="product-info">
                    <div class="product-name">${p.productName}</div>
                    <div class="product-brand">${p.productBrand}</div>
                    <div class="product-nutrient">${nutrientName}</div>
                    <div class="product-price">${p.productPrice}원</div>
                    <div class="product-date">${p.productStartDate}</div>
               
                    <button class="btn-cart"
                            onclick="event.stopPropagation(); addCart(${p.productId}, '${safeName}', '${safeBrand}')">
                        🛒 담기
                    </button>
                </div>
            </div>
        `;
    });
    // 기존 데이터를 지우지 않고 뒤에 이어 붙임 (insertAdjacentHTML)
    container.insertAdjacentHTML('beforeend', htmlString);
}

function updateFilterUI(selectedId) {
    document.getElementById("filter-all").classList.remove("active");
    document.querySelectorAll(".filter-item").forEach(btn => btn.classList.remove("active"));

    if (!selectedId) {
        document.getElementById("filter-all").classList.add("active");
    } else {
        const targetBtn = document.querySelector(`.filter-item[data-id='${selectedId}']`);
        if (targetBtn) targetBtn.classList.add("active");
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



//add부분 이미지 미리보기 함수
// 이미지 미리보기 함수
function previewImage(input) {
    const preview = document.getElementById('modal-img-preview');
    const placeholder = document.querySelector('.image-placeholder');

    if (input.files && input.files[0]) {
        const reader = new FileReader();

        reader.onload = function(e) {
            // 1. 미리보기 이미지의 src에 읽어온 데이터 할당
            preview.src = e.target.result;
            // 2. hidden 클래스 제거하여 이미지 표시
            preview.classList.remove('hidden');
            // 3. 기존의 아이콘과 텍스트(placeholder) 숨기기
            if (placeholder) {
                placeholder.style.display = 'none';
            }
        };

        reader.readAsDataURL(input.files[0]); // 파일을 Data URL로 읽기
    } else {
        // 파일 선택 취소 시 초기화
        preview.src = "";
        preview.classList.add('hidden');
        if (placeholder) {
            placeholder.style.display = 'block';
        }
    }
}

// 모달 닫을 때 이미지 초기화 로직 (추가 권장)
function closeModal() {
    const modal = document.getElementById('productModal');
    modal.style.display = 'none';

    // 이미지 초기화
    const preview = document.getElementById('modal-img-preview');
    const placeholder = document.querySelector('.image-placeholder');
    const fileInput = document.getElementById('product_image_file');

    if(preview) {
        preview.src = "";
        preview.classList.add('hidden');
    }
    if(placeholder) placeholder.style.display = 'block';
    if(fileInput) fileInput.value = ""; // 파일 선택 값 비우기
}



// 페이지 로드 완료 시 순차적 페이드인 적용
document.addEventListener("DOMContentLoaded", function() {
    const cards = document.querySelectorAll('.product-card');
    cards.forEach((card, index) => {
        // 각 카드마다 0.05초씩 딜레이를 주어 물결처럼 나타나게 처리
        card.style.animationDelay = (index * 0.05) + 's';
    });
});

// // 장바구니/찜 담기
// function addCart(productId, productName, brand) {
//     console.log('Adding to cart:', {productId, productName, brand});
//
//     fetch('cart/add', {
//         method: 'POST',
//         headers: {'Content-Type': 'application/json'},
//         body: JSON.stringify({productId, productName, brand})
//     })
//     .then(r => {
//         console.log('Response status:', r.status);
//         return r.json();
//     })
//     .then(data => {
//         console.log('Response data:', data);
//         showToast(data.message);
//         if (data.success) updateCartBadge(data.cartCount);
//     })
//     .catch(error => {
//         console.error('Cart add error:', error);
//         showToast('장바구니 담기 오류가 발생했습니다');
//     });
// }

function toggleWishLegacy(btn, productId) {
    fetch('cart/toggle', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({productId})
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            btn.textContent = data.action === 'added' ? '❤️' : '🤍';
        }
    });
}

function updateCartBadgeLegacy(count) {
    var badge = document.querySelector('.nav-badge');
    if (badge) badge.textContent = count;
}

// 드롭다운 토글 함수
function toggleDropdown(button) {
    const dropdownMenu = button.nextElementSibling;
    dropdownMenu.classList.toggle("show");
}

// 메뉴 외부 클릭 시 드롭다운 닫기
window.onclick = function(event) {
    if (!event.target.closest('.filter-dropdown')) {
        const dropdowns = document.getElementsByClassName("dropdown-menu");
        for (let i = 0; i < dropdowns.length; i++) {
            let openDropdown = dropdowns[i];
            if (openDropdown.classList.contains('show')) {
                openDropdown.classList.remove('show');
            }
        }
    }
}

