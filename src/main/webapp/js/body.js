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
                        width:200px; text-align:center; vertical-align:top; position:relative;">
                
                
                <img src="${s.supplementImagePath}"  width="120" style="border-radius:5px;"
                 onerror="this.onerror=null; this.src='images/default.png';">
                <br>
                <strong>${s.supplementName}</strong>
                <p style="color:#666; font-size:0.9em;">${s.supplementEfficacy}</p>
                <p style="color:#999; font-size:0.85em;">
                    👁️ ${s.supplementViewCount} &nbsp; ❤️ ${s.likeCount}
                </p>

                <button onclick="goDetail(${s.supplementId})"
                        style="cursor:pointer; padding:5px 10px; margin-bottom:5px;">
                    상세보기
                </button>

                ${isAdmin ? `
                    <div style="margin-top:10px; border-top:1px dashed #ccc; padding-top:10px;">
                        <button onclick="location.href='admin?action=form&suppId=${s.supplementId}'" 
                                style="background:#2196F3; color:white; border:none; padding:5px 10px; border-radius:3px; cursor:pointer; font-size:0.8em;">
                            수정
                        </button>
                        <button onclick="adminDelete(${s.supplementId}, '${s.supplementName}')" 
                                style="background:#f44336; color:white; border:none; padding:5px 10px; border-radius:3px; cursor:pointer; font-size:0.8em; margin-left:5px;">
                            삭제
                        </button>
                    </div>
                ` : ''}
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

// 관리자 전용 삭제 함수
function adminDelete(id, name) {
    if (confirm(`[관리자 권한] '${name}' 영양제를 정말 삭제하시겠습니까?\n삭제 후에는 복구가 불가능합니다.`)) {
        // 자바스크립트로 가상의 form을 만들어 POST 요청을 보냅니다.
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'admin'; // AdminC 서블릿으로 전송

        // action 파라미터 (delete)
        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'delete';

        // 삭제할 영양소 ID
        const idInput = document.createElement('input');
        idInput.type = 'hidden';
        idInput.name = 'suppId';
        idInput.value = id;

        form.appendChild(actionInput);
        form.appendChild(idInput);
        document.body.appendChild(form);

        form.submit();
    }
}