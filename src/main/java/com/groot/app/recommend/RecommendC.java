package com.groot.app.recommend;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RecommendC", value = "/recommend")
public class RecommendC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // 탭 활성화 상태를 전달 (index.jsp의 active 클래스 제어용)
        request.setAttribute("activeTab", "recommend");

        // 선택 페이지로 포워딩
        request.getRequestDispatcher("recommend/recommend.jsp").forward(request, response);

    }

    public void destroy() {
    }
}