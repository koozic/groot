package com.groot.app.product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ProductDetailC", value = "/product-detail")
public class ProductDetailC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        //일
        ProductDAO.PDAO.showProductDetail(request);
        ProductDAO.PDAO.getNutrientInfo(request);

        // 🌟 무영님 파트: 페이지 넘어가기 전에 리뷰 통계(별점/개수) 싹 다 계산해서 가방에 담아두기!
        int productId = Integer.parseInt(request.getParameter("id"));
        com.groot.app.review.ReviewDAO.getReviewStats(request, productId);
// 🌟 추가! 포토 리뷰 갤러리용 데이터도 가방에 담아주기!
        request.setAttribute("allPhotoImages", com.groot.app.review.ReviewDAO.RDAO.getAllPhotoImages(productId));


//        request.getRequestDispatcher("product/product_detail.jsp").forward(request, response);

        // 변경된 코드 (수정 후)
// 1. index.jsp의 <jsp:include> 영역에 삽입될 타겟 JSP 경로 지정
        request.setAttribute("content", "product/product_detail.jsp");

// 2. UI 처리를 위한 activeTab 플래그 전달 (선택 사항이나 권장됨)
        request.setAttribute("activeTab", "product");

// 3. 최종적으로 레이아웃 템플릿인 index.jsp로 포워딩
        request.getRequestDispatcher("index.jsp").forward(request, response);

    }


    public void destroy() {
    }
}