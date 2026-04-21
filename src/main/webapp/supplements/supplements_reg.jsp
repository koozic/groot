<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <style>
            /* ==================================================
               1. 전체 컨테이너 설정
               ================================================== */
        .reg-container {
            margin: 40px auto; /* 화면 중앙 정렬 */
            padding: 30px;     /* 안쪽 여백을 살짝 늘려 답답하지 않게 조절 */
            border: 2px solid #eee;
            border-radius: 8px;
            width: 90%;
            max-width: 550px;  /* 가로로 배치할 공간 확보를 위해 살짝 넓힘 */
            background-color: #fafafa;
        }

        /* ==================================================
           2. 폼 그룹 (라벨과 입력칸 가로 배치 🌟)
           ================================================== */
        .form-group {
            display: flex;
            align-items: center; /* 글자와 입력칸의 세로 높이를 중앙으로 맞춤 */
            gap: 20px;           /* 라벨과 입력칸 사이의 간격 (조절 가능) */
            margin-bottom: 15px;
        }

        /* ==================================================
           3. 라벨 설정 (크기 고정 및 줄바꿈 방지)
           ================================================== */
        .form-label {
            font-weight: bold;
            margin-bottom: 0;    /* 가로 배치이므로 하단 여백 제거 */
            white-space: nowrap; /* 글자가 두 줄로 찌그러지지 않게 방어 */
            width: 110px;        /* 모든 라벨의 가로 너비를 똑같이 맞춰 깔끔하게 정렬 */
            flex-shrink: 0;      /* 화면이 줄어들어도 라벨 크기 유지 */
            color: #333;
        }

        /* ==================================================
           4. 입력칸 설정 (빈 공간 꽉 채우기)
           ================================================== */
        .form-input {
            flex: 1;             /* 라벨이 차지하고 남은 공간을 모두 차지함 */
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            font-family: inherit;
            font-size: 1em;
        }

        /* 파일 첨부 버튼은 겉에 테두리가 없어야 예쁘므로 예외 처리 */
        input[type="file"].form-input {
            padding: 0;
            border: none;
            background: transparent;
        }

        /* ==================================================
           5. 하단 버튼 설정
           ================================================== */
        .submit-btn {
            width: 100%;
            padding: 12px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 1.05em;
            font-weight: bold;
            cursor: pointer;
            margin-top: 10px;
            transition: background-color 0.2s;
        }

        .submit-btn:hover {
            background-color: #45a049;
        }

        /* ==================================================
           6. 📱 모바일 화면 최적화 (가로 768px 이하)
           ================================================== */
        @media (max-width: 768px) {
            .reg-container {
                margin: 20px auto;
                padding: 20px;
            }

            .form-group {
                flex-direction: column;  /* 좁은 화면에서는 다시 위아래로 줄바꿈! */
                align-items: flex-start; /* 왼쪽으로 정렬 */
                gap: 5px;                /* 라벨과 입력칸 사이 위아래 간격을 좁게 */
            }

            .form-label {
                width: auto;             /* 모바일에서는 너비 고정 해제 */
            }
        }
    </style>
</head>

<body>
<div class="reg-container">
    <h2 style="text-align: center; margin-top: 0;">새 영양성분 등록</h2>

    <form action="supplements" method="post" enctype="multipart/form-data">

        <div class="form-group">
            <label class="form-label">영양성분명</label>
            <input type="text" name="supplementName" class="form-input"
                   placeholder="예) 비타민C" required>
        </div>

        <div class="form-group">
            <label class="form-label">효능 (줄바꿈 가능)</label>
            <textarea name="supplementEfficacy" rows="3" class="form-input"
                      placeholder="예) 피로 회복에 도움" required></textarea>
        </div>

        <div class="form-group">
            <label class="form-label">권장 복용량</label>
            <input type="text" name="supplementDosage" class="form-input"
                   placeholder="예) 1일 1회 1정">
        </div>

        <div class="form-group">
            <label class="form-label">복용 시간</label>
            <input type="text" name="supplementTiming" class="form-input"
                   placeholder="예) 식후 30분">
        </div>

        <div class="form-group">
            <label class="form-label">주의사항</label>
            <textarea name="supplementCaution" rows="2" class="form-input"
                      placeholder="예) 특이체질 알레르기 주의"></textarea>
        </div>

        <div class="form-group">
            <label class="form-label">이미지 사진 첨부</label>
            <input type="file" name="supplementFile" accept="image/*" class="form-input" style="border: none; padding: 0;">
        </div>

        <button type="submit" class="submit-btn">등록하기</button>
        <%-- 💡 돌아가기 버튼은 시각적으로 덜 튀게 회색으로 처리했습니다 --%>
        <button type="button" class="submit-btn" onclick="location.href='supplements'" style="background-color: #95a5a6;">목록으로 돌아가기</button>
    </form>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const form = document.querySelector('form[action="supplements"]');
        const submitBtn = form ? form.querySelector('button[type="submit"]') : null;
        if (!form || !submitBtn) return;

        form.addEventListener('submit', function (event) {
            if (form.dataset.submitting === 'true') {
                event.preventDefault();
                return;
            }

            if (event.defaultPrevented) return;

            form.dataset.submitting = 'true';
            submitBtn.disabled = true;
            submitBtn.textContent = '등록 중...';
        });
    });
</script>
</body>
</html>
