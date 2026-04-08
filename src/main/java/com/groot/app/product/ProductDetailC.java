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


        request.getRequestDispatcher("product/product_detail.jsp").forward(request, response);

    }




    public void destroy() {
    }
}