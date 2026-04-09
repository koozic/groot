package com.groot.app.main;

import com.groot.app.review.ReviewDAO;
import com.groot.app.review.ReviewDTO;

import java.io.*;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@WebServlet(name = "helloServlet", value = "/hello-servlet")
public class HelloServlet extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // 🌟 [무영] DAO에서 베스트 리뷰 4개 가져와서 가방(request)에 담기!
        ArrayList<ReviewDTO> bestReviews = ReviewDAO.RDAO.getBestReviews();
        request.setAttribute("bestReviews", bestReviews);


        // HomeServlet.java 예시
        request.setAttribute("content", "views/home.jsp");
        request.setAttribute("activeTab", "home");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    public void destroy() {
    }
}