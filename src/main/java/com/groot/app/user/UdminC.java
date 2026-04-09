package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "UdminC", value = "/udmin")
public class UdminC extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. 어떤 요청인지 확인
        String action = request.getParameter("action");

        // --- [기존 사용자 관련 로직 처리 부분] ---
        if ("login".equals(action)) {
            // 기존 로그인 처리 로직
        } else if ("register".equals(action)) {
            // 기존 회원가입 처리 로직
        }

        // --- [임시 관리자 로직 추가 부분] ---
        else if ("admin".equals(action) || "adminForm".equals(action)) {

            // 2. 임시 관리자 인증 (URL 파라미터로 '?devAdmin=true'가 있는지 확인)
            String devAdmin = request.getParameter("devAdmin");

            if (!"true".equals(devAdmin)) {
                // 관리자 패스가 없으면 접근 거부
                response.setContentType("text/html; charset=UTF-8");
                response.getWriter().write("<script>alert('관리자 권한이 없습니다.'); history.back();</script>");
                return; // 중요: 여기서 멈춰야 아래 로직이 실행 안 됨
            }

            // 3. 관리자 기능 분기
            if ("admin".equals(action)) {
                // TODO: DB에서 영양소 목록(suppList)을 조회하는 코드 작성
                // List<Supplement> suppList = dao.getAllSupplements();
                // request.setAttribute("suppList", suppList);

                request.getRequestDispatcher("admin_main.jsp").forward(request, response);

            } else if ("adminForm".equals(action)) {
                String suppId = request.getParameter("suppId");

                if (suppId != null) {
                    // 수정 모드: DB에서 기존 데이터 조회
                    // Supplement supp = dao.getSupplementById(suppId);
                    // request.setAttribute("supp", supp);
                }
                // 등록 모드일 때는 아무 데이터 없이 포워딩
                request.getRequestDispatcher("admin_form.jsp").forward(request, response);
            }
        }
    }
    public void destroy() {
    }
}