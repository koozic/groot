<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Groot - 신체별 영양소 추천</title>

    <script>
        // 1. 초기 상태 설정
        let currentBodyId = null;
        // 기본 정렬값을 비워두면 서블릿에서 자동으로 'recent'(등록순)로 처리합니다.
        let currentSort = "";

        // 2. 신체 클릭 시 실행 (초기화 및 목록 로드)
        function loadSupplements(bodyId) {
            currentBodyId = bodyId;
            // 신체를 새로 클릭할 때는 정렬을 다시 기본값(등록순)으로 돌리고 싶다면 아래 주석 해제
            // currentSort = "";

            // 서블릿 규칙에 맞게 URL 수정: /body?action=supps&bodyId=..&sort=..
            fetch(`body?action=supps&bodyId=${bodyId}&sort=${currentSort}`)
                .then(res => res.json())
                .then(data => renderList(data))
                .catch(err => console.error("데이터 로딩 실패:", err));
        }

        // 3. 정렬 변경 (조회순 / 좋아요순 버튼 클릭 시)
        function changeSort(sort) {
            currentSort = sort;

            if (currentBodyId != null) {
                loadSupplements(currentBodyId);
            } else {
                alert("먼저 신체 부위를 선택해주세요!");
            }
        }

        // 4. 화면에 리스트 그리기 (BodyDTO 필드명에 맞춤)
        function renderList(list) {
            const container = document.getElementById("result");

            // ✅ 추가: 영양소 목록이 로드되면 정렬 버튼 표시
            document.getElementById("sort-buttons").style.display = "block";

            if (list.length === 0) {
                container.innerHTML = "<p>해당 부위에 등록된 영양소가 없습니다.</p>";
                return;
            }

            let html = "";
            list.forEach(s => {
                // Java의 BodyDTO 필드명(supplementName 등)과 일치해야 합니다.
                html += `
                    <div style="border:1px solid #eee; margin:10px; padding:15px; border-radius:10px; display:inline-block; width:200px; text-align:center;">
                        <img src="${s.supplementImagePath}" width="120" style="border-radius:5px;"><br>
                        <strong style="font-size:1.1em;">${s.supplementName}</strong>
                        <p style="color:#666; font-size:0.9em; margin:5px 0;">
                            👁️ ${s.supplementViewCount}  ❤️ ${s.likeCount}
                        </p>
                        <button onclick="goDetail(${s.supplementId})" style="cursor:pointer;">상세보기</button>
                    </div>
                `;
            });

            container.innerHTML = html;
        }

        // 상세페이지 이동 함수
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

<div id="sort-buttons" style="display: none">
    <button onclick="changeSort('view')">🔥 많이 본 순</button>
    <button onclick="changeSort('like')">❤️ 인기순</button>
</div>

<hr>

<div id="result" style="min-height: 200px;">
    <p style="color:#999;">신체 부위를 선택하면 영양소 목록이 나타납니다.</p>
</div>

</body>
</html>