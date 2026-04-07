<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Groot - 신체별 영양소 추천</title>
    <script>
        let currentBodyId = null;
        let currentSort = "";

        function loadSupplements(bodyId) {
            currentBodyId = bodyId;

            fetch(`body?action=supps&bodyId=${bodyId}&sort=${currentSort}`)
                .then(res => {
                    if (!res.ok) throw new Error("서버 오류: " + res.status);
                    return res.json();
                })
                .then(data => {
                    console.log("받은 데이터:", data); // 개발 중 확인용
                    renderList(data);
                })
                .catch(err => {
                    console.error("로딩 실패:", err);
                    document.getElementById("result").innerHTML =
                        `<p style='color:red;'>오류 발생: ${err.message}</p>`;
                });
        }

        function changeSort(sort) {
            currentSort = sort;
            if (currentBodyId != null) {
                loadSupplements(currentBodyId);
            } else {
                alert("먼저 신체 부위를 선택해주세요!");
            }
        }

        function renderList(list) {
            const container = document.getElementById("result");

            // ✅ 영양소 목록 로드 후 정렬 버튼 표시
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
                             onerror="this.src='images/default.png'">
                        <br>
                        <strong>${s.supplementName}</strong>
                        <p style="color:#666; font-size:0.9em;">${s.supplementEfficacy}</p>
                        <p style="color:#999; font-size:0.85em;">
                            👁️ ${s.supplementViewCount} &nbsp; ❤️ ${s.likeCount}
                        </p>
                        <p style="color:#bbb; font-size:0.8em;">등록일: ${s.supplementRegDate}</p>
                        <button onclick="goDetail(${s.supplementId})"
                                style="cursor:pointer; padding:5px 10px;">
                            상세보기
                        </button>
                    </div>
                `;
            });
            container.innerHTML = html;
        }

        function goDetail(id) {
            location.href = `body?action=detail&suppId=${id}`;
        }
    </script>
</head>
<body>
<h2>👤 어떤 부위가 고민이신가요?</h2>

<div id="body-buttons">
    <button onclick="loadSupplements(1)">👁️ 눈</button>
    <button onclick="loadSupplements(2)">🥩 간</button>
    <button onclick="loadSupplements(3)">💤 피로개선</button>
    <button onclick="loadSupplements(4)">🦴 뼈/관절</button>
</div>

<hr>

<%-- ✅ 처음엔 숨기고 목록 로드 후 표시 --%>
<div id="sort-section" style="display:none;">
    <button onclick="changeSort('view')">🔥 많이 본 순</button>
    <button onclick="changeSort('like')">❤️ 인기순</button>
    <hr>
</div>

<div id="result" style="min-height:200px;">
    <p style="color:#999;">신체 부위를 선택하면 영양소 목록이 나타납니다.</p>
</div>
</body>
</html>