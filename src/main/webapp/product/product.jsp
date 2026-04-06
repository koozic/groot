<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>제품 상세 페이지</title>

</head>
<body>
<div class="product-container">
    <c:forEach items="${products}" var="product">

        <div class="product-card">
            <div class="product-image">${product.img}이미지 영역</div>
            <div class="product-info">
                <div class="product-name">${product.name}</div>
                <div class="product-brand">${product.brand}</div>
                <div class="product-nutrient">${product.nutrient}</div>
                <div class="product-price">${product.price}원</div>
                <div class="product-date">${product.date}</div>
            </div>
        </div>

        <div class="product-card">
            <div class="product-image">이미지 영역</div>
            <div class="product-info">
                <div class="product-name">${product.name}</div>
                <div class="product-brand">${product.brand}</div>
                <div class="product-nutrient">${product.nutrient}</div>
                <div class="product-price">${product.price}원</div>
                <div class="product-date">${product.date}</div>
            </div>
        </div>

    </c:forEach>
</div>

</body>


</html>




