package com.groot.app.supplements;

import com.groot.app.user.UserDTO; // 유저 정보 객체를 쓰기 위해 임포트
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

// 1. 클래스 껍데기를 없애고 서블릿을 바로 선언합니다.
@WebServlet("/supplementsLike")
public class SupplementsLikeC extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);

        // 2. [핵심 수정] UserDAO에서 저장한 이름인 "loginUser"로 객체를 꺼냅니다.
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("loginUser") : null;

        // 로그인 체크
        if (loginUser == null) {
            out.print("{\"status\":\"error\",\"message\":\"로그인이 필요합니다.\"}");
            return;
        }

        // 3. [핵심 수정] 꺼낸 객체 안에서 진짜 아이디를 추출합니다.
        String userId = loginUser.getUser_id();

        // 브라우저에서 보낸 영양제 고유번호 받기
        String idParam = request.getParameter("supplementId");

        if (idParam == null) {
            out.print("{\"status\":\"error\",\"message\":\"잘못된 요청입니다.\"}");
            return;
        }

        try {
            int supplementId = Integer.parseInt(idParam);

            // DAO 실행 (좋아요 토글)
            String result = SupplementsDAO.SDAO.supplementLike(userId, supplementId);

            // 결과 반환 ("liked" 또는 "unliked")
            out.print("{\"status\":\"" + result + "\"}");

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\",\"message\":\"숫자 형식이 아닙니다.\"}");
        }
    }
}