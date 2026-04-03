
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>

    <link rel="stylesheet" href="css/product.css">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
</head>
<body>

<header class="top-nav">
    <button class="back-btn">이전</button>
    <div class="header-title">제품 정보</div>
</header>

<main class="container">
    <section class="image-section">
        <img src="https://via.placeholder.com/400x400" alt="제품 이미지" class="product-img">
    </section>

    <section class="info-section">
        <p class="brand-name">제조사: [product_brand]</p>
        <h1 class="product-title">[product_name]</h1>
        <div class="price-container">
            <span class="price">[product_price]</span><span class="unit">원</span>
        </div>
    </section>

    <hr class="divider">

    <section class="dosage-section">
        <h3>복용 가이드</h3>
        <div class="dosage-grid">
            <div class="dosage-item">
                <span class="label">총 용량</span>
                <span class="value">[product_total]정</span>
            </div>
            <div class="dosage-item">
                <span class="label">1회 섭취</span>
                <span class="value">[product_serve]정</span>
            </div>
            <div class="dosage-item">
                <span class="label">1일 횟수</span>
                <span class="value">[product_per_day]회</span>
            </div>
        </div>
        <p class="time-info"><strong>복용 시점:</strong> [product_time_info]</p>
    </section>

    <hr class="divider">

    <section class="description-section">
        <h3>제품 설명</h3>
        <p class="description-text">
            [product_description] <br>
            영양소 식별 번호: [product_nutrient]
        </p>
    </section>

    <section class="status-section">
        <div class="status-box">
            <p>복용 시작일: [product_start_date]</p>
            <p>현재 잔여량: <strong>[product_current]</strong> / [product_total]정</p>
        </div>
    </section>
</main>






<div>review 부분</div>








</body>
</html>
