<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- index.jsp include 구조 — html/head/body 없음 --%>

<style>
    /* ── 전체 컨테이너 ── */
    .select-container {
        display: flex;
        justify-content: center;
        align-items: stretch; /* 두 박스 높이 통일 */
        gap: 32px;
        margin-top: 80px;
        padding: 0 24px 40px;
        flex-wrap: wrap; /* 공간 부족하면 자동 줄바꿈 */
    }

    /* ── 카드 박스 ── */
    .select-box {
        width: 280px;
        min-width: 200px; /* 최소 너비 보장 */
        padding: 40px 30px;
        border: 2px solid #eee;
        border-radius: 20px;
        text-align: center;
        cursor: pointer;
        transition: border-color 0.3s, transform 0.3s, box-shadow 0.3s;
        background: #fff;
    }

    .select-box:hover {
        border-color: #4CAF50;
        transform: translateY(-8px);
        box-shadow: 0 12px 28px rgba(76, 175, 80, 0.15);
    }

    .select-box h2 {
        color: #333;
        font-size: 1.25em;
        margin-bottom: 12px;
        word-break: keep-all; /* 글자 중간에서 안 잘림 */
    }

    .select-box p {
        color: #666;
        font-size: 0.92em;
        line-height: 1.7;
        word-break: keep-all;
    }

    /* ── 웹에서 창 좁아지면 (700px 이하) 세로 정렬 ── */
    @media (max-width: 700px) {
        .select-container {
            flex-direction: column; /* 세로 배치 */
            align-items: center;
            gap: 20px;
            margin-top: 40px;
            padding: 0 20px 40px;
        }

        .select-box {
            width: 100%;
            max-width: 400px; /* 너무 넓어지지 않게 */
            padding: 28px 24px;
        }

        .select-box:hover {
            transform: translateY(-4px);
        }
    }

    /* ── 모바일 (480px 이하) ── */
    @media (max-width: 480px) {
        .select-container {
            margin-top: 24px;
            gap: 16px;
            padding: 0 16px 32px;
        }

        .select-box {
            padding: 24px 20px;
            border-radius: 14px;
        }

        .select-box h2 {
            font-size: 1.1em;
        }

        .select-box p {
            font-size: 0.88em;
        }
    }
</style>

<div class="select-container">
    <div class="select-box" onclick="location.href='body_view'">
        <h2>👤 신체별 추천</h2>
        <p>눈, 간, 피부 등 아픈 부위에<br>딱 맞는 영양소를 찾아보세요.</p>
    </div>

    <div class="select-box" onclick="location.href='curation_view'">
        <h2>🤖 AI 테마 추천</h2>
        <p>수험생, 임산부 등 상황에 맞는<br>최적의 조합을 AI가 추천합니다.</p>
    </div>
</div>