package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "UserLogoutC", value = "/logout")
public class UserLogoutC extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 세션 무효화
        req.getSession().invalidate();

        // 로그인 페이지로 리다이렉트(바로 이동)
        resp.sendRedirect(req.getContextPath() + "/index.jsp");
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

        request.getSession().invalidate();

        response.sendRedirect(request.getContextPath() + "/index.jsp");
        
        Boolean redirectJoin = (Boolean) request.getAttribute("redirectJoin");
        if (redirectJoin != null && redirectJoin) {
            response.sendRedirect("user/join.jsp");
        } else {
            response.sendRedirect("index.jsp");
        }
    }

    public void destroy() {
    }
}