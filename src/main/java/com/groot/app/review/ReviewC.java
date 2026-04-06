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

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 1. DAO가 데이터를 가져오게 시킴
        ReviewDAO.RDAO.getAllReview(request);

        // 🌟 추가: JSP에서 쓸 'reviews'라는 이름으로 리스트를 명시적으로 꺼내서 다시 확인하거나,
        // DAO 내부에서 request.setAttribute("reviews", list)를 했는지 확인해봐야 해.
        // 만약 DAO 안에서 "reviews"로 담았다면 아래 totalCount만 추가해!

        // 리뷰 별점 통계
        Map<Integer, Integer> starStats = ReviewDAO.getStarStats(101);
        request.setAttribute("starStats", starStats);

        // 🌟 추가: 전체 개수를 미리 계산해서 보내주면 JSP가 훨씬 편해함!
        // 만약 DAO에서 리스트를 "reviews"라는 이름으로 담았다면:
        List<ReviewDTO> list = (List<ReviewDTO>) request.getAttribute("reviews");
        int totalCount = (list != null) ? list.size() : 0;
        request.setAttribute("totalCount", totalCount);

        request.setAttribute("content", "review/review.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    public void destroy() {
    }
}