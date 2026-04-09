package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "UserIdCheckC", value = "/user.id.check")
public class UserIdCheckC extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");
        
        String userId = request.getParameter("user_id");
        PrintWriter out = response.getWriter();
        
        if (userId == null || userId.trim().isEmpty()) {
            out.print("ERROR");
            return;
        }
        
        // DAO를 통해 아이디 중복 확인
        boolean isDuplicate = UserDAO.checkUserIdDuplicate(userId.trim());
        
        if (isDuplicate) {
            out.print("DUPLICATE");
        } else {
            out.print("OK");
        }
    }
    
    public void destroy() {
    }
}
