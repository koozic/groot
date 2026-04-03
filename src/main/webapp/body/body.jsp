<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>신체 선택</title>

    <script>
        // 🔥 현재 선택 상태 저장
        let currentBodyId = null;
        let currentSort = "view";

        // 🔥 신체 클릭 시 실행
        function loadSupplements(bodyId) {
            currentBodyId = bodyId;

            fetch(`/supplement/ajax?bodyId=${bodyId}&sort=${currentSort}`)
                .then(res => res.json())
                .then(data => renderList(data));
        }

        // 🔥 정렬 변경
        function changeSort(sort) {
            currentSort = sort;

            if (currentBodyId != null) {
                loadSupplements(currentBodyId);
            }
        }

        // 🔥 화면에 리스트 그리기
        function renderList(list) {

            const container = document.getElementById("result");

            let html = "";

            list.forEach(s => {
                html += `
                    <div style="border:1px solid #ccc; margin:10px; padding:10px;">
                        <img src="${s.image}" width="100">
                        <p>${s.name}</p>
                        <p>조회수: ${s.viewCount}</p>
                        <p>좋아요: ${s.likeCount}</p>

                        <a href="/supplement/detail?id=${s.id}">
                            상세보기
                        </a>
                    </div>
                `;
            });

            container.innerHTML = html;
        }
    </script>
</head>

<body>

<h2>신체 부위 선택</h2>

<!-- 🔥 신체 클릭 -->
<button onclick="loadSupplements(1)">눈</button>
<button onclick="loadSupplements(2)">간</button>
<button onclick="loadSupplements(3)">피로</button>

<hr>

<!-- 🔥 정렬 -->
<button onclick="changeSort('view')">조회순</button>
<button onclick="changeSort('like')">좋아요순</button>

<hr>

<!-- 🔥 결과 출력 영역 -->
<div id="result">
    <p>신체 부위를 선택하세요</p>
</div>

</body>
</html>