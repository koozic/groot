package com.groot.app.review;

import com.google.gson.Gson;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

// 🌟 JSP에서 fetch(`lounge-api?category=...`) 로 부르는 주소!
@WebServlet("/lounge-api")
public class ReviewLoungeApiC extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");

        // 프론트에서 "all", "photo", "비타민 C" 등 뭘 보냈는지 꺼내기
        String category = request.getParameter("category");

        // DAO한테 "이 카테고리 베스트 리뷰 찾아와!" 시키기
        ArrayList<ReviewDTO> list = ReviewDAO.RDAO.getLoungeFilterReviews(category);

        // JSON으로 변환해서 화면에 쏴주기
        response.getWriter().write(new Gson().toJson(list));
    }
}