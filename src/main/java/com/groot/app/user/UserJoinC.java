package com.groot.app.user;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "UserJoinC", value = "/user-join")
public class UserJoinC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

       response.sendRedirect("user/join.jsp");
    }

    public void destroy() {
    }
}