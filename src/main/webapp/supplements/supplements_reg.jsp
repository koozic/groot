<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <style>
        .reg-container {
            margin: 40px auto; /* 가운데 정렬 */
            padding: 20px;
            border: 2px solid #eee;
            border-radius: 8px;
            width: 90%;
            max-width: 500px;
            background-color: #fafafa;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .form-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .submit-btn {
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            margin-top: 10px;
        }
        .submit-btn:hover {
            background-color: #45a049;
        }

        /* 🪄 모바일 화면(768px 이하)일 때 여백 살짝 줄여주기 */
        @media (max-width: 768px) {
            .reg-container {
                margin: 20px auto; /* 위아래 여백을 살짝 줄여서 화면을 넓게 씁니다 */
                padding: 15px;
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
            <input type="text" name="supplementName" class="form-input" required>
        </div>

        <div class="form-group">
            <label class="form-label">효능 (줄바꿈 가능)</label>
            <textarea name="supplementEfficacy" rows="3" class="form-input" required></textarea>
        </div>

        <div class="form-group">
            <label class="form-label">권장 복용량</label>
            <input type="text" name="supplementDosage" class="form-input">
        </div>

        <div class="form-group">
            <label class="form-label">복용 시간</label>
            <input type="text" name="supplementTiming" class="form-input">
        </div>

        <div class="form-group">
            <label class="form-label">주의사항</label>
            <textarea name="supplementCaution" rows="2" class="form-input"></textarea>
        </div>

        <div class="form-group">
            <label class="form-label">이미지 사진 첨부</label>
            <input type="file" name="supplementFile" accept="image/*" class="form-input" style="border: none; padding: 0;">
        </div>

        <button type="submit" class="submit-btn">등록하기</button>
        <button class="submit-btn" onclick="location.href='supplements'">목록으로 돌아가기</button>
    </form>
</div>

</body>
</html>
