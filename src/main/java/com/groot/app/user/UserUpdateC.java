package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "UserUpdateC", value = "/user-update")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)

public class UserUpdateC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        UserDAO.UserUpdate(req);
        Boolean redirectJoin = (Boolean) req.getAttribute("redirectJoin");
        if (redirectJoin != null && redirectJoin) {
            resp.sendRedirect("user/login.jsp");
        } else {
            resp.sendRedirect("index.jsp");
        }



    }

    public void destroy() {
    }
}