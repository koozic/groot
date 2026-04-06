<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Groot - 리뷰 작성하기</title>
    <style>
        /* 깔끔하게 보이려고 넣은 간단한 디자인 */
        .write-box { width: 500px; margin: 40px auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 8px; }
        .form-group input[type="text"], .form-group textarea { width: 100%; padding: 10px; box-sizing: border-box; }
        .star-radio { display: flex; gap: 15px; }
        .btn-submit { width: 100%; padding: 12px; background-color: #2ecc71; color: white; border: none; font-size: 16px; border-radius: 5px; cursor: pointer; }
        .btn-submit:hover { background-color: #27ae60; }
    </style>
</head>
<body>

<div class="write-box">
    <h2>✍️ 솔직한 리뷰를 작성해주세요!</h2>
    <hr>

    <%-- 🌟 핵심 1: action="ReviewWriteC" (데이터를 받을 컨트롤러 이름) --%>
    <%-- 🌟 핵심 2: method="post" (데이터가 많고 길 때는 무조건 post) --%>
    <%-- 🌟 핵심 3: enctype="multipart/form-data" (사진 업로드할 때 이거 없으면 에러남!!!) --%>
    <form action="review-write" method="post" enctype="multipart/form-data">

        <%-- 몰래 숨겨서 보내는 데이터 (어떤 상품의 리뷰인지 알아야 하니까!) --%>
        <%-- 일단 무영이가 테스트하기 쉽게 value="101" 로 고정해둘게. 나중에 합칠 때 바꿀 거야. --%>
        <input type="hidden" name="product_id" value="101">

        <div class="form-group">
            <label>리뷰 제목</label>
            <input type="text" name="r_title" required placeholder="핵심만 짧게 적어주세요!">
        </div>

        <div class="form-group">
            <label>별점 선택 (1~5점)</label>
            <div class="star-radio">
                <label><input type="radio" name="r_score" value="1"> 1점</label>
                <label><input type="radio" name="r_score" value="2"> 2점</label>
                <label><input type="radio" name="r_score" value="3"> 3점</label>
                <label><input type="radio" name="r_score" value="4"> 4점</label>
                <label><input type="radio" name="r_score" value="5" checked> 5점</label> </div>
        </div>

        <div class="form-group">
            <label>리뷰 내용</label>
            <textarea name="r_content" rows="6" required placeholder="상품을 사용해 본 솔직한 후기를 남겨주세요."></textarea>
        </div>

        <div class="form-group">
            <label>사진 첨부 (선택)</label>
            <%-- type="file"을 쓰면 브라우저가 알아서 '파일 선택' 버튼을 만들어줘! --%>
            <input type="file" name="r_img" accept="image/*">
        </div>

        <button type="submit" class="btn-submit">🚀 리뷰 등록하기</button>
    </form>
</div>

</body>
</html>