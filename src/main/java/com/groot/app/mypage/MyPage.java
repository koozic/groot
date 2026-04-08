package com.groot.app.mypage;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "MyPage", value = "/mypage")
public class MyPage extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // HomeServlet.java 예시
        request.setAttribute("content", "mypage/mypage.jsp");
        request.setAttribute("activeTab", "home");
        request.getRequestDispatcher("index.jsp").forward(request, response);

    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {


    }
    public void destroy() {
    }
}