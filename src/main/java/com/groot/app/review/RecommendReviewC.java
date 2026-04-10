package com.groot.app.review;

import com.google.gson.Gson;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet("/recommend-reviews")
public class RecommendReviewC extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");

        // 프론트에서 넘어온 영어 데이터 그대로 받기
        String[] supps = request.getParameterValues("supp");
        String isDef = request.getParameter("isDef");
        String limitStr = request.getParameter("limit");
        int limit = (limitStr != null) ? Integer.parseInt(limitStr) : 3;

        // 모든 복잡한 처리는 DAO에게 위임! (통역 포함)
        ArrayList<ReviewDTO> list;
        if ("true".equals(isDef)) {
            list = ReviewDAO.RDAO.getDeficiencyBestReviews(supps, limit);
        } else {
            list = ReviewDAO.RDAO.getCustomBestReviews(supps);
        }

        Gson gson = new Gson();
        response.getWriter().write(gson.toJson(list));
    }
}