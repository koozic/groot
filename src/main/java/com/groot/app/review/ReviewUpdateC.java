package com.groot.app.review;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ReviewUpdateC")
public class ReviewUpdateC extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // DAO의 updateReview가 실행되고 결과(true/false)를 리턴함
        if (ReviewDAO.RDAO.updateReview(request)) {
            response.getWriter().print("1"); // 🌟 JS한테 "성공!"이라고 말해줌
        } else {
            response.getWriter().print("0"); // 🌟 "실패!"
        }
    }
}