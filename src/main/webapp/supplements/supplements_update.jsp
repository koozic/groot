<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>영양성분 정보 수정</title>
    <style>
        /* 1. 전체 감싸는 영역 (update-wrapper로 이름 변경) */
        .update-wrapper { display: flex; flex-direction: column; align-items: center; margin-top: 40px; padding-bottom: 50px; }

        /* 2. 하얀색 예쁜 폼 박스 (supp-update-box로 이름 변경) */
        .supp-update-box { width: 700px; border: 1px solid #ddd; padding: 30px; border-radius: 15px; background-color: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 20px; }

        /* 이미지 영역 */
        .detail-img-area { text-align: center; margin-bottom: 30px; }
        .detail-img-area img { max-width: 100%; height: 350px; object-fit: cover; border-radius: 10px; border: 1px solid #eee; margin-bottom: 15px; }

        /* 좌우 정렬 폼 그룹 */
        .form-group { display: flex; border-bottom: 1px solid #f5f5f5; padding: 15px 0; align-items: flex-start; }
        .form-group:last-child { border-bottom: none; }
        .col-1 { width: 150px; font-weight: bold; color: #2c3e50; font-size: 1.05em; padding-top: 5px; }
        .col-2 { flex: 1; }

        /* 입력 칸 디자인 */
        .update-input { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px; font-size: 1em; font-family: inherit; }
        .update-textarea { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px; font-size: 1em; font-family: inherit; height: 80px; resize: vertical; }

        /* 제목 및 버튼 영역 */
        .detail-title { text-align: center; font-size: 2em; color: #333; margin-bottom: 30px; border-bottom: 2px solid #4CAF50; display: inline-block; padding-bottom: 10px; }
        .btn-group { margin-top: 15px; text-align: center; display: flex; gap: 10px; justify-content: center; }

        /* 버튼 디자인 */
        .btn-submit { padding: 12px 30px; background-color: #4CAF50; color: white; border: none; cursor: pointer; border-radius: 5px; font-weight: bold; font-size: 1em; }
        .btn-cancel, .btn-list { padding: 12px 30px; background-color: #95a5a6; color: white; border: none; cursor: pointer; border-radius: 5px; font-weight: bold; font-size: 1em; }

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

<div class="update-wrapper">
<h1 class="detail-title">- 영양성분 정보 수정 -</h1>
    <form action="updateSupplement" method="post" enctype="multipart/form-data">

        <%-- hidden하는 이유! --%>
        <input type="hidden" name="supplementId" value="${detailSupp.supplementId}">
        <input type="hidden" name="oldSupplementFile" value="${detailSupp.supplementImagePath}">

    <div class="supp-update-box">
        <div class="detail-img-area">
            <img src="/supplementImg/supplementImgFile/${detailSupp.supplementImagePath}" alt="${detailSupp.supplementName}">
            <br>
            <span style="font-weight: bold; color: #e74c3c;">사진 변경 (선택): </span>
            <input type="file" name="supplementFile" style="margin-top: 10px;">
        </div>

        <%-- 자바에서 getParameter("supplementName")라고 부를 수 있는 유일한 이유가 바로
        JSP 파일의 input 태그에 name="supplementName"이라고 적어두었기 때문 --%>

        <div class="form-group">
            <div class="col-1">🆔 No.</div>
            <div class="col-2" style="padding-top: 5px; color: #7f8c8d;">${detailSupp.supplementId}</div>
        </div>

        <div class="form-group">
            <div class="col-1">🏷️ Name.</div>
            <div class="col-2">
            <input type="text" name="supplementName" class="update-input" value="${detailSupp.supplementName}">
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">✨ Efficacy.</div>
            <div class="col-2">
            <textarea name="supplementEfficacy" class="update-textarea">${detailSupp.supplementEfficacy}</textarea>
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">💊 Dosage.</div>
            <div class="col-2">
                <input type="text" name="supplementDosage" class="update-input" value="${detailSupp.supplementDosage}">
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">⏰ Timing.</div>
            <div class="col-2">
                <input type="text" name="supplementTiming" class="update-input" value="${detailSupp.supplementTiming}">
            </div>
        </div>

        <div class="form-group">
            <div class="col-1">⚠️ Caution.</div>
            <div class="col-2">
                <textarea name="supplementCaution" class="update-textarea">${detailSupp.supplementCaution}</textarea>
            </div>
        </div>

    </div>

    <%-- <form> 태그 안에 있는 <button>은 type="button"을 명시하지 않으면
    무조건 제출(Submit) 버튼으로 작동합니다.
    그래서 "목록으로 돌아가기" 버튼에 type="button"을 안 적어주면,
    목록으로 안 가고 냅다 수정을 진행해 버릴 수 있습니다.--%>
    <div class="btn-group">
        <button type="button" class="btn-list" onclick="location.href='supplements'">목록으로 돌아가기</button>
    </div>

    <div class="btn-group">
        <button type="submit" class="btn-submit">수정 완료</button>
        <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
    </div>
    </form>
</div>

</body>
</html>
