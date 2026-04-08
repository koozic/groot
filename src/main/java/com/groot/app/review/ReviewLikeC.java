package com.groot.app.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ReviewLikeC", value = "/review-like")
public class ReviewLikeC extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. DAO야, 파라미터든 DB든 네가 알아서 다 하고 결과 숫자만 가져와!
        int finalLikeCount = ReviewDAO.RDAO.toggleReviewLike(request);

        // 2. 브라우저한테 데이터(숫자) 쏴주기
        response.setContentType("text/plain; charset=UTF-8");
        response.getWriter().write(String.valueOf(finalLikeCount));
    }
}