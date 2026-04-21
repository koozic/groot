package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "UserEmailCheckC", value = "/user.email.check")
public class UserEmailCheckC extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain; charset=UTF-8");

        String userEmail = request.getParameter("user_email");
        PrintWriter out = response.getWriter();

        if (userEmail == null || userEmail.trim().isEmpty()) {
            out.print("ERROR");
            return;
        }

        boolean isDuplicate = UserDAO.checkUserEmailDuplicate(userEmail.trim());
        out.print(isDuplicate ? "DUPLICATE" : "OK");
    }
}
