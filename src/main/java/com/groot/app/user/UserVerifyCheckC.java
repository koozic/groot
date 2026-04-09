package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/email-auth-check")
public class UserVerifyCheckC extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String email = request.getParameter("user_email");
        String inputCode = request.getParameter("email_code");

        HttpSession session = request.getSession();
        String savedEmail = (String) session.getAttribute("emailAuthEmail");
        String savedCode = (String) session.getAttribute("emailAuthCode");

        if (savedEmail != null && savedCode != null
                && savedEmail.equals(email)
                && savedCode.equals(inputCode)) {

            session.setAttribute("emailAuthVerified", true);
            response.getWriter().write("{\"result\":\"success\"}");
        } else {
            session.setAttribute("emailAuthVerified", false);
            response.getWriter().write("{\"result\":\"fail\"}");
        }
    }
}
