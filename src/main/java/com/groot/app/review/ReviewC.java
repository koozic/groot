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

        // 🚦 1. 비동기(Ajax) 손님이면? "DAO야, 네가 알아서 데이터 쏴주고 끝내!"
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            ReviewDAO.RDAO.getSortedReviewsAjax(request, response);
            return; // 🛑 페이지 이동 안 하고 여기서 즉시 종료! (쌤 스타일)
        }

        // 🚦 2. 일반 손님이면? "DAO야, 가방에 짐(데이터) 싸라!"
        int pId = Integer.parseInt(request.getParameter("PRODUCT_ID"));

        // 1. 정렬 조건 파라미터 받기 (처음 들어오면 null일 거야)
        String sortType = request.getParameter("sortType");
        if (sortType == null || sortType.equals("")) {
            sortType = "like"; // 🌟 여기서 "like"로 기본값을 딱!
        }

        // 2. 가방 채우기
        request.setAttribute("allPhotoImages", ReviewDAO.RDAO.getAllPhotoImages(pId));

        // 🌟 "date" 대신 우리가 정한 sortType 변수를 넣어줘!
        ReviewDAO.RDAO.getAllReview(request, pId, sortType, 0);

        ReviewDAO.getReviewStats(request, pId);

        // 🚦 3. 자, 이제 JSP 화면으로 안내해!
        request.setAttribute("content", "review/review.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}