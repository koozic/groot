<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>제품 상세 페이지</title>
    <link rel="stylesheet" href="css/product.css">
</head>
<body>
<div class="product-container">
    <c:forEach items="${products}" var="p">

        <div class="product-card">
            <div class="product-image">이미지 영역</div>
            <div class="product-info">
                <div class="product-name">${p.productName}</div>
                <div class="product-brand">${p.productBrand}</div>
                <div class="product-nutrient">${p.productNutrient}</div>
                <div class="product-price">${p.productPrice}원</div>
                <div class="product-date">${p.productStartDate}</div>
            </div>
        </div>

    </c:forEach>
</div>

</body>


</html>




