<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>영양성분 상세정보</title>
    <style>
        /* 전체 컨테이너: 화면 중앙 정렬 */
        .detail-wrapper { display: flex; flex-direction: column; align-items: center; margin-top: 40px; padding-bottom: 50px; }

        /* 상세 박스: Movie 스타일의 테두리와 그림자 */
        .supp-detail-box {
            width: 700px;
            border: 1px solid #ddd;
            padding: 30px;
            border-radius: 15px;
            background-color: #ffffff;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        /* 이미지 영역: Movie의 포스터 이미지 스타일 */
        .detail-img-area { text-align: center; margin-bottom: 30px; }
        .detail-img-area img {
            max-width: 100%;
            height: 350px;
            object-fit: cover;
            border-radius: 10px;
            border: 1px solid #eee;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        /* 행(Row) 구조: Movie의 col-1, col-2 스타일 계승 */
        .detail-row { display: flex; border-bottom: 1px solid #f5f5f5; padding: 15px 0; align-items: flex-start; }
        .detail-row:last-child { border-bottom: none; }

        .col-1 { width: 150px; font-weight: bold; color: #2c3e50; font-size: 1.05em; } /* 아이콘과 라벨 */
        .col-2 { flex: 1; color: #34495e; line-height: 1.6; font-size: 1.05em; } /* 실제 내용 */

        /* 제목 스타일 */
        .detail-title { text-align: center; font-size: 2em; color: #333; margin-bottom: 30px; border-bottom: 2px solid #4CAF50; display: inline-block; padding-bottom: 10px; }

        /* 버튼 스타일 */
        .btn-group { margin-top: 30px; text-align: center; }
        .btn-list { padding: 12px 30px; background-color: #4CAF50; color: white; border: none; cursor: pointer; border-radius: 5px; font-weight: bold; font-size: 1em; transition: background 0.3s; }
        .btn-list:hover { background-color: #45a049; }
    </style>
</head>

<body>

<div class="detail-wrapper">
    <h1 class="detail-title">- Supplement Detail -</h1>

    <div class="supp-detail-box">

        <div class="detail-img-area">
            <img src="/supplementImg/supplementImgFile/${detailSupp.supplementImagePath}" alt="${detailSupp.supplementName}">
        </div>

        <div class="detail-row">
            <div class="col-1">🆔 No.</div>
            <div class="col-2">${detailSupp.supplementId}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">🏷️ Name.</div>
            <div class="col-2" style="font-size: 1.3em; font-weight: bold; color: #4CAF50;">${detailSupp.supplementName}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">✨ Efficacy.</div>
            <div class="col-2">${detailSupp.supplementEfficacy}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">💊 Dosage.</div>
            <div class="col-2">${detailSupp.supplementDosage}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">⏰ Timing.</div>
            <div class="col-2">${detailSupp.supplementTiming}</div>
        </div>

        <div class="detail-row">
            <div class="col-1">⚠️ Caution.</div>
            <div class="col-2">${detailSupp.supplementCaution}</div>
        </div>

    </div>

    <div class="btn-group">
        <button class="btn-list" onclick="location.href='supplements'">목록으로 돌아가기</button>
        <button class="supp-btn" onclick="updateSupplement('${supp.supplementId}')">수정</button>

    </div>
</div>

</body>
</html>

</body>

<script>
    function updateSupplement(id) {
        let ok = confirm('정말로 이 영양성분 정보를 수정하시겠습니까?');
        if (ok) {
            // 사용자가 '확인'을 누르면 수정 서블릿으로 요청을 보냄
            location.href = 'updateSupplement?id=' + id;
        }
    }
</script>

</html>
