<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <link rel="stylesheet" href="css/supplements.css">
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
