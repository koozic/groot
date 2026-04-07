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
<<<<<<< HEAD

=======
>>>>>>> 7eb826f7e6d960133475f3008b130016d3af5898

        resp.sendRedirect("user/login.jsp");
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        boolean isSuccess = UserDAO.Login(request);

        if (isSuccess) {
            // 2-1. 로그인 성공: 메인 페이지(또는 성공 후 보여줄 페이지)로 이동 (보통 Redirect 사용)
            response.sendRedirect("index.jsp");
        } else {
            // 2-2. 로그인 실패: 다시 로그인 페이지로 포워딩 (Forward)
            // request.setAttribute에 담긴 "loginMsg"가 유지되어 로그인 창에 에러 문구를 띄울 수 있음
            request.getRequestDispatcher("user/login.jsp").forward(request, response);
        }

    }


    public void destroy() {
    }
}