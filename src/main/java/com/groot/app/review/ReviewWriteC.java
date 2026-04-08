package com.groot.app.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ReviewWriteC", value = "/review-write")
public class ReviewWriteC extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. 주방장(DAO)한테 박스 통째로 넘기기 (여기서 언박싱이랑 DB 저장이 싹 다 일어남!)
        ReviewDAO.RDAO.insertReview(request);

        // 2. 🌟 쌤의 핵심 비법! 
        // 주방장이 언박싱해서 request 가방에 다시 넣어둔 상품 번호를 꺼냄!
        // (setAttribute로 넣었으니까 getAttribute로 빼고, Object 타입이니까 String으로 변환)
        String productId = (String) request.getAttribute("p_id");

        // 3. 원래 리뷰 페이지로 튕겨내기 (컨트롤러 끝!)
        response.sendRedirect("review?PRODUCT_ID=" + productId);
    }
}