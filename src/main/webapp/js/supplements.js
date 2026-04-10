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
    fetch('/supplementAdd', {
        // 💡 서버(필터)가 비동기 요청임을 알아챌 수 있도록 헤더를 추가
        headers: {
            'X-Requested-With': 'fetch'
        }
        }) // 등록용 JSP를 반환하는 서블릿 경로

        .then(res => {
            // 서버에서 403 에러 코드를 보냈다면 권한이 없다는 뜻입니다.
            if (res.status === 403) {
                alert('관리자만 접근할 수 있는 기능입니다!');
                // throw 에러를 발생시켜서 아래의 .then(html => ...) 부분이 실행되지 않게 막습니다.
                throw new Error('권한 없음');
            }
            // 권한이 있다면 정상적으로 HTML 텍스트를 반환
            return res.text();
        })

        .then(html => {
            console.log(html)
            content.innerHTML = html;
            modal.showModal();
        })

        .catch(error => {
            // 위에서 throw한 에러(권한 없음)를 여기서 조용히 처리합니다.
            console.log(error.message);
            // 에러가 났으므로 모달 창은 열리지 않습니다!
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
                btn.classList.add('liked'); // 하트 색상 칠하기

                // 만약 버튼 안에 'like-label' 이라는 텍스트 영역이 있다면 글씨도 변경
                const label = btn.querySelector('.like-label');
                if(label) label.textContent = '좋아요 취소';

            } else if (data.status === 'unliked') {
                btn.classList.remove('liked'); // 하트 색상 지우기

                const label = btn.querySelector('.like-label');
                if(label) label.textContent = '좋아요';

            } else {
                // status가 error일 경우 경고창
                alert(data.message || '로그인이 필요하거나 오류가 발생했습니다.');
            }
        })
        .catch(err => console.error('좋아요 비동기 통신 오류:', err));
}

document.addEventListener("DOMContentLoaded", function() {
    const cards = document.querySelectorAll('.supp-wrap');
    cards.forEach((card, index) => {
        // 각 카드마다 0.05초씩 딜레이를 주어 물결처럼 나타나게 처리
        card.style.animationDelay = (index * 0.08) + 's';
    });
});