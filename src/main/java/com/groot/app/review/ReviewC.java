package com.groot.app.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ReviewC", value = "/review")
public class ReviewC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 1. DAO야, 데이터 가방에 담아놔! 다 보여주는일
        ReviewDAO.RDAO.getAllReview(request);

        // 2. 🌟 index.jsp의 가운데 구멍(${content})에 끼워넣을 페이지 경로 설정

        request.setAttribute("content", "review/review.jsp");

        // 3. 🌟 review.jsp가 아니라 index.jsp로 포워딩!
        request.getRequestDispatcher("index.jsp").forward(request, response);

    }

    public void destroy() {
    }
}