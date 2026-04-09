console.log('connected..')

const modal = document.getElementById('commonModal');
const content = document.getElementById('modalContent');

// ESC key event handler to close modal
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && modal.open) {
        modal.close();
        content.innerHTML = '';
    }
});

// 1. 등록 모달 열기
function openAddModal() {
    fetch('/supplementAdd') // 등록용 JSP를 반환하는 서블릿 경로
        .then(res => res.text())
        .then(html => {
            console.log(html)
            content.innerHTML = html;
            modal.showModal();
        });
}


// 2. 상세 모달 열기
async function openDetailModal(div) {
    const divData = div.dataset;
    console.log(divData)
    const id = divData.id;
    const name = divData.name;
    const efficacy = divData.efficacy;
    const dosage = divData.dosage;
    const timing = divData.timing;
    const caution = divData.caution;
    const imgPath = divData.imgpath;

    const response = await fetch('/detailSupplements') // 등록용 JSP를 반환하는 서블릿 경로
    const html = await response.text();
    content.innerHTML = html;
    modal.showModal();

    const imgEl =  document.querySelector(".detail-img-area").children[0];
    console.log(imgEl)
    imgEl.src = imgPath;

    // 명재샘...!
    const rows = document.querySelectorAll(".detail-row");
    rows[0].children[1].innerText = id;
    rows[1].children[1].innerText = name;
    rows[2].children[1].innerText = efficacy;
    rows[3].children[1].innerText = dosage;
    rows[4].children[1].innerText = timing;
    rows[5].children[1].innerText = caution;

    // 모달의 수정 버튼에게 고유번호(id) 쥐어주기!
    const btns = document.querySelectorAll(".btn-group .btn-list");
    // btns[0]은 목록으로 버튼, btns[1]이 수정 버튼입니다.
    btns[1].setAttribute("onclick", `updateSupplement('${id}')`);
}

//---------------------------------------------------------------------------------------------
// 버튼을 클릭했을 때 화면 새로고침 없이 하트를 바꿔주고 서버(컨트롤러)로 데이터를 보내는 자바스크립트

function toggleLike(btn, supplementId) {
    fetch('supplementsLike', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'supplementId=' + supplementId
    })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'liked') {
                btn.classList.add('liked');
                btn.querySelector('.like-label').textContent = '좋아요 취소';
            } else if (data.status === 'unliked') {
                btn.classList.remove('liked');
                btn.querySelector('.like-label').textContent = '좋아요';
            } else {
                alert(data.message || '로그인이 필요합니다.');
            }
        })
        .catch(err => console.error('좋아요 오류:', err));
}