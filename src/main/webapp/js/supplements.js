console.log('connected..')

const modal = document.getElementById('commonModal');
const content = document.getElementById('modalContent');

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

}
