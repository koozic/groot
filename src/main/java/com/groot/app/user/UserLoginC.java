package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "UserLoginC", value = "/user-Login")
public class UserLoginC extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        // redirect 파라미터가 있으면 login.jsp로 포워딩해서 파라미터 유지
        String redirect = req.getParameter("redirect");
        if (redirect != null && !redirect.trim().isEmpty()) {
            // sendRedirect 대신 forward → ${param.redirect} 그대로 유지됨
            req.getRequestDispatcher("user/login.jsp").forward(req, resp);
        } else {
            resp.sendRedirect("user/login.jsp");
        }
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        boolean isSuccess = UserDAO.Login(request);

        if (isSuccess) {
            // redirect 파라미터가 있으면 그쪽으로, 없으면 기본 홈으로
            String redirect = request.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty()
                    && !redirect.contains("//")      // 오픈 리다이렉트 방지
                    && !redirect.startsWith("http")) {
                response.sendRedirect(redirect);
            } else {
                response.sendRedirect("hello-servlet");
            }
        } else {
            request.getRequestDispatcher("user/login.jsp").forward(request, response);
        }

    }


    public void destroy() {
    }
}