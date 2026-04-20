<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/curation.css">

<div class="curation-layout">

    <%-- 왼쪽 카테고리 사이드바 --%>
    <div class="curation-sidebar">
        <div class="curation-sidebar-title">큐레이션</div>
        <button class="curation-cat-btn" onclick="selectCategory(this, '임산부')">임산부 맞춤 영양 케어</button>
        <button class="curation-cat-btn" onclick="selectCategory(this, '노년층')">시니어 건강 관리</button>
        <button class="curation-cat-btn" onclick="selectCategory(this, '수험생')">수험생 집중력 영양</button>
        <button class="curation-cat-btn" onclick="selectCategory(this, '직장인')">직장인 피로 회복 관리</button>
        <button class="curation-cat-btn" onclick="selectCategory(this, '운동하는 사람')">운동 맞춤 퍼포먼스 케어</button>
        <button class="curation-cat-btn" onclick="selectCategory(this, '다이어트')">다이어트 영양 밸런스</button>
        <button class="curation-cat-btn" onclick="selectCategory(this, '비건')">비건 맞춤 영양 보충</button>
    </div>

    <%-- 오른쪽 AI 답변 영역 --%>
    <div class="curation-content">
        <div class="curation-content-header">
            <h2 id="curationTitle">카테고리를 선택해주세요</h2>
            <p id="curationSubtitle">왼쪽 항목을 클릭하면 오터가 맞춤 영양소를 추천해드려요</p>
        </div>
        <div class="curation-answer" id="curationAnswer">
            <div class="curation-empty">
                <img class="curation-empty-otter"
                     src="${pageContext.request.contextPath}/img/ottos/lying_otter.png"
                     alt="오터">
                <span class="curation-empty-text">항목을 선택하면 추천이 시작돼요</span>
            </div>
        </div>
    </div>
</div>

<script>
    const CURATION_OTTER_IMG = '${pageContext.request.contextPath}/img/ottos/lying_otter.png';

    const CURATION_PROMPTS = {
        '임산부': '임산부에게 필요한 영양소와 영양제를 추천해줘. 각 영양소가 필요한 이유와 권장 섭취량도 알려줘.',
        '수험생': '수험생의 집중력·피로 회복에 도움되는 영양소와 영양제를 추천해줘. 이유와 복용 팁도 포함해줘.',
        '직장인': '스트레스 많은 직장인에게 필요한 영양소와 영양제를 추천해줘. 피로 해소와 면역력 위주로.',
        '운동하는 사람': '운동하는 사람의 근육 회복·체력 향상에 도움되는 영양소와 영양제를 추천해줘. 운동 전후 복용법도 알려줘.',
        '다이어트': '다이어트 중인 사람에게 필요한 영양소와 영양제를 추천해줘. 체지방 감소와 근육 유지 위주로.',
        '비건': '비건 식단에서 부족하기 쉬운 영양소와 보충제를 추천해줘. 동물성 원료 없는 제품 기준으로.',
        '노년층': '노년층의 뼈·관절·심혈관 건강에 도움되는 영양소와 영양제를 추천해줘. 주의사항도 함께 알려줘.'
    };

    let currentCategory = null;
    let isLoading = false;

    function selectCategory(btn, category) {
        if (isLoading || currentCategory === category) return;

        document.querySelectorAll('.curation-cat-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentCategory = category;

        document.getElementById('curationTitle').textContent = category + ' 맞춤 영양 케어';
        document.getElementById('curationSubtitle').textContent = 'AI 오터(Otter)가 분석한 ' + category + ' 큐레이션';

        fetchCuration(category);
    }

    function fetchCuration(category) {
        const answerEl = document.getElementById('curationAnswer');
        isLoading = true;

        answerEl.innerHTML =
            '<div class="curation-bubble-name">오터 Otter</div>' +
            '<div class="curation-loading-row">' +
            '  <div class="curation-loading-spacer"></div>' +
            '  <div class="curation-loading-bubble">' +
            '    <div class="curation-dot"></div>' +

            '    <div class="curation-dot"></div>' +
            '    <div class="curation-dot"></div>' +
            '  </div>' +
            '</div>';

        const prompt = CURATION_PROMPTS[category] || (category + '에게 맞는 영양소와 영양제를 추천해줘.');

        const eventSource = new EventSource(
            "http://10.1.82.100:80/chat/stream?q=" + encodeURIComponent(prompt)
        );

        eventSource.onmessage = (event) => {
            console.log(event.data);
        };

        eventSource.onerror = () => {
            eventSource.close();
        };
        // fetch('http://10.1.82.100/chat3', {   // ← 실제 엔드포인트로 수정
        //     method: 'POST',
        //     headers: {'Content-Type': 'application/json'},
        //     body: JSON.stringify({message: prompt})
        // })
        //     .then(res => {
        //         if (!res.ok) throw new Error('서버 오류: ' + res.status);
        //         return res.json();
        //     })
        //     .then(data => {
        //         const text = data.response || data.answer || data.content || data.text || JSON.stringify(data);
        //         answerEl.innerHTML =
        //             '<div class="curation-bubble-name">오터케어 AI</div>' +
        //             '<div class="curation-otter-row">' +
        //             '  <img class="curation-otter-img" src="' + CURATION_OTTER_IMG + '" alt="오터">' +
        //             '  <div class="curation-bubble">' + escapeHtml(text) + '</div>' +
        //             '</div>';
        //     })
        //     .catch(err => {
        //         answerEl.innerHTML =
        //             '<div class="curation-bubble-name">오터케어 AI</div>' +
        //             '<div class="curation-otter-row">' +
        //             '  <img class="curation-otter-img" src="' + CURATION_OTTER_IMG + '" alt="오터">' +
        //             '  <div class="curation-error">오류가 발생했어요 ' + err.message + '</div>' +
        //             '</div>';
        //     })
        //     .finally(() => {
        //         isLoading = false;
        //     });
    }

    function escapeHtml(str) {
        return str
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/\n/g, '<br>');
    }
</script>