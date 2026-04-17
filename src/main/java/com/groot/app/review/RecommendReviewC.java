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
        response.setCharacterEncoding("UTF-8");

        String[] supps = request.getParameterValues("supp");
        String limitStr = request.getParameter("limit");
        int limit = 1;

        try {
            if (limitStr != null && !limitStr.isBlank()) {
                limit = Math.max(1, Integer.parseInt(limitStr));
            }
        } catch (NumberFormatException ignored) {
            limit = 1;
        }

        ArrayList<ReviewDTO> list = ReviewDAO.RDAO.getBestReviewsBySupplements(supps, limit);
        Gson gson = new Gson();
        response.getWriter().write(gson.toJson(list));
    }
}
