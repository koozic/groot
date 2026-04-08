let currentBodyId = null;
let currentSort = "recent"; // ✅ 기본값을 'recent'로 설정해서 에러 방지

// 1. 서버에서 데이터를 가져오는 함수
function loadSupplements(bodyId, sortType = 'recent') {

    // ✅ [수정 1] 함수 인자로 받은 bodyId가 있는지 먼저 확인
    if (!bodyId) {
        // 만약 정렬 버튼을 눌러서 호출된 거라면 기존에 저장된 ID 사용
        bodyId = currentBodyId;
    }


    // ✅ [수정 2] 여전히 bodyId가 없다면(처음부터 안 눌렀다면) 중단
    if (!bodyId) {
        console.warn("신체 부위 ID가 없습니다. 버튼을 먼저 눌러주세요.");
        return;
    }

    currentBodyId = bodyId;
    currentSort = sortType;

    // ✅ [수정 3] URL 생성 (변수가 비어있지 않은지 확인)
    const url = `body?action=supps&bodyId=${currentBodyId}&sort=${currentSort}`;

    console.log("요청 전송 주소:", url);

    fetch(url)
        .then(res => {
            // if (!res.ok) {
            //     // 400 에러 등이 여기서 잡힙니다.
            //     throw new Error(`서버 응답 에러: ${res.status}`);
            // }
            return res.json();
        })
        .then(data => {
            console.log("받은 데이터:", data);
            renderList(data);
        })
        .catch(err => {
            console.error("로딩 실패:", err);
            document.getElementById("result").innerHTML =
                `<p style='color:red;'>데이터 로딩 실패: ${err.message}</p>`;
        });
}

// 2. 받은 데이터를 화면에 그려주는 함수 (이게 꼭 있어야 목록이 보입니다!)
function renderList(list) {
    const container = document.getElementById("result");
    document.getElementById("sort-section").style.display = "block";

    if (!list || list.length === 0) {
        container.innerHTML = "<p>해당 부위에 등록된 영양소가 없습니다.</p>";
        return;
    }

    let html = "";
    list.forEach(s => {
        html += `
                <div style="border:1px solid #eee; margin:10px; padding:15px;
                            border-radius:10px; display:inline-block;
                            width:200px; text-align:center; vertical-align:top;">
                    <img src="${s.supplementImagePath}"
                         width="120"
                         style="border-radius:5px;"
                         >
                    <br>
                    <strong>${s.supplementName}</strong>
                    <p style="color:#666; font-size:0.9em;">${s.supplementEfficacy}</p>
                    <p style="color:#999; font-size:0.85em;">
                        👁️ ${s.supplementViewCount} &nbsp; ❤️ ${s.likeCount}
                    </p>
<!--                    <p style="color:#bbb; font-size:0.8em;">등록일: ${s.supplementRegDate}</p>-->
                    <button onclick="goDetail(${s.supplementId})"
                            style="cursor:pointer; padding:5px 10px;">
                        상세보기
                    </button>
                </div>
            `;
    });

    container.innerHTML = html;
}

// 3. 정렬 변경 함수
function changeSort(sort) {
    if (!currentBodyId) {
        alert("먼저 신체 부위를 선택해주세요!");
        return;
    }
    loadSupplements(currentBodyId, sort);
}

// 4. 상세 페이지 이동 함수
function goDetail(id) {
    location.href = `body?action=detail&suppId=${id}`;
}