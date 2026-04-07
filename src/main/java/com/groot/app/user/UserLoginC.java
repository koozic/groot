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


        resp.sendRedirect("user/login.jsp");
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        UserDAO.Login(request);
        
        Boolean redirectJoin = (Boolean) request.getAttribute("redirectJoin");
        if (redirectJoin != null && redirectJoin) {
            response.sendRedirect("user/join.jsp");
        } else {
            response.sendRedirect("index.jsp");
        }

        UserDAO.ProfileUpdate(request);











    }

    public void destroy() {
    }
}