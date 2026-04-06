package com.groot.app.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ReviewC", value = "/review")
public class ReviewC extends HttpServlet {

    // ReviewC.java doGet 메서드 수정
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // 1. URL 파라미터에서 상품 번호(PRODUCT_ID) 꺼내기
        String pIdStr = request.getParameter("PRODUCT_ID");
        int pId = Integer.parseInt(pIdStr); // 숫자로 변환

        // 2. DAO가 전체 리뷰 리스트 가져오게 시킴
        ReviewDAO.RDAO.getAllReview(request);

        // 3. 🌟 무영이가 만든 무적의 통계 메서드 호출! (101 대신 변수 pId 넣기)
        ReviewDAO.getReviewStats(request, pId);

        // 4. 페이지 이동
        request.setAttribute("content", "review/review.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}