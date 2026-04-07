package com.groot.app.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

// 🌟 JS 파일에서 fetch('/review-delete?review_id=번호')로 보낸 걸 여기서 받아!
@WebServlet("/review-delete")
public class ReviewDeleteC extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. 지울 리뷰 번호 꺼내기
        int reviewId = Integer.parseInt(request.getParameter("review_id"));

        // 2. DAO 출동시켜서 지우기
        boolean isDeleted = ReviewDAO.RDAO.deleteReview(reviewId);

        // 3. 결과를 다시 JS(화면)로 돌려주기 (Ajax 응답)
        // 지워졌으면 "1", 실패했으면 "0"을 보낸다!
        response.getWriter().print(isDeleted ? "1" : "0");
    }
}