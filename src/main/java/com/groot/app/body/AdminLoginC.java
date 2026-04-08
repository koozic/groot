package com.groot.app.body;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AdminLoginC", value = {"/admin_login", "/admin_login_view"})
public class AdminLoginC extends HttpServlet {

    private final AdminLoginDAO dao = new AdminLoginDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 로그인 페이지 이동
        request.getRequestDispatcher("body/admin_login.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String adminId = request.getParameter("adminId");
        String adminPw = request.getParameter("adminPw");

        try {
            AdminDTO admin = dao.login(adminId, adminPw);

            if (admin != null) {
                // ✅ 로그인 성공: 세션에 adminId 저장
                HttpSession session = request.getSession();
                session.setAttribute("adminId", admin.getAdminId());
                session.setAttribute("adminName", admin.getAdminName());

                response.sendRedirect("admin"); // 관리자 메인으로 이동
            } else {
                // 로그인 실패: 다시 로그인 페이지
                request.setAttribute("errorMsg", "아이디 또는 비밀번호가 틀렸습니다.");
                request.getRequestDispatcher("body/admin_login.jsp")
                        .forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "로그인 처리 오류");
        }
    }
}