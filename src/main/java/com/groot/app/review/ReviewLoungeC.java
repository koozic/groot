package com.groot.app.review; // 본인 패키지 경로에 맞게 놔두세요!

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/review-lounge")
public class ReviewLoungeC extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. DAO한테 "베스트 리뷰 싹 다 가져와!" 시키기
        request.setAttribute("bestReviews", ReviewDAO.RDAO.getBestReviews());

        // 2. review_lounge.jsp로 포워딩 (화면 이동)
        request.setAttribute("content", "review/review_lounge.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}