console.log('connected..')

const modal = document.getElementById('commonModal');
const content = document.getElementById('modalContent');

// ESC key event handler to close modal
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && modal.open) {
        modal.close();
        content.innerHTML = '';
    }
// document : 우리가 보고 있는 웹페이지 전체
// addEventListener('keydown', ...) : "사용자가 키보드 자판(key)을 밑으로 누르는(down) 순간을 항상 감시하고 있다는 코드
// 어떤 키를 눌렀는지에 대한 정보가 event라는 바구니에 담겨서 함수 안으로 전달됨
// content.innerHTML = '' : 아까 fetch로 꽉꽉 채워 넣었던 모달창 안의 알맹이(HTML 껍데기와 데이터)를 싹 지움
});

// 1. 등록 모달 열기
function openAddModal() {
    fetch('/supplementAdd', {
        // 💡 서버(필터)가 비동기 요청임을 알아챌 수 있도록 디테일 포인트 (headers)를 추가
        headers: {
            'X-Requested-With': 'fetch'
        }
        }) // 등록용 JSP를 반환하는 서블릿 경로 supplementAdd

        .then(res => {
            // 403 에러 : 서버가 클라이언트의 요청을 이해했지만, 권한 부족 등의 이유로 접근을 거부할 때 발생하는 HTTP 상태 코드
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

        // 위에서 throw한 에러(권한 없음)를 여기서 조용히 처리합니다.
        // 에러가 났으므로 모달 창은 열리지 않습니다!
        .catch(error => {
            console.log(error.message);
        });
}


// 2. 상세 모달 열기
async function openDetailModal(div) {

    // JSP에서 data 주머니에 채운 정보를 주라는 코드
    const divData = div.dataset;
    console.log(divData)

    // 그 내용을 자바스크립트가 각각 기억해 둠.
    const id = divData.id;
    const name = divData.name;
    const efficacy = divData.efficacy;
    const dosage = divData.dosage;
    const timing = divData.timing;
    const caution = divData.caution;
    const imgPath = divData.imgpath;

    // 서버야, '/detailSupplements' 주소에 있는 빈 껍데기 HTML 좀 줘! (받을 때까지 기다림)
    const response = await fetch('/detailSupplements')
    // 서버가 준 응답을 html 변수에 담음.
    const html = await response.text();

    // 서버한테 받은 빈 모달창을 화면에 짠! 하고 띄움.
    // content(빈 공간), innerHTML(지정한 빈 공간에 들어갈 html 코드를 조작할 수 있는 자바스크립트 명령어), html(서버가 준 뼈대
    content.innerHTML = html;
    modal.showModal();

    // const imgEl =  document.querySelector(".detail-img-area").children[0];
    // console.log(imgEl)
    // imgEl.src = imgPath;

    // [이미지 띄우기 로직]
    // 모달창 안의 img 태그를 찾습니다.
    const imgEl = document.querySelector(".detail-img-area img");

    if (imgEl && imgPath) {
        // 이미지가 http로 시작하면(클라우디너리 외부 링크) 그대로 씀
        if (imgPath.startsWith('http')) {
            imgEl.src = imgPath;
        }
        // http가 없으면(default.png 등 순수 파일명) 내 폴더 경로를 앞에 붙여줌!
        else {
            imgEl.src = '/supplementImg/supplementImgFile/' + imgPath;
        }
    }

    // 모달창 안의 빈칸들을 찾아서, 아까 기억해 둔 글자들을 채워 넣음.
    const rows = document.querySelectorAll(".detail-row");
    rows[0].children[1].innerText = id; // "첫 번째 빈칸에 아까 기억한 번호 적어!"
    rows[1].children[1].innerText = name; // "두 번째 빈칸에 아까 기억한 이름 적어!"
    rows[2].children[1].innerText = efficacy;
    rows[3].children[1].innerText = dosage;
    rows[4].children[1].innerText = timing;
    rows[5].children[1].innerText = caution;

    // 모달의 수정 버튼에게 고유번호(id) 쥐어주기!
    const btns = document.querySelectorAll(".btn-group .btn-list");
    // btns[0]은 목록으로 버튼, btns[1]이 수정 버튼입니다.
    // "두 번째 버튼(수정 버튼)아! 너한테 '클릭하면(onclick)
    // 영양제 번호(id)를 들고 updateSupplement 함수를 실행해라!'라는 명령어를 강제로 주입할게!"
    // .setAttribute("속성이름", "넣을 값")
    btns[1].setAttribute("onclick", `updateSupplement('${id}')`);
}



//---------------------------------------------------------------------------------------------
// 버튼을 클릭했을 때 화면 새로고침 없이 하트를 바꿔주고 서버(컨트롤러)로 데이터를 보내는 자바스크립트

function toggleLike(btn, supplementId) {
    if (btn.disabled) {
        return;
    }

    btn.disabled = true;

    fetch('supplementsLike', {
        method: 'POST',
        // 이거 일반 폼(form) 데이터 형식이야!라고 명찰(headers)을 붙임
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        // post에 supplementId=15 같은 값을 넣어 보냄
        body: 'supplementId=' + supplementId
    })
        .then(res => res.json())
        .then(data => {
            if (data.status === 'liked') {
                btn.classList.add('liked'); // 하트 색상 칠하기
                btn.setAttribute('aria-pressed', 'true');
                btn.setAttribute('aria-label', '영양성분 찜 취소');
            } else if (data.status === 'unliked') {
                btn.classList.remove('liked'); // 하트 색상 지우기
                btn.setAttribute('aria-pressed', 'false');
                btn.setAttribute('aria-label', '영양성분 찜하기');
            } else {
                // status가 error일 경우 경고창
                alert(data.message || '로그인이 필요하거나 오류가 발생했습니다.');
            }
        })
        .catch(err => {
            console.error('좋아요 비동기 통신 오류:', err);
            alert('찜 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        })
        .finally(() => {
            btn.disabled = false;
        });
}

// 리스트 보여주는 효과...
document.addEventListener("DOMContentLoaded", function() {
    const cards = document.querySelectorAll('.supp-wrap');
    cards.forEach((card, index) => {
        // 각 카드마다 0.05초씩 딜레이를 주어 물결처럼 나타나게 처리
        card.style.animationDelay = (index * 0.08) + 's';
    });
});
