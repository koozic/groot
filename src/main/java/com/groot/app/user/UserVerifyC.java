package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;

@WebServlet("/user/email-auth-send")
public class UserVerifyC extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String email = request.getParameter("user_email");

        if (email == null || email.trim().isEmpty()) {
            response.getWriter().write("{\"result\":\"fail\", \"msg\":\"email empty\"}");
            return;
        }

        String authCode = String.valueOf(100000 + new Random().nextInt(900000));

        HttpSession session = request.getSession();
        session.setAttribute("emailAuthCode", authCode);
        session.setAttribute("emailAuthEmail", email);
        session.setAttribute("emailAuthVerified", false);

        try {
            MailSender.sendAuthMail(email, authCode);
            response.getWriter().write("{\"result\":\"success\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"result\":\"fail\", \"msg\":\"send error\"}");
        }
    }
}